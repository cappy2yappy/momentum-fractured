#!/usr/bin/env python3
"""Check the exact draft boundary and byte-identical reused ART-08 parts."""
import hashlib,json,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[2]
base='af184380fb690f2c19bac69960b7aacce50f9ff2'
allowed=('tools/cin_tools_03/','assets/cin_tools_03/','presets/cutins/studio/','tests/cin_tools_03/','docs/cin_tools_03/')
changed=subprocess.check_output(['git','diff','--name-only',base],cwd=root,text=True).splitlines()
violations=[p for p in changed if p!='tools/cin_tools_01/preview.gd' and not p.startswith(allowed)]
assert not violations,violations
manifest=json.loads((root/'assets/cin_tools_03/rig_parts/PROVENANCE.json').read_text())
for row in manifest['files']:
 data=(root/row['path']).read_bytes()
 assert hashlib.sha256(data).hexdigest()==row['sha256'],row['path']
 original=subprocess.check_output(['git','show',manifest['source_commit']+':'+row['source']],cwd=root)
 assert data==original,row['path']
print('PASS: Draft changes confined to studio namespaces and additive preview seam')
print(f"PASS: {len(manifest['files'])} reused ART-08 files match pinned source bytes")
print('PASS: Gameplay, Canal Doorway, save schema, canon and approved sprite files have no changes')
