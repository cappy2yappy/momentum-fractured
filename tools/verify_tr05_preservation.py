"""Guard creator art/physics, level geometry and persistence against PR33."""
from pathlib import Path
import subprocess,re
r=Path(__file__).resolve().parents[1];base='1835fcca272fd6a925b3d8ad4834fb225a6caef6';failures=[]
def original(path):return subprocess.check_output(['git','-c','safe.directory=*','show',base+':'+path],cwd=r)
def check(ok,label):
 print(('PASS: ' if ok else 'FAIL: ')+label)
 if not ok:failures.append(label)
for path in ['scripts/player.gd','scripts/level_geometry.gd','scripts/mixed_transitions.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','scripts/guard.gd','scripts/storm_keeper.gd','scripts/hud.gd','scripts/momentum_profile.gd','project.godot','export_presets.cfg','world/MapData.txt']:
 check((r/path).read_bytes()==original(path),path+' PR33 exact')
for group in ['assets/kaze/cleaned','assets/web','assets/art04']:
 for p in sorted((r/group).rglob('*')):
  if p.is_file() and p.suffix in ['.png','.tres','.tscn']:
   path=p.relative_to(r).as_posix();check(p.read_bytes()==original(path),path+' PR33 exact')
def function(text,name):
 m=re.search(r'^func '+name+r'\(.*?(?=^func |\Z)',text,re.S|re.M);assert m,name
 return m.group(0).strip()
new=(r/'scripts/world.gd').read_text();old=original('scripts/world.gd').decode().replace('\r\n','\n')
for name in ['configure_input','can_enter','world_edges','room_size','left_exit_position','right_exit_position','save_progress','load_progress','recover_from_fall','add_platform']:
 check(function(new,name)==function(old,name),name+' PR33 function exact')
new=(r/'scripts/world_expansion.gd').read_text();old=original('scripts/world_expansion.gd').decode().replace('\r\n','\n')
for name in ['portals','allowed','regional','build_room','update']:
 check(function(new,name)==function(old,name),'expansion '+name+' PR33 function exact')
check('transition = 0.65' in (r/'scripts/world.gd').read_text(),'0.65s loader retained')
check('if transition < 0.32 and pending_room >= 0:' in (r/'scripts/world.gd').read_text(),'existing hidden-swap threshold retained')
print('TR05 PRESERVATION:',len(failures),'failure(s)');raise SystemExit(bool(failures))
