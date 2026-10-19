#!/usr/bin/env python3
"""PM-pilot independent QA runner (test-only). One command, one JSON result.

  python3 tools/pm_pilot_qa/run_qa.py --repo /path/to/worktree          --label cand-a
  python3 tools/pm_pilot_qa/run_qa.py --commit <sha> [--fetch-from URL] --label pr39 [--borrow-tr06]

The harness (tests/pm_pilot_qa.gd) is read from THIS checkout and passed to Godot by absolute path, so
the target worktree is never modified except for Godot's own import cache and untracked .import files.
Results are categorised, never merged: automated_headless, graphical, human, platform, untested.
"""
import argparse, datetime, hashlib, json, os, re, shutil, subprocess, sys, tempfile, time
from pathlib import Path

QA = Path(__file__).resolve().parents[2]
GODOT_DEFAULT = os.environ.get('GODOT', '/home/claude/godot_bin/Godot_v4.6.1-stable_linux.x86_64')
LINE = re.compile(r'^(PASS|FAIL|SKIP): \[([^\]]+)\] (.*)$')


def sh(cmd, cwd=None, env=None, timeout=None, log=None):
    t0 = time.monotonic()
    try:
        if log:
            with open(log, 'wb') as f:
                rc = subprocess.run(cmd, cwd=cwd, env=env, stdout=f, stderr=subprocess.STDOUT, timeout=timeout).returncode
        else:
            p = subprocess.run(cmd, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
            rc = p.returncode
            return rc, p.stdout.decode(errors='replace'), round(time.monotonic() - t0, 1)
    except subprocess.TimeoutExpired:
        rc = 124
    return rc, '', round(time.monotonic() - t0, 1)


def profile_env(profile):
    env = os.environ.copy()
    for k in ('HOME', 'APPDATA', 'XDG_DATA_HOME', 'XDG_CONFIG_HOME', 'XDG_CACHE_HOME'):
        env[k] = str(profile)
    return env


def parse_harness(text):
    sections, order = {}, []
    for line in text.splitlines():
        m = LINE.match(line)
        if not m:
            continue
        kind, sec, label = m.groups()
        s = sections.setdefault(sec, dict(pass_=0, fail=0, skip=0, failures=[], skips=[]))
        if sec not in order:
            order.append(sec)
        if kind == 'PASS':
            s['pass_'] += 1
        elif kind == 'FAIL':
            s['fail'] += 1
            s['failures'].append(label)
        else:
            s['skip'] += 1
            s['skips'].append(label)
    for s in sections.values():
        s['pass'] = s.pop('pass_')
    return {k: sections[k] for k in order}


def errors(text):
    return len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load', text, re.M))


def run_godot_harness(godot, repo, out, name, extra, rendered, timeout, hooks):
    profile = Path(tempfile.mkdtemp(prefix='pmqa-profile-'))
    cmd = []
    if rendered:
        cmd += ['xvfb-run', '-a', '-s', '-screen 0 1280x720x24']
    cmd += [godot, '--path', str(repo), '--fixed-fps', '60']
    cmd += ['--rendering-method', 'gl_compatibility', '--rendering-driver', 'opengl3', '--resolution', '1280x720'] if rendered else ['--headless']
    cmd += ['--script', str(QA / 'tests/pm_pilot_qa.gd'), '--', '--qa-hooks=' + str(hooks)] + extra
    log = out / (name + '.log')
    rc, _, secs = sh(cmd, cwd=repo, env=profile_env(profile), timeout=timeout, log=log)
    shutil.rmtree(profile, ignore_errors=True)
    text = log.read_text(errors='replace')
    secs_map = parse_harness(text)
    tot = dict(pass_=sum(s['pass'] for s in secs_map.values()), fail=sum(s['fail'] for s in secs_map.values()), skip=sum(s['skip'] for s in secs_map.values()))
    platform = re.search(r'^PLATFORM: (.*)$', text, re.M)
    return dict(name=name, exit=rc, seconds=secs, passes=tot['pass_'], failures=tot['fail'], skips=tot['skip'],
                script_errors=errors(text), sections=secs_map, platform=platform.group(1) if platform else None,
                log=str(log.relative_to(out.parent) if out.parent in log.parents else log), command=cmd)


def run_stock(godot, repo, out, label_prefix, timeout):
    """Run the target's own stock runners if present; copy their logs and results."""
    rows = {}
    runner = repo / 'tools/run_tr05_qa.py'
    if runner.exists():
        rc, _, secs = sh([sys.executable, str(runner), '--godot', godot], cwd=repo, timeout=timeout, log=out / (label_prefix + 'run_tr05_qa.log'))
        res = repo / 'build/tr05/qa/results.json'
        suites = json.loads(res.read_text()) if res.exists() else []
        dest = out / (label_prefix + 'tr05_suites')
        dest.mkdir(exist_ok=True)
        for s in suites:
            lg = repo / 'build/tr05/qa' / (s['suite'] + '.log')
            if lg.exists():
                shutil.copy(lg, dest / lg.name)
        (dest / 'results.json').write_text(json.dumps(suites, indent=2))
        rows['tr05_suites'] = dict(exit=rc, seconds=secs, suites=len(suites),
                                   assertions_passed=sum(s['passes'] for s in suites), assertions_failed=sum(s['failures'] for s in suites),
                                   script_errors=sum(s['script_errors'] for s in suites),
                                   suites_failed=[s['suite'] for s in suites if s['exit'] or s['failures'] or s['script_errors']],
                                   per_suite=[{k: s[k] for k in ('suite', 'exit', 'passes', 'failures', 'script_errors', 'legacy')} for s in suites])
    for tool in ('verify_baseline.py', 'verify_tr05_preservation.py'):
        t = repo / 'tools' / tool
        if t.exists():
            rc, text, secs = sh([sys.executable, str(t)], cwd=repo, timeout=600)
            (out / (label_prefix + tool + '.log')).write_text(text)
            rows[tool] = dict(exit=rc, seconds=secs, passes=len(re.findall(r'^PASS', text, re.M)), failures=len(re.findall(r'^FAIL', text, re.M)))
    return rows


def main():
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--repo')
    g.add_argument('--commit')
    ap.add_argument('--fetch-from', default='origin', help='remote or URL used to fetch --commit if absent')
    ap.add_argument('--label', required=True)
    ap.add_argument('--godot', default=GODOT_DEFAULT)
    ap.add_argument('--out', help='output dir (default docs/pm_pilot/qa/runs/<label>)')
    ap.add_argument('--hooks', default=str(QA / 'tools/pm_pilot_qa/hooks'))
    ap.add_argument('--rendered', action='store_true', help='also run the harness under xvfb + software GL (graphical category)')
    ap.add_argument('--rendered-sections', default='start,issue42,reduced', help='sections for the software-GL run (the full suite runs in real time and takes over an hour); use all for everything')
    ap.add_argument('--no-stock', action='store_true')
    ap.add_argument('--no-import', action='store_true')
    ap.add_argument('--borrow-tr06', action='store_true', help='copy PR51 author test+runner from this checkout into a temp --commit worktree and run them')
    ap.add_argument('--timeout', type=int, default=1800)
    ap.add_argument('--keep', action='store_true')
    a = ap.parse_args()

    out = Path(a.out) if a.out else QA / 'docs/pm_pilot/qa/runs' / a.label
    out.mkdir(parents=True, exist_ok=True)
    temp = None
    if a.commit:
        rc, _, _ = sh(['git', 'cat-file', '-e', a.commit + '^{commit}'], cwd=QA)
        if rc:
            rc, text, _ = sh(['git', 'fetch', '--depth=1', a.fetch_from, a.commit], cwd=QA, timeout=300)
            if rc:
                sys.exit('fetch failed: ' + text)
        temp = Path(tempfile.mkdtemp(prefix='pmqa-wt-')) / 'wt'
        rc, text, _ = sh(['git', 'worktree', 'add', '--detach', str(temp), a.commit], cwd=QA, timeout=300)
        if rc:
            sys.exit('worktree add failed: ' + text)
        repo = temp
    else:
        repo = Path(a.repo).resolve()
    head = sh(['git', 'rev-parse', 'HEAD'], cwd=repo)[1].strip()
    dirty = sh(['git', 'status', '--porcelain', '--untracked-files=no'], cwd=repo)[1].strip().splitlines()
    result = dict(label=a.label, started=datetime.datetime.now(datetime.timezone.utc).isoformat(), repo=str(repo), head=head,
                  tracked_modifications=dirty, qa_harness_sha256=hashlib.sha256((QA / 'tests/pm_pilot_qa.gd').read_bytes()).hexdigest(),
                  qa_checkout_head=sh(['git', 'rev-parse', 'HEAD'], cwd=QA)[1].strip(),
                  engine=sh([a.godot, '--version'])[1].strip())
    try:
        borrowed = {}
        if a.borrow_tr06 and temp:
            for rel in ('tests/automatic_passage_reliability.gd', 'tests/fixtures/transition_test_hud.gd', 'tools/run_tr06_qa.py'):
                src = QA / rel
                (repo / rel).parent.mkdir(parents=True, exist_ok=True)
                shutil.copy(src, repo / rel)
                borrowed[rel] = hashlib.sha256(src.read_bytes()).hexdigest()
        if not a.no_import:
            rc, _, secs = sh([a.godot, '--headless', '--path', str(repo), '--import'], cwd=repo, timeout=900)
            result['import'] = dict(exit=rc, seconds=secs)
        head_run = run_godot_harness(a.godot, repo, out, 'harness_headless', [], False, a.timeout, a.hooks)
        cli_off = run_godot_harness(a.godot, repo, out, 'harness_reduced_cli_off', ['--qa-sections=reduced_cli'], False, 300, a.hooks)
        cli_on = run_godot_harness(a.godot, repo, out, 'harness_reduced_cli_on', ['--qa-sections=reduced_cli', '--qa-expect-reduced', '--tr05-reduced-motion'], False, 300, a.hooks)
        auto = dict(harness=head_run, reduced_cli_default=cli_off, reduced_cli_flag=cli_on)
        if not a.no_stock:
            auto['stock'] = run_stock(a.godot, repo, out, '', a.timeout)
        if (repo / 'tests/automatic_passage_reliability.gd').exists() and (repo / 'tools/run_tr06_qa.py').exists():
            # PR51 author's own real-input test (native in PR51 and descendants, borrowed into a temp PR39 worktree).
            rc, text, secs = sh([sys.executable, 'tools/run_tr06_qa.py', '--godot', a.godot, '--label', 'author'], cwd=repo, timeout=900)
            lg = repo / 'build/tr06/author.log'
            if lg.exists():
                shutil.copy(lg, out / 'author_tr06.log')
            js = repo / 'build/tr06/author.json'
            auto['author_tr06_test'] = dict(exit=rc, seconds=secs, borrowed=bool(borrowed), borrowed_files_sha256=borrowed,
                                            test_sha256=hashlib.sha256((repo / 'tests/automatic_passage_reliability.gd').read_bytes()).hexdigest(),
                                            summary=json.loads(js.read_text()) if js.exists() else None)
        result['automated_headless'] = auto
        graphical = None
        if a.rendered:
            if shutil.which('xvfb-run'):
                graphical = run_godot_harness(a.godot, repo, out, 'harness_graphical_swgl', [] if a.rendered_sections == 'all' else ['--qa-sections=' + a.rendered_sections], True, a.timeout, a.hooks)
            else:
                graphical = dict(skipped='xvfb-run not available')
        result['graphical'] = graphical if graphical else dict(skipped='not requested (--rendered)')
    finally:
        if temp and not a.keep:
            sh(['git', 'worktree', 'remove', '--force', str(temp)], cwd=QA)
            shutil.rmtree(temp.parent, ignore_errors=True)
            sh(['git', 'worktree', 'prune'], cwd=QA)
    result['human'] = 'none: no human playtest or creator acceptance performed by this runner'
    result['platform'] = dict(this_run=head_run.get('platform'), note='Linux cloud only. Windows and macOS belong to Build (export/launch) and the creator.')
    result['untested'] = ['native Windows/macOS play', 'physical gamepad', 'sustained performance', 'unseeded full-campaign traversal',
                          'creator visual acceptance of transition presentation', 'candidate-specific hooks (see skips)']
    hooks_skipped = [s for sec, v in head_run['sections'].items() if sec.startswith('hook_') for s in v['skips']]
    result['pending_hooks_skipped'] = hooks_skipped
    h = head_run
    bad = h['exit'] or h['failures'] or h['script_errors'] or cli_off['failures'] or cli_on['failures'] or cli_off['script_errors'] or cli_on['script_errors']
    st = auto.get('stock', {})
    stock_bad = any(v.get('exit') for v in st.values()) if st else False
    result['verdict'] = 'FAIL' if (bad or stock_bad) else ('PASS_WITH_SKIPS' if hooks_skipped else 'PASS')
    result['finished'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    (out / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('label', 'head', 'verdict')}))
    print('result:', out / 'result.json')
    sys.exit(1 if result['verdict'] == 'FAIL' else 0)


if __name__ == '__main__':
    main()
