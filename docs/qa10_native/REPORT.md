# QA-10 — Native cinematic regression investigation

Executed 2026-10-23, Godot **4.6.1.stable.official.14d19694e**, macOS Apple M4, native OpenGL compatibility renderer. Lead: Codex, independent QA.

## Diagnosis

**The reproduced stationary-player failures are inherited native test-harness defects exposed by application focus events. A second inherited screenshot wait can time out after gameplay has passed. No new Studio gameplay regression was found.** Both failure mechanisms exist on PR #78 and PR #100. The correction changes tests and diagnostic tools only.

The immediate paused-tree mechanism and the unbounded capture wait are confirmed by native traces and controlled experiments. The historical CIN-TOOLS-03 logs did not record tree pause or draw counters, so the particular OS event behind every historical attempt cannot be reconstructed retrospectively. The exact compositor reason for withholding ordinary draws is also unresolved. These limits do not require a gameplay correction.

## References recovered before changes

| Reference | Exact inspected head |
| --- | --- |
| [Draft PR #100](https://github.com/cappy2yappy/momentum-fractured/pull/100) | `d227b038576fc5268acc4f94324fc5fbf64244a5` |
| [Draft PR #78](https://github.com/cappy2yappy/momentum-fractured/pull/78) | `af184380fb690f2c19bac69960b7aacce50f9ff2` |

PR #100 targets that exact PR #78 head. Published metadata and empty discussion were retrieved through GitHub; see [published_refs.json](published_refs.json). The first investigation reads were the published [QA report](../cin_tools_03/QA.md), [attempt metadata](../cin_tools_03/qa/rendered-attempt/results.json), and both raw failure logs at the pinned PR #100 commit. No speculative gameplay edit preceded them.

The historical attempt records Canal **0 PASS / 28 FAIL** and automatic passage **9 PASS / 57 FAIL**, both exit **124** at approximately **100 seconds**. Those commands used generated scripts under `build/cin_tools_01/qa/rendered`. The published CIN-TOOLS-03 reproduction runner now has a 120-second bound. Prefix counts from differently bounded runs are not complete-suite totals.

## Reproduced signatures and comparison

The first unchanged PR #100 documented native run passed all five selected suites, including Canal **53/0** and automatic passage **305/0**. This established intermittency; it did not resolve the reported failures. Its ten selected headless suites also passed **857/0**.

The complete unchanged PR #78 seven-suite rendered set was executed, followed by a strictly serial seven-suite run with passive observation. The first set passed both target gameplay suites but timed out in `native_cinematic_transitions` after 23 passes. Its last case briefly overlapped the beginning of an exploratory candidate run; retain that set as attempted evidence, not timing-isolated certification. The later serial baseline run has no rendered-process overlap.

| Unchanged game/test source, native run | Canal | Automatic passage | Native cinematics |
| --- | --- | --- | --- |
| PR #100, published historical attempt | 0 pass / 28 fail, timeout 100 s | 9 pass / 57 fail, timeout 100 s | not selected |
| PR #100, documented QA-10 replay | 53 pass / 0 fail, exit 0 | 305 pass / 0 fail, exit 0 | not selected |
| PR #100, exploratory passive trace | 3 pass / 50 fail, exit 1 | 10 pass / 72 fail, timeout 120 s | 54 pass / 0 fail |
| PR #78, strictly serial passive trace | 2 pass / 51 fail, exit 1 | 2 pass / 2 fail, timeout 120 s at capture | 54 pass / 0 fail |

The exploratory candidate matrix also contains observer setup errors in Studio/authoring (indentation and a missing `w` property); those rows are invalid as product evidence. The two target gameplay traces themselves have zero script errors. Their test bodies and assertions were unchanged, apart from disposable paths and observation hooks. Final matrices use the corrected observer. All attempts remain in the log archive.

The shared Canal failure state is exact: **R13 position `(330,1158)`, velocity `(0,0)`, floor false, player physics enabled, no transition ownership, no request, doorway unarmed**. The fresh automatic-passage state repeats **R0 `(220,1298)`**, and endpoint fixtures repeat **`(300,1198)`**, with zero velocity and unsupported floor state. These match the published failure shapes; assertion counts vary with progress and timeout.

## Confirmed pause mechanism

The candidate trace records an actual application/window focus-out notification after the first successful Canal case, before the next fixture's first physics step. In the following sample:

- `paused=true`, HUD `pause_open=true`, window focus false;
- player and world physics processing flags remain true;
- `player.can_process()` and `world.can_process()` are false;
- physical A, left action, and the player's held-left query are all true;
- player age remains zero, floor contact is never established, and the doorway is never armed.

Thus input reaches the engine and controller queries. The SceneTree prevents their physics callbacks from executing. A physics-enabled flag alone was insufficient telemetry.

Deleting the paused world does not unpause its SceneTree. The next world has a new closed HUD while inheriting `paused=true`; it cannot fall onto the floor or arm its doorway. This explains repeated stationary fixtures and why merely replacing the HUD or adding a focus warmup did not repair the state.

The existing `transition_test_hud.gd` inherits production `hud.gd` and overrides `_notification` to print that automation will continue. Godot invokes **every inherited `_notification` implementation**, so the production base still sets `paused=true`. The trace shows that misleading message alongside `hud_pause=true` and `paused=true`. This behavior is documented in [Godot 4.6 Object._notification](https://docs.godotengine.org/en/4.6/classes/class_object.html#class-object-private-method-notification).

An unchanged-PR78 native positive control passed **12 checks**: production focus pause, enabled-but-blocked physics, all three active input queries, exact stationary pose, unarmed trigger, base notification propagation despite the override, inherited pause across world replacement, and recovery of movement/floor/arming after normal resume. The same positive control passed headlessly. A later native repeat had **9 pass / 3 fail** when another real focus-out arrived between its resume steps; this is retained and explains why that deliberately unisolated historical control is excluded from final certification.

## Confirmed capture mechanism

Correcting pause alone produced a separate candidate attempt with **265 passing automatic-passage assertions, zero failures, and exit 124**. Its player/world continued processing with `paused=false` while the suite stopped producing assertions.

The serial original baseline trace locates the blocked coroutine: `QA10_SHOT begin tr06_jump_1-0_landed` has no matching end. Process/physics frames continue into the hundreds of thousands while ordinary drawn frames remain **433**, with `render_loop_enabled=true`, a visible normal-mode window, and no window focus. The inherited `shot()` waits forever for the next `frame_post_draw`; a process timeout was therefore not proof of a gameplay failure.

A native render control intentionally disables the regular render loop. The legacy wait stays pending over advancing process frames. `RenderingServer.force_draw(false)` releases its pending post-draw signal and produces readable viewport pixels, visually inspected locally. Godot documents [force_draw](https://docs.godotengine.org/en/4.6/classes/class_renderingserver.html#class-renderingserver-method-force-draw) as a main-thread viewport redraw. A first control incorrectly expected this manual draw to increment Engine's ordinary drawn-frame counter (2 pass / 1 fail); the direct signal/pixel control corrected that diagnostic assumption and passed 3/3. Both logs are retained.

The final capture contract also verifies the corrected helper while regular rendering is disabled: it completes and saves pixels without moving the frozen player.

## Minimal correction and preservation

1. A test-only HUD factory reads the current production HUD source and renames only its `_notification` callback to `simulated_notification`. This avoids the automatic base callback chain while preserving the entire handler body. Compilation and the exact source transform are checked. No copied production HUD implementation can drift silently.
2. The native/Canal/fresh-save harnesses install that HUD only at new-world construction. Inherited pause is cleared only at that boundary. Tick loops, input helpers and assertions never repair state.
3. Deliberate Canal focus interruptions call the preserved handler explicitly. All original 53 checks remain, with nine additional checks proving that those interruptions really pause processing. Existing Esc/map interruption cases and real `InputEventKey` approaches remain intact.
4. Native captures connect their post-draw observer before forcing one real GPU draw. They have a bounded wait and fail if no frame or saved pixels are obtained. No capture is silently skipped on the native path.

The final verifier confirms **609 production/resource files byte-identical to PR #100**, identical gameplay/routing/project/addon content between the two reference heads, and all **36 original assertion source lines** in the four edited tests intact. See [preservation log](preservation.log.txt) and [file hashes](preservation_manifest.json). Approved physics, Canon, Canal Doorway code, room routing, progression, saves, sprites and project settings were not changed. PR #100 and Alpha 0.6.1 Candidate 3 were not modified or merged.

The legacy `transition_test_hud.gd` remains available for the positive control. The separate `capture_pm_transition.gd` tool still uses it; that older capture workflow was not run or certified by QA-10. The corrected shared gameplay suites use the new factory.

## Final regression results

PR #78 final results use its exact game commit plus **the same four test edits and new HUD factory** as the candidate. This is an explicit test overlay, not a claim that unchanged PR #78 always passes. Original baseline failures are preserved separately.

| Native suite | PR #78 + harness correction | PR #100 + harness correction |
| --- | ---: | ---: |
| Studio workspace | unavailable on PR78 | 29 |
| Cut-In Maker authoring | 27 | 27 |
| Cut-In Maker runtime | 103 | 103 |
| TR-08 embodied cinematics | 226 | 226 |
| Canal hang regression | 62 | 62 |
| Stage labels | 9 | 9 |
| Automatic passage reliability | 309 | 309 |
| Native cinematic transitions | 90 | 90 |
| **Relevant rendered suite total** | **826** | **855** |
| Added automation/capture contracts | 16 | 16 |

Every final native row exits zero with **zero failed assertions and zero script errors**. Counts include all original assertions, nine added focus checks, and forty successful screenshot checks. The eight-suite candidate set and seven-suite baseline set run completely, serially and without overlap.

Headless: **33 existing suites, 2,453 pass / 0 fail / 0 script errors**; Studio **29/0**; lifecycle/automation controls **23/0**. Combined headless evidence: **2,505 passes**. The standard asset/controller verifier passes. The headless macOS system-CA warning remains in raw logs and is unrelated to these offline tests. Final rendered logs contain no runtime errors or leaked-resource warnings.

## Reproduction and evidence

The runner accepts either checkout with `--root`, uses fresh ignored per-suite directories, and records commands, source SHA-256, UTC start time, exit code and counts. Normal-save tests get a disposable `--tr05-save` and no `--test`; other suites use `--test`. It uses Python subprocess APIs and forward-slash Godot resource paths. Each label must be new to prevent evidence overwrite.

```sh
python3 tools/qa10_native/run_investigation.py --godot /Applications/Godot.app/Contents/MacOS/Godot --label native-review --observe --suites cin_tools_03/workspace cin_tools_01/authoring cin_tools_01/runtime tr08_embodied_cinematics tr08_canal_hang_regression tr08_stage_labels automatic_passage_reliability native_cinematic_transitions qa10_native/automation_contract qa10_native/render_capture
python3 tools/cin_tools_01/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot
python3 tools/qa10_native/verify_preservation.py
python3 tools/verify_baseline.py
```

On Windows, substitute the Godot 4.6.1 console executable path for `--godot`; these procedures were executed only on macOS. No Windows native or controller/export certification is claimed.

See [logs](logs), per-run `results.json`, and [log_manifest.json](log_manifest.json). Stdout captures merge stderr, retaining native renderer identification and script diagnostics. Large exploratory logs use lossless gzip; the manifest includes both compressed and original SHA-256/byte counts. To read one, use `python3 -c "import gzip,sys;sys.stdout.write(gzip.open(sys.argv[1],'rt').read())" <log.gz>`.

The sandbox initially aborted all native launches with exit -6 before renderer initialization. Those empty/aborted logs are retained separately; authorized native execution outside that sandbox initialized the renderer. A missing-save-path probe and observer development errors are also retained as invalid tooling attempts. No such result is counted as passing product validation.

PM acceptance and remaining work are in [HANDOFF.md](HANDOFF.md). Keep the investigation and its parent tooling PRs draft and unmerged.
