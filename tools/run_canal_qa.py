"""Canal-left geometry regression (LEVEL pilot) in a disposable save profile.
Usage: run_canal_qa.py --godot <bin> [--label after] [--script res://tests/canal_geometry.gd]"""
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
p.add_argument('--script', default='res://tests/canal_geometry.gd')
p.add_argument('--root', default=None)
a = p.parse_args()
r = Path(a.root).resolve() if a.root else Path(__file__).resolve().parents[1]
out = r / 'build/canal'
out.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='canal-', dir=out) as profile:
    env = os.environ.copy()
    env['APPDATA'] = profile
    env['HOME'] = profile
    env['XDG_DATA_HOME'] = profile
    command = [a.godot, '--path', str(r), '--fixed-fps', '60', '--headless', '--script', a.script, '--', '--tr05-save=' + str(Path(profile) / 'fresh.json')]
    log = out / (a.label + '.log')
    with log.open('wb') as stream:
        try:
            code = subprocess.run(command, cwd=r, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=900).returncode
        except subprocess.TimeoutExpired:
            code = 124
    text = log.read_text(encoding='utf-8', errors='replace')
    row = dict(exit=code, passes=len(re.findall(r'^PASS:', text, re.M)), failures=len(re.findall(r'^FAIL:', text, re.M)),
               script_errors=len(re.findall('SCRIPT ERROR|Parse Error|Failed to load', text)), command=command)
    (out / (a.label + '.json')).write_text(json.dumps(row, indent=2) + '\n')
    print(json.dumps(row))
    raise SystemExit(bool(row['exit'] or row['failures'] or row['script_errors']))
