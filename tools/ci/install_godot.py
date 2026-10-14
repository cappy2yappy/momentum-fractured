"""Install the exact official editor/templates, checking release SHA-256 digests."""
import argparse, hashlib, json, os, pathlib, shutil, subprocess, urllib.request, zipfile
VERSION = '4.6.1.stable.official.14d19694e'
ASSETS = {
    'Godot_v4.6.1-stable_linux.x86_64.zip': 'cecd0cb6b55e931318a9d7237dc4197d69ea914966787a454808523626e2789f',
    'Godot_v4.6.1-stable_export_templates.tpz': 'e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875',
}
def main():
    parser = argparse.ArgumentParser(); parser.add_argument('--templates-file', type=pathlib.Path)
    args = parser.parse_args()
    dest = pathlib.Path(os.environ.get('RUNNER_TEMP', 'build/ci/runtime')) / 'godot-4.6.1'
    dest.mkdir(parents=True, exist_ok=True)
    for name, digest in ASSETS.items():
        target = dest / name
        if args.templates_file and name.endswith('.tpz'):
            shutil.copyfile(args.templates_file, target)
        else:
            urllib.request.urlretrieve('https://github.com/godotengine/godot-builds/releases/download/4.6.1-stable/' + name, target)
        assert hashlib.sha256(target.read_bytes()).hexdigest() == digest, f'Checksum mismatch: {name}'
    editor = dest / 'Godot_v4.6.1-stable_linux.x86_64'
    with zipfile.ZipFile(dest / 'Godot_v4.6.1-stable_linux.x86_64.zip') as z: z.extractall(dest)
    editor.chmod(0o755)
    assert subprocess.check_output([str(editor), '--version'], text=True).strip() == VERSION
    templates = pathlib.Path.home() / '.local/share/godot/export_templates/4.6.1.stable'
    templates.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dest / 'Godot_v4.6.1-stable_export_templates.tpz') as z:
        for name in ('windows_release_x86_64.exe', 'macos.zip', 'version.txt'):
            (templates / name).write_bytes(z.read('templates/' + name))
    assert (templates / 'version.txt').read_text().strip() == '4.6.1.stable'
    if 'GITHUB_ENV' in os.environ:
        with open(os.environ['GITHUB_ENV'], 'a') as f: f.write(f'GODOT={editor}\n')
    (dest / 'installation.json').write_text(json.dumps({'version': VERSION, 'sha256': ASSETS}, indent=2))
if __name__ == '__main__': main()
