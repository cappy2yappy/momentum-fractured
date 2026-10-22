# Agent work-order matrix (Alpha 0.7)

All work orders: own branch and worktree, one writer per worktree, draft PR only, no merges, REST-only GitHub, commit actual deliverables (code, data, tests, art), re-download pushed assets and verify hashes, report exact SHAs and tests really run, no em dashes, honest separation of automated, software-GL, creator and untested. Base every branch on the SHA the PM names when the order starts (not on candidate/wave3-targeted-3). Contracts: CONTRACTS.md v1. Do not edit another agent's files.

| ID | Owner (suggested) | Phase | Scope | Out of scope | Depends on | Primary deliverable | Done when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| INT-01 | Gameplay/Integration agent | A1 | StoryDirector, flag helpers (`has`, `set_flag`), rules loader, interactable base, announcement FIFO (max 3), 5 hook call sites in world.gd, `tools/story/validate_data.gd`, isolated demo scene `tests/story_demo/` | Real story text, new UI, save keys, edits to guarded functions, cut-ins | A0 contracts | Branch `feature/int01-story-director`, tests, demo capture | Unit tests green; guard passes unchanged; #42 305/0; hang 53/0; old saves load; demo shows discovery, objective, encounter trigger and trap activation in one scripted run |
| EN-01 | Gameplay/Enemy agent | A1 | Encounter data loader, trigger-on-event spawn, two new behavior scripts extending guard.gd (proposed: a ranged "lamp sentry" with a long telegraph and a "slow shielded bruiser" that must be parried) with budget table below, isolated arena | Editing guard.gd or storm_keeper.gd, new bosses, changing existing encounters, hp padding | A0; INT-01 `report` stub | Branch `feature/en01-encounters` | Existing encounters bit-identical (probe); new enemies survive 1000-tick headless soak; persistence round trip; telegraph minimums met |
| HAZ-01 | Gameplay/Level agent | A1 | Hazard spec loader and runner (vent compat, pulse, drip, state-gated), placement validator probe, isolated demo | New colliders, moving platforms, changes to water pits or `recover_from_fall`, damage rules | A0 | Branch `feature/haz01-hazards` | R15, R18, R19 vents behave exactly as before when expressed as specs; flag-gated trap changes state only while player is outside it; placement probe passes |
| ST-05 | Story agent (Narrative) | A2, B1 | Beat sheet and discovery text proposals per room from creator markup, as rules and objects data rows marked PROPOSED, consistency check against ST-03/ST-04 canon | Implementation, canonical decisions, new characters, named deaths, revelations, chronology of convoy/evacuation | Creator blueprint markup; ST-04 decisions D3 to D8 | `docs/narrative/st05/*` plus data rows | Each row has creator status; zero rows reference unapproved canon |
| ART-09 | Art agent | A1 request list; B1 art | Request list and style board for objects, enemy sheets, hazard telegraphs and readability marks; then approved assets only | Gameplay edits; replacing approved Kaze sprites or ART-08 clips; assets without a consuming approved row | A0; ROOM_MATRIX approvals | `docs/art/art09/REQUESTS.md`, later strips with manifest | Each asset has consumer id, size, pivot, license/provenance label, hash |
| QA-07 | Independent QA | Each phase | Contract conformance suite, regression of 0.6.1 behaviors, per-feature acceptance, pacing measurement harness | Writing features | Features per phase | `docs/agent_handoffs/QA07_*` | Acceptance criteria in RISKS_AND_ACCEPTANCE.md evaluated, thresholds not lowered |
| BUILD-08 | Build agent | After A1 merges to the Alpha 0.7 integration branch | Isolated demo package only on request; pack checks for `data/*` | Matrix builds | PM go | Pins, inventory | Packs include data files; source_art excluded |
| PM/Coordinator | Claude Production Coordinator | All | Gate A0, sequencing, contract bumps, integration branch, honest status | Content canon | Creator | This plan | Gates met |

## EN-01 enemy budget table (design guardrails, not creator-approved balance)

| Property | Existing Guard | Rule for new enemies |
| --- | --- | --- |
| hp | 6 | 4 to 8; boss-class 14 reserved |
| Telegraph before damage | windup state | at least 0.5 s with a distinct pose or light |
| Contact damage | 1 via `player.damage` | 1 only; no instant kills, no unavoidable damage |
| Player counterplay | strike, parry, kunai | at least two valid answers (for example parry or avoid by dash); no counter that needs an unlock the player lacks at that room |
| Spawn | `spawn_enemy` | persistent_id required; never within 400 px of arrival points or checkpoints |
| Count per room | 1 to 3 | at most 4 total, at most 2 of any new type |

## Isolated demonstration rule

Every system ships first with a demo that lives outside the 21-room world (`tests/story_demo/` or equivalent scene run by a test), uses neutral geometry and `[TEST FIXTURE]` text, and is not reachable from a normal game launch. Content integration into real rooms is a different PR, per room, per approved row.


## Ownership and delegation (Gate A0 provisional, 2026-10-22)

Codex leads implementation and may delegate to separate subagents. Claude coordinates, reviews against CONTRACTS v1.1, runs QA and keeps PRs draft. Nobody merges.

| Stream | Lead | Delegable to | Branch | Compliance changes required |
|---|---|---|---|---|
| INT-01 story director + interactions | Codex | Interactions subagent | feature/int01-story-director (not yet pushed) | Push branch, open draft PR; namespace table, deferred `request_save` |
| Cinematics (cut-in requests only) | Codex | Cinematics subagent | none yet | `request_cutin` stays a no-op until approved |
| Animation | Codex | Animation subagent | none yet | Needs creator art approval before any asset |
| EN-01 enemies | Codex | Enemy subagent | feature/en01-alpha07-enemy-framework (#83) | Windup 0.5 s, hp 4 to 8, `world.spawn_enemy` adapter, `request_save`, `en01/` alias |
| HAZ-01 hazards | Codex | Hazard subagent | feature/haz01-toolkit (#82) | Telegraph 0.6 s, flag persistence adapter, placement probe, no macOS path, EX-01 tests |
| ST-05 narrative | Creator-gated | none | narrative/st05-discoveries (#81) | Alias table only, no registration |
| QA | Claude | QA subagent | feature branches, read-only | Compliance suite for sections 2, 3, 7, 8, 9 |

Merge order is unchanged: nothing merges until the PM opens Gate A1, and integration happens only on `candidate/alpha07-integration`.
