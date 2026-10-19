"""Apple Silicon smoke: run the extracted macOS Universal package natively on an arm64 host.

Checks the inner ZIP SHA-256 against SHA256SUMS.txt, extracts into a path with spaces, confirms the host is arm64
and the binary carries an arm64 slice, then runs every Play-*.command for 120 headless frames with launcher-owned
user data. Headless only: no graphics, no input, no hands-on play.
"""
from pathlib import Path
import argparse, hashlib, json, os, platform, subprocess, sys, zipfile

p = argparse.ArgumentParser()
p.add_argument('--artifact-dir', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
sums = next(a.artifact_dir.rglob('SHA256SUMS.txt')).read_text().split()
inner = next(a.artifact_dir.rglob(sums[1]))
assert hashlib.sha256(inner.read_bytes()).hexdigest() == sums[0], 'inner ZIP SHA-256 mismatch'
dest = a.out / 'Apple Silicon Extract'
dest.mkdir(parents=True)
with zipfile.ZipFile(inner) as z:
    assert z.testzip() is None
    for e in z.infolist():
        z.extract(e, dest)
        (dest / e.filename).chmod(e.external_attr >> 16 & 0o777)
assert platform.machine() == 'arm64', platform.machine()
app = next(dest.glob('*.app'))
binary = next((app / 'Contents/MacOS').iterdir())
archs = subprocess.check_output(['lipo', '-archs', str(binary)], text=True).split()
assert 'arm64' in archs and 'x86_64' in archs, archs
rows = []
for launcher in sorted(dest.glob('Play-*.command')):
    env = os.environ.copy()
    r = subprocess.run([str(launcher), '--headless', '--fixed-fps', '60', '--quit-after', '120'], env=env, capture_output=True, text=True, timeout=120)
    ok = r.returncode == 0 and 'Godot Engine v4.6.1' in (r.stdout + r.stderr)
    rows.append(dict(launcher=launcher.name, exit=r.returncode, ok=ok))
    print(launcher.name, 'PASS' if ok else 'FAIL', flush=True)
result = dict(host=platform.platform(), machine=platform.machine(), binary_archs=archs, inner_sha256=sums[0], launchers=rows, headless_only=True)
(a.out / 'APPLE_SILICON_SMOKE.json').write_text(json.dumps(result, indent=2) + '\n')
print('::notice title=pmpilot apple silicon::' + json.dumps(result))
sys.exit(0 if rows and all(r['ok'] for r in rows) else 1)
