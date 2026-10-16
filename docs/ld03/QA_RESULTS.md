# LD03 QA return — 2026-10-16 UTC

Baseline PR33: `1835fcca272fd6a925b3d8ad4834fb225a6caef6`. Runtime: `1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0` (local a77a40e489fe3733e0540f34753a57b3e9220aa2; identical tree9b432e0e56f4720079a9ce8b228d395b0ca48b38). Later packaging/checker commits do not change game scripts.

**Final batch: 31 actions, 24 behavioral suites, 1,292 passing assertions, zero failed assertions, zero script/parser errors and zero nonzero exits.** [Exact per-suite commands/results](evidence/QA_RESULTS.json), [summary](evidence/QA_SUMMARY.json).

Official Godot 4.6.1.stable.official.14d19694e, native Windows, NVIDIA RTX 4070 Laptop GPU, OpenGL3.3 compatibility / driver591.44. Disposable APPDATA/explicit test saves; normal creator save not loaded.

## Coverage

- 63 new intentional-space checks: six solid masses/six one-way steps match actual collision/layer policy; base400px/s jump segments with double-jump/dash/tether/Stride/momentum disabled; three roof returns; grounded foundations; existing log relocation; locked gates; six historical blocked-save positions with capsule-clear staging; unchanged free/other-room positions; real version8 save/reload/respawn preserves earned ability and lore.
- 21 room checks: all other20 ordered collision signatures match PR33 to0.001px JSON serialization tolerance; Bellroof retains every old rectangle and adds only12 authored shapes. [All-room data](evidence/SPACE_AUDIT.json).
- 46 preservation checks guard controller, momentum, mixed policy, art, map and save/gate construction. World differences are only builder/preload and two blocked-save staging calls; expansion changes only R14 optional lore coordinate/legacy decoration suppression; presentation changes only R14 backdrop.
- Existing combat/swing, boss/story, save migration/restart, movement/momentum, grapple, world traversal, gate/reward, character-art, mixed/embodied/ART04 and TR04 geometry suites pass.

Native rendered route fixtures:63 passes. Exported Windows resource pack on official native Windows engine:63 passes. Native actual-key transition fixture:11 passes. Actual exported EXE boot with120-frame quit: exit0. These are segment/input fixtures, not an uninterrupted human playthrough. Each leap fixture seeds its launch position; an overlapping higher roof landing is a valid recovery corridor, not a reason to disable mobility.

## Reproduce

From repository root, substitute your official engine path:

```powershell
python tools/run_ld03_qa.py --godot ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe
$env:APPDATA="$PWD/build/ld03/native-route-user"
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --fixed-fps 60 --script res://tests/intentional_space.gd -- --test
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --script res://tests/playtest_level_geometry.gd -- --test --tr03-art-preview
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --script res://tests/capture_ld03.gd -- --test
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' build/ld03/windows/Kaze-LD03-Intentional-Space-Windows.exe
python tools/package_ld03.py --source 1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0
```

Before captures used the same capture script with `--before` before edits. Four fixed1280x720 views, same ART04 mode; overview zoom0.46 and details zoom1. JPEG copies preserve framing; native PNGs remain in ignored build outputs.

The packed test combines the unchanged leap-helper prefix from tests/expansion_traversal.gd with intentional-space's run method, avoiding inheritance from excluded res://tests. It runs with `--main-pack build/ld03/windows/Kaze-LD03-Intentional-Space-Windows.exe --fixed-fps 60 --script <absolute packed_intentional_space.gd> -- --test`. Compiled world/controller come from the export. [Native routes](evidence/WINDOWS_NATIVE_ROUTES.txt), [packed routes](evidence/WINDOWS_PACKED_ROUTES.txt), [transition inputs](evidence/WINDOWS_TRANSITIONS.txt), [EXE boot](evidence/WINDOWS_EXE_BOOT.txt).

## Failure and build provenance

[Hosted run38847365650](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650) passed: approved art/controller, preservation, settled import, new routes, all-room audit, TR04 geometry, export, PCK/CRC and artifact uploads. Source3f03bb92f69b67bbf5f3505bd4b0112a82e729df. This hosted Windows rebuild is not byte-identical to the native-session build and does not acquire a new native rendering certificate merely because scripts match. Exact hosted download/hash are in [WINDOWS_HOSTED_BUILD.json](evidence/WINDOWS_HOSTED_BUILD.json).

Initial JSON equality rejected five unchanged rooms with generated float32 thirds. The checker now preserves count/order and compares components within0.001px; independent source guards prove construction code remains unchanged. Failed [initial results](evidence/QA_INITIAL_RESULTS.json) and hosted run38847262531 remain recorded. Corrected audit passed targeted rerun, then full final batch and hosted rebuild. No runtime change was made to conceal that checker failure.

Inherited import/editor/export RID/ObjectDB shutdown diagnostics remain in raw warnings. No behavioral/script/parser failures accompany the final run. Engine-generated import metadata/old endpoint-matrix output are excluded from the implementation diff. Transcripts normalize line endings only.

## Limits

No human full-campaign run, exhaustive reachable-volume proof, physical gamepad review, sustained 60 FPS measurement or macOS candidate. Native rendering worked on the listed GPU; fixed-fps fixtures do not measure rendering performance. ART04 missing cycles/fallbacks remain unchanged. New faces use existing materials/procedural context, not a finished original tileset.

Creator should start Lower-West, find the log, try all three returns, drop from roofs into each bay and compare Roof-Route. Old-Save-Staging demonstrates the same-x safe spawn. Other rooms were audited, not redesigned; named P2 recovery/readability issues remain in the world audit.
