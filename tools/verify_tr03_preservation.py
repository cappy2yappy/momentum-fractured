"""Verify protected TR-02 bytes and world policies, without rewriting manifests."""
from pathlib import Path
import subprocess,hashlib,re,json
ROOT=Path(__file__).resolve().parents[1]
BASE='e9a2d1ab0537f3f903c543b080451b3556961179'
def original(path):return subprocess.check_output(['git','show',f'{BASE}:{path}'],cwd=ROOT)
checks=[]
def check(ok,label):
    checks.append({'label':label,'passed':bool(ok)});print(('PASS: ' if ok else 'FAIL: ')+label)
for path in ['scripts/player.gd','scripts/mixed_transitions.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','scripts/hud.gd','scripts/guard.gd','scripts/storm_keeper.gd','project.godot','export_presets.cfg','world/MapData.txt']:
    check(original(path)==(ROOT/path).read_bytes(),path+' matches TR-02 byte for byte')
for group in ['assets/kaze/cleaned','assets/web']:
    for path in (ROOT/group).glob('kaze_*.png'):
        check(original(path.relative_to(ROOT).as_posix())==path.read_bytes(),str(path.relative_to(ROOT))+' preserved')
expansion=(ROOT/'scripts/world_expansion.gd').read_text()
visual_hook='\t\t\tif w.embodied_transitions.production_art.suppresses_legacy(w.embodied_transitions,w.room,Rect2(at-Vector2(160,225),Vector2(390,385))): continue\n'
check(expansion.count(visual_hook)==1 and expansion.replace(visual_hook,'')==original('scripts/world_expansion.gd').decode(),'world_expansion preserves all TR-02 code except scoped decoration suppression')
old=original('scripts/world.gd').decode();new=(ROOT/'scripts/world.gd').read_text()
def function(text,name):
    match=re.search(r'^func '+name+r'\([^\n]*\):?.*?(?=^func |\Z)',text,re.S|re.M)
    assert match,name
    return match.group(0).strip()
for name in ['configure_input','can_enter','world_edges','room_size','left_exit_position','right_exit_position','save_progress','load_progress','interact','recover_from_fall']:
    check(function(old,name)==function(new,name),name+' unchanged')
for line in ['transition = 0.65','if transition < 0.32 and pending_room >= 0:','player.position = destination + Vector2(110 if moving_east else -140, -2) if pending_arrival == Vector2.INF else pending_arrival']:
    check(line in new,line+' retained')
print(json.dumps({'base':BASE,'checks':len(checks),'failures':sum(not x['passed'] for x in checks)},sort_keys=True))
raise SystemExit(any(not x['passed'] for x in checks))
