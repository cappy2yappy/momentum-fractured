# ANIM-STOP-01 — measured stopping study

Creator-review candidate; not production animation or a silhouette acceptance. Base: Studio PR100 `6ab1454ea44e946265d2a65d1495d81e7aae840f`. Branch reserved: `prototype/anim-stop-01`. Task: `/root/anim_stop_01`. Only the three `anim_stop_01` namespaces are added. Studio, ART10, original artwork, controller and normal user saves are unchanged.

Open [private native review](private-evidence/review.html) locally for the actual 1.0× video, six-pose frame sheet and aligned overlays. Private evidence is intentionally excluded from Git; these are local renders of existing artwork, not generated illustrations. The viewer shows seed, portable keys, and calibrated actor study simultaneously. Its panels display at 0.7 scale and follow root travel horizontally; alpha/transform audit captures use 1:1 source coordinates and a common root. There is no gameplay or production placement.

## Concrete audit result

The perceived leg growth is consistent with a real art/transform mismatch, not merely a bad crossfade:

| Measurement | Actual result |
|---|---|
| Active run sheet | 2176×724; eight 272×724 cells; Studio Sprite scale 0.85, offset `(0,-238)` |
| Run visible height, alpha >128 | 244–259 source pixels, 207.4–220.15 displayed pixels |
| Misleading zero-alpha bound | Frame 0 spans 635 pixels from low-opacity fringe, versus 254 at alpha >128; do not calibrate using any-nonzero bbox |
| Native aligned 1.417s | Run 207px high; seed rig 318px high, approximately 54% larger overall visible extent |
| Native aligned 1.583s | Run 220px high; seed rig 323px high, approximately 47% larger visible extent |
| Native aligned feet | Run alpha bottom y327 at root y420; seed rig bottom y402 at 1.583s and y410 at settle |
| Rig segment construction | Both thighs/shins reuse the same tube; knee and ankle offsets are 65+65 source px. Thigh target raster width 28, shin width 24; boot raster unscaled 70×63 with opaque extent 53×50 |
| Actual support pixels | Heel `(13,51)` and forefoot `(40,50)` in the boot image, both alpha >0.5. Forefoot is one source pixel above heel, not a flat fabricated sole |
| Near/far overlap | Identical tube/boot textures, not independently painted perspective views; crossing overlaps and seams remain visible |

[Pixel audit](pixel_audit.json) records all thresholds, eight frames, part hashes and exact offsets. [Transform audit](transform_audit.json) records seven times per view, alpha bounds, hip/knee/heel/forefoot positions, and common-root alignment. These silhouette extents are **not anatomical leg-length measurements**: pose, hair, costume and perspective differ. The actual artwork and native overlays were inspected. Scale 0.68 improves gross visible size in this study; it is not approved anatomy or proof of a seamless handoff. At 1.583s the calibrated rig is 212px high, but its silhouette is narrower and its legs/arms still do not match the running drawing.

## Two deliberately different deliverables

1. [portable_stop.tres](../../tools/anim_stop_01/portable_stop.tres) uses the unmodified Actor and only Studio-approved position/rotation/property tracks. It improves planted contact and weight shift. It **retains the original oversized rig art** and does not fix the handoff silhouette.
2. [calibrated_stop.tres](../../tools/anim_stop_01/calibrated_stop.tres) uses the same track contract but expects `Rig.scale = Vector2(0.68,0.68)` set explicitly on an isolated Actor instance by [review.gd](../../tools/anim_stop_01/review.gd). No existing scene/resource is modified. It must not be imported into ordinary Studio as a claimed self-contained fix: current Studio validates no scale tracks and does not persist this actor calibration. Future adoption requires the Studio owner's separate actor/asset decision.

Both clips are reproducibly generated at 60 keys/second with an analytic two-segment joint solve. Root motion, all approved running sprite exposures and the existing 1.42–1.58 alpha handoff are retained exactly. No new art or meshes are created. The build never runs Studio's seed rebuild and never overwrites authored clips.

Motion phases: existing sprint through 1.42 → passing/reach through 1.58 → near heel contact at 1.80 → compression at 2.05 → root recovery/stop at 2.55 → far heel down at 2.85 → settled hold by 3.40–4.20. The near heel remains at source-world `(788,517.35)` after contact. Torso/head counterrotation and hair/ribbon lags are motion proposals. The source torso remains inclined and the clothing/hair are rigid pieces; a keyed zero rotation is **not** a completed upright drawing.

**Natural settled-idle and anatomy acceptance: NOT MET.** The actual 4.2s capture still leans/hunches, holds flexed knees and shows cutout seams. Foot-support success does not satisfy that visual requirement. The next original drawing needs a long upright spine and stacked head/ribcage/pelvis over a balanced two-foot stance, distinct relaxed knee contours, correct ankle bends and the approved boot silhouette; do not rotate the current bent torso until the pose merely fits a numeric box.

The M key supplies a mirrored geometry inspection only. The source is right-facing art; no independently authored or accepted left-facing stop is claimed.

## Executed validation

- Official Godot 4.6.1 Windows: **28 checks headless, 28 checks native OpenGL**, zero failures. See [headless log](headless.log.txt), [native log](native.log.txt), [results](contract_result.json).
- The unchanged Studio validator accepts both native resources; private disposable-profile save/disk reload passes. Same native resource is reused at 2.05s and 6.25s in Studio's unchanged two-shot Director; reduced mode holds the final pose. Calibration is set only in the test instance for the calibrated case.
- Planted-support sweeps sample 1.8–4.2s at 240 Hz, including between baked keys. Portable max x/y error: 0.003235/0.009192 px. Calibrated: 0.009644/0.022314 px. Boots remain level; far heel lands within 0.00022px by recovery. These are transform/support tests, not creator balance/anatomy approval.
- **129 actual native draw samples over 4.506864s**, Engine.time_scale 1.0, max timeline/clock discrepancy 0.000823s. Video uses recorded wall-clock intervals; no movie mode or fixed-FPS acceleration. [Capture summary](capture_summary.json), [capture log](capture.log.txt). Capture overhead and ~30Hz recording are not a 60fps game performance certification.
- 28 native transparent phase captures plus two actual aligned overlays. No external services or art transfers.
- [Approved baseline verifier](baseline.log.txt): zero failures. [Preservation](preservation_result.json): all 14 protected initial-clone byte hashes unchanged; approved character PNGs also exactly match pinned Git blobs; no tracked changes outside reserved namespaces.

The source-file Image load in the test emits an export warning; the test is a source/editor audit, not an export test. Initial editor import also emitted safe-save/cleanup diagnostics; subsequent generator, contract and native capture runs completed. No warning-free import, packaged export, macOS, hardware controller, campaign or full current-Studio certification is claimed. QA101 remains about old Studio `d227b038`, not this head.

## Artist-ready requirements

Use the existing approved eight-frame run sheet as identity/proportion authority. Suggested interchange: layered PSD or separate transparent PNGs authored in Clip Studio Paint; preserve 272×724 reference canvas and a registered copy of the existing run exposure. A proposed drawing-space sole line is y490 with x136 center; the existing Studio root convention is below the foot and needs an explicit owner-reviewed mapping. Do not silently change live sprite offsets.

Required six original pose drawings: final sprint extension, passing leg, braking heel/forefoot contact, knee/hip compression, opposite-foot recovery, and upright settled idle. Provide matching transition exposure(s) between final sprint and first brake. Match head size, boot length/thickness, thigh/shin silhouette and skirt overlap to the **actual approved drawings**, rather than shrinking this tube rig until a bounding box matches. Frame count/in-betweens follow reviewed timing, not the six-key minimum.

Suggested layer order: far hair/ribbon; far sleeve/arm/hand; far thigh/shin/boot; rear skirt/hidden pelvis; torso; near thigh/shin/boot; front skirt; near sleeve/arm/hand; head; front hair strands. Existing rig draws both arms late relative to torso and duplicates near/far parts; dedicated occluded surfaces and a reviewed compositing order are needed. Separate rooted hair mass from trailing shapes and provide sleeve/elbow/knee contours through compression. Supply heel and forefoot landmark coordinates per exposure, not one generic ankle dot. Preserve alpha without near-transparent background speckle.

Missing: distinct near/far boots and knee bends, upright torso/head alignment, hidden shoulder/pelvis/under-skirt surfaces, matching sprint/stop bridge pose, natural cloth deformation and secondary hair drawings. This task has **not painted** those missing surfaces, created a layered PSD, filled ART10 staircase slots, or overwritten the creator's Studio saves.

## Reproduction and next decisions

Use a fresh disposable APPDATA path before every engine invocation. From this checkout:

```powershell
$env:APPDATA = Join-Path (Get-Location) 'docs/anim_stop_01/private-profile'
& '<Godot 4.6.1 console>' --headless --path . --script tools/anim_stop_01/generate.gd
& '<Godot 4.6.1 console>' --headless --path . --script tests/anim_stop_01/contract.gd
& '<Godot 4.6.1 console>' --path . --rendering-method gl_compatibility --script tests/anim_stop_01/measure.gd
& '<Godot 4.6.1 console>' --path . --rendering-method gl_compatibility tools/anim_stop_01/review.tscn -- --stop-capture
python tools/anim_stop_01/package_evidence.py
python tools/anim_stop_01/verify_preservation.py
```

Python pixel audit needs Pillow/NumPy; packaging needs FFmpeg. Do not run `tools/cin_tools_03/build.gd` over creator files.

Creator review: select acceptable size/proportion references and contact/settle direction, then commission matching original drawings; no full animation acceptance requested for this cutout study. Studio owner: decide whether a separate calibrated Actor resource belongs in a later review, without changing the saved-clip schema prematurely. Coordinator: preserve this bounded candidate and the exact current-Studio/QA101 distinction. No merge, release, production integration or external art transfer is authorized by this handoff.
