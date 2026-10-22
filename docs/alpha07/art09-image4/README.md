# ART09 — actual Image4 extraction and ninja staircase pose studies

**Candidate only; creator visual acceptance pending.** Original PR30 Kaze
identity remains authoritative. No live runtime art, world, progression, save or
shared interface was modified. The existing PR78/TR08 demonstration and its
captures remain separate.

## Exact source and alpha finding

Creator-supplied clipboard source is preserved without modification at
`source_art/art09-image4/image4-original.png`, SHA256
`0c9dc1eeab228a683d86cd156d02251400e7ebd7c1b1a46b1e56e8ae2d44bb09`.
It is 1143×2048 RGBA8, but **all 2,340,864 pixels have alpha 255**. The checkerboard
is baked into its RGB, rather than actual transparency.

The deterministic Godot Image pipeline flood-fills only exterior-connected,
near-neutral pixels (RGB range <0.11 and value >0.53), then zeroes their RGBA.
It removes 1,754,659 background pixels and retains 586,205 source pixels with
**zero retained RGB changes**. All 13,345 green-dominant source pixels survive,
including the neon bow/ribbon. Enclosed white details remain; small neutral edge
fringes or enclosed checker pockets still need visual review before production.
This is a reproducible mask candidate, not a claim of artist-perfect cleanup.

Reference recovery: [PR30](https://github.com/cappy2yappy/momentum-fractured/pull/30),
`art/art04-production-pilots`, head
`a6b76b9938825307bdcd4efb687c7198ea0d8681`. Existing purple jacket/skirt,
boots, long dark-purple hair and green ribbon define identity; the supplied
sheet's pixel proportions and facial simplification remain candidate deviations.
No generative edits, limb reconstruction, image rotation, optical-flow morphing
or interpolation was used. Crops retain original keyed source pixels.

## Catalog and selected source ROIs

[Interactive component catalog](catalog.html) lists exact source coordinates,
category and review disposition for each component. The catalog has **170
connected foreground components of at least 100 pixels**, including a portrait;
this does not establish 170 complete, validated poses. Small detached fragments
are not separately counted. Automated categories describe mixed row groups;
only the pilot's six full ROIs were individually selected for sequencing.

| Pilot keys | Source x,y,width,height | Use |
|---|---|---|
| 138 | 322,1566,86,75 | Arms-back sprint pose |
| 139 | 425,1570,98,72 | Arms-back sprint pose |
| 140 | 540,1570,108,73 | Arms-back sprint pose |
| 141 | 922,1571,59,96 | Guard key for braking study |
| 142 | 996,1571,58,93 | Guard key for braking study |
| 143 | 1058,1575,69,91 | Guard key for braking study |

The catalog also retains alternate runs, combat, crouches, kicks, acrobatics and
possible frontflip keys. Apparent flip keys are **not** asserted to form an
ordered frontflip. Component146 is portrait-only. Components161–164 have exposed
tan torso / widened body variations that diverge from PR30's jacket silhouette
and are rejected from this pilot. Unreviewed variants are not runtime-ready.

## What the native pilot demonstrates

The sprint repeats **three actual source keys**, 10fps, as an incomplete cycle
study. Ascent and descent put the same three keys on independent staircase root
paths, at 10fps and 8fps respectively. They do not contain authored tread plants,
landing compression or directional staircase anatomy. The orange dot exposes
the presentation root; flight and foot contact are visibly unvalidated.

Braking slows the presentation root, then switches from sprint into three actual
guard keys (0.12/0.16/0.18/0.28s sequence timing). They are unrelated guard drawings,
not a finished braking animation; the body height and posture change visibly.
These are inspectable **pose and timing candidates**, not finished gameplay gait
replacements. A real production cycle still needs matching contact/passing keys,
stance feet, entry/exit transitions, descent compression, braking in-betweens and
creator identity/visual acceptance.

## Native Mac launch

Godot 4.6.1 at `/Applications/Godot.app`:

```sh
./tools/art09_image4/launch.command
```

Or open `project.godot`, then run `tools/art09_image4/demo.tscn` as current scene.
Keys1–4 choose sprint/ascent/descent/braking. Space pauses/resumes. R restarts.
C opens the catalog; Left/Right cycle modes or catalog pages. The scene is a
neutral, isolated presentation and loads no world/player/save scene.

## Reproduction and verification

From repository root:

```sh
GODOT=/Applications/Godot.app/Contents/MacOS/Godot
"$GODOT" --headless --path . --log-file /tmp/art09-extract.log --script res://tools/art09_image4/extract.gd
"$GODOT" --headless --path . --log-file /tmp/art09-build.log --script res://tools/art09_image4/build_frames.gd
"$GODOT" --headless --path . --log-file /tmp/art09-verify.log --script res://tools/art09_image4/verify.gd
"$GODOT" --headless --path . --log-file /tmp/art09-study.log --script res://tools/art09_image4/test_study.gd
python3 tools/verify_baseline.py
```

`MANIFEST.json` records exact crop rectangles, pivots (bounding-box bottom center,
not artist-authored foot markers), timing and honest per-clip limits. Pixel and
source integrity verification checks every extracted crop against its actual
keyed source region. `hashes.json` inventories exact PNG hashes and sizes.
Native capture uses actual post-draw timestamps and no fixed-FPS/movie mode:

```sh
"$GODOT" --path . --log-file /tmp/art09-capture.log --rendering-method gl_compatibility tools/art09_image4/demo.tscn -- --test --art09-capture
```

Raw frames/timing are generated under ignored `build/art09_image4/capture`.
Creator-facing previews are delivered in the coordination workspace's
`outputs/art09-image4`. Alpha before/after comparisons are extraction comparisons;
this does not establish a finished before/after improvement to live animation.

## Recorded results

- Godot4.6.1 pixel/source integrity: 347 checks, 0 failures.
- Isolated mode switching, pause/resume, restart, root direction and absence of
  gameplay children: 22 checks, 0 failures.
- Existing sprite integration: 43 checks, 0 failures, 0 script errors.
- Existing TR08 transitions including interruptions/restoration: 226 checks,
  0 failures, 0 script errors.
- Preservation verifier: 0 failures; approved original/active art unchanged.
- Final actual native capture: 323 post-draw samples, 19.004 wall-clock seconds,
  AppleM4 compatibility renderer, all four study modes and five catalog pages.

No new production save ownership, controller, progression or transition behavior
was introduced. Save/reload and gamepad certification of new production animation
is not claimed; this is an isolated candidate viewer with keyboard controls.
