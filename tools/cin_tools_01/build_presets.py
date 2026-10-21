#!/usr/bin/env python3
"""Reproduce shipped starting templates. Author scenes in Godot; do not regenerate edits.
Native Animation resources contain all timing. No runtime timeline compiler.
"""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
manifest = json.loads((ROOT / 'assets/art08/MANIFEST.json').read_text())
clips = {c['name']: c for c in manifest['clips']}

def vec(x, y): return f'Vector2({x}, {y})'
def col(r,g,b,a=1): return f'Color({r}, {g}, {b}, {a})'
def string(x): return json.dumps(x)
def array(values): return '[' + ', '.join(values) + ']'

def build(name, title, duration, commit, stem):
    ext = ['[ext_resource type="Script" path="res://tools/cin_tools_01/presentation.gd" id="1"]',
           '[ext_resource type="Texture2D" path="res://assets/web/district-fidelity.png" id="bg"]',
           '[ext_resource type="Texture2D" path="res://assets/web/terrain-materials.png" id="fg"]']
    c = clips[stem]
    ext.append(f'[ext_resource type="Texture2D" path="res://{c["strip"]}" id="actor"]')
    def anim(id, length, reduced=False):
        tracks=[]
        def track(path, times, values, discrete=False, transition=1):
            idx=len(tracks)
            tracks.append(f'''tracks/{idx}/type = "value"
tracks/{idx}/path = NodePath("{path}")
tracks/{idx}/interp = {0 if discrete else 1}
tracks/{idx}/enabled = true
tracks/{idx}/keys = {{
"times": PackedFloat32Array({', '.join(map(str,times))}),
"transitions": PackedFloat32Array({', '.join([str(transition)]*len(times))}),
"update": {1 if discrete else 0},
"values": {array(values)}
}}''')
        track('.:handoff', [0, length*.85 if reduced else commit], ['false','true'], True)
        track('.:sample_time', [0,length], ['0.0',str(length)])
        track('.:shake_strength',[0,length*.45,length*.6,length],["0.0",'0.0' if reduced else '3.0','0.0','0.0'])
        track('Framing:position',[0,length*.4,length], [vec(0,0),vec(0,0) if reduced else vec(-55,15),vec(0,0)],transition=1.8)
        track('Framing:scale',[0,length*.45,length], [vec(1,1),vec(1,1) if reduced else vec(1.08,1.08),vec(1,1)],transition=1.8)
        track('Framing/Shake/Background:position',[0,length], [vec(0,0),vec(0,0) if reduced else vec(18,0)])
        track('Framing/Shake/Foreground:position',[0,length], [vec(0,610),vec(0,610) if reduced else vec(-28,610)])
        track('Tint:color',[0,length*.5,length],[col(.09,.14,.24,.35),col(.2,.3,.4,.15),col(.09,.14,.24,.35)])
        track('Top:scale',[0,length*.2,length], [vec(1,.6),vec(1,1),vec(1,1)])
        track('Bottom:scale',[0,length*.2,length], [vec(1,.6),vec(1,1),vec(1,1)])
        track('Title:modulate',[0,length*.2,length*.7,length],[col(1,1,1,0),col(1,1,1),col(1,1,1),col(1,1,1,0)])
        track('Destination:modulate',[0,length*.15,length],[col(1,1,1,0),col(1,1,1),col(1,1,1)])
        track('Fade:color',[0,length*.15,length*.85,length],[col(.02,.03,.05,1),col(.02,.03,.05,0),col(.02,.03,.05,0),col(.02,.03,.05,1)])
        track('SpeedLines:modulate',[0,length*.4,length*.5,length*.7,length],[col(1,1,1,0),col(1,1,1,0 if reduced else .22),col(1,1,1,0 if reduced else .4),col(1,1,1,0),col(1,1,1,0)])
        track('.:music_cue',[0],[string('biome_reveal_reference' if name=='major_biome' else 'cinematic_reference')],True)
        track('.:sound_event',[0,length*.4],['""',string('reveal_reference')],True)
        track('Music:volume_db',[0,length*.15,length*.85,length],['-40.0','-8.0','-8.0','-40.0'])
        track('SFX:volume_db',[0,length],['-6.0','-12.0'])
        # ART-08 registered cell, pivot and timing. Root motion stays in metadata;
        # the approved TR-08 staging applies it to actual staircase treads.
        track('Framing/Shake/Character:texture',[0],['ExtResource("actor")'],True)
        track('Framing/Shake/Character:hframes',[0],[str(c['hframes'])],True)
        track('Framing/Shake/Character:offset',[0],[vec(c['cell'][0]/2-c['pivot'][0],c['cell'][1]/2-c['pivot'][1])])
        track('Framing/Shake/Character:flip_h',[0],['false'],True)
        # Candidate settle is an honest short action, then a held final pose.
        times=[0]; elapsed=0
        for d in c.get('durations',[1/c['fps']]*c['hframes'])[:-1]:
            elapsed+=d; times.append(round(elapsed,5))
        track('Framing/Shake/Character:frame', times, [str(i) for i in range(c['hframes'])],True)
        track('Framing/Shake/Character:position',[0,length],[vec(790,590),vec(790,590)])
        track('Framing/Shake/Character:scale',[0,length],[vec(.72,.72),vec(.72,.72)])
        return f'[sub_resource type="Animation" id="{id}"]\nresource_name = "{id}"\nlength = {length}\nmetadata/art08_clip = {string(stem)}\nmetadata/root_motion_source_px = {string(json.dumps(c.get("root_motion_px_per_frame",[])))}\n'+ '\n'.join(tracks)
    normal=anim('standard',duration)
    reduced=anim('reduced',.4,True)
    # RESET is a full static sample, so native editor reset restores every track.
    reset=anim('RESET',.001,True)
    nodes=f'''[node name="CutIn" type="Node2D"]
script = ExtResource("1")
artwork_status = "ART-08 {stem}: candidate. Background atlas and masonry strip are temporary staging. Audio references are silent until streams are assigned."

[node name="Framing" type="Node2D" parent="."]
[node name="Shake" type="Node2D" parent="Framing"]
[node name="Background" type="Sprite2D" parent="Framing/Shake"]
texture = ExtResource("bg")
centered = false
scale = Vector2(2.5, 1.5)
modulate = Color(0.45, 0.55, 0.7, 1)
[node name="Foreground" type="Sprite2D" parent="Framing/Shake"]
position = Vector2(0, 610)
texture = ExtResource("fg")
centered = false
scale = Vector2(3, 0.4)
[node name="Character" type="Sprite2D" parent="Framing/Shake"]
position = Vector2(790, 590)
scale = Vector2(0.72, 0.72)
texture = ExtResource("actor")
hframes = {c['hframes']}
offset = Vector2(0, -238)
[node name="Tint" type="ColorRect" parent="."]
offset_right = 1280.0
offset_bottom = 720.0
mouse_filter = 2
color = Color(0.09, 0.14, 0.24, 0.35)
[node name="SpeedLines" type="Node2D" parent="."]
modulate = Color(1, 1, 1, 0)
[node name="LineA" type="Line2D" parent="SpeedLines"]
points = PackedVector2Array(0, 110, 430, 170)
width = 3.0
[node name="LineB" type="Line2D" parent="SpeedLines"]
points = PackedVector2Array(1280, 570, 990, 530)
width = 3.0
[node name="Top" type="ColorRect" parent="."]
offset_right = 1280.0
offset_bottom = 56.0
mouse_filter = 2
color = Color(0.015, 0.02, 0.03, 1)
[node name="Bottom" type="ColorRect" parent="."]
offset_top = 652.0
offset_right = 1280.0
offset_bottom = 720.0
mouse_filter = 2
color = Color(0.015, 0.02, 0.03, 1)
[node name="Title" type="Label" parent="."]
offset_left = 92.0
offset_top = 265.0
text = {string(title)}
theme_override_font_sizes/font_size = 42
[node name="Destination" type="Label" parent="."]
offset_left = 92.0
offset_top = 603.0
text = "COUNTERWEIGHT SPIRE / TIMING STUDY"
theme_override_font_sizes/font_size = 20
[node name="Status" type="Label" parent="."]
offset_left = 22.0
offset_top = 17.0
text = "CIN-TOOLS-01 • ART-08 CANDIDATE • TEMPORARY ENVIRONMENT STAGING"
theme_override_font_sizes/font_size = 16
[node name="Fade" type="ColorRect" parent="."]
offset_right = 1280.0
offset_bottom = 720.0
mouse_filter = 2
color = Color(0.02, 0.03, 0.05, 0)
[node name="Music" type="AudioStreamPlayer" parent="."]
[node name="SFX" type="AudioStreamPlayer" parent="."]
[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {{&"": SubResource("library")}}
'''
    # Generic templates do not imply an unapproved boss, location or story beat.
    if name!='special_transition': nodes=nodes.replace('COUNTERWEIGHT SPIRE / TIMING STUDY','DESTINATION LABEL / EDIT IN INSPECTOR')
    text='[gd_scene load_steps=9 format=3]\n\n'+'\n'.join(ext)+'\n\n'+normal+'\n\n'+reduced+'\n\n'+reset+'''\n\n[sub_resource type="AnimationLibrary" id="library"]
_data = {&"standard": SubResource("standard"), &"reduced": SubResource("reduced"), &"RESET": SubResource("RESET")}
\n'''+nodes
    (ROOT/'presets/cutins'/f'{name}.tscn').write_text(text)

build('major_biome','BIOME ENTRANCE / TEMPLATE',2.4,2.0,'stair_arrive_idle_settle')
build('boss_intro','SUBJECT REVEAL / TEMPLATE',2.8,2.4,'stair_arrive_idle_settle')
build('special_transition','STAIRCASE REVEAL',1.8,1.6,'stair_arrive_idle_settle')
