#!/usr/bin/env python3
"""Export recovery playtests with local official 4.6.1 templates; retain presets."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--godot', default='godot')
parser.add_argument('--templates', default='build/templates')
parser.add_argument('--evidence', default='validation/current-export')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
templates = (root / args.templates).resolve()
if (templates / 'version.txt').read_text().strip() != '4.6.1.stable':
    raise SystemExit('Official 4.6.1.stable export templates are required')
version = subprocess.check_output([args.godot, '--version'], text=True).strip()
if not version.startswith('4.6.1.'):
    raise SystemExit('Godot 4.6.1 is required')
source = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
out = (root / args.evidence).resolve()
out.mkdir(parents=True, exist_ok=True)
(root / 'build').mkdir(exist_ok=True)
(root / 'build/.gdignore').touch()
presets = root / 'export_presets.cfg'
original = presets.read_text()
local = original.replace('custom_template/release=""', 'custom_template/release="' + str(templates / 'macos.zip') + '"', 1)
start = local.index('[preset.1.options]')
local = local[:start] + local[start:].replace('custom_template/release=""', 'custom_template/release="' + str(templates / 'windows_release_x86_64.exe') + '"', 1)
results = []
try:
    presets.write_text(local)
    for name, platform, suffix in [('Windows Desktop', 'windows', '.exe'), ('macOS', 'macos', '-macOS.zip')]:
        destination = root / 'build' / platform / ('Kaze-Recovery-' + source[:8] + suffix)
        destination.parent.mkdir(parents=True, exist_ok=True)
        command = [args.godot, '--headless', '--path', str(root), '--export-release', name, str(destination), '--log-file', str(out / (platform + '.engine.log'))]
        run = subprocess.run(command, cwd=root, capture_output=True, text=True, timeout=120)
        output = run.stdout + run.stderr
        (out / (platform + '.log')).write_text(output)
        errors = [line for line in output.splitlines() if 'ERROR:' in line or 'SCRIPT ERROR' in line]
        result = dict(preset=name, exit=run.returncode, errors=errors, file=str(destination), bytes=destination.stat().st_size if destination.exists() else 0)
        if destination.exists():
            result['sha256'] = hashlib.sha256(destination.read_bytes()).hexdigest()
        results.append(result)
        print(json.dumps(result), flush=True)
finally:
    presets.write_text(original)
    (out / 'export-results.json').write_text(json.dumps(dict(source_commit=source, engine=version, exports=results), indent=2) + '\n')
if len(results) != 2 or any(item['exit'] != 0 or item['errors'] or not item['bytes'] for item in results):
    raise SystemExit(1)
