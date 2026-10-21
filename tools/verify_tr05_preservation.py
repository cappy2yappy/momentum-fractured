"""Guard creator art/physics, level geometry and persistence against PR37."""
from pathlib import Path
import subprocess,re
r=Path(__file__).resolve().parents[1];base='b950373efb5c4621d7da7e0be1506db048e3043a';failures=[]
def original(path):return subprocess.check_output(['git','-c','safe.directory=*','show',base+':'+path],cwd=r)
def check(ok,label):
 print(('PASS: ' if ok else 'FAIL: ')+label)
 if not ok:failures.append(label)
# Creator-approved narrow differences (ST-04 copy PR #72; defensive export filter).
# Each entry is (new text, original text). A file may differ from PR37 only by these exact swaps.
ALLOWED={
 'scripts/skyworks_region.gd':[
  ('Foundry Rest Station restored. The Keeper waits east.','Foundry Refuge restored. The Keeper waits east.'),
  ('FOUNDRY REST STATION \u2022 E','FOUNDRY REFUGE \u2022 E')],
 'export_presets.cfg':[
  ('build/*,.autoconverted/*,source_art/*','build/*,.autoconverted/*')],
}
def normalized(path,data):
 for new,old in ALLOWED.get(path,[]):
  data=data.replace(new.encode(),old.encode())
 return data
for path in ['scripts/player.gd','scripts/bellroof_walk.gd','scripts/level_geometry.gd','scripts/mixed_transitions.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','scripts/guard.gd','scripts/storm_keeper.gd','scripts/hud.gd','scripts/momentum_profile.gd','project.godot','export_presets.cfg','world/MapData.txt']:
 check(normalized(path,(r/path).read_bytes())==original(path),path+(' PR37 exact' if path not in ALLOWED else ' PR37 exact (allowed approved swaps only)'))
for group in ['assets/kaze/cleaned','assets/web','assets/art04']:
 for p in sorted((r/group).rglob('*')):
  if p.is_file() and p.suffix in ['.png','.tres','.tscn']:
   path=p.relative_to(r).as_posix();check(p.read_bytes()==original(path),path+' PR37 exact')
def function(text,name):
 m=re.search(r'^func '+name+r'\(.*?(?=^func |\Z)',text,re.S|re.M);assert m,name
 return m.group(0).strip()
new=(r/'scripts/world.gd').read_text();old=original('scripts/world.gd').decode().replace('\r\n','\n')
for name in ['configure_input','can_enter','world_edges','room_size','left_exit_position','right_exit_position','save_progress','load_progress','recover_from_fall','add_platform']:
 check(function(new,name)==function(old,name),name+' PR37 function exact')
new=(r/'scripts/world_expansion.gd').read_text();old=original('scripts/world_expansion.gd').decode().replace('\r\n','\n')
for name in ['portals','allowed','regional','build_room','update']:
 current=function(new,name)
 if name=='build_room':
  # PR58 added this exact, room-scoped enclosure hook. Keep the PR37
  # comparison for every other byte, and independently lock its implementation.
  hook='\tif index == 13: CanalGatehouse.build(w)\n'
  check(current.count(hook)==1,'single PR58 R13 gatehouse build hook')
  current=current.replace(hook,'')
 check(current==function(old,name),'expansion '+name+' PR37 function exact after scoped PR58 hook')
pilot='0656766d8fe13c702a4808b1d25ddd0855d8922c'
gatehouse=subprocess.check_output(['git','show',pilot+':scripts/canal_gatehouse.gd'],cwd=r)
check((r/'scripts/canal_gatehouse.gd').read_bytes()==gatehouse,'Canal gatehouse implementation PR58 exact')
check(new.count('const CanalGatehouse = preload("res://scripts/canal_gatehouse.gd")\n')==1,'single exact PR58 gatehouse preload')
check('transition = 0.65' in (r/'scripts/world.gd').read_text(),'0.65s loader retained')
check('if transition < 0.32 and pending_room >= 0:' in (r/'scripts/world.gd').read_text(),'existing hidden-swap threshold retained')
print('TR05 PRESERVATION:',len(failures),'failure(s)');raise SystemExit(bool(failures))
