"""Additional strict proof for the contract-required JSON export filter."""
from pathlib import Path
import re, subprocess
root = Path(__file__).resolve().parents[2]
base = 'c2170032d08ea55268313e0020676c743251deab'
def original(path):
    return subprocess.check_output(['git', 'show', base + ':' + path], cwd=root).decode()
def function(text, name):
    return re.search(r'^func ' + name + r'\(.*?(?=^func |\Z)', text, re.S | re.M).group(0).strip()
current = (root / 'scripts/world.gd').read_text()
old = original('scripts/world.gd')
for name in ['configure_input','can_enter','world_edges','room_size','left_exit_position','right_exit_position','save_progress','load_progress','recover_from_fall','add_platform']:
    assert function(current, name) == function(old, name), name
    print('PASS byte-identical:', name)
export = (root / 'export_presets.cfg').read_text()
new = 'include_filter="world/*.txt,data/story/*,data/encounters/*,data/hazards/*"'
old_filter = 'include_filter="world/*.txt"'
assert export.count(new) == original('export_presets.cfg').count(old_filter) == 2
assert export.replace(new, old_filter) == original('export_presets.cfg')
print('PASS only two exact JSON include-filter extensions')
for path in ['scripts/player.gd','scripts/guard.gd','scripts/world_expansion.gd','scripts/route_extension.gd','scripts/skyworks_region.gd','world/MapData.txt','project.godot']:
    assert (root / path).read_text() == original(path), path
    print('PASS unchanged:', path)
