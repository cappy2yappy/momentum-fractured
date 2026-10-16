# Godot 4.6 collision review

2026-10-16. An independent Godot-focused review agent inspected the actual PR31 source, the proposed repair, and then `level_geometry.gd` plus its `add_platform` call site. This was a read-only source review, not an external certification or a human gameplay acceptance.

Review disposition: approve bounded perimeter extensions and the exact Terrace implicit-arrival correction, subject to runtime checks. Those checks subsequently passed in the 78-assertion geometry suite.

- Player capsule: radius14, height60, layer2/mask1. Static platform bodies remain on layer1.
- Extend the existing rectangle rather than add adjacent strips: no new collision seam.
- Preserve top, thickness and original one-way behavior. Expansion40px ledges retain margin8; original solid ledges remain solid. Floors/walls/pits are untouched.
- Keep the allowlist restricted to near-boundary exit shelves; do not fill interior vertical routes or water gaps.
- Keep R15/R16 directional crossing, speed threshold, rearm/cooldown and vertical corridor unchanged. Existing109-check mixed-transition suite passes.
- Cistern/Span/Terrace seals still precede the extension. Gate/reward/save regression suites pass; no new progression bypass is authorized.
- Terrace return: default feet2300,828 overlap shelf810-850. Use2300,808 only for that exact implicit arrival. New query verifies no capsule/solid overlap after swap, then grounded settlement. Explicit/save coordinates are untouched.
- ART04 stair: preserve source crop, shared0.8 vertical scale, anchor1680,1300 and identical lip registration. A recessed wall return may close its silhouette; do not shift or stretch the remaining stair artwork.

References consulted by the reviewer: [Godot 4.6 CollisionShape2D](https://docs.godotengine.org/en/4.6/classes/class_collisionshape2d.html), [Godot 4.6 CharacterBody2D](https://docs.godotengine.org/en/4.6/classes/class_characterbody2d.html). One-way margin is collision tolerance, not a substitute for missing horizontal support.

Remaining review: creator feel/visual acceptance, human route sweep, authored art and sustained rendering performance. Native scripted input tests do not replace these.
