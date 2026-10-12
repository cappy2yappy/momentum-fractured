#!/usr/bin/env python3
"""Run Godot 4.6.1 checks with bounded processes, logs and isolated saves."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import sys

TESTS = {
    'alpha_08_smoke': 'ALPHA 0.8 SMOKE TEST: 0 failure(s), 12 rooms',
    'echo_territory_regression': 'ECHO TERRITORY REGRESSION: 0 failure(s)',
    'swimming_regression': 'SWIMMING REGRESSION: 0 failure(s)',
    'canal_chamber_regression': 'CANAL CHAMBER REGRESSION: 0 failure(s)',
    'recovery_regression': 'RECOVERY REGRESSION: 0 failure(s)',
    'live_motion_regression': 'LIVE MOTION REGRESSION: 0 failure(s)',
    'fire_return_regression': 'FIRE RETURN REGRESSION: 0 failure(s)',
}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default='godot')
    parser.add_argument('--output', default='validation/current')
    parser.add_argument('--suite', action='append', choices=TESTS)
    parser.add_argument('--skip-import', action='store_true')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    out = (root / args.output).resolve()
    out.mkdir(parents=True, exist_ok=True)
    version = subprocess.check_output([args.godot, '--version'], text=True).strip()
    if not version.startswith('4.6.1.'):
        raise SystemExit('Godot 4.6.1 required; got ' + version)
    results = []
    jobs = [] if args.skip_import else [('import', ['--import'], None)]
    for name in args.suite or TESTS:
        jobs.append((name, ['--script', 'res://tests/' + name + '.gd'], TESTS[name]))
    for name, flags, marker in jobs:
        command = [args.godot, '--headless', '--path', str(root), '--log-file', str(out / (name + '.engine.log')), *flags,
                   '--', '--recovery-test-mode', '--test-save-path=' + str(out / (name + '.save.json'))]
        try:
            run = subprocess.run(command, cwd=root, capture_output=True, text=True, timeout=60)
            output, exit_code = run.stdout + run.stderr, run.returncode
        except subprocess.TimeoutExpired as exc:
            output = (exc.stdout or b'').decode() + (exc.stderr or b'').decode()
            exit_code = 124
        (out / (name + '.log')).write_text(output)
        # Certificate access is a known macOS host warning. All other engine
        # errors (including physics flush errors) fail even when Godot exits 0.
        errors = [line for line in output.splitlines()
                  if re.search(r'SCRIPT ERROR|Parse Error|^ERROR:|^FAIL:', line)
                  and not line.startswith('ERROR: Condition "ret != noErr" is true.')]
        passed = exit_code == 0 and not errors and (marker is None or marker in output)
        result = dict(test=name, exit=exit_code, passed=passed, errors=errors,
                      summary=[line for line in output.splitlines() if 'failure(s)' in line],
                      warnings=[line for line in output.splitlines() if 'WARNING:' in line or 'ret != noErr' in line],
                      command=command)
        results.append(result)
        print(json.dumps(result), flush=True)
    (out / 'results.json').write_text(json.dumps(dict(engine=version, results=results), indent=2) + '\n')
    return 0 if all(result['passed'] for result in results) else 1

if __name__ == '__main__':
    sys.exit(main())
