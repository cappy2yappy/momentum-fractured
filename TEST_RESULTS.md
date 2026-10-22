# Test Results — 2026-10-12

## Environment and method

Official macOS Godot: `/Applications/Godot.app/Contents/MacOS/Godot`.
Reported version: `4.6.1.stable.official.14d19694e`.
Baseline: 2ec0a1d; fresh recovery worktree. Test save data isolated from the user's existing saves. Each script process had a 60-second timeout, captured stdout/stderr and an independently recorded exit code.

## Actually executed baseline

| Check | Exit | Evidence | Scope |
|---|---:|---|---|
| `--headless --path . --import` | 0 | validation/2026-10-12/baseline-import.log | Assets imported; global scripts registered; no script/resource compilation errors |
| alpha_08_smoke | 0 | baseline-alpha_08_smoke.log | 0 failures, 12 room loads; topology, tether targeting/obstruction, dash momentum, abilities, save/load |
| echo_territory_regression | 0 | baseline-echo_territory_regression.log | 0 failures; territory and ledge behavior |
| swimming_regression | 0 | baseline-swimming_regression.log | 0 failures; depth control, overlap handling, respawn, 30/60/120 tick behavior |
| canal_chamber_regression | 0 | baseline-canal_chamber_regression.log | 0 failures; actual water overlap, depth hold, ascent/descent with input |

Machine-readable exits/summaries: `validation/2026-10-12/baseline-results.json`.
All logs are under validation/2026-10-12.

## Limitations and observed failures

macOS `get_system_ca_certificates` prints an ERROR at startup; this is an environment warning, not a script compile error. ObjectDB teardown leak warnings remain in several suites and are recorded in raw logs. A zero process exit alone does not mean all errors are absent.

Existing smoke checks call progression/death handlers directly; they do not prove that a player completed every encounter. Actual melee collision and checkpoint/navigation tests are being added. Visual/HUD interaction acceptance, full-speed movement feel, 60 FPS target-device performance, Windows execution, macOS packaged execution and alpha acceptance have not yet passed.

## Stability increment evidence

All five runtime suites passed in `validation/2026-10-12/stability/results.json`. The new recovery suite passed 43 checks including physical melee damage/immunity, per-window target tracking, camera transform, checkpoint save/load and actual scene respawn, detached helper guards, and audio teardown. Initial regressions demonstrated repeated per-window damage, an Echo death physics mutation error, and default-spawn checkpoint restoration; fixed and rerun.

The sandboxed re-import exited 0 but failed the strict runner due to denied writes to normal Godot editor settings/ObjectDB snapshot paths. It is recorded as **failed**, not passed; the engine import is being rerun with filesystem access. Baseline asset import had succeeded in an isolated application directory. Certificate and ObjectDB teardown warnings remain documented.

Godot re-import with normal filesystem access succeeded (exit 0), with no script/resource/editor-setting errors: `validation/2026-10-12/stability/import-unsandboxed.log`. The initial sandbox failure remains retained in the strict results file.

## Integrated continuation results

Fresh import: exit 0, no errors (continuation-import.log). Full runtime runner: exit 0, all seven suites passed (continuation-final/results.json). Recovery 43 checks; live motion 37; Fire return 37. Tests actually drove input, collision signals, gate impacts, save/load, scene transitions and checkpoint respawns. Initial room9 textured-layer smoke failure is retained under continuation/; added a second environment layer and reran the entire suite successfully.

Live movement evidence: tapped jump 51.70px, held jump151.69px; tether horizontal release350.47→341.80px/s (normal air drag), rope length and swing angle checks passed. Actual door/checkpoint arrivals match their markers within one physics tick. UI map/loadout/pause plus hit-pause overlap checks passed after reproducing/fixing an unintended unpause.

Rendered performance (not headless): Apple M4, Mac16,1, Metal Forward+, 1280×720. Probe sampled180frames after40warmupframes in each of12rooms. Averages116.8–120.1FPS, p95 frame times8.6–9.9ms, worst frame53.5ms. Source test process exited0. The average60FPS target was exceeded on this machine in this short probe; sustained16.67ms frame budget and Windows target performance are unverified. Exact samples: rendered-performance.json.
