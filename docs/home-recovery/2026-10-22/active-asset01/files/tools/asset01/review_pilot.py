#!/usr/bin/env python3
"""Verify the existing local intake and open one curated, non-production view."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DOCS = ROOT / 'docs/asset01'


def checked_path(base, relative):
    candidate = base / relative
    resolved = candidate.resolve(strict=True)
    if not resolved.is_relative_to(base.resolve()) or candidate.is_symlink():
        raise ValueError('Staged path escapes its pack: ' + relative)
    return resolved


def verify(stage):
    inventory = json.loads((DOCS / 'inventory/packs.json').read_text())
    if json.loads((stage / 'gallery.json').read_text()) != inventory:
        raise ValueError('Staged gallery metadata differs from audited inventory')
    register = json.loads((DOCS / 'license-status.json').read_text())
    packs = {p['slug']: p for p in inventory['packs']}
    rights = {r['pack']: r for r in register}
    if len(packs) != 6 or len(rights) != 6:
        raise ValueError('Expected six individually registered packs')
    files_checked = 0
    for slug, pack in packs.items():
        row = rights[pack['name']]
        if row['archive_sha256'] != pack['sha256']:
            raise ValueError('Register archive pin mismatch: ' + slug)
        if row['production_placement_approved'] is not False:
            raise ValueError('This review does not accept production approvals')
        if row['attested_standalone_redistribution'] != 'prohibited_including_modified_assets':
            raise ValueError('Missing no-redistribution restriction: ' + slug)
        archive = checked_path(stage / 'originals', pack['name'])
        if hashlib.sha256(archive.read_bytes()).hexdigest() != pack['sha256']:
            raise ValueError('Changed local archive: ' + slug)
        for shard in sorted((DOCS / 'inventory').glob(slug + '-*.jsonl')):
            for line in shard.read_text().splitlines():
                entry = json.loads(line)
                path = checked_path(stage / 'extracted' / slug, entry['path'])
                if hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']:
                    raise ValueError('Changed staged source: ' + slug + '/' + entry['path'])
                files_checked += 1
    if files_checked != 1106:
        raise ValueError('Incomplete source inventory: ' + str(files_checked))
    plan = json.loads((DOCS / 'pilot-plan.json').read_text())
    ids = set()
    for pilot in plan['pilots']:
        if pilot['id'] in ids or pilot['production_placement_approved'] is not False:
            raise ValueError('Duplicate pilot or unexpected production approval')
        ids.add(pilot['id'])
        seq = next(s for s in packs[pilot['pack_slug']]['sequences']
                   if s['id'] == pilot['sequence_id'])
        region = pilot['region_index']
        if region < -1 or region >= len(seq.get('regions', [])):
            raise ValueError('Invalid pilot region: ' + pilot['id'])
    return plan, files_checked


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--stage', type=Path, required=True)
    parser.add_argument('--pilot')
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--godot', default='/Applications/Godot.app/Contents/MacOS/Godot')
    parser.add_argument('--host-project', type=Path)
    parser.add_argument('--host-mode', choices=['enemy', 'hazard'])
    parser.add_argument('--host-check', action='store_true')
    parser.add_argument('--capture', type=Path)
    args = parser.parse_args()
    plan, count = verify(args.stage.resolve())
    if args.check:
        print(json.dumps({'archives_verified': 6, 'files_verified': count,
                          'pilot_selections_verified': len(plan['pilots']),
                          'production_placements': 0}))
        return
    if args.host_mode:
        if not args.host_project:
            parser.error('--host-mode requires a separate --host-project checkout')
        host = args.host_project.resolve()
        head = subprocess.check_output(['git', '-C', str(host), 'rev-parse', 'HEAD'], text=True).strip()
        if head != '5172db6898f3efc35b74f3c134293049165b9bf7':
            parser.error('Host must be the isolated PR87 compliance commit 5172db6; never Candidate 3')
        if subprocess.check_output(['git', '-C', str(host), 'status', '--porcelain', '--untracked-files=no'], text=True).strip():
            parser.error('Host has tracked changes; use a clean isolated checkout')
        log_dir = ROOT / 'build/asset01'
        log_dir.mkdir(parents=True, exist_ok=True)
        command = [args.godot, '--path', str(host), '--rendering-method', 'gl_compatibility',
                   '--log-file', str(log_dir / ('host-' + args.host_mode + '.log')), '--script',
                   str(ROOT / 'tools/asset01/host_pilot.gd'), '--', '--test',
                   '--stage=' + str(args.stage.resolve()), '--host-mode=' + args.host_mode]
        if args.host_check:
            command += ['--pilot-check']
        if args.capture:
            args.capture.parent.mkdir(parents=True, exist_ok=True)
            command += ['--pilot-capture=' + str(args.capture.resolve())]
        raise SystemExit(subprocess.call(command))
    if not args.pilot:
        parser.error('--pilot ID or --check is required')
    pilot = next((p for p in plan['pilots'] if p['id'] == args.pilot), None)
    if pilot is None:
        parser.error('Unknown pilot. Choose: ' + ', '.join(p['id'] for p in plan['pilots']))
    # Argument vector only; never copy/import source payloads or start the campaign.
    log_dir = ROOT / 'build/asset01'
    log_dir.mkdir(parents=True, exist_ok=True)
    command = [args.godot, '--path', str(ROOT / 'tools/asset01/gallery'),
               '--rendering-method', 'gl_compatibility',
               '--log-file', str(log_dir / 'curated-gallery.log'), '--',
               '--stage=' + str(args.stage.resolve()),
               '--selection=' + pilot['sequence_id'],
               '--region=' + str(pilot['region_index'])]
    raise SystemExit(subprocess.call(command))


if __name__ == '__main__':
    main()
