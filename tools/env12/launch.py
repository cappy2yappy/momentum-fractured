#!/usr/bin/env python3
"""ENV-12: pinned native review in a private host; never launch the reference checkout."""
import argparse, hashlib, json, os, shutil, subprocess, sys
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
CODE = ROOT / 'tools/env12'
PRIVATE = CODE / '.private'
BASE = '250afde28517fcc05984038ac9e1487114729b78'

def blob(data):
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

def verify_sources():
    rows = json.loads((CODE / 'source-contract.json').read_text())
    for row in rows:
        if blob((ROOT / row['path']).read_bytes()) != row['sha']:
            raise ValueError('Pinned source changed: ' + row['path'])
    return rows

def profile(name):
    p = PRIVATE / 'profiles' / name
    p.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env['APPDATA'] = env['LOCALAPPDATA'] = str(p)
    env['XDG_DATA_HOME'] = env['XDG_CONFIG_HOME'] = str(p)
    return env

def run_engine(godot, args, name, timeout=90):
    PRIVATE.mkdir(parents=True, exist_ok=True)
    log = PRIVATE / (name + '.log')
    with log.open('w', encoding='utf8') as out:
        p = subprocess.run([godot] + args, env=profile(name), stdout=out,
                           stderr=subprocess.STDOUT, timeout=timeout)
    content = log.read_text(encoding='utf8', errors='replace')
    failures = [line for line in content.splitlines() if 'SCRIPT ERROR' in line or 'Parse Error' in line]
    print(name, 'exit', p.returncode, 'script errors', len(failures), flush=True)
    if p.returncode or failures:
        print(content[-10000:])
        raise RuntimeError('Native check failed: ' + name)
    return log

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('action', choices=['prepare', 'capture', 'review', 'audit'])
    p.add_argument('--godot', required=True)
    p.add_argument('--cache', type=Path, required=True)
    p.add_argument('--stage', type=Path, required=True)
    p.add_argument('--room', type=int, choices=[0,4,14,16], default=0)
    p.add_argument('--all', action='store_true')
    args = p.parse_args()
    rows = verify_sources()
    sys.path.insert(0, str(ROOT / 'tools/asset01'))
    from review_pilot import verify
    verify(args.stage.resolve())
    runtime = json.loads((args.cache / 'runtime.json').read_text())
    lineage = json.loads((ROOT / 'docs/art11/derivative-lineage.json').read_text())
    if runtime != lineage: raise ValueError('Cache manifest differs from ART-11 lineage')
    for asset in runtime['assets'].values():
        for frame in asset['frames']:
            data = (args.cache / frame['path']).read_bytes()
            if hashlib.sha256(data).hexdigest() != frame['sha256']: raise ValueError('Changed frame')
    host = PRIVATE / 'host'
    common = ['--rendering-method','gl_compatibility','--path',str(host)]
    if args.action == 'prepare':
        for row in rows:
            target = host / row['path']; target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / row['path'], target)
        run_engine(args.godot, common + ['--headless','--editor','--import','--quit'], 'import', 180)
    else:
        for row in rows:
            if blob((host / row['path']).read_bytes()) != row['sha']:
                raise ValueError('Private host changed; run prepare: '+row['path'])
        rooms = [0,4,14,16] if args.all else [args.room]
        for room in rooms:
            output = PRIVATE / 'captures' / ('R'+str(room)); output.mkdir(parents=True, exist_ok=True)
            cmd = common + ['--script',str(CODE/'study.gd'),'--','--test','--code='+str(CODE),
                '--art11='+str(ROOT/'tools/art11'),'--cache='+str(args.cache.resolve()),
                '--room='+str(room),'--output='+str(output)]
            if args.action != 'review': cmd += ['--capture']
            run_engine(args.godot, cmd, 'R'+str(room), None if args.action == 'review' else 120)
    print('Pinned runtime files:',len(rows),'verified cache frames:',runtime['frame_count'])
    return 0
if __name__ == '__main__':
    raise SystemExit(main())
