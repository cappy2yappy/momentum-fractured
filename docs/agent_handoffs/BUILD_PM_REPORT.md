# BUILD PM return (ORDER 5)

## Phase B status (2026-10-19): comparison packages built on hosted Windows and macOS

Hosted run **[39205060691](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39205060691)**, purpose `comparison`,
tooling head `f6dacba` on branch `ci/pm-pilot-comparisons` (PR #56). All 17 jobs succeeded: plan, 5 Windows, 5 macOS,
5 Apple Silicon smoke. Windows jobs took 2m to 3m40s, macOS 5m to 8m, Apple Silicon smoke about 25 s each. Packages are
labelled **QA pending** (see below), unsigned, unnotarized, internal playtest only, not a release. No merge, tag, release or
main update; no binary committed.

Pinned sources (all final per coordinator):

| Variant | Commit | Notes |
| --- | --- | --- |
| `baseline-pr39` | `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` | control; same source as the BUILD-06 control |
| `transitions` | `903634afa51237e29fd306ae815c880415230f17` | Transition, 4 commits on PR51 |
| `geometry` | `0656766d8fe13c702a4808b1d25ddd0855d8922c` | Level, 1 commit on PR51 |
| `art` | `dfab1cf2efcacb2a792fb578b72be2434b9e4411` | Art, 1 commit on PR51 |
| `combined` | `49ae3efe21dea6a9eba556ce2fbc8299b00412b9` (tree `2a41ac47390a2a4e025435512d2b623894733270`) | branch `candidate/pm-pilot-combined`: PR51 + Level + Art + Transition, merged cleanly by the coordinator; the build asserts HEAD and tree equal these pins |

Allowlists were derived from `git diff` against PR51 `baedd678` (recorded in `tools/pmpilot/pins.json`; each build also
writes `PRESERVATION_DIFF.json`). Docs, editable `source_art/` sources and Art's `tools/pm_pilot_art/__pycache__` are
allowed in the source diff but can never reach a package: the build fails if any pack entry or ZIP member contains
`__pycache__`, `.pyc`, `source_art/`, `tools/`, `docs/`, `tests/`, `assets/art07/` or `tools/art07/`. That passed for all
ten packages. The Art branch's committed bytecode is acknowledged and stays out of every package.

Waivers (authorised by the coordinator for Level and combined only): **`expansion build_room PR37 function exact`**.
Reason: Level's `scripts/world_expansion.gd` change adds the gatehouse rooms inside `build_room`, so the PR37
function-exactness check in `tools/verify_tr05_preservation.py` reports exactly that one line; I measured it locally
on `0656766d` and on `49ae3efe` (1 failure each, everything else passes, `verify_baseline.py` 0 failures). The waiver
string is matched line by line, so any other preservation failure still fails the build. `scripts/world.gd` changes
(Transition and Level) did not trip any check, so no `world.gd` waiver was needed or used. Transition and Art have no
waivers. No protected gameplay file (`player.gd`, `guard.gd`, `storm_keeper.gd`, `momentum_profile.gd`,
`project.godot`, `export_presets.cfg`, `addons/`) differs in any candidate.

Checks every package passed (Windows and macOS hosts): source identity, diff allowlist, cold and settled import, baseline
and preservation scripts, TR05 suites (25 suites), TR06 suite where present, two exports with equal resource payloads,
exported scripts equal source, changed assets present in the pack, required entries (`scripts/staged_stair_cinematic.gd`,
`scripts/canal_gatehouse.gd`, `assets/pm_pilot/canal/*.png.import`, `assets/pm_pilot/wipe/*.png.import` where relevant),
ART-07 exclusion in source, pack and ZIP, extraction in a path with spaces, release startup, all four launchers actually
run with the isolation check, 54-check exported input fixture, six exported suites, source unchanged. The generated
demo seeds equal Transition's own fixture files for the two seeded demos.

### QA pending

The coordinator pinned QA's harness at PR #59 head `455f352e304955c0d4ea400bff62d489ce7834bb`
(`tools/pm_pilot_qa/run_qa.py`, checked out beside each candidate). Each build runs it as an **informational** step: its
output is recorded in the QA artifact and, if it does not pass, a finding is written to the manifest, but it does not gate.
Its cinematic-completion and Canal-containment hooks SKIP until QA publishes them; a skip is not a pass. Every manifest
carries `qa_status: pending`. I could not read the result files from this sandbox (artifact blobs blocked), so I do not
state the harness outcome here. Packages stay "QA pending" until the coordinator says otherwise.

### Downloads

Package artifacts (30-day retention; expiry is when GitHub deletes them):

| Artifact | id | size (bytes) | outer SHA-256 | expires (UTC) |
| --- | --- | --- | --- | --- |
| PMPILOT-comparison-macos-art | 12166315541 | 77679406 | `6f7159b7f0459a6ee5efeb623b3e834fe3b5a7e4be51d8b8b576bce125048aa3` | 2026-11-18 05:47:57 |
| PMPILOT-comparison-macos-baseline-pr39 | 12165716423 | 76421224 | `6fb569e669e06264d9f75ca9ef6f878bf21e16f4ef16aa004859081992218765` | 2026-11-18 05:44:49 |
| PMPILOT-comparison-macos-combined | 12166240723 | 77689419 | `34dd9fdd757662234c9b05b5915587253945cc123a169e49547d936402b84583` | 2026-11-18 05:47:33 |
| PMPILOT-comparison-macos-geometry | 12166071100 | 76424007 | `69caef73eb306b89d95a7614569fc83ac1bb8f634752a85a2bd01b27345b9e9e` | 2026-11-18 05:46:42 |
| PMPILOT-comparison-macos-transitions | 12165004319 | 76429591 | `f0771cff28c114872b18d38b7d73766b5152924283e135b59634410d6391b468` | 2026-11-18 05:47:15 |
| PMPILOT-comparison-windows-art | 12165621966 | 53018767 | `ea457ccafa351e2c95e38875db5335a1428152a59da8dd12f9aef974f88f1ef4` | 2026-11-18 05:39:11 |
| PMPILOT-comparison-windows-baseline-pr39 | 12165562131 | 51763420 | `3142ae4748fe4327f225a3391866ae460482e787c21eff769198d7c3442ef61a` | 2026-11-18 05:38:04 |
| PMPILOT-comparison-windows-combined | 12165581290 | 53029735 | `23d0897786a1d57d89d4e5b128d0c2fed10d26fc9fc2598d72eb6537515724b8` | 2026-11-18 05:39:18 |
| PMPILOT-comparison-windows-geometry | 12165268852 | 51766444 | `e94c3c0721ed69137e786ceafde775cae163e8b66472b21e250acc180cddf17a` | 2026-11-18 05:39:24 |
| PMPILOT-comparison-windows-transitions | 12165646989 | 51771863 | `69ea2e4ea93dc43fdf5502dc5bc78d32c120c95ab50f3694158808d85c45e89b` | 2026-11-18 05:39:09 |

Evidence artifacts (QA results, logs, `RESOURCE_SHA256.json`, `PRESERVATION_DIFF.json`, `LAUNCHER_ISOLATION.json`, harness output):

| Artifact | id | size (bytes) | outer SHA-256 | expires (UTC) |
| --- | --- | --- | --- | --- |
| PMPILOT-QA-comparison-macos-art | 12165891992 | 108417 | `facc3fa978be9b3ffa3d711f3455ad5a131887e6f9b10056c6cc11de644c44eb` | 2026-11-18 05:48:04 |
| PMPILOT-QA-comparison-macos-baseline-pr39 | 12165302880 | 103950 | `31453ea3cdd9e808fee3c27a42bdb2239eb9f63c0f1d43d00dadfd055fc6a66e` | 2026-11-18 05:44:53 |
| PMPILOT-QA-comparison-macos-combined | 12165941757 | 110688 | `2b12876226daf265d317f1941cfc21779860b1fa77f842e2804869884b7db1f2` | 2026-11-18 05:47:38 |
| PMPILOT-QA-comparison-macos-geometry | 12166315352 | 106034 | `7a55959c6f251b7d7213a8ee11dd262c7c7a456ec7ccf947a53c24a69fae7554` | 2026-11-18 05:46:47 |
| PMPILOT-QA-comparison-macos-transitions | 12166330041 | 106279 | `7c5927139172ce781757f588656a5bc6c41f64ae157feccfb35d6e49ee51abfa` | 2026-11-18 05:47:20 |
| PMPILOT-QA-comparison-windows-art | 12165029927 | 108555 | `621594542451359167250506057cc329c37911369e883a96cb89c6df4c08284f` | 2026-11-18 05:39:14 |
| PMPILOT-QA-comparison-windows-baseline-pr39 | 12165910457 | 104077 | `063a0b4c0a6aec47e8b70cde3727a2bd0072e2f21c0f6e5b8eb68cebd79f7b29` | 2026-11-18 05:38:07 |
| PMPILOT-QA-comparison-windows-combined | 12164823878 | 110812 | `96289378aa3d86ef5fe5692729d7ffc10a1a5194591634b7676435075f86a657` | 2026-11-18 05:39:21 |
| PMPILOT-QA-comparison-windows-geometry | 12165960516 | 106180 | `e9efa9c954861d62c26236a5341a6ccf618da295a3a29fb9c24e79c1dc1097b6` | 2026-11-18 05:39:28 |
| PMPILOT-QA-comparison-windows-transitions | 12165955459 | 106436 | `c972d5cbc14eb82722a40442ccd38728ab001d43aa6d6894b4f153628d621967` | 2026-11-18 05:39:12 |

Each package artifact contains the inner `Kaze-PMPILOT-<variant>-<host>-<sha8>.zip`, `MANIFEST.json`, `QA_RESULTS.json` and
`SHA256SUMS.txt`; the inner ZIP's SHA-256 is in those files. The Apple Silicon smoke recorded these inner macOS ZIP
hashes in annotations: baseline-pr39 `7ab7a947ffcb9c1e31727aa70444832c04ec9fd6159c970d4fbf0d449d05ca06`, combined
`3e584d9fe90b5a1ef50eb948521cc05ce06be8fdca5a588c84e0b7dfefb7ef19` (the others are in their SHA256SUMS.txt).

**Download verification not performed here.** This sandbox cannot reach the Actions artifact storage
(`productionresultssa*.blob.core.windows.net` is refused; checked again with an artifact of this run), so
`verify_download.py` was not run on the real artifacts. For the creator or any machine with GitHub access and a full clone
of the repository (`gh auth login` done, `git fetch --all` so every pinned commit exists):

```
python tools/pmpilot/verify_download.py --run 39205060691 --clone <full clone> --downloads <empty dir> --out <empty dir> --require-complete
```

It checks every artifact digest against the Actions record, ZIP integrity, the inner SHA-256 against the manifest, every
member hash, every packed resource payload against an independently re-assembled pinned source, text-script equality,
ART-07 and forbidden-path absence, and QA artifact pass state. It was only exercised offline here.

### Launch instructions

1. Download the package artifact for your platform, unzip it, then unzip the inner `Kaze-PMPILOT-...zip` into its own
   writable folder (one folder per variant). Compare the inner ZIP SHA-256 with `SHA256SUMS.txt`.
2. Windows x86_64: run a `Play-*.cmd`. macOS: run a `Play-*.command`; the app is unsigned and unnotarized, so approve it in
   System Settings, Privacy and Security if Gatekeeper blocks it.
3. Launchers: `Play-Fresh` (unseeded, persistent), `Play-Canal-Left` (room 13, hold A to leave left, no E, no flag),
   `Play-Cinematic-Pilot` (room 14 stair, press E; passes `--pm-staged-stair`), `Play-Cinematic-Reduced` (same plus
   `--tr05-reduced-motion`; F6 toggles). The same arguments are used in every variant. `--pm-staged-stair` only has an effect
   in `transitions` and `combined`; elsewhere the stair shows the inherited behavior.
4. Each launcher uses its own save, `profiles/<variant>-<Name>.json`, and its own user-data folder. Demos reset their seed on
   every launch; Fresh persists. Do not open the EXE or app directly.

### Tester checklist (observations only; creator acceptance is separate and still pending)

For each of `baseline-pr39`, `transitions`, `geometry`, `art`, `combined`, in that order:
- [ ] Play-Fresh starts, moves, and a second variant's Fresh starts from nothing.
- [ ] Play-Canal-Left: the visible door is where the automatic crossing fires; the approach reads as an enclosed hall; hold A through the door and note the wipe, destination and arrival.
- [ ] Jump and wall-jump around the Canal exit: you cannot climb above the mandatory exit into unintended space; vertical routes elsewhere still work.
- [ ] `geometry` and `combined` only: solid gatehouse masonry; `art` alone shows no new art (assets present, nothing draws them); `combined` shows Art's door layers over the opening.
- [ ] Play-Cinematic-Pilot at the stair: about 2.35 s staged sequence in `transitions` and `combined` only; Cinematic-Reduced about 0.95 s without camera move.
- [ ] Movement, character size, combat and saves feel the same as the baseline.
- [ ] Note any placeholder labels and any held pose that reads as fake animation.

### Coverage and limits (precise)

- **Hosted Windows** (`windows-2022`, x86_64): native, headless. Real exported EXE and `.cmd` launchers ran with `--headless`
  for 120 frames. No GPU, window, rendering or input from a person.
- **Hosted macOS Intel** (`macos-15-intel`, x86_64): native, headless, all checks above.
- **Hosted Apple Silicon** (`macos-15`, arm64, macOS 15.7.9): a separate smoke job downloaded each macOS package from the same
  run, verified the inner ZIP SHA-256, confirmed an arm64 slice, and ran all four launchers natively for 120 headless
  frames (all exit 0, Godot 4.6.1 banner seen). Headless smoke only: it does not run the suites or any graphics.
- **No graphical or hands-on coverage on any hosted host.** One software-GL capture of the combined source (not the exported
  package, Linux, xvfb, Mesa llvmpipe, OpenGL compatibility, `PM-Canal-Left` fixture, frame 40 of 45) is in
  `docs/pm_pilot/build/previews/combined_canal_left_source_swgl.jpg`. It shows the Level masonry gatehouse, Art's door
  frame, leaf and warm interior glow, the arrow cue and the "WALK THROUGH" labels, with Kaze on the shelf inside the hall.
  It confirms the layers coexist in the source. It is not the exported package, not a hands-on playthrough, and not creator
  acceptance. The staged stair was not captured by me.
- Not covered anywhere: human campaign, physical gamepad, sustained FPS, signing, notarization, creator visual acceptance.
- Reproducibility means identical repeated resource payloads within a run; cross-run only the `.godot/exported` group varies.

---

# Phase A record (superseded where it conflicts with the above)


Owner: Build Shogun. Date: 2026-10-19. Model: Claude Sonnet 5.5 (`claude-sonnet-5-5`) in Claude Code, Linux sandbox.
Draft PR: https://github.com/cappy2yappy/momentum-fractured/pull/56 (base `fix/tr06-automatic-passage` = PR51 head
`baedd6786ad4bee2123ea872b437bbb98e6d2721`, branch `ci/pm-pilot-comparisons`).

Status at the end of Phase A: tooling built and exercised; no candidate package existed. (Phase B above supersedes this.) ART-07 (PR #53, `18491105da5f8dd0b11b616c7da81803ced1fadc`) is excluded and untouched.
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

## Missing inputs for Phase B (all since supplied by the coordinator, see top)

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
