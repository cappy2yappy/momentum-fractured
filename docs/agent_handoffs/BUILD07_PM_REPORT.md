# BUILD-07 PM report (Phase A prep, then Phase B comparison run)

Phase B result is in the section at the end. Phase A text follows unchanged except where marked SUPERSEDED.

Report id BUILD07. Branch ci/build07-wave3 on PR56 head 34f308ef. Model: Claude Sonnet 5.5. Environment: Linux cloud container, Godot 4.6.1 headless available, no export templates, so no local export.

## Done
- pins.json: variants w3-control (49ae3efe, tree 2a41ac47 asserted), w3-transition (PR64 775ef9ff), w3-level (PR63 a6e3de25), w3-art (PR62 61b32194), w3-combined (commit null until the coordinator sends it). Allowlists derived from the diff against 49ae3efe; ART-07 and protected gameplay files still refused; ART-08 paths forbidden in the pack for non-art variants.
- demos.json list `w3`: Fresh, Stair-Fullscreen, Stair-Return, Canal-Doorway, Canal-Return, Geometry-Test, Geometry-OpenTop, Reduced-Stair, Reduced-Canal. Isolated profiles and user-data as before. All launchers are marked PROVISIONAL.
- tools/pmpilot/w3_inventory.py: INVENTORY.json and INVENTORY.md per package (source SHA, every ART-08 clip with SHA256, label, alias, in-pack check, LD-05 switches and audited rooms, TR-08 flags, launcher args, export success vs native graphical validation NOT PERFORMED). Fails the build on unlabelled or approved clips, SHA mismatch, unlisted PNGs, ART-07, unexpected ART-08.
- build_package.py: variant tr08 flag, flags_no_tr08, list-valued fixture checks, Wave 3 README (states no clip is creator-approved, headless limits, ART-07 exclusion), GEOMETRY_TEST.txt from docs/ld05/room_audit.json, manifest validation_levels.
- Workflow: pull_request base list now includes ci/pm-pilot-comparisons; INVENTORY files uploaded. actionlint clean.
- tools/pmpilot/w3_prep_check.py local dry run.

## Local validation (real)
Detached worktrees at pinned SHAs: diff violations 0 for all four; inventory problems 0; ART-08 labels in PR62: candidate 11, stand-in 1 (door_turn_to_rear), unfinished 1 (door_turn_to_side, no PNG), 13 entries, 11 PNGs, door_walk_out is an alias; generated seeds equal TR08 fixtures (4 of 4) and pilot fixtures. Changed-file counts vs 49ae3efe: PR64 19, PR63 151, PR62 177. w3-combined plan is refused (no SHA), as designed.
Not run: any export, hosted candidate packaging, graphical capture.
request.json was set to a cheap preparation-smoke (w3-control, windows, quick) so the PR does not trigger candidate packaging; its result is not yet known.

## Observations
- PR63 adds 43 docs .import stubs and .uid files for existing scripts (allowed, docs never packed): owner may want to confirm intent. PR63 touches scripts/world.gd, world_expansion.gd, room_presentation.gd; the PR37 preservation waiver stays.
- TR-08 turns off with --pm-staged-stair; launcher flags handled per variant.
- docs/pm_pilot/build/README.md named in the brief does not exist in this branch; the package README now points to docs/wave3/build/README.md.
- TR08_DEMO_ARGS.md did not exist yet at last check.

## Needed for Phase B
1. Final candidate SHAs for Transition (real clip binding), Level, Art, and the combined Wave 3 branch SHA (and expected tree if known). Owner: coordinator.
2. Transition: confirm launcher args (DEMO_ARGS), especially R17 stair and Canal-Return start poses. Owner: Transition.
3. Level: confirm Geometry-Test start pose and room list. Owner: Level.
4. Whether to wire QA's wave 3 harness as informational. Owner: coordinator/QA.
5. Platforms (windows, macos, apple_silicon) and go for comparison runs.


# Phase B

## Pins used (final, from the coordinator)
| variant | commit | note |
|---|---|---|
| w3-control | 49ae3efe21dea6a9eba556ce2fbc8299b00412b9 (tree 2a41ac47...) | candidate/pm-pilot-combined, the build the creator rejected |
| w3-transition | 308bbf105dc6ea0eaaa14f7aadaa626abf4ca13a | PR64, real ART-08 clips bound; contains the same ART-08 files as PR62 (all 12 strips and MANIFEST.json compared by git blob id) |
| w3-level | a6e3de254185cb76b1546c2723b707f4154e9f68 | PR63 |
| w3-art | 61b321944f44df573a0d9d5d231d3d358823ef0d | PR62 |
| w3-combined | cb1a59c4395584c08f6fb4cb45ae8a57fdfcd5f8 (tree d76d23c9e57b189d29010943cd2ffcd02b35dcaf asserted by the build) | candidate/wave3-combined |
QA harness: PR65 e9eec5b509be5cb1833c42fed64926767aafa759, wired as an INFORMATIONAL step (`run_w3.py --only w3`, headless, 900 s). Its result is not readable from here (see limits); nothing gates on it.

Controls commit for the successful run: `cb42293ba1110f057c25a85fc2e9261300164946` (confirmed by the API). Launcher arguments are the final ones from TR08_DEMO_ARGS.md (PROVISIONAL marking removed). Local prep check against the new heads: 0 allowlist violations and 0 inventory problems on all five.

## Runs
| run | controls commit | result |
|---|---|---|
| 39361970460 | 79f7520c | preparation-smoke w3-control, Windows, quick: success |
| 39364847805 | c44576aa | comparison, all five: Windows control and level succeeded; transition, art, combined FAILED (see incidents). macOS skipped. No packages from this run are to be used. |
| **39366130916** | cb42293b | **comparison, all five variants: plan, 5 Windows, 5 macOS (Intel host, Universal), 5 Apple Silicon launcher smoke: all success** |

Run 39366130916: https://github.com/cappy2yappy/momentum-fractured/actions/runs/39366130916. Windows jobs ran about 5 to 7 minutes, macOS 8 to 19 minutes (control longest).

## Incidents and decisions (read these)
1. **Art's source_art/art08 has no .gdignore.** The first run failed in w3-art and w3-combined with `Forbidden PCK entry: source_art/art08/frames/door_cross.json`: the Art source folders (about 80 files) would otherwise ship inside the game pack. Fix applied BY THE BUILD, not in the pinned source: pins `build_gdignore: [source_art/art08]` writes an untracked empty `.gdignore` into that folder after the clean-source check; it is recorded in each MANIFEST as `build_overlays`. The pinned tree is unchanged. Art should commit the file (the PR55 pilot did) and remove the committed `.png.import` stubs under source_art/art08. After the overlay, `assets/art08` resource group hash is identical in art, transition and combined (`ca075a1844`), as expected for identical files.
2. **tests/native_cinematic_transitions.gd (the exported-pack native input suite) does not pass on TR-08.** In run 39364847805 w3-transition failed it with FAIL lines including `Native physical input crosses [13, 0] without E and lands`, `Native [13, 0] visible live Kaze restored` and `Native E stair_14-17_cinematic staircase completes safely` (and stair_17-14). Transition did not touch that file (TEST_CHANGES.md lists the other suites). Cause is NOT verified; consistent with fixed waits written for the old 0.65 s / wipe timing, but it could also be a real regression. Decision: for w3-transition and w3-combined only, that one check is informational (`native_input_informational`): the FAIL lines are recorded in MANIFEST `findings` and in QA_RESULTS. Every other check stays gating. The coordinator or Transition should decide. I could not read the manifests of the successful run, so whether it passed on 39366130916 is UNKNOWN to me; the QA artifacts hold the answer (read `findings` in MANIFEST.json of the transition and combined packages).
3. The first run also showed the wasted macOS stage: macOS only starts if every Windows job succeeds, so one failing variant skipped all macOS jobs.
4. The control 49ae3efe tracks two `.pyc` files under tools/pm_pilot_art/__pycache__; the combined branch deletes them. The combined allowlist permits that deletion. Packages never contain them (tools/ is excluded).

## Packages (outer artifact = zip that GitHub serves, containing the package zip, MANIFEST.json, QA_RESULTS.json, SHA256SUMS.txt, INVENTORY.json, INVENTORY.md)
Digests below are GitHub's own `digest` field from the artifacts API. Expiry is 30 days from upload (all about 2026-11-19 03:52 to 04:15 UTC).

| artifact | id | bytes | GitHub digest (outer sha256) | expires (UTC) |
|---|---|---|---|---|
| PMPILOT-comparison-macos-w3-art | 12240008505 | 81006187 | `8bf6ebf3cd6ed2173997b3b56865332bdf95b406a9c84311df17feb163c8bdd4` | 2026-11-19T04:08:07Z |
| PMPILOT-comparison-macos-w3-combined | 12240491121 | 81031667 | `3d97936571cfadb4f2cdc551c57ef396a193c84a55af5c999ae0b0620e74886e` | 2026-11-19T04:09:42Z |
| PMPILOT-comparison-macos-w3-control | 12240740248 | 77697752 | `5705548a7e34e7aae5b5ea622012da0baafb9e2b3c0e4d7568924bda9065eccc` | 2026-11-19T04:14:01Z |
| PMPILOT-comparison-macos-w3-level | 12239818632 | 77707263 | `73573b294e4d73dafe67f8f93a68166043b75749a5dcec2d7b6b906b35f7aed2` | 2026-11-19T04:06:55Z |
| PMPILOT-comparison-macos-w3-transition | 12239993580 | 81023443 | `8bd0e953a5b2b1f6dedf98c8272506449a81d6a388babb861e91bccdbd2b13aa` | 2026-11-19T04:08:40Z |
| PMPILOT-comparison-windows-w3-art | 12239786712 | 56344408 | `b77244e183122c03991f95765237719f5508bb7c5e0359544b8f11f6006b0c3d` | 2026-11-19T03:54:43Z |
| PMPILOT-comparison-windows-w3-combined | 12239836292 | 56372345 | `c8ad6b55953c99869c7dfef1c2bcffb420f8129fcae9ce4f08cb5031deeb458e` | 2026-11-19T03:52:53Z |
| PMPILOT-comparison-windows-w3-control | 12240245612 | 53037811 | `e6ce37b834305b1ffd145d0639e4c11d8a72589c4b9de649a78834dfe2a0256d` | 2026-11-19T03:54:59Z |
| PMPILOT-comparison-windows-w3-level | 12239557106 | 53046081 | `f5b760881677156b52c477b9d68edd88a53549a6dca16e6f49ccdd516084d7a0` | 2026-11-19T03:54:52Z |
| PMPILOT-comparison-windows-w3-transition | 12239328676 | 56362650 | `6e9711bd23e8d25d49689b18c5e744d0292b1c9d098275ac5aff7c5453139bee` | 2026-11-19T03:54:22Z |

QA artifacts (evidence logs, QA_RESULTS.json; `if: always()` upload):

| artifact | id | bytes | GitHub digest (outer sha256) | expires (UTC) |
|---|---|---|---|---|
| PMPILOT-QA-comparison-macos-w3-art | 12239958546 | 117574 | `9fe88a3ac7d22526c13f9f5edde3e024b19ab862a1ecb86676cccdfff1671104` | 2026-11-19T04:08:13Z |
| PMPILOT-QA-comparison-macos-w3-combined | 12239938933 | 123447 | `e03218ef1152b61beebd2d47054845673aae3a2e00df6752933b125f42aaf2cd` | 2026-11-19T04:09:47Z |
| PMPILOT-QA-comparison-macos-w3-control | 12239869644 | 111959 | `9cb0bc5ffc000a34538d92636aa3b0574ccbf59ad2981b47109e9403c1ba1bd6` | 2026-11-19T04:14:09Z |
| PMPILOT-QA-comparison-macos-w3-level | 12239833533 | 114462 | `010cf8b5a9b355a030b51575fa6edc6f37979707f11bc01a40f1b19460da0438` | 2026-11-19T04:06:59Z |
| PMPILOT-QA-comparison-macos-w3-transition | 12240108303 | 119826 | `46e5e006643b82a2a67eae6a7b749acd94c386569b22313bc6c2a27ddeac0884` | 2026-11-19T04:08:46Z |
| PMPILOT-QA-comparison-windows-w3-art | 12240205842 | 117764 | `378c7f5ccb024ef47d15d353b158bfe0bcbadac2bcbd12d0dccd6f9b204e8b66` | 2026-11-19T03:54:46Z |
| PMPILOT-QA-comparison-windows-w3-combined | 12239487255 | 123628 | `1a9b274bcb3e417309aa9b4296567393c3b40371eec56dfedcd09974a9c51ece` | 2026-11-19T03:52:56Z |
| PMPILOT-QA-comparison-windows-w3-control | 12239324000 | 112104 | `ca28f2dce62df5677a543503b3dd5e25012ff670887958634e829f614ba7f3a0` | 2026-11-19T03:55:02Z |
| PMPILOT-QA-comparison-windows-w3-level | 12239487556 | 114681 | `21e8b9603142bbc3496b98032a70c0c93b6f84de29d807276acf4b0889cb2e67` | 2026-11-19T03:54:55Z |
| PMPILOT-QA-comparison-windows-w3-transition | 12240006283 | 119999 | `fa69e39b2fc8dfb901dc1753e785302c19187adea20a4ac58122eb603ce587f1` | 2026-11-19T03:54:24Z |

Canonical resource hashes from job annotations (the pack payload hash; cross-run and cross-host identity is not claimed, as BUILD-06 already warned):

| variant | host | canonical resource sha256 (export-pack payloads) |
|---|---|---|
| w3-control | windows | `68c24c9e725201190e4e063e2a729b018307f773733882e767e56c28f55e21a9` |
| w3-transition | windows | `dac86fa2ef6c2d62fb8cb088261f32ea1a0d4a459e110970850dd0ad56aa087c` |
| w3-level | windows | `85602859e582fd32ec45daa14fb671bb17ac22cac7a98977d81200ad2221cb30` |
| w3-art | windows | `de52e62e4740ae79f6e8c2b93a8d8dccd1476fb6e7b599347f2e539f7ba12a2b` |
| w3-combined | windows | `a742887caab447539eae681fd82cf1126b399001d8c5df00246cc42d4bb7dd99` |
| w3-control | macos | `af0385fc2af5c6a2f8366ecc1fae7c7996ea8234601904e4a4f148f9444ef9e3` |
| w3-transition | macos | `f09847072e72ff4a7d4398fa03ab3d58d0151a7c6fa923a5fff21763bbe5e91a` |
| w3-level | macos | `f20b69d2558fa1d6fb8fe1921d20be5e2ffd04407247bbd8516b4a16ffcff474` |
| w3-art | macos | `232ff5b6ed07e759175f1d59d4b047eca467d76f4b5f7bd242a167f8bf70e32e` |
| w3-combined | macos | `d51c073f566a43647c6ae8a5e8b04427cfab78c52b1c4d843ce064b37d0070d0` |

## Verification status, stated plainly
- **Outer SHA-256 verified against GitHub's artifact digest: NOT DONE by me.** I could not download any artifact: the sandbox gets an empty file because the blob host (productionresultssa*.blob.core.windows.net) is not reachable, the same as last time. So `verify_download.py` was not run and no inner hash, member hash or pack payload was independently re-checked here. The table's digests are GitHub's recorded values, copied, not recomputed. Anyone with network access can run `python tools/pmpilot/verify_download.py` from a clone holding all pinned commits.
- Job logs are blocked too; job annotations (failure text and the resource-hash notice) were readable and used.
- What the successful run itself asserted (inside the jobs, per the build code): HEAD and tree equal the pins; allowlist diff clean; ART-07 absent from source, pack and package; export twice with equal resource payloads; text scripts in the pack equal source bytes; INVENTORY built with 0 problems (every ART-08 clip labelled, SHA256 matching the manifest, strips present in the pack, none creator-approved); launcher isolation on Windows and macOS; native headless release startup; exported-resource suites.
- Not verified at all: any graphical output, hands-on play, gamepad, FPS, signing. macOS Universal contains arm64 and x86_64; hosted macOS Intel executes x86_64 only; the Apple Silicon job is a headless launcher smoke.

## Export success versus native graphical validation
Every manifest has `validation_levels`: `export_success: true` and `native_graphical_validation: NOT PERFORMED`, with the statement that hosted runs are headless. The package README and INVENTORY.md repeat it. A green run means the source exported and scripted headless suites passed. It says nothing about how the stair, doorway or geometry look or feel. That is the creator's playtest.

## ART-08 labels (exactly as Art's MANIFEST.json, PR62 61b32194; identical files in PR64 and the combined branch)
13 entries, 11 PNG files: candidate 11 (stair_ascend_enter/loop/exit, stair_descend_enter/loop/exit, stair_arrive_idle_settle, door_approach_walk, door_cross, door_emerge, door_walk_out which is an ALIAS of door_approach_walk with the same file and SHA256); stand-in 1 (door_turn_to_rear: PR #41 frames re-registered, AI-derived lineage); unfinished 1 (door_turn_to_side: no PNG, none in any pack). None is creator-approved. SHA256 of every PNG is in each package's INVENTORY.md. Variants: w3-art ships the PNGs but nothing draws them; w3-transition and w3-combined bind them in game code; w3-control and w3-level contain no ART-08.

## Launch instructions
Extract the package zip fully into a writable folder (spaces are fine), then use the launchers. Windows: `Play-<Name>.cmd`. macOS: `Play-<Name>.command` (unsigned and unnotarized: right-click, Open; if blocked run `xattr -dr com.apple.quarantine <folder>` once). Each launcher writes only to `profiles/` inside the folder.

| Launcher | Start | Do |
|---|---|---|
| Play-Fresh | new unseeded campaign (persistent profile) | normal play |
| Play-Stair-Fullscreen | R14 feet (1410,478), 40 px left of the stair | press E: ascent R14 to R17 |
| Play-Stair-Return | R17 feet (1650,1298), 30 px left of the stair | press E: descent R17 to R14 |
| Play-Canal-Doorway | R13 feet (330,1158) on the hallway shelf | hold A, no E: through the Canal doorway to R0 |
| Play-Canal-Return | R0 feet (650,778), 60 px right of the Mooring Loft door | press E: through the R0 door, emerging in R13 |
| Play-Geometry-Test | R13, all 21 rooms on the map, all abilities | try to leave intended space; see GEOMETRY_TEST.txt (LD-05 builds) |
| Play-Geometry-OpenTop | same, `--ld05-open-top` | roof course off, for before/after |
| Play-Reduced-Stair / Play-Reduced-Canal | as above with `--tr05-reduced-motion` | F6 toggles live |

Builds with TR-08 (w3-transition, w3-combined) use no flag (TR-08 default-on). Builds without TR-08 (control, level, art) pass `--pm-staged-stair` on stair launchers so the old staged stair shows; `--pm-staged-stair` is an OFF switch for TR-08 and must never be added to TR-08 launchers. Seeded unlocks are QA fixtures, not earned progression.

## Tester checklist (compare in order: control, transition, level, art, combined)
- [ ] Canal doorway (Play-Canal-Doorway, then Play-Canal-Return): does Kaze physically walk through the doorway with moving limbs, or does the screen wipe? Control and level/art should wipe; transition and combined should show the embodied passage. Is the bottom destination label still there?
- [ ] Staircase (Play-Stair-Fullscreen, Play-Stair-Return): is it full screen? Does Kaze climb and descend with a real changing leg animation or a held pose? Control: old stair; transition and combined: the full-screen stage.
- [ ] Which clips look unfinished: door_turn_to_rear (stand-in) and the missing door_turn_to_side (unfinished) should be visible as gaps in the doorway sequence. None of the candidates is approved; judge them.
- [ ] Reduced motion variants: still readable, no zoom or pan.
- [ ] Geometry (Play-Geometry-Test): wall-jump, double jump and dash at the walls and tops of the listed rooms; compare Play-Geometry-OpenTop. Does the level guide you or still allow unintended areas? Anything the roof course blocked that you think is legitimate?
- [ ] w3-art alone should look identical to the control (assets present, nothing draws them).
- [ ] Movement feel unchanged in all five.

## Coverage limits
No human playtest, no gamepad, no sustained FPS, no graphical validation, no signing. Hosted runs are headless. The QA Wave 3 informational step ran headless on Windows and macOS hosts but its output was not read by me. Apple Silicon is a launcher smoke only. Artifact bytes were not downloaded or re-hashed by me.

## Files changed in Phase B
tools/pmpilot/pins.json, demos.json, build_package.py, request.json (reset to a cheap preparation-smoke after the comparison run, because every push to this PR re-triggers whatever request.json holds: a report-only push re-ran the comparison as run 39368721353, which could not be cancelled via the API (403) and was superseded by this reset through the concurrency group; to rebuild, push request.json with the five w3 variants, purpose comparison, platforms both, apple_silicon true), docs/agent_handoffs/BUILD07_PM_REPORT.md.

## Environment
Model Claude Sonnet 5.5. Hosted: windows-2022, macos-15-intel, macos-15 (Apple Silicon). Engine Godot 4.6.1.stable.official.14d19694e, checksum-pinned install.


# Follow-up: verification of run 39366130916 and targeted rebuild plan (no rebuild started)

## 1. What can be established from the API about run 39366130916
- Run head cb42293ba1110f057c25a85fc2e9261300164946, event pull_request, attempt 1, 03:47:29Z to 04:15:10Z. All 16 jobs report head_sha cb42293b and conclusion success; no step in any job had a non-success conclusion.
- pins.json at cb42293b (read with git show): w3-control 49ae3efe (expected tree 2a41ac47), w3-transition 308bbf10, w3-level a6e3de25, w3-art 61b32194 (build_gdignore source_art/art08), w3-combined cb1a59c4 (expected tree d76d23c9, build_gdignore), `native_input_informational` true on transition and combined; QA harness e9eec5b5. request.json at that SHA: the five w3 variants, comparison, both, apple_silicon true, quick false. Matches the pins the coordinator supplied.
- Source SHA per variant: the build asserts `HEAD == pinned commit` and, for control and combined, the tree, and fails otherwise; every job succeeded, so the assertion held. That is inference from code plus green jobs. No log or annotation prints the SHA itself, so I cannot show it directly. (The rebuilt tooling now does.)
- Artifacts: exactly 20 (10 packages, 10 QA), no unexpected names; ids, sizes, digests and expiry are in the Phase B table above.
- Independent evidence that is readable: the resource-hash annotation of each of the 10 package jobs. It shows entry counts (control 542, level 543, art 565, transition 570, combined 571 on both Windows and macOS) and group hashes: the `assets/art08` group hash is `ca075a1844` in art, transition and combined on both hosts; `scripts/room_boundary.gd` is `bb4d33303b` in level and combined; the five `scripts/tr08_*.gd` hashes are identical in transition and combined; no group for `source_art`, `tools`, `docs` or `art07` appears in any pack. Level adds exactly one entry over control (room_boundary.gd); art adds 23. This supports "no extra source_art, no ART-07, ART-08 files identical across variants" and the .gdignore overlay having worked. It does not prove per-file content (only group hashes) or the manifests.
- NOT readable from here: MANIFEST.json, INVENTORY.json and INVENTORY.md, QA_RESULTS.json, SHA256SUMS.txt, the packages themselves, all job logs, and step summaries (the build wrote none). Consequently unknown: the inner archive hash, the `findings` list, whether the TR-08 native input suite passed or failed on that run (it was informational), the QA Wave 3 informational result, ART-08 clip hashes as packaged, and launcher isolation results (asserted in-job, not shown).
- Download retried today for a package artifact (12239836292) and a QA artifact (12239487255): the API returns a redirect to productionresultssa12.blob.core.windows.net and the sandbox proxy answers `CONNECT ... 403` (proxy status lists `connect_rejected`, policy denial for that host). Zero bytes written. It is a standing proxy policy, not transient.

## How integrity can still be established without blob downloads
1. This branch now echoes the key facts into check-run annotations at the end of every package build (identity, checks and findings, inventory with every ART-08 clip hash, launcher args). A rebuild makes the answers API-readable.
2. Fallback for the existing run, for the creator (who has GitHub access): from a full clone containing the pinned commits, `python tools/pmpilot/verify_download.py` (see its docstring for arguments; it re-assembles each pinned source, checks outer digest, inner SHA-256, every member, every pack payload, ART-07 absence and the QA pass state) and paste the output. At minimum, `shasum -a 256` of each downloaded outer zip against the digests in the table above, and open each package's MANIFEST.json and INVENTORY.md.

## 2. Targeted rebuild plan
See `docs/wave3/build/REBUILD_PLAN.md`: TR-08 45d66970 (native suite 54/0) with `native-exported-input` blocking again, committed `.gdignore` required instead of overlaid (new SHAs from the hygiene agent are NOT guessed and not pinned), Windows combined first then macOS, cost about 21 job-minutes in 5 jobs versus about 109 in 16 for the full matrix. Tooling pushed: build_package.py (blocking suite, require_gdignore, facts notices, pack_file_list_sha256), pins.json (allowlists include tests/native_cinematic_transitions.gd; informational key removed), w3_prep_check.py, new w3_repin.py. Local checks: py_compile, emit_facts exercised on a real PR62 inventory, w3_repin dry run against 45d66970 (0 allowlist violations, 0 inventory problems, tree fdd33d4f).
Not done: no rebuild, no new pins, no change to request.json beyond the cheap smoke already there. Pushing these changes triggers the existing cheap preparation-smoke (w3-control, Windows, quick), which also exercises the new code path on a hosted runner.
