"""Native Godot key/physics regression in a new, disposable save profile per run."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

p = argparse.ArgumentParser()
p.add_argument('--godot', required=True)
p.add_argument('--label', default='after')
p.add_argument('--rendered', action='store_true')
a = p.parse_args()
r = Path(__file__).resolve().parents[1]
out = r / 'build/tr06'
out.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='tr06-', dir=out) as profile:
    env = os.environ.copy()
    env['APPDATA'] = profile
    env['HOME'] = profile
    env['XDG_DATA_HOME'] = profile
    command = [a.godot, '--path', str(r), '--fixed-fps', '60']
    command += ['--rendering-method', 'gl_compatibility', '--resolution', '1280x720'] if a.rendered else ['--headless']
    command += ['--script', 'res://tests/automatic_passage_reliability.gd', '--', '--tr05-save=' + str(Path(profile) / 'fresh.json')]
    log = out / (a.label + '.log')
    with log.open('wb') as stream:
        try:
            code = subprocess.run(command, cwd=r, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=300).returncode
        except subprocess.TimeoutExpired:
            code = 124
    text = log.read_text(encoding='utf-8', errors='replace')
    row = dict(exit=code, rendered=a.rendered,
               passes=len(re.findall(r'^PASS:', text, re.M)), failures=len(re.findall(r'^FAIL:', text, re.M)),
               script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load', text)), command=command)
    (out / (a.label + '.json')).write_text(json.dumps(row, indent=2) + '\n')
    print(json.dumps(row))
    raise SystemExit(bool(row['exit'] or row['failures'] or row['script_errors']))
