# GP09 startup remediation — author validation

Authorization: PR97 comment 6407592939. Existing owner/branch only; parent source 02c69c31c7595c9c901de0abe8ae005d265fca0d. The enclosing commit identifies this remediation; no composition or release approval is implied.

## Change boundary

Only production change: scripts/gp09/vertical_slice.gd. Required registration/loading now executes outside assertions with separately checked results. Startup is synchronous, without yielding; the player is disabled immediately after base construction, before consumer registration. Hazard processing is disabled before registration. Initialization is committed only after validated registrations, loaded story inventory and successful requested fresh-profile deletion.

Each successful registration records its Callable. Rollback removes a registry entry only if it still equals that Callable, then disposes owned consumers/bindings/hazard/presenter and restores the prior story tables. Existing callbacks survive duplicates and replacement callbacks survive rollback. Failure remains visible with Quit, logged, inactive, save-blocked and without automatic retry. Normal v8 loading delegates unchanged; requested fresh loading is suppressed and its deletion deferred until validation succeeds.

No controller, shared StoryDirector/EN01/HAZ01, canon/copy, profile identity/schema, production room, geometry/graph/gates, Canal, GN06/open-top, artwork, export preset or QA guard edits. The prior selective composition/conflict map remains unadopted. No assertions remain in GP09 startup; prior full tracked-GDScript audit found no other equivalent required startup operations inside assertions.

## Executed author checks

Engine: Godot 4.6.1.stable.official.14d19694e, Windows. Separate disposable APPDATA/LOCALAPPDATA profiles under ignored build/gp09; no campaign profiles used. Native runs used gl_compatibility. All commands exited 0.

| Check | Result | Log |
| --- | --- | --- |
| Startup, fresh, headless | 82 pass / 0 fail | evidence/startup/headless.log |
| Startup, existing v8 save, headless | 65 pass / 0 fail | evidence/startup/existing-save-headless.log |
| Startup, fresh, native debug | 82 pass / 0 fail | evidence/startup/native-debug.log |
| Existing GP09 scenario, headless | 36 pass / 0 fail | evidence/startup/integration-headless.log |
| Existing GP09 scenario, native debug, reduced motion | 36 pass / 0 fail | evidence/startup/integration-native-reduced.log |
| Approved baseline | 32 pass | evidence/startup/approved_baseline.log |
| Approved combat/swing | 7 pass | evidence/startup/approved_combat_swing.log |
| Movement momentum | 53 pass | evidence/startup/movement_momentum.log |
| Sprite integration | 43 pass | evidence/startup/sprite_integration.log |
| EN01 framework | 52 pass | evidence/startup/en01_framework.log |
| EN01 consumer contract | 31 pass | evidence/startup/en01_consumer_contract.log |
| HAZ01 toolkit | 56 pass | evidence/startup/haz01_toolkit.log |
| HAZ01 contract | 17 pass | evidence/startup/haz01_contract.log |

Component regression total: 291 passes, zero failures. Startup logs deliberately contain GP09 ERROR diagnostics: eight in each fresh run, seven in the existing-save run. These are injected encounter/hazard/story/inventory failures, preexisting callback collisions, callback replacement during failure and a real Windows locked-save deletion failure. No SCRIPT ERROR occurred. Do not misclassify these expected diagnostics as a clean log with no errors.

Startup tests check callback identity, unrelated callbacks, staged resource cleanup, disabled movement, visible diagnostic text, blocked save/input/exit, unchanged save bytes, no retry, successful registration/loading, deferred deletion, no duplicate ready, and reentry. The native failure screen was captured and visually inspected: evidence/startup/failure-native.png.

The existing integration suite covers discovery, cinematic interruption/retry and deduplication, managed enemy persistence across queued transitions, hazard damage, recovery, save/reload, exit/control restoration and death recovery. It is automated source/debug evidence; scripted position changes and direct calls are not a human/native-input release playthrough.

## Reproduce (Windows PowerShell, from repository)

Set GODOT to the Godot 4.6.1 console executable. Use a disposable profile:

```powershell
$env:APPDATA = Join-Path (Get-Location) 'build/gp09/review-profile'
$env:LOCALAPPDATA = $env:APPDATA
New-Item -ItemType Directory -Force $env:APPDATA | Out-Null
& $env:GODOT --headless --path . --script res://tests/gp09/startup.gd -- --gp09-fresh --gp09-save=user://startup_test.json
```

Omit --gp09-fresh to exercise existing-save failures. Omit --headless and add --rendering-method gl_compatibility for native debug startup. Run res://tests/gp09/integration.gd with --gp09-save=user://integration.json for the scenario; add --reduced-motion for its reduced native run. These test scripts overwrite only the specified disposable test save. The locked-save case is Windows-specific. Component suites run headlessly with --test.

## Remaining gates — BLOCKED release acceptance

No new Windows release EXE/PCK for this remediation was supplied or built. No actual release-EXE discovery→cinematic→encounter→hazard→recovery→save→close/relaunch/reload→exit evidence exists for this source. Release skip/cancel/focus/pause, old-save and reduced-motion scenarios and actual pack inventory checks are NOT RUN. Existing Build owns packaging after approval; existing QA owns independent Godot 4.6.1 debug/release scenario evidence. No PCK harness, historic release boot, or these author tests substitutes for that gate.

Candidate3 remains needs-work with 11 failures/six skips and missing verified Windows candidate packaging. Studio latest-head QA, creator art/geometry/rights approvals and other acceptance gates remain unchanged. PR97 remains draft/unmerged; no export, merge, release or shared integration performed.
