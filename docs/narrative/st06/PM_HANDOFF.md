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

See VALIDATION.json for 158 executed assertions and runner provenance; validate_fallback.js reproduces those checks. Six additional before/after comparisons confirmed unchanged room data, approved strings, original candidate IDs/titles/relative offsets/art layers, room Markdown sections, ability specifications and ST05 decision register. Structural/document/HTML/JSON checks and the actual review JavaScript's DOM-model import/edit/export/reset behavior were rerun in the available V8 code runtime. The existing Python/Node command could not be launched: the host rejected execution because a configured file:///workspace permission path is invalid on Windows. The updated Python runner is supplied for a later local rerun, not claimed as executed here.

Browser visual testing: **not run**. Native browser layout, real download/print, screen reader/accessibility and responsive rendering are not covered by the model checks. No Godot run, native playtest, controller/save/transition QA, FPS or artwork review performed. Prior 131-check results are not copied forward as current execution evidence.

Final revision SHA, draft status and docs-only remote comparison are reported in the task response after publication. Keep PR107 draft/unmerged; stop again for creator review.
