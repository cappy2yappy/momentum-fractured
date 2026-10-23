# ART-11 validation and performance

2026-10-23, official Godot 4.6.1 Windows, OpenGL 3.3, NVIDIA GeForce RTX 4070 Laptop GPU (driver 591.44). Native world/lab viewport 1280 × 720; gallery 1440 × 900.

## Verified

- Six archive hashes and 1,106 extracted-file hashes reproduce the ASSET-01 inventory.
- 580 focused assertions, zero failures: every frame decodes, fixed dimensions, transparent alpha/gutters, real animation content, bounded silhouettes, pause, reduced motion, hazard phase signals, snapshot/reset, re-enable warning and signal teardown.
- 185 cached textures, 3795784 decoded RGBA bytes (3.62 MiB), below the 16 MiB mixed-selection cap. No ongoing texture decoding/upload during normal playback. This is selected CPU/GPU texture payload, not total process or VRAM usage.
- All selected loops have zero-pixel alpha-base variation. First/last-frame premultiplied color/alpha comparison error is 0.26–0.83% for animated selections at 32 × 32 sampling; this is a seam indicator, not a complete motion-quality metric. All source frames retained.
- Four native art pilots and four art-off comparison runs pass. Collision shape identities, transforms, dimensions, layers/masks and disabled states match on attachment and immediate same-phase removal.
- R16 protects three doors, two actual grapple anchors and the checkpoint. R15 protects two doors, two actual anchors, its gate and existing hazardous bay. Every accepted foliage/architecture rectangle clears all exclusions; surface art also clears reserved doorway status plaques. Exact surfaces/anchors are in the JSON evidence.
- Real HAZ-01 idle/warning/active/recovery and EN-01 awakening/patrol/windup/strike/recover were observed; no synthesized combat/hazard phases were used for these captures.
- Existing HAZ-01 contract suite: zero failures. Existing toolkit suite: 56 checks, zero failures. Approved artwork/baseline verifier: zero failures.
- Production files are unchanged; the draft adds files only under tools/art11 and docs/art11. No asset images, archives, editable projects, screenshot pixels, binaries, or caches are in the Git change.

## Native mixed-load measurements

| Pilot | Baseline p95 ms | Art p95 ms | Baseline draw calls p95 | Art draw calls p95 |
| --- | ---: | ---: | ---: | ---: |
| moss | 7.811 | 7.949 | 64 | 114 |
| cave | 7.677 | 7.848 | 66 | 104 |
| hazard | 8.040 | 7.547 | 24 | 25 |
| enemy | 7.885 | 8.104 | 12 | 12 |

Each run lasts 12 seconds. Wall-clock inter-frame samples use Time.get_ticks_usec after seven seconds of warmup/capture; around 700 samples per run. Measurements are display-paced near 144 Hz and are a local budget check, not isolated GPU profiling. Art-on and art-off each load the same texture bank, so the comparison measures drawing/animation overhead rather than startup allocation. Differences smaller than a millisecond are not a demonstrated speedup/regression. All measured p95 values are below 16.67 ms on this machine. Screenshot encoding is outside the measurement window.

## Native review and limits

Inspected the candidate gallery (linear and nearest), R16/R15 art-on/off/detail/collision views, poison-plant warning/active states, and slime windup/strike views. Corrected initial oversized bodies, checkpoint-flower overlap, a proposed rock overlapping the old hazard bay, diagnostic-header overlap, conflicting review keys, and surface art obscuring exit status plaques before final capture. Linear filtering is the default; nearest remains a comparison option.

Room checks freeze movement for repeatable framing. Native enemy/hazard checks run their real behavior clocks, with the enemy test player held in approach range and invulnerable for the recording. This is not physical-controller QA, a campaign save/reload test, a full traversal/combat playthrough, or a full-world/low-end/Mac performance approval. Existing HAZ-01 save/load tests cover its isolated course. R18 production art, R13/R17 geometry, Canal Doorway and creator pending redesigns are untouched.

Slime attack/hurt/death poses are still missing; the existing guard warning ring and strike line remain essential. The poison plant uses the existing steam behavior and does not add poison mechanics. Moss tiling/seams and final art direction need creator/Art Mane acceptance. DarkCave independent publisher terms and release packaging remain as recorded in the licensing inventory.

Initial headless editor imports reported engine/plugin shutdown resource warnings; final native pilots and focused validation emitted no script or runtime errors.
