# Executed benchmark and reproducibility

Final source pin: `1835fcca272fd6a925b3d8ad4834fb225a6caef6` (PR #33). Engine: `4.6.1.stable.official.14d19694e`, native Windows executable in headless mode. Python: local 3.10. Engine SHA-256 is in [pilot-lock.json](pilot-lock.json).

## Corrected paired run

| Suite | Baseline passes | Pilot passes | Baseline seconds | Pilot seconds |
| --- | ---: | ---: | ---: | ---: |
| level_geometry | 78 | 78 | 0.922 | 0.844 |
| movement_momentum | 53 | 53 | 9.094 | 9.078 |
| sprite_integration | 43 | 43 | 0.656 | 0.656 |
| art04_transitions | 111 | 111 | 0.656 | 0.656 |
| save_compatibility | 11 | 11 | 0.657 | 0.657 |
| **Behavioral total** | **296** | **296** | **11.985** | **11.891** |

All ten behavioral executions exited 0, with zero `FAIL:`, script errors, parse errors or failed loads. Single samples, cache state and fixed suite work dominate these timings. The 0.094-second total difference is **not evidence of speedup**, and these are process runtimes, not frame-time/FPS measurements.

Additional executed checks:

- Baseline asset/physics manifest verifier: exit 0 in both phases.
- TR-03 preservation: 32 passes in each phase, exit 0.
- TR-04 preservation: 46 passes in each phase, exit 0.
- Warmup and settled imports: exit 0, zero script/parser/failed-load matches. Their full logs retain engine shutdown diagnostics; import success does not erase those warnings/errors.
- Haxqer static lint: 0.437 seconds, **exit 1**, 54 input-action error findings and 2 optional capture-path warnings. Advisory, not a pass. See [AUDIT.md](AUDIT.md) for source-level triage.
- API-positive: 0.203 seconds, exit 0, all 5 queries found with engine version 4.6.1. `CharacterBody2D.move_and_slide` returns bool; one-way collision property exists; ray queries accept RID exclusions; AnimationPlayer.play and default collision layer were resolved.
- API-negative: 0.219 seconds, **expected exit 1**, all 3 absent: `CharacterBody2D.move_and_snap`, `CharacterBody2D.move_teleport`, `CollisionShape2D.one_way_collision_direction`. This successful negative control is separate from the linter's failure.
- SHA-256 preservation: all 996 tracked files identical before/after, `changed: []` in [preservation.json](preservation.json). The new documentation checkout itself never ran the engine.

[benchmark-results.json](benchmark-results.json) records exact absolute commands, isolated profile paths, return codes, elapsed times, failure counts and raw-output SHA-256. Every final action has a matching `.txt` transcript in this directory. [pilot-lock.json](pilot-lock.json) records precise selected sources and engine hash; [upstream-lock.json](upstream-lock.json) records all four source inventories.

## Initial attempts and corrections

Initial archive execution passed the same 296 behavioral assertions per phase. Preservation tools first errored because a Git archive has no history, then ran with supplied `GIT_DIR`/`GIT_WORK_TREE` but failed on 3/6 text files respectively. Investigation showed system `core.autocrlf=true` changed archive bytes for text types not covered by explicit LF attributes. The actual PR #33 Git objects matched historical protected objects; no source defect was established.

The corrected harness invokes `git -c core.autocrlf=false archive`, supplies Git history explicitly, uses a new execution directory and new profiles, and reruns the complete selected pair. All preservation checks then pass without source edits or weakened assertions. Failed initial records are retained under [initial-attempt](initial-attempt/), including original command records and both missing-history and line-ending failure transcripts. They are not counted as final passes. An earlier slow inventory attempt was stopped and replaced with one archive read per upstream repository; no gameplay/tool execution results came from that stopped attempt.

## Reproduce

Use a fresh workspace, separate from the active Kaze checkout. These instructions require Git, Python 3.10+ and the official Windows Godot 4.6.1 console executable. Do not install any proposed skill globally.

1. Create `kaze-skill-eval` as a separate clone containing PR #33's pin and historical bases `e9a2d1ab0537f3f903c543b080451b3556961179` and `c2c6b08bfb3b85ad174dcc7ef60bddf1a3a48c15`. Do not use a history-truncated clone for the preservation checks.
2. Clone upstream repositories into `skill-audit-upstream/{divergent,awesome,haxqer,vl4dt}` and detach each at its exact SHA from the audit table. Run no setup scripts or hooks. The harness checks their HEADs; use pristine upstream copies because selected tools execute from those checkouts.
3. Place the verified engine at `sprite-engine/Godot_v4.6.1-stable_win64_console.exe` and verify its SHA-256 against the pilot lock.
4. Run `python <path-to-this-directory>/benchmark.py --workspace <absolute-fresh-workspace>`. It writes only its disposable execution/profile/cache directories and the evaluation evidence directory. The named execution/profile directories must not contain personal data. For exact pristine-cache behavior, start with a new workspace. For this recorded run the first attempt generated the API cache, then the corrected run reused it.
5. Inspect return codes and output, not just script termination. The harness deliberately records nonzero tool results and continues so diagnostics and preservation can be compared; it is **not** a CI gate and does not return aggregate failure status. Lint exit 1 is documented rather than suppressed. The negative API query must return 1 with all 3 names absent, while behavioral/preservation checks must return 0.

`inventory.py` reproduces the static indicator scan when placed in the fresh workspace root (it locates repositories relative to itself); run only after `benchmark.py` has generated the lock. It scans source text and never executes upstream scripts. Indicator matches include comments, fixtures, examples and documentation; they are review leads, not vulnerabilities. No upstream test suite was used as a security certification.

## Executed versus pending

| Work | Status |
| --- | --- |
| Four repository pins, tracked-file hashing and static inventory | Executed |
| Focused instruction/helper/bridge security and compatibility review | Executed; scope bounded in AUDIT.md |
| Minimal haxqer tools + one physics reference pilot | Executed manually; no global installation |
| Paired TR-04 geometry/movement/sprite/ART04/save benchmark | Passed, 592 behavioral assertions total |
| Protected baseline/TR-03/TR-04 checks | Passed in corrected run; initial failures retained |
| Exact-engine API positive/negative controls | Passed expected outcomes |
| Blocking linter adoption | Rejected; advisory findings retained |
| Agent productivity A/B study; adversarial skill execution | Not run |
| Full 22-suite/1,240-assertion TR-04 replay | Not run in this evaluation; prior report only |
| Native key fixture, export build/resources, FPS/gamepad/campaign | Not run in this evaluation |
| Missing animation cycles and authored environment art | Pending existing project work |
| Expanded automation, editor/MCP bridge, installation | Deferred; outside approved minimal pilot |
| Merge | Not performed |
