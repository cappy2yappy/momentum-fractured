# DEV-06 QA — newly executed 2026-10-13 UTC

Official Godot 4.6.1.stable.official.14d19694e on Windows; source runs use a disposable APPDATA directory (`integration-final-user`). Twelve final suites return exit 0, zero failed assertions, no GDScript parse/runtime errors. Baseline verifier returns zero failures. Pre-integration nine suites also passed; original logs are preserved outside source.

| Suite | PASS assertions | FAIL assertions | Result |
|---|---:|---:|---|
|approved_baseline|32|0|PASS|
|approved_combat_swing|7|0|PASS|
|annex_expansion|34|0|PASS|
|annex_traversal|6|0|PASS|
|save_compatibility|11|0|PASS|
|skyworks_progression|33|0|PASS|
|storm_keeper|12|0|PASS|
|sprite_integration|43|0|PASS|
|movement_momentum|53|0|PASS|
|world_expansion|193|0|PASS|
|expansion_gates_save|17|0|PASS|
|expansion_traversal|115|0|PASS|

Total: 556 passing assertions. Structured evidence: `test_summary.json`.

## Exact commands

From workspace root, with the official engine under `sprite-engine`:

```powershell
$env:APPDATA = Join-Path $PWD 'integration-final-user'
$engine = (Get-ChildItem sprite-engine -Filter '*console.exe').FullName
& $engine --headless --path kaze-integration --editor --import --quit
python kaze-integration/tools/verify_baseline.py
$suites = @('approved_baseline','approved_combat_swing','annex_expansion','annex_traversal','save_compatibility','skyworks_progression','storm_keeper','sprite_integration','movement_momentum','world_expansion','expansion_gates_save','expansion_traversal')
foreach ($suite in $suites) {
  & $engine --headless --path kaze-integration --script "res://tests/$suite.gd" -- --test
}
```

## What the tests establish

- Original eight-room collision arrays, restored-size artwork, unchanged MV-01 controller checksum, swing release and differential movement fixtures.
- Twenty-one room definitions/map cells, graph connectivity, reciprocal new links, 30 timer-driven transitions and 30 collision-settled arrival checks.
- Both-direction fail-closed progression checks at upgraded speed; named sigils reject arbitrary optional pickups; old keeper/gates remain tested.
- Cistern/Archive state guards from alternate-side coordinate approaches, save-before-open/save-after-open/save-after-reward checks; real wrong/correct projectiles at new Wind/Electric/Fire seals.
- Version8 checkpoint, speed, seals, lore/shortcut and exploration persistence; legacy4/6/7 migration. Existing app/save identity preserved. Old earned completion is retained rather than revoked.
- Every new room has a dry recovery floor, correct camera bounds, bounded enemy lanes and exposed stationary anchors. Actual airborne/facing/height/obstruction eligibility probes pass for all new anchors.
- Conservative route landing probes use actual capsule collisions and baseline400 walking, zero speed tier and meter disabled. Direction control counter-steers for the preserved lack of air braking. New service ledges are upward one-way; higher overlapping waypoints may be valid landings in the target corridor. These are seeded local probes, not continuous fresh-save navigation or creator feel approval.
- Optional meter gain/decay/cap/damage/anti-farming, dash/tether, state reset and old speed-save compatibility through the retained MV-01 suite.

## Corrections and initial failures

Initial solid ledges obstructed upward movement through overlapping shelf undersides. Changed only new40px service ledges to upward one-way, leaving original rooms/perimeters/recovery floors solid. Early landing harness assumed releasing horizontal input would brake in air; preserved controller intentionally retains air velocity. Harness now counter-steers using measured air acceleration. The old SkyWorks suite's exact13-room count was updated to21; Archive setup now explicitly opens its required seal. Retained original source assertions, not old test claims. Final reruns are recorded above.

## Visual/render checks

Native OpenGL rendering captured eight new rooms and21-room atlas with `res://tests/capture_dev06.gd`; no script errors. Inspected Spire and atlas, then tightened atlas cell width to keep the rightmost room in the map panel. Underground rooms received darker tint; environmental art remains blockout. Native capture is visual QA, not an interactive playthrough or FPS benchmark.

## Limitations and release blockers

No complete unseeded campaign playthrough, subjective web parity/440px/+5% creator approval, full swing arc/landing sweep at all progression states, or measured60FPS rendering performance. No hardware FPS claim. Initial capture used seeded abilities/exploration; it does not establish earned progression. Windows export and packaged boot are recorded in the final PM report; macOS template/toolchain is not installed. Remaining environment art is listed separately.

Known diagnostics: pre-existing root-certificate-store warning on engine runs; editor-only MetSys RID/ObjectDB cleanup warnings during import. These are not new script failures; runs are not warning-free. MV-01 still prints its historical KNOWN BASELINE GAP headings with repaired values false; the new gate suites provide the affirmative repaired-state assertions.
