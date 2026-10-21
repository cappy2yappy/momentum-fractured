"""Native Godot geometry captures from a pinned tree; no runtime files edited.
Usage: python3 tools/ld07/capture_geometry.py --godot BIN --ref SHA --spec JSON --out DIR
Omit --ref to capture the current working tree. Requires an imported checkout.
"""
import argparse
from pathlib import Path
import subprocess
import tarfile
import tempfile
import uuid
import io

p = argparse.ArgumentParser()
p.add_argument('--godot', required=True)
p.add_argument('--ref')
p.add_argument('--spec', required=True)
p.add_argument('--out', required=True)
a = p.parse_args()
root = Path(__file__).resolve().parents[2]
out = (root / a.out).resolve();out.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='ld07-capture-') as temp:
    shadow = Path(temp)
    for entry in root.iterdir():
        if entry.name not in {'.git', 'project.godot', 'override.cfg', 'scripts', 'scenes'}:
            (shadow / entry.name).symlink_to(entry, target_is_directory=entry.is_dir())
    (shadow / 'project.godot').write_bytes((root / 'project.godot').read_bytes())
    if a.ref:
        archive = subprocess.check_output(['git', 'archive', a.ref, 'scripts', 'scenes'], cwd=root)
        with tarfile.open(fileobj=io.BytesIO(archive)) as files:
            files.extractall(shadow)
    else:
        for name in ['scripts', 'scenes']:
            (shadow / name).symlink_to(root / name, target_is_directory=True)
    (shadow / 'override.cfg').write_text('[application]\nconfig/use_custom_user_dir=true\n'
        'config/custom_user_dir_name="Kaze-LD07-Capture-' + uuid.uuid4().hex + '"\n')
    command = [a.godot, '--path', str(shadow), '--rendering-method', 'gl_compatibility',
               '--log-file', str(out / 'engine.log'), '--script', 'res://tools/ld05/capture.gd',
               '--', str((root / a.spec).resolve()), str(out), '--test', '--ld05-open-top',
               '--tr05-save=' + str(shadow / 'capture-save.json')]
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
    (out / 'capture.log').write_bytes(result.stdout)
    print(result.stdout.decode(errors='replace'))
    raise SystemExit(result.returncode)
