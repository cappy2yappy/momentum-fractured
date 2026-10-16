# REF-01 — External gameplay references: spatial readability and animation production

**Date:** 2026-10-15  
**Owner:** Kaze Project Management  
**Status:** Inspiration / review reference, **not** approved source assets or a direction to copy gameplay  
**Related:** creator's Alpha 0.6.1 Canal Route geometry feedback; INT-TR03 / ART-04 [PR #31](https://github.com/cappy2yappy/momentum-fractured/pull/31); forthcoming TR-04 / LD-02 containment and ART-05 dressing work.

## Sources and provenance

1. Public Reddit post: [Anime Style Metroidvania — Day 10 (Codex Only)](https://www.reddit.com/r/aigamedev/comments/1wgoirv/anime_style_metroidvania_day_10_codex_only/). Source is a third-party developer's self-report and shared visual reference, not verified evidence of their specific implementation or performance.
2. Creator-provided **23.47-second 1920 × 1080 / 30 FPS VP9 clip**, supplied privately as `example.mp4` in the PM chat on October 15. Visual inspection used sampled frames through the clip. **Do not upload or redistribute this third-party video or extracted stills in the public Kaze repository without rights approval.** The clip depicts a dense side-scrolling nighttime city street with storefronts and a later interior room/lab. It may be a *different* project from the Reddit demo; do not infer shared authorship.

## Direct observations from attached clip

- The character travels laterally through **contiguous street ground** and visually anchored storefront architecture. Sidewalk and building faces form a consistent plane at player height. This is an observation of presentation, **not proof** of actual collider continuity or input mechanics.
- Background buildings, signs, neon, windows, street objects and distant skyline create depth while leaving the character's traversable ground legible.
- Foreground and props have a clear relationship to a recognizable physical city. Locations differ visually without requiring floating test rectangles as the main landscape.
- Roughly the final portion moves from an exterior commercial street to indoor scenes. The clip suggests a useful *scene identity* shift but does not prove seamless streaming, collision implementation, door trigger reliability or specific animation frame counts.
- The view favors readable gameplay scale and consistent side-view composition. Do not blindly adopt its HUD density or color palette for Kaze's ruin/shrine/canal biomes.

## What the Reddit developer explicitly describes

In the linked discussion, the author says their project focused on movement, animations and fights, built an internal visual animation testbed, compared multiple sprite resolutions, inserted in-between frames, codified a reusable animation production guide, and repeatedly reviewed visible defects and improved them. **These are the author's claims, not independently audited evidence.**

### Useful workflow adaptation for Kaze

- **Art Mane:** preview *all* current and proposed Kaze clips side by side at **actual 1280 × 720, zoom 1.0** plus enlarged frame inspection. Compare to approved art to catch identity and proportions drift. Work from the actual fixed frame/pivot/import contract rather than copying the Reddit author's sprite dimensions.
- **Level Masta Masta:** validate the playable *collision floor and return path* under environment art. A visually continuous ledge without matching CollisionShape2D/shape data still fails.
- **Gameplay Masta:** preserve the creator-approved movement and combat feel; review hit-spark readability independently of animation motion if and when assigned.
- **PM / QA:** each art review should identify the three largest concrete defects, repair, replay/capture and repeat until the agreed acceptance criteria pass. Avoid performative iteration counts in place of measurable quality.

## Kaze implications, prioritized

| Priority | Applicable inspiration | Required original Kaze implementation / test |
|---|---|---|
| P0 | Physical-looking continuous traversal lane | **Canal Route left exit**: collision shelf, threshold and exit reachability must remain safe after stopping for pickup; walk, sprint, reverse, return, idle/pause, jump and dash approaches. No accidental drop into unintended negative space. |
| P0 | Architecture communicates solid versus non-solid | Review room silhouettes and collision arrays together. Ground/wall/passage boundaries must correspond at gameplay zoom. Preserve intentional downward routes and any narrative exploration rather than plugging every vertical gap. |
| P1 | Detailed environmental treatment grows from location | Art Mane produces modular caps, masonry/wood/ruin supports, wall endings and occlusion layers that precisely match **Level's corrected geometry**. Avoid standalone decorative art that hides a broken platform. |
| P1 | Side-scroller visual clarity | Compare Kaze's approved ART-04 environment texture silhouettes against solid floor, pickups, actor and interaction indicators. Distinguish rear, actor, and front occluder layers without covering critical UI. |
| P1 | Animation reviewed as motion, not still poses | Turn/enter/stairs/walk source keys must be assembled into readable sequences and inspected at real play speed with actual feet/pivot, no fake shrinking or relabeled held keys. |
| P2 | Dense atmosphere and room identity | Incorporate ruins/canal/shrine biomes and story beats where authorized. Do not duplicate this reference's nighttime cyberpunk environment, assets, signs, UI or character design. |

## Explicit safety and scope notes

- Inspiration is **directional**. No third-party sprite sheets, layouts, sound, effects or art should be copied/redistributed.
- Video alone does not tell us the other game's engine, source code, physics, collisions, FPS, or authorship.
- No approved Kaze movement, floatiness, save, progression, gate, map topology or 0.65-second transition policy should be changed without a measured defect/creator approval.
- Correct **geometry and transitions first**, then modular art dressing, then animation finish and gameplay-scale QA. Native Mac/Windows tests and fresh-save game playthrough remain separate acceptance gates.
- The creator's referenced screenshot of Canal Route remains the authoritative *bug example* for TR-04, not the external example itself.

## Next review action

Ask Level Masta Masta to demonstrate a before/after replay of the Canal Route left exit where Kaze stops at the nearby pickup and re-approaches safely, and have a Godot reviewer inspect both **solid collision coverage** and **visual ground continuity**. Art Mane should then dress the finalized surfaces. This reference is a benchmark for clarity and finish, not a new feature request.
