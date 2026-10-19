"""PM pilot (TRANSITION) regressions: staged stair cinematic, Canal-left passage and the
unchanged TR06 issue #42 real-input suite. Disposable profile per suite, exact logs.
Stock suites: run tools/run_tr05_qa.py separately (unchanged, no pilot flag)."""
import argparse, json, os, re, subprocess, tempfile, time
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--godot', required=True)
p.add_argument('--label', default='headless')
a = p.parse_args()
r = Path(__file__).resolve().parents[1]
out = r / 'build/pm_pilot/transition/qa' / a.label
out.mkdir(parents=True, exist_ok=True)
suites = [
    ('pm_staged_stair_cinematic', ['--test', '--pm-staged-stair']),
    ('pm_canal_left_passage', []),
    ('automatic_passage_reliability', []),
]
rows = []
for name, flags in suites:
    with tempfile.TemporaryDirectory(prefix='pmtr-', dir=out) as profile:
        env = os.environ.copy()
        env.update(APPDATA=profile, HOME=profile, XDG_DATA_HOME=profile)
        command = [a.godot, '--headless', '--path', str(r), '--fixed-fps', '60', '--script', 'res://tests/%s.gd' % name, '--'] + flags + ['--tr05-save=' + str(Path(profile) / 'fresh.json')]
        start = time.monotonic()
        try:
            res = subprocess.run(command, cwd=r, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=600)
            text, code = res.stdout.decode(errors='replace'), res.returncode
        except subprocess.TimeoutExpired as e:
            text, code = (e.stdout or b'').decode(errors='replace'), 124
    (out / (name + '.log')).write_text(text, encoding='utf-8')
    row = dict(suite=name, exit=code, seconds=round(time.monotonic() - start, 2),
               passes=len(re.findall(r'^PASS:', text, re.M)), failures=len(re.findall(r'^FAIL:', text, re.M)),
               script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load', text)), flags=flags)
    rows.append(row)
    print(json.dumps(row), flush=True)
(out / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
raise SystemExit(any(x['exit'] or x['failures'] or x['script_errors'] for x in rows))
