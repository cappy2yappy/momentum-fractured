# LD-07 QA report - 2026-10-21

Verdict: recovered ground repairs verified; coordinator review is possible, but **overall acceptance remains conditional**. GN-06 still fails its explicit dash regression and must go through PM to Transition. The roof decision remains with the creator. No failures were waived. No merge, combined-candidate change, or release build was performed.

Environment: official Godot 4.6.1 (`14d19694e`), macOS, Apple M4. Rendered checks/captures used OpenGL 4.1 Metal compatibility rendering. Disposable shadow projects and uniquely named save profiles prevented loading the creator's saves. Runtime scripts/scenes/assets/settings remain exactly at recovered `fa299cff0afe5172d5e37fad7d8378209425db56`.

## Executed results

| Check | Result | Evidence |
|---|---|---|
| Original 25 TR05 source suites, including movement/combat/save/progression | 1,607 pass / 0 fail | `evidence/stock/`, plus the six applicable suites in `evidence/recovered/`; exact per-suite consolidation in `evidence/summary.json` |
| LD05 boundary suite after assertion repair | 171 / 0 | `evidence/revised/ld05_boundaries.txt` |
| New LD07 ground suite, both roof modes | 154 / 0 | `evidence/revised/ld07_ground.txt` |
| Canal geometry | 173 / 0 | `evidence/recovered/canal_geometry.txt` |
| Automatic passage reliability, normal fresh mode | 305 / 0 | `evidence/recovered/automatic_passage_reliability.txt` |
| PM Canal passage | 56 / 0 | `evidence/recovered/pm_canal_left_passage.txt` |
| All 30 current headless suites above | **2,466 / 0** | `evidence/summary.json` |
| Native rendered: LD07 ground / automatic reliability / Canal geometry | 154 / 0; 305 / 0; 173 / 0 (632 total) | `evidence/native/` |
| Approved controller and artwork manifest | 0 failures | `evidence/approved-baseline.txt` |
| TR05 preservation after narrow PR58 contract repair | 0 failures | `evidence/tr05-preservation.txt` |
| Preservation mutation tests | 4 tests pass | `evidence/preservation-mutations.txt` |
| Known GN-06 dash regression on pinned recovered runtime | **1 pass / 1 FAIL**, exit 1 | `evidence/known-dash/ld07_dash_regression.txt` |
| Pre-repair physical reproductions on pinned 49ae3efe | All 3 defects reproduced | `evidence/before-reproduction/ld07_before_reproduction.txt` (PASS means observed broken behavior) |

The known red dash case is deliberately separate from the green geometry matrix. It is not part of the "2,466 / 0" total, and it is not waived. From feet (2300,1108) in R6, hold D, press Shift at tick 8 for one tick: Kaze reaches (2585.997,1089.998) with zero room requests. Walking inward and reapproaching recovers normally (second check passes). This existed at the recovered head, before LD-07. PM should hand the committed reproducer to Transition without assuming the later #64 implementation fixes it.

## Audits and traversal coverage

Two roof-off sweeps ran all 21 rooms: 11,216 movement samples with gate fixtures open, and 11,216 with Kunai gate flags cleared. Probe families include walking, double-tap sprinting, hops, full jumps, double jumps, dashes and grapple attempts. Each sweep includes 72 fixture starts on buried R13 pier/footing tops; those samples do not establish reachable traps. All raw samples/flags are retained in compressed JSON under `evidence/open-top/` and `evidence/closed-gates/`.

There were 149 fall samples with gates open and 148 with gates closed, all within the seven intentional pit intervals. There were also **12 above-top lateral exits with gates open** (R13: 8, R17: 4), and **10 with gates closed** (R13: 8, R17: 2). These are unresolved open-top behavior, not floor holes, and are not hidden by the ground result. The existing roof comparison is unchanged; its approval cannot be inferred from green roof-on checks.

The live-input door inventory covers 58 endpoints. All 39 ordinary walking passages open; 15 of 19 interact endpoints open. Four story-gated returns (R3<->R9 and R8<->R12) remain locked because this fixture omits their specific story flags. All 54 observed arrivals are supported. Before the sill, the same door probe on pinned 658ed34 opens only 38 of 39 walking exits; R6->R7 is the miss.

Targeted checks verify walking/sprinting over the sill; stopping/reversing before its threshold; reciprocal R7 arrival; a normal drop/jump/landing at the R8 seam; walking into and reversing away from the Canal plinth; jumping from the quay into the hallway; automatic exit in both roof modes; uninterrupted real-input Stride pickup, descent across existing shelves, and return to the Canal exit without a warp; serialized save reload/respawn on the repaired Canal landing and automatic exit afterward. Existing Canal tests cover sprint/dash/jump timings, ceiling bumps, stop/reverse, vertical route legs, grapple, held direction, and repeated re-entry.

## Initial failures and why checks changed

1. The initial Mac run of `ld05_boundaries` was 170 / 1. Its sole failure expected final stopped feet-x 227.1 +/-3 after R6->R7, but the actual supported stop was x223.4 at y1089.9. Frame-relative input release changes carried stopping distance. The replacement checks the actual reciprocal shelf contract: grounded at y1090 +/-1.5, inward of the normal arrival point and no farther than x286 (14px clear of shelf end300). It still fails wrong-room, falling, outward or off-shelf arrivals. Revised result171 / 0. The original failed transcript is preserved.
2. The initial TR05 preservation guard reported one failure: expansion `build_room` was compared literally with PR37, although PR58 had already added exactly one room-13 CanalGatehouse build hook. The guard now requires that exact hook once, compares every remaining byte of the function with PR37, requires the exact preload, and independently locks the entire gatehouse implementation to PR58. Mutation tests prove missing/duplicate hooks, an unrelated route-generation change and a moved gatehouse threshold are rejected. This repairs a stale contract; it does not loosen gameplay preservation generally.
3. The recovered LD05 report listed several source-suite failures/timeouts and a 296/9 automatic suite. Those do not reproduce under this run's isolated profiles and suite modes. In particular, the fresh normal-input automatic suite must run without `--test`; its first checks explicitly require normal mode. All 305 now pass. The 25 stock suites also pass here. Historical reports remain intact; no earlier failure claim is silently rewritten.

## Re-run

Import once, then use the QA runner. It leaves production project settings and personal saves unchanged:

```sh
Godot --headless --editor --path . --import
python3 tools/run_ld07_qa.py --godot /path/to/Godot
python3 tools/run_ld07_qa.py --godot /path/to/Godot --suites ld07_ground automatic_passage_reliability canal_geometry --rendered --label native
python3 tools/run_ld07_qa.py --godot /path/to/Godot --suites ground_probe door_walk_probe --open-top --label open-top
python3 tools/run_ld07_qa.py --godot /path/to/Godot --suites ground_probe --open-top --gates-closed --label closed-gates
python3 tools/run_ld07_qa.py --godot /path/to/Godot --suites ld07_before_reproduction --ref 49ae3efe --label before-reproduction
python3 tools/run_ld07_qa.py --godot /path/to/Godot --suites ld07_dash_regression --ref fa299cff --label known-dash
python3 tools/verify_baseline.py
python3 tools/verify_tr05_preservation.py
python3 tools/ld07/test_preservation_guard.py
```

The known-dash command is expected to return exit1 until Transition resolves GN-06. The default QA command covers 11 selected suites; the complete 30-suite inventory and original invocations are in `evidence/summary.json`. The runner applies legacy comparison mode only for the four legacy transition suites and normal mode for the fresh automatic suite.

## Untested / not accepted

No human playtest, complete fresh campaign, physical gamepad, Windows/Linux rerun, export/binary validation, performance qualification or creator design/art acceptance. The four story-gated doors were not opened in the live-input inventory (source progression/save suites pass separately). Arbitrary legacy/imported out-of-bounds save poses were not certified. No claim that this branch verifies the latest combined candidate: PR #74 is a read-only reference and must be revalidated by PM after integration. Roof changes, new recovery routes, new collision beside other doorways, and changes to Transition's Canal implementation require the appropriate owner/creator decision.
