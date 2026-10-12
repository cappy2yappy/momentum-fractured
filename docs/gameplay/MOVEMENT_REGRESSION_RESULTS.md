# Movement regression results — 2026-10-12

Engine: official Godot 4.6.1.stable.official.14d19694e; headless Windows; 60 physics ticks/s. All runs use disposable `APPDATA` within the workspace. No personal save or original executable was changed. Baseline commit0bf37e1; feature branch feature/alpha-0.6-momentum.

| Suite | Before PASS assertions | After PASS assertions | Result |
| --- | --- | --- | --- |
| approved_baseline | 32 | 32 | PASS / exit 0 |
| approved_combat_swing | 7 | 7 | PASS / exit 0 |
| annex_expansion | 34 | 34 | PASS / exit 0 |
| annex_traversal | 6 | 6 | PASS / exit 0 |
| save_compatibility | 11 | 11 | PASS / exit 0 |
| skyworks_progression | 33 | 33 | PASS / exit 0 |
| storm_keeper | 12 | 12 | PASS / exit 0 |
| sprite_integration | 43 | 43 | PASS / exit 0 |
| movement_momentum | new | 53 | PASS / exit 0 |

All listed commands exited0 with no FAIL assertions or script errors. Baseline art verifier passed before and after; original/active PNG bytes and animation/swing methods are preserved. Existing room geometry checks and six actual platform landing probes passed. All eight prior suites were rerun after implementation, plus the new movement suite. Sprite integration has no summary line but returns its failure-derived exit status.

Measured values: base walk400px/s; run600px/s; held jump232.5643px; scripted double-jump second-apex rise464.5643px; dash168.6667px over12 sampled physics frames. Differential controller test compares267 frames of walk/run acceleration, braking, held/tap/double jumps, wall slide/jump and dash against rollback source, within0.01 position/velocity tolerance. Separate60 swing integration steps test opposite pump directions; position/velocity agree within0.001, release velocity exactly preserved.

New tests: 399/400/420/440 accepted and441/480 rejected at default range; facing/upward/minimum-distance checks; nearest target; real layer1 obstruction; independent clearance rollback; enabled/disabled/unknown-requirement object anchors; explicit tier and invalid IDs; permanent420/630 target; combined667.8 target; meter gain/cap/idle decay/damage suppression; stationary transition rejection and alternating traveled rewards; real collider-based upgraded running and wall-blocked anti-farm; save7 roundtrip, legacy6 default, invalid level; room/death/checkpoint reset; Wind/Electric transition flags.

Integrated run probe after120 live physics frames:638.3916px/s, meter0.224. This is below667.8 and above630; meter filled through actual movement, not scripted velocity assignment. Actual movement into a wall for120 frames yields zero meter.

Known pre-existing progression defects are not counted as passes: coordinate-seeded audit shows `completed=true` from Archive relay proximity with relay_electric_seal unopened, and `secret=true` from Cistern secret proximity with cistern_wind_cache unopened. Tests log KNOWN BASELINE GAP; they do not claim successful path traversal or repair. New speed flags do not bypass the explicitly state-guarded SkyWorks transitions. See shared contract for LD-01 follow-up.

Reproduce after fresh import:

```powershell
$env:APPDATA = Join-Path $PWD 'test-user-data'
godot --headless --path . --editor --import --quit
python tools/verify_baseline.py
godot --headless --path . --script res://tests/movement_momentum.gd -- --test
```

Run the same command for every suite above. Temporary momentum is disabled by default; movement_momentum toggles it deliberately. Existing regressions test unchanged starting progression. All tests are source-level; no packaged executable or remote CI run is claimed.

Remaining manual requirements: creator comparison of400/420/440 grapple ranges and exposed object placement; longer-pendulum timing; all existing anchors near platform edges/ceilings; sprint reversal and precise landings at full meter; dash-to-tether and tether-to-dash chains; damage while attached; fresh/earned saves; unseeded complete route and gate bypass sweep at base/upgraded/full-meter states. Approve +5% permanent/+6% temporary balance and opt-in defaults before release. Native interactive control was unavailable; headless evidence does not establish subjective feel, web parity or60FPS rendering performance.

Diagnostics: pre-existing root-certificate-store warning in engine runs; editor import emitted existing MetSys RID/ObjectDB cleanup warnings. These are not new script failures and runs are not described as warning-free. No region, anchor placement, enemy/boss, environment-art or main/release edits.
