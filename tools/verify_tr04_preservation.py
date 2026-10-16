"""Exact PR31 preservation, permitting only the reviewed TR04 world hooks."""
from pathlib import Path
import subprocess
r=Path(__file__).resolve().parents[1]
base='c2c6b08bfb3b85ad174dcc7ef60bddf1a3a48c15'
def original(path):return subprocess.check_output(['git','-c','safe.directory=*','show',base+':'+path],cwd=r)
failures=[]
def check(ok,label):
 print(('PASS: ' if ok else 'FAIL: ')+label)
 if not ok:failures.append(label)
world=(r/'scripts/world.gd').read_text(encoding='utf-8')
for hook in ['const LevelGeometry = preload("res://scripts/level_geometry.gd")\n','\trect = LevelGeometry.perimeter_landing(room,room_size(room),rect)\n','\t\t\tif pending_arrival == Vector2.INF: player.position = LevelGeometry.legacy_arrival(room,player.position)\n']:
 check(world.count(hook)==1,'single scoped hook: '+hook.strip());world=world.replace(hook,'')
world=world.replace('\t\tLevelGeometry.draw_surface(self,rect)\n','\t\tdraw_rect(rect, Color("252631"))\n\t\tdraw_rect(Rect2(rect.position, Vector2(rect.size.x, 7)), Color("aaa18b"))\n\t\tdraw_rect(Rect2(rect.position + Vector2(0, 7), Vector2(rect.size.x, 9)), Color("54535c"))\n')
check(world==original('scripts/world.gd').decode().replace('\r\n','\n'),'world PR31 text after removing four reviewed geometry/render hooks (LF normalized)')
for path in ['scripts/player.gd','scripts/mixed_transitions.gd','scripts/embodied_transitions.gd','scripts/world_expansion.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','scripts/guard.gd','scripts/storm_keeper.gd','scripts/hud.gd','scripts/momentum_profile.gd','project.godot','export_presets.cfg','world/MapData.txt']:
 check((r/path).read_bytes()==original(path),path+' PR31 exact')
for group in ['assets/kaze/cleaned','assets/web','assets/art04']:
 for path in sorted((r/group).rglob('*')):
  if path.is_file() and path.suffix in ['.png','.tres','.tscn']:
   relative=path.relative_to(r).as_posix();check(path.read_bytes()==original(relative),relative+' preserved')
print('TR04 PRESERVATION:',len(failures),'failure(s)');raise SystemExit(bool(failures))
