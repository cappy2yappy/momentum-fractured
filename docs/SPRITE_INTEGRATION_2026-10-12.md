# Cleaned Kaze sprite integration

Authorized by the creator on October 12, 2026. Development branch: `codex/kaze-boundary-sprite-integration`, based on the approved 13-room Alpha 0.5.2 source.

Runtime idle/run use the supplied Final Cleanup strips (2176 x 724, eight 272 x 724 cells). Combat/traversal use the supplied Boundary QA strips (2560 x 724, eight 320 x 724 cells). PNG bytes are copied unchanged into `assets/kaze/cleaned`. Original `assets/web/kaze_*.png` files remain unchanged and recoverable; source package manifests are retained alongside the new assets.

The controller edits only texture bindings and sprite scale, offset and position inside `animate`. Idle visible height is approximately 80 world pixels; run/combat/traversal use scale 0.24. Fixed ground baselines are idle 591, run 491, combat 498 and traversal 510 source pixels. Frames retain their authored registration, including airborne poses; no per-frame bounding-box recentering occurs. Dash afterimages copy the sprite offset. The kit portrait crops transparent top/bottom margins while retaining image bytes.

Frame ordering, idle/run cadence, state-to-pose selection and combo-driven attack playback remain unchanged. Source package suggested FPS values are advisory and do not replace gameplay timing. Capsule, physics process, movement, damage, tether and room geometry retain the approved implementation. The controller checksum changes because rendering lives in that script; verification separately locks the original physics function and original art hashes.

Validation: Godot 4.6.1 imports the project; seven gameplay suites passed with 135 assertions and zero failures before the portrait-only adjustment. The additional sprite integration suite passed 39 assertions after the portrait adjustment, covering all 32 nonempty cells, dimensions, dash pose, mirror and pivot. Rendered SkyWorks and kit captures confirm textures display at gameplay scale and the portrait is fully visible. A complete interactive animation/playthrough review remains pending. Known environment diagnostics include certificate-store access and portable-editor settings writes, plus import cleanup warnings.

The wider canvas reduces cell-edge contact; the handoff explicitly says it cannot restore artwork already clipped in the source. This integration does not claim those missing details were repaired. Fixed pivots reduce floor drift, but authored pose/proportion differences still warrant live review.

## Playtest size correction

The creator reported the cleaned character appeared too small. Measured original and cleaned alpha silhouettes at threshold 0.1 across all eight frames per clip. Restored average prior visible height using a fixed scale per animation: idle 0.264990881, run 0.382578054, attack 0.378751572 and traversal 0.339192793. Fixed ground pivots remain unchanged; no per-frame scaling or gameplay changes. The earlier 80-pixel idle / 0.24 scale describes the superseded first review build. Sprite integration and approved baseline checks passed after this correction.
