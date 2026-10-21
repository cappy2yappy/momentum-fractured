# BUILD-07 targeted rebuild plan (HOLD: nothing is pinned or started until the coordinator says go)

## Why
Run 39366130916 is green but (a) three facts could not be read back from here (manifests, inventory and logs are in blob-hosted artifacts the sandbox cannot fetch), (b) `native_cinematic_transitions` was downgraded to informational for the TR-08 variants, and (c) Art's `source_art/art08/.gdignore` was a build-time overlay rather than committed source.

## Inputs still to arrive (never guessed; read /home/claude/wave3_shared/ and the coordinator message)
| input | known now | needed |
|---|---|---|
| Transition head | 45d669703349fbeafd5a28c1871980691d1a6e6f (tree fdd33d4f..., native suite 54/0 per TR-08) | none; confirm unchanged |
| Art head with committed `source_art/art08/.gdignore` | not yet | SHA from the hygiene agent |
| Combined candidate rebuilt on those | not yet | SHA and tree |
| Level, control | a6e3de25..., 49ae3efe... unchanged | none |

## Tooling already in the branch (this PR)
- `native-exported-input` is BLOCKING for every variant again (the informational downgrade and the pins key are removed). The allowlists for w3-transition and w3-combined now include `tests/native_cinematic_transitions.gd` (the only path outside the allowlist in the new Transition head; checked).
- `pins.json` `require_gdignore: [source_art/art08]` mode: the build asserts the pinned source TRACKS the file and creates nothing. The legacy overlay (`build_gdignore`) still exists for the old pins, is recorded as `build_overlays` in the manifest, and is empty in the new mode. `w3_repin.py` converts art and combined to `require_gdignore`.
- Echo-to-annotations: at the end of each package build the job emits four notices (readable through the check-runs annotations API): identity (source head, tree, pin equality, expected tree equality, inner archive sha256 and bytes, pck sha256, entries, `pack_file_list_sha256`, canonical resource hash, export reproducibility), checks (every check with pass/exit/assertion counts, findings, `build_overlays`, launcher isolation, validation level), inventory (ART-08 manifest sha256, label counts, every clip name/label/sha256/alias/in-pack flag, ART-07, LD-05 switches, TR-08 presence, problems), launchers (exact args). The existing resource-hash notice is kept.
- `tools/pmpilot/w3_repin.py`: dry run by default. `python tools/pmpilot/w3_repin.py --repo . --transition <sha> --art <sha> --combined <sha> [--combined-tree <tree>]` verifies every SHA resolves, takes the tree from git (and refuses a mismatching supplied tree), runs the local prep check (allowlist diff, inventory, fixtures, launcher text, tracked `.gdignore`), and with `--write` edits pins.json; with `--write-request` also writes request.json (committing that file IS the run).

## Rebuild sequence on go
1. Run `w3_repin.py` with the three SHAs (and `--level`/`--control` only if they changed); expect 0 violations and `gdignore_tracked` true for art and combined. Commit pins.json.
2. Run A: request `w3-combined`, purpose comparison, platforms `windows`, no Apple Silicon. Add `w3-control` only if the coordinator wants a same-run comparison package (the control is unchanged at 49ae3efe, so run 39366130916's control package already stands).
3. Read the four facts notices through the API and check: head equals pin, tree equals expected, `build_overlays` empty, native-exported-input passes (counts), clip hashes equal Art's manifest, `pack_file_list_sha256` recorded.
4. Run B (only after A is green and facts match): same request with platforms `macos` and `apple_silicon: true` (the macOS job accepts a skipped Windows job).
5. Update BUILD07_PM_REPORT.md with run ids, artifact ids, digests, expiry. Keep request.json reset to a cheap smoke afterwards, because any push to this PR re-runs whatever request.json says.

## Cost
Last run (39366130916), job minutes from the API: plan 0.1; Windows 5.3 to 7.5 each (combined 5.3), total 34.2 for five; macOS 11.8 to 19.3 each (combined 14.7), total 72.5 for five; Apple Silicon smoke 0.4 to 0.5 each, 2.3 for five. Full matrix: 16 jobs, about 109 job-minutes, wall clock about 28 minutes.
Minimal rebuild, combined only: run A is 2 jobs (plan, Windows), about 5.5 job-minutes, about 6 to 7 minutes wall; run B is 3 jobs (plan, macOS, Apple Silicon), about 15.5 job-minutes, about 16 minutes wall. Total 5 jobs, about 21 job-minutes (20 percent of the full matrix, 31 percent of its jobs). Adding the control to run A adds one Windows job (7.5 minutes) and, if wanted on macOS, 19.3.

---
# Update: gate prep for candidate/wave3-targeted (PR #74), HOLD for the coordinator's go after QA

Pin: variant `w3-targeted`, commit `c2c3d958abe8c1eb77e2851d29c00544bef63e80`, tree `8eb0bb92b34e0405ab9cf689e4652a5f57f3ca53` (asserted by the build), branch candidate/wave3-targeted, base candidate/wave3-combined. eb3cc0fa (TR-08 hang fix and tests) is merged in (d710901c). The older `w3-combined` pin (cb1a59c4) is left untouched as history.

Changes in pins.json for w3-targeted: `native_input_informational` absent (native_cinematic_transitions BLOCKING); `build_gdignore` absent, `require_gdignore: [source_art/art08]` (tracked file asserted); new `require_export_exclude: [source_art/*]` (build asserts export_presets.cfg exclude_filter, committed in the candidate, covers it); `allow_protected: [export_presets.cfg]` (the candidate edits it); allowlist adds .gitignore, export_presets.cfg, scripts/skyworks_region.gd, tests/skyworks_progression.gd, tests/st04_approved_copy.gd, tests/capture_st04_copy.gd, tests/tr08_*.gd, tests/ld05_boundaries.gd, tools/verify_tr05_preservation.py, docs/**. Required pack entries: assets/art08/MANIFEST.json, assets/art08/kaze_*_strip.png.import, scripts/room_boundary.gd, the TR-08 scripts, staged stair, Canal gatehouse, pm_pilot canal imports. The inventory now also fails the build if any ART-08 strip lacks a `.import` entry in the pack, if MANIFEST.json is not in the pack, or if any `source_art/` entry is.

Planned requests (templates, NOT request.json; pushing request.json is the run). Each push to PR #69 meanwhile only re-runs the cheap smoke currently in request.json.
1. macOS creator build: `cp tools/pmpilot/request.targeted-1-macos.json tools/pmpilot/request.json` -> variants `w3-targeted`, comparison, platforms `macos`, apple_silicon false.
2. ONE Windows validation build: `request.targeted-2-windows.json` -> same with platforms `windows`.
Order as asked (macOS first, Windows second); the macOS job accepts a skipped Windows job. Alternatively one request with platforms `both` runs Windows first then macOS (same 2 jobs plus plan). After each run, set request.json back to the cheap smoke.
Cost: 2 runs, 4 jobs (2 plan, 1 macOS about 15 min, 1 Windows about 5.5 min), about 21 job-minutes.

## Local dry run results (candidate c2c3d958, Linux, no run)
- `w3_prep_check.py --variants w3-targeted`: 0 allowlist violations (559 changed files vs 49ae3efe), 0 inventory problems, tree 8eb0bb92 equals the pin, `source_art/art08/.gdignore` tracked, no build overlay, 4 of 4 TR08 fixtures equal the generated seeds.
- Real pack listing: `godot --headless --export-pack "Windows Desktop"` on a detached worktree (text script mode as the build does) gave 573 entries; 68 text scripts byte-equal to source; 0 entries under source_art, tools, docs, tests, build or art07; assets/art08 holds MANIFEST.json plus 13 `*_strip.png.import` (one per shipped PNG, including the new stair_descend_arrive_settle); the inventory run against that pack returned 0 problems; all required entries present. Linux hashes are not claimed to equal hosted ones.
- ART-08 labels in the candidate manifest: 14 entries, 13 PNG files, candidate 12 (incl. stair_descend_arrive_settle and the revised descent strips, with the door_walk_out alias), stand-in 1 (door_turn_to_rear), unfinished 1 (door_turn_to_side, no PNG). None creator-approved.
- Not run locally: the full source regression suites and the exported-pack native input suite (hosted only).
- Observations: the candidate edits `export_presets.cfg` (protected, allowed explicitly) and narrows `tools/verify_tr05_preservation.py` (hygiene commit b2245387 "narrow TR05 preservation guard for approved R11 copy"); the build still runs that guard with the existing waiver, so a reviewer should read that diff. The allowlist includes `docs/**` because the candidate carries many evidence files; docs are never packed.

## Verification steps for the creator after the run
1. In the run's check-run annotations (API readable) read the four `pmpilot facts` notices: head equals pin `c2c3d958...`, tree `8eb0bb92...`, `build_overlays` empty, `native-exported-input` ok with a nonzero count, inventory problems empty, 14 ART-08 entries with the labels above and each clip sha256.
2. Download the artifact (expected: `PMPILOT-comparison-macos-w3-targeted` and `PMPILOT-QA-comparison-macos-w3-targeted`, then the same for windows) and compare `shasum -a 256` of each outer zip with GitHub's artifact digest shown by `gh api repos/cappy2yappy/momentum-fractured/actions/runs/<run>/artifacts`.
3. From a full clone: `python tools/pmpilot/verify_download.py` (it re-assembles each pinned source, checks outer and inner SHA-256, every member, every pack payload, ART-07 absence and the QA pass state; needs `gh` auth and a clone containing c2c3d958). Paste the output.
4. Open INVENTORY.md in the package: no clip is labelled approved; read GEOMETRY_TEST.txt for the room list.
