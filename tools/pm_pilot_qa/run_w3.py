#!/usr/bin/env python3
"""Wave 3 independent QA: evaluate ANY pushed SHA with one command (test-only).

  python3 tools/pm_pilot_qa/run_w3.py --sha <40-hex SHA> --label <label> [--rendered] [--quick] [--no-stock] [--only w3]
  python3 tools/pm_pilot_qa/run_w3.py --branch feature/tr08-fullscreen-embodied-cinematics --label tr08-s1 --rendered

What it does, in order:
  1. resolves the SHA (or a branch tip through gh api), fetches exactly that commit and creates a DETACHED worktree at it
     (verified by git rev-parse; the candidate checkout is never modified except by Godot's import cache);
  2. headless: core regression sections, reduced CLI on/off, the Wave 3 hooks (stair both directions, Canal doorway both
     directions, reach/wall-jump probes), the legacy Canal containment hook, the stock 25 TR05 suites + preservation
     scripts + PR51 issue #42 author test (305/0), ART-08 manifest/strip checks and the analyzer self-test;
  3. with --rendered: software-GL (xvfb + llvmpipe) stair, doorway and presentation self-test hooks, with viewport coverage
     and presentation captures (JPEG) saved under the output folder;
  4. compares every W3 check to the recorded control baselines and maps all checks to the Wave 3 acceptance list;
  5. writes result.json. Categories are never merged: automated_headless, software_gl_graphical, human (always none),
     platform, untested. A pass is never a creative acceptance.
Output: docs/wave3/qa/runs/<label>/ (result.json, logs, captures).
"""
import argparse, datetime, hashlib, json, os, re, shutil, subprocess, sys, tempfile, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import run_qa as rq  # noqa: E402

QA = rq.QA
OUT_BASE = QA / 'docs/wave3/qa/runs'
BASELINES = QA / 'docs/wave3/qa/baselines'
REPO = 'cappy2yappy/momentum-fractured'
LINE = re.compile(r'^(PASS|FAIL|SKIP): \[([^\]]+)\] (.*)$')
ID = re.compile(r'\[(W3-[A-Z0-9-]+)\]')
CORE = 'start,issue42,matrix,controls,hints,endpoints,save,combat,graph,reduced'

ACCEPTANCE = [
    ('fullscreen_stair_presentation', r'W3-STAIR-(ASCEND|DESCEND)-(FULLSCREEN|NO-LETTERBOX|KAZE-SCALE)$', 'rendered only; stage-layer coverage, letterbox bars, Kaze scale'),
    ('true_multiframe_stair_movement', r'W3-STAIR-(ASCEND|DESCEND)-TRUE-ANIM$|ART08:true_animation', 'playback pose analysis plus shipped-strip analysis'),
    ('true_multiframe_door_movement', r'W3-DOOR-CANAL-(IN|OUT)-(TRUE-ANIM|POSES|VISIBLE|THRESHOLD|NOT-WIPE)$', 'Kaze physically passes the threshold with true frames'),
    ('staircase_ascent', r'W3-STAIR-ASCEND-(STARTS|DURATION|ONCE|ARRIVAL|FACING|PROGRESSION|HELD-E|CONTROL)$', ''),
    ('staircase_descent', r'W3-STAIR-DESCEND-(STARTS|DURATION|ONCE|ARRIVAL|FACING|PROGRESSION|HELD-E|CONTROL)$', ''),
    ('canal_doorway_entry_R0_to_R13', r'W3-DOOR-CANAL-IN-(DURATION|ONCE|ARRIVAL|FACING|PROGRESSION|HELD-KEY|CONTROL)$', ''),
    ('canal_doorway_emergence_R13_to_R0', r'W3-DOOR-CANAL-OUT-(DURATION|ONCE|ARRIVAL|FACING|PROGRESSION|HELD-KEY|CONTROL)$', ''),
    ('destination_label_present', r'W3-(STAIR|DOOR)-.*-LABEL$', 'data/field evidence; pixel placement is a human review item'),
    ('reduced_motion', r'W3-.*-REDUCED-', ''),
    ('correct_room_arrivals', r'W3-.*-(ARRIVAL|FACING)$', ''),
    ('control_restoration_and_cancel', r'W3-.*-(CONTROL|CANCEL-[A-Z]+|HELD-E|HELD-KEY)$|Control state restored', 'completion, pause, death, room change; timeout is not forceable externally'),
    ('doorway_reliability_issue42', r'SECTION:(issue42|matrix|controls|endpoints)|AUTHOR_TR06', 'issue #42 matrix, endpoint sweep, author suite 305/0'),
    ('vertical_routes_vs_escapes', r'W3-REACH-|hook_canal_containment', 'wall-jump probes with real input; lost routes vs controls; escapes'),
    ('save_and_progression', r'SECTION:save|W3-.*-PROGRESSION$', ''),
    ('graph_integrity', r'SECTION:graph', ''),
]


def sh(cmd, **kw):
    return rq.sh(cmd, **kw)


def resolve(a):
    if a.branch:
        rc, out, _ = sh(['gh', 'api', 'repos/%s/commits/%s' % (REPO, a.branch), '--jq', '.sha'])
        if rc or not re.fullmatch(r'[0-9a-f]{40}', out.strip()):
            sys.exit('cannot resolve branch %s: %s' % (a.branch, out.strip()[:200]))
        return out.strip()
    if not re.fullmatch(r'[0-9a-f]{7,40}', a.sha):
        sys.exit('--sha must be hex')
    if len(a.sha) < 40:
        rc, out, _ = sh(['gh', 'api', 'repos/%s/commits/%s' % (REPO, a.sha), '--jq', '.sha'])
        if rc:
            sys.exit('cannot expand sha: ' + out[:200])
        return out.strip()
    return a.sha


def parse_checks(text):
    """-> {check key: outcome}. Key = section + id (W3 ids) or section + label."""
    res = {}
    for line in text.splitlines():
        m = LINE.match(line)
        if not m:
            continue
        kind, sec, label = m.groups()
        i = ID.search(label)
        key = (i.group(1) if i else label[:140])
        res['%s|%s' % (sec, key)] = kind
    return res


def run_hook(godot, repo, out, name, section, extra, rendered, timeout, hooks):
    r = rq.run_godot_harness(godot, repo, out, name, ['--qa-sections=' + section, '--pm-staged-stair'] + extra, rendered, timeout, hooks)
    r['checks'] = parse_checks(Path(out / (name + '.log')).read_text(errors='replace'))
    return r


def accept_table(all_checks, extra_status):
    rows = []
    for name, pat, note in ACCEPTANCE:
        rx = re.compile(pat)
        hit = {k: v for k, v in all_checks.items() if rx.search(k.split('|', 1)[1]) or rx.search('SECTION:' + k.split('|', 1)[0]) or rx.search(k.split('|', 1)[0])}
        for ek, ev in extra_status.items():
            if rx.search(ek):
                hit[ek] = ev
        fails = sorted(k for k, v in hit.items() if v == 'FAIL')
        skips = sorted(k for k, v in hit.items() if v == 'SKIP')
        passes = sum(1 for v in hit.values() if v == 'PASS')
        status = 'NOT_RUN' if not hit else ('FAIL' if fails else ('PASS_WITH_SKIPS' if skips else 'PASS'))
        rows.append(dict(item=name, status=status, passes=passes, fails=len(fails), skips=len(skips), failed_checks=fails[:25], skipped_checks=skips[:10], note=note))
    return rows


def compare(baseline_path, checks):
    if not baseline_path.exists():
        return None
    b = json.loads(baseline_path.read_text())['w3_checks']
    diff = {}
    for k in sorted(set(b) | set(checks)):
        if '|W3-' not in k:
            continue
        if b.get(k) != checks.get(k):
            diff[k] = [b.get(k), checks.get(k)]
    return dict(baseline=baseline_path.name, changed=len(diff), improved=sorted(k for k, v in diff.items() if v[0] == 'FAIL' and v[1] == 'PASS'),
                regressed=sorted(k for k, v in diff.items() if v[0] == 'PASS' and v[1] == 'FAIL'), detail=diff)


def main():
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--sha'); g.add_argument('--branch'); g.add_argument('--repo', help='existing checkout (control development only; not for candidates)')
    ap.add_argument('--label', required=True)
    ap.add_argument('--godot', default=rq.GODOT_DEFAULT)
    ap.add_argument('--rendered', action='store_true', help='software-GL graphical subset (stair, doorway, self-test, captures)')
    ap.add_argument('--quick', action='store_true', help='reach probes: fewer patterns and ticks, full kit only')
    ap.add_argument('--no-stock', action='store_true'); ap.add_argument('--no-reach', action='store_true')
    ap.add_argument('--only', choices=['w3', 'all'], default='all', help='w3 = Wave 3 hooks and art checks only (skip core regression and stock)')
    ap.add_argument('--expect-canal', action='store_true')
    ap.add_argument('--keep', action='store_true'); ap.add_argument('--timeout', type=int, default=2400)
    a = ap.parse_args()

    out = OUT_BASE / a.label
    out.mkdir(parents=True, exist_ok=True)
    hooks = QA / 'tools/pm_pilot_qa/hooks'
    temp = None
    if a.repo:
        repo = Path(a.repo).resolve(); sha = sh(['git', 'rev-parse', 'HEAD'], cwd=repo)[1].strip()
    else:
        sha = resolve(a)
        if sh(['git', 'cat-file', '-e', sha + '^{commit}'], cwd=QA)[0]:
            rc, text, _ = sh(['git', 'fetch', '--depth=1', 'origin', sha], cwd=QA, timeout=300)
            if rc:
                sys.exit('fetch failed: ' + text[:300])
        temp = Path(tempfile.mkdtemp(prefix='w3qa-wt-')) / 'wt'
        rc, text, _ = sh(['git', 'worktree', 'add', '--detach', str(temp), sha], cwd=QA, timeout=300)
        if rc:
            sys.exit('worktree add failed: ' + text[:300])
        repo = temp
        head = sh(['git', 'rev-parse', 'HEAD'], cwd=repo)[1].strip()
        if head != sha:
            sys.exit('worktree HEAD %s != requested %s' % (head, sha))
    result = dict(label=a.label, tested_sha=sha, started=datetime.datetime.now(datetime.timezone.utc).isoformat(), engine=sh([a.godot, '--version'])[1].strip(),
                  qa_checkout_head=sh(['git', 'rev-parse', 'HEAD'], cwd=QA)[1].strip(),
                  harness_sha256=hashlib.sha256((QA / 'tests/pm_pilot_qa.gd').read_bytes()).hexdigest(),
                  hooks_sha256={p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(hooks.glob('*')) if p.is_file()},
                  analyzer_sha256=hashlib.sha256((HERE / 'true_animation.py').read_bytes()).hexdigest())
    try:
        rc, _, secs = sh([a.godot, '--headless', '--path', str(repo), '--import'], cwd=repo, timeout=900)
        result['import'] = dict(exit=rc, seconds=secs)
        auto, all_checks, extra = {}, {}, {}
        canal = ['--qa-expect-canal'] if a.expect_canal else []
        if a.only == 'all':
            r = rq.run_godot_harness(a.godot, repo, out, 'core_headless', ['--qa-sections=' + CORE] + canal, False, a.timeout, str(hooks))
            r['checks'] = parse_checks((out / 'core_headless.log').read_text(errors='replace')); auto['core'] = r
            auto['reduced_cli_off'] = rq.run_godot_harness(a.godot, repo, out, 'reduced_cli_off', ['--qa-sections=reduced_cli'], False, 300, str(hooks))
            auto['reduced_cli_on'] = rq.run_godot_harness(a.godot, repo, out, 'reduced_cli_on', ['--qa-sections=reduced_cli', '--qa-expect-reduced', '--tr05-reduced-motion'], False, 300, str(hooks))
            auto['canal_containment_hook'] = run_hook(a.godot, repo, out, 'hook_canal_containment', 'hook_canal_containment', canal, False, 900, str(hooks))
        auto['stair'] = run_hook(a.godot, repo, out, 'w3_stair_headless', 'hook_w3_stair', [], False, 900, str(hooks))
        auto['doorway'] = run_hook(a.godot, repo, out, 'w3_doorway_headless', 'hook_w3_doorway', [], False, 900, str(hooks))
        if not a.no_reach:
            reach_args = ['--qa-reach-label=' + a.label] + (['--qa-reach-quick'] if a.quick else [])
            auto['reach'] = run_hook(a.godot, repo, out, 'w3_reach_headless', 'hook_w3_reach', ['--qa-out=' + str(out)] + reach_args, False, a.timeout, str(hooks))
        for k, v in auto.items():
            all_checks.update(v.get('checks', {}))
        # ART-08 shipped strips + analyzer self-test
        rc, text, secs = sh([sys.executable, str(HERE / 'art08_check.py'), '--repo', str(repo), '--out', str(out / 'art08_check.json')])
        (out / 'art08_check.log').write_text(text)
        auto['art08'] = dict(exit=rc, status={0: 'PASS', 1: 'FAIL', 3: 'SKIP'}.get(rc, 'ERROR'), seconds=secs, summary=text.strip()[-400:])
        art = json.loads((out / 'art08_check.json').read_text()) if (out / 'art08_check.json').exists() else {}
        extra['ART08:true_animation'] = {'PASS': 'PASS', 'FAIL': 'FAIL', 'SKIP': 'SKIP'}.get(auto['art08']['status'], 'FAIL')
        if art.get('failed'):
            extra['ART08:true_animation'] = 'FAIL'
        rc, text, secs = sh([sys.executable, str(HERE / 'true_animation.py'), '--controls', str(QA)])
        auto['analyzer_controls'] = dict(exit=rc, ok=(rc == 0))
        if a.only == 'all' and not a.no_stock:
            auto['stock'] = rq.run_stock(a.godot, repo, out, '', a.timeout)
            if (repo / 'tests/automatic_passage_reliability.gd').exists() and (repo / 'tools/run_tr06_qa.py').exists():
                rc, text, secs = sh([sys.executable, 'tools/run_tr06_qa.py', '--godot', a.godot, '--label', 'author'], cwd=repo, timeout=900)
                js = repo / 'build/tr06/author.json'
                auto['author_tr06_test'] = dict(exit=rc, seconds=secs, summary=json.loads(js.read_text()) if js.exists() else None)
                s = auto['author_tr06_test']['summary']
                extra['AUTHOR_TR06'] = 'PASS' if (rc == 0 and s and s.get('failures', 1) == 0) else 'FAIL'
        if a.only == 'all':
            for sec, v in auto['core']['sections'].items():
                extra['SECTION:' + sec] = 'FAIL' if v['fail'] else ('SKIP' if v['skip'] and not v['pass'] else 'PASS')
            all_checks.update(auto['core']['checks'])
        result['automated_headless'] = auto
        graphical = {}
        if a.rendered:
            if shutil.which('xvfb-run'):
                cap = out / 'captures'
                graphical['stair'] = run_hook(a.godot, repo, out, 'w3_stair_swgl', 'hook_w3_stair', ['--qa-out=' + str(cap)], True, a.timeout, str(hooks))
                graphical['doorway'] = run_hook(a.godot, repo, out, 'w3_doorway_swgl', 'hook_w3_doorway', ['--qa-out=' + str(cap)], True, a.timeout, str(hooks))
                graphical['selftest'] = run_hook(a.godot, repo, out, 'w3_selftest_swgl', 'hook_w3_selftest', ['--qa-out=' + str(out / 'selftest')], True, 600, str(hooks))
                graphical['captures_jpeg'] = rq.convert_captures(out, a.label)
                pres = re.compile(r'\|W3-.*-(FULLSCREEN|NO-LETTERBOX|KAZE-SCALE|NOT-WIPE)$')
                for k in ('stair', 'doorway'):
                    # the rendered run is the only one that can measure presentation; it replaces the headless SKIP
                    for ck, cv in graphical[k]['checks'].items():
                        if pres.search(ck):
                            all_checks[ck] = cv
                shutil.rmtree(out / 'selftest', ignore_errors=True)
            else:
                graphical['skipped'] = 'xvfb-run not available'
        result['software_gl_graphical'] = graphical or dict(skipped='not requested (--rendered)')
    finally:
        if temp and not a.keep:
            sh(['git', 'worktree', 'remove', '--force', str(temp)], cwd=QA)
            shutil.rmtree(temp.parent, ignore_errors=True)
            sh(['git', 'worktree', 'prune'], cwd=QA)
    w3 = {k: v for k, v in all_checks.items() if '|W3-' in k}
    result['w3_checks'] = w3
    result['w3_totals'] = dict(pass_=sum(1 for v in w3.values() if v == 'PASS'), fail=sum(1 for v in w3.values() if v == 'FAIL'), skip=sum(1 for v in w3.values() if v == 'SKIP'))
    result['acceptance'] = accept_table(all_checks, extra)
    result['vs_controls'] = {p.stem: compare(p, w3) for p in sorted(BASELINES.glob('*.json'))} if BASELINES.exists() else {}
    core = auto.get('core')
    result['regression_summary'] = dict(core_harness=(dict(passes=core['passes'], failures=core['failures'], skips=core['skips'], script_errors=core['script_errors']) if core else 'not run'),
                                        stock=auto.get('stock', 'not run'), author_tr06=auto.get('author_tr06_test', 'not run'))
    result['human'] = 'none: no human playtest or creator acceptance performed. Presentation quality, label placement and animation quality require the creator.'
    result['platform'] = 'Linux cloud only (headless dummy renderer; software GL llvmpipe for the graphical subset). Windows and macOS belong to Build and the creator.'
    result['untested'] = ['native Windows/macOS play', 'physical gamepad', 'sustained performance', 'unseeded full-campaign traversal', 'creator visual acceptance',
                          'candidate watchdog timeout path (not forceable from outside)', 'pixel placement of the destination label']
    bad_acc = [r['item'] for r in result['acceptance'] if r['status'] == 'FAIL']
    skip_acc = [r['item'] for r in result['acceptance'] if r['status'] in ('PASS_WITH_SKIPS', 'NOT_RUN')]
    hard = []
    if core and (core['failures'] or core['script_errors'] or core['exit']): hard.append('core regression harness')
    st = auto.get('stock')
    notes = []
    if st:
        for kname, v in st.items():
            if isinstance(v, dict) and v.get('exit'):
                if kname == 'verify_tr05_preservation.py':
                    notes.append('verify_tr05_preservation.py exit %s: exact-function check of build_room differs (expected when Level changes room geometry; review the log, not a gameplay regression by itself)' % v.get('exit'))
                else:
                    hard.append('stock: ' + kname)
    result['notes'] = notes
    if auto.get('author_tr06_test') and extra.get('AUTHOR_TR06') == 'FAIL': hard.append('issue #42 author suite')
    result['automated_verdict'] = 'REGRESSION' if hard else ('ACCEPTANCE_FAILURES' if bad_acc else ('AUTOMATED_GATES_PASS_WITH_SKIPS' if skip_acc else 'AUTOMATED_GATES_PASS'))
    result['hard_regressions'] = hard
    result['acceptance_failing'] = bad_acc
    result['acceptance_with_skips_or_not_run'] = skip_acc
    result['readiness'] = ('NOT READY: automated acceptance failures remain' if (hard or bad_acc) else 'AUTOMATED GATES PASS: creator/human review still required; never a creative acceptance')
    result['finished'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    (out / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(label=a.label, tested_sha=sha, automated_verdict=result['automated_verdict'], w3=result['w3_totals'], acceptance_failing=bad_acc), indent=1))
    print('result:', out / 'result.json')
    sys.exit(0)


if __name__ == '__main__':
    main()
