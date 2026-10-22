# Kaze — home-machine recovery, October 22, 2026

Audit prepared 2026-10-22T17:40:19.903414-04:00. Repository: https://github.com/cappy2yappy/momentum-fractured (public, connected account verified with push/admin access).

The Alpha 0.7 specialist work is on GitHub in draft PRs. Main is not the Alpha 0.7 integration. No PR was merged, no history was rewritten, and Candidate 3 was not changed. New recovery branches preserve previously unpublished local QA/source checkpoints with explicit handoff notes. This task changed documentation only; it did not re-run gameplay acceptance.

## Recover on the home computer

Install Git, Python 3 and Godot **4.6.1**. Mac recording tools additionally need Xcode Command Line Tools. Use a normal full clone; the reference scan found no Git LFS pointer assets or submodules requiring a separate acquisition step in these recovery snapshots (check the verification record for scan scope).

```sh
git clone --branch docs/home-recovery-20261022 https://github.com/cappy2yappy/momentum-fractured.git kaze
cd kaze
git fetch origin
git status --short
git rev-parse HEAD
git rev-parse '@{upstream}'
```

For an existing home checkout, first inspect `git status --short --branch`; leave home edits in their own checkout, fetch origin, and create separate worktrees. Do not pull across unrelated foundations.

Start with the authoritative QA composition when reproducing the previously combined runtime. It includes INT01 follow-up and the earlier story/compliance composition; ART09 and ASSET01 remain separate review streams. Its old local source is preserved beneath a documentation-only recovery note. This is an isolated test snapshot, not a creator-approved campaign build.

```sh
git worktree add ../kaze-alpha07-qa --track -b home/alpha07-qa origin/recovery/alpha07-qa-authoritative-20261022
git worktree add ../kaze-art09 --track -b home/art09 origin/codex/alpha07-animation
git worktree add ../kaze-story --track -b home/story origin/codex/alpha07-story-cinematics
git worktree add ../kaze-int01 --track -b home/int01 origin/codex/alpha07-int01-remote-followup
git worktree add ../kaze-assets --track -b home/assets origin/codex/asset01-intake
```

Run `git rev-parse HEAD`, `git rev-parse '@{upstream}'` and `git status --short` in each fresh worktree. Heads should match the pin tables at this cutoff; later intentional owner commits may advance remote branches. `git diff --exit-code HEAD '@{upstream}'` verifies tree equivalence when histories differ. The three snapshot branches use handoff notes rather than integration PRs to avoid suggesting that duplicate experimental implementations should merge.

## Published feature pins

All PRs #80–#92 were verified open, draft and unmerged against the GitHub API; remote branch refs matched their API head SHAs. Full base pins and titles are in `pr-pins.json`.

| PR | Branch | Verified remote SHA |
| --- | --- | --- |
| #80 | `docs/alpha07-production-plan` | `8a915f277b6304a25b90eb3c09195ae090020747` |
| #81 | `narrative/st05-discoveries` | `1d157f4b7014ad1c05e231a8787594d57b5e33a3` |
| #82 | `feature/haz01-toolkit` | `33e70874cd938200f47bcabc1283c7581f17696b` |
| #83 | `feature/en01-alpha07-enemy-framework` | `5265e6c6182d883432215f4e9beab50255e48b5e` |
| #84 | `candidate/alpha07-integration` | `1f01e4078d2c2c219a1c3fffbc376ac6097df107` |
| #85 | `codex/alpha07-animation` | `378b86ca47130ede1663674d82f3cfe6bd00511f` |
| #86 | `codex/alpha07-story-cinematics` | `2d459743bce4a11a2d6bed1ae75d0c6d3adf3d5f` |
| #87 | `codex/alpha07-compliance` | `5172db6898f3efc35b74f3c134293049165b9bf7` |
| #88 | `feature/int01-story-director` | `2fa6cd6a03de599b7f9098e8bf61f8d770784091` |
| #89 | `codex/alpha07-int01-remote-followup` | `3dc433cd7b537391f218864abeb2398dc671ccb0` |
| #90 | `codex/alpha07-integration-readiness` | `95fe0a3694dfa6fda01806c269f7ee9d7de0903c` |
| #91 | `codex/alpha07-coordination` | `164daddd5bcf2d8a92a09fb864492d438a95e8f7` |
| #92 | `codex/asset01-intake` | `2dd5c4f671a34424e65c8399013d3a44e50b1350` |

Dependencies matter: #88 is the incomplete original checkpoint; #89 is its separate audited follow-up. #87 carries the HAZ01 implementation from #82, so these must not be independently layered without owner review. #90 publishes QA reports/tests; the recovery snapshot below preserves its otherwise-local combined source. #84 is a base-note branch, not the finished integration. #91 records source/ownership and acceptance limits. #85 retains the exact Image4 source, derived crops/catalog and manifests; it remains an incomplete pose study. #86 owns presentation and never progression. Existing room/story placements and production art acceptance still belong to the creator and their owners.

## Newly preserved local checkpoints

| Recovery branch | Remote SHA | Role |
| --- | --- | --- |
| `recovery/alpha07-qa-authoritative-20261022` | `2d08adfc242debc62451f30a8de1aeaeb4842d7a` | Authoritative combined QA composition. Recover this snapshot for isolated testing; PR90 publishes its reports but not the composed source. This snapshot has existing specialist changes composed locally before this audit. It is not an approved integration candidate. |
| `recovery/alpha07-qa-provisional-20261022` | `8fb4a75da08ab53a6d209d5806d51ed584324361` | Earlier provisional combined QA. Superseded by recovery/alpha07-qa-authoritative-20261022. Retain only for reproduction of earlier reported failures. |
| `recovery/alpha07-int01-experiment-20261022` | `0a8e6afff3d589cc5eb371863c54e987cb20dc8f` | Earlier INT01 reconstruction experiment. Superseded by original PR88 and audited follow-up PR89. Do not integrate this alternative implementation. |
| `recovery/legacy-fire-source-20261022` | `350b5c7ccbb2b7fcc40d1ef07ab63ea19321a640` | Historical source; original workflow unchanged; raw historical validation logs retain whitespace |

The original historical `recovery/legacy-fire-20261022` push was rejected by GitHub because the OAuth connection lacks `workflow` scope. Its local tip is `142eec554239d076e0c9fd8c85e690fad5882796`, original local source `84f82ee66a9618dd94ca5bfaa6ef16110bb8e8a0`. The separate `recovery/legacy-fire-source-20261022` preserves the source changes against the already-remote parent while retaining that parent's workflow unchanged. The unpublished workflow delta remains local; it was not uploaded via another API or embedded in a patch.

## Original Mac worktree state

`compared-repos.json` records 35 discovered checkouts, paths, local heads, initial statuses and remote comparisons. `verification.json` records the later upstream/status/ref checks. The initial search covered Documents, the project mirror, Desktop, Downloads, Artcraft, known home game directories and temporary workspace locations, then followed registered Git worktrees. Old game exports without Git are inventoried as references, not active feature branches. No stashes were found in the discovered repositories.

Five local Alpha07 branches have different commit IDs but **identical complete trees** to published versions: coordination, story-cinematics, asset01-intake, integration-readiness and int01-remote-followup. Their original local histories/upstream settings were left intact. In particular, some original branches track PR78 or PR80 instead of their actual published branch; an ahead counter against that configured upstream is misleading. Use the remote pins and tree comparison in the audit, or start the fresh home worktrees above. ART02 and LD05 local checkouts lag their remote branches; their local files must not overwrite newer remote work. Eighteen of nineteen ART02 untracked files exactly match remote blobs; the older completion report is retained only as an inventoried stale local variant. The ART03 QA_RESULTS.json change is line-ending-only and was not recommitted.

The `comparison-int01/` folder preserves the tiny synthetic comparison repository's final tracked text files, including its staged edits. It lacks a full game foundation and must not replace the original INT01 or PR89 implementation. Disposable tests generated for profile isolation are inventoried; their generator helpers and the committed QA runner reproduce them. No authoring gameplay changes were made during this audit.

## Recordings and ART09 recovery

These three generated MP4s stay local:

- `/Users/tonysantiago/Documents/Codex/2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative/outputs/story-cinematics/three-native-previews.mp4` — 3,284,989 bytes; SHA256 `1de4e2bfcdc72d299b516385c90be5997168ae860d52c1cd6dd74a72a34a42f0`.
- `/Users/tonysantiago/Documents/Codex/2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative/outputs/animation/native-staircase-baseline.mp4` — 2,022,819 bytes; SHA256 `7e7ac2d86316c492841a07b4cc98f82509c268ca4961d0369328151026c49d51`.
- `/Users/tonysantiago/Documents/Codex/2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative/outputs/art09-image4/native-image4-pose-studies.mp4` — 4,278,964 bytes; SHA256 `f471142a42e146427abf911606f80c4f38fc2e9fce3dea31bcbb158560a229d7`.

The feature sources and capture scripts are published. Recreate fresh native frames/timestamps on the destination; encoding can differ by machine/GPU, so reproduced movies are not promised byte-identical to the inventoried recordings.

On the story worktree, from its root:

```sh
GODOT=/Applications/Godot.app/Contents/MacOS/Godot
"$GODOT" --path . --log-file /tmp/story-capture.log --script res://tests/story_cinematics/capture.gd -- --test
swift tools/cin_tools_01/encode_capture.swift build/story_cinematics/video/timing.json build/story_cinematics/previews.mp4
```

On the ART09 worktree:

```sh
GODOT=/Applications/Godot.app/Contents/MacOS/Godot
"$GODOT" --headless --path . --log-file /tmp/art09-extract.log --script res://tools/art09_image4/extract.gd
"$GODOT" --headless --path . --log-file /tmp/art09-build.log --script res://tools/art09_image4/build_frames.gd
"$GODOT" --headless --path . --log-file /tmp/art09-verify.log --script res://tools/art09_image4/verify.gd
"$GODOT" --path . --log-file /tmp/art09-capture.log --rendering-method gl_compatibility tools/art09_image4/demo.tscn -- --test --art09-capture
```

See `docs/alpha07/art09-image4/README.md` for source hash/crops, the 323-sample/19.004-second original capture, and unfinished animation details. The older staircase-baseline clip came from the separate animation study; run `"$GODOT" --path . --log-file /tmp/stair-capture.log --script res://tests/cin_tools_01/capture.gd -- --test` and encode `build/cin_tools_01/capture/timing.json`. `helpers/encode_native.m` preserves the actual AVFoundation encoder used in the coordination workspace:

```sh
xcrun clang -fobjc-arc -framework Foundation -framework AppKit -framework AVFoundation -framework CoreVideo -framework CoreGraphics docs/home-recovery/2026-10-22/helpers/encode_native.m -o /tmp/kaze-encode-native
# Supply a newly generated timing.json containing frame time/path entries:
/tmp/kaze-encode-native /absolute/path/to/timing.json /absolute/path/to/output.mp4
```

Helper copies are archival source; this audit did not execute/retest them. They preserve local reproduction methods, not new test results. Original timing JSON often has Mac absolute frame paths, so regenerate or rebase those paths for the home computer.

## ASSET01 staging and rights

The six raw ZIPs total **98,829,985 bytes**, located in `/Users/tonysantiago/Downloads/Packs`. Their audited hashes, publisher provenance and per-file manifests are in #92. The raw archives, extracted PNG/PSD/AEP sources, 49 rendered gallery captures and duplicate staging trees are **not** published. The creator's permission to use/modify commercially does not authorize standalone asset redistribution into a public repository. The separate active controlled-pilot session records that attestation while preserving source-verification distinctions; consult `active-asset01/` and the final session snapshot.

Transfer legitimately acquired packs privately to the home machine or re-download from the identified publishers under their terms. Keep acquisition/permission records. On the ASSET01 checkout:

```sh
python3 tools/asset01/stage.py --source /path/to/Packs --stage /absolute/local/asset01-staging
xcrun clang -O2 -fobjc-arc -framework Foundation -framework ImageIO -framework CoreGraphics tools/asset01/scan_images.m -o /tmp/asset01-scan
/tmp/asset01-scan /absolute/local/asset01-staging/extracted /absolute/local/asset01-staging/inventory-initial.json
python3 tools/asset01/finalize_inventory.py /absolute/local/asset01-staging/inventory-initial.json --out /absolute/local/audit-inventory
cp /absolute/local/audit-inventory/packs.json /absolute/local/asset01-staging/gallery.json
./tools/asset01/launch.command /absolute/local/asset01-staging
```

These are the committed project's Mac commands; Windows needs equivalent platform image scanning or privately transferred metadata/staging and a Godot executable path. Neither a Windows run nor physical-controller verification is claimed here. Never execute third-party editable project content merely to inventory it.

## Anything not synced

The `inventory/files-*.jsonl` shards list **14,366** inspected local files with absolute Mac path, bytes, SHA256, Git blob and whether that blob was already reachable from a remote branch. `blob_already_on_remote: false` means the payload was absent at the inventory's remote snapshot, not that it is safe or useful to publish. Later preserved text helpers/snapshots are separately recorded; some older exports or duplicates differ only in packaging. No file payloads are embedded in the inventory. `local-summary.json` gives scope, category counts, total bytes and 32 aggregated `.godot` cache directories; no inventory read errors occurred.

Remaining payloads include the six source packs and extracted staging, generated preview movies/frames/contact sheets, generated app/export archives, final local PDF print packs and their source PDF, old non-Git prototype exports, personal/disposable profiles and saves, `.import` cache metadata, and the historical workflow delta. Local file inventories include these by name/hash; caches are aggregated by directory. Selected PDF generators are retained in helpers, but their original Mac source paths require adjustment and the inventoried input PDF must be supplied privately. None of these should be assumed recoverable from a Git clone merely because this manifest is published.

No caches, credentials, oversized new binaries, source asset ZIPs or local-only rendered previews were added by this task. New-object comparison confirmed inherited screenshot/art blobs were already present on GitHub; source recovery introduced text only. Credential-pattern checks are a bounded check, not a guarantee about every historical repository object.

Codex chat UI state, unsaved editor buffers, live Godot state and Claude application memory are not Git data. Local session metadata and process working-directory checks were inspected without exporting logs/credentials or process arguments. Active sessions can continue producing changes after this timestamp: the final asset-session snapshot defines this audit's recoverable cutoff.

## Verification and next owner

Passed: remote branch hash/PR-head comparisons, tree-equivalence checks, new-object type/size/exclusion/credential-pattern checks, staged documentation validation, and clean status checks for new recovery checkouts. Recorded historical test evidence is preserved in the existing specialist PRs and QA snapshot. Runtime/gameplay/Windows/physical-controller acceptance was **not run** by this sync task.

Next owner: developer on the home computer. Read #80/#91 ownership and contract notes, inspect #89/#87 interfaces, then use the isolated QA snapshot for reproduction. Keep the existing specialist PRs draft and unmerged until the normal acceptance gates are satisfied. Do not merge old experiments or alternative-foundation Fire work into the creator's campaign.
