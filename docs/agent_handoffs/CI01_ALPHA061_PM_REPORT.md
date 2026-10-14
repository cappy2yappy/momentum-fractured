# KAZE PROJECT MANAGEMENT REPORT — CI-01-0061

## A. Executive summary / true status

**READY FOR PM REVIEW.** Actual PR-triggered [Actions run 38625422844](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844) completed **successfully**. Import, baseline preservation, all 17 regression suites, save prepare/reload, negative validator checks, Windows x86_64 export, macOS universal export, ZIP/PCK audits, and both native headless startup jobs passed. **691 assertions; zero failed assertions, parser/load errors, hard errors or nonzero test exits.**

All five published artifacts were actually downloaded, their GitHub outer archive SHA-256 digests verified, and both inner game ZIPs/member hashes and PCK contents independently rechecked. No merge performed. This is an internal alpha candidate infrastructure milestone, not public release approval.

## B. Verified source and branch

- Authoritative order: [CI01_ALPHA061_AUTOMATED_BUILDS.md at 4c91c34](https://github.com/cappy2yappy/momentum-fractured/blob/4c91c34b994986f57fd15c0474514573e7babe16/docs/agent_assignments/CI01_ALPHA061_AUTOMATED_BUILDS.md), read in full before editing.
- Remote review base verified: `integration/candidate-alpha-0.6.1-gp-ld`, `afecef1922231081807a332c511de85c7941fec8`.
- Dedicated branch: `ci/alpha-0.6.1-automated-godot-builds`.
- **Tested/exported source:** [`ec68565b8169f4113a3c1930475cce88c9eaa39f`](https://github.com/cappy2yappy/momentum-fractured/commit/ec68565b8169f4113a3c1930475cce88c9eaa39f).
- Draft review [PR #13](https://github.com/cappy2yappy/momentum-fractured/pull/13) targets the combined candidate. PRs #8–#12 and specialist branches were not changed, merged or cherry-picked.
- Clean isolated checkout: `work/ci01-alpha061`. Synced `sources/` reference files were untouched. Existing specialist checkouts were untouched.
- Gameplay scripts/assets, room geometry, `project.godot`, export presets, existing QA runner and preservation verifier are byte-for-byte unchanged relative to the verified base. Renderer GL Compatibility, 1280×720, save identity, Kaze sprite sizing, 21-room graph, approved physics/progression are preserved.

Files delivered: `.github/workflows/godot-ci.yml`; `tools/ci/install_godot.py`, `qa.py`, `package.py`, `negative_path.py`, `native_smoke.py`; `docs/build/CI01_AUTOMATED_BUILD_HANDBOOK.md`; this report; `CI01_ALPHA061_TEST_RESULTS.json`. Final report publication is a docs-only follow-up to the exact tested source; it changes no executable or workflow code.

## C. CI architecture and events

A 30 minute Ubuntu 24.04 QA/export job checks out the exact PR head SHA with credentials persistence disabled. It installs official checksum-pinned Godot/templates, reuses the INT-01 runner, discovers additional assertion suites, validates every result, and exports/audits both targets. Windows 2022 and macOS 14 jobs download those packages and launch the actual release main scene headlessly for 120 fixed-rate frames under isolated profiles. Each native job has a 10 minute limit.

PR trigger targets the approved integration branch; docs-only edits are excluded. No duplicate push trigger. Concurrency supersedes older runs. `workflow_dispatch` has build_artifacts and optional deliberate negative_probe controls. **Run workflow UI is not promised on this unmerged branch: GitHub requires the workflow definition on default.** PR execution worked without default-branch promotion. PM must authorize default installation separately.

## D. Godot versions, templates, export presets

Engine: `4.6.1.stable.official.14d19694e`. Templates: `4.6.1.stable`. Official [release](https://github.com/godotengine/godot-builds/releases/tag/4.6.1-stable) archive SHA-256 pins:

- Linux x86_64 editor: `cecd0cb6b55e931318a9d7237dc4197d69ea914966787a454808523626e2789f`.
- Export templates: `e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875`.

Existing preset names remain `Windows Desktop` (x86_64, embedded PCK) and `macOS` (universal, unsigned/unnotarized). Existing include `world/*.txt` and exclusions `tests/*,docs/*,tools/*,build/*,.autoconverted/*` remain effective. Required addons/main resources and world text bytes are checked inside actual exported PCKs; all 527 entries are MD5 checked. Windows PE machine `0x8664` and macOS two-architecture universal header were confirmed.

## E. Test results and failure behavior

[Linux QA/export job](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/job/116063840055): **success**. Detailed raw logs and JSON are downloadable in the QA artifact; committed structured results preserve every actual result.

| Check/suite | PASS assertions | Exit code | Seconds | Result |
| --- | ---: | ---: | ---: | --- |
| import | 0 | 0 | 10.18 | Passed |
| verify_baseline | 0 | 0 | 0.04 | Passed |
| approved_baseline | 32 | 0 | 2.03 | Passed |
| approved_combat_swing | 7 | 0 | 0.44 | Passed |
| annex_expansion | 34 | 0 | 3.6 | Passed |
| annex_traversal | 6 | 0 | 8.81 | Passed |
| save_compatibility | 11 | 0 | 0.53 | Passed |
| skyworks_progression | 33 | 0 | 5.09 | Passed |
| storm_keeper | 12 | 0 | 0.53 | Passed |
| movement_momentum | 53 | 0 | 8.9 | Passed |
| sprite_integration | 43 | 0 | 0.53 | Passed |
| world_expansion | 193 | 0 | 4.44 | Passed |
| expansion_gates_save | 17 | 0 | 3.79 | Passed |
| expansion_traversal | 125 | 0 | 98.07 | Passed |
| gameplay_stabilization | 16 | 0 | 0.53 | Passed |
| traversal_transitions | 8 | 0 | 0.44 | Passed |
| world_cohesion_traversal | 56 | 0 | 60.31 | Passed |
| integration_candidate | 12 | 0 | 0.44 | Passed |
| integration_descent | 26 | 0 | 0.53 | Passed |
| profile_prepare | 2 | 0 | 0.44 | Passed |
| profile_reload | 5 | 0 | 0.44 | Passed |

Each process has a 300 second timeout. Failures include nonzero exits, missing results/assertions/completion, FAIL, script/parser/load failures, and unrecognized ERROR diagnostics. The pre-existing sprite integration suite has no textual summary; it requires its 43 assertions plus successful exit instead. Known narrow engine teardown leak messages and the macOS headless CA-certificate noErr diagnostic remain visible and classified nonfatal; other errors are not suppressed. Export logs retain warnings, including any missing resource-editor warning; package/runtime audits remain required. Headless import can generate temporary metadata, kept out of the implementation commits.

**Observed deliberate negative path:** [job 116062527261](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625120369/job/116062527261) at `1ced40ada2481064da8dcd48906673f31044c8cb` intentionally passed corrupt bytes to the real pack validator. It completed **failure**, exit 1, `AssertionError: Missing embedded PCK trailer`. The temporary job was removed by `ec68565b...`; the final run is green. The overall probe run was later cancelled when the final revision superseded its still-running QA; its negative job had already completed red. Run 38624823240 was also superseded/cancelled. Neither cancelled run is acceptance evidence.

## F. Exported artifacts, sizes, checksums and downloads

| Actual artifact download | ID | Outer archive bytes | Expiry UTC |
| --- | ---: | ---: | --- |
| [Kaze-Native-Smoke-macOS-Universal](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/artifacts/11924337829) | 11924337829 | 804 | 2026-11-04T19:44:47Z |
| [Kaze-macOS-Universal-ec68565b](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/artifacts/11923808069) | 11923808069 | 75,664,924 | 2026-11-04T19:44:24Z |
| [Kaze-Native-Smoke-Windows-x86_64](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/artifacts/11923803182) | 11923803182 | 808 | 2026-11-04T19:44:46Z |
| [Kaze-QA-Results-ec68565b](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/artifacts/11923633103) | 11923633103 | 55,021 | 2026-11-04T19:44:19Z |
| [Kaze-Windows-x86_64-ec68565b](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/artifacts/11923433290) | 11923433290 | 51,004,783 | 2026-11-04T19:44:21Z |

Inner game ZIPs (hash these after extracting GitHub's outer artifact download):

| Target / filename | Bytes | SHA-256 |
| --- | ---: | --- |
| Windows: `Kaze-Alpha-0.6.1-Candidate-Windows-x86_64-ec68565b.zip` | 51,146,695 | `71d6bfdbe08ddf53ef530200d3324e24cd7c5b431c610492c0fae59d3a544c92` |
| macOS: `Kaze-Alpha-0.6.1-Candidate-macOS-Universal-ec68565b.zip` | 75,943,920 | `33652b5df50a295012282db13c9b7ec86726c0350a873c877bd7778d6d38f096` |

Each platform artifact contains the game ZIP and BUILD_MANIFEST.json with full source SHA/branch, UTC timestamp, engine/templates checksum, target, QA outcome, file sizes and member SHA-256s. ZIP CRCs, Windows executable/embedded PCK, macOS universal app/PCK, required world data and excluded directories were independently verified after download. No creator saves, profiles, signing credentials, source archives or QA logs are inside game packages. QA/native artifact upload paths exclude disposable profile directories.

## G. Native boot matrix and caveats

| Runtime | Actual evidence | Scope |
| --- | --- | --- |
| Windows AMD64 | [native job success](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/job/116065885878), returncode 0, no hard errors | Actual downloaded EXE, main-scene headless startup |
| macOS arm64 | [native job success](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844/job/116065886238), returncode 0, no hard errors | Actual downloaded universal app executable, main-scene headless startup |
| macOS x86_64 | Universal package structure verified; native launch **untested** | Intel interactive/native compatibility remains a gate |
| Creator hardware / graphics / controls | **Untested by CI** | Actual Windows and Apple Silicon interactive playtest required |
| Sustained 60 FPS | **Not certified** | Human native stress-test gate; fixed-fps/headless execution is not a performance measurement |

The platform manifests describe the earlier export stage as native untested; later startup evidence lives in the separate NATIVE_SMOKE.json artifacts and this matrix. Supplemental local macOS arm64 startup and full local QA also passed, but acceptance relies on the green hosted run and downloaded builds.

## H. Security and cost controls

Explicit contents:read token; no secrets or expanded workflow token permissions; no persisted checkout credential; no pull_request_target; no auto-merge/tag/release posting. Official GitHub Actions v4 major tags are used and resolved upstream SHAs appear in raw logs. Runners currently warn about Node 20 deprecation and force these actions onto Node 24; observed execution passed. PM can adopt immutable pins/current major upgrades in future maintenance.

21 day artifact retention, bounded job timeouts and concurrency limit obsolete run costs. This execution used one Linux build and two short native jobs, plus deliberately superseded setup/probe runs. Account billing/quota and future storage remain subject to GitHub policy; no unlimited/free quota claim is made. Downloads expire November 4, 2026 UTC; rerun the same source if needed later.

Local Git OAuth push refused workflow publication because its credential lacks workflow scope. The already-connected GitHub app successfully published the same reviewed Git tree/commits, triggered PR runs and fetched evidence; no additional scope, secret or repository setting change was requested. This access issue was resolved and is not an outstanding blocker.

## I. Commits, PR and execution links

- [`fa47642657333f98e10e71eadb0649b684c13db7`](https://github.com/cappy2yappy/momentum-fractured/commit/fa47642657333f98e10e71eadb0649b684c13db7): initial CI implementation/handbook.
- [`1ced40ada2481064da8dcd48906673f31044c8cb`](https://github.com/cappy2yappy/momentum-fractured/commit/1ced40ada2481064da8dcd48906673f31044c8cb): native startup and deliberate negative evidence; sprite suite validation correction.
- [`ec68565b8169f4113a3c1930475cce88c9eaa39f`](https://github.com/cappy2yappy/momentum-fractured/commit/ec68565b8169f4113a3c1930475cce88c9eaa39f): removes temporary red probe; **exact source tested and exported**.
- [Draft PR #13](https://github.com/cappy2yappy/momentum-fractured/pull/13), [green run 38625422844](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844), [negative job evidence](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625120369/job/116062527261).

## J. Creator instructions and remaining decisions

Open the green execution → Artifacts → download Windows, macOS and QA results (login may be required). Extract GitHub's outer ZIP first; compare inner game ZIP SHA-256 with BUILD_MANIFEST.json using Get-FileHash on Windows or shasum -a 256 on Mac. Extract the inner ZIP and run the game EXE/app. Back up normal saves first: different binary filenames retain the existing save identity. Review unsigned macOS startup through the normal OS approval process; signing/notarization is deferred.

Review [the operational handbook](../build/CI01_AUTOMATED_BUILD_HANDBOOK.md) for failed-job reruns, log interpretation, Run workflow after default installation, download verification, save isolation and workflow-only rollback. PM decisions remaining: review PR without automatic merge; separately authorize default-branch promotion if desired; schedule creator hardware playtests, Intel Mac startup and sustained 60 FPS stress validation. No permission change is required for the already-proven PR build path.

## K. Verdict

**READY FOR PM REVIEW** — CI-01 infrastructure acceptance evidence exists: real green Actions execution, full suite pass, both actually downloaded/verified platform builds, source manifests, ZIP/PCK audits, native headless startup reports and observed negative-path failure. No unauthorized merges and no gameplay edits. Public release and interactive/performance acceptance remain with creator/PM.
