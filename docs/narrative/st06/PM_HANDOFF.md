# ST-06 Existing Owner Revision — Creator-Review Handoff

Date: October 24, 2026. Same Story Agent package on draft PR107 / issue102, WD01 issue106.
**Documentation-only revision complete; stop for creator review. No runtime integration authorized.**

## Source / ownership

Same branch `narrative/st06-storyboards`; revision parent `9426c7d8086bc20745fd7301fa1f318c84d0b6d3`. ST05 base remains `1d157f4b7014ad1c05e231a8787594d57b5e33a3`. This is a continuation of the existing completed review package. No replacement task, story branch or competing board.

Only `docs/narrative/st06/` is revised. Original ST05 documents/dialogue/decisions, sources/, runtime, character art, player abilities, saves and the world graph are unchanged.

## Revision delivered

1. **A — Present gameplay:** existing trap/cave sequence as currently developed.
2. **B — Pending trigger:** explore and clear selected rooms; exact room IDs/conditions remain creator decisions.
3. **C — Powerless flashback:** later playable earlier life before powers, following the original Story Bible and ST-01; exact scenes/activities/controls pending.
4. **D — Return:** preserve existing present unlocks, gameplay progress and saves, including the then-current objective and earned rewards.

REVIEW.html and BOARD.json show these four phases separately from chronological story events. STORYBOARD_CARDS.md, TIMELINE_AND_ABILITIES.md, authority register, README and 21-room overlay scope agree.

All eight original attack/fall/aftermath concepts remain editable **unscheduled flashback or memory candidates**. Their inherited +0–90s study offsets are relative references only; the former 17-second pre-control/new-game-opening assumption is superseded. They neither replace the current opening nor define the entire playable prologue. Schema v2 rejects old v1 exports that carry the superseded framing.

## Preserved authority

- Exact opening: **The refuge was attacked. I have to find the others.**
- Exact first objective: **Search for survivors. Defeat the Market sentinel for Windstep.**
- **Foundry Rest Station**, original approved dialogue and ST05 C1/C2/D1–D14 including D6a–d unchanged.
- Kenji is Kaze's brother; Aria is Kenji's missing partner; parents remain unnamed. Later Mizuki/Darkness revelations stay protected.
- Earlier powerless life precedes trial/powers/attack; no assertion that Kaze was powerless during the attack.
- Existing 21-room overlay/29 links and ability visual specifications retained. G1/G2 undecided, casualty choices blocked, geography/fire/Level redlines pending.
- Existing controller, Windstep/Wind Kunai/Tether/Dash progression, saves, Canal Doorway/automatic passages and R13/R17 open-top direction untouched.
- Prior native transition failure reports remain inherited/unverified; this documentation revision does not clear them.

## Next review / unresolved work

Creator: choose exact trigger rooms/conditions, playable earlier-life scope and candidate memory placement/duration. No new room IDs or thresholds have been assigned.

Gameplay/INT: separately review powerless-experience isolation and completion/skip/cancel/save/reload/reentry/return behavior while preserving current campaign state. This package contains requirements only; no ability stripping, save reset, flags or cutscene implementation.

Level/Art/CIN: review geography, frame composition, accessibility and future presentation handoff only within separately approved scope. Existing ownership and presentation contracts remain intact; no new clip/interface or completed artwork.

## Validation and limits

Retry verification completed October 24, 2026 against committed revision `a6d7fb21d37e813d75dce8119a2b4bfd3707153b`. All 11 downloaded ST06 files matched their Git blob hashes before testing. The presentation-order revision had already reached PR107 before the interrupted response; this retry does not rebuild or replace it.

- **Passed locally:** `python docs/narrative/st06/validate.py` — 136 assertions, including HTML parsing, JSON/document structure, Node syntax validation and the actual review JavaScript's DOM-model render/import/export/reset behavior.
- **Passed locally:** `node docs/narrative/st06/validate_fallback.js` — 158 assertions, including four experience phases, separate chronology, eight retained candidates, Markdown/model agreement and 13 invalid-import cases.
- These suites overlap; their counts are not a combined unique-test total. Both commands exited 0 using Python 3.10.6 and Node v24.13.0. The earlier launcher failure no longer blocks this retry.
- `VALIDATION.json` records both fresh runs, hashes of the verified documentation and the scope limits. The earlier V8 execution and six before/after preservation comparisons remain historical evidence, not newly executed comparisons.
- Remote comparison of the narrative revision against `9426c7d8086bc20745fd7301fa1f318c84d0b6d3` confirms 11 changed files, all under `docs/narrative/st06/`. This retry updates only this handoff and validation evidence; the board and all narrative content remain as committed.

Browser visual testing: **not run**. Native browser layout, real download/print, screen reader/accessibility and responsive rendering are not covered by DOM-model checks. No Godot run, native playtest, controller/save/transition QA, FPS or artwork review performed. Prior runtime claims remain unverified by this documentation task.

Keep PR107 draft/unmerged; stop again for creator review. The creator's trigger-room, earlier-life scope and return-policy decisions remain pending.
