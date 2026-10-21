"""Only the exact R18 opt-in hook may differ from PR49's inherited game."""
from pathlib import Path
import subprocess
r=Path(__file__).resolve().parents[2];base='00d74c36212e0493c242c25e15d4200ef094a49c'
def original(path):return subprocess.check_output(['git','show',base+':'+path],cwd=r)
fail=[];count=0
for path in subprocess.check_output(['git','ls-tree','-r','--name-only',base],cwd=r,text=True).splitlines():
 if path=='scripts/world.gd':continue
 count+=1
 if not (r/path).exists() or (r/path).read_bytes()!=original(path):fail.append(path)
s=(r/'scripts/world.gd').read_text()
changes=[('\n\t\tif authored_room_active: break # Native pilot owns the single terrain draw.',''),('const RoomCreatorPilot = preload("res://tools/ld_tools_02/runtime_pilot.gd")\n',''),('var platforms: Array[Rect2] = []\n# Default off; no save field or project-wide activation.\nvar authored_r18_enabled = "--authored-r18" in OS.get_cmdline_user_args()\nvar authored_r18_path = RoomCreatorPilot.DEFAULT_LAYOUT\nvar authored_room_active = false','var platforms: Array[Rect2] = []'),('\n\tRoomCreatorPilot.prepare(self)',''),('\n\t# The authored bodies already exist. Retain generator bookkeeping, create no duplicates.\n\tif authored_room_active: return','')]
for new,old in changes:
 if s.count(new)!=1:fail.append('missing/duplicate pilot hook: '+new.splitlines()[0])
 s=s.replace(new,old)
if s!=original('scripts/world.gd').decode():fail.append('world.gd beyond exact approved hook')
print(f'{count} baseline files exact; world.gd reverse-hook comparison; {len(fail)} failures')
for path in fail:print('FAIL:',path)
raise SystemExit(bool(fail))
