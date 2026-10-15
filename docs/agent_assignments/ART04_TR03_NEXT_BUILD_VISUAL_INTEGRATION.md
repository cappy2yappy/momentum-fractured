# ART-04 / INT-TR03 — Creator-approved ART-03 visual direction, next-build production pilot

**Date:** 2026-10-15  
**Status:** Approved *conceptual visual direction*; production art and integration pending  
**Milestone:** Next Alpha 0.6.1 comparison build, conditional on QA and creator review  
**PM owner:** Kaze PM  
**Owners:** The Art Mane (production key poses and environment dressing); Level Masta Masta (runtime integration, world pilot); Build Shogun (macOS/Windows comparison delivery and verification)  
**No merge authorization.**

## Creator decision

Creator's response to the three full-scene ART-03 recovered paintings was **"love it to be honest. We should try to implement in the next build."**

This approves **the look and direction of the paintings for targeted implementation**: Kaze identity, architectural support, doorway depth, staircase contact and atmosphere. This does **not** mean that full-size flattened paintings constitute game-ready assets or that every room should be replaced. The next build should **try** a tightly scoped, reviewable in-game implementation, with safe fallback if asset production or technical QA is not ready.

## Authoritative sources

- ART-03 draft [PR #28](https://github.com/cappy2yappy/momentum-fractured/pull/28), published HEAD `fc998f9b22f3e778cc51ee2c81668ad73ac7902e`.
- [ART-03 creator gallery and recovery report](https://github.com/cappy2yappy/momentum-fractured/blob/fc998f9b22f3e778cc51ee2c81668ad73ac7902e/docs/art/tr03/art03_recovery/README.md); sources `01_doorway.png`, `02_staircase.png`, `03_supported_crossing.png` (each 1672 × 941, flattened, *not* layered).
- Level implementation draft [PR #27](https://github.com/cappy2yappy/momentum-fractured/pull/27), published HEAD `c2c002267c58e991966c0eebf7e098c6e7fff769`, which owns scoped R14↔R13 optional depth, R14↔R17 stairs, R15↔R16 walk/run, and R14/R15 visual support pilots.
- Existing specification PR #25 and recovery review kit PR #24. Respect canonical Kaze source identity and proposed new 320 × 724, pivot (160,600), 12px alpha margin frame contract. Existing sprites keep their current pivots/scales.
- Current playable TR-02 reference remains available at PR #16.

## Delivery order / critical path

### A. The Art Mane, first: game-ready conversion of the approved look

1. Extract **design language and actionable environment details** from the three paintings: materials, lighting, wall/ground/door support continuity, depth ordering, scale relationships, and palette. The paintings are reference art; do not use a 1672×941 painting as a room-wide replacement without scene geometry alignment.
2. For R14/R15 visual-only pilots, author **separated 2D game layers/pieces** (behind platform, front occluder, door jamb/threshold, staircase run/landing, arch/piers/roof braces) with transparency, source working files if possible, import settings and scene-to-world anchor annotations. Avoid inventing paths and collision.
3. Produce a minimal set of **actual Kaze identity-matched transparent sprite key poses** for depth-turn entry and stair up/down, including a distinction between ascending and descending mechanics. Integrate existing run frame identity as a guide. Prioritize 3–6 usable key poses before promising the complete 30-frame animation sheet.
4. Audit pixel bounds/alpha, clip registration, pivots/foot contact, colors, clothing, skin/face identity and legibility at 1280×720 zoom 1.0. If new art cannot meet that gate, do not insert or relabel schematic proxies as final; ship staging comparison while reporting the art blocker.
5. Publish source PNG/aseprite/layers if actually available, exact SHA, visual comparisons at game scale, approved reference links and a draft production PR. Preserve all ART-03 painted concepts and accepted older sprite assets.

### B. Level Masta Masta: scoped world implementation

1. Branch from verified Lane A PR #27 implementation (not a stale DEV-06 or directly main). Keep its comparison flags, 0.65s/39-tick loader, save isolation, gate/graph, movement and wind-fold unchanged.
2. Consume approved *derived* assets from Art Mane through explicitly coordinated Git commit references, never pull unreviewed draft branch en masse.
3. R14↔R13: replace visible placeholder depth-door proxy with approved key poses only when technically verified; preserve fallback and optional depth-demo gate.
4. R14↔R17: distinct ascending/descending contact poses, correct anchored entry/exit/stair masking, no altered collider.
5. R14/R15: introduce supported visual dressing with believable attachment to terrain/structures; never conceal pickups, anchor interaction prompts or level hazards.
6. R15↔R16: maintain run-continuation; introduce walk frames only after real frames exist. Do not slow Kaze's approved speed merely to match a new look.
7. Put **original vs refined vs art-preview vs reduced-motion** comparisons behind explicit launch options. Keep plain fallbacks.
8. QA game-scale visual clipping/occlusion/foot placement, input state, both travel directions, save reload, cancel/death/room rebuild, controlled CPU/render impact, and no movement/progression/topology regressions.
9. Publish isolated implementation branch, draft PR and PM return, with explicit list of missing production clips.

### C. Build Shogun: accessible next comparison build

1. Pin the exact art/game integration commits and Godot 4.6.1. Produce **macOS and Windows** creator review packages with isolated save profiles and obvious `Play-ART04-Preview` and `Play-TR03-Original` entry points (platform-appropriate launchers).
2. Include short launch/readme, provenance, download links via GitHub Actions artifacts whenever possible, and checksum/hash evidence; do not represent the user's chat-only file as remotely downloadable.
3. Run automated QA, Windows/macOS native smoke tests where truly available. Apple Silicon validation must not be claimed unless actually run. Target 60 FPS but do not certify it from headless tests.
4. If polished sprites are unfinished, produce a **clearly labelled transition staging comparison** with visual support art where ready, not a false 'final art' release.

## Creator review acceptance

- Actual playable room assets look faithful to the approved painted direction while retaining the existing established Kaze sprite identity.
- Kaze's doorway turn and stair entry *read as physical motions* at actual gameplay zoom, not a shrinking or sideways idle cutout.
- Architecture visibly supports previously floating sections, without hiding interaction surfaces.
- Movement feel, save progress, map, world gates, 0.65s transition clock and special wind-fold remain intact.
- Fast, readable, reduced-motion safe and 60 FPS objective preserved, subject to real hardware evidence.
- Missing full animation frames, incomplete art or native-platform gaps are listed honestly as open issues.

## Release and authority

Creator approved **visual direction** and an attempt to integrate in the next build, **not** a merge into main, a public release, wholesale world reskin, new game mechanics, or acceptance of any untested asset. Keep PR #28 and PR #27 as independently recoverable review baselines; use isolated integration PR(s), and do not merge without subsequent creator authorization.

## Required return report

Each specialist returns exact branch/HEAD/draft PR, implemented asset list vs proposed, game-scale screenshots/GIFs, affected room IDs, actual QA and platform limitations, creator review links, blockers and needed next decisions.
