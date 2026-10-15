# INT-TR03 / ART-04 — Build Shogun Return

Date: October 15, 2026 (America/New_York).
Verdict: **READY FOR CREATOR / PM REVIEW. Downloadable comparison builds verified. No merge or public production release.**

## Exact source and recovered infrastructure

Recovered BUILD03 [PR #20](https://github.com/cappy2yappy/momentum-fractured/pull/20), branch `ci/build03-tr02-playtest`, head `3d6610bc67dad56111ac66f3aedc2b684c78ba79`. This work extends that infrastructure on **`ci/build-int-tr03-art04`**, [draft build PR #32](https://github.com/cappy2yappy/momentum-fractured/pull/32); it does not restart CI02 or merge gameplay history.

- **Actual exported runtime/art:** [`e91e49caeada21baad5ab25e5080e67ab16a4094`](https://github.com/cappy2yappy/momentum-fractured/commit/e91e49caeada21baad5ab25e5080e67ab16a4094), `integration/int-tr03-art04-production`, [PR #31](https://github.com/cappy2yappy/momentum-fractured/pull/31).
- Foundation: PR #27 `c2c002267c58e991966c0eebf7e098c6e7fff769`. ART04 delivery: PR #30 `a6b76b9938825307bdcd4efb687c7198ea0d8681`.
- Given docs checkpoint `3efdd2f9312cff37d4843ed109a2cbec417f5d01` has the same runtime. Latest observed PR31 head `c2c6b08bfb3b85ad174dcc7ef60bddf1a3a48c15` also has no changes to scripts/scenes/assets/world/project/export presets relative to the pin; its documentation/CHANGELOG and repeat-run QA profile fix are not substituted for the exact requested source.
- **Tested CI controls:** [`ffda93c7ae92b5ed90dabbef6a1ffe7bb1c32f25`](https://github.com/cappy2yappy/momentum-fractured/commit/ffda93c7ae92b5ed90dabbef6a1ffe7bb1c32f25).
- **Successful hosted run:** [38811061838](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838).

Dedicated checkout: `work/build-int-tr03-art04`. The integration owner's `work/int-tr03-art04-live` checkout was untouched. PR20/PR27/PR31 remain unmerged and their shared branches were not changed by this build task. Source checkout identity is explicitly asserted against the pin. No gameplay, physics, collision/geometry, progression, save identity, character asset or 0.65s loader change was made. Final report publication adds documentation only after the tested controls.

## Downloads — use these comparison archives

Sign into GitHub if required. Download/extract the outer artifact ZIP, then extract the inner game ZIP. No creator-side Godot compilation is required.

| Platform | Final comparison artifact | Inner game ZIP bytes | Inner game ZIP SHA-256 |
| --- | --- | ---: | --- |
| Windows x86_64 | [Download Windows comparisons](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12008448895) | 52,125,393 | `3a48edaee49b626e72ab4e10de79faaa11bdac35b1c72edb079df1aa313cc81e` |
| macOS universal | [Download macOS comparisons](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12009016928) | 76,902,488 | `600720aed0e34fe835071197e3a74e836c0fe842237638993e0374d56dae4e55` |

Inner filenames:
- `Kaze-INT-TR03-ART04-Windows-x86_64-e91e49ca.zip`
- `Kaze-INT-TR03-ART04-macOS-Universal-e91e49ca.zip`

Windows comparison artifact expires **2026-11-05T21:41:38Z**; macOS comparison artifact expires **2026-11-05T21:44:56Z**. These are UTC timestamps, November 5, 2026. Inner ZIP hashes differ from GitHub's outer artifact hashes; both layers were independently verified. Manifests, source IDs, engine/template provenance and member SHA-256s are included alongside the inner game ZIP. The source recipe's smaller manifest is also retained inside it.

**The separate `Kaze-macOS-e91e49ca` artifact is an export intermediate, without the 45 comparison launchers.** Use the final `Kaze-INT-TR03-ART04-macOS-Universal-e91e49ca` link above for creator comparison review.

## How the packages were produced

CI02/BUILD03's checksum-pinned Godot **4.6.1.stable.official.14d19694e** and matching templates are reused. Linux editor archive SHA-256: `cecd0cb6b55e931318a9d7237dc4197d69ea914966787a454808523626e2789f`; template archive SHA-256: `e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875`.

The existing Windows Desktop embedded-PCK/x86_64 and macOS universal unsigned/unnotarized presets are used without changes. The workflow explicitly allowlists/pins the integration; CI controls and game source are separate checkouts. Full Git history is available to the source verifiers so their PR27/ART04/TR02 baseline objects can be checked. No unapproved specialist branch is combined.

The exact committed `tools/package_int_tr03_art04.py` recipe creates nine pilots × five comparison launchers. Windows packaging runs after Linux export; macOS packaging uses the recipe's `ditto` path on the native Mac runner. The wrapper adds optional bounded headless/logging arguments to generated Windows launchers and forwards them through the actual `.cmd` entry points; normal interactive launcher behavior and the game binary are unchanged. Both platform packages contain 45 entry launchers. Each comparison has a separate explicit absolute save path under its extracted package, and targeted fixtures seed QA progression on first launch only.

Only workflow/tools/ci changes were added relative to BUILD03: the target/pin, full integration QA adapter, comparison package wrapper, direct-launcher validator, and source_art exclusion audit. The six implementation files are listed in the structured evidence. This report and its JSON are the final documentation additions. Main/shared integration/PR27/PR31/PR20 were not merged or updated.

## Actual test and verification evidence

| Validation | Observed result |
| --- | --- |
| Hosted full source batch | **1,158 passing checks**, 29 actions, 21 behavioral suites plus preservation/profile/endpoint actions |
| Five CLI comparisons, including save paths with spaces | **21 passing checks**; original/refined/art-preview/reduced/plain |
| Combined hosted checks | **1,179 passes**, zero failed assertions, script/parser/load failures or hard errors |
| Export/package CRC and actual PCK audits | Passed; **567 hash-verified entries per platform**, required ART04 and world data present |
| Native Windows AMD64 | Actual downloaded release ordinary startup + **45/45 `.cmd` launcher boots passed** |
| Native Intel macOS | Actual release ordinary startup + **45/45 `.command` launcher boots passed** |
| Native arm64 macOS | **The exact final hosted Mac archive was downloaded**, ordinary startup and **45/45 launchers passed locally** |
| Download integrity | All six hosted artifacts downloaded; outer SHA-256, CRC, inner ZIP/member hashes, Windows AMD64 PE header and macOS Intel+arm64 universal header verified |
| Save/path boundary | Actual launcher/package/script/log paths contain spaces; isolated profile creation and 45 native engine logs per hosted platform verified |

Hosted jobs: [QA/export](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/job/116684508582), [Windows native](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/job/116686632735), [Intel macOS native](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/job/116686632705). The promotion-only legacy candidate job is intentionally skipped for this branch; the pinned integration's complete suite runs in the primary job.

Native checks execute the **actual release launcher files**, not equivalent synthetic commands. They check bounded process exit, engine errors/banner, profile creation and spaced paths. Comparison/save identity is separately asserted by the source CLI tests. **Native release memory state, interactive transition feel and sustained frame rate are not inferred from these checks.** Normal main-scene startup is tested separately from fixture launches.

The arm64 check used the hosted Mac ZIP hash `600720aed0e34fe835071197e3a74e836c0fe842237638993e0374d56dae4e55`; it is not merely a source run or a local cross-export substitute. The integration team's separate graphical/UI checks and bounded FPS samples remain independently attributed in PR31's evidence; they are not new human/performance acceptance performed by this build task.

Individual hosted action counts:

| Action | Pass checks | Exit | Result |
| --- | ---: | ---: | --- |
| import_warmup | 0 | 0 | Diagnostic import |
| import | 0 | 0 | Passed |
| verify_baseline | 0 | 0 | Passed |
| verify_tr03_preservation | 32 | 0 | Passed |
| verify_art04_assets | 42 | 0 | Passed |
| approved_baseline | 32 | 0 | Passed |
| approved_combat_swing | 7 | 0 | Passed |
| annex_expansion | 34 | 0 | Passed |
| annex_traversal | 6 | 0 | Passed |
| save_compatibility | 11 | 0 | Passed |
| skyworks_progression | 33 | 0 | Passed |
| storm_keeper | 12 | 0 | Passed |
| movement_momentum | 53 | 0 | Passed |
| sprite_integration | 43 | 0 | Passed |
| world_expansion | 193 | 0 | Passed |
| expansion_gates_save | 17 | 0 | Passed |
| expansion_traversal | 125 | 0 | Passed |
| gameplay_stabilization | 16 | 0 | Passed |
| traversal_transitions | 8 | 0 | Passed |
| world_cohesion_traversal | 56 | 0 | Passed |
| integration_candidate | 12 | 0 | Passed |
| integration_descent | 26 | 0 | Passed |
| room_transition_prototype | 93 | 0 | Passed |
| mixed_transitions | 109 | 0 | Passed |
| embodied_transitions | 80 | 0 | Passed |
| art04_transitions | 111 | 0 | Passed |
| profile_prepare | 2 | 0 | Passed |
| profile_reload | 5 | 0 | Passed |
| endpoint_audit | 0 | 0 | Passed |
| cli_original | 4 | 0 | Passed |
| cli_refined | 4 | 0 | Passed |
| cli_art-preview | 4 | 0 | Passed |
| cli_reduced | 5 | 0 | Passed |
| cli_plain | 4 | 0 | Passed |

Known narrowly classified editor/engine shutdown diagnostics remain in raw logs. In this accepted run even import warmup had zero script/hard errors; settled import and all required tests passed. No warnings were blanket-suppressed.

## Failures and recovery boundaries

The initial local batch lacked the pinned ART04 Git object when its verifier ran: the other 1,116 checks passed, that action failed. After fetching the object, the unchanged verifier independently passed all 42 checks. This was not claimed as a single green local batch. The accepted hosted batch had complete history and passed all 1,158 source checks in one run.

A native external-observer experiment produced no validation signal from the release; its results were rejected. That execution was removed from the acceptance test in favor of direct release startup/profile/log checks, with identity covered by the explicit source CLI suite. Superseded run [38810315952](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38810315952) was cancelled and is not delivery evidence. The revised run above is green. No source was modified to make tests pass.

## All artifact references and reproducibility

| Artifact | Outer archive bytes | Expiry UTC |
| --- | ---: | --- |
| [Kaze-Native-Smoke-Windows-x86_64-e91e49ca](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12009500197) | 22,516 | 2026-11-05T21:44:11Z |
| [Kaze-INT-TR03-ART04-macOS-Universal-e91e49ca](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12009016928) | 76,619,134 | 2026-11-05T21:44:56Z |
| [Kaze-Native-Smoke-macOS-e91e49ca](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12008737744) | 25,573 | 2026-11-05T21:45:03Z |
| [Kaze-Windows-x86_64-e91e49ca](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12008448895) | 51,972,173 | 2026-11-05T21:41:38Z |
| [Kaze-macOS-e91e49ca](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12008339028) | 76,592,661 | 2026-11-05T21:41:41Z |
| [Kaze-QA-Results-e91e49ca](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38811061838/artifacts/12008339008) | 66,154 | 2026-11-05T21:41:37Z |

[Machine-readable verification](INT_TR03_ART04_BUILD_VERIFICATION.json) includes full manifests, outer/inner/member hashes, individual source/native outcomes, source/controls IDs and all 135 accepted launcher outcomes (90 hosted + 45 local arm64 on the downloaded archive). Raw hosted logs retain full job paths; committed outcome rows record path shape/space/absolute checks without publishing the creator's local workspace path.

Published game PCKs exclude build/tests/docs/tools/source_art; game ZIPs contain no profiles, personal saves or QA logs. Fixtures embedded in launchers are explicit QA defaults, not creator progress. Artifact uploads include only intended package/manifests or selected report/log paths. The raw Mac export is retained for native-job reruns; the comparison artifact is the delivery. Retention is 21 days. Read-only workflow token, no persisted checkout credentials, no new secrets, no repository security changes, no signing/notarization and no public release/tag creation. Existing action runtime notices remain maintenance items; bounded jobs/concurrency and expiring storage remain in place.

To reproduce, use PR32's exact tested controls and the pinned source selection, in fresh disposable checkouts, then observe all QA/export/native jobs. Do not repoint to a moving integration head or substitute the older BUILD03 TR02 artifacts. Original e91's source runner reuses its restart profile; use a fresh output/profile tree for local repeat runs. The later integration QA-only fix uses a unique restart name, but was deliberately not substituted into this pinned build. Manual selection on the new build controls is configured; this task's proof is actual PR execution, not a claim that this unmerged option has been promoted onto main's manual UI.

## Creator comparison instructions and remaining gates

1. Extract both ZIP layers to a writable folder. Verify the inner game SHA-256 above with `Get-FileHash` on Windows or `shasum -a 256` on Mac.
2. Start **Play-stair-up-art-preview.cmd** on Windows or **Play-stair-up-art-preview.command** on Mac. Use E at the stairwell, then compare the same pilot in refined and original modes.
3. Review stair-down, depth, reverse-depth, passage, special and structure14/15 pilots. Compare reduced and plain. `Play-fresh-*` starts unseeded Haven in its own test save.
4. Targeted pilots seed traversal/progression **on first launch only** as QA fixtures. Modes have separate persistent test saves. To reseed later, close the game and remove only the relevant extracted package's profile folder, if desired.
5. Use the launchers for isolated review. Direct EXE/.app launch retains the normal historical save identity; back up normal saves before intentionally testing that path. Unsigned/unnotarized internal candidates may require the creator's normal OS opening approval.

**Four ART04 held keys are not completed animation cycles.** Unsupported outward/opposite-arrival facings remain labelled approved-idle fallbacks; no reversed rear art or completed-cycle claim is introduced. R17 art remains clipped at the existing boundary. Physics, save/progression/collision and the existing loader remain as the approved integration implements them.

Remaining creator/PM gates: human feel/readability/art acceptance, missing animation cycles/facings, broad campaign/gamepad/audio/graphics coverage and sustained 60 FPS stress testing. This task closes the automated packaging/native-launcher evidence gap only. Review PR32 infrastructure separately from PR27/PR31 gameplay/art. **Do not merge automatically.** No blocking platform limitation prevented this delivery.
