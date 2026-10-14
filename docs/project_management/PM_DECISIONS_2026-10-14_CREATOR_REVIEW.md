# Kaze PM Creator Decisions — 2026-10-14

**Decision ID:** PM-DEC-2026-10-14-01
**Milestone:** Alpha 0.6.1
**Status:** Creator review; no authorization to merge mainline.

## Decisions

1. **Gameplay ACCEPTED:** speed is good as-is. Preserve jump floatiness, dash, grapple, current speed and controller. Cancel any proposed speed reduction unless later creator playtests warrant it.
2. **Art direction ACCEPTED AS PLACEHOLDER:** ART-01-0061 visuals and biome concepts may guide prototypes and follow-up production. Not final production art, not blanket approval to merge PR #11.
3. **Doors REQUIRE REVISION:** compact global entrances in PR #9 / #10 feel too small. Previously oversized floating doorways were also unsatisfactory. Prototype environmental entrances with clearly legible cues and ninja-style transition effects. Preserve room destinations, activation, ability gates, checkpoints and save behavior.
4. **Ruins DIRECTION ACCEPTED:** B1-A Overgrown Shrine as Kaze's awakening setting; B1-B Canal Remains as path toward City/Silent District. Story Agent must resolve exact timeline, escape method and geography without inventing memory loss. Hidden Village remains playable prologue.

## Assigned follow-up recommendation

**TR-01-0061 — Room Transition Presentation Prototype.** Work on a separate branch based on the verified head of combined Alpha 0.6.1 candidate PR #10. Level Design chooses two test entrances; Art supplies contextual entrance concepts; Integration implements reusable visual departure/arrival cue without changing transition/gate logic. Validate both test entrances, preserved navigation, 60 FPS sensitivity and ordinary zoom. Obtain creator approval prior to global replacement.

Maintain PR #8, #9, #10 and #11 unmerged until creator/PM integration acceptance. Record this decision for all specialist briefs.
