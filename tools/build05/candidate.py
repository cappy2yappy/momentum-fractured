"""Build the pinned PR39 Mac candidate; keep game bytes and saves untouched."""
from pathlib import Path
import argparse,datetime,hashlib,json,os,platform,re,shutil,subprocess,time,zipfile
from audit import audit_pack
SOURCE='5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c'
r=Path(os.environ['BUILD05_SOURCE_ROOT']).resolve();control=Path(__file__).resolve().parent
out=r/'build/build05';evidence=out/'evidence';evidence.mkdir(parents=True,exist_ok=True)
p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--verify-only',action='store_true');p.add_argument('--headless-native',action='store_true');a=p.parse_args()
rows=[]
def hard(text):
 return re.findall(r'^.*(?:SCRIPT ERROR|Parse Error|Failed to load|FAIL:|Could not open).*$|^ERROR:.*$',text,re.M)
def run(label,cmd,env=None,timeout=180,expected=None):
 started=time.monotonic()
 try:
  result=subprocess.run(list(map(str,cmd)),cwd=r,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=timeout)
  text=result.stdout;rc=result.returncode
 except subprocess.TimeoutExpired as exc:
  text=exc.stdout or '';text=text.decode(errors='replace') if isinstance(text,bytes) else text
  text+='\nERROR: Test exceeded '+str(timeout)+' second bound\n';rc=124
 (evidence/(label+'.log')).write_text(text)
 # Godot's macOS headless certificate diagnostic is unrelated to gameplay.
 errors=[x for x in hard(text) if 'ret != noErr' not in x and not any(s in x for s in ['RID allocations','RID of type','resources still in use','Pages in use exist at exit'])]
 row=dict(test=label,exit=rc,seconds=round(time.monotonic()-started,2),passes=len(re.findall(r'^PASS:',text,re.M)),errors=errors,expected=expected)
 row['passed']=rc==0 and not errors and (expected is None or expected in text)
 rows.append(row);(out/'QA_RESULTS.json').write_text(json.dumps(dict(source=SOURCE,host=platform.platform(),architecture=platform.machine(),native_capture_mode='headless; no screenshots' if a.headless_native else 'graphical capture',checks=rows),indent=2)+'\n')
 print(label, 'PASS' if row['passed'] else 'FAIL',row['passes'],flush=True)
 assert row['passed'],text[-5000:]
 return text
def profile(name):
 home=out/'disposable-profiles'/name;home.mkdir(parents=True,exist_ok=True)
 env=os.environ.copy();env.update(HOME=str(home),XDG_DATA_HOME=str(home/'xdg'),APPDATA=str(home))
 return env
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip()==SOURCE
assert subprocess.check_output([a.godot,'--version'],text=True).strip()=='4.6.1.stable.official.14d19694e'
archive=out/'Kaze-BUILD05-macOS-Universal-5dfc4c4f.zip'
if not a.verify_only:
 # Settled import is authoritative; retain warmup diagnostics separately.
 run('import-warmup',[a.godot,'--headless','--editor','--path',r,'--import','--quit'],profile('import'),300)
 run('import',[a.godot,'--headless','--editor','--path',r,'--import','--quit'],profile('import'),300)
 run('baseline',['python3',r/'tools/verify_baseline.py'])
 run('preservation',['python3',r/'tools/verify_tr05_preservation.py'])
 run('source-suites',['python3',r/'tools/run_tr05_qa.py','--godot',a.godot],timeout=1800)
 suites=json.loads((r/'build/tr05/qa/results.json').read_text())
 assert len(suites)==25 and all(x['passes']>0 and not(x['exit'] or x['failures'] or x['script_errors']) for x in suites)
 env=profile('export');templates=Path(os.environ['CI_TEMPLATES_DIR'])
 dest=Path(env['HOME'])/'Library/Application Support/Godot/export_templates/4.6.1.stable'
 shutil.copytree(templates,dest,dirs_exist_ok=True)
 raw=out/'raw.zip';run('export',[a.godot,'--headless','--path',r,'--export-release','macOS',raw],env,300)
 staging=out/'staging';staging.mkdir(exist_ok=True)
 subprocess.run(['ditto','-x','-k',str(raw),str(staging)],check=True)
 app=next(staging.glob('*.app'));app.rename(staging/'Kaze-BUILD05.app');app=staging/'Kaze-BUILD05.app'
 # Use the reviewed TR05 fixture definitions without changing the Windows recipe.
 recipe=(r/'tools/package_tr05.py').read_text();start=recipe.index('pilots=');end=recipe.index('\nfor name,room,at,flags in pilots:')
 namespace={};exec(recipe[start:end],namespace);pilots=namespace['pilots']
 fixtures=staging/'fixtures';fixtures.mkdir(exist_ok=True)
 for name,room,at,flags in pilots:
  # Recover only the deterministic fixture expression, never execute the Windows packager.
  seedline=next(x.strip() for x in recipe.splitlines() if x.strip().startswith('seed=dict('))
  scope=dict(room=room,at=at);exec(seedline,scope)
  (fixtures/(name+'.json')).write_text(json.dumps(scope['seed'])+'\n')
 for name,room,at,flags in pilots+[('Fresh',0,[],[])]:
  seed='' if name=='Fresh' else f'cp "$HERE/fixtures/{name}.json" "$HERE/profiles/{name}.json"\n'
  launcher=staging/('Play-'+name+'.command')
  launcher.write_text('#!/bin/bash\nset -euo pipefail\nHERE="$(cd "$(dirname "$0")" && pwd)"\nmkdir -p "$HERE/profiles"\n'+seed+'exec "$HERE/Kaze-BUILD05.app/Contents/MacOS/Kaze-Alpha-0.6.1-Combined-GP-LD" "$@" -- '+ ' '.join(flags)+' "--tr05-save=$HERE/profiles/'+name+'.json"\n')
  # Godot uses config/name for executable; inspect rather than assume its label.
  binary=next((app/'Contents/MacOS').iterdir())
  launcher.write_text(launcher.read_text().replace('Kaze-Alpha-0.6.1-Combined-GP-LD',binary.name));launcher.chmod(0o755)
 (staging/'README.txt').write_text('''KAZE BUILD-05 / Alpha 0.6.1 / macOS Universal / internal draft review
Source: '''+SOURCE+'''
Extract this ZIP completely into a writable folder. Open Play-Fresh.command for an
isolated persistent campaign. Play-Canal-Automatic.command: hold A without E.
Play-Door-East.command: hold D, stop, wait one second, reverse with A.
Play-Door-West.command starts the reciprocal R14 side. Stair-Cinematic: E;
Stair-Descending reverses it. Stair-Reduced-Motion: E with still camera and pose.
F6 toggles reduced motion for this session. Space jump, Q tether, Shift dash,
J attack, F parry, R kunai, T element, M map, I kit, Escape pause.

Demo launchers reset ONLY their own seeded fixture profiles; Fresh persists.
Seeded unlocks are review fixtures, not proof of an earned campaign. Opening the
.app directly uses the historical ordinary save identity; prefer launchers.
39 side passages are automatic with outward movement at matching elevation.
Meaningful interior entrances, stairs, shrines and gates still use E.
Discrete 0.65-second loading remains. Stair presentation is a MOVING PROTOTYPE:
approved held up/down poses move through space; finished gait/walk/outward art
is pending. Existing physics, artwork, progression and Bellroof geometry preserved.

Unsigned and unnotarized internal candidate: macOS may require your organization's
approved method to allow an identified downloaded app. No signing bypass is bundled.
Native scripted checks do not certify a human campaign, gamepad, or sustained FPS.
''')
 subprocess.run(['ditto','-c','-k','--sequesterRsrc',str(staging),str(archive)],check=True)
# Verify final distribution, not the staging directory.
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 assert not any('/profiles/' in n or n.startswith('profiles/') for n in z.namelist())
 pack=next(n for n in z.namelist() if n.endswith('.pck'));audit=audit_pack(z.read(pack))
 assert any('cinematic_transitions.gdc' in n for n in audit['entries'])
 members=[dict(path=i.filename,bytes=i.file_size,sha256=hashlib.sha256(z.read(i)).hexdigest()) for i in z.infolist() if not i.is_dir()]
(evidence/'pack-audit.json').write_text(json.dumps(audit,indent=2))
extract=out/'Downloaded Candidate With Spaces'
if extract.exists():shutil.rmtree(extract)
subprocess.run(['ditto','-x','-k',str(archive),str(extract)],check=True)
app=next(extract.glob('*.app'));binary=next((app/'Contents/MacOS').iterdir());binary.chmod(0o755)
architectures=subprocess.check_output(['lipo','-archs',str(binary)],text=True).strip();assert set(architectures.split())=={'x86_64','arm64'}
run('release-startup',[binary,'--headless','--fixed-fps','60','--quit-after','120'],profile('release'),90, 'Godot Engine v4.6.1')
for launcher in sorted(extract.glob('Play-*.command')):
 launcher.chmod(0o755);run(launcher.stem,[launcher,'--headless','--fixed-fps','60','--quit-after','120'],profile('launchers'),90,'Godot Engine v4.6.1')
# Tests remain external to the shipped PCK. Mount that exact PCK before scene load.
env=profile('packaged-native');env.update(BUILD05_PACK=str(next(app.rglob("*.pck"))),BUILD05_CAPTURE_DIR=str(evidence/'native-captures'),BUILD05_CAPTURE_MODE='headless' if a.headless_native else 'graphical')
run('packaged-native',[a.godot]+(['--headless'] if a.headless_native else [])+['--path',r,'--fixed-fps','60','--script',control/'packaged_native.gd','--','--test'],env,300,'54 checks, 0 failure(s)')
for suite in ['intentional_space','audit_intentional_space','movement_momentum','save_compatibility','expansion_gates_save','skyworks_progression']:
 method='_run' if suite in ['movement_momentum','save_compatibility','skyworks_progression'] else 'run'
 wrapper=out/('packaged-'+suite+'.gd');wrapper.write_text('extends "res://tests/'+suite+'.gd"\nfunc _init():\n\tif not ProjectSettings.load_resource_pack(OS.get_environment("BUILD05_PACK"),true):\n\t\tpush_error("Mac PCK mount failed");quit(1);return\n\tcall_deferred("'+method+'")\n')
 if suite=='audit_intentional_space':
  text=(r/'tests/audit_intentional_space.gd').read_text()
  init='func _init():\n\tif not ProjectSettings.load_resource_pack(OS.get_environment("BUILD05_PACK"),true):\n\t\tpush_error("Mac PCK mount failed");quit(1);return\n\tcall_deferred("run")'
  text=text.replace('func _init(): call_deferred("run")',init).replace('"res://build/ld03"',json.dumps(str(evidence/'packaged-space-audit')))
  wrapper.write_text(text)
 run('packaged-'+suite,[a.godot,'--headless','--path',r,'--fixed-fps','60','--script',wrapper,'--','--test'],env,120)
 assert rows[-1]['passes']>0
manifest=dict(source_commit=SOURCE,pr39_runtime='f168339a6fa6b02f16958ce250636dbe47d4a783',geometry_base='b950373efb5c4621d7da7e0be1506db048e3043a',engine='4.6.1.stable.official.14d19694e',architectures=architectures.split(),native_host=platform.machine(),timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),archive=archive.name,sha256=hashlib.sha256(archive.read_bytes()).hexdigest(),bytes=archive.stat().st_size,pck_entries=audit['entry_count'],members=members,qa_status='passed',signing='unsigned, unnotarized',limits=['stair gait unfinished','scripted fixtures, no human full campaign','gamepad and sustained FPS not certified'])
(out/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k!='members'}),flush=True)
