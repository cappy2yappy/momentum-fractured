"""Preview renders (PIL composition of repo assets; NOT Godot captures). Writes to docs/pm_pilot/art/previews/."""
import os, sys
sys.path.insert(0, os.path.dirname(__file__))
from scene import *
OUT = P('docs/pm_pilot/art/previews'); os.makedirs(OUT, exist_ok=True)
VIEW = (0, 720)
F = font(15); FS = font(12)

def caption(im, text, h=26):
    out = Image.new('RGBA', (im.width, im.height + h), (14, 16, 26, 255)); out.alpha_composite(im.convert('RGBA'), (0, 0))
    ImageDraw.Draw(out).text((8, im.height + 5), text, font=FS, fill=(222, 214, 232, 255)); return out

def old_exit(view=VIEW):
    """PR51 draw_exit(): 96x132 dark rect, 12x140 jambs at +-52, 8px lintel line, floor line, arrow (cinematic_transitions.gd)."""
    im = backdrop(view); d = ImageDraw.Draw(im); draw_pad(d, view)
    at = (120 - view[0], 1200 - view[1]); c = (217, 201, 173, 255)
    d.rectangle([at[0] - 48, at[1] - 132, at[0] + 48, at[1]], fill=(20, 28, 41, 255))
    for s in (-1, 1): d.rectangle([at[0] + s * 52 - 6, at[1] - 140, at[0] + s * 52 + 6, at[1]], fill=(103, 112, 116, 255))
    d.line([at[0] - 60, at[1] - 140, at[0] + 60, at[1] - 140], fill=(146, 144, 138, 255), width=8)
    d.line([at[0] - 48, at[1] - 3, at[0] + 48, at[1] - 3], fill=c, width=4)
    d.line([at[0] + 18, at[1] - 55, at[0] - 18, at[1] - 55], fill=c, width=3)
    d.polygon([(at[0] - 4, at[1] - 67), (at[0] - 18, at[1] - 55), (at[0] - 4, at[1] - 43)], outline=c)
    return im

def standing(x=120, clip='idle', i=0, facing=-1):
    k = kaze(clip, i, facing); return compose(VIEW, (k[0], k[1], x, 1200))

def wipe_overlay(im, lead, rows, badge_alpha=0.0, fade=0.0):
    panels = [Image.open(P('assets/pm_pilot/wipe', f'wipe_panel_{c}.png')).convert('RGBA') for c in 'abc']
    for r, y in enumerate([-230, -60, 110, 280, 450]):
        p = panels[r % 3]; off = rows[r]
        im.alpha_composite(p, (round(lead + off), y)) if lead + off > -p.width and lead + off < im.width else None
    if badge_alpha > 0:
        b = Image.open(P('assets/pm_pilot/wipe/wipe_badge_plate.png')).convert('RGBA')
        b.putalpha(b.getchannel('A').point(lambda v: int(v * badge_alpha)))
        im.alpha_composite(b, (410, 480))
        ImageDraw.Draw(im).text((434, 496), '<- CANAL HAVEN', font=font(22), fill=(212, 182, 206, int(255 * badge_alpha)))
    return im

def seq_frame(t):
    """Staged ~2.7 s sequence. Only approved clips: run strip (flipped for facing left, as player.gd does) and idle strip."""
    TRIG = 120
    if t < 0.25: x, clip, i = 330, 'idle', int(t / 0.16) % 8
    elif t < 0.25 + 210 / 400: x = 330 - 400 * (t - 0.25); clip, i = 'run', int((t - 0.25) / 0.08) % 8
    else:
        tt = t - (0.25 + 210 / 400); x = max(88, TRIG - 120 * tt) if tt < 0.35 else 88
        clip, i = 'run', int((t - 0.25) / 0.08) % 8
    shade = None
    if x < TRIG:
        f = min(1, (TRIG - x) / 32.0); shade = (1 - 0.85 * f, 1 - 0.85 * f, 1 - 0.80 * f)   # presentation tint into the dark aperture
    facing = -1
    k = kaze(clip, i, facing, shade)
    im = compose(VIEW, (k[0], k[1], x, 1200))
    tw0 = 1.15
    if t >= tw0:
        u = min(1, (t - tw0) / 0.9); u = 1 - (1 - u) ** 2
        lead = 1500 - u * (1500 + 300)             # leading edge 1500 -> -300 (full coverage)
        rows = [0, -90, 50, -60, 30]
        wipe_overlay(im, lead, rows, badge_alpha=max(0, min(1, (t - 1.8) / 0.25)))
    if t >= 2.35:
        a = min(1, (t - 2.35) / 0.35); ov = Image.new('RGBA', im.size, (20, 20, 43, int(255 * a))); im.alpha_composite(ov)
        ImageDraw.Draw(im).text((434, 496), '', font=F)
    d = ImageDraw.Draw(im); d.rectangle([0, 684, 1280, 720], fill=(10, 10, 20, 215))
    d.text((12, 692), 'STAGING PREVIEW  |  approved run/idle strips + deterministic composition only  |  no authored entry/exit poses  |  creator acceptance PENDING', font=FS, fill=(244, 219, 150, 255))
    if TRIG - 2 <= x <= TRIG + 2 and 0 < t < 2: d.line([TRIG, 1068 - VIEW[1], TRIG, 1200 - VIEW[1]], fill=(255, 90, 90, 200), width=1)
    return im

if __name__ == '__main__':
    # 1 true-size still
    standing(120, 'idle', 0).convert('RGB').save(f'{OUT}/canal_exit_kaze_true_size.png')
    st = standing(120, 'idle', 0).crop((0, 300, 420, 540)).resize((1260, 720), Image.NEAREST)
    st.convert('RGB').save(f'{OUT}/canal_exit_kaze_true_size_3x.png')
    # 2 compare strip: before (PR51 draw_exit) / after (art layers)
    a = caption(old_exit().crop((0, 300, 420, 540)), 'BEFORE: PR51 draw_exit procedural rect, stand-in only')
    b = caption(standing(120).crop((0, 300, 420, 540)), 'AFTER: pm_pilot Canal layers L0-L4, Kaze idle strip at game scale')
    s = Image.new('RGBA', (a.width * 2 + 12, a.height), (14, 16, 26, 255)); s.alpha_composite(a, (0, 0)); s.alpha_composite(b, (a.width + 12, 0))
    s.resize((s.width * 2, s.height * 2), Image.LANCZOS).convert('RGB').save(f'{OUT}/canal_compare_strip.png')
    # 3 exploded layer sheet
    names = ['L0_hall_back_wall', 'L1_door_interior', 'L1_door_frame', 'L1_door_leaf', 'L2_gatehouse_face', 'L2_lintel_course', 'L3_back_pier', 'L4_mouth_corbel']
    sheet = Image.new('RGBA', (1280, 520), (30, 34, 48, 255)); d = ImageDraw.Draw(sheet); x = 10
    for n in names:
        l, _ = layer(n)
        if n == 'L2_gatehouse_face': l = l.crop((0, 660, 296, 1020))
        sheet.alpha_composite(l, (x, 30)); d.text((x, 10), n.replace('_', ' '), font=FS, fill=(222, 214, 232, 255)); x += l.width + 14
        if x > 1100: break
    sheet.convert('RGB').save(f'{OUT}/canal_layer_sheet.png')
    # 4 held poses sheet (existing approved keys, registered as held poses)
    hp = Image.new('RGBA', (1280, 724 + 40), (60, 66, 80, 255)); hp.alpha_composite(img('assets/art04/kaze/key_pose_atlas.png'), (0, 0))
    d = ImageDraw.Draw(hp)
    for i, n in enumerate(['turn_depth_key  (quarter-rear, held)', 'enter_depth_key  (rear, held; WIP defects per ART-05)', 'stair_up_key  (held)', 'stair_down_key  (held)']):
        d.text((i * 320 + 8, 730), n, font=FS, fill=(244, 219, 150, 255))
    hp.convert('RGB').resize((960, 573)).save(f'{OUT}/held_poses_sheet.png')
    # 5 GIF
    fr = [seq_frame(i / 20.0).convert('RGB').resize((768, 432), Image.LANCZOS) for i in range(0, 58)]
    pal = [f.quantize(colors=96, method=Image.MEDIANCUT, dither=Image.NONE) for f in fr]
    pal[0].save(f'{OUT}/canal_staging_preview.gif', save_all=True, append_images=pal[1:], duration=50, loop=0, optimize=True)
    seq_frame(0.7).convert('RGB').save(f'{OUT}/seq_t0.70_trigger.png'); seq_frame(1.55).convert('RGB').save(f'{OUT}/seq_t1.55_wipe.png'); seq_frame(2.1).convert('RGB').save(f'{OUT}/seq_t2.10_badge.png')
    print('previews ok')
