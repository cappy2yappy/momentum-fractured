"""Pinned-source, native-platform playtest export; no gameplay edits or releases."""
from pathlib import Path
import argparse,datetime,hashlib,importlib.util,json,os,platform,re,shutil,stat,struct,subprocess,sys,time,zipfile

CONTROL=Path(__file__).resolve().parent
VERSION='4.6.1.stable.official.14d19694e'
PILOTS=[('Canal-Automatic',13,[220,1198],[]),('Door-East',13,[1560,558],[]),('Door-West',14,[220,1098],[]),('Stair-Cinematic',14,[1450,478],[]),('Stair-Descending',17,[1680,1298],[]),('Stair-Reduced-Motion',14,[1450,478],['--tr05-reduced-motion'])]

def digest(data):return hashlib.sha256(data).hexdigest()
def git(root,*args):return subprocess.check_output(['git','-C',str(root),*args])
def snapshot(root):
 return {n:digest((root/n).read_bytes()) for n in git(root,'ls-files').decode().splitlines() if (root/n).is_file()}
def pack_bytes(path):
 data=path.read_bytes()
 if data[:4]==b'GDPC':return data
 assert data[:2]==b'MZ' and data[-4:]==b'GDPC'
 start=len(data)-12-struct.unpack_from('<Q',data,len(data)-12)[0]
 return data[start:-12]

def main():
 p=argparse.ArgumentParser();p.add_argument('--godot',required=True);p.add_argument('--source',default='baseline');p.add_argument('--graphical',action='store_true');a=p.parse_args()
 root=Path(os.environ['BUILD06_SOURCE_ROOT']).resolve();host={'Windows':'windows','Darwin':'macos'}[platform.system()]
 spec=json.loads((CONTROL/'sources.json').read_text())[a.source];sha=spec['commit']
 assert re.fullmatch('[0-9a-f]{40}',sha)
 assert git(root,'rev-parse','HEAD').decode().strip()==sha
 assert not git(root,'status','--porcelain','--untracked-files=no').strip(),'Source must start clean'
 assert subprocess.check_output([a.godot,'--version'],text=True).strip()==VERSION
 before=snapshot(root)
 out=root/'build/build06';evidence=out/'evidence';evidence.mkdir(parents=True,exist_ok=True)
 rows=[]
 def run(name,cmd,env=None,timeout=180,expected=None):
  start=time.monotonic();env=env or profile(name)
  try:
   r=subprocess.run(list(map(str,cmd)),cwd=root,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=timeout)
   text=r.stdout.decode('utf-8',errors='replace');rc=r.returncode
  except subprocess.TimeoutExpired as e:
   text=(e.stdout or b'').decode('utf-8',errors='replace')+'\nERROR: timeout\n';rc=124
  raw=text.encode('utf-8');(evidence/(name+'.log')).write_bytes(raw)
  errors=[line for line in text.splitlines() if re.search(r'SCRIPT ERROR|Parse Error|Failed to load|FAIL:|Could not open|^ERROR:',line)]
  inherited=[x for x in errors if any(t in x for t in ['ret != noErr','RID allocations','RID of type','resources still in use','Pages in use exist at exit'])]
  errors=[x for x in errors if x not in inherited]
  row=dict(test=name,command=list(map(str,cmd)),exit=rc,seconds=round(time.monotonic()-start,3),passes=len(re.findall(r'^PASS:',text,re.M)),errors=errors,inherited_diagnostics=inherited,log_sha256=digest(raw),expected=expected)
  row['passed']=rc==0 and not errors and (expected is None or expected in text)
  rows.append(row)
  (out/'QA_RESULTS.json').write_text(json.dumps(dict(source=sha,host=platform.platform(),architecture=platform.machine(),mode='graphical automated fixture' if a.graphical else 'native headless automated',checks=rows),indent=2)+'\n',encoding='utf-8')
  print(name, 'PASS' if row['passed'] else 'FAIL',row['passes'],flush=True)
  assert row['passed'],text[-5000:]
  return text
 def profile(name):
  home=out/'profiles'/name;home.mkdir(parents=True,exist_ok=True)
  env=os.environ.copy();env.update(HOME=str(home),APPDATA=str(home),LOCALAPPDATA=str(home),XDG_DATA_HOME=str(home/'xdg'),PYTHONIOENCODING='utf-8')
  return env
 base=[a.godot,'--headless','--path',root]
 run('import-warmup',base+['--editor','--import','--quit'],timeout=300)
 run('import-settled',base+['--editor','--import','--quit'],timeout=300)
 run('baseline',[sys.executable,root/'tools/verify_baseline.py'])
 run('preservation',[sys.executable,root/'tools/verify_tr05_preservation.py'])
 run('source-regressions',[sys.executable,root/'tools/run_tr05_qa.py','--godot',a.godot],timeout=1800)
 suites=json.loads((root/'build/tr05/qa/results.json').read_text())
 assert len(suites)==25 and sum(x['passes'] for x in suites)==1607
 assert all(x['passes']>0 and not(x['exit'] or x['failures'] or x['script_errors']) for x in suites)
 export_env=profile('export');templates=Path(os.environ['BUILD06_TEMPLATES'])
 template_dest=(Path(export_env['APPDATA'])/'Godot' if host=='windows' else Path(export_env['HOME'])/'Library/Application Support/Godot')/'export_templates/4.6.1.stable'
 shutil.copytree(templates,template_dest,dirs_exist_ok=True)
 preset='Windows Desktop' if host=='windows' else 'macOS'
 raw=out/('raw.exe' if host=='windows' else 'raw.zip')
 repeat=out/('repeat.exe' if host=='windows' else 'repeat.zip')
 run('export',base+['--export-release',preset,raw],export_env,300)
 run('export-repeat',base+['--export-release',preset,repeat],export_env,300)
 stage=out/'staging';assert not stage.exists(),'Use a fresh execution checkout'
 stage.mkdir()
 if host=='windows':
  binary=stage/'Kaze-BUILD06.exe';shutil.copy2(raw,binary);packed=binary
  repeat_pack=pack_bytes(repeat);architectures=['x86_64']
 else:
  subprocess.run(['ditto','-x','-k',str(raw),str(stage)],check=True)
  app=next(stage.glob('*.app'));app.rename(stage/'Kaze-BUILD06.app');app=stage/'Kaze-BUILD06.app'
  binary=next((app/'Contents/MacOS').iterdir());packed=next(app.rglob('*.pck'))
  repeat_dir=out/'repeat-app';repeat_dir.mkdir();subprocess.run(['ditto','-x','-k',str(repeat),str(repeat_dir)],check=True)
  repeat_pack=next(repeat_dir.rglob('*.pck')).read_bytes()
  architectures=subprocess.check_output(['lipo','-archs',str(binary)],text=True).split()
  assert set(architectures)=={'x86_64','arm64'}
 first_pack=pack_bytes(packed)
 reproducibility={'export_a_sha256':digest(raw.read_bytes()),'export_b_sha256':digest(repeat.read_bytes()),'export_bytes_identical':raw.read_bytes()==repeat.read_bytes(),'pck_a_sha256':digest(first_pack),'pck_b_sha256':digest(repeat_pack),'pck_bytes_identical':first_pack==repeat_pack}
 (evidence/'REPRODUCIBILITY.json').write_text(json.dumps(reproducibility,indent=2)+'\n')
 assert reproducibility['pck_bytes_identical'],'Repeated export changed runtime payload; investigate before publishing'
 os.environ['BUILD05_SOURCE_ROOT']=str(root)
 loader=importlib.util.spec_from_file_location('build05_pack_audit',CONTROL.parent/'build05/audit.py');audit=importlib.util.module_from_spec(loader);loader.loader.exec_module(audit)
 pack_audit=audit.audit_pack(packed.read_bytes())
 assert any('cinematic_transitions.gdc' in n for n in pack_audit['entries'])
 assert not any(n.startswith(('assets/art05/','assets/art06/','assets/art07/')) for n in pack_audit['entries']),'Candidate art unexpectedly packaged'
 (evidence/'PACK_AUDIT.json').write_text(json.dumps(pack_audit,indent=2)+'\n')
 fixtures=stage/'fixtures';fixtures.mkdir()
 for name,room,at,flags in PILOTS:
  seed=dict(version=8,checkpoint_room=room,checkpoint_position=at,double_jump=True,tether_unlocked=True,dash_unlocked=True,completed=True,guard_defeated=True,boss_defeated=True,speed_upgrade_level=0,kunai_unlocked=dict(wind=True,fire=True,electric=True),opened_kunai_gates=dict(skyworks_wind_intake=True,cistern_wind_cache=True,spire_wind_shutter=True),relay_fragments=dict(undercroft_sigil=True,terrace_west=True,terrace_fire_cache=True),expansion_flags=dict(junction_return=True),visited=[i==room for i in range(21)])
  (fixtures/(name+'.json')).write_text(json.dumps(seed)+'\n')
 for name,room,at,flags in PILOTS+[('Fresh',0,[],[])]:
  if host=='windows':
   seed='' if name=='Fresh' else 'copy /y "fixtures\\'+name+'.json" "profiles\\'+name+'.json" >nul\r\n'
   text='@echo off\r\ncd /d "%~dp0"\r\nif not exist "profiles" mkdir "profiles"\r\n'+seed+'"%~dp0Kaze-BUILD06.exe" %* -- '+' '.join(flags)+' "--tr05-save=%~dp0profiles\\'+name+'.json"\r\nexit /b %errorlevel%\r\n'
   (stage/('Play-'+name+'.cmd')).write_bytes(text.encode())
  else:
   seed='' if name=='Fresh' else f'cp "$HERE/fixtures/{name}.json" "$HERE/profiles/{name}.json"\n'
   text='#!/bin/bash\nset -euo pipefail\nHERE="$(cd "$(dirname "$0")" && pwd)"\nmkdir -p "$HERE/profiles"\n'+seed+'exec "$HERE/Kaze-BUILD06.app/Contents/MacOS/'+binary.name+'" "$@" -- '+' '.join(flags)+' "--tr05-save=$HERE/profiles/'+name+'.json"\n'
   launcher=stage/('Play-'+name+'.command');launcher.write_bytes(text.encode());launcher.chmod(0o755)
 (stage/'README.txt').write_text('KAZE BUILD-06 / INTERNAL PLAYTEST / NO PRODUCTION RELEASE\nSource: '+sha+'\n'+spec['content_note']+'\n\nExtract fully into a writable folder. Play-Fresh creates an isolated persistent campaign.\nSix demonstration launchers reset only their own seeded profiles. Seeded unlocks are\nfixtures, not earned progression. Direct EXE/app launch uses the historical ordinary\nsave identity; use the supplied launchers.\n\nA/D move, double-tap run, Space jump, E meaningful interactions, Q tether, Shift dash,\nJ attack, F parry, R kunai, T element, M map, I kit, Escape pause, F6 reduced motion.\nCanal-Automatic: A; Door-East: D; Door-West: A; stairs: E.\nKnown doorway jump recovery issue #42 remains in this baseline control.\nNo ART-06 lateral/R18 integration or ART-07 idle/waiting/crouch substitution.\nUnsigned/unnotarized. Scripted native checks do not certify a human campaign,\ngamepad, or sustained FPS. No signing/security bypass is bundled.\n',encoding='utf-8')
 archive=out/('Kaze-BUILD06-'+host+'-'+a.source+'-'+sha[:8]+'.zip')
 with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
  for f in sorted(stage.rglob('*')):
   if not f.is_file():continue
   info=zipfile.ZipInfo(f.relative_to(stage).as_posix(),(2026,1,1,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
   info.create_system=3;info.external_attr=((stat.S_IFREG|(0o755 if os.access(f,os.X_OK) else 0o644))<<16)
   z.writestr(info,f.read_bytes())
 extracted=out/'Downloaded Candidate With Spaces';extracted.mkdir()
 with zipfile.ZipFile(archive) as z:
  assert z.testzip() is None
  for entry in z.infolist():
   assert (extracted/entry.filename).resolve().is_relative_to(extracted.resolve())
   z.extract(entry,extracted)
   if host=='macos':(extracted/entry.filename).chmod(entry.external_attr>>16&0o777)
  members={i.filename:digest(z.read(i)) for i in z.infolist()}
 if host=='windows':
  release=extracted/'Kaze-BUILD06.exe';export_pack=release
 else:
  release=next((extracted/'Kaze-BUILD06.app/Contents/MacOS').iterdir());export_pack=next(extracted.rglob('*.pck'))
 release_env=profile('release');fresh=str(out/'release-fresh.json')
 run('native-release-startup',[release,'--headless','--fixed-fps','60','--quit-after','120','--','--tr05-save='+fresh],release_env,90,'Godot Engine v4.6.1')
 for launcher in sorted(extracted.glob('Play-*')):
  cmd=([os.environ.get('COMSPEC','cmd.exe'),'/d','/c',str(launcher)] if host=='windows' else [launcher])+['--headless','--fixed-fps','60','--quit-after','120']
  run('launcher-'+launcher.stem,cmd,profile('launcher'),90,'Godot Engine v4.6.1')
 env=profile('packaged');env.update(BUILD06_PACK=str(export_pack),BUILD06_CAPTURE_DIR=str(evidence/'native-captures'),BUILD06_GRAPHICAL='1' if a.graphical else '0')
 run('native-exported-input',[a.godot]+([] if a.graphical else ['--headless'])+['--path',root,'--fixed-fps','60','--script',CONTROL/'packaged_native.gd','--','--test'],env,300,'54 checks, 0 failure(s)')
 for suite in ['intentional_space','audit_intentional_space','movement_momentum','save_compatibility','expansion_gates_save','skyworks_progression']:
  method='_run' if suite in ['movement_momentum','save_compatibility','skyworks_progression'] else 'run'
  wrapper=out/('packaged-'+suite+'.gd')
  init='func _init():\n\tif not ProjectSettings.load_resource_pack(OS.get_environment("BUILD06_PACK"),true):\n\t\tpush_error("BUILD06 pack mount failed");quit(1);return\n\tcall_deferred("'+method+'")\n'
  text='extends "res://tests/'+suite+'.gd"\n'+init
  if suite=='audit_intentional_space':
   text=(root/'tests/audit_intentional_space.gd').read_text().replace('func _init(): call_deferred("run")',init.rstrip()).replace('"res://build/ld03"',json.dumps(str(evidence/'packaged-room-audit')))
  wrapper.write_text(text,encoding='utf-8')
  run('exported-'+suite,base+['--fixed-fps','60','--script',wrapper,'--','--test'],env,120)
  assert rows[-1]['passes']>0
 after=snapshot(root);changes=[n for n in before if before[n]!=after.get(n)]
 (evidence/'SOURCE_PRESERVATION.json').write_text(json.dumps(dict(source=sha,tracked_files=len(before),changes=changes,before=before,after=after),indent=2)+'\n')
 assert not changes,changes
 controls=git(CONTROL,'rev-parse','HEAD').decode().strip()
 manifest=dict(source_commit=sha,source_tree=git(root,'rev-parse',sha+'^{tree}').decode().strip(),controls_commit=controls,engine=VERSION,engine_sha256=digest(Path(a.godot).read_bytes()),host=platform.platform(),architectures=architectures,timestamp_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),run_url='https://github.com/'+os.environ.get('GITHUB_REPOSITORY','cappy2yappy/momentum-fractured')+'/actions/runs/'+os.environ.get('GITHUB_RUN_ID','local'),run_attempt=os.environ.get('GITHUB_RUN_ATTEMPT','local'),content=spec,reproducibility=reproducibility,archive=archive.name,archive_sha256=digest(archive.read_bytes()),archive_bytes=archive.stat().st_size,pck_sha256=digest(first_pack),pck_entries=pack_audit['entry_count'],members=members,source_suites=25,source_assertions=1607,exported_assertions=sum(x['passes'] for x in rows if x['test'].startswith(('native-exported','exported-'))),source_files_unchanged=len(before),native_coverage='graphical automated input fixture; headless release/launchers' if a.graphical else 'native headless release, launchers and input fixture',signing='unsigned/unnotarized',limitations=['No hands-on human campaign','No physical gamepad','No sustained FPS','Issue #42 unresolved in baseline'])
 (out/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
 (out/'SHA256SUMS.txt').write_text(manifest['archive_sha256']+'  '+archive.name+'\n')
 if os.environ.get('BUILD06_INSTALL'):shutil.copy2(os.environ['BUILD06_INSTALL'],evidence/'INSTALL.json')
 print(json.dumps({k:v for k,v in manifest.items() if k!='members'}),flush=True)

if __name__=='__main__':main()
