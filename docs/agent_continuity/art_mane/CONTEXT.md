# The Art Mane — ART-04 production checkpoint

State: handed-off for creator key/asset review and Level integration. Branch `art/art04-production-pilots`, draft [PR #30](https://github.com/cappy2yappy/momentum-fractured/pull/30), based on ART-03 #28 fc998f9. Published art checkpoint `9f4e7151b1f8aa683123ee59aa549c3d8c2b4bb7`; final publication pointers/logs/continuity follow in a docs-only checkpoint. Fetch current PR HEAD before continuing.

Creator approved ART-03 direction and an attempt to use it in the next playable comparison. Actual new ART-04 assets still await review; no merge authorized. Read docs/art/art04/README.md, LEVEL_HANDOFF.md and docs/agent_handoffs/ART04_PM_REPORT.md.

Delivered: four true transparent Kaze keys (quarter-back turn, rear inward step, right-up contact, left-down landing), eight environment textures (door layers, stair/lip, timber roof and masonry arch), packed atlas, SpriteFrames and collision-free prefabs. Nine generated RGBA masters plus two identity-reference crops, eight editable ORAs, provenance, fixed transforms, import settings, manifests and eight native Godot captures. No original sheets or approved paintings altered.

QA:13 RGBA textures full decode/CRC/hash/zero hidden RGB; four320×724 keys and12px margins; eight ORA ZIP/merged-image checks. Native Mac Apple M4/OpenGL Godot4.6.1,1280×720 zoom1, four-key resource and two prefabs load. Colliders R14 23→23, R15 15→15. Baseline verifier0failures. Final native log has no script/resource errors. Initial import/profile and first-render texture-lifetime problems are documented and corrected.

Limits: four held keys, not full cycles; no walk, outward/front-quarter or opposite-facing acceptance. Existing procedural roof/arch drawing still overdraws some dressing; Level resolves scoped order. No playable ART04 integration, R17 arrival, live transition cleanup/timing, Windows or sustained60FPS certification. Preserve0.65s/39 ticks and current run registration.

Coordination payload published on [Level PR #27](https://github.com/cappy2yappy/momentum-fractured/pull/27#issuecomment-6201972556) at pinned art SHA. No live acknowledgment/integration claimed. Next: creator asset review; Level consumes only reviewed assets/art04 paths, then actual runtime QA/Build Shogun delivery. Continue existing30-frame production plan after key feedback. No merge.
