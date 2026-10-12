# Momentum Fractured / Kaze — Project Status

Updated 2026-10-12 (America/New_York).
Active development branch: `codex/alpha-recovery-source-2026-10-12`.
Active local checkout: `~/Documents/Playground/momentum-fractured-recovery`.
GitHub source verified at `5b364591e9835819882566a7a1f3d4694587457b`; final report/export-tool commit follows this source.

## Current milestone

Recovered, published, tested recovery playtest candidate. **Alpha 0.5 and Alpha 0.8 acceptance are incomplete.**
Seven automated Godot 4.6.1 suites passed, totaling 520 executed checks across 12 rooms. Fresh asset import/script registration passed. Windows x86_64 and universal macOS playtest exports were generated; macOS packaged startup passed. Windows native runtime remains unverified.
Evidence: TEST_RESULTS.md, RECOVERY_REPORT.md, and validation/2026-10-12.

## Completed this session

- Archived both original local checkouts, all untracked/ignored files and Git objects; verified Git bundle. Located all five reported commits and preserved the unreachable stash.
- Compared all nominated GitHub branches; based active work on latest September 30 parity 2ec0a1d. Published preserved local history/stash separately.
- Recovered camera-correct damage numbers, defensive combat/checkpoint access and audio shutdown cleanup.
- Fixed repeated damage within a melee window, already-overlapped combo targets, lethal-enemy physics mutation and pooled projectile monitoring.
- Fixed checkpoint/door arrival restoration by waiting for scene_changed.
- Fixed map/loadout/pause/hit-pause ownership so one panel cannot unpause another.
- Authored Fire-Sealed Return (Room 9), saved elemental gate state, matching projectile detection, physical passage barriers, one-way Surface shortcut and map indication. Canal retreat and onward campaign remain available.
- Ran actual movement/jump/dash/tether, combat, UI, save/checkpoint and selected transition tests, plus rendered performance measurement and exports.

## Build and performance evidence

Build source: `5b364591e9835819882566a7a1f3d4694587457b`.

| Artifact | Verification |
|---|---|
| build/windows/Kaze-Recovery-5b364591.exe | Export exit0/no errors; x86_64 PE and embedded Godot pack verified; native Windows execution not run |
| build/macos/Kaze-Recovery-5b364591-macOS.zip | Export exit0/no errors; archive CRC and universal x86_64/arm64 binary verified; native headless startup180 frames exit0/no errors; isolated save created |

Hashes/byte counts: validation/2026-10-12/final-export/export-results.json. These are playtest packages, not accepted releases; signing/notarization/distribution acceptance remain pending.
Rendered source probe on Apple M4 / Mac16,1, Metal Forward+,1280×720:180measuredframes/room after40 warmup frames, averages116.8–120.1 FPS, p95frame times 8.6–9.9 ms, worst frame53.5 ms. Short-run average exceeded60 FPS on this Mac; sustained16.67 ms frame budget across target devices is not verified.

## Remaining development and acceptance tasks

P0: direct five-room reachability/playthrough and movement/tether feel approval; reconcile canonical run/parry/control/unlock pacing; remaining teardown warnings and long-session frame-time stability.
P1: canonical green/purple Kaze sheets and action animations (legacy red-scarf art remains); underwater presentation/recovery; bespoke bosses rather than scaled Echo encounters; safe recovery of Guardian, Echo Amalgam, tutorials and victory stats from preserved history.
Release: Windows native runtime/performance tests; macOS rendered packaged playthrough and signing/notarization/distribution decisions; sustained performance on target hardware.

The five-room loop is structurally implemented, not visually or subjectively parity-approved. Canonical web inspection showed Lantern Haven Alpha 0.3.2 with F parry, double-tap run, Q tether after unlock and Shift/right-click dash after unlock; Godot's existing F-kunai/base-kit choices are documented prototype differences.

## Genuine blockers and resolution

GitHub OAuth authentication can publish ordinary source but rejected the workflow-changing commit 84f82ee because it lacks workflow scope. Port22 SSH timed out; port443 rejected the existing key. Full attempted development history remains locally on codex/alpha-recovery-2026-10-12. Source was published on a new branch without rewriting either history; the workflow proposal is preserved at docs/ci/parity-playtest-build.proposed.yml. A maintainer must install that proposal with workflow-capable authentication to run native Windows/macOS CI. No such CI run is claimed.

No native Windows host is available in this session. Direct creator feel/art acceptance and target hardware validation are still required. No scheduled/background continuation process exists.
