# TR-03 Lane A — executed QA, 2026-10-15

Official Godot4.6.1.stable.official.14d19694e, Linux x86_64, isolated XDG/APPDATA per case. Final batch:27 recorded actions,20 behavioral suites, **1003 PASS assertions,0 failed assertions,0 script errors**. Includes32 preservation assertions and7 cross-process prepare/reload assertions. The original TR-02 recovery batch had893 behavioral/profile assertions with no behavioral failures; its first editor import had UID/class-registration errors, preserved in baseline_results.json. Settled current imports are clean of script errors; inherited editor cleanup diagnostics remain. Diagnostic warmup is explicitly labelled, not silently counted as a clean import.

|Action|PASS|FAIL|Script errors|Exit|
|---|---:|---:|---:|---:|
|import_warmup|0|0|0|0|
|import|0|0|0|0|
|verify_baseline|0|0|0|0|
|verify_tr03_preservation|32|0|0|0|
|approved_baseline|32|0|0|0|
|approved_combat_swing|7|0|0|0|
|annex_expansion|34|0|0|0|
|annex_traversal|6|0|0|0|
|save_compatibility|11|0|0|0|
|skyworks_progression|33|0|0|0|
|storm_keeper|12|0|0|0|
|movement_momentum|53|0|0|0|
|sprite_integration|43|0|0|0|
|world_expansion|193|0|0|0|
|expansion_gates_save|17|0|0|0|
|expansion_traversal|125|0|0|0|
|gameplay_stabilization|16|0|0|0|
|traversal_transitions|8|0|0|0|
|world_cohesion_traversal|56|0|0|0|
|integration_candidate|12|0|0|0|
|integration_descent|26|0|0|0|
|room_transition_prototype|93|0|0|0|
|mixed_transitions|109|0|0|0|
|embodied_transitions|78|0|0|0|
|profile_prepare|2|0|0|0|
|profile_reload|5|0|0|0|
|endpoint_audit|0|0|0|0|

After that full batch the test harness alone was strengthened to use real directional double-taps instead of setting the run flag. Focused final embodied suite: **80 assertions,0 failures**, replacing the earlier78-assertion harness. Runtime source is unchanged. Raw result live_doubletap.txt is separate rather than retroactively rewriting the batch count.

## Reproduction

```
python3 tools/run_tr03_qa.py --godot /path/to/Godot_v4.6.1-stable_linux.x86_64
```

That runner records exact commands/results and raw logs under ignored build/tr03/qa; it never uses the creator's normal profile. Preservation verifies player, original/cleaned art, mixed-transition policy, world-expansion graph, HUD, enemy/combat scripts, save/input/gate functions, project config and0.65s/below0.32 loader rules. No preservation checksum is weakened to fit this feature. Existing mixed suite109 assertions and room prototype93 assertions remain active.

## New behavioral coverage

All58 directed endpoints classify without inventing topology. Grounded walk vs real double-tap running in both culvert directions; original carry and exact arrivals; explicit stair up/down; opt-in depth axis and render-only quarter placeholder; swap tick20 and39/40 completion tick tolerance; actual capsule/facing/scale untouched; denied gates do not hide Kaze; repeatedE cannot restart; completion, pause, death and external rebuild restore the true sprite; reduced pose static; original/refined/reduced/plain still arrive identically. Two structural pilots retain collider counts/platform arrays. Scene/proxy lifecycles are tested in the actual engine.

## Native visual evidence

Eighteen scripted comparison captures cover walk, run, ascent, descent, depth and wind-fold in original/refined/reduced. All reach the expected destination and report a restored visible character. Native captures were1280×720 at zoom1.0 with seeded fixture progress and scripted input. They are not human playtests. GIFs downsample for comparison; full-resolution JPG stage/structure captures are preserved. Capture baseline runtime is a2b0052; later harness refinements do not change the runtime adapter.

In this container X11 Unix listeners were unavailable; Xvfb with a local TCP display allowed software OpenGL rendering. The isolated unpaced benchmark below supersedes the earlier capture-loop sample:120 draw-only wall-time samples after30 warmup frames, no PNG encoding inside timed intervals. Timing includes engine/render scheduling, not GPU draw-only duration or sustained game FPS. The comparison sequence is not randomized, and small differences are not evidence of a speedup.

```
NATIVE_RENDER adapter=llvmpipe (LLVM 20.1.2, 256 bits) driver=opengl3
DRAW_SAMPLE comparison=original n=120 mean_ms=13.921 p95_ms=16.775 max_ms=24.020 median_draw_calls=114
DRAW_SAMPLE comparison=refined n=120 mean_ms=13.711 p95_ms=15.834 max_ms=24.912 median_draw_calls=109
DRAW_SAMPLE comparison=reduced n=120 mean_ms=13.299 p95_ms=14.730 max_ms=19.177 median_draw_calls=109
```

Driver: Mesa llvmpipe LLVM20.1.2 / OpenGL4.5 compatibility, software renderer in a shared Linux container. Both structure additions are simple low-contrast backing polygons/lines. No sustained60FPS or supported-hardware performance certification. VSync-unavailable and audio/network/container diagnostics are retained honestly.

## Export and packed-resource checks

Windows x86_64 cross-export succeeds using the official4.6.1 Windows template. ZIP CRC and hashes are recorded in BUILD_MANIFEST.json. The Linux engine loaded the resource pack embedded in the exported Windows EXE from an empty working directory: boot120 frames exit0; then the external final80-assertion embodied suite ran against those packed resources and passed. Exact commands/logs are packed_resource_boot.txt and packed_resource_suite.txt. This validates packaged scripts/resources on the Linux engine, **not native Windows execution or PowerShell launcher behavior**. Native Windows launch remains for Build Shogun/creator. No Wine or macOS validation was used.

## Remaining acceptance gaps

Finished walk/rear-turn/stair-up/stair-down frames are absent; Kaze's reused/quarter-scale placeholders are labelled. Convincing rear silhouette and anatomical stair contacts are not claimed. Default fallback endpoints remain unoriented. No gamepad interaction binding exists in the inherited baseline; keyboardE is preserved, physical controller mapping/testing remains a gameplay/input follow-up. No full unseeded campaign, exhaustive human approach/turn readability or supported-hardware FPS acceptance. No main/candidate/TR-02 merge.
