# Test Results — 2026-10-12

## Environment

Official Godot 4.6.1.stable.official.14d19694e at /Applications/Godot.app/Contents/MacOS/Godot. Active source derives from September 30 parity 2ec0a1d. Tests use explicit isolated save files and bounded processes, capture logs/exit codes, and reject assertion/script/resource/physics errors even if the process returns0. The sole macOS certificate warning is classified explicitly, not silently ignored.

## Executed source validation

| Suite | Executed checks | Result | Evidence under validation/2026-10-12/continuation-final |
|---|---:|---|---|
| alpha_08_smoke | 369 | PASS,exit0,12 rooms | alpha_08_smoke.log |
| echo_territory_regression | 6 | PASS,exit0 | echo_territory_regression.log |
| swimming_regression | 11 | PASS,exit0 | swimming_regression.log |
| canal_chamber_regression | 17 | PASS,exit0 | canal_chamber_regression.log |
| recovery_regression | 43 | PASS,exit0 | recovery_regression.log |
| live_motion_regression | 37 | PASS,exit0 | live_motion_regression.log |
| fire_return_regression | 37 | PASS,exit0 | fire_return_regression.log |

Total 520 checks; machine-readable exits and summaries: continuation-final/results.json.
Fresh import and script registration: exit0/no errors (continuation-import.log).
After enabling explicit packaged-test save isolation, applicable recovery43 checks and Fire-return37 checks reran successfully (source-publication/results.json).

Actual physics/input coverage includes horizontal response, short/held jumps, dash, anchor-constrained swinging/release, player/enemy melee overlap, invincibility/Guard Veil, lethal enemy death, per-window target tracking, HUD health/cells, minimap, map/loadout/pause interaction and hit-pause timeout, physical door transitions, checkpoints/save/load/respawn, water entry/depth/ascent/descent, elemental projectile impacts, closed/open passage collision, shortcut transitions, gate/encounter persistence and death/reload. Smoke progression also uses direct handler calls; it does not prove every encounter was beaten by a player.

Live measurements: tapped jump51.70 px, held jump151.69 px; tether horizontal release350.47→341.80 px/s with normal air drag. Selected arrival markers were accurate within one physics tick.

## Failures reproduced and resolved

- Reentry dealt repeated damage within one multi-target melee window: fixed target tracking; also handle restarted attacks with continuing overlap.
- Lethal Echo collision changed monitoring during a physics callback: defer monitoring for Hitbox/Hurtbox/projectile shutdown.
- Checkpoint respawn used default rather than saved arrival marker: await scene_changed before restoration.
- Escape/map/pause interleaving and hit-pause timeout could unpause a visible overlay: coordinate ownership.
- New room9 initially failed the existing textured-layer smoke assertion: added a coherent second textured environment layer and reran all seven suites.
- Sandboxed re-import could not write editor settings/ObjectDB snapshots despite exit0: strict runner marked it failed. Import reran with normal filesystem access and passed. Both logs retained under stability/.

## Rendered performance — measured, limited scope

Apple M4, Mac16,1, Metal Forward+,1280×720. Sampled180 frames per room after40 warmup frames across12 rooms. Averages116.8–120.1 FPS, p95frame times 8.6–9.9 ms, worst frame53.5 ms. Process exit0; raw samples/log in rendered-performance.json/.log. Average60 FPS was exceeded on this Mac in this short probe. Frame spikes mean a sustained16.67 ms budget is not established; Windows performance is untested.

## Export verification

Source commit 5b364591e9835819882566a7a1f3d4694587457b. Official4.6.1.stable templates downloaded from godotengine/godot-builds. Both exports exited0 with no export errors/warnings; final-export/export-results.json contains byte sizes/SHA-256 hashes.

| Export | Actually run/verified | Limitation |
|---|---|---|
| Windows x86_64 | Valid PE machine0x8664; embedded GDPC pack footer;117951936 bytes | No native Windows execution or platform playthrough |
| macOS universal | ZIP CRC valid; Mach-O x86_64+arm64;74180193 bytes; packaged native headless startup180 frames exit0/no errors and isolated save creation | No full rendered packaged playthrough; signing/notarization acceptance pending |

Evidence: final-package-verification.json; final-export/macos-native-results.json/.log.
An attempt to run editor regression scripts against the release binary exited1 because official release templates disable --path overrides. Recorded under native-macos-tests/. It is not reported as a passed regression suite; use the official editor for those suites and dedicated native startup/playthrough checks for exports.

## Remaining warnings and unrun acceptance

macOS headless editor prints get_system_ca_certificates ERROR (ret != noErr); the unsandboxed import/export/native startup did not report it. Some smoke/test shutdown paths still warn of ObjectDB instances leaked at exit (verbose audit identified audio playback/Tween instances). These warnings remain open.

Not passed/claimed: complete player reachability through all rooms; subjective movement/web feel; canonical Kaze art; run/parry/unlock parity; bespoke boss acceptance; underwater presentation/recovery; native Windows runtime; full packaged platform playthroughs; sustained target-device60 FPS; Alpha 0.5 or0.8 acceptance.

Reproduce source suites: python3 tools/validate_recovery.py --godot /path/to/official/Godot-editor. Import requires normal access to Godot editor settings; --skip-import can reuse a successful import. Export tool: tools/export_recovery.py, with official templates in build/templates. The proposed native-platform CI is retained in docs/ci but is not installed or claimed to have run.
