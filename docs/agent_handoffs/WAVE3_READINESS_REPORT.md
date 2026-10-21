# Wave 3 Integration and Build Gate Readiness Report

Coordinator: Claude Production Coordinator. Date: 2026-10-21. Status: **NO-GO for creator build until items B1 to B3 are decided.** No build started, nothing merged, every PR draft. No creative acceptance is claimed anywhere in this report.

Note: the assignment text said PR #63 was still in progress. It had already returned (head fa299cff) before this report, so it is included below.

## 1. Verified PR and SHA inventory (checked against GitHub via gh api on 2026-10-21)

| PR | Branch | Head | Draft | Merged |
| --- | --- | --- | --- | --- |
| #62 ART-08 | art/art08-embodied-cinematic-animation | 81679650bcd0ff8ca6f4b6373b6554027264038a | yes | no |
| #63 LD-05 | feature/ld05-intentional-world-boundaries | fa299cff0afe5172d5e37fad7d8378209425db56 | yes | no |
| #64 TR-08 | feature/tr08-fullscreen-embodied-cinematics | eb3cc0fa3b546b41a164f4786df94d479f053b75 | yes | no |
| #65 QA | test/wave3-independent-qa | 3df307e872438c6ebfe58d25efb8445c27e3c17f | yes | no |
| #69 Build | ci/build07-wave3 | fc091a0d | yes | no |
| #72 ST-04 copy | story/st04-approved-opening-copy | 5251848b5d222a03de5d6e9416f3f37b4be9e710 | yes | no |
| #73 hygiene | fix/preservation-export-filter | d9b2219fa538b772ec20869c623b1de7d4db6dc4 | yes | no |
| #74 candidate | candidate/wave3-targeted | c2c3d958abe8c1eb77e2851d29c00544bef63e80 (tree 8eb0bb92) | yes | no |

## 2. Verification of the six requested points (done on the candidate checkout, not copied from reports)

1. **Movement physics untouched.** `git diff 49ae3efe..HEAD` on scripts/player.gd, scripts/momentum_profile.gd and project.godot is empty. Against the earlier combined head 869a3aa, scripts/world.gd changes only the ST-04 strings, the boundary_polys declaration and RoomBoundary.pit_rect on the three water draw calls (art only). The guard's world.gd function-exact checks pass except the waived build_room.
2. **Canal Return.** Code review: the Return-side files are not edited. Changes in the TR-08 range are the doorway landing rule (tr08_canal_doorway.gd), a per-tick ground history `observe` (cinematic_transitions.gd, tr08_embodied_cinematics.gd) and two numbers in transition_pilot_data.gd (land_recent_ticks, land_timeout). **Unresolved discrepancy:** the Transition agent reports the Return timeline identical, but QA measured full durations about 0.1 s shorter (Canal OUT 2.18 to 2.07 s, IN 2.38 to 2.25 s; stair 2.88 to 2.75 s) with arrivals unchanged. Cause not isolated (harness frame quantisation versus a real timing change). See blocker B1.
3. **ART-08 hashes.** Re-computed SHA256 of every shipped strip against MANIFEST.json at the candidate: 13 checked, 0 mismatches. door_turn_to_side has no file (labelled unfinished).
4. **Settle clip registered.** stair_descend_arrive_settle is in the CLIPS list of scripts/tr08_clip_library.gd (line 14) and binds to the ART-08 strip. Note the library still carries a stand-in row for it that only applies if the strip is absent.
5. **Preservation exceptions narrow.** tools/verify_tr05_preservation.py allows only: the two exact ST-04 text swaps in skyworks_region.gd and the single `source_art/*` token in export_presets.cfg. Verified by negative tests: an appended line, a different word change, an extra cfg change, and a missing filter all fail. The separate `expansion build_room` failure is the LD-05 geometry change (RoomBoundary roof/pit hooks), carried as a waiver in the build pins, not in the guard script; it is still the only failing guard check on the candidate.
6. **Source art excluded.** Both presets now end exclude_filter with `source_art/*`. Pack listing: 0 source_art entries, 11 to 13 art08 entries present.

## 3. Packaging finding (MANIFEST.json)

The request said MANIFEST.json was missing from a plain export. Re-tested: it is present in the pack in both the default and the text script mode used by the build (the earlier claim came from a truncated listing regex). **No export filter change is needed; none is made.** The build inventory already fails if it is absent.

## 4. Integration sequence (as executed for candidate c2c3d958)

Base 869a3aa (PR #71 head). Merge order: #62 (81679650), #64 (eb3cc0fa), #63 (fa299cff), #72 (5251848b), #73 (d9b2219f). All clean; only scripts/world.gd auto-merged (ST-04 plus LD-05). Manual inspection: world.gd, tr08_clip_library.gd, export_presets.cfg, verify_tr05_preservation.py. Rollback: branches are untouched and unmerged; discard candidate/wave3-targeted or reset to 869a3aa; the earlier cb1a59c4 and 869a3aa candidates remain. History contains the hygiene commit that briefly added stub files (removed by the next commit); do not force push.

## 5. Validation matrix

| Check | Status |
| --- | --- |
| Heads, hashes, physics diff, guard negatives, pack listing | Verified here |
| QA harness at c2c3d958: 104 pass / 9 fail / 6 skip (unchanged), 4 acceptance categories fail | Executed by QA, headless and software GL |
| Core 460/0, issue #42 305/0, 25 stock suites 0 failed, 928 probes 0 escapes | Executed by QA |
| native_cinematic_transitions 54/0 (blocking), tr08_embodied 226/0, hang regression 53/0, st04 copy | Executed by specialists and QA |
| ld05_boundaries 171 checks, 1 failure (R6 to R7 arrival x 223.4 vs 227.1 +-3) | Failing, see B2 |
| Hosted build, exported-pack native input test, macOS and Windows launch | Ready, not executed (request prepared on #69) |
| Gamepad, sustained FPS, full campaign, human playthrough, watchdog timeout | Untested |

## 6. Blockers and accepted deviations

- **B1:** reconcile Canal Return duration (about 0.12 s shorter in QA) with the claim of an identical timeline. Requires a same-SHA timeline diff run by one party at fixed fps against 869a3aa. Return was creator-rated Perfect, so this gates a build.
- **B2:** ld05_boundaries stale expectation (3.7 px). Level decides: widen the tolerance with justification or confirm TR-08 landing changed the arrival. A candidate SHA change follows, so QA must rerun.
- **B3:** ascent true animation 88 percent vs 90 percent gate (held frame 3 of stair_arrive_idle_settle); letterbox 3.9 percent vs 2 percent (debug label and destination bar). Thresholds are not lowered. PM decision: fix, or ship to creator with disclosure.
- Known, disclosed deviations: door_turn_to_side missing, door_turn_to_rear stand-in, residual descent art flaws (hair wisps, elbow notch), dash miss before the R6 sill (Transition trigger rule), pier wall-slide of about 1.2 s (pre-existing, approved physics), universal roof NOT approved (--ld05-open-top stays), R15 base kit inconclusive.

## 7. Creator playtest checklist (observable pass or fail)

1. Canal Doorway, hold A from R13 shelf at several start offsets, 10 attempts each: PASS if Kaze always completes the embodied passage and arrives in Canal Haven with control; FAIL on any attempt that leaves her standing in the doorway for more than 3 s.
2. Doorway interruption: begin the passage, then switch window focus, press Esc, open map: PASS if after resuming she either completes the passage or can walk away and re-trigger by walking; FAIL if only E recovers.
3. Canal Return (E at R0 portal): PASS if it looks and feels as you approved (note any change in pace).
4. Stair descent R17 to R14: PASS if the back is upright, strides land toe first on treads, and the final settle ends standing without a hunch; record any frame that looks wrong.
5. Ground repairs: R6 walk right through the exit without jumping or dashing (opens every time), and pit water reads as water at the floor lip, R2 R4 R5.
6. Roof comparison: Play-Geometry-Test versus Play-Geometry-OpenTop: note which you prefer; roof stays unapproved.
7. Save and re-entry: save at R11 (label reads Foundry Rest Station), quit, reload, re-enter rooms 13, 0, 14, 17: PASS if position, checkpoint and gates persist.
8. Launch validation: macOS and Windows builds start from the launchers, no missing-asset errors, F6 reduced-motion toggles.
Cosmetic flags only (no scope expansion): top-left hint still "Find Windstep", README and PROJECT_STATUS say Foundry Refuge.

## 8. GO or NO-GO criteria for the hosted build

GO when all hold: B1 reconciled with a documented same-SHA comparison; B2 resolved and QA rerun at the new pinned SHA with no new failures versus the table above; B3 decided in writing by the PM; PR #73 guard diff reviewed by a human; native_cinematic_transitions blocking and passing; request.json set to macOS only first. After the run: creator verifies downloads with verify_download.py and checks the annotations (source head equals pin, tree matches, build_overlays empty, native input count above zero). Any new failing check blocks until explained; no silent waivers.
