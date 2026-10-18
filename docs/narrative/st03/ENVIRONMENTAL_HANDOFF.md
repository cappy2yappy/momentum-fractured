# ST-03 — Environmental Storytelling and Development Handoff
Audience: Level Masta Masta, Art Mane, Transition Masta, PM.
Recommendations only. This publication does not claim those agents were contacted or that implementation has started.
**ST-04 update (October 18):** The immediate post-attack district and Mizuki nomenclature are confirmed; use [the approved-versus-proposed R0–R7/R18 beat map](../st04/ENVIRONMENTAL_BEAT_MAP.md). Do not depict R0 as the original clan refuge, a proven emergency-shelter interior, or a named survivor location. PR #37 / PR #39 supersede PR #33 where level geometry or transition behavior differs; re-register art against actual current colliders.

## Shared deliverable per room
Use ROOM_PURPOSE_MATRIX as the brief. Supply one annotated gameplay-scale composition showing primary route, optional lane, recovery lane, exits, landmark, existing hazard/anchor, and optional clue. Every reachable area should serve progression, exploration, challenge, recovery or storytelling; not every area needs a pickup.
Do not use story dressing to hide a geometry defect. Retain believable negative space where it serves views/rope arcs; remove purposeless accessible pockets only through LD review.

## Priority work packages

**ST-04 immediate coordination:** Prioritize R0–R7 and R18 for non-spoiler environmental guidance: a safe first foothold, abandoned civic space, readable water/bridge/worker systems, neutral defended Archive threshold, and relay/pump connections. Restoration gives Kaze *access to search farther*, never magical survivor detection. Visual freshness/age and damage attribution stay ambiguous until approved. Use existing pickups and transitions only.

| Priority / owner | Scope | Concrete recommendation | Acceptance |
|---|---|---|---|
| P0 Level + Art | R14 lower area | Treat as existing roof-maintenance/recovery level with visible ascent back to upper route. Proposed old convoy-view alcove only if it adds purpose without new gate/reward dependency. | A missed swing has readable recovery; no featureless long detour; stair and R9/R13 links retained |
| P0 Art + Level | R13/R14 thresholds | Match wall returns and roof caps to PR33 repaired support; distinguish loft doorway from lateral passage | Stops/reapproaches remain supported; no false collision or directional cue mismatch |
| P1 Art + Level | R2/R15 | Pair wet cistern with dry service descent; repeated gauges/pipe shapes show connection | Water gaps/hazard bypass remain legible; no fake swim entrance |
| P1 Art + Level | R5/R17 | Numbered worker levels and fixed lift-beam structure distinguish long climb from repeated shelves | Rest landings visible at gameplay zoom; no blocked rope arc, stair or wind shutter |
| P1 Art | R8/R16/R18/R20 | Repeat maintenance markers and older masonry in different proportions | Player recognizes loop connections without reading every lore item |
| P1 Art + Level | R10/R11/R19/R12 | Consistent intake/coil/relay industrial vocabulary, distinct checkpoint shelter and boss stage | No decoration hides telegraphs, pickups, gates or routes |
| P2 Narrative + Art | Optional historical record pilots R3/R7/R16 | One age-marked inscription/record device each; affinity response proposed | Clear optionality and no named survivor/Mizuki hint; no new mandatory interaction |

## Geometry/art registration requirements
Historical PR33 coordinates below are reference-only. Confirm all present-day placements against the latest geometry in PR #37 and the transition behavior in PR #39 before producing assets; coordinate from collision geometry, not screenshot estimates.
- R13 left top1200 / R14 left top1100; extend visual cap to x0, matching repaired collider support.
- R2 right shelf top850 (120px extension), R4 top1080 (200px), R9 top810 (140px). R9 interaction marker830 is not art floor level.
- R15–20 repaired left/right perimeter strips use existing one-way landings; scenery must not imply a solid column blocking upward motion.
- R17 stair contact1680,1300 within room width1800; preserve existing crop/front lip.
- All anchor attachment positions, capsule clearance, ropes, gates, spawn pads and recovery floors remain authoritative.
- Use approved ART03/ART04 visual language, existing Kaze identity and current biome palettes. No new art direction, generic neon layer or schematic stand-in sold as production artwork.
Each future asset delivery needs transparent layers, dimensions, pivot, scale, placement metadata, collision-free bounds and gameplay-zoom screenshot.

## Transition coordination
ST-03 describes spatial relationships; it does not implement TR-05. Ordinary lateral movement should read as an adjoining passage; depth entrances as actual recesses; stairs need coherent paired landing elevations. Proposed changes must retain reciprocal endpoints, prerequisites, reduced-motion behavior and anti-loop protection.
Do not cover the source/destination cue with lore signage. No extra E prompt is requested for flavor text.

## Information and spoiler rules
- Ancient records show older lives/systems, not foreknowledge of current massacre.
- Existing convoy/evacuation notes remain undated until approved; do not claim their causes.
- Tended lamps/maintenance can suggest use; no Water motif or named clue that unmasks Mizuki.
- No Aria captivity record in the early ruins that discloses her capture location without approved chronology.
- No naming every enemy an ArcuTech agent or every shrine a clan installation.
- No mass exposition wall or required note-reading before a platform opens.
- Capability-reactive artifacts do not become new detectable beacons by inference.

## Future implementation QA, not executed by ST-03
At baseline/upgraded speed and meter states: inspect route readability, test stop/reapproach at every dressed threshold, fail swings into recovery, verify gates/checkpoints/save/reload, compare map links, check color-independent landmarks and subdued reaction effects.
Use isolated saves. New narrative pickups must never count as the three named relay sigils or modify completion flags. Run existing preservation/gameplay checks only when implementation actually changes relevant resources/code.
