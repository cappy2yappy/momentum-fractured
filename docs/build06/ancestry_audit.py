from pathlib import Path
import datetime,json,subprocess
r=Path(__file__).resolve().parents[2];out=r/'docs/build06/evidence';out.mkdir(parents=True,exist_ok=True)
refs={
 'main':'origin/main','baseline39':'5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c',
 'pipeline40':'32e75a884b62d08f9e024eab5b01429e87ed12f7',
 'tr06_51':'baedd6786ad4bee2123ea872b437bbb98e6d2721',
 'art05_41':'60859a861b4dbcde25f2fe274bae7400bd9eb11b',
 'art06_lateral':'5fc41d231ee7a030a5c273e5263f96be54b55a8e',
 'r18_art47':'4b11bef0b3727f1647029cb04568b96a2e09c9fd',
 'art07_initial':'65e1e08d3650349ae1573985af3470b2bb6ac9e9',
 'art07':'18491105da5f8dd0b11b616c7da81803ced1fadc',
 'ldtools49':'00d74c36212e0493c242c25e15d4200ef094a49c',
 'st03_38':'553285f1e8a3961c6b7c1c83ba861bbd4ee21438'}
def git(*args):return subprocess.check_output(['git','-C',str(r),*args],text=True).strip()
base=refs['baseline39'];data={'timestamp_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'refs':{},'dry_runs':[]}
for name,ref in refs.items():
 sha=git('rev-parse',ref);ancestor=git('merge-base',base,sha)
 files=git('diff','--name-only',base,sha).splitlines()
 runtime=[f for f in files if f.startswith(('scripts/','scenes/','world/','assets/')) or f in ['project.godot','export_presets.cfg']]
 data['refs'][name]={'sha':sha,'merge_base_with_pr39':ancestor,'left_right_count':git('rev-list','--left-right','--count',base+'...'+sha),'changed_files_vs_pr39':files,'runtime_or_asset_changes':runtime,'assets_art06_files':git('ls-tree','-r','--name-only',sha,'--','assets/art06').splitlines(),'assets_art07_files':git('ls-tree','-r','--name-only',sha,'--','assets/art07').splitlines()}
for left,right in [('pipeline40','tr06_51'),('pipeline40','art06_lateral'),('pipeline40','r18_art47'),('pipeline40','art07'),('tr06_51','r18_art47'),('art06_lateral','r18_art47'),('r18_art47','ldtools49'),('pipeline40','st03_38')]:
 p=subprocess.run(['git','-C',str(r),'merge-tree','--write-tree',refs[left],refs[right]],capture_output=True,text=True,timeout=120)
 data['dry_runs'].append({'left':left,'right':right,'exit':p.returncode,'conflict_free':p.returncode==0,'output':p.stdout,'stderr':p.stderr,'method':'merge-tree only; no checked-out merge or ref update'})
(out/'ANCESTRY.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'refs':{k:{n:v for n,v in d.items() if n in ['sha','merge_base_with_pr39','left_right_count']} for k,d in data['refs'].items()},'dry_runs':[{k:v for k,v in d.items() if k not in ['output','stderr']} for d in data['dry_runs']]},indent=2))
