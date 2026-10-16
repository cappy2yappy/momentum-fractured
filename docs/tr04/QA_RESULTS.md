# TR04 QA results — 2026-10-16

Runtime source e7c308abd93de6f2191fbf000961d6fa1bb80721 (local548bdd13ba3c9111b90cc3302f778a1ac827b9d2, identical tree6c9a100f5ef1f8ce6f003142c9bce02248b19f47). Official Godot 4.6.1.stable.official.14d19694e on native Windows, OpenGL3.3 compatibility, NVIDIA RTX 4070 Laptop GPU / driver591.44. Disposable APPDATA and explicit test saves; no personal save loaded by tests.

Final reproducible batch: **30 actions,22 behavioral suites,1,240 passing assertions, zero failed assertions, zero script/parser failures, zero nonzero exits**. Separate ART04-enabled native input fixture:11 passes. Exported Windows PCK running on the official native Windows engine: same11 passes. Actual exported EXE boot/120-frame quit: exit0. These are scripted native tests, not a human campaign playthrough.

## Commands

Run from repository root, using the official engine path in your environment:

```powershell
python tools/run_tr04_qa.py --godot ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe
$env:APPDATA="$PWD/build/tr04-native-art-user"
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --script res://tests/playtest_level_geometry.gd -- --test --tr03-art-preview
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --script res://tests/audit_level_geometry.gd -- --test
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' build/tr04/windows/Kaze-TR04-Geometry-Windows.exe
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --main-pack build/tr04/windows/Kaze-TR04-Geometry-Windows.exe --script "$PWD/tests/playtest_level_geometry.gd" -- --test --tr03-art-preview
python tools/package_tr04.py
```

The runner records every exact per-suite command/profile in [QA_RESULTS.json](evidence/QA_RESULTS.json). Exported EXE was also launched with `Start-Process -WindowStyle Hidden -Wait -PassThru`, `--quit-after 120 --log-file <absolute log> -- --test`, isolated APPDATA; exit0. See [native input](evidence/WINDOWS_NATIVE.txt), [packed input](evidence/WINDOWS_PACKED.txt), [EXE boot](evidence/WINDOWS_EXE_BOOT.txt), [geometry](evidence/GEOMETRY_TEST.txt), [preservation](evidence/PRESERVATION_TEST.txt).

## Coverage

- 19 perimeter landings: stopped capsule support,400/600/630/920px/s approaches and stop, one-way rise/catch, actual Stride collection, locked/unlocked Canal exit, reapproach/E, safe arrival and immediate Terrace capsule overlap query:78 assertions.
- Existing baseline/controller/art, combat/swing, movement/momentum, grapple, region/boss/story,21-room graph/traversal, seal/reward gates, backward-compatible saves and restart profiles, mixed triggers, embodied staging and ART04 presentation all pass.
- Native input injects actual A/D/E key events and real engine frames: Canal walking and double-tap running into wall, stop/wait/reapproach, E arrival, both stairs and both opt-in depth-door directions, restored visibility.
- All 21 room definitions exported before/after; native 1280x720 overview captures inspected, fitted inspection zoom. Four before/after Canal captures use zoom1; staged fixed position shows geometry, not a recorded failed-jump sequence.
- Windows ZIP CRC passes. Exported PCK569 resources includes new geometry script and excludes build/tests/docs/tools/source_art. Approved sprites, ART04 assets, movement, enemy systems, map, save functions and gate logic remain protected.

## Failures encountered and resolved

Recovery checks exposed Windows CRLF conversion in six non-GDScript text files; exact repository bytes were restored. The first TR04 batch rejected two intentionally extended original-room rectangles and the new verifier used Windows' default text encoding. The historical geometry reference was kept intact; tests now explicitly allow only the R2/R4 endpoint width changes. Verifier reads UTF8 and removes only the four reviewed world hooks for its comparison. Both failing checks passed targeted reruns, followed by the complete clean final batch. [Initial results](evidence/QA_INITIAL_RESULTS.json) are preserved; they are not represented as a passing run.

Import/editor/export shutdown still emits inherited RID allocation/ObjectDB cleanup diagnostics. Full warning lists remain in raw batch results. No script/parser errors or behavioral failures accompanied these; a successful export does not make those diagnostics disappear.

## Limits

No human fresh-save campaign, exhaustive all-ability shortcut/bypass sweep, gamepad acceptance, sustained60 FPS benchmark, other-GPU test or native macOS certification. Native rendering worked on the listed GPU; no new FPS measurement is claimed. The creator's favorable movement/performance feedback remains creator evidence, not a newly measured metric. ART04 single keys remain incomplete cycles; outward/arrival/walk frames remain missing. Surface materials and the R17 wall return are reusable/temporary dressing, not a completed authored environment pass. Save schema is unchanged; migration/restart regressions pass, but no creator's personal save was used.

Evidence text transcripts use LF line endings; original process logs remain in ignored build outputs.
