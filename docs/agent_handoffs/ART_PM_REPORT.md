# ART_PM_REPORT: Canal-left architecture and staged-passage material (ORDER 3)

Branch `art/pm-pilot-passage-cinematic`. Base (PR51 head): `baedd6786ad4bee2123ea872b437bbb98e6d2721`. Head: a commit cannot name its own SHA; read it from `gh api repos/cappy2yappy/momentum-fractured/commits/art/pm-pilot-passage-cinematic` (also given in the final reply). Draft PR against `fix/tr06-automatic-passage`. Creator visual acceptance is explicitly reserved and pending.
Model: Claude Sonnet 5.5 (claude-sonnet-5-5). Environment: Linux sandbox, Python 3 with Pillow 12.3.0 and numpy, Godot 4.6.1 stable (headless and xvfb with Mesa llvmpipe OpenGL). No Aseprite, Inkscape or tablet. ImageMagick and ffmpeg exist but were not needed.

## Delivered

Labels used: authored drawing / held pose / deformation / procedural architecture / unfinished.

| Item | Path | Label |
|---|---|---|
| Canal layers L0 to L4 (8 PNG + `.import`) | `assets/pm_pilot/canal/` | procedural architecture |
| Wipe panels a, b, c and badge plate | `assets/pm_pilot/wipe/` | procedural architecture (original wind-cloth direction) |
| Manifest (SHA256, size, anchors, z-order, labels, import notes) | `assets/pm_pilot/MANIFEST.json` | |
| Held ART-04 keys and approved run/idle strips, referenced in place, not copied | listed under `referenced_not_copied` in the manifest | held pose / authored drawing |
| Editable sources: 2x masters, layered OpenRaster `canal_layers.ora`, layer rects | `source_art/pm_pilot/` | |
| Generators: `common.py`, `build_canal.py`, `build_wipe.py`, `build_previews.py`, `build_manifest.py`, `scene.py`, `canal_contract_v1.json`, `godot_check.gd`, `godot_capture.gd` | `tools/pm_pilot_art/` | |
| Previews: true-size exit still (1x and 3x), before/after compare strip, layer sheet, held-poses sheet, three sequence stills, staging GIF (58 frames, 20 fps, 768x432), Godot capture | `docs/pm_pilot/art/previews/` | staging preview |
| Missing-pose request (69 frames over 3 groups) | `docs/pm_pilot/art/MISSING_ANIMATION.md` | |
| Engineering integration note (mirrored to `/home/claude/pilot_shared/ART_INTEGRATION.md`) | `docs/pm_pilot/art/ART_INTEGRATION.md` | |

The architecture is fitted to CANAL_CONTRACT v1: aperture (72,1068,96,132), frame (40,1032,160,168), hall back wall (72,1020,224,180), gatehouse face (0,0,296,1020), lintel course (72,960,224,60), back pier (0,1020,72,180), mouth corbel (284,1004,40,40). Palette matches the repo's night-canal masonry and the warm d9c9ad / f4db96 cue colours; warm lamp at the R0 end (seen through the aperture), cooler light on the mouth side, per STORY guidance (a PROPOSAL, not canon). No continuous ramp, no refuge or crest wording, no ceiling beyond the contract mass.

## Honesty statement

- No new Kaze drawing was made. The preview uses only the approved cleaned run and idle strips, registered exactly as `scripts/player.gd` does, plus two deformations: horizontal flip (as the game does) and a dark tint while she is inside the aperture. That is composition, not an entry or exit animation.
- The four ART-04 keys are registered as held poses and are not used in the Canal preview (wrong direction for a leftward side exit). PR41 `turn_depth`, `enter_depth` and `stair_up` were inspected, not imported. PR47 R18 art was style reference only, nothing copied. PR53 (ART-07) was not touched.
- Higgsfield was not called. No credits spent, no moderation interaction.
- The missing authored poses are specified in `MISSING_ANIMATION.md`: A 19, B 18, C 32, total 69 frames at 320x724, pivot (160,600), scale 0.303125.
- The one doorway/stair scope: the Canal doorway has staged material; the R14 to R17 stair has no architecture or poses in this pilot (it needs the 32 frames in group C and was out of the contract numbers received).
- The layers are procedural (seeded noise masonry plus ink edges). They are cleaner and flatter than the painted ART-04 door and the ART-06 generated masters. Expect the creator to ask for a paint-over; the 2x masters and ORA make that possible. The interior of the doorway is a simple gradient passage, not a drawn scene.

## Tests and checks actually executed

| Check | Result |
|---|---|
| `godot --headless --path . --import` | completed; `.import` files kept only for `assets/pm_pilot/**`, stray regenerated ones elsewhere deleted |
| `godot --headless --script res://tools/pm_pilot_art/godot_check.gd` | 12 of 12 manifest assets load at manifest size, 0 failures |
| Draw-order capture, Godot 4.6.1 gl_compatibility, xvfb, llvmpipe | `canal_exit_godot_capture.png` rendered: layers, pad stand-in, Kaze idle frame facing left, corbel in front. Purpose-built canvas, not the game scene |
| Contract dimension assertions in `build_canal.py` | every layer equals its contract rect size |
| Em dash scan of added text and JSON | none |

Not run: the game scene with real `draw_exit`, any gameplay or QA suite (no runtime script was changed), exports, human playtest. No pixel-compare against LEVEL's `canal_gatehouse.gd` stand-in because LEVEL's branch was not read.

## Limitations and blockers

- The sequence preview is a Pillow composition at 20 fps. The engine's 0.65 s load clock is shorter than the 2.7 s staged timeline; engineering must hold or proxy it (contract section 7).
- Door leaf covers part of the opening by design; engineering can skip it.
- Locked-state art is not shipped; use a tint.
- Wipe panels are 1822x488 each, five rows needed for 720 px; memory is about 3.5 MB each uncompressed.
- Contract v1 numbers only. If LEVEL changes them, edit `canal_contract_v1.json` and rerun the five generators.

## Next action

Creator review of the layers and sequence; decide on paint-over versus procedural; commission or supply the missing poses; engineering binds per `ART_INTEGRATION.md`.
