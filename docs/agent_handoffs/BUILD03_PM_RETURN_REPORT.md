# BUILD-03 PM Return Report

Date: 2026-10-15 UTC (creator session: October 14, New York).
Status: **Windows playtest delivered; ready for creator review. No merge or public production release.**

## Recovery and exact source

Repository: https://github.com/cappy2yappy/momentum-fractured

- Independently recovered CI-01 PR #13 (open), CI-02 PR #14 (merged), verified main c69efbb43aa49b71dc6c541820934487a170fa7b, and read PM-02 PR #18's Build Shogun CONTEXT/SESSION_LOG/RECOVERY. PR #18 remains unmerged.
- TR-02 PR #16 remains open. **Exported game source: e9a2d1ab0537f3f903c543b080451b3556961179**, branch feature/alpha-0.6.1-mixed-transitions.
- Dedicated infrastructure branch: ci/build03-tr02-playtest; [review PR #20](https://github.com/cappy2yappy/momentum-fractured/pull/20).
- Successful [Actions run 38674862607](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38674862607), CI branch head **7a02be64bfe508f39b1a7a724a2aa5ab2341ede6**. Last executable CI change: 220b93177b74ac4309fcc45e377e88f04dcaf38e. Subsequent publication commits contain documentation/evidence only and skip redundant CI.
- This is **TR-02**, not older integration candidate afecef19. No gameplay, specialist source, project settings, scene, export preset or personal save was changed. Audio specialist PR #17 was not combined.

## Recovered infrastructure and permissions

Existing CI-02 is reused: Ubuntu 24.04 installs official checksum-pinned Godot 4.6.1.stable.official.14d19694e and 4.6.1.stable templates, runs regression/preservation checks, exports Windows x86_64 embedded-PCK and macOS universal packages, audits ZIP/PCK contents, and runs native release headless startup on windows-2022 and macos-15-intel. Requires Python 3, official editor/templates, standard Actions checkout/upload/download and Git. No local creator compilation is required.

Linux editor SHA-256: cecd0cb6b55e931318a9d7237dc4197d69ea914966787a454808523626e2789f.
Templates SHA-256: e6d372afd4fdfaae9571eb5e3568afcd96ce6db9a569244034154faf0ac69875.

Actions retains contents:read, no persisted checkout credentials, no secrets added, no pull_request_target, no permissions/security-setting changes, bounded timeouts/concurrency and 21-day retention. Connected repository permissions report admin/maintain/push/pull; read-only GitHub branch API reports main protected:false with no required status checks. Creator's no-merge restriction remains binding regardless of technical permission. Git CLI push authentication was unavailable; connected GitHub app successfully published all recoverable work.

Prior run 38636982092 artifacts were independently queried and unexpired through 2026-11-04; they belong to the older integration candidate and cannot substitute for this delivery.

## CI changes and future operation

Only .github/workflows/godot-ci.yml and tools/ci helpers changed:
- Explicitly add the approved TR-02 source branch to the manual allowlist; no arbitrary source input.
- BUILD-03 review PR selects the verified TR-02 SHA, checks actual checkout identity, and keeps CI controls separate from game source.
- Package the committed TR-02 launcher/README recipe without the unrelated Pillow/GIF-generation dependency. Ten original comparison/fresh launchers and their explicit save override remain.
- Run mixed_profile explicitly with four valid isolated fixtures instead of auto-discovering it as a standalone assertion suite.
- Native Windows job launches all ten packaged launcher combinations in addition to ordinary main-scene headless startup.

Current main workflow remains unchanged until separately approved infrastructure merge. The tested route is PR execution; no manual-dispatch UI success is claimed for the new option. Future specialist/integration targets must be explicitly approved, allowlisted and source-identified; do not combine unfinished branches automatically.

## QA evidence

[Machine-readable verification, manifests, native reports and suite rows](BUILD03_VERIFICATION.json). All five actual Actions artifacts were downloaded through the connected GitHub app. Their outer SHA-256 digests, CRCs, game inner ZIP hashes, every manifest member hash, Windows AMD64 PE header, macOS two-architecture universal header and **529 hash-verified PCK entries per platform** were independently checked. Exact committed world data matches both packs, and mixed_transitions resources are present. No source/test/docs/tools/build payloads leaked into the PCK.

Independent local source archive initially applied Windows CRLF conversion to MapData.txt; it was corrected using the exact Git blob before final byte comparison. This was a verifier checkout difference, not a game-package defect. PowerShell HTTP download failed in this environment; Python urllib successfully retrieved and verified all artifacts. Neither issue remains a delivery blocker.

| Validation | Result and scope |
| --- | --- |
| Godot version, import/script parsing and preservation | Passed |
| Source regression | **897 passing assertions**, zero failed assertions, parser/load failures or hard errors |
| Suite accounting | 19 regression suites, two save restart stages, four explicit fixture checks |
| Baseline progression/gates/save checks | 691 assertions passed |
| TR-01 adjusted transition checks | 93 assertions passed |
| TR-02 directional/arrival/gating/presentation checks | 109 assertions passed |
| Fresh/walk/stair/special isolated save fixtures | Four checks passed, expected rooms 0/15/14/20 |
| Negative validator probes | Corrupt packs and zero-exit assertion/parser/load errors rejected; also passed locally |
| Windows/macOS export and actual PCK/ZIP audit | Passed |
| Native Windows AMD64 | Downloaded release startup and all ten comparison launcher boots passed, exit 0 |
| Native Intel macOS | Downloaded universal release main-scene headless startup passed, exit 0 |
| Audio initialization | Existing TR-02 game starts without hard audio initialization errors under headless runtime; audible output/mix and AUD-01/AUD-02 integration not tested/included |
| Automated transition comparisons | Source assertions cover all treatments, directional crossings, reciprocal arrivals, cooldowns, gates, reduced-motion policy and save compatibility. No new graphical comparison capture in this session |
| Human gameplay/input/graphics | Not performed |
| Apple Silicon native startup | Not performed for this build; universal binary structure verified |
| Sustained 60 FPS | Not certified; fixed-rate/headless startup is not a performance benchmark |

Known narrow engine shutdown leak/certificate diagnostics remain classified by the recovered CI validator; hard errors were absent. Node runtime/action deprecation notices remain infrastructure maintenance items. Superseded runs 38674729038 and 38674789799 were cancelled after newer commits; neither is acceptance evidence. Final run is successful.

## Actual downloads and checksums

Sign into GitHub to download Actions artifacts. The download is an outer artifact ZIP containing the game ZIP and BUILD_MANIFEST.json; extract both layers.

| Artifact | Download | Expiry UTC |
| --- | --- | --- |
| Windows TR-02 | [Windows download](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38674862607/artifacts/11945722171) | 2026-11-05T03:15:17Z |
| macOS universal | [macOS download](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38674862607/artifacts/11945887204) | 2026-11-05T03:15:19Z |
| Source QA/logs | [QA results](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38674862607/artifacts/11945867083) | 2026-11-05T03:15:17Z (approximately; exact API timestamp in evidence) |
| Windows native | [Native report](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38674862607/artifacts/11946625394) | 21-day retention; exact timestamp in evidence |
| Intel macOS native | [Native report](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38674862607/artifacts/11946385503) | 2026-11-05T03:15:42Z |

Inner Windows ZIP: **Kaze-TR02-Mixed-Transitions-Windows-e9a2d1ab.zip**, 51,162,244 bytes.
SHA-256: **edd8661a7a6b1bb2b528eb4c205e22ee84bae9629fe58c69daaae7ca998c2350**.

Inner macOS ZIP: Kaze-Alpha-0.6.1-Candidate-macOS-Universal-e9a2d1ab.zip, 75,954,928 bytes.
SHA-256: 28794062b7385994e27ded8a3d1d34edc11fb52e9b2e7cbd423c1521b0e4e1bf.
Despite the inherited candidate label, its manifest/source and independently audited pack are the exact TR-02 commit above.

Each platform manifest includes full source SHA/branch, engine/templates provenance, ZIP size/hash, member hashes and export QA. Later native results are separate artifacts; manifest's earlier native_boot field correctly records export-stage status.

## Windows installation and comparison

1. Download Windows artifact, extract the outer ZIP, then extract Kaze-TR02-Mixed-Transitions-Windows-e9a2d1ab.zip to a writable folder. No Godot install needed.
2. Open **Play-walk-graphic.cmd**. Wait about one second, hold D through the culvert. It should cross R15 → R16 automatically without E. Move at least 96px inward, wait, then cross back.
3. Compare Play-walk-plain.cmd and Play-walk-reduced.cmd.
4. Open Play-stair-graphic.cmd: E at the rooftop stairwell operates R14 ↔ R17. Plain/reduced variants are also included.
5. Open Play-special-graphic.cmd: E at the unlocked wind-fold operates R20 ↔ R13. Compare plain/reduced variants.
6. **Play-fresh-graphic.cmd** starts a separate unseeded campaign. All launchers use profiles/<pilot>-<treatment> beside the package and an explicit absolute --tr02-save path, not personal progress. Seeded progress is clearly QA-only. To repeat a genuinely fresh campaign later, close the game and remove only this extracted package's profiles/fresh-graphic folder.
7. Controls: A/D move, double-tap run, Space jump, Q held tether, Shift dash, J attack, F parry, R kunai, T element, E interact, M atlas, I kit, Esc pause. Full comparison instructions are included in README.txt.

Do not double-click the EXE directly for isolated playtests: direct launch retains normal game save behavior. The binary is unsigned internal alpha. macOS artifact is separately available, unsigned/unnotarized; this delivery does not add equivalent macOS comparison launchers.

## Known limitations and PM actions

Discrete 0.65s loader, 0.75s safety cooldown and 96px inward rearm remain as implemented. Horizontal carry is limited to the walk pilot; vertical/tether/dash transients retain safe-loader reset. Pilot art is prototype work. No topology expansion, global transition rollout or other specialist integration.

Creator: review plain/original/reduced presentation, automatic crossing/rearm feel, rooftop stair readability, wind-fold clarity and landings. Human campaign progression, broad graphics/input/hardware coverage and sustained performance testing remain open.

PM: review PR #20 infrastructure separately from gameplay PR #16 and decide future targets. No merge was performed. All source, CI changes, continuity records and this verification/report are published on the dedicated GitHub branch. Future expired artifacts can be reproduced from the documented exact source and CI controls.
