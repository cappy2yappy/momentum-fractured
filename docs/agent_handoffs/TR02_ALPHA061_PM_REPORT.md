# KAZE — PROJECT MANAGEMENT RETURN REPORT

**Assignment:** TR-02-0061 — Mixed Room Transition Playable Comparison

**Date:** October 14, 2026, America/New_York

**Verdict:** **READY FOR PM REVIEW**

## A. Baseline verification

Retrieved and read the complete updated authoritative work order at `0b9470b71ebd32eaa0d4987cbd23bcde082242bf:docs/agent_assignments/TR02_ALPHA061_MIXED_TRANSITIONS.md`, including the Persona5-inspired original Kaze graphic addendum. Confirmed TR-01 branch tip `c26cb7fa23131c2fd9c8deae288f7d0d468a6b52` before creating `feature/alpha-0.6.1-mixed-transitions`. Reviewed TR-01 creator discussion, contextual presentation, combined candidate tests, actual transitions and export presets. Godot version is `4.6.1.stable.official.14d19694e`.

Published runtime commits:

- `6c39cf585e7c46f420f447e3312e268213711f1a`: mixed activation/presentation prototype.
- `1ef2f459611e366dd359ef4f970a79234136970f`: explicit opt-in isolated comparison save path and process-waited launch tooling. This is the executable's runtime source reference.

Evidence/report/test-only refinements are in a subsequent commit on the same branch; use PR head for the complete handoff. No merge was performed.

## B. Audited graph and existing transition behavior

World remains21 rooms and29 undirected links: original12 chain edges, two return shortcuts and15 expansion edges. Root `scenes/main.tscn` loads the dynamically built world; per-room bounds, collision, map cells and all edge endpoints are unchanged.

Existing loader freezes player physics for its0.65s clock, swaps rooms below0.32s remaining, places Kaze at an explicit arrival (or ordinary entrance offset), resets rope/dash transients and restarts physics. This is discrete loading, not streaming. Existing E edge radius remains85 for expansion portals and105 for ordinary exits. The walk pilot alone changes activation and carries horizontal velocity; vertical velocity is zeroed for the existing dry landing. All other interactions retain stopped arrivals.

Original movement/element acquisition, Archive restoration, named-sigil checks, Wind intake, Electric Foundry relay, Keeper and junction-return requirements remain authoritative. No new exits, skills, story flags, map connections, platforms or save versions were introduced.

## C. Exact pilot choices, recorded before edits

| Mode | Existing reciprocal connection | Endpoint feet coordinates | Arrival / prerequisites |
|---|---|---|---|
| Automatic walk-through | R15 Lower Sluice ↔ R16 Root Shrine | (2080,1120) ↔ (120,1120) | Existing destination minus(0,2); Archive restored both directions |
| Approved stairwell control | R14 Bellroof ↔ R17 Counterweight Spire | (1450,480) ↔ (1680,1300) | Existing destination minus(0,2); Tether + Dash; E/radius85 unchanged |
| Special E wind-fold | R20 Relay Junction ↔ R13 Mooring Loft | (600,520) ↔ (900,400) | Existing destination minus(0,2); Archive, three named sigils, Wind intake and existing junction switch |

R15/R16 provides matching-height dry open-culvert continuity. R14 stairwell is retained as the liked grounded control. R20/R13 is already a gated return connection, so special presentation does not invent travel powers or bypass progression.

## D. Implementation and original graphic treatment

- `scripts/mixed_transitions.gd`: bounded edge policy, directional samples,96px inward approach/rearm,0.75s arrival/load cooldown, height corridor, signed velocity and attached-tether rejection. No proximity-only activation. Closed Archive state rejects crossing and names the cause; failure requires another approach rather than repeated announcements.
- `scripts/world.gd`: small lifecycle hooks at configuration, room load, request, arrival, respawn and physics update. Uses original can_enter and clock. Prototype `--tr02-save=<absolute file>` optionally selects a disposable comparison save before loading; without that argument, the existing default path and schema remain unchanged.
- `scripts/world_expansion.gd`: suppresses only R15/R16's former E activation and updates exact pilot captions. All other E portals retain original behavior.
- `scripts/room_presentation.gd`: delegates only chosen passage/special exits and effects. TR-01 stairwell drawing function is unchanged. Culvert has a full-height recess, supports, directional cue and locked grille artwork. Wind-fold uses stable wind-thread rings, original rose accent and explicit E/requirement cue.
- Original Kaze graphic study: angled indigo/rose wind-cloth panels and thread lines, directional travel and destination badge. No Persona artwork, font, logo, music, characters or exact animation sequence is copied. No strobe or camera shake. Animated interior study is0.44s inside the retained0.65s loader fade; it does not extend navigation timing.
- Camera remains1280×720, zoom1.0. Optional departure offset is at most20px, clamped to available room-bound margin and reset on arrival/abort. No false seamless scroll claim.
- Three comparison treatments: default original graphic; `--tr02-plain` fade; `--tr02-reduced-motion` or existing `--tr01-reduced-motion` static badge/fade without moving panels/camera accent. Stairwell remains modest.
- `tests/mixed_transitions.gd`, `tests/mixed_profile.gd`, `tests/capture_mixed_transitions.gd`, `tools/run_tr02_qa.py`, `tools/package_tr02.py`: regression, isolated profile, live capture and packaging tools. Existing tests changed only for the explicitly converted edge's former E expectations.

Detailed specification: [TR02_MIXED_TRANSITION_SPEC.md](../level_design/alpha061/TR02_MIXED_TRANSITION_SPEC.md).

## E. Preservation

[preservation.json](tr02_evidence/preservation.json) records comparison with the TR-01 baseline. Player, momentum, anchor, guard, kunai, keeper, HUD, route extension, SkyWorks scripts, map data and project settings are unchanged in content. Baseline verifier confirms approved artwork/controller preservation.

World configure_input, can_enter, interact, save_progress, load_progress, add_platform, reset_room_actions and world_edges are unchanged. Expansion constants/geometry/endpoints and the complete TR-01 stairwell drawing body are unchanged. Runtime save version8, application identity and ordinary default filename remain. Explicit QA path selection is opt-in and does not change the save API or payload.

Horizontal carry is limited to the walk pilot. Vertical velocity, dash action, tether and meter still follow existing room-reset semantics. This is not preservation of an entire airborne state across rooms. Normal launches are not seeded; launchers intentionally use separate fresh and clearly labeled QA profiles.

## F. QA — actual commands, counts, warnings and performance

Final full runner passed889 assertions with zero failures or GDScript parse/runtime errors:691 combined baseline checks (including two-process profile restart),93 updated TR-01 checks and105 TR-02 checks. Test-only expansion subsequently passed109 TR-02 checks in both normal and CLI reduced-motion runs. Four explicit profile tests each passed. Unique final coverage is897 checks; repeated runs are not added to that total.

Original TR-01's109 count becomes93 because the16 E expectations for the intentionally converted R15/R16 portal were replaced by dedicated directional tests. No failed test was simply relabeled passed. Final source runtime is `1ef2f459611e366dd359ef4f970a79234136970f`; latest additional changes affect tests, recipe/readme and reporting only.

Tests establish directional walk/run/dash-speed sampling and live player-input/collision crossings; wrong direction, stationary/corner/height/tether rejection; reciprocal safe arrivals and carried x velocity; no proximity bounce; load/respawn cancellation; unchanged E ranges/held-E behavior; individual special prerequisites; upgraded save reload; graph/name/cue consistency and reduced-motion configuration. Existing baseline suites cover progression, real projectiles, named sigils, collisions, checkpoints and save migration.

Exact reproducible commands from the feature checkout:

```powershell
# Writable portable copy of official4.6.1 engine, with Windows template.
$trEngine="$PWD/build/tr02/engine/Godot_v4.6.1-stable_win64_console.exe"
python tools/run_tr02_qa.py --godot $trEngine
# Extra final policy runs; isolated APPDATA in build/tr02/final-policy-user.
& $trEngine --headless --path . --script res://tests/mixed_transitions.gd -- --test
& $trEngine --headless --path . --script res://tests/mixed_transitions.gd -- --test --tr02-reduced-motion
# Each actual fixture save is passed after --; expected-room is0,15,14 or20.
& $trEngine --headless --path . --script res://tests/mixed_profile.gd -- "--tr02-save=$trSave" "--expected-room=$trRoom"
# Normal1280x720/zoom1.0 live scripted comparisons and no-encoding draw sample.
& $trEngine --path . --fixed-fps 60 --script res://tests/capture_mixed_transitions.gd -- --test
# Local export and package, not unmerged CI.
& $trEngine --headless --path . --export-release 'Windows Desktop' build/tr02/windows/Kaze-TR02.exe
python tools/package_tr02.py 1ef2f459611e366dd359ef4f970a79234136970f
& .\build\tr02\playable\launch.ps1 -Pilot walk -Treatment graphic -Headless -QuitAfter 180
```

QA runner records complete commands, elapsed times, pass/fail counts and diagnostics in [test_results.json](tr02_evidence/test_results.json); raw suite output is beside it. Source fixture runs loaded expected0/15/14/20 and an absolute QA save path. Final packaged fresh/walk/stair/special processes were waited and exited0. Native packaged movie capture exited0 for all three seeded pilots; inspected title crops confirm Lower Sluice, Bellroof Walk and Relay Junction. Packaged capture command uses engine arguments before `--`, then `--tr02-save="<absolute fixture file>"` after it. Source live capture reached all nine intended destinations (three modes × three pilots).

NVIDIA RTX4070 Laptop GPU, OpenGL3,120 warmed native draw intervals per mode, no screenshot encoding inside measured intervals:

| Treatment | Mean ms | p95 ms | Maximum ms |
|---|---:|---:|---:|
| Plain fade | 1.985 | 2.653 | 3.368 |
| Original graphic | 2.021 | 2.878 | 3.553 |
| Reduced motion | 1.909 | 2.647 | 3.012 |

These are short uncapped draw-frame samples with fixed simulation stepping, not sustained campaign FPS certification. PNG/movie encoding is intentionally excluded; packaged movie encoding took much longer than gameplay draw time and is not a frame-rate benchmark. No full hardware matrix or continuous earned-progression campaign acceptance is claimed.

Known diagnostics remain certificate-store errors and MetSys RID/ObjectDB cleanup warnings. Initial export from a read-only portable-engine folder produced a corrupt project header; that export was rejected and rebuilt using a writable engine directory. Initial launch checks did not correctly wait for the GUI process and are not accepted evidence. Environment-only release profile selection and an omitted CLI separator were detected through native capture, corrected with explicit QA save arguments and proper `--`. Release templates do not support the external --script inspection attempted here; stalled probe processes were stopped and no probe pass is claimed. Final binaries/captures/launchers supersede all failed attempts.

## G. Publication, artifacts and build provenance

Draft [PR #16](https://github.com/cappy2yappy/momentum-fractured/pull/16) targets **TR-01's feature branch**, not integration/main. Branch: `feature/alpha-0.6.1-mixed-transitions`. Runtime commits are listed above; final evidence/report commit is included in PR head. No merge, force push, CI workflow adoption or other agent branch overwrite.

User-facing delivered files:

- `Kaze-TR02-Mixed-Transitions-Windows.zip` — Windows x86_64; final corrected isolated launchers,10 comparison/fresh command files and readable instructions. No personal saves are shipped.
- `TR02-walk-Comparison.gif`, `TR02-stair-Comparison.gif`, `TR02-special-Comparison.gif` — side-by-side plain/original/reduced live scripted captures; previews, not human-playtest footage.
- Native packaged witnesses and graphic contact sheet: [tr02_evidence](tr02_evidence).

Exact local output directory is `C:\Users\TonyS\Documents\Codex\2026-10-12\new-chat\kaze-tr02\build\tr02`. User-facing file links accompany this handoff. [BUILD_MANIFEST.json](tr02_evidence/BUILD_MANIFEST.json) records final ZIP/executable hashes, size, CRC check and runtime source. Binary is unsigned. A macOS package was not exported because the local template is absent; no native Mac/Intel/arm64 pass is claimed. No remote binary release is claimed and no unmerged CI infrastructure was relied on.

## H. Risks and limitations

- Discrete0.65s loading remains; this is a concise graphical wipe and safe carry, not streaming.
- A0.75s safety cooldown and96px inward rearm intentionally prevent instant reverse bounce. Wait about one second after load/arrival before returning; creator should evaluate this feel.
- Locked grille artwork communicates semantic denial but is not newly added solid collision; original geometry is untouched. Walking around it cannot grant travel/progression flags.
- Culvert/special architecture and graphic panels are procedural Kaze-original prototype art; finished environmental assets and global vocabulary are not approved.
- Full continuous campaign, maximum released-swing landing sweeps, broad performance certification and native macOS playtesting remain pending.
- No normal personal save path is used by included launchers after the explicit override; opening the executable directly uses ordinary game behavior. Use the provided launchers for comparison.

## I. Creator comparison test

1. Unzip the Windows package. Open `Play-walk-plain.cmd`, `Play-walk-graphic.cmd` and `Play-walk-reduced.cmd` to compare identical seeded starting progress in separate profiles. Wait one second, then hold D through the large culvert; do not press E. It should arrive in Root Shrine with forward x motion.
2. Move at least96px right inside Root Shrine, wait a beat, then move left across the passage to return. Try running/dashing, then approaching backward or above the threshold. No automatic proximity jump should occur.
3. Use `Play-stair-graphic.cmd`; press E beside R14's upper stairwell. Confirm its original appearance and return semantics. Hold E through the transition: it must not bounce back.
4. Use `Play-special-graphic.cmd` and its plain/reduced counterparts. E operates the already-unlocked junction wind-fold; return from Mooring Loft. This is explicitly seeded QA progress, not a newly granted travel ability.
5. `Play-fresh-graphic.cmd` is a separate unseeded campaign. The main movement/progression remains ordinary; optional momentum defaults off and seeded profiles start at Stride tier0. Existing element/story locks still apply to earned saves.
6. Report preferred graphic intensity, destination-title readability, passage/rearm feel, stairwell readability and any unwanted activation/landing issue. GIF previews let the creator review visuals before a Mac package becomes available.

## J. Next approval and final verdict

PM/creator should choose plain versus original graphic intensity, accept/revise the directional passage cooldown and decide whether the three pilot contexts fit the world. Then assign native Mac packaging and further playtest/performance QA as appropriate.

Separate [TR02_MULTILEVEL_EXIT_DESIGN.md](../level_design/alpha061/TR02_MULTILEVEL_EXIT_DESIGN.md) depicts upper roof and lower canal branches, reciprocal arrivals, gating and map ports. It is design-only; no new topology/collision/map state was implemented. Additional same-wall exits require explicit approval and future edge-ID support.

**READY FOR PM REVIEW** — all three modes are comparable in the actual source and corrected Windows prototype; relevant gates, arrivals, saves, isolated fixtures and QA pass. This does not authorize merge, integration, global rollout or release acceptance.
