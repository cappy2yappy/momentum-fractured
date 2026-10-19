"""Install checksum-pinned official Godot 4.6.1 and export templates (PM pilot).

Derived from PR52 tools/build06/install.py (see PROVENANCE.json). Same pinned
URLs, same SHA-256 digests, same version assertion. Differences: environment
variable names, a destination folder name, templates for both targets, and a
--templates-only local mode (verifies the template archive digest and unpacks it
without touching an editor) for non-hosted smoke tests. Game dependencies are
never installed.
"""
from pathlib import Path
import argparse, hashlib, json, os, platform, subprocess, urllib.request, zipfile

BASE = 'https://github.com/godotengine/godot-builds/releases/download/4.6.1-stable/'
ASSETS = {
    'windows': ('Godot_v4.6.1-stable_win64.exe.zip', '088da0457e2d1f7f8a45e6d4605a42b756ea33b9ccd75059bdbc01bb31c2b40d'),
    'macos': ('Godot_v4.6.1-stable_macos.universal.zip', 'f43613ad72ab1cc9ef14383545f4de344844451a5c9c5f4ea4a923f1f34f91e4'),
    'templates': ('Godot_v4.6.1-stable_export_templates.tpz', 'e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875'),
}
VERSION = '4.6.1.stable.official.14d19694e'
TEMPLATE_MEMBERS = ['windows_release_x86_64.exe', 'macos.zip', 'version.txt']


def fetch(name, digest, dest, local=None):
    target = dest / name
    if local and (Path(local) / name).is_file():
        target.write_bytes((Path(local) / name).read_bytes())
    else:
        urllib.request.urlretrieve(BASE + name, target)
    got = hashlib.sha256(target.read_bytes()).hexdigest()
    assert got == digest, 'Checksum mismatch for %s: %s' % (name, got)
    return target


def unpack_templates(archive, dest):
    templates = dest / 'templates'
    templates.mkdir(exist_ok=True)
    with zipfile.ZipFile(archive) as z:
        for member in TEMPLATE_MEMBERS:
            (templates / member).write_bytes(z.read('templates/' + member))
    return templates


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--templates-only', action='store_true', help='local smoke mode: no editor, no GITHUB_ENV')
    p.add_argument('--dest', type=Path)
    p.add_argument('--local-dir', help='directory already holding the pinned archives (still checksum verified)')
    a = p.parse_args()
    dest = a.dest or Path(os.environ['RUNNER_TEMP']) / 'pmpilot-engine'
    dest.mkdir(parents=True, exist_ok=True)
    evidence = {}
    if a.templates_only:
        name, digest = ASSETS['templates']
        archive = fetch(name, digest, dest, a.local_dir)
        evidence[name] = digest
        templates = unpack_templates(archive, dest)
        (dest / 'INSTALL.json').write_text(json.dumps(evidence, indent=2) + '\n')
        print('templates:', templates)
        return
    host = {'Windows': 'windows', 'Darwin': 'macos'}[platform.system()]
    for key in [host, 'templates']:
        name, digest = ASSETS[key]
        fetch(name, digest, dest)
        evidence[name] = digest
    if host == 'macos':
        subprocess.run(['ditto', '-x', '-k', str(dest / ASSETS[host][0]), str(dest)], check=True)
        binary = dest / 'Godot.app/Contents/MacOS/Godot'
    else:
        with zipfile.ZipFile(dest / ASSETS[host][0]) as z:
            z.extractall(dest)
        binary = dest / 'Godot_v4.6.1-stable_win64_console.exe'
    assert subprocess.check_output([str(binary), '--version'], text=True).strip() == VERSION
    templates = unpack_templates(dest / ASSETS['templates'][0], dest)
    (dest / 'INSTALL.json').write_text(json.dumps(evidence, indent=2) + '\n')
    with open(os.environ['GITHUB_ENV'], 'a', encoding='utf-8') as f:
        f.write('GODOT=' + str(binary) + '\nPMPILOT_TEMPLATES=' + str(templates) + '\nPMPILOT_INSTALL=' + str(dest / 'INSTALL.json') + '\n')


if __name__ == '__main__':
    main()
