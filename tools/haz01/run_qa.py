"""Bounded native regressions; redirect test saves to disposable directories."""
import argparse, json, pathlib, re, subprocess, tempfile
p = argparse.ArgumentParser()
p.add_argument('--godot', required=True)
p.add_argument('--suite', action='append', choices=['haz01_toolkit','movement_momentum','save_compatibility','ld05_boundaries'])
a = p.parse_args()
root = pathlib.Path(__file__).resolve().parents[2]
out = root / 'docs/haz01/evidence'
out.mkdir(parents=True, exist_ok=True)
results = json.loads((out / 'results.json').read_text()) if a.suite and (out / 'results.json').exists() else []
for name in a.suite or ['haz01_toolkit', 'movement_momentum', 'save_compatibility', 'ld05_boundaries']:
    with tempfile.TemporaryDirectory(prefix='haz01-') as profile:
        source = (root / f'tests/{name}.gd').read_text()
        source = source.replace('user://', pathlib.Path(profile).as_posix() + '/')
        source = source.replace('/private/tmp/haz01-course-test.json', profile + '/course.json')
        script = pathlib.Path(profile) / f'{name}.gd'
        script.write_text(source)
        command = [a.godot, '--headless', '--fixed-fps', '60', '--path', str(root), '--script', str(script), '--log-file', profile + '/engine.log', '--', '--test']
        try:
            run = subprocess.run(command, cwd=root, capture_output=True, text=True, timeout=240)
            text, code = run.stdout + run.stderr, run.returncode
        except subprocess.TimeoutExpired as exc:
            text, code = str(exc), 124
        (out / f'{name}.txt').write_text(text)
        row = dict(suite=name, exit=code, passes=len(re.findall(r'^PASS:', text, re.M)), failures=len(re.findall(r'^FAIL:', text, re.M)), script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load', text)))
        results = [r for r in results if r["suite"] != name]
        results.append(row)
        print(json.dumps(row), flush=True)
(out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
raise SystemExit(any(r['exit'] or r['failures'] or r['script_errors'] for r in results))
