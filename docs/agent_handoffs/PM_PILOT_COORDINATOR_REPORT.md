# PM Pilot Coordinator Report (2026-10-19)

Coordinator: Claude Sonnet 5.5 (Claude Code session https://claude.ai/code/session_01GL26CDpTPVQDecMuWS9nqL), Linux cloud sandbox.
Nothing here is merged. No main update, no tag, no production release. No binary is committed. Creator visual and play acceptance is **pending for everything below**.

## 1. Status of every order

| Order | Branch | Head SHA (verified via GitHub API) | Draft PR | Status |
| --- | --- | --- | --- | --- |
| 1 Transition Masta | `feature/pm-pilot-transitions` | `903634afa51237e29fd306ae815c880415230f17` | [#57](https://github.com/cappy2yappy/momentum-fractured/pull/57) | Delivered. Canal-left door drawn on the contract opening; staged R14 to R17 stair cinematic (2.35 s) behind opt-in `--pm-staged-stair`. Placeholder poses labelled. |
| 2 Level Masta | `feature/pm-pilot-canal-geometry` | `0656766d8fe13c702a4808b1d25ddd0855d8922c` | [#58](https://github.com/cappy2yappy/momentum-fractured/pull/58) | Delivered. Canal-left gatehouse hallway, aperture, support and trigger aligned; exit audit; LD-04 status reported. One residual (section 7). |
| 3 Art Mane | `art/pm-pilot-passage-cinematic` | `dfab1cf2efcacb2a792fb578b72be2434b9e4411` | [#55](https://github.com/cappy2yappy/momentum-fractured/pull/55) | Partial by design. Canal architecture layers and wipe kit delivered (procedural architecture, not painted). **No authored entry/traversal/departure animation**: 69 frames listed as missing. |
| 4 QA | `test/pm-pilot-regressions` | `c44f2b8163867e211f7d2297d6dcfad26c36abe7` | [#59](https://github.com/cappy2yappy/momentum-fractured/pull/59) | Delivered (Phases A and B). Recommendation: ready for creator playtest and packaging, not ready to merge. |
| 5 Build Shogun | `ci/pm-pilot-comparisons` | `34f308ef6dab94ed6ca45c56b2f61456d96675e2` | [#56](https://github.com/cappy2yappy/momentum-fractured/pull/56) | Built on hosted Windows x86_64, macOS (Intel host, lipo Universal) and an Apple Silicon smoke job. Download verification not performed in this sandbox. Packages are QA pending. |
| 6 Story Agent | `docs/pm-pilot-narrative` | `6cb4b6bb61f064c310d92a75b3fdcda4ab351398` | [#54](https://github.com/cappy2yappy/momentum-fractured/pull/54) | Delivered (doc only). |
| Combined test candidate | `candidate/pm-pilot-combined` | `49ae3efe21dea6a9eba556ce2fbc8299b00412b9` (tree `2a41ac47390a2a4e025435512d2b623894733270`) | none (temporary) | PR51 + Level + Art + Transition, three clean `--no-ff` merges, no conflict resolution. |

## 2. Source pins and ancestry

All six worktrees started at PR51 head `baedd6786ad4bee2123ea872b437bbb98e6d2721` (TR06 doorway fix for issue #42), which is exactly one commit on PR39 head `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` (compare API: ahead 1, behind 0). Main (`c69efbb`) was not used as a gameplay base. Existing specialist branches (#30, #39, #41, #47, #49, #51, #52, #53) were not modified.

| Reference | Role here |
| --- | --- |
| PR #30 ART-04 | approved Kaze drawings: held keys reused as labelled held poses |
| PR #39 TR-05 | gameplay baseline (control) |
| PR #41 ART-05 | inspected only; not imported; turn_depth candidate only, enter_depth WIP, stair_up rejected |
| PR #51 TR-06 | carried forward as the base of every branch; verified (305 pass / 0 fail) |
| PR #52 BUILD-06 | control and tooling reference (artifacts from run 39098330966 still live, expire 2026-11-17, unchanged) |
| PR #47 R18 art | inspected only; no R18 change in any pilot; status below |
| PR #49 authoring tool | inspected only; not runtime adoption |
| PR #53 ART-07 | untouched and excluded; Build asserts absence of `assets/art07` and `tools/art07` in every package |

LD-04 R18 status (Level, read only): issue #43 open (step 1 is a behaviour-preserving freeze of generated slabs, owned by Level); PR #47 draft at `4b11bef0` awaiting Level redesign publication, creator style acceptance and export include filter; PR #49 draft at `00d74c36`, editable layout scene with default-off migration plan, workflow comfort and route QA pending.

## 3. Actual models and environments

| Role | Model | Environment |
| --- | --- | --- |
| Coordinator | Claude Sonnet 5.5 | Claude Code cloud Linux sandbox |
| Transition Masta | Opus (requested via the sub-agent model setting; the agent did not self-report a version) | same sandbox, Godot 4.6.1 official Linux, software GL (llvmpipe, xvfb) |
| Level, Art, QA, Story | Sonnet (requested; not self-reported) | same sandbox |
| Build Shogun | Claude Sonnet 5.5 (self-reported) | sandbox plus GitHub-hosted `windows-2022`, `macos-15-intel`, `macos-15` (arm64 smoke) |

Sub-agents were available and used; they ran in parallel in isolated worktrees (one writer per tree).

## 4. Tests executed and results

Linux headless Godot 4.6.1, each at the exact SHA in a fresh detached worktree (QA, PR #59). "Harness" is QA's real-key suite; "#42" is the PR51 author test; "stock" is the 25 existing suites.

| Target | SHA | Harness | #42 | Stock | Staged stair (flag on) |
| --- | --- | --- | --- | --- | --- |
| Combined | `49ae3efe` | 488 / 0 | 305 / 0 | 1607 / 0 | 32 / 0 (reduced-motion launch 6 / 0) |
| Transitions only | `903634af` | 463 / 0 | 305 / 0 | 1607 / 0 | 32 / 0 |
| Geometry only | `0656766d` | 485 / 0 | 305 / 0 | 1607 / 0 | n/a |
| Art only | `dfab1cf2` | 460 / 0 | 305 / 0 | 1607 / 0 | n/a |
| PR51 control | `baedd678` | 460 / 0 | 305 / 0 | 1607 / 0 | n/a |
| PR39 control | `5dfc4c4f` | 332 / 128 | 211 / 94 | 1607 / 0 | n/a |

- Issue #42 reproduced independently on unchanged PR39 (jump toward the left exit stalls at x about 14; all 23 gated passages show "PASSAGE LOCKED" instead of the specific hint; R9 to R10 also fails). PR51 and every candidate fix these. This reproduction is separate from the creator's single good doorway landing, which does not close #42 across endpoints.
- Own suites on combined: `pm_staged_stair_cinematic` 50 / 0, `pm_canal_left_passage` 56 / 0, `canal_geometry` 173 / 0. Level also ran TR04 and LD03 runners: identical to baseline (1059/68 and 1141/70, pre-existing failures).
- Stair measured 2.38 s from E to control (contract 2.35 s); reduced motion 0.98 s; control returns after pause, respawn and F6; no double trigger.
- Canal containment: on PR51 wall-jump probes leave the world; on geometry candidates the hallway holds at feet y 1080.07 (limit 1080). Added R13 colliders are exactly the contract mass and pier; no PR51 platform removed. Real-key climb to the R14 exit still works.
- Software-GL graphical subset 67 / 0 on all four candidates; 14 captures each for combined and transitions-only, 6 each for geometry-only and art-only. Captures were opened and inspected by QA and by Transition.
- Build hosted checks per package (Windows and macOS): source identity, allowlist, cold and settled import, baseline and preservation scripts, 25 TR05 suites, TR06 where present, two exports with equal resource payloads, exported scripts equal source, ART-07 and forbidden-path exclusion, release startup, all four launchers actually run with isolation check, 54 exported-input checks plus six exported-pack suites. Run [39211674090](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39211674090): 16 of 16 jobs succeeded.

Coverage kept distinct:
- Automated headless: yes (Linux, hosted Windows and macOS).
- Graphical: Linux software GL only; inspected captures; not a GPU, not Windows or macOS graphics.
- Human acceptance: none.
- Not tested: gamepad, sustained FPS, full unseeded campaign, 4 s watchdog firing path, upper R13 routes by direct play (rests on the platform diff and Level's suite), Apple Silicon beyond a headless launcher smoke, download verification (below).

## 5. Known items (kept separate)

1. With `--pm-staged-stair`, 9 stock stair-timing assertions fail (359 / 9) because they encode the old 0.65 s stair. They pass with the flag off. Default-on needs creator sign-off and a reviewed update of those checks.
2. Residual escape: wall jumps up the outside face of the gatehouse (x=296) reach feet y about -177 and leave the world; the existing fall recovery returns Kaze to the hallway. Closing it needs a game-wide room top or a movement change, which were out of scope.
3. Pre-existing: wall jumps up the R13 right wall also leave the world on PR51. Level's audit: of 39 wall-side walk-through exits, 24 reach above the room and 15 leave it; R6 to R7 and R9 to R10 doors sit 20 px off their support; R8 to R18 door overhangs its shelf by 28 px.
4. `verify_tr05_preservation.py` reports one line ("expansion build_room PR37 function exact") on geometry-only and combined because of Level's hook in `world_expansion.gd`. Build used a narrowly matched waiver; a reviewed exception is needed before any merge.
5. Two `.pyc` files are committed under `tools/pm_pilot_art/__pycache__/` on the Art branch and the combined candidate. They are excluded from every package and should be removed before any merge.
6. Placeholders: the stair climb uses the approved ART-04 held stair pose labelled "FULL GAIT PENDING"; arrival uses the approved idle cycle labelled "ARRIVAL KEY PENDING". These are not finished animation. Minor visual overlaps noted by Transition (destination plate over the E prompt; reduced-motion plate over the old stair box; room label over the gatehouse face from `world_expansion.gd`).
7. Art quality: layers are procedural and flatter than the painted ART-04 and ART-06 art, so a creator paint-over is likely. No locked-state door art. The 2.7 s staging preview is longer than the engine's 0.65 s loader, so the cinematic holds or proxies it.
8. Art-only package contains assets but nothing draws them without Transition's binding.

## 6. Asset provenance and approval status

| Asset | Provenance | Approval |
| --- | --- | --- |
| Canal layers `assets/pm_pilot/canal/*` (8 PNG) | generated by `tools/pm_pilot_art/` scripts, labelled procedural architecture; SHA-256 in `assets/pm_pilot/MANIFEST.json` | not approved; creator review pending |
| Wipe kit `assets/pm_pilot/wipe/*` | procedural, follows the repo TR-02 wipe direction, no third-party assets | not approved |
| Kaze poses | existing approved ART-04 held keys and idle/run strips only, composition only | previously approved art; this use is a staging placeholder |
| Missing animation | 69 frames at 320x724 pivot (160,600): 19 Canal exit, 18 arrival, 32 R14 to R17 stair; list in `docs/pm_pilot/art/MISSING_ANIMATION.md` on PR #55 | blocked on an artist or original layered Kaze sources |
| Higgsfield | not used; no credits spent; moderation not circumvented | n/a |
| ART-07 | excluded | n/a |

Art re-downloaded four files from GitHub and matched SHA-256 to local copies.

## 7. Dependencies, missing inputs, blockers

- Authored Kaze animation (entry, traversal, departure, stair gait): owner Art Mane or an artist; needs drawing access (the creator's Aseprite or original layered sources) and a decision on mirrored versus newly drawn left-to-rear turn.
- Download verification: owner Build/creator machine. This sandbox cannot reach the Actions artifact storage and `workflow_dispatch` returns 403 here, so `verify_download.py` was not run on the real downloads.
- Inner Windows ZIP hashes are only inside the Windows artifacts (`SHA256SUMS.txt`) and could not be read here.
- Build pinned QA's Phase A harness (`455f352e`) as an informational step, so its in-package QA hooks skipped; QA's final Phase B results (above) are on Linux only. Packages are therefore labelled QA pending even though QA's recommendation is positive.
- Each push to PR #56 re-runs the configured request through its path filter; later runs may create newer artifact sets. The set below is run 39211674090.

## 8. Downloads (Actions artifacts, 30-day retention, unsigned, internal playtest only)

GitHub-recorded outer SHA-256 and expiry. Download from the run page ([39211674090](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39211674090)) while signed in to GitHub; the artifact name below is what appears in the list. All expire 2026-11-18 about 07:03 to 07:15 UTC (about 03:03 to 03:15 on November 18 in New York).

| Artifact | id | outer SHA-256 |
| --- | --- | --- |
| PMPILOT-comparison-windows-combined | 12168313973 | `5973457b78da908ae495a6a9fd36dffc94f3ab53c5274185fb42fba9d77a4ee8` |
| PMPILOT-comparison-windows-transitions | 12168309004 | `cb7543dbe6a3632d76f011ce058580981f1b7946a122cc1e0500d62fb0b2d470` |
| PMPILOT-comparison-windows-geometry | 12168114813 | `c9a216340e5967edad4c759fe3a4934aed5bb97ffdda15173b8a166bf5372f79` |
| PMPILOT-comparison-windows-art | 12168084988 | `8260b4a63d469c3418943b23c6418b1bd1b965a491ec31797beea5a785d60bf8` |
| PMPILOT-comparison-windows-baseline-pr39 | 12168561583 | `488e297c44345ba0385c20df211836826e5cc85872f7613debc4e8227cd8f9fc` |
| PMPILOT-comparison-macos-combined | 12169380923 | `14025e428a51a79ebbc9d81077a4df1ad84b85bd34cbc6697a2dcb31ff8d9983` |
| PMPILOT-comparison-macos-transitions | 12168938051 | `24c469285a3c3ae9632e283b03bb97295ed7fa915859ef8d676438366b678c44` |
| PMPILOT-comparison-macos-geometry | 12169375725 | `bcc0e6bfdd784e2a85a5665581f9c8218841d0f482b77c076665984d2a2b9f3f` |
| PMPILOT-comparison-macos-art | 12169121941 | `50ebac52a335424fdcf858aec56eff1632e25e721fc67fc5d8690f3cabd28442` |
| PMPILOT-comparison-macos-baseline-pr39 | 12169076337 | `b71254c12aee2df3f111815d3eefc5177fed4f47a895dc20265263abb549983b` |

Direct artifact URL pattern: `https://github.com/cappy2yappy/momentum-fractured/actions/runs/39211674090/artifacts/<id>`. Evidence artifacts (`PMPILOT-QA-...`) and inner macOS ZIP hashes are listed in `docs/agent_handoffs/BUILD_PM_REPORT.md` on PR #56. The PR #52 BUILD-06 control packages remain separate and unchanged (expire 2026-11-17).

Verify on a machine with GitHub access and a full clone:
`python tools/pmpilot/verify_download.py --run 39211674090 --clone <full clone> --downloads <empty dir> --out <empty dir> --require-complete`

## 9. Launch instructions

1. Unzip the artifact, then the inner `Kaze-PMPILOT-<variant>-<host>-<sha8>.zip` into its own writable folder (one folder per variant). Compare the inner ZIP hash with `SHA256SUMS.txt`.
2. Windows: run a `Play-*.cmd`. macOS: run a `Play-*.command`; approve the unsigned app in System Settings, Privacy and Security if blocked. Do not open the EXE or app directly.
3. `Play-Fresh`: unseeded persistent campaign. `Play-Canal-Left`: Room 13, hold A through the door (no E). `Play-Cinematic-Pilot`: Room 14 stair, press E (passes `--pm-staged-stair`). `Play-Cinematic-Reduced`: same with reduced motion (F6 toggles).
4. Each variant keeps its own save under `profiles/<variant>-<Name>.json` and its own user-data folder; demo seeds are fixtures, not earned progression, and reset at each launch.

## 10. Creator tester checklist (observations only)

For `baseline-pr39`, `transitions`, `geometry`, `art`, `combined`:
- [ ] Fresh starts, moves, jumps; second variant's Fresh starts from nothing.
- [ ] Canal-left: the visible door is where the crossing fires; the approach reads as an enclosed hall; walk, sprint, jump near the door, stop and reverse, leave and return.
- [ ] Try to climb above the exit inside the hall: contained; other R13 vertical routes still work.
- [ ] `combined`: Art door layers over the opening and the gatehouse masonry; `art` alone shows nothing new.
- [ ] Stair pilot (`transitions`, `combined`): about 2.35 s staged sequence with wipe, control returns; reduced motion about 0.95 s.
- [ ] Movement, size, combat, saves feel identical to baseline.
- [ ] Note every placeholder label and any held pose that looks like fake animation.
- [ ] Try the outside of the gatehouse (x=296) and the R13 right wall to judge the wall-jump residuals.

## 11. Decisions requiring creator review

1. Visual acceptance of the Canal architecture, wipe, and the transition presentation (pending; Art expects a paint-over).
2. Wall-jump residuals: accept, or authorise a game-wide room top or wall-jump limit (a movement or blanket-ceiling change).
3. Staged stair: keep opt-in, or make it default (requires updating 9 stock assertions).
4. Authorise authored Kaze animation work: who draws the 69 frames, and with what tools or sources; mirrored or new left-to-rear turn.
5. Story proposals needing approval (PR #54, labelled proposals): Canal-left as a covered masonry service gallery through the mooring wall; R14 to R17 as the stair pilot; flagged canon questions (R0 shelter status open between ST-03 and ST-04; R0/R13 portal height mismatch 780 vs 1200; stair direction is provisional; `docs/CANONICAL_BASELINE.md` stale; R11 refuge naming under review). `GDD.md` is absent from this tree.
6. Reviewed preservation exception for the one `world_expansion.gd` line; removal of committed `.pyc` files before any merge.
7. Fix of other exit mismatches in the audit (doors 20 and 28 px off their supports), and whether to extend containment to other exits.
8. Whether to add a hosted Apple Silicon graphical job; none exists today.
9. No merge, main update or release is requested or implied.

## 12. Honest limits

Work stops when the session stops; nothing here continues in the background. Automation did not establish human, gamepad or FPS acceptance, and no Windows or macOS graphical session was run.
