"""Preserve PR33 simulation/topology/art while permitting the scoped R14 design."""
from pathlib import Path
import re,subprocess
r=Path(__file__).resolve().parents[1];base='1835fcca272fd6a925b3d8ad4834fb225a6caef6';failures=[]
def old(path):return subprocess.check_output(['git','-c','safe.directory=*','show',base+':'+path],cwd=r)
def check(ok,label):
 print(('PASS: ' if ok else 'FAIL: ')+label)
 if not ok:failures.append(label)
s=(r/'scripts/world.gd').read_text(encoding='utf-8')
for hook,count in [('const BellroofWalk = preload("res://scripts/bellroof_walk.gd")\n',1),('\tBellroofWalk.build(self)\n',1),('\tcheckpoint_position = BellroofWalk.stage_checkpoint(self,checkpoint_position)\n',2)]:
 check(s.count(hook)==count,'Scoped world hook count '+hook.strip());s=s.replace(hook,'')
check(s==old('scripts/world.gd').decode(),'World exact PR33 after builder and blocked-save staging hooks removed')
s=(r/'scripts/world_expansion.gd').read_text(encoding='utf-8');s=s.replace('const LORE = {14:Vector2(1300,1220),','const LORE = {14:Vector2(1700,700),').replace('\t\t\tif w.room==14: continue # LD03 uses grounded service-walk architecture.\n','')
check(s==old('scripts/world_expansion.gd').decode(),'Expansion exact PR33 except R14 optional log position and legacy decoration suppression')
s=(r/'scripts/room_presentation.gd').read_text(encoding='utf-8');before=old('scripts/room_presentation.gd').decode()
block=re.search(r'\tif w.room==14:\n.*?(?=\telif w.room==15:)',before,re.S).group()
hook='\tif w.room==14:\n\t\tw.BellroofWalk.draw_backdrop(w)\n'
check(s.count(hook)==1 and s.replace(hook,block)==before,'Only R14 background block changes; other presentation exact')
for path in ['scripts/player.gd','scripts/mixed_transitions.gd','scripts/embodied_transitions.gd','scripts/art04_presentation.gd','scripts/level_geometry.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','scripts/hud.gd','scripts/guard.gd','scripts/storm_keeper.gd','scripts/momentum_profile.gd','project.godot','export_presets.cfg','world/MapData.txt']:
 check((r/path).read_bytes()==old(path),path+' PR33 byte exact')
for group in ['assets/web','assets/kaze/cleaned','assets/art04']:
 for p in (r/group).rglob('*.png'):check(p.read_bytes()==old(p.relative_to(r).as_posix()),str(p.relative_to(r))+' preserved')
print('LD03 PRESERVATION:',len(failures),'failure(s)');raise SystemExit(bool(failures))
