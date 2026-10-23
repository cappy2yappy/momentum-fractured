# LD-08 traversal audit and QA

Pinned reference: PR #77 `c2170032d08ea55268313e0020676c743251deab`. References reviewed: PR #37, PR #63 and PR #77. Native Windows, official Godot 4.6.1 (`14d19694e`), NVIDIA RTX 4070 Laptop GPU / OpenGL compatibility renderer. Tests used disposable APPDATA profiles; creator saves were not used.

## Before/after findings

The LD-07 stored ground audit contained 12 above-top lateral exits with gates open: eight in R13 and four in R17. The exact starts, directions and action sequences are retained in `tests/ld08/escape_cases.json`, extracted from `docs/ld07/evidence/open-top/ground_probe.json.gz`. R13 escapes came from upper service shelves near the gatehouse and the right boundary; R17 escapes came from the top shutter/exit shelf.

Replaying those fixtures on this PR77-based candidate with `--ld08-before` reproduces **12 open-gate and 10 closed-gate lateral exits**. The LD-08 candidate produces **zero** in both conditions. The new test defines lateral escape as feet x < -20 or x > room width + 20, matching the historical sampling. Going above y=0 is allowed. The old room probe classified some vertical ascents as escapes and omitted object-based grapple anchors; it is not used as the final pass criterion.

## Results

| Check | Result |
| --- | --- |
| Historical escape replay, wall chains, attempts to round caps, all four object anchors — headless | 66 checks, 0 failures |
| Same traversal suite — native rendered real-key input | 66 checks, 0 failures |
| 64 combinations of double-jump and reversal timing after a real wall-chain / dash at the soffit | 64 checks, 0 failures |
| 21-room geometry contract, live collision queries, central-sky rays, serialized valid save/reload/respawn | 93 checks, 0 failures |
| Eleven retained behavioral suites | 790 PASS lines, 0 failures |
| Approved artwork/controller manifest and source-scope verification | 0 failures |
| Native comparison capture passes | 18 images; all three processes exit 0 |
| Interactive review fixture boot | Exit 0 |

The eleven retained suites cover approved movement and combat/swing, momentum differentials, expansion traversal, expansion gates/saves, save compatibility, level geometry, Bellroof intentional space, Canal geometry, GN-06 dash offsets and TR-08 embodied cinematics. See `regression_results.json` for exact per-suite counts and timing. The movement suite includes frame-by-frame position/velocity comparison against the preserved controller. The expansion traversal suite still passes 125 checks, including the ordinary upper landing paths and all object-anchor eligibility checks.

The scoped traversal suite uses actual InputEventKey events and Godot physics. It does not move Kaze or assign velocity during a measured trajectory. Only initial fixture staging sets position/state. Wall-chain fixtures reach approximately y=-180 at the visible soffits, and the inward dash/double-jump attempt reaches approximately y=-395 in the open sky, while staying inside the room. These observations show that the old y=0 top is no longer a ceiling; they are not a claim of exhaustive reachability over every possible input.

The contract checks all 21 platform lists, anchors, gate definitions and portal endpoints against the roof-reference mode, and checks the other 19 boundary sets. It also queries real PhysicsServer collision at each new solid and verifies an unobstructed central vertical ray from y=-1000 to y=0. Normal R13/R17 saved checkpoints retain their exact coordinates, kit, Stride, gates and flags through a newly loaded world and respawn. Save/load/respawn methods remain byte-identical to PR77.

## Reproduction

Run from repository root with an explicit official 4.6.1 executable:

```sh
python tools/ld08/verify_scope.py
python tools/verify_baseline.py
python tools/ld08/run_qa.py --godot /path/to/godot --group contract
python tools/ld08/run_qa.py --godot /path/to/godot --group before
python tools/ld08/run_qa.py --godot /path/to/godot --group after
python tools/ld08/run_qa.py --godot /path/to/godot --group sweep
python tools/ld08/run_qa.py --godot /path/to/godot --group regression
python tools/ld08/run_qa.py --godot /path/to/godot --group native
python tools/ld08/capture_all.py --godot /path/to/godot
```

Native traversal takes about four minutes on the tested machine. Captures are Godot-rendered JPEGs at quality 0.92, not painted mockups. Exact cameras are in `tools/ld08/capture_spec.json`; hashes are in `CAPTURES.sha256`. Collision overlays mark existing solids in teal, one-way shelves in gold and boundary solids in magenta.

## Limits and retained initial findings

- **Creator geometry acceptance, Art Mane production art, a human playthrough, gamepad, macOS and exported-build verification remain pending.** This is an isolated draft, not production integration or a full-campaign certificate.
- The first checkpoint experiment tried to repair old escaped saves after loading. It failed five assertions because the existing loader clamps saved coordinates into x=40..width-40, y>=80 before staging; R13 can clamp an invalid old pose into the pre-existing gatehouse. The unsuccessful experiment's log is retained as `initial_contract_legacy_clamp.log`. That repair and its assumptions were removed from the candidate. The final contract verifies valid saved checkpoints; invalid historical escaped-save recovery remains a pre-existing issue, not a claimed fix. No save or respawn changes ship.
- The initial editor import emitted inherited resource-leak diagnostics at shutdown. Final runtime suites have no script/parser errors. These shutdown diagnostics do not establish an in-game failure or a clean export.
- R13/R17 boundary architecture and the extended sky are provisional review skins. Other rooms retain their prior roof policy; this task does not resolve their pending redesigns.
