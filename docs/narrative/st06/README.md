# ST-06 — Present Gameplay and Later Playable Flashback

**Creator-review revision • October 24, 2026 • documentation only**  
Existing Story Agent continuation on [draft PR #107](https://github.com/cappy2yappy/momentum-fractured/pull/107), task [#102](https://github.com/cappy2yappy/momentum-fractured/issues/102). Same branch `narrative/st06-storyboards`; ST05 base `1d157f4b7014ad1c05e231a8787594d57b5e33a3`. Revision continues prior ST06 head `9426c7d8086bc20745fd7301fa1f318c84d0b6d3`.

## Confirmed player-experience order

1. **Present gameplay:** Begin with the existing trap/cave sequence as currently developed.
2. **Pending flashback trigger:** Explore and clear selected rooms. Exact rooms and conditions remain creator decisions.
3. **Powerless flashback:** Play Kaze's earlier life before she has powers, following the original Story Bible and ST-01.
4. **Return to present:** Preserve existing unlocks, gameplay progress and saves; resume the then-current objective.

Story chronology is shown separately. The eight attack/fall/aftermath concepts remain **unscheduled flashback or memory candidates**, not an automatically played new-game opening. Their +0–90 s relative study timing does not define boot, prologue duration or a 17-second control lock. No flashback room IDs are assigned.

Open [REVIEW.html](REVIEW.html) locally: four experience-phase cards, separate chronology, eight retained editable candidate cards, JSON import/export and printing. These are **text/concept placeholders, not production frames or a playable prologue**. [BOARD.json](BOARD.json) is the editable source; HTML embeds the same source and works offline.

Export review JSON to retain edits; reload resets. Schema v2 locks confirmed order, pending trigger, chronology, approved copy, room inventory and candidate placement. Older v1 exports are rejected explicitly to prevent reinstating the superseded opening assumption. Descriptive edits/discussion marks remain proposals and never grant canon or implementation approval.

- [Experience order and retained cards](STORYBOARD_CARDS.md)
- [Timeline, preservation/accessibility requirements and ability visuals](TIMELINE_AND_ABILITIES.md)
- [21-room present-world overlay](ROOM_VISUAL_PROGRESSION.md)
- [Authority and exact D1–D14 register](SOURCES_AND_DECISIONS.md)
- [Validation results](VALIDATION.json) / [existing Python validator](validate.py) / [portable JavaScript fallback](validate_fallback.js)
- [PM handoff](PM_HANDOFF.md)

Only `docs/narrative/st06/` is revised. Original approved dialogue and ST05 decisions stay unchanged. Kenji is Kaze's brother; Aria is Kenji's missing partner; parents remain unnamed. Later Mizuki/Darkness revelations stay protected. No runtime, controller, cutscene, ability, save or world-graph changes.

R0 is not the refuge; trap/cave geography is not inferred from room IDs. Map/fire dimensions remain pending. Preserve 21 rooms/29 links, automatic Canal/stairs, R13/R17 open-top direction and saves. Windstep remains double_jump plus Wind Kunai; Tether is swing; Gale Dash is existing Dash. G1/G2 is undecided; no casualty by default.
