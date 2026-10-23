# Alpha 0.7 Production Plan (PM-ALPHA07)

Status: PLAN ONLY. Documentation draft. No gameplay code, scene, asset or save change is included, and nothing here is creator-approved canon.
Author: Claude Production Coordinator. Date: 2026-10-22. Base for this docs branch: Wave 3 Candidate 3, PR #77, `c2170032d08ea55268313e0020676c743251deab` (code read at that SHA).

## 0. Alpha 0.6.1 protection

- PR #77 (candidate/wave3-targeted-3) is draft, open, unmerged. Its QA is 162 pass / 8 fail / 6 skip with unchanged thresholds. The PM authorized exactly one macOS creator-playtest build pinned to `c2170032` (PR #77 decision comment, 2026-10-21). That build is in progress under the Build agent and is separate from everything in this plan.
- Alpha 0.7 work happens on its own branches. **Nothing from Alpha 0.7 is merged into, or stacked on, candidate/wave3-targeted-3 or any 0.6.1 build candidate.** Alpha 0.7 branches base on the SHA that is current when each work order starts, and are rebased/merged forward only after the creator verdict on 0.6.1.
- Locked inputs that every Alpha 0.7 branch must keep byte-exact unless a work order lists a narrow, documented exception: player.gd, momentum_profile.gd, project.godot, the PR37 guarded functions in world.gd (including save_progress and load_progress), the approved sprites, ST-04 copy strings, Canal Return timelines, roof-on/open-top comparison.

## 1. Documents

| File | Content |
| --- | --- |
| README.md | This summary, scope separation, integration sequence |
| SURVEY.md | What already exists in the code, with reusable systems |
| CONTRACTS.md | Shared technical contracts (event, flags, save, interactable, encounter, hazard, objective, cinematic) |
| WORK_ORDERS.md | Agent work-order matrix INT-01, EN-01, HAZ-01, ST-05, ART-09 plus QA and Build |
| ROOM_MATRIX.md | 21-room enhancement matrix |
| RISKS_AND_ACCEPTANCE.md | Risk register, dependencies, proposed Alpha 0.7 acceptance criteria |

## 2. Scope separation (what is allowed when)

1. **Reusable systems and isolated demonstrations (can start now, no creator content approval needed).** Story director and flag helpers, interactable base, encounter and hazard spec loaders, an isolated test room that is not in the 21-room world, and unit tests. Demo content is neutral and labelled TEST FIXTURE. No canonical text, no named characters, no revelations.
2. **Creator-approved content integration (blocked on approvals).** Real discoveries, objective text, encounters, traps and story beats in the 21 rooms. Each item needs a row in ROOM_MATRIX.md marked APPROVED by the creator. The creator is separately marking up the 21-room blueprint; that markup is authoritative input and will supersede the proposals here.
3. **Additional rooms and world expansion (blocked on creator-designed rooms).** Only after the creator delivers designs. The room-authoring pilots (PR #79 Room Creator, PR #78 Cut-In Maker) are tooling dependencies, not adopted.
4. **Full gameplay QA and pacing (last).** Pacing is measured, not padded.

## 3. Hard rules for all Alpha 0.7 agents

- No unapproved new rooms, named deaths, major revelations or new canonical story events. ST-03 and ST-04 canon stands: the 21 rooms occur right after the refuge attack, a survival and search story, R11 checkpoint is "Foundry Rest Station", chronology of convoy and evacuation records stays undated, "Mentals" is not a faction.
- No new dialogue UI. The game has only a single-line announcement banner today (see SURVEY.md). Any text surface must be proposed in ST-05 and approved first.
- No second event manager, no second save file, no new save keys (see CONTRACTS.md section 3).
- Playtime depth must come from meaningful optional discovery, encounters with distinct behaviors and readable hazards. No padding: no extra backtracking walls, no inflated enemy hp, no timers, no mandatory reading.
- Keep every feature PR draft, small, and independently reviewable. No merges.

## 4. Integration sequence

| Step | Content | Gate to start | Gate to finish |
| --- | --- | --- | --- |
| A0 | Contracts frozen (CONTRACTS.md v1) | This PR reviewed by PM | PM sign-off on contracts |
| A1 | INT-01 core: StoryDirector, flag helpers, interactable base, isolated demo | A0 | Unit tests, no change to guarded functions, #42 305/0, hang 53/0 |
| A1 (parallel) | HAZ-01 core: hazard spec and runner, isolated demo | A0 | Existing vents behave identically (regression) |
| A1 (parallel) | EN-01 core: enemy registry, two new behavior scripts on guard.gd base, isolated demo | A0 | Existing encounters identical, persistent_id contract |
| A1 (parallel) | ART-09 request list and placeholder-free style board | A0 | Requests list only; no gameplay assets shipped without a consumer |
| A2 | ST-05 beat sheet from creator markup | Creator blueprint markup | Creator approval per row |
| B1 | Content integration room by room, smallest regions first | A1 merged to an Alpha 0.7 integration branch (not main, not 0.6.1) plus approved rows | Per-room QA, save round trip |
| C | New rooms | Creator room designs | Level plus QA |
| D | Full QA and pacing pass | B1 complete | Acceptance criteria met |

Alpha 0.7 integration branch: `candidate/alpha07-integration`, created only after the PM approves A0 and the 0.6.1 creator verdict is in. Feature branches stack on it, one PR each, all draft.
