"""Build a standalone Godot authoring project with no game/autoload/plugin dependencies."""
from pathlib import Path
import argparse, shutil, zipfile

p = argparse.ArgumentParser()
p.add_argument('destination', type=Path)
a = p.parse_args()
source = Path(__file__).resolve().parent
dest = a.destination.resolve()
if dest.exists():
    raise SystemExit('Choose a fresh destination; existing work is never overwritten.')
folder = dest/'tools/ld_tools_01'
folder.mkdir(parents=True)
names = ['rectangle_surface.gd','slope_surface.gd','preview.gd','preview.tscn','preview_edited.tscn','layout_records.gd',
         'r18_layout.tscn','r_18_pump_gallery_layout.tscn','r18_frozen.json']
for name in names:
    shutil.copy2(source/name, folder/name)
    uid = source/(name+'.uid')
    if uid.exists(): shutil.copy2(uid, folder/uid.name)
(folder/'evidence').mkdir()
for file in sorted((source/'evidence').iterdir()):
    if file.is_file() and file.suffix in {'.png','.jpg','.json','.log'}:
        shutil.copy2(file,folder/'evidence'/file.name)
for name in ['README.md','QA.md','MIGRATION.md','PLUGIN_EVALUATION.md']:
    if (source/name).exists(): shutil.copy2(source/name, folder/name)
(dest/'project.godot').write_text('''config_version=5
[application]
config/name="Kaze LD-TOOLS-01 Isolated Authoring"
run/main_scene="res://tools/ld_tools_01/preview.tscn"
config/features=PackedStringArray("4.6", "GL Compatibility")
[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
[rendering]
renderer/rendering_method="gl_compatibility"
environment/defaults/default_clear_color=Color(0.075,0.065,0.11,1)
''', encoding='utf-8')
(dest/'START-HERE.txt').write_text('Open project.godot in Godot 4.6.1.\nRead tools/ld_tools_01/README.md.\nF5 runs the geometry laboratory; it never loads Kaze gameplay or saves.\n',encoding='utf-8')
with zipfile.ZipFile(dest.with_suffix('.zip'),'w',zipfile.ZIP_DEFLATED) as z:
    for f in sorted(dest.rglob('*')):
        if f.is_file(): z.write(f, str(f.relative_to(dest)))
print(dest.with_suffix('.zip'))
