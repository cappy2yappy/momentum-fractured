#!/usr/bin/env python3
"""Scoped Studio milestone QA. Native cases run serially; profiles stay under build/."""
import argparse, json, re, subprocess, tempfile, time
from pathlib import Path
p = argparse.ArgumentParser()
p.add_argument('--godot', required=True)
p.add_argument('--rendered', action='store_true')
a = p.parse_args()
r = Path(__file__).resolve().parents[2]
mode = 'rendered' if a.rendered else 'headless'
base = r / 'build/cin_tools_03/minimum_usable' / mode
base.mkdir(parents=True, exist_ok=True)
# Retain previous QA and creator review profiles, including staged examples.
out = Path(tempfile.mkdtemp(prefix='run-', dir=base))
profile = out / 'fresh_process_profile'
rows = []
cases = [('cin_tools_03/workspace', []), ('cin_tools_03/layout', []), ('cin_tools_03/pointer', []),
         ('cin_tools_03/persistence', ['--write-example']),
         ('cin_tools_03/persistence', []), ('cin_tools_03/pointer_example', []),
         ('cin_tools_01/authoring', []), ('cin_tools_01/runtime', [])]
for index, (name, flags) in enumerate(cases):
    label = f'{index + 1:02d}_' + name.replace('/', '_')
    # Legacy runtime's user:// references are redirected; production sources stay untouched.
    source = (r / 'tests' / f'{name}.gd').read_text().replace('user://', str(out / label) + '/')
    source = source.replace('res://build/cin_tools_03/', 'res://' + str(out.relative_to(r)) + '/isolated/')
    script = out / (label + '.gd')
    script.write_text(source)
    # macOS scans all argv for --test, even after --, and selects a headless
    # OS loop. Studio has no gameplay save path and needs no such guard.
    # Legacy gameplay fixtures retain their save guard and synthetic-input scope.
    guards = [] if a.rendered and name.startswith('cin_tools_03/') else ['--test']
    cmd = [a.godot] + ([] if a.rendered else ['--headless']) + [
        '--path', str(r), '--log-file', str(out / (label + '.engine.log')),
        '--script', 'res://' + str(script.relative_to(r)), '--', *guards,
        '--studio-save-dir=' + str(profile)] + flags
    started = time.monotonic()
    try:
        proc = subprocess.run(cmd, cwd=r, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=60)
        output, code = proc.stdout.decode(errors='replace'), proc.returncode
    except subprocess.TimeoutExpired as e:
        output, code = (e.stdout or b'').decode(errors='replace'), 124
    (out / (label + '.log.txt')).write_text(output)
    row = dict(suite=name, flags=flags, mode=mode, exit=code, seconds=round(time.monotonic() - started, 2),
               passes=len(re.findall(r'^PASS:', output, re.M)), failures=len(re.findall(r'^FAIL:', output, re.M)),
               script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load', output)), command=cmd)
    rows.append(row)
    print(json.dumps(row), flush=True)
    (out / 'results.json').write_text(json.dumps(rows, indent=2))
    # Never call a stale file a successful fresh-process round trip.
    if code or row['failures'] or row['script_errors']: break
raise SystemExit(any(x['exit'] or x['failures'] or x['script_errors'] for x in rows))
