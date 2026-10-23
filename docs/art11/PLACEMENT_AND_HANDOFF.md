# Geometry, presentation seams and owner handoff

## Exact placement contract

The two world pilots instantiate the existing main scene at the PR94 pin, then select **R16 Root Shrine** or **R15 Lower Sluice**. They read `host.platforms` after the normal room builder finishes. No room definition, collider, gate, exit, save or controller file changes.

Surface art stays inside each runtime Rect2. It tiles at native prepared size with clipped final pieces; a continuous rim marks the exact collider top. A 216 × 56 reserved region at each doorway keeps its original threshold and underfoot status plaque visible; surface art is clipped around it, so LOCKED/approach labels cannot be painted over. The floor retains its real rectangular body. It creates no false bridge across gaps. All platform rectangles and selected foliage/background anchors are recorded in the per-room JSON results in `evidence/`.

Decorative exclusion zones are evaluated for both moving foliage and recessed architecture:
- 200px around existing portal endpoints.
- 100px around actual `kaze_grapple_anchor` attachment nodes (and legacy anchor coordinates).
- Existing expansion hazard rectangles enlarged by 48px.
- Existing gate bodies with 64px lateral and 48px vertical clearance.
- Lore-marker approach rectangles and enemy combat lanes.
- R16's actual checkpoint interaction/marker at (420,1120), using (300,940,240,200) as the protected rectangle.

The orange debug rectangles are these review exclusions; cyan outlines are the actual surfaces. They are overlays only. The hazardous bay in R15 remains visible; a proposed background rock intersecting that bay is rejected. The R16 checkpoint stays clear of the nearby blue flower proposal. Original architecture, including the existing R15 arch and legacy silhouettes, is retained.

The art child is ordered before the player and actors. Recessed forms draw before surface faces; the source world is unchanged. In interactive use the overlay is removed when leaving the nominated room and regenerated from live geometry on re-entry.

## Existing behavior ownership

HAZ-01 uses the pinned PR87 course and only attaches a non-physics Node2D to its steam hazard. The body fits inside the existing sensor and renders behind the original outline, hatching, label and progress strip. It listens to `phase_changed`/`enabled_changed`; elapsed time, timing thresholds, collision, damage, reset and snapshots remain owned by HAZ-01. Reduced motion freezes the decorative loop without suppressing warning/active/recovery changes. The existing collapse demonstration remains part of the host lab; this work does not adopt it for production.

EN-01 uses the pinned guard lab. The slime presentation reads the real enemy state. It temporarily hides the original guard sprite only in that isolated runtime; F4 restores it, and teardown restores visibility. Existing name, health, warning ring and strike line remain. F7 shows the core hit-radius at the existing projectile-query center; the separate projectile margin and directional melee checks remain unchanged. This guide is not a new body/hurtbox. The shallow slime body does not yet fully communicate the existing guard target reach: creator/Gameplay approval and dedicated action poses remain necessary.

## Decisions to review

**Creator / Art Mane:** accept or reject individual selections, the material repetition, the cyan-flower accent, muted tints and background depth. Review the linear/nearest gallery and native detail views at Kaze's actual display scale. Consider seamless cap/body variants before production. Supply dedicated slime anticipation/attack/hurt/death work before accepting a combat skin.

**Level Masta:** review R16 and R15 exact runtime anchors and exclusions. No pending redesign is incorporated. These anchors become stale when those rooms are redesigned; rerun the source contract and survey rather than transplanting them silently. R13, R17, R18 and Canal Doorway remain unchanged.

**Gameplay:** retain EN-01/HAZ-01 ownership of state and timing. The completed checks establish visual attachment, real state observation, pause and hazard snapshot/reset behavior, not a full combat/traversal playthrough or campaign integration approval.

**Integration owner:** use the separate review captures and QA results. Production acceptance must name the source IDs/derivatives, room/anchors, visual treatment and applicable author/creator rights evidence. No candidate is auto-approved. No raw-pack or derivative-texture publication is part of this PR.
