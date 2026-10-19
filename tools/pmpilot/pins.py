"""Source pins for PM pilot comparison packages: validation, planning, assembly.

A variant is either an exact commit pin ("commit") or a deterministic composition
("compose": base commit plus ordered member variants merged with --no-ff). No
variant is buildable until every SHA it needs is a 40-hex pin; null means the
owning agent has not supplied it yet.
"""
from pathlib import Path
import argparse, fnmatch, json, os, re, subprocess, sys

HERE = Path(__file__).resolve().parent
SHA = re.compile(r'[0-9a-f]{40}')
KINDS = ('baseline', 'control', 'candidate', 'combined')
SMOKE_KINDS = ('baseline', 'control')
FIXED_DATE = '2026-01-01T00:00:00+00:00'
# Gameplay files a comparison candidate may not touch unless the pin names them in allow_protected.
PROTECTED = ['scripts/player.gd', 'scripts/guard.gd', 'scripts/storm_keeper.gd', 'scripts/momentum_profile.gd',
             'project.godot', 'export_presets.cfg', 'addons/**']
ART07 = ['assets/art07/**', 'tools/art07/**']


def load(path=None):
    return json.loads(Path(path or HERE / 'pins.json').read_text(encoding='utf-8'))


def matches(path, patterns):
    for pat in patterns or []:
        if pat.endswith('/**'):
            if path.startswith(pat[:-2]):
                return True
        elif fnmatch.fnmatchcase(path, pat):
            return True
    return False


def git(root, *args, check=True):
    r = subprocess.run(['git', '-c', 'safe.directory=*', '-C', str(root), *args], capture_output=True)
    if check and r.returncode:
        raise SystemExit('git %s failed: %s' % (' '.join(args), r.stderr.decode(errors='replace')))
    return r.stdout.decode(errors='replace').strip()


def resolve(pins, name, _seen=()):
    """Return (commit_or_none, members, problems) for a variant."""
    v = pins['variants'][name]
    problems = []
    if name in _seen:
        return None, [], ['composition cycle at ' + name]
    if 'compose' in v:
        c = v['compose']
        base = c.get('base')
        if not (base and SHA.fullmatch(base)):
            problems.append(name + ': compose.base is not a 40-hex SHA')
        members = []
        for m in c.get('merge', []):
            commit, _, p = resolve(pins, m, _seen + (name,))
            problems += p
            if commit:
                members.append((m, commit))
            else:
                problems.append(name + ': member ' + m + ' has no pinned commit')
        return None, members, problems
    commit = v.get('commit')
    if not (commit and SHA.fullmatch(commit)):
        problems.append(name + ': commit is not pinned (' + repr(commit) + ')')
        return None, [], problems
    return commit, [], problems


def allowed_paths(pins, name):
    v = pins['variants'][name]
    ap = v.get('allowed_paths')
    if ap == 'union':
        out = []
        for m in v['compose']['merge']:
            out += allowed_paths(pins, m) or []
        return sorted(set(out))
    return ap


def validate(pins, names, purpose):
    problems = []
    if pins.get('schema') != 1:
        problems.append('unsupported pins schema')
    for name in names:
        if name not in pins['variants']:
            problems.append('unknown variant ' + name)
            continue
        v = pins['variants'][name]
        if v.get('kind') not in KINDS:
            problems.append(name + ': bad kind')
        if purpose == 'preparation-smoke' and v.get('kind') not in SMOKE_KINDS:
            problems.append(name + ': candidate and combined variants are not allowed in a preparation-smoke run')
        _, _, p = resolve(pins, name)
        problems += p
        if v.get('kind') in ('candidate', 'combined'):
            ap = allowed_paths(pins, name)
            if not isinstance(ap, list) or not ap:
                problems.append(name + ': allowed_paths must be supplied by the owning agent')
            if not (v.get('compare_base') and SHA.fullmatch(v['compare_base'])) and 'compose' not in v:
                problems.append(name + ': compare_base missing')
    return problems


def assemble(pins, name, root):
    """Make `root` (a full-history clone) a clean detached checkout of the variant. Returns record."""
    v = pins['variants'][name]
    commit, members, problems = resolve(pins, name)
    if problems:
        raise SystemExit('; '.join(problems))
    env_date = {'GIT_AUTHOR_DATE': FIXED_DATE, 'GIT_COMMITTER_DATE': FIXED_DATE}
    for k, val in env_date.items():
        os.environ[k] = val
    if 'compose' in v:
        base = v['compose']['base']
        git(root, 'checkout', '--detach', '--force', base)
        order = []
        for mname, mcommit in members:
            r = subprocess.run(['git', '-c', 'safe.directory=*', '-c', 'user.name=pmpilot', '-c', 'user.email=pmpilot@invalid',
                                '-C', str(root), 'merge', '--no-ff', '--no-edit', '-m', 'pmpilot compose ' + mname, mcommit],
                               capture_output=True)
            if r.returncode:
                git(root, 'merge', '--abort', check=False)
                raise SystemExit('composition failed merging %s (%s): %s %s' % (mname, mcommit, r.stdout.decode(errors='replace'), r.stderr.decode(errors='replace')))
            order.append({'variant': mname, 'commit': mcommit})
        record = {'variant': name, 'mode': 'compose', 'base': base, 'merged': order}
    else:
        git(root, 'checkout', '--detach', '--force', commit)
        record = {'variant': name, 'mode': 'commit', 'commit': commit}
    head = git(root, 'rev-parse', 'HEAD')
    tree = git(root, 'rev-parse', 'HEAD^{tree}')
    expected = v.get('expected_tree')
    if expected and expected != tree:
        raise SystemExit('tree mismatch for %s: pinned %s, assembled %s' % (name, expected, tree))
    record.update(head=head, tree=tree, expected_tree=expected)
    return record


def diff_check(pins, name, root):
    """Preservation by diff: every change against compare_base must be allowlisted."""
    v = pins['variants'][name]
    base = v.get('compare_base') or (v['compose']['base'] if 'compose' in v else None)
    if not base:
        return {'compared_to': None, 'changed': [], 'violations': [], 'note': 'baseline pin: nothing to compare'}
    rows = git(root, 'diff', '--name-status', '--no-renames', base, 'HEAD').splitlines()
    changed = [(r.split('\t')[0], r.split('\t', 1)[1]) for r in rows if r]
    allow = allowed_paths(pins, name) or []
    protect_ok = v.get('allow_protected', [])
    violations = []
    for status, path in changed:
        if matches(path, ART07):
            violations.append(path + ': ART-07 path in source diff')
        elif matches(path, PROTECTED) and not matches(path, protect_ok):
            violations.append(path + ': protected gameplay file changed without allow_protected')
        elif not matches(path, allow):
            violations.append(path + ': outside allowed_paths')
    return {'compared_to': base, 'changed': [list(c) for c in changed], 'allowed_paths': allow,
            'allow_protected': protect_ok, 'violations': violations}


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest='cmd', required=True)
    a = sub.add_parser('plan')
    a.add_argument('--variants')
    a.add_argument('--purpose', choices=['preparation-smoke', 'comparison'])
    a.add_argument('--platforms', choices=['windows', 'macos', 'both'])
    a.add_argument('--quick', default='')
    a.add_argument('--request', help='request.json used when the other options are not given (pull_request events)')
    a.add_argument('--pins')
    b = sub.add_parser('assemble')
    b.add_argument('--variant', required=True)
    b.add_argument('--source-root', type=Path, required=True)
    b.add_argument('--pins')
    c = sub.add_parser('check-diff')
    c.add_argument('--variant', required=True)
    c.add_argument('--source-root', type=Path, required=True)
    c.add_argument('--pins')
    args = p.parse_args()
    pins = load(args.pins)
    if args.cmd == 'plan':
        req = {}
        if args.request and Path(args.request).is_file():
            req = json.loads(Path(args.request).read_text(encoding='utf-8'))
        variants = args.variants or req.get('variants', 'baseline-pr39')
        purpose = args.purpose or req.get('purpose', 'preparation-smoke')
        platforms = args.platforms or req.get('platforms', 'both')
        quick = (args.quick or str(req.get('quick', False))).lower() in ('1', 'true', 'yes')
        names = [n.strip() for n in variants.split(',') if n.strip()]
        problems = validate(pins, names, purpose)
        if purpose == 'comparison' and quick:
            problems.append('quick is not allowed for comparison packages')
        if problems:
            print('PLAN REFUSED:\n  ' + '\n  '.join(problems), file=sys.stderr)
            raise SystemExit(2)
        out = {'variants': json.dumps(names), 'purpose': purpose, 'platforms': platforms, 'quick': '1' if quick else '0',
               'windows': 'true' if platforms in ('windows', 'both') else 'false', 'macos': 'true' if platforms in ('macos', 'both') else 'false'}
        print(json.dumps(out))
        if os.environ.get('GITHUB_OUTPUT'):
            with open(os.environ['GITHUB_OUTPUT'], 'a', encoding='utf-8') as f:
                for k, v in out.items():
                    f.write('%s=%s\n' % (k, v))
    elif args.cmd == 'assemble':
        print(json.dumps(assemble(pins, args.variant, args.source_root), indent=2))
    else:
        r = diff_check(pins, args.variant, args.source_root)
        print(json.dumps(r, indent=2))
        raise SystemExit(1 if r['violations'] else 0)


if __name__ == '__main__':
    main()
