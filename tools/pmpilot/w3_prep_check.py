"""BUILD-07 local dry run: for each pinned w3 variant, make a detached worktree at the pinned SHA (read only use),
check the allowlist diff, ART-07/ART-08 rules, inventory, launcher/fixture agreement. No export, nothing published."""
from pathlib import Path
import argparse, json, subprocess, sys, tempfile
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import pins as pinlib, w3_inventory, build_package as bp  # noqa: E402


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--repo', type=Path, required=True)
    ap.add_argument('--variants', default='w3-control,w3-transition,w3-level,w3-art')
    ap.add_argument('--work', type=Path, default=Path(tempfile.mkdtemp(prefix='w3prep-')))
    a = ap.parse_args()
    pins = pinlib.load()
    demos_doc = json.loads((HERE / 'demos.json').read_text(encoding='utf-8'))
    report, bad = {}, 0
    for name in a.variants.split(','):
        spec = pins['variants'][name]
        commit = spec.get('commit')
        if not commit:
            report[name] = {'skipped': 'no pinned commit'}
            continue
        wt = a.work / name
        pinlib.git(a.repo, 'worktree', 'add', '--detach', '--force', str(wt), commit)
        try:
            diff = pinlib.diff_check(pins, name, wt)
            inv = w3_inventory.build(wt, name, commit, pinlib.git(wt, 'rev-parse', 'HEAD^{tree}'), spec)
            demos = bp.resolve_demos(demos_doc, spec)
            fx = []
            for d in demos:
                if d.get('seed') is not None and d.get('fixture_check'):
                    f = bp.first_existing(wt, d['fixture_check'])
                    same = None if not f else json.loads((wt / f).read_text()) == bp.seed_for(d['seed'], demos_doc['save_version'])
                    fx.append(dict(demo=d['name'], fixture=f, equals_generated_seed=same))
            for kind in ('windows', 'macos'):
                for d in demos:
                    bp.launcher_text(kind, 'X.exe', name, d, d.get('seed') is not None)
            tree_ok = (not spec.get('expected_tree')) or spec['expected_tree'] == pinlib.git(wt, 'rev-parse', 'HEAD^{tree}')
            r = dict(commit=commit, changed=len(diff['changed']), diff_violations=diff['violations'], inventory_problems=inv['problems'],
                     art08=(inv['art08']['manifest'] or {}).get('label_counts'), ld05=bool(inv['ld05']), tr08=inv['tr08']['tr08_present'],
                     tr08_flags=sorted(inv['tr08']['flags']), fixtures=fx, expected_tree_ok=tree_ok)
            if diff['violations'] or inv['problems'] or not tree_ok or any(x['equals_generated_seed'] is False for x in fx):
                bad += 1
            report[name] = r
        finally:
            pinlib.git(a.repo, 'worktree', 'remove', '--force', str(wt), check=False)
    print(json.dumps(report, indent=2))
    raise SystemExit(1 if bad else 0)


if __name__ == '__main__':
    main()
