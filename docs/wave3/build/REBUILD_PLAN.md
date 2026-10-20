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
