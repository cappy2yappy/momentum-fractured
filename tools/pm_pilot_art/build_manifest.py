"""Writes assets/pm_pilot/MANIFEST.json (SHA256, dimensions, anchors, z-order, labels, import notes). Run after the other builders."""
import hashlib, json, os
from PIL import Image
R = 'assets/pm_pilot'
def sha(p): return hashlib.sha256(open(p, 'rb').read()).hexdigest()
rects = json.load(open('source_art/pm_pilot/canal_layer_rects.json'))
C = json.load(open('tools/pm_pilot_art/canal_contract_v1.json'))
z = {'L0_hall_back_wall': 0, 'L1_door_interior': 1, 'L1_door_frame': 2, 'L1_door_leaf': 3, 'L2_gatehouse_face': 4, 'L2_lintel_course': 5, 'L3_back_pier': 6, 'L4_mouth_corbel': 8}
notes = {
 'L0_hall_back_wall': 'Rear plane. Tiles horizontally (period 224).',
 'L1_door_interior': 'Behind the frame. Fills the 96x132 aperture; warm far-end glow stands for the R0 lamp.',
 'L1_door_frame': 'Aperture (72,1068,96,132) is fully transparent. Frame is behind Kaze.',
 'L1_door_leaf': 'Optional. Ajar leaf on the left hinge, covers about 30 percent of the aperture width. Drawn behind Kaze per contract.',
 'L2_gatehouse_face': 'Only y 660..1020 is normally on screen near the exit; the rest is tiling fill.',
 'L2_lintel_course': 'Bottom edge y1020 is the physical ceiling.',
 'L3_back_pier': 'Behind Kaze.',
 'L4_mouth_corbel': 'Foreground, in front of Kaze, above the walking envelope. Must not cover the aperture.',
}
assets = []
for n, r in rects.items():
    p = f'{R}/canal/canal_{n}.png'; im = Image.open(p)
    assets.append(dict(id=f'canal_{n}', path=p, sha256=sha(p), size=list(im.size), mode=im.mode, room=13,
        room_rect=r['rect'], anchor_top_left_room_px=r['rect'][:2], draw_order_back_to_front=z[n],
        in_front_of_kaze=(n == 'L4_mouth_corbel'), scale=1.0, label='procedural architecture',
        generator='tools/pm_pilot_art/build_canal.py', import_notes='lossless, mipmaps off, default filter; draw with draw_texture at room_rect position, no scaling', status='technical candidate; creator visual acceptance pending'))
for c in 'abc':
    p = f'{R}/wipe/wipe_panel_{c}.png'; im = Image.open(p)
    assets.append(dict(id=f'wipe_panel_{c}', path=p, sha256=sha(p), size=list(im.size), mode=im.mode, space='screen (1280x720 viewport)',
        anchor_top_left_screen_px='animated; see integration note', draw_order_back_to_front='transition overlay (above cinematic z3)', scale=1.0, travel='toward -x (leftward); flip_h for rightward exits',
        label='procedural architecture (wipe kit, original Kaze wind-cloth direction; not Persona art)', generator='tools/pm_pilot_art/build_wipe.py',
        import_notes='lossless, no mipmaps; tilted 6 degrees; stack 5 rows spaced 170 px; panel rows overlap', status='technical candidate; creator visual acceptance pending'))
p = f'{R}/wipe/wipe_badge_plate.png'; im = Image.open(p)
assets.append(dict(id='wipe_badge_plate', path=p, sha256=sha(p), size=list(im.size), mode=im.mode, space='screen', anchor_top_left_screen_px=[410, 480], scale=1.0,
    label='procedural architecture (UI plate, no text baked in)', generator='tools/pm_pilot_art/build_wipe.py', import_notes='engine draws destination text over it', status='technical candidate; creator visual acceptance pending'))
refs = []
for k in ['turn_depth_key', 'enter_depth_key', 'stair_up_key', 'stair_down_key']:
    p = f'assets/art04/kaze/{k}.png'
    refs.append(dict(id=k, path=p, sha256=sha(p), size=list(Image.open(p).size), pivot=[160, 600], scale=0.303125, offset=[0, -238], label='held pose',
        note='single held drawing, not animation; ART-04 PR30 source a6b76b9938825307bdcd4efb687c7198ea0d8681; referenced in place, not copied or modified; not used in the Canal staging preview'))
for k, sc, base in [('idle', 0.2649908807267889, 591), ('run', 0.3825780535911868, 491)]:
    p = f'assets/kaze/cleaned/kaze_{k}_strip.png'
    refs.append(dict(id=f'kaze_{k}_strip', path=p, sha256=sha(p), size=list(Image.open(p).size), frames=8, scale=sc, ground_baseline=base, label='authored drawing (approved cleaned strip)',
        note='used in the staging preview exactly as scripts/player.gd registers it (centered sprite, offset y = height/2 - baseline, flip_h when facing < 0)'))
doc = dict(schema_version=1, pilot='ART-PM (ORDER 3)', base='PR51 baedd6786ad4bee2123ea872b437bbb98e6d2721', contract='CANAL_CONTRACT v1 (LEVEL)', contract_rects=C['rects'],
    labels_legend=['authored drawing', 'held pose', 'deformation', 'procedural architecture', 'unfinished'],
    honesty='No new Kaze drawings were created. Deformation used in the preview: horizontal flip (player.gd behaviour) and a dark tint. Authored entry, traversal and departure poses are missing: docs/pm_pilot/art/MISSING_ANIMATION.md.',
    assets=assets, referenced_not_copied=refs,
    inspected_not_imported=[dict(source='PR41 60859a861b4dbcde25f2fe274bae7400bd9eb11b', note='turn_depth candidate right-to-rear only; enter_depth WIP with defects; stair_up rejected. Nothing copied.'),
                            dict(source='PR47 4b11bef0b3727f1647029cb04568b96a2e09c9fd', note='R18 art inspected for style reference only. Nothing copied.'),
                            dict(source='PR53 ART-07', note='excluded by order; not read.')])
json.dump(doc, open(f'{R}/MANIFEST.json', 'w'), indent=1)
print(len(assets), 'assets')
