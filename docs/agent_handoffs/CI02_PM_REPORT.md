# KAZE PROJECT MANAGEMENT RETURN REPORT — CI-02

## A. Executive summary and verdict

**READY FOR PM REVIEW — infrastructure-only draft PR #14.** Two actual PR-triggered workflow runs completed green:

- [Main-target promotion run 38631729109](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109): main-derived import/startup, Windows x86_64 and Intel macOS exports/audits, Windows AMD64 and macOS x86_64 release startup, and separate candidate compatibility QA/export all passed.
- [Candidate-target verification run 38632031577](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577): full 17-suite candidate QA plus save prepare/reload (**691 assertions**), Windows/universal macOS exports/audits, and both native startup jobs passed.

All **13 artifacts were actually downloaded**. Outer GitHub SHA-256 digests, inner game ZIP/member SHA-256s, ZIP CRCs and actual PCK directories/content hashes were independently verified. Main packs contain 125 audited entries; candidate packs contain 527. Main has **zero regression suites**; it is not represented as having Alpha 0.6.1 regression coverage.

**Architecture exception for PM review:** unmodified historical main cannot export universal/arm64 macOS because its project lacks the ASTC texture-import setting. Its CI fallback is explicitly **Intel macOS x86_64**, verified on an Intel runner. Candidate universal exports remain intact. No project configuration or gameplay changes were introduced to force main universal export. This limitation and a separately approved upgrade path remain PM decisions.

No merge, direct push to main/integration, repository security change, release publication or PR #13 modification occurred. Manual dispatch UI is **not live before default-branch installation**.

## B. Authority, verified sources and branch ancestry

Read the [complete authoritative order at 257b0ee](https://github.com/cappy2yappy/momentum-fractured/blob/257b0eeadf9d0d38c355c3da37253813a7837478/docs/agent_assignments/CI02_SAFE_WORKFLOW_PROMOTION.md) before development.

- Main baseline, verified remotely at start and finish: [`1a33d283a3781ba7068f86b43d4197f28f063939`](https://github.com/cappy2yappy/momentum-fractured/commit/1a33d283a3781ba7068f86b43d4197f28f063939).
- Implementation branch: `ci/default-branch-godot-builds`; first implementation commit's parent is exactly that main SHA. No candidate history cherry-picked.
- Tested promotion source: [`aec292c4f23610ca542a50e69a66c35b904c009f`](https://github.com/cappy2yappy/momentum-fractured/commit/aec292c4f23610ca542a50e69a66c35b904c009f).
- Candidate baseline: [`afecef1922231081807a332c511de85c7941fec8`](https://github.com/cappy2yappy/momentum-fractured/commit/afecef1922231081807a332c511de85c7941fec8), independently checked out by the compatibility job and recorded in its manifests.
- Supplemental verification branch: `ci/ci02-candidate-workflow-proof`, parent exactly candidate baseline; tested source [`7f6633edf2a92a517b8687f612d65c30290684a6`](https://github.com/cappy2yappy/momentum-fractured/commit/7f6633edf2a92a517b8687f612d65c30290684a6). This branch copies only the same infrastructure files to prove the candidate PR event. Its seven workflow/helper/handbook files match the promotion commit byte-for-byte.
- [PR #13](https://github.com/cappy2yappy/momentum-fractured/pull/13) remains open/unmerged at `e0b70b6371342907fcaff1060e551ab3a6418860`; CI-01 [green evidence](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844) remains intact.

Main is an older MOMENTUM: FRACTURED project with main scene `scenes/rooms/room_01_combat.tscn`. It lacks `tests/`, `tools/run_int01_qa.py`, `tools/verify_baseline.py` and export_presets.cfg. It was not replaced by modern candidate gameplay.

## C. Scope/diff proof

[Draft promotion PR #14](https://github.com/cappy2yappy/momentum-fractured/pull/14) targets **main**. Seven implementation files are additions relative to main:

- `.github/workflows/godot-ci.yml`
- `tools/ci/install_godot.py`, `qa.py`, `package.py`, `native_smoke.py`, `negative_path.py`
- `docs/build/CI01_AUTOMATED_BUILD_HANDBOOK.md`

This report and `docs/agent_handoffs/CI02_TEST_RESULTS.json` are the only final documentation additions. Diff checks passed. No diff under scripts/, scenes/, assets/, tests/; no project.godot, export_presets.cfg, gameplay or old integration commit changes. Main/integration refs remain unchanged. Generated presets/templates/import caches/profiles/build outputs are disposable and not committed. Synced sources/ references and specialist checkouts were untouched.

[Draft verification PR #15](https://github.com/cappy2yappy/momentum-fractured/pull/15) targets the candidate and has only the same seven infrastructure files. **It is verification evidence, not a deployment/merge request.** Keep PRs #13/#14/#15 unmerged until the relevant explicit PM decision. The final report commit changes documentation only relative to the exact tested promotion source.

## D. Before/after workflow capability

| Source | Before CI-02 | Proposed infrastructure capability |
| --- | --- | --- |
| Main | No Godot CI workflow, regression runner or presets | Import + 120-frame headless main-scene startup; explicit zero-suite report; generated Windows/Intel macOS presets; source manifests; pack/ZIP audits; native startup reports |
| Candidate Alpha 0.6.1 | CI-01 infrastructure exists on unmerged PR #13, separate from candidate baseline | Adapted default controls can build approved candidate source with all 17 suites + save checks and unchanged Windows/universal macOS presets; real candidate-target PR event proven by #15 |
| Manual builds | Run workflow not installed on default | After separately approved merge: keep workflow branch main, select allowlisted game source_ref main or candidate; actual selected checkout SHA recorded |

Triggers include PR targets main and the approved candidate; docs-only changes are ignored. No push duplication. PR game checkout uses exact head SHA. CI controls use immutable `github.workflow_sha` independently of game source, allowing a candidate checkout without requiring its own CI helpers. Actual source identity is resolved from git and used in manifests, artifact names, and native verification.

A trigger filter on main does not rewrite candidate branch history. Candidate-target proof #15 explicitly contains the adapted workflow in its PR tree. Future candidate PRs should contain approved workflow infrastructure in their merge tree and be observed empirically; PM may authorize a separate infrastructure-only sync if needed. After default installation, manual candidate builds use controls from main and do not require a candidate infrastructure merge. No integration sync was performed here.

## E. Godot, templates, fallback behavior and failures

Pinned official engine: `4.6.1.stable.official.14d19694e`; templates: `4.6.1.stable`.

- Editor archive SHA-256: `cecd0cb6b55e931318a9d7237dc4197d69ea914966787a454808523626e2789f`.
- Template archive SHA-256: `e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875`.

The installer verifies official release digests/version. Main fallback presets are generated only in its disposable checkout. To preserve main's original project settings while exporting Intel macOS, the byte-exact x86_64 Mach-O slice from the verified official universal template is added to the disposable template archive; the universal template is preserved. Manifests disclose this derivation and fallback origin. Candidate presets/templates remain universal and unchanged. No override.cfg remains in the implementation or builds; no renderer/physics/save-identity override is used.

Sources labelled 0.6.1 or containing integration tests cannot fall back if mandatory runner/presets are absent. Unknown sources with tests but no recognized runner fail. Candidate failures/nonzero exits/missing assertions/results, parser/load errors and unrecognized ERROR lines fail QA; exact previously documented nonfatal engine teardown diagnostics remain visible. Main runs import/startup and reports unavailable regression/preservation checks explicitly. Export/package failure withholds game uploads; native failure makes the run red even if packages already exist.

**Actual earlier failure evidence:** [main job 116082355000](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631017554/job/116082355000) passed main QA but failed universal export with the missing ASTC setting, exit 1. The attempted temporary override did not satisfy editor export validation and was removed. Initial run 38631017554 and intermediate run 38631502235 were superseded/cancelled; they are not acceptance runs. A local Apple Silicon Intel launch failed with Bad CPU type because no Rosetta is installed; this prompted the explicit Intel hosted runner, not an OS modification.

Existing negative validator checks passed on hosted jobs. [CI-01's deliberate corrupt-pack red job](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625120369/job/116062527261) remains preserved evidence. Local tests of the actual manual guard passed 4/4: approved main and candidate accepted; a nonallowlisted ref and an unreviewed workflow branch rejected. These guard checks are not misrepresented as real workflow_dispatch execution.

## F. Actual QA and native results

| Execution | QA scope | Result |
| --- | --- | --- |
| Main-derived PR #14 | Import + main-scene startup; **0 regression suites / 0 assertions**; absent regression/verifier recorded | Passed |
| Candidate compatibility within #14 | Baseline verifier, 17 suites, save prepare/reload; **691 assertions** | Passed |
| Candidate PR #15 | Same complete candidate scope; **691 assertions** | Passed |
| Main Windows | Actual release EXE on Windows AMD64, headless 120 frames, isolated profile | Passed |
| Main macOS | Actual Intel release on macos-15-intel x86_64, headless 120 frames | Passed |
| Candidate Windows/macOS in #15 | Actual downloaded EXE/universal app on AMD64 and Intel x86_64 | Passed |

Individual candidate PR results (raw log commands/profiles remain in its QA download):

| Check | Assertions | Exit | Seconds | Result |
| --- | ---: | ---: | ---: | --- |
| import | 0 | 0 | 9.73 | Passed |
| verify_baseline | 0 | 0 | 0.04 | Passed |
| approved_baseline | 32 | 0 | 2.02 | Passed |
| approved_combat_swing | 7 | 0 | 0.43 | Passed |
| annex_expansion | 34 | 0 | 3.6 | Passed |
| annex_traversal | 6 | 0 | 8.71 | Passed |
| save_compatibility | 11 | 0 | 0.43 | Passed |
| skyworks_progression | 33 | 0 | 5.08 | Passed |
| storm_keeper | 12 | 0 | 0.54 | Passed |
| movement_momentum | 53 | 0 | 8.9 | Passed |
| sprite_integration | 43 | 0 | 0.53 | Passed |
| world_expansion | 193 | 0 | 4.34 | Passed |
| expansion_gates_save | 17 | 0 | 3.78 | Passed |
| expansion_traversal | 125 | 0 | 98.07 | Passed |
| gameplay_stabilization | 16 | 0 | 0.43 | Passed |
| traversal_transitions | 8 | 0 | 0.43 | Passed |
| world_cohesion_traversal | 56 | 0 | 60.22 | Passed |
| integration_candidate | 12 | 0 | 0.43 | Passed |
| integration_descent | 26 | 0 | 0.53 | Passed |
| profile_prepare | 2 | 0 | 0.44 | Passed |
| profile_reload | 5 | 0 | 0.43 | Passed |

Both green runs have zero failed assertions, parser/load/hard errors or nonzero test exits. The proof PR's promotion-only duplicate compatibility job was correctly skipped; its primary job executed the entire candidate suite. Native startup covers the main scene only. Interactive graphics/input, save playtesting and sustained 60 FPS are not certified. Main Apple Silicon native export is unavailable under unchanged settings; Intel compatibility was actually tested. Candidate Apple Silicon startup evidence from CI-01 remains supplemental; CI-02 native runner evidence is Intel.

## G. Downloaded artifacts and manifests

| Actual download link | Outer ZIP bytes | Expiry UTC |
| --- | ---: | --- |
| [Kaze-Native-Smoke-macOS-aec292c4](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11926940080) | 799 | 2026-11-04T20:26:09Z |
| [Kaze-Windows-x86_64-aec292c4](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11926024442) | 36,467,641 | 2026-11-04T20:25:38Z |
| [Kaze-QA-Results-aec292c4](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11925904559) | 9,919 | 2026-11-04T20:25:38Z |
| [Kaze-Native-Smoke-Windows-x86_64-aec292c4](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11925429922) | 808 | 2026-11-04T20:26:00Z |
| [Kaze-macOS-aec292c4](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11925344955) | 32,064,467 | 2026-11-04T20:25:40Z |
| [CI02-Candidate-QA-afecef19](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11926646963) | 55,130 | 2026-11-04T20:28:46Z |
| [CI02-Candidate-macOS-afecef19](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11926372355) | 75,664,981 | 2026-11-04T20:28:50Z |
| [CI02-Candidate-Windows-afecef19](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109/artifacts/11926362002) | 51,004,861 | 2026-11-04T20:28:47Z |
| [Kaze-Native-Smoke-macOS-7f6633ed](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577/artifacts/11926891044) | 805 | 2026-11-04T20:30:51Z |
| [Kaze-Native-Smoke-Windows-x86_64-7f6633ed](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577/artifacts/11926776955) | 808 | 2026-11-04T20:30:38Z |
| [Kaze-macOS-7f6633ed](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577/artifacts/11926457555) | 75,664,981 | 2026-11-04T20:30:17Z |
| [Kaze-QA-Results-7f6633ed](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577/artifacts/11926262499) | 55,158 | 2026-11-04T20:30:14Z |
| [Kaze-Windows-x86_64-7f6633ed](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577/artifacts/11926213154) | 51,004,871 | 2026-11-04T20:30:15Z |

All 13 outer digests matched GitHub's artifact metadata. All six inner game ZIPs and every manifest member hash matched. CRC checks and independent PCK re-audits passed. Full manifests, native reports, artifact IDs/digests and per-suite outcomes are committed in CI02_TEST_RESULTS.json.

| Game source SHA prefix | Actual target | Inner ZIP bytes | Inner ZIP SHA-256 |
| --- | --- | ---: | --- |
| aec292c4 | Windows-x86_64 | 36,613,385 | `8fdde58e9e2df9961977a8ee36419133876ea78c890a5c985490ee02b526b085` |
| aec292c4 | macOS-x86_64 | 32,251,409 | `4e6ebe9103e3245c2491357630a686dcb51ec386ae83e7c15770371ebd637d29` |
| afecef19 | macOS-Universal | 75,943,910 | `82755c8de354cd46f68619ec22e9037b682d84bfc54173425ebe92583f1ae7e1` |
| afecef19 | Windows-x86_64 | 51,146,694 | `56e65f027dbd61a4dae5d42acd7c961e193ccae889fc25e65e66853d4f97b7c9` |
| 7f6633ed | macOS-Universal | 75,943,906 | `98118df053864ef4e952f66789a7d14776cee35fc392abf9e6bba3745a915396` |
| 7f6633ed | Windows-x86_64 | 51,146,701 | `0abc0b011c250605a19524ec3576725da6c45ce68ea2ad34adcfefd1c1b8f2db` |

Each platform artifact contains the inner game ZIP and BUILD_MANIFEST.json; manifests record full source SHA/branch, UTC timestamp, target, pinned engine/templates, QA mode/count/unavailable checks, fallback/template origin, file sizes/hashes and audit scope. Published game packs exclude tests/docs/tools/build/profile/log/source archive content. QA/native uploads include only explicit log/report paths. No tokens, saves, certificates or signing credentials published.

## H. Security and operational controls

Explicit contents:read token, credentials persistence disabled, no secrets, no pull_request_target, no signing/notarization, no automatic releases/tags/merges or security-setting changes. Manual source inputs are choices plus independent runtime allowlist guards. Only main and the approved candidate source are accepted; workflow branch must be main or the dedicated promotion branch. Default rollout instructions use main for workflow controls. Native jobs request the exact artifact name and assert source SHA equality.

Official GitHub actions v4 tags retain CI-01 behavior; observed runs succeeded. Runner Node-version deprecation warnings remain visible and are maintenance work, not hidden failures. Jobs have 30 minute QA/export and 10 minute native caps, concurrency cancels superseded runs, and artifacts expire after 21 days. Promotion-only candidate compatibility adds one bounded Linux job; #15 adds explicit event-verification runner usage. Account quota/billing remains subject to GitHub terms; no unlimited quota claim.

## I. Rollout, download and rollback instructions

1. PM reviews **PR #14**, this report, its nine-file allowed diff and both green runs. No merge is performed by CI-02.
2. If approved, creator/PM merges the infrastructure-only PR through normal review. Do not merge PR #13 to install CI. #15 is verification-only and may be closed after review.
3. After default installation, verify Actions → Godot 4.6.1 QA and Playtest Builds → Run workflow appears. Keep workflow branch **main**. Select source_ref main or integration/candidate-alpha-0.6.1-gp-ld; enable build_artifacts; leave negative_probe false. Execute both selections and verify actual SHA/QA mode/architecture in manifests. This real post-merge dispatch is an explicit remaining PM validation gate, not claimed completed.
4. Download a platform artifact from a green run. Extract GitHub's outer ZIP first, hash the inner game ZIP with Get-FileHash or shasum -a 256, compare manifest, then extract/run. Back up creator saves first; executable filenames do not isolate save identities. Unsigned/unnotarized builds remain internal playtests.
5. Failed run: inspect CI_QA_REPORT.json, named logs, export logs, pack audit and NATIVE_SMOKE.json. Re-run failed jobs to retry the same source; fix infrastructure on a new source commit. Do not label an export-only artifact as boot-tested.
6. Rollback after an authorized installation by reverting only CI-02 infrastructure/docs commits or disabling this workflow with PM approval. Do not revert gameplay, import candidate history, change branch protections or signing permissions.

## J. GitHub references and remaining PM decisions

- [Draft promotion PR #14 → main](https://github.com/cappy2yappy/momentum-fractured/pull/14).
- [Draft verification PR #15 → candidate](https://github.com/cappy2yappy/momentum-fractured/pull/15), unmerged and verification-only.
- [Green main-target run](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38631729109) and [green candidate-target run](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577).
- Implementation commits: [7d839e5](https://github.com/cappy2yappy/momentum-fractured/commit/7d839e5e2f7d82018f0b1ec5fcc92eddddd2e785), [a13c048](https://github.com/cappy2yappy/momentum-fractured/commit/a13c048771a05bbc3628013ec8563a001aeed211), [aec292c — tested](https://github.com/cappy2yappy/momentum-fractured/commit/aec292c4f23610ca542a50e69a66c35b904c009f).
- [Operational handbook](../build/CI01_AUTOMATED_BUILD_HANDBOOK.md) and [structured evidence](CI02_TEST_RESULTS.json).

No GitHub permission/quota blocker prevented the successful runs. Outstanding decisions: final infrastructure merge approval; acceptance of main's explicit zero-regression/Intel-only fallback; separate gameplay test development or main ASTC/universal configuration if desired; candidate branch infrastructure sync as needed for future PR trees; post-merge real dispatch validation; human rendering/input/60 FPS QA. Main and candidate gameplay remain unchanged.

## K. Verdict / hold point

**READY FOR PM REVIEW.** Green hosted runs on both target branches, actual verified downloads, explicit coverage/architecture limitations and clean infrastructure-only diffs meet CI-02's review handoff. **Do not merge automatically.** Default activation and any gameplay/project configuration upgrades remain with creator/PM.
