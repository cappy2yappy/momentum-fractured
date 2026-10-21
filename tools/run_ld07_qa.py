"""Run ground/transition regressions in a disposable project and save profile.

Godot must already have imported this checkout. A shadow project keeps QA user
settings out of project.godot and never loads the creator's save directory.
"""
import argparse
import io
import json
from pathlib import Path
import re
import subprocess
import tempfile
import tarfile
import time
import uuid

p = argparse.ArgumentParser()
p.add_argument('--godot', required=True)
p.add_argument('--suites', nargs='+', default=[
    'ld07_ground', 'ld05_boundaries', 'canal_geometry',
    'automatic_passage_reliability', 'pm_canal_left_passage',
    'audit_intentional_space', 'level_geometry', 'save_compatibility',
    'expansion_gates_save', 'expansion_traversal', 'cinematic_transitions'])
p.add_argument('--label', default='current')
p.add_argument('--open-top', action='store_true')
p.add_argument('--gates-closed', action='store_true')
p.add_argument('--rendered', action='store_true')
p.add_argument('--ref', help='Read-only runtime snapshot for before/after reproduction')
a = p.parse_args()
root = Path(__file__).resolve().parents[1]
out = root / 'build/ld07' / a.label
out.mkdir(parents=True, exist_ok=True)
rows = []
with tempfile.TemporaryDirectory(prefix='project-', dir=out) as temp:
    shadow = Path(temp)
    for entry in root.iterdir():
        if entry.name not in {'.git', 'project.godot', 'override.cfg'} and not (a.ref and entry.name in {'scripts','scenes'}):
            (shadow / entry.name).symlink_to(entry, target_is_directory=entry.is_dir())
    if a.ref:
        archive = subprocess.check_output(['git','archive',a.ref,'scripts','scenes'],cwd=root)
        with tarfile.open(fileobj=io.BytesIO(archive)) as files:
            files.extractall(shadow)
    (shadow / 'project.godot').write_bytes((root / 'project.godot').read_bytes())
    for suite in a.suites:
        profile = 'Kaze-LD07-QA-' + uuid.uuid4().hex
        (shadow / 'override.cfg').write_text(
            '[application]\nconfig/use_custom_user_dir=true\n'
            'config/custom_user_dir_name="' + profile + '"\n')
        script = {'ground_probe': 'tools/ld05/ground_probe',
                  'door_walk_probe': 'tools/ld05/door_walk_probe'}.get(suite, 'tests/' + suite)
        command = [a.godot, '--headless', '--path', str(shadow), '--fixed-fps', '60',
                   '--log-file', str(out / (suite + '-engine.log')),
                   '--script', 'res://' + script + '.gd', '--',
                   '--tr05-save=' + str(shadow / (suite + '-save.json'))]
        if a.rendered:
            command.remove('--headless')
        if suite != 'automatic_passage_reliability':
            command.append('--test')
        if suite in {'room_transition_prototype','mixed_transitions','embodied_transitions','art04_transitions'}:
            command.append('--tr05-legacy')
        if a.open_top:
            command.append('--ld05-open-top')
        if a.gates_closed:
            command.append('--gates=closed')
        if suite in {'ground_probe', 'door_walk_probe'}:
            command.append('--out=' + str(out / (suite + '.json')))
        start = time.monotonic()
        try:
            result = subprocess.run(command, stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=900 if suite == 'ground_probe' else 180)
            log, code = result.stdout.decode(errors='replace'), result.returncode
        except subprocess.TimeoutExpired as error:
            log, code = (error.stdout or b'').decode(errors='replace'), 124
        (out / (suite + '.log')).write_text(log)
        row = dict(suite=suite, exit=code, seconds=round(time.monotonic()-start, 2),
                   passes=len(re.findall(r'^PASS:', log, re.M)),
                   failures=len(re.findall(r'^FAIL:', log, re.M)),
                   script_errors=len(re.findall(r'SCRIPT ERROR|Parse Error|Failed to load', log)),
                   profile=profile, command=command)
        rows.append(row)
        (out / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
        print(json.dumps(row), flush=True)
raise SystemExit(any(r['exit'] or r['failures'] or r['script_errors'] for r in rows))
