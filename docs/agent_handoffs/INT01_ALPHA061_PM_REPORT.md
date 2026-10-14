# KAZE — PROJECT MANAGEMENT RETURN REPORT
# INT-01-0061

Date: October 14, 2026 (America/New_York). Specialist: Integration, Build & QA.

## A. Executive summary

**READY FOR PM REVIEW**, with bounded acceptance and the verification gaps below. Constructed a separate Alpha 0.6.1 combined review candidate, merging Gameplay PR #8 first and Level Design PR #9 second. Neither shared integration nor main was merged or pushed. Both specialist branches and PRs remain intact. Movement equations, floatiness, dash impulse/timing, swing integration, sprite image bytes/scales/anchors, save identity and progression architecture were preserved.

Godot 4.6.1 on Apple Silicon macOS completed import, baseline verification, all 15 current regression suites and new combined probes: **691 executed PASS assertions, zero assertion failures, zero script/parser errors**. Engine diagnostics remain documented; this is not a claim of zero engine error lines. Windows x86_64 and universal macOS candidate ZIPs were exported. Final macOS package booted headlessly and with native graphics. Windows boot and Intel macOS execution remain NOT TESTED. Human feel acceptance and full continuous campaign traversal remain pending.

## B. Verified inputs and provenance

Assignment read in full before integration from exact commit `945266c643f764824e3b85135cc37a5744bcbf8e`, path `docs/agent_assignments/INT01_ALPHA061_COMBINED_INTEGRATION_ASSIGNMENT.md` (blob `abde276a022f10c4ac29fc34d9d1ee70168b36f9`). Its documentation branch matched that commit.

| Input | Verified SHA |
| --- | --- |
| Shared integration `integration/alpha-0.6-world-momentum` | `34be30436996284ec2f783269c40269d321ed427` |
| Gameplay PR #8 / feature branch | `70a0a83bd6076c9c711a43bcaafb3c79a8ad20a2` |
| Level Design PR #9 / design branch | `a4926e9f0667168f390ab99279efe3243055aa3f` |
| main | `1a33d283a3781ba7068f86b43d4197f28f063939` |

Verified via remote heads, PR head refs and GitHub PR metadata. No input had advanced from the assignment. Candidate branch was absent and created from the verified integration head. The existing art checkout was dirty and deliberately left intact; a separate clean checkout was used at `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/int01-alpha061`. Nothing under synced `sources/` was edited.

Executable: `/Applications/Godot.app/Contents/MacOS/Godot`, version `4.6.1.stable.official.14d19694e`. Host architecture arm64; native renderer identified Apple M4, OpenGL 4.1 Metal compatibility. Export templates were initially absent; downloaded the official Godot 4.6.1 template archive into `/private/tmp/int01-godot-4.6.1-templates.tpz`, extracting only needed templates under ignored `build/int01/export-home/Library/Application Support/Godot/export_templates/4.6.1.stable`. No Windows/Wine runtime was found.

## C. Integration strategy, conflict resolutions and changes

Auditable no-fast-forward history:

1. `14d61921e4a508bb0c0beda018d47fc8ff7edacd`: parents integration `34be304` and reviewed Gameplay `70a0a83`.
2. `a34f802117dd7317cccc5b91723e6e8e847d14cc`: parents Gameplay merge `14d6192` and reviewed Level Design `a4926e9`.
3. `a82a83b97e65ab3a8ed912f01e490eabce42289e`: new combined/save/descent tests, reproducible QA runner, review-candidate version metadata, Windows labeling and universal macOS preset.
4. **Build source `847d3e57bcc1561a8d0fbb431a104703355ade03`**: exclude `build/*`, `tests/*`, `docs/*`, `tools/*` from exports. Later handoff commits contain documentation only.

Git merged `scripts/world.gd` automatically with no textual conflict. This was explicitly reviewed, not accepted blindly:

- Relative to Gameplay head, its only world changes are the `RoomPresentation` preload, `RoomPresentation.draw_background(self)` before platforms, and delegation of `draw_door` to `RoomPresentation.draw_exit`. All Gameplay saved-field filtering, MetSys normalization, fresh collection reset and earned-state restoration remain.
- Relative to Level Design head, its only world changes are Gameplay's save normalization helpers and `load_progress`/`restore_metsys_save` edits. All Level Design drawing hooks remain.
- `player.gd`, `kunai.gd`, and `assets/web/kaze_manifest.json` exactly match Gameplay head. The controller's intentional four-line change releases rope before dash and rejects attachment during dash; constants and integration are unchanged. The manifest preserves the reviewed controller checksum.
- `world_expansion.gd` and `room_presentation.gd` exactly match Level Design head. R14/R15/R17/R19 shelves and noninteractive architecture are retained. Portal endpoints and gates are unchanged. Global compact exits preserve existing interaction code/radii (85px expansion, 105px original rooms).
- No character/environment art was dropped or changed; the only asset-path diff is the reviewed manifest. The original eight-room collision contract passes. Optional momentum code is unchanged.
- New `integration_candidate.gd` explicitly combines sparse-save loading with refined layouts and compact-door gate/radius behavior. `integration_descent.gd` checks missed shelves under ordinary, Stride and optional-momentum settings plus vent phases. `integration_profile.gd` checks real default-path save/reload in separate processes. No controller tuning was introduced.

An initial packaging pass included generated capture resources because the inherited export preset did not exclude `build/`. The final preset fixes this. Both final PCK directory tables were inspected: **527 entries each, zero build/test/doc/tool entries**. Only final archives in BUILD_MANIFEST are handed off.

## D. Acceptance checklist

| Requirement | Status | Evidence / limit |
| --- | --- | --- |
| 1. GP kunai, save, dash/tether fixes | PASS | Exact reviewed files; stabilization 16 and transition 8 assertions |
| 2. LD four rooms, environmental cues, compact exits | PASS | Exact reviewed files; 54 native exit captures across all 21 rooms |
| 3. No unintended controller/sprite change | PASS | Baseline verifier, 32 baseline, 53 movement, 43 sprite assertions; exact specialist comparison |
| 4. Available merged regressions | PASS | All 15 existing suites, 646 PASS assertions; additional 45 PASS checks |
| 5. Fresh/upgraded save and reload | PASS (bounded) | Legacy/malformed suites; separate fresh prepare/reload processes; no creator save accessed |
| 6. Critical routes/gates/exits | PARTIAL | Seeded reciprocal arrivals, gate rejection, forward/reverse local collision probes pass; continuous campaign not completed |
| 7. Natural descent/missed landing/returns at normal zoom | PARTIAL | 12 seeded missed-shelf falls, 56 reverse-suite assertions, 125 forward-suite assertions and visual exits; human navigation/feel pending |
| 8. Packaged Windows integrity and launch | PARTIAL | Export, x86_64 PE, embedded PCK and ZIP CRC pass; Windows boot NOT TESTED |
| 9. Native 60 FPS rendering | PARTIAL | Actual native draw intervals measured; averages exceed 60 FPS, but spikes exceed 16.67ms; no sustained campaign guarantee |
| 10. Exact GitHub source/report/draft PR, protected branches unchanged | PASS on publication | Candidate-only publication; final branch/report/PR references below and in final chat return |
| Additional macOS candidate | PASS (Apple Silicon bounded) | Universal export, ZIP CRC, headless 180-frame boot and native 360-frame boot; Intel untested, unsigned/not notarized |

## E. QA results and reproduction

The final reproducible run executed 21 processes: import, verifier, 17 named suites and two save-profile stages. It produced **691 PASS lines**, zero FAIL lines, zero script/parser/load errors, and successful process exits. Totals count assertions actually executed in this run; overlapping coverage across suites is included and historical totals are not added. Movement's differential frame comparisons are not inflated into separate printed assertions.

| Existing suite | PASS assertions |
| --- | ---: |
| approved_baseline | 32 |
| approved_combat_swing | 7 |
| annex_expansion | 34 |
| annex_traversal | 6 |
| save_compatibility | 11 |
| skyworks_progression | 33 |
| storm_keeper | 12 |
| movement_momentum | 53 |
| sprite_integration | 43 |
| world_expansion | 193 |
| expansion_gates_save | 17 |
| expansion_traversal | 125 |
| gameplay_stabilization | 16 |
| traversal_transitions | 8 |
| world_cohesion_traversal | 56 |
| **Existing total** | **646** |
| integration_candidate | 12 |
| integration_descent | 26 |
| profile_prepare + profile_reload | 2 + 5 |
| **Combined total** | **691** |

Reproduce on macOS from repository root:

```sh
python3 tools/run_int01_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot
```

The runner records full command arrays, duration, return code, counts, diagnostics and absolute HOME paths to `build/int01/logs/int01_reproduction_results.json`; a committed snapshot is `INT01_ALPHA061_TEST_RESULTS.json`. Every engine suite uses `--headless --path <checkout> --script res://tests/<suite>.gd -- --test`; only descent adds `--fixed-fps 60`. Save-profile prepare/reload deliberately omit `--test`, use the real default save filename, and share one newly created isolated HOME. Exact paths appear in the JSON and profile logs. `HOME` isolation was verified with `OS.get_user_data_dir()` on this Mac; it is not a claim about Windows isolation. The baseline verifier separately validates four sprite sheets/controller preservation.

Warnings/attempted failures: the sandboxed native renderer aborted with exit 134 before rendering. The authorized native run outside that sandbox succeeded. Twenty engine processes in the reproducible run emitted macOS `get_system_ca_certificates` errors under isolated HOME. Import/export shutdown logs contain CanvasItem, dummy texture, font/shaped-text RID and ObjectDB leak diagnostics. These are retained in raw logs and not hidden as passes. They did not cause suite/script failures. A Python bytecode-cache write attempt was denied outside the workspace; syntax was subsequently checked in memory. A release-executable external-script pack-inspection attempt timed out at 30 seconds; the final resource audit instead parsed both PCK directory tables directly and passed. Neither failed diagnostic attempt is counted as a successful test.

Native visual QA used 1280×720 and unchanged zoom `(1,1)`, with 54 exit screenshots across all 21 rooms. Contact sheets `int01_evidence/exits_0.jpg` through `exits_2.jpg` cover original rooms and refined rooms. Individual full-resolution captures remain under ignored `build/int01/captures`. Inspected compact housings/E cues, destination labels and separation from HUD; backgrounds render below platforms and HUD remains readable. Frozen/seeded captures do not prove live combat-effect visibility in every situation. Global room titles and long destination text still merit human navigation review.

Actual renderer samples (120 post-draw intervals after 30 warm-up frames each; world/enemy physics frozen, camera normal; Apple M4/OpenGL compatibility):

| Room | Mean ms | p95 ms | Max ms | Derived average FPS |
| --- | ---: | ---: | ---: | ---: |
| Haven 0 | 8.596 | 10.059 | 36.753 | 116.33 |
| Bellroof 14 | 8.327 | 9.789 | 10.037 | 120.09 |
| Lower Sluice 15 | 9.654 | 19.478 | 41.768 | 103.59 |
| Counterweight 17 | 8.333 | 9.815 | 10.622 | 120.01 |
| Coil 19 | 8.343 | 9.957 | 10.308 | 119.85 |

These measure real presentation intervals, not GPU-only execution. The counter sampled at the final draw signal reports 119 completed frames for 120 signal intervals; no claim of 120 independent benchmark frames beyond those intervals. VSync/display refresh and concurrent processes may affect results. The final packaged native startup separately printed 121 FPS (8.26ms). Lower Sluice spikes and occasional Haven spikes mean steady 60 FPS is not accepted.

Continuous-route attempt: a fresh isolated process ran 6,000 actual physics ticks (100 simulated seconds with fixed 60fps), no granted abilities and no teleports. It walked Haven→Lantern Market, repeatedly died before defeating the guard and respawned at Haven; ended without Windstep, tether or dash. This incomplete automation is not evidence of a softlock or of campaign success. Milestones after that remain supported by local seeded tests only. Authentic continuous campaign and human feel acceptance are still required.

## F. Builds, packaging and access

**Build source:** `847d3e57bcc1561a8d0fbb431a104703355ade03`. Official matching release templates; Windows has embedded PCK, macOS universal has separate PCK. Both ZIP CRC checks pass; both resource directory audits pass. No personal profiles or save data are included. Builds have candidate labels, controls, exact source SHA and fresh/existing-save instructions.

Exact validated artifacts live on the current Mac/session, **not on GitHub Releases**:

- `build/int01/artifacts/Kaze-Alpha-0.6.1-Combined-GP-LD-Windows.zip`: **51,148,764 bytes**; SHA-256 `b384a6c43678108d7ffdd9beaa029359becdc259a52b50e2c4a19fd57b8353c7`.
- `build/int01/artifacts/Kaze-Alpha-0.6.1-Combined-GP-LD-macOS-Universal.zip`: **75,946,454 bytes**; SHA-256 `197c345d6c76d47cad6ff08c37fa672d0e897a0b2d6034d733353e8e2b6665cd`.

Prefix for those paths: `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/int01-alpha061/`. Component hashes/sizes are committed in `int01_evidence/BUILD_MANIFEST.json`. GitHub binary-upload/release-creation tools and gh CLI were unavailable, so no remote binary download URL is claimed. Source/QA/report publication is independent of that limitation.

Exports reproduced with the isolated template HOME:

```sh
HOME="$PWD/build/int01/export-home" /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release 'Windows Desktop' build/windows/Kaze-Alpha-0.6.1-Combined-GP-LD.exe
HOME="$PWD/build/int01/export-home" /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release macOS build/macos/Kaze-Alpha-0.6.1-Combined-GP-LD-final.zip
```

Raw logs, exact packaging code and renderer/capture/route-attempt scripts are preserved under `int01_evidence` as `.txt` references. The final macOS executable ran `--headless --quit-after 180 -- --test` successfully and `--quit-after 360 --print-fps -- --test` with native graphics successfully, each under separate isolated HOME. Windows lacks an executable runtime in this environment; no startup claim. Linux execution was not available/tested.

## G. GitHub publication

Candidate branch: `integration/candidate-alpha-0.6.1-gp-ld`.

Source: https://github.com/cappy2yappy/momentum-fractured/commit/847d3e57bcc1561a8d0fbb431a104703355ade03

Report: https://github.com/cappy2yappy/momentum-fractured/blob/integration/candidate-alpha-0.6.1-gp-ld/docs/agent_handoffs/INT01_ALPHA061_PM_REPORT.md

Results: https://github.com/cappy2yappy/momentum-fractured/blob/integration/candidate-alpha-0.6.1-gp-ld/docs/agent_handoffs/INT01_ALPHA061_TEST_RESULTS.json

Publication verification and draft PR URL are appended after push below. Local source branch contains both reviewed heads as ancestors. No specialist branch force push, PR closure, shared integration push, release publication or main merge was performed.

## H. Risks, blockers and missing verification

No integration/export blocker remains. Acceptance gaps: Windows native launch/feel; Intel macOS launch; signed/notarized macOS distribution; full unseeded campaign; human navigation/feel with ordinary, Stride and momentum modes; sustained live 60 FPS; rendering effects under full combat load. Remaining shutdown/certificate diagnostics and frame spikes need triage if PM treats them as acceptance blockers. The fresh-route bot failed to defeat the guard and therefore cannot certify major unlock continuity. None of these gaps was papered over with seeded tests or inherited counts.

## I. Creator playtest instructions

1. On this Mac, extract the macOS universal ZIP to a writable folder. Use **Play Isolated.command** to keep test saves in `playtest-profile` beside the launcher, leaving normal creator saves intact. It persists that test profile across runs. Verify Haven, three HP and no unlocked traversal kit before beginning. The app is unsigned/not notarized; if macOS blocks it, review/approve this specific candidate according to local security policy.
2. For existing-save playtesting, back up the normal Godot userdata directory first, then open the `.app` normally. Intentional save identity: `~/Library/Application Support/Godot/app_userdata/Kaze — Silent District Alpha 0.5.0`; save file `silent_district_alpha_v3.json`. Keep the original backup unchanged. Do not delete creator saves to force a fresh campaign.
3. Windows: extract ZIP and launch EXE. For safe fresh-save testing use a separate disposable Windows user account; for existing-save testing back up `%APPDATA%\Godot\app_userdata\Kaze — Silent District Alpha 0.5.0` first. No unverified APPDATA-remapping launcher is supplied.
4. Controls are in each README. Check ordinary movement/floatiness and sprite proportions first; play guard→Windstep→Wind seal→tether→dash→Warden→Archive→sigils→regional elemental gates. Review R14/R15/R17/R19 forward and backward, deliberately miss shelves, use ordinary-zoom doors, test gate rejection and returns, checkpoint/save/reload. Earn Stride I in Mooring Loft; optionally launch the isolated script with `--momentum-prototype` for the prototype. Record separate feedback for each mode.
5. Return crashes, stuck positions, room/exit identifiers, ability kit, save/profile type and movement/sprite feedback to PM. Retain source/build hashes with the feedback.

## J. PM decisions and next actions

Review the combined diff and evidence; arrange creator macOS playtesting and Windows native startup testing. Decide whether observed frame spikes and shutdown diagnostics block subsequent acceptance. Have the creator assess guard encounter progression and the full continuous campaign; adjust the automation only as a testing follow-up, not by changing approved movement. Decide whether remote artifact hosting and signed macOS distribution are needed. Any speed/expressiveness request in inherited creator feedback remains a separate PM decision and was not implemented here. Only after review and creator acceptance should PM authorize a later mainline integration; this work order does not authorize it.

## K. Final verdict

**READY FOR PM REVIEW** — combined candidate, source, tests, evidence and both platform exports delivered for review. **Not approved for mainline integration or release.** Creator transports this report to the existing Project Management chat.
