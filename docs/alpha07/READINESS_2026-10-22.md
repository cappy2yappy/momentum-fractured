# Alpha 0.7 consolidated readiness report (2026-10-22)

Coordinator: Claude Production Coordinator. Draft, documentation only. No gameplay feature merge and no creator-canon approval is claimed or authorized. Alpha 0.7 stays independent of Wave 3 Candidate 3 (PR #77, `c2170032`) and of any 0.6.1 build. Creator verdict on Candidate 3 is "needs work" (3 of 28 checklist items complete); nothing here is Alpha 0.6.1 acceptance.

## 1. Inventory (verified through gh api, 2026-10-22)

| PR | Item | Head | Base | State | Change |
| --- | --- | --- | --- | --- | --- |
| #80 | Alpha 0.7 plan (this PR) | see branch | candidate/wave3-targeted-3 (diff scoping only) | draft | docs |
| #81 | ST-05 narrative bible | `1d157f4b` | candidate/wave3-targeted-3 | draft | 8 docs, +308 |
| #82 | HAZ-01 hazard toolkit | `33e70874` | feature/ld05-intentional-world-boundaries (30155f5) | draft | 25 files, +984/-0 |
| #83 | EN-01 enemy/encounter framework | `5265e6c6` | integration/candidate-alpha-0.6.1-gp-ld (afecef19) | draft | 53 files, +1253/-0 |
| none | INT-01 StoryDirector | `feature/int01-story-director` | n/a | **branch not on GitHub, no PR** | unverifiable |

## 2. HAZ-01 (PR #82) against the PR #80 contracts

Isolated and additive: no existing file changed, no world.gd hook, no save change, no production placement. Verified myself on a local trial merge onto Candidate 3 (not pushed): clean merge, preservation guard 0 failures; via the author's own runner on that merged tree, haz01_toolkit 56/0, movement_momentum 53/0, save_compatibility 11/0, ld05_boundaries 172/0 (Linux, headless). Note "292 passing checks" is 56 HAZ-01 checks plus 236 re-runs of existing suites. Running `tests/haz01_toolkit.gd` directly on Linux fails 2 course-save checks because the test hardcodes the macOS path `/private/tmp/...`; the author's runner rewrites it. Portability defect for Windows/CI, not a gameplay defect.

| Contract item | Status | Detail |
| --- | --- | --- |
| Damage through `player.damage`, no new damage path (C8) | CONFORMS | Uses it directly; 1.2 s immunity untouched |
| Telegraph at least 0.6 s (C8) | DEVIATES | Validator allows warning and recovery down to 0.3 s; defaults are 1.0 s. Either raise validator minimum to 0.6 or amend contract |
| No new colliders (C8) | DEVIATES | The `collapse` kind adds a layer-1 StaticBody2D platform. It rebuilds only when clear of the player. Needs an explicit PM and creator decision before production use; steam and electric are damage volumes only |
| State from flags (C3, C8) | NEEDS ADAPTER | Exposes `set_enabled(bool)` and its own `snapshot()` dictionary `{version, id, disabled}`. Contract persists booleans in `expansion_flags` (`trap/<id>`); the dictionary shape would be dropped by `saved_flags` and must not become a second format. Adapter: StoryDirector flag drives `set_enabled`; snapshot unused |
| Never change state under the player | CONFORMS | Collapse stays absent until clear; disabling is always safe |
| Placement rules (not on recovery floors, door approaches, bypass present) (C8) | NOT YET | Only per-resource field validation exists; no placement probe. HAZ-01 itself says production placement waits for the creator blueprint |
| Existing R15/R18/R19 vents | CONFORMS | Left intact; the PR warns not to layer both systems on the same bounds |
| Phase and timing determinism | CONFORMS | Independent clock with fixed timing, never restores an active phase after load |
| Reduced-motion safe | CONFORMS | Static hatch and timer bar, no flashing |
| Art | PLACEHOLDER | Labeled rectangles and debug text; ART-09 dependency |

Disposition: accept as an isolated toolkit prototype for review; four follow-ups (telegraph minimum, collapse decision, flag adapter, placement probe, plus path fix). Native macOS captures and the "Apple Silicon macOS" run are the author's claims; I did not reproduce them.

## 3. INT-01 event ownership and save persistence

Cannot be confirmed. `feature/int01-story-director` is not on GitHub and there is no draft PR; the reported 11 initial checks cannot be inspected. Compatibility is therefore a checklist, not a finding. INT-01 is compatible with the PR #80 contract only if all hold:

1. One StoryDirector owned by `world`; no autoload, signal hub or second flag store (C1).
2. Story state persists only as String to bool entries in the existing `expansion_flags`; `cleared_encounters` and `opened_kunai_gates` for their own domains; `save_progress` and `load_progress` unmodified so the PR37 guard passes with no new exception (C3).
3. Disk-save verification (reported outstanding) must prove: old version-8 saves load unchanged, a 0.6.1 save loads, new flags round trip, and a deleted flag never crashes. The ST-05 draft (D13) anticipates "additive narrative storage with explicit old-save defaults"; if INT-01 introduces a new save key rather than reusing `expansion_flags`, that is a contract bump requiring PM approval and a narrow guard exception.
4. Hook edits only at the five call sites in world.gd; effects deferred while `world.transition > 0`.
5. Announcement queue arbitration so objective, gate and pickup text win (ST-05 PRODUCTION requires it).
6. Gamepad support and rendered captures (outstanding per PM) cover the examine prompt; E conflicts with doors and checkpoints checked by the overlap test.

Open id-format conflict to resolve at gate A0: ST-05 uses dotted ids (`st05.b06.read`), EN-01 uses `en01/<id>`, contract v1 uses `disc|evt|trap|enc|obj/<slug>`. Recommendation: contract v1.1 reserves `en01/` and maps `st05.bNN.*` to `disc/` and `evt/` slugs at INT-01 import; ST-05 ids are proposals (PRODUCTION.md says the namespace is not an existing API).

## 4. EN-01 (PR #83) implementation status

Delivered (author-reported): three behaviors (guard, ranged, ambush) extending `guard.gd` without editing it, a JSON encounter schema with a whole-batch validator, defeat persistence in the existing `cleared_encounters` as `en01/<id>`, `completed(event_id)` signal, four isolated scenes, 43 framework assertions plus 5 save/load assertions, and eight existing suites (191 assertions). I reran on a local trial merge onto Candidate 3: `tests/en01/framework.gd` 0 failures, `tests/en01/persistence.gd` 0 failures. Native macOS captures and the 191-assertion existing suites are the author's claims.

| Contract item | Status | Detail |
| --- | --- | --- |
| Extend guard.gd, do not edit | CONFORMS | |
| Persistence in existing dictionaries | CONFORMS | `cleared_encounters["en01/<id>"]`, bool |
| Story activation reads flags | CONFORMS | Reads `expansion_flags`, read-only |
| Spawn through `world.spawn_enemy` with `persistent_id` meta (C7) | DEVIATES | Own Encounter node instantiates enemies and registers them in `world.enemies`; reasonable but must be reconciled so patrol bounds and defeat handling stay single-path, or the contract amended |
| hp budget 4 to 8 (WORK_ORDERS) | DEVIATES | Schema allows hp 1 to 30; add a validator cap to prevent padding |
| Telegraph at least 0.5 s | NEAR | windup minimum 0.48 s; default 0.65 s. Raise minimum to 0.5 |
| Spawn grace | CONFORMS | minimum 0.8 s |
| Save during transitions | CHECK | Calls `world.save_progress()` on defeat; confirm it cannot run during a transition (hang class); route through the director's deferred save |
| `completed(event_id)` to StoryDirector | NEEDS ADAPTER | Listener calls `story.report` |
| Base branch | NOTE | Based on `integration/candidate-alpha-0.6.1-gp-ld`, not Candidate 3; the trial merge onto Candidate 3 is clean and additive |

Limits stated by the author: fixed horizontal surfaces, placeholder art, no Windows or physical controller verification, no feel sign-off.

## 5. ST-05 (PR #81)

Documentation only, stays inside its stated limit. It proposes optional discoveries and three mutually exclusive casualty treatments (F1, F2, F3), all pending creator choice (D6). No casualty, death, named character or new objective may be implemented from it before an explicit creator decision. D13 (examine UI and persistence) is pending and must be answered by INT-01 under contract v1.

## 6. Integration dependency matrix (no branch is merged)

| Piece | Depends on | Blocks | Conflicts found | Gate before integration |
| --- | --- | --- | --- | --- |
| Contract v1 (PR #80) | PM sign-off (gate A0) | Everything below | none | A0 |
| INT-01 StoryDirector | A0; branch pushed and reviewed | HAZ and EN adapters, ST-05 rows, any content | not assessable | Branch visible; disk-save test; guard passes; 5 hooks only |
| HAZ-01 (#82) | A0; telegraph minimum; collapse decision | Hazard placements | none (trial merge clean, additive) | PM decisions listed in section 2 |
| EN-01 (#83) | A0; id and spawn path decision; hp cap | Encounter placements | none (trial merge clean, additive) | Section 4 items |
| ST-05 (#81) | Creator D1 to D14 | All story content | none | Per-row creator approval |
| ART-09 | Approved rows; HAZ/EN readability marks | Real visuals | n/a | Consumer ids |
| Creator blueprint markup | Creator | Room coordinates, placements | n/a | Received |
| Alpha 0.7 integration branch | A0; creator verdict on 0.6.1 | All content PRs | n/a | Created by PM only after both |

Trial merge result (local, not pushed, discarded): #82, #83 and #81 together onto Candidate 3 merge with no conflicts; 86 files, 2,545 insertions, zero deletions, no existing file touched; preservation guard 0 failures.

## 7. Independence from Candidate 3

- No Alpha 0.7 PR is based on or merged into Candidate 3 as content. #80 and #81 use it only as a diff base for documentation; #82 and #83 use older 0.6.1 bases. None is retargeted until the creator's 0.6.1 verdict and gate A0.
- The Build agent's macOS package (run 39815022431) pins exactly `c2170032` and contains none of this.
- Because all three code PRs are additive, they can be rebased onto whichever 0.6.1 base the creator finally accepts without touching Wave 3 files.

## 8. Failure-by-failure disposition, QA W6 on `c2170032` (162 pass, 8 fail, 6 skip)

Source: QA_W6_PM_REPORT.md and `result.json` (PR #65 head `1db53eed`). Thresholds unchanged; no check is waived by this report.

| # | Failing check | Evidence | Disposition | Next owner and action |
| --- | --- | --- | --- | --- |
| 1 | W3-STAIR-ASCEND-NO-LETTERBOX | 7.8% added bars vs 2% | OPEN, creator decision | Creator rules on the bars after Mac playtest; then Transition either removes them or QA gate is amended with written approval |
| 2 | W3-STAIR-DESCEND-NO-LETTERBOX | same | OPEN, creator decision | same |
| 3 | W3-DOOR-CANAL-OUT-FULLSCREEN | Canal is a world-camera presentation | RECORDED, informational by PM decision (not waived) | PM confirms category; QA relabels only on written PM approval |
| 4 | W3-DOOR-CANAL-IN-FULLSCREEN | same | same | same |
| 5 | W3-DOOR-CANAL-OUT-NO-LETTERBOX | same presentation; Return rated Perfect | RECORDED, do not change | same; Canal Return stays untouched |
| 6 | W3-DOOR-CANAL-IN-NO-LETTERBOX | same | same | same |
| 7 | W3-DOOR-CANAL-OUT-KAZE-SCALE | world-camera, gameplay scale | RECORDED, informational | same |
| 8 | W3-DOOR-CANAL-IN-KAZE-SCALE | same | same | same |

Failures outside the 176 counted Wave 3 checks (same run, acceptance table), so the headline 8 understates open automated failures by three:

| # | Check | Evidence | Disposition | Next owner and action |
| --- | --- | --- | --- | --- |
| 9 | ART08:true_animation (shipped-strip analysis, 1 of 163) | `door_turn_to_side` PNG missing; every other strip passes | OPEN, known | Art authors the clip or the creator approves leaving the labelled stand-in; blocked on creator priority |
| 10 | W3-REACH-ROUTES-vs-c49 | pairs R13 2>0 full, R15 0>1 base, R16 2>0 full | OPEN, needs evidence | Level confirms R15 base-kit is not entered without Windstep; QA reruns with longer probes (QA says R16 vanishes with longer probes and R13 2>0 existed on the control only through an escape) |
| 11 | W3-REACH-ROUTES-vs-pr51 | five pairs incl. R13 1>0 base, R13 2>0 base | OPEN, same | same |

Skips (6), all untested rather than passed: W3-STAIR-ASCEND/DESCEND-CANCEL-TIMEOUT and W3-DOOR-CANAL-IN/OUT-CANCEL-TIMEOUT (watchdog timeout path cannot be forced from outside; Transition could add a test hook), W3-COMBINED-STAIR-ASCEND/DESCEND-ROOF-VISIBLE (needs a human to read captures).

QA accounting note: the "8" counts failing Wave 3 hook checks, and `w3_totals` is 162 / 8 / 6. Items 9 to 11 are additional failing checks recorded in the acceptance table, so the true count of failing automated checks in that run is 11.

## 9. Remaining blockers and next owners

| Blocker | Next owner |
| --- | --- |
| Gate A0: sign off contract v1 (resolve id prefixes, telegraph minimum, collapse collider, spawn path, hp cap) | PM |
| INT-01 branch not visible; disk-save, gamepad, captures, regression, PM handoff outstanding | INT-01 agent |
| HAZ-01: raise telegraph minimum, flag adapter, placement probe, fix macOS-only test path | Level/HAZ-01 |
| EN-01: hp cap, windup minimum, spawn path reconciliation, deferred save | Gameplay/EN-01 |
| Creator decisions D1 to D14 (ST-05), blueprint markup, 0.6.1 verdict | Creator |
| QA W6 items 1 to 11 (section 8) | Creator, Art, Level, QA, per table |
| Platform coverage (Windows/macOS graphics, gamepad, performance, human playthrough) | Build, QA, creator |

## 10. What I verified versus what I am reporting

Verified by me: PR heads, bases, drafts and file lists; HAZ-01 and EN-01 source against the contracts; the trial merge; reruns of haz01_toolkit (via the runner), movement_momentum, save_compatibility, ld05_boundaries, en01 framework and en01 persistence on the merged tree (headless, Linux); QA W6 result file. Reported by others and not reproduced: macOS captures, Apple Silicon runs, EN-01's eight existing suites, INT-01 anything, and all creative judgments. No gameplay was changed by this report.
