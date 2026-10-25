# Dependencies, risk register and proposed Alpha 0.7 acceptance criteria

## 1. Dependencies

| Dependency | Needed by | State |
| --- | --- | --- |
| Creator verdict on the Alpha 0.6.1 macOS playtest build (PR #77 pin `c2170032`) | Creating the Alpha 0.7 integration branch | Build in progress; verdict pending |
| PM sign-off on CONTRACTS.md v1 (gate A0) | All A1 work | Pending (this PR) |
| Creator 21-room blueprint markup | ST-05, all of ROOM_MATRIX | Pending, authoritative when received |
| ST-04 decisions D3 to D8 (environment identity, chronology, optional text moments) | Content rows | Pending |
| Level/world geometry updates from the creator | Hazard and object coordinates | Pending; coordinates in the matrix are provisional |
| Room Creator PR #79 and Cut-In Maker PR #78 | Phase C and cut-ins only | Unmerged pilots, not adopted |
| ART-08 open items (`door_turn_to_side`, stand-in `door_turn_to_rear`) | None for 0.7 systems | Tracked separately under 0.6.1 |

## 2. Risk register

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
| --- | --- | --- | --- | --- | --- |
| R1 | Alpha 0.7 code leaks into the 0.6.1 candidate | Low | High | Separate branches and base SHAs; PR base never candidate/wave3-targeted-3; Build pins are explicit | Coordinator |
| R2 | Edit to a guarded world.gd function breaks the PR37 preservation guard or old saves | Medium | High | Contract: story state lives in existing dictionaries; hooks only at the five listed call sites; guard runs in every PR; old-save fixtures | INT-01, QA |
| R3 | Two agents create competing event or flag mechanisms | Medium | Medium | One StoryDirector; code review checklist item; validator rejects unknown ids | Coordinator |
| R4 | Story effects fire during a cinematic and recreate the doorway-hang class of bug | Medium | High | Effects deferred while `transition > 0`; cinematics never own progression; TR-08 and `--tr08-off` must give identical state; stress hooks reused | INT-01, QA |
| R5 | Single-line announcements overwrite each other or objective text | High | Medium | FIFO of 3 and priority rules; no dialogue UI until ST-05 approves one | INT-01 |
| R6 | Interactable E prompts collide with doors, checkpoints or automatic transitions | Medium | High | Overlap validator; E handler order; unit test over all records | INT-01 |
| R7 | Padding: more backtracking, higher enemy hp, extra mandatory reading | Medium | High | Budget table; acceptance criterion A9 (optional content only, no new mandatory gates); pacing harness | Coordinator, QA |
| R8 | New traps create unfair deaths or block recovery floors | Medium | High | Placement probe, telegraph minimum, bypass requirement, no new colliders | HAZ-01 |
| R9 | Unapproved canon enters through text or art | Medium | High | Rows carry creator status; `[TEST FIXTURE]` scan; ST-05 consistency check | ST-05, QA |
| R10 | Save counters or non-bool values silently dropped by `saved_flags` | Medium | Medium | Bool-only schema documented; validator rejects non-bool state | INT-01 |
| R11 | Pack omits `data/*` so builds run with empty content, or includes dev fixtures | Medium | Medium | Same-PR include filter plus pack check; fixtures live under tests/ (excluded) | BUILD-08 |
| R12 | Creator markup invalidates matrix coordinates | High | Low | Matrix marked provisional; rows keyed by ids not coordinates until approved | ST-05 |
| R13 | New enemy art blocks behavior work | Medium | Medium | Behavior can ship with existing sheets recolored only as TEST FIXTURE; real art is ART-09 | EN-01, ART-09 |
| R14 | Automated checks mistaken for creative acceptance | Medium | High | Reports separate automated, software-GL, creator, untested; no claims of fun or pacing from tests | QA, Coordinator |
| R15 | Platform coverage still untested (macOS/Windows graphics, gamepad, sustained FPS, human full playthrough) | High | Medium | Listed in every report; Alpha 0.7 build only after 0.6.1 platform verification plan | Coordinator, Build |

## 3. Proposed Alpha 0.7 acceptance criteria

Each criterion is checkable; creator-judgement criteria are marked C. Thresholds from 0.6.1 QA are not lowered.

| ID | Criterion | Evidence |
| --- | --- | --- |
| A1 | Contract conformance: one StoryDirector; no other event hub, flag store or save key introduced | Code scan, validator output |
| A2 | Preservation: PR37 guard passes with no new exceptions to guarded functions; movement checksum and approved sprites unchanged | Guard, movement suites |
| A3 | Old saves (version 8 fixtures incl. a 0.6.1 save) load; new saves round trip every story flag; encounters and hazards restore correctly after save and reload; deleting a flag in a save never crashes | Save fixture tests |
| A4 | Flag stability: no id renamed or reused; ST-04 strings and Foundry Rest Station pinned by test | Data validator, st04 test |
| A5 | Discovery chain demo: report a discovery, objective updates, an encounter triggers, a trap changes state, and a cinematic request is made without owning progression, in one scripted run, with identical gameplay state under `--tr08-off` and reduced motion | Demo test |
| A6 | Interactables: zero overlaps with doors, checkpoints and automatic transitions; every E target reachable; prompts readable at gameplay scale | Overlap test, software-GL captures, C review |
| A7 | Enemies: budget table honored; each new enemy has a telegraph at least 0.5 s and two valid counters; 1000-tick soak without errors; existing encounters bit-identical | Probes, soak |
| A8 | Hazards: telegraph at least 0.6 s; bypass or timing window exists; none on recovery floors or door approaches; state-gated hazards never change under the player | Placement probe |
| A9 | No padding: no new mandatory gates, no mandatory reading, no hp inflation; added content is optional or varies existing encounters. Pacing harness reports main-route time before and after; the creator sets any target | Pacing report, C |
| A10 | Real-input regression: #42 305/0, hang regression 53/0, stress 57/0, native cinematic 54/0, stock 1,617/0 (or the updated agreed baseline) still pass | QA run |
| A11 | Creator-approved content only: every shipped text, object, enemy placement and hazard maps to an APPROVED row; no `[TEST FIXTURE]` strings in the pack | Pack scan |
| A12 | Packaging: data files present, source_art excluded, manifest and hashes verified on a machine with Actions access | Build report |
| A13 | Creator playtest on macOS (and Windows validation) covering discovery readability, enemy fairness, trap readability, pacing | C, human |
| A14 | All feature PRs draft, independently reviewable, no merges before the PM release call | GitHub state |

## 4. Gate list

- A0: contracts frozen (PM).
- A1 done: INT-01, EN-01, HAZ-01 cores reviewable with isolated demos.
- B0: creator markup received and rows approved.
- B1 done per room: matrix rows integrated and QA'd.
- C: room designs received (separate plan).
- D: acceptance A1 to A14 evaluated; GO/NO-GO written by the Coordinator, decision by PM/creator.
