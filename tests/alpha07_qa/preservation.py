"""Independent PR78 composition proof; keeps original PR37 guard outcomes separate."""
from pathlib import Path
import subprocess, re, hashlib, json
root=Path(__file__).resolve().parents[2]
BASE='af184380fb690f2c19bac69960b7aacce50f9ff2'
def original(path): return subprocess.check_output(['git','show',BASE+':'+path],cwd=root)
def function(text,name):
    return re.search(r'^func '+name+r'\(.*?(?=^func |\Z)',text,re.S|re.M).group(0).strip()
checks=[]
def check(ok,label):
    checks.append({'pass':bool(ok),'label':label});print(('PASS: ' if ok else 'FAIL: ')+label)
world=(root/'scripts/world.gd').read_text(); old=original('scripts/world.gd').decode()
for name in ['configure_input','can_enter','world_edges','room_size','left_exit_position','right_exit_position','save_progress','load_progress','recover_from_fall','add_platform']:
    check(function(world,name)==function(old,name),name+' exact PR78 body')
for path in ['scripts/player.gd','scripts/guard.gd','scripts/world_expansion.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','scripts/level_geometry.gd','scripts/cinematic_transitions.gd','scripts/bellroof_walk.gd','world/MapData.txt','project.godot']:
    check((root/path).read_bytes()==original(path),path+' byte-exact PR78')
assets=[]
for group in ['assets/kaze/cleaned','assets/web','assets/art04','assets/art08']:
    for path in sorted((root/group).rglob('*')):
        if path.is_file() and path.suffix in ['.png','.tres','.tscn','.json']:
            rel=path.relative_to(root).as_posix(); data=path.read_bytes(); same=data==original(rel)
            assets.append({'path':rel,'sha256':hashlib.sha256(data).hexdigest(),'same':same})
check(all(a['same'] for a in assets),f'{len(assets)} approved/candidate art files byte-exact PR78')
export=(root/'export_presets.cfg').read_text(); new='include_filter="world/*.txt,data/story/*,data/encounters/*,data/hazards/*"'; old_filter='include_filter="world/*.txt"'
check(export.count(new)==2 and export.replace(new,old_filter)==original('export_presets.cfg').decode(),'export only two exact contract-required include-filter extensions')
# Normalize exactly the designated owner's reviewed hook delta, preserving all other bytes.
normalized=world
new='\t\tif enemy.get_meta("story_managed_encounter", false):\n\t\t\tstory.record_encounter(encounter_id)\n\t\telse:\n\t\t\tcleared_encounters[encounter_id] = true\n\t\t\tsave_progress()'
old_defeat='\t\tcleared_encounters[encounter_id] = true\n\t\tsave_progress()'
assert normalized.count(new)==1
normalized=normalized.replace(new,old_defeat)
for hook in ['var story = preload("res://scripts/story/story_director.gd").new()\n','\tstory.room_loaded(self, room)\n','\tif not story.objective_override().is_empty(): return story.objective_override()\n','\tif story.interact(self): return\n','\tstory.update(self, dt)\n','\tif story.world != null: story.draw_room(self)\n']:
    assert normalized.count(hook)==1,hook
    normalized=normalized.replace(hook,'')
check(normalized==old,'world.gd entire file equals PR78 after only the six hooks plus director declaration are removed')
output={'base':BASE,'checks':checks,'asset_hashes':assets,'failures':sum(not c['pass'] for c in checks)}
(root/'build/alpha07_qa').mkdir(parents=True,exist_ok=True)
(root/'build/alpha07_qa/preservation.json').write_text(json.dumps(output,indent=2)+'\n')
print('QA PRESERVATION:',output['failures'],'failure(s)')
raise SystemExit(bool(output['failures']))
