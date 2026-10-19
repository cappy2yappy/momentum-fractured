# BUILD PM return (ORDER 5), Phase A: preparation only

Owner: Build Shogun. Date: 2026-10-19. Model: Claude Sonnet 5.5 (`claude-sonnet-5-5`) in Claude Code, Linux sandbox.
Draft PR: https://github.com/cappy2yappy/momentum-fractured/pull/56 (base `fix/tr06-automatic-passage` = PR51 head
`baedd6786ad4bee2123ea872b437bbb98e6d2721`, branch `ci/pm-pilot-comparisons`).

Status: tooling built and exercised; **no candidate package exists or was published**. Candidate pins are null and the
workflow refuses to plan them. ART-07 (PR #53, `18491105da5f8dd0b11b616c7da81803ced1fadc`) is excluded and untouched.
Nothing was merged, tagged or released; main is untouched; no binary is committed.

## Commits

Base `baedd6786ad4bee2123ea872b437bbb98e6d2721`. Tooling head validated by hosted run 39203801126:
`37ffbb91f976608a24e8ab05dd36f0dbca34de17`. This report is added on top of it in a docs-only commit that does not touch
`tools/pmpilot/**` or the workflow (so no further CI run is triggered); the final head SHA is verified through the API
in the coordinator reply.

## BUILD-06 control (PR52): studied, preserved, not re-run

PR52 head `336c1094f0b0a2da5872a5db67566907b8d12324` (base `ci/build05-integrated-macos` = PR40
`32e75a884b62d08f9e024eab5b01429e87ed12f7`), still open and draft. Read: workflow, `tools/build06/*`, README,
INTEGRATION_PLAN, `verify_delivery.py`, `ancestry_audit.py`, BUILD06_PM_REPORT. Note `candidate.py` also loaded
`tools/build05/audit.py` from PR40, so that file was copied from PR40 as well. The accepted run's controls commit is
`bbec1b0d4494a489711385f8c3dff5137d166773`, not the PR52 head (documentation commits were stacked after it).

Artifacts of run 39098330966, re-queried 2026-10-19T05:28Z with `gh api .../actions/runs/39098330966/artifacts`:
all four **live, `expired: false`**.

| Artifact | id | expires (UTC) | digest (sha256, as reported by Actions) |
| --- | --- | --- | --- |
| Kaze-BUILD06-windows-baseline-5dfc4c4f | 12125915950 | 2026-11-17 04:51:18 | `f0cd1a453b4b8e75ec8a533d121d5d2266d210d54d5936444550d56c35c0dbbc` |
| BUILD06-windows-QA | 12126075333 | 2026-11-17 04:51:21 | `1dbd212b5e27aa96dbcefaffebf7436792a58be47bae6f13c59fc3cfdf2f57a8` |
| Kaze-BUILD06-macos-baseline-5dfc4c4f | 12125533126 | 2026-11-17 04:53:07 | `cb21b38d61d8c1f11bbd8d56a6411985f277b55390f2fb01a8fe5cfaa04e0642` |
| BUILD06-macos-QA | 12125846459 | 2026-11-17 04:53:13 | `843b9e5b361eec64...` (full value in the API record) |

The control was not altered, re-run or re-pinned. Its provenance is recorded in `tools/pmpilot/pins.json`
(`control_provenance`). I could only read metadata: the artifact blob hosts are not reachable from this sandbox (see
Limitations), so I did not download the control packages here.

## Delivered files

All new, under `tools/pmpilot/`, `.github/workflows/pmpilot-packages.yml`, `docs/pm_pilot/build/README.md` and this report.

| File | Role |
| --- | --- |
| `.github/workflows/pmpilot-packages.yml` | `plan` job (validates the request against pins), then Windows x86_64 matrix, then macOS Universal matrix (starts only if Windows succeeded or was not requested). Inputs via `workflow_dispatch`, or on pull_request from `tools/pmpilot/request.json`. Artifacts `PMPILOT-<purpose>-<host>-<variant>` plus `PMPILOT-QA-...` (always uploaded). |
| `tools/pmpilot/pins.json` | Variants: `baseline-pr39`, `pr51-control` (pinned), `transitions`, `geometry`, `art` (commit null), `combined` (merge of the three onto PR51). Per variant: compare base, allowed paths, protected-file waivers, preservation waivers, forbidden/required pack entries, regression counts and extra commands, QA harness pin. |
| `tools/pmpilot/request.json` | Repo-driven run request (needed because dispatch is not available, see below). Currently the preparation baseline smoke. |
| `tools/pmpilot/pins.py` | Plan/validate (refuses unpinned, mislabelled, quick+comparison), deterministic assembly (fixed merge dates, `--no-ff`, optional expected tree), diff-allowlist preservation check, ART-07 and protected-file guards. |
| `tools/pmpilot/build_package.py` | Derived from PR52 `candidate.py`. See checks below. |
| `tools/pmpilot/install_engine.py` | Derived from PR52 `install.py`: same pinned URLs, SHA-256 digests and version assertion. |
| `tools/pmpilot/audit_pack.py`, `packaged_native.gd` | Verbatim copies (PR40 `tools/build05/audit.py`, PR52 `tools/build06/packaged_native.gd`). |
| `tools/pmpilot/verify_download.py` | Derived from PR52 `verify_delivery.py`: re-assembles the pinned source and verifies the downloaded Actions artifacts; offline `--from-dir` mode. |
| `tools/pmpilot/demos.json` | Launcher definitions from Transition's demo arguments. |
| `tools/pmpilot/PROVENANCE.json` | Source commit, path and SHA-256 of every file taken from PR52/PR40, copy mode and change summary. |
| `docs/pm_pilot/build/README.md` | Launch instructions, tester checklist, coverage limits. |

Allowlisted copies were made explicitly (five files, recorded with source hashes); no other PR52 file or PR52 evidence
was imported. Nothing from PR53, no `assets/art07`, no `tools/art07`.

## What the package build checks (all implemented in `build_package.py`)

Source identity and clean tree; diff-allowlist preservation against the candidate base (protected gameplay files and
ART-07 paths fail); cold and settled import; baseline and PR37 preservation scripts; TR05 25 suites, TR06 automatic
passage suite, candidate extra commands; two text-script exports with the pinned Godot 4.6.1 editor and templates and
equal resource payloads; every shipped script equals source bytes; changed assets must reach the pack; ART-07 and forbidden
prefix exclusion in source, pack and ZIP; extraction into a path with spaces; native release startup and actual launcher
runs with an isolation check (Windows and macOS hosts); six exported-pack suites plus the 54-check input fixture;
source unchanged afterwards; manifest, QA results, SHA256SUMS; separate download verification script.

## Tests actually executed

Hosted (GitHub Actions, PR trigger on PR #56, all labelled `preparation-smoke`, variant `baseline-pr39` only):

| Run | Head | Result |
| --- | --- | --- |
| [39201296157](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39201296157) | `284269a9` | Windows FAILED at the step "Validate source and native Windows package" after 50 s. Job logs are unreadable from here and this run carried no failure annotation, so its cause was not observed directly; the next run, with annotations added, failed on the control-equality assertion below, which is the presumed cause. |
| [39201499055](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39201499055) | `dad5c04e` | Windows FAILED on that assertion (annotation: `Canonical resource hash differs from the BUILD-06 control for the same pinned source`). |
| [39201864695](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39201864695) | `c9af14e` | Windows success after making control equality recorded, not gated. macOS skipped (Windows only default). |
| [39202076019](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39202076019) | `de5ebf4` | Windows and macOS success (first macOS pass). |
| [39202814465](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39202814465) | `7e2e7de` | Windows and macOS success, request.json plumbing. |
| [39203404440](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39203404440) | `760068c` | Deliberate refusal test: request `transitions,combined` as `comparison`. `plan` job failed with exit code 2 and the build jobs were skipped, so no package was produced. Reverted in the next commit. The refusal text itself is in the unreadable log; only the exit code and skipped jobs are confirmed. |
| [39203801126](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39203801126) | `37ffbb9` | **Final tooling head: plan, Windows (2m00s) and macOS (5m12s) all success.** Each ran the 25 TR05 suites, the preservation scripts, two exports, release startup, all four launchers, 54-check input fixture and six exported suites. |

Artifacts of the final run (30-day retention, preparation smoke, not candidates; please do not distribute):

| Artifact | id | digest (sha256) | expires (UTC) |
| --- | --- | --- | --- |
| PMPILOT-preparation-smoke-windows-baseline-pr39 | 12164614301 | `3e7d22c48130c3f2b4c8da7a1d4ef9e4fa1d5caea316ff7eb4237c25cc03567a` | 2026-11-18 05:22:23 |
| PMPILOT-QA-preparation-smoke-windows-baseline-pr39 | 12164853213 | `77dd5988cbf5acf6c5577b61ca1bd7faf9ad4119973df5a4f2176dfe4e0f07e3` | 2026-11-18 05:22:25 |
| PMPILOT-preparation-smoke-macos-baseline-pr39 | 12165490852 | `4b384b099cea71cf6ec9d615a26efe9cb7410b49adc37669dcc724b666165321` | 2026-11-18 05:27:40 |
| PMPILOT-QA-preparation-smoke-macos-baseline-pr39 | 12165237279 | `d0712f1450770637ee5297b5ba9203b6e8c15aaceb2229bcb366e58c0c9e706f` | 2026-11-18 05:27:44 |

Local (Linux Godot 4.6.1 official binary, templates downloaded from the godot-builds release and SHA-256 verified,
Windows x86_64 cross-export, `--local-smoke`, not deliverables):
- `baseline-pr39`, `--quick`: all gated steps pass; 514 pack entries, 59 scripts equal to source, 252 exported
  assertions (matches the BUILD-06 figure). Archive reproduced byte-identically across two runs on one machine.
- `pr51-control`, full: 25 suites / 1,607 assertions, TR06 305 assertions, 54 input checks and six exported suites
  pass. These are the numbers pinned for that variant.
- Offline `verify_download.py --from-dir` against a locally built package: Actions-digest stand-in, inner SHA-256,
  7 members, 514 payloads, 59 scripts verified.
- Rehearsal with synthetic candidate branches (scratch repo only): diff-allowlist accepted allowed edits and rejected
  `scripts/player.gd` and `assets/art07/` changes; sequential merge composition is deterministic (same head twice);
  the changed-asset gate caught a `.txt` asset that the export filter drops.
- Rehearsal with the real Transition branch `903634afa51237e29fd306ae815c880415230f17` (non-deliverable, Linux
  cross-export, no packages kept): diff allowed with a broad allowlist, 25 suites / 1,607 assertions, TR06, preservation,
  exports (516 entries, 61 scripts), exported suites all pass; generated seeds equal Transition's own fixture files.
  This used a scratch pins file, not `pins.json`.
- `git merge-tree` probes with merge base PR51: transitions+geometry, transitions+art, geometry+art are each textually
  clean. A real merge and a combined run have not been done. Semantic compatibility is untested.
- `actionlint` on the workflow: clean. All Python files compile.

## Findings

1. **Cross-run resource identity does not hold, as BUILD-06 already warned.** Canonical resource hashes of four hosted
   Windows runs of the same PR39 source differ, and the only differing group (per-directory hashes annotated by the build)
   is `.godot/exported` (`a4c2469b25`, `1e5aceda28`, `f6e628d044`, `f303821c80`). `.godot/imported`, `project.binary`
   and every script group were identical across runs (`uid_cache.bin` too in the three runs where it was recorded); Linux and hosted Windows also agree on
   `.godot/imported`. Therefore equality with the BUILD-06 control's canonical hash (`dd654a86...`) is recorded in each
   manifest (`equals_build06_control`), not gated. The gated claim is identical repeated exports within one run.
2. The cold editor import prints MetSys editor-script and UID resolution errors on a fresh Linux clone. Hosted
   Windows and macOS cold imports are clean and gated; on the Linux smoke host that one step is recorded as a finding.
3. Existing preservation scripts compare to PR37 exactly (`scripts/level_geometry.gd`, `scripts/world_expansion.gd`
   functions, `scripts/world.gd` functions). Transition's candidate passes them; Level's candidate edits `world.gd`,
   `world_expansion.gd` and `tests/level_geometry.gd`, so expect either a pass to be proven or explicit
   `preservation_waivers` from Level.

## Limitations (precise)

- Hosted Windows and macOS are headless. The macOS runner is `macos-15-intel` (x86_64): the Universal app contains
  arm64, but arm64 execution is not covered. No graphical capture, human campaign, gamepad, sustained FPS, signing or
  notarization is covered. Linux software-GL captures are not part of this workflow.
- The Linux smoke cannot run the Windows binary, `.cmd` launchers or macOS bundle. Launcher execution was proven only on
  the hosted runners.
- The launcher isolation check is negative (no ordinary-save file after 120 headless frames); it does not exercise a save.
- `workflow_dispatch` is not usable from this sandbox: the API returned 403 "Resource not accessible by integration",
  and the workflow is not on the default branch. Runs are requested through `request.json` and the PR trigger instead.
- Hosted job logs and Actions artifact blobs are not reachable from this sandbox (`productionresultssa*.blob.core.windows.net`
  is refused by the egress proxy). So `verify_download.py` has not been run against real Actions artifacts; I used check-run
  annotations (the builder emits an error annotation on failure and one notice with resource hashes) and artifact metadata.
  Download verification needs a machine with access, run with `--require-complete` for comparison packages.
- `pr51-control` has been built only in the local Linux cross-export, not on hosted runners.

## Missing inputs for Phase B, and who supplies them

| # | Input | Owner | State now |
| --- | --- | --- | --- |
| 1 | Final commit SHA of `feature/pm-pilot-transitions` | Transition | origin shows `903634afa51237e29fd306ae815c880415230f17` (4 commits). Confirm it is final. |
| 2 | Final commit SHA of `feature/pm-pilot-canal-geometry` | Level | origin shows `0656766d8fe13c702a4808b1d25ddd0855d8922c` (1 commit). Confirm it is final. |
| 3 | Final commit SHA of `art/pm-pilot-passage-cinematic` | Art | origin shows `dfab1cf2efcacb2a792fb578b72be2434b9e4411` (1 commit). Confirm it is final. |
| 4 | `allowed_paths` for each candidate (and `allow_protected`, `preservation_waivers` if any) | each owner, confirmed by coordinator | not supplied. Observed in the diffs: Transition changes `scripts/cinematic_transitions.gd`, `staged_stair_cinematic.gd`, `transition_pilot_data.gd`, `world.gd`, tests, docs; Level changes `canal_gatehouse.gd`, `world.gd`, `world_expansion.gd`, tests; Art adds `assets/pm_pilot/**`, `source_art/pm_pilot/**`, `tools/pm_pilot_art/**`, docs. |
| 5 | QA harness commit SHA (`test/pm-pilot-regressions`, `tools/pm_pilot_qa/run_qa.py`) and whether Phase B hooks (cinematic completion, Canal containment) will replace the current SKIPs; QA's output path for `result.json` | QA | `QA_RUN.md` read; branch not on origin yet. Without a pinned SHA the plan refuses candidate variants. |
| 6 | Combined recipe: merge order transitions, geometry, art onto PR51 is built in; confirm, or supply an integration SHA / expected tree | Coordinator | decision |
| 7 | Whether Level's `scripts/canal_gatehouse.gd` stand-in draw and Art's layers are meant to coexist in the combined build (Art's note says the stand-in should stop drawing once art is bound) | Level + Transition + Art | needs an owner answer; an art-only build shows no art unless engineering code binds it |
| 8 | Whether the Art branch should carry `tools/pm_pilot_art/__pycache__` bytecode (it does) and binary sources under `source_art/` (`.ora`, 2x masters) | Art / coordinator | not a build blocker (outside the export filter), but conflicts with the no-binary rule |
| 9 | Decision: add a hosted Apple Silicon (`macos-15`) headless job, and who performs a hands-on Mac check | Coordinator | not built; coverage statement stays Intel-only |
| 10 | Who downloads and verifies the Actions artifacts with SHA-256 | Coordinator / a machine with artifact access | cannot be done from this sandbox |

## Ready-to-run checklist for Phase B

1. Coordinator announces candidate SHAs (items 1 to 3) and the QA harness SHA (item 5).
2. Owners confirm allowlists and waivers (item 4). I edit `pins.json` (`commit`, `allowed_paths`, `qa_harness.commit`,
   optional `required_pack_entries` such as `assets/pm_pilot/canal/*.png.import`, per-variant regression counts).
3. Optional rehearsal on Linux of each pin before spending runner time.
4. Push `request.json` with `"purpose": "comparison"`, variants `baseline-pr39,pr51-control,transitions,geometry,art,combined`,
   platforms `both`. The `plan` job refuses anything unpinned.
5. A machine with artifact access runs `python tools/pmpilot/verify_download.py --run <id> --clone <full clone> --downloads <dir> --out <dir> --require-complete`.
6. Hand the verified artifact list, SHA-256 digests and expiries to the creator with the README checklist.

## Next action and turn state

Waiting for the coordinator's Phase B go-ahead and the inputs above. State: Phase A complete, tooling validated on
hosted Windows and macOS with a baseline smoke only. No candidate built. Existing PR branches and the BUILD-06 control
are untouched.
