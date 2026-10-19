#!/usr/bin/env python3
"""ART-08 manifest and strip verification (test-only). SKIPs (exit 3) until assets/art08/MANIFEST.json exists.

  art08_check.py --repo <worktree> [--out result.json]

Per clip: file exists and the SHA256 and byte size in the manifest match; hframes x 480 equals the strip width and the
height is 724; pivot (240,600); loop flag; fps or per-frame durations; contact frames inside range; provenance label is
not 'held' or 'unfinished' (those fail unless flagged as such); RGB zeroed where alpha is 0; no frame is empty; adjacent
identical frames (held within the clip) counted; loop seam differs; and the true-animation analyzer judges the strip.
Interface: /home/claude/wave3_shared/ANIMATION_INTERFACE.md (v1 or later); names compared with the requested clip list.
"""
import argparse, hashlib, json, sys
from pathlib import Path
import numpy as np
from PIL import Image
sys.path.insert(0, str(Path(__file__).resolve().parent))
import true_animation as ta

EXPECTED = ['stair_ascend_enter', 'stair_ascend_loop', 'stair_ascend_exit', 'stair_descend_enter', 'stair_descend_loop', 'stair_descend_exit',
            'door_approach_walk', 'door_turn_to_rear', 'door_cross', 'door_emerge', 'door_turn_to_side', 'door_walk_out']
LOCOMOTION = ('stair_ascend_loop', 'stair_descend_loop', 'door_approach_walk', 'door_walk_out', 'stair_ascend_enter', 'stair_descend_enter', 'stair_ascend_exit', 'stair_descend_exit', 'door_cross')


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--repo', required=True); ap.add_argument('--out')
    a = ap.parse_args()
    repo = Path(a.repo)
    mp = repo / 'assets/art08/MANIFEST.json'
    if not mp.exists():
        r = dict(status='SKIP', reason='assets/art08/MANIFEST.json not present in this checkout (no ART-08 candidate). NOT a pass.')
        print(json.dumps(r)); 
        if a.out: Path(a.out).write_text(json.dumps(r, indent=2))
        sys.exit(3)
    m = json.loads(mp.read_text())
    clips = m.get('clips', m) if isinstance(m, dict) else m
    if isinstance(clips, dict):
        clips = [dict(name=k, **v) if isinstance(v, dict) else dict(name=k) for k, v in clips.items()]
    rows, checks = [], []

    def chk(name, ok, detail=''):
        checks.append(dict(check=name, ok=bool(ok), detail=detail))
    names = [c.get('name') for c in clips]
    missing = [n for n in EXPECTED if n not in names]
    chk('inventory_names', not missing, 'missing from manifest (a rename table is acceptable only if published): %s' % missing)
    total_frames = 0
    for c in clips:
        name = c.get('name'); sp = repo / str(c.get('strip', c.get('path', ''))).replace('res://', '')
        row = dict(name=name, strip=str(sp.relative_to(repo)) if sp.exists() else str(sp), provenance=c.get('provenance'))
        if not sp.exists():
            chk(name + ':exists', False, str(sp)); rows.append(row); continue
        data = sp.read_bytes()
        chk(name + ':sha256', c.get('sha256') in (None, '') or hashlib.sha256(data).hexdigest() == c['sha256'], 'manifest %s actual %s' % (c.get('sha256'), hashlib.sha256(data).hexdigest()))
        chk(name + ':bytes', c.get('bytes') in (None, '') or len(data) == int(c['bytes']), 'manifest %s actual %d' % (c.get('bytes'), len(data)))
        im = Image.open(sp).convert('RGBA'); hf = int(c.get('hframes', 0)); cell = c.get('cell', [480, 724])
        total_frames += hf
        chk(name + ':geometry', hf > 0 and im.width == hf * cell[0] and im.height == cell[1] and list(cell) == [480, 724], '%dx%d hframes %s cell %s' % (im.width, im.height, hf, cell))
        chk(name + ':pivot', list(c.get('pivot', [240, 600])) == [240, 600], str(c.get('pivot')))
        chk(name + ':timing', bool(c.get('fps') or c.get('durations') or c.get('frame_durations')), 'fps or per-frame durations required')
        chk(name + ':loop_flag', isinstance(c.get('loop'), bool), str(c.get('loop')))
        cf = c.get('contact_frames') or c.get('contacts') or []
        chk(name + ':contacts_in_range', all(0 <= int(i) < hf for i in cf) and (name not in LOCOMOTION or len(cf) > 0 or not c.get('loop') ), 'contacts %s' % cf)
        prov = str(c.get('provenance', '')).lower()
        chk(name + ':provenance_not_held', not any(k in prov for k in ('held', 'unfinished')), prov)
        arr = np.asarray(im)
        zero_alpha = arr[:, :, 3] == 0
        dirty = int(np.count_nonzero(arr[:, :, :3][zero_alpha].any(axis=1))) if zero_alpha.any() else 0
        chk(name + ':rgb_zeroed_where_transparent', dirty == 0, '%d pixels with alpha 0 and nonzero RGB' % dirty)
        frames = ta.strip_frames(sp, hf)
        masks = [ta.norm_mask(f) for f in frames]
        empty = [i for i, mk in enumerate(masks) if mk is None]
        chk(name + ':no_empty_frames', not empty, str(empty))
        ident = sum(1 for i in range(hf - 1) if masks[i] is not None and masks[i + 1] is not None and ta.diff(masks[i], masks[i + 1]) < 0.02)
        loop = bool(c.get('loop'))
        seam = ta.diff(masks[-1], masks[0]) if loop and masks[0] is not None and masks[-1] is not None else None
        res = ta.analyze_masks(masks, loop, name)
        row.update(frames=hf, adjacent_identical=ident, loop_seam_diff=None if seam is None else round(seam, 3), animation=res)
        if hf >= 2:
            chk(name + ':true_animation', res['verdict'] == 'TRUE_ANIMATION' or (hf <= 4 and res['distinct'] >= 2 and res['max_leg_diff'] >= ta.POSE_T), '%s %s' % (res['verdict'], res['reason']))
            chk(name + ':no_held_frames', ident <= max(0, hf // 8), '%d adjacent identical pairs of %d' % (ident, hf - 1))
        else:
            chk(name + ':true_animation', False, 'single-frame clip is a held pose, not animation')
        if loop: chk(name + ':loop_seam', seam is not None and seam >= 0.02 and seam < 1.2, 'seam diff %s (identical first/last frame stutters)' % seam)
        rows.append(row)
    chk('total_frames_reported', True, 'total frames %d (69 requested inventory; Art may refine)' % total_frames)
    bad = [c for c in checks if not c['ok']]
    out = dict(status='FAIL' if bad else 'PASS', checks_run=len(checks), failures=len(bad), failed=bad, clips=rows, total_frames=total_frames)
    print(json.dumps({k: out[k] for k in ('status', 'checks_run', 'failures', 'total_frames')}))
    if a.out: Path(a.out).write_text(json.dumps(out, indent=2))
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
