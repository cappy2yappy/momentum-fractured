# HYGIENE PM report: asset hygiene and bytecode cleanup (Wave 3 follow-up)

Model: Claude Sonnet 5.5. Environment: Linux cloud container, Godot 4.6.1 stable headless (no GPU, no human playtest). Nothing here is creative acceptance; no animation art was touched.

## 1. Branch heads (old -> new)

| Branch | Old head | New head |
|---|---|---|
| art/art08-embodied-cinematic-animation (PR #62) | 61b321944f44df573a0d9d5d231d3d358823ef0d | 42c09dc0b277290377e73670fe947fba20874bb4 (cleanup); this report adds one doc-only commit on top |
| art/pm-pilot-passage-cinematic (PR #55) | dfab1cf2efcacb2a792fb578b72be2434b9e4411 | 2c004946e1b040ef8a185d28c084e1b7fae48a3f |
| candidate/pm-pilot-combined (PR #61) | 49ae3efe21dea6a9eba556ce2fbc8299b00412b9 | 56b0f4bfe6adfcdd2b76fc9216fbbef5104d66bf |
| feature/tr08-fullscreen-embodied-cinematics (PR #64) | 45d669703349fbeafd5a28c1871980691d1a6e6f | 079d9b28d30423a9b38fccb1cc2b9784ce4eab96 |
| feature/ld05-intentional-world-boundaries (PR #63) | a6e3de254185cb76b1546c2723b707f4154e9f68 | 658ed34c2d182dd650c1d22b8fa6b3a6c43ca837 |
| docs/wave3-coordinator-report (PR #70, found by scanning all 90 origin heads) | 1361aa0c739e312bf3ba4fb23dfa7790d9b3f594 | 24046747252db7cc0f1e215ffa530c19c14ee461 |
| candidate/wave3-combined (PR #71) | cb1a59c4395584c08f6fb4cb45ae8a57fdfcd5f8 | 869a3aa13e0ef76292ec7fd7578453a7d77c7b7d (tree 38d9e8e760488857aa51c9e8ad8ab1c36fb4d51e) |

All pushes were normal fast-forwards. Heads confirmed through `gh api repos/cappy2yappy/momentum-fractured/commits/<branch>`.

## 2. Committed bytecode

Scan: `git/trees/<sha>?recursive=1` on all 90 origin branch heads. Tracked bytecode existed on exactly six heads (the five above plus the combined base), always the same two files: `tools/pm_pilot_art/__pycache__/common.cpython-313.pyc` and `scene.cpython-313.pyc`. ART-08 also carried them. Each affected branch got one normal commit: `git rm --cached` of both files plus `__pycache__/` and `*.pyc` in `.gitignore`. candidate/wave3-combined was already untracked and gets the ignore rules through the merges.

History statement: NO history rewrite, NO force push, NO deleted commits. The old commits (and the old heads listed above) still contain the .pyc blobs and remain reachable in history, forks and clones. Only the new heads are clean. PRs that point at these branches now see new head SHAs.

Not touched: the other 83 origin heads contain no tracked bytecode.

## 3. .gdignore (ART-08 branch, commit 42c09dc)

Empty `.gdignore` files added to: `source_art/art08` (80 masters, parts, scripts, sheets), `docs/art/art08` (GIF previews, sheets, capture), `docs/agent_handoffs` (all *_evidence screenshots), `docs/level_design/alpha061`, `docs/pm_pilot/level`, `docs/tr05/previews`, `docs/tr06/evidence`. Existing ones (source_art/pm_pilot, docs/tr04, docs/ld03, docs/int_tr03_art04, docs/pm_pilot/art, docs/pm_pilot/transition) were left as is.

Deliberately NOT ignored: `assets/art08` (shipped strips), `tools/` (python plus gd scripts run via res:// path, e.g. tools/art08/capture.gd; contains no images that import), `tests/` and `tests/fixtures` (gameplay-adjacent scripts and fixtures), `scripts/`, `scenes/`.
Checked that nothing loads resources from the newly ignored directories: the only res://docs references in tests are `save_png`/`save_jpg` writes and FileAccess reads, which work with .gdignore.

Why it matters: export_presets.cfg excludes `tests/*,docs/*,tools/*,build/*,.autoconverted/*` but NOT `source_art/*`, so before this change, `source_art/art08` PNGs would have been imported and exported with `export_filter="all_resources"`. The .gdignore is currently the only thing keeping them out (the build07 audit does forbid `source_art`). Suggested follow-up for the owner of export_presets.cfg: add `source_art/*` to exclude_filter as a second layer (not done here, out of scope).

Left in place: ~35 already tracked `.import` stubs under source_art/art08 and docs/art/art08. They are now orphaned (ignored by Godot) but harmless; removing them is possible later. Untracked `.import` and `.uid` files that Godot generated in the worktree were not committed.

Cold headless import (`rm -rf .godot; godot --headless --path . --import`, exit 0): `.godot/imported` holds the 11 ART-08 strips (ctex plus md5) and zero entries from source_art/art08 or any ignored docs directory; the import log has zero mentions of source_art/art08 or docs/art/art08.

## 4. Art integrity

Before and after hash comparison on the Art worktree: 11 `assets/art08/*.png` sha256 identical (diff of `sha256sum` lists, before vs after cleanup, no difference); `MANIFEST.json` sha256 `a105571fa4776d04a6e99172c27f43d053f4f02e497ec23d1b1b3ec79f815847` identical; manifest verifier: 12 clip entries checked (11 files, door_walk_out aliases door_approach_walk), 0 mismatches, none unlisted or missing (door_turn_to_side stays `unfinished`, sha null). `git status assets` shows no change, including the `.import` stubs. Re-download from GitHub via the contents API at Art head 42c09dc and at combined head 869a3aa: all 11 PNG sha256 equal the manifest. No art status was changed (door_turn_to_rear remains stand_in, creator acceptance still pending).

## 5. Combined Wave 3 candidate

candidate/wave3-combined, previous head cb1a59c, three `--no-ff` merges (after `git fetch --depth=30`): TR-08 079d9b2 (= 45d6697 test-only head plus bytecode cleanup; combined had 308bbf1), ART-08 42c09dc, LD-05 658ed34. Result head 869a3aa13e0ef76292ec7fd7578453a7d77c7b7d, tree 38d9e8e760488857aa51c9e8ad8ab1c36fb4d51e.
Checks: 1700 tracked files; path set equals the union of the four parent trees exactly (0 extra, 0 missing); every blob is byte-identical to a parent blob; 0 tracked .pyc or __pycache__; `.gitignore` has the new rules; `assets/art08` tree identical to the Art head; ART-08 PNG hashes equal the manifest (see 4). The combined head does not contain this report commit (doc-only difference: docs/agent_handoffs/HYGIENE_PM_REPORT.md on the Art branch).
The `candidate/pm-pilot-combined` cleanup (56b0f4b) was not merged into the Wave 3 candidate (not needed: the candidate is already clean).

## 6. Export audit (real Godot pack)

From the combined head, `godot --headless --path . --export-pack "Windows Desktop" test.pck` and the same for "macOS" both worked without export templates (exit 0, 21,144,952 and 21,144,968 bytes). Audit with the build07 `tools/pmpilot/audit_pack.py` (ci/build07-wave3 7e5781e, forbidden parts build/tests/docs/tools/source_art/.autoconverted/.git, per-entry md5, world data match, main scene present): PASS on both, 639 entries. My additional regex asserts: no source_art/, tools/, docs/, tests/, build/, __pycache__, .pyc, art07 entries (0 hits). 272 addons entries; no .gdignore files in the pack. ART-08 entries present: assets/art08/MANIFEST.json, 11 `*_strip.png.import` remap stubs, and all 11 imported ctex textures under `.godot/imported/` (one per manifest strip, checked by name), plus the 10 tr08 script entries (remap and gdc). Note the raw PNG bytes are not in the pack (Godot ships the compressed ctex), so PNG sha256 cannot be compared inside the pack; the hash proof is on the repo files.

## 7. Limits

- History still contains the .pyc files and the old heads; only new heads are clean.
- Pack export is the Windows/macOS preset payload as a bare PCK; the actual .exe/.app/zip packaging and the code signing were not run (templates not available). Runtime behaviour of the pack was not launched.
- No gameplay or visual verification was done; imports were headless only.
- The wave3 combined tests were not re-run after the merge (only content-neutral ignore rules and .pyc removals changed, but that is a claim from the diff, not a test run).
- docs/wave3-coordinator-report was cleaned although it is the coordinator's branch; its head changed.
