# CI-01 Alpha 0.6.1 internal candidate builds

This infrastructure validates the approved combined GP/LD candidate without changing gameplay. Godot is pinned to `4.6.1.stable.official.14d19694e`; editor and export-template archives are SHA-256 checked against official godotengine/godot-builds release digests. Existing `Windows Desktop` and `macOS` presets, save identity, renderer, room graph, and asset preservation contract are unchanged.

## Events and first installation

Open a draft PR targeting `integration/candidate-alpha-0.6.1-gp-ld`. Source/infrastructure changes run QA and both exports; docs-only changes are ignored. Checkout uses the exact PR head SHA, recorded in filenames/manifests, rather than the synthetic merge ref. Rebase/merge conflict suitability remains a PM review gate. No push trigger or duplicate build exists. This workflow does not alter existing Alpha 0.5 CI.

`workflow_dispatch` supports the selected branch, `build_artifacts` (default true), and `negative_probe` (default false). **GitHub requires the workflow on the default branch before its Run workflow UI is available.** This unmerged CI branch alone does not install that button. PM must authorize any default-branch installation; never merge to enable it without that authorization. If PR events fail to create a run, record the observed absence and ask PM to approve a minimal infrastructure installation. No `pull_request_target` is used.

After installation: Actions → Kaze Alpha 0.6.1 QA and Builds → Run workflow → select the desired branch → leave build_artifacts enabled. negative_probe intentionally makes a run red after the validator checks; never select it for a deliverable build. Negative fixtures stay in memory and cannot change gameplay or saves.

## QA and packaging

One Ubuntu 24.04 QA/export job has a 30 minute cap. Two bounded native startup jobs then download the verified packages on Windows 2022 and macOS 14. Each has a 10 minute cap and reports the actual runner architecture; they launch the release main scene headlessly for 120 frames with disposable profiles. It reuses `tools/run_int01_qa.py` for import, baseline preservation, 17 known suites, and separate-process save prepare/reload. Additional top-level assertion suites are discovered and run with a disposable profile. Every known suite must exist. Processes have 300 second timeouts. Missing results, zero assertions, missing completion markers, nonzero exits, FAIL, parser/load errors and unrecognized engine ERROR lines fail validation. Exact known engine teardown leaks and the macOS headless noErr diagnostic are visible in raw logs and distinguished from hard failures.

Exports run only after QA passes. Templates are copied into disposable HOME/XDG export profiles. Windows contains an x86_64 executable with embedded PCK. macOS is an unsigned/unnotarized universal app ZIP. The pack checker reads Godot V2/V3 directories, verifies entry MD5s and required world text bytes, rejects forbidden directories, and verifies main/addon resources. ZIP CRC and universal binary headers are checked. Platform build manifests truthfully describe the export stage; subsequent native smoke results are published separately in Kaze-Native-Smoke artifacts and linked in the PM report. Headless startup does not test rendering or interactive compatibility. Build manifests include full SHA, branch, version/templates checksum, UTC time, QA outcome, sizes, archive/member SHA-256s, pack audit and native startup scope.

Artifacts are:
- `Kaze-Windows-x86_64-<8-character SHA>`
- `Kaze-macOS-Universal-<8-character SHA>`
- `Kaze-QA-Results-<8-character SHA>`

Both platform artifacts contain a candidate-labelled game ZIP and `BUILD_MANIFEST.json`. QA uploads run even on failure, containing only logs/reports, never profile directories. Retention is 21 days; re-run the same source before expiry if needed. GitHub automatically wraps each artifact in a download ZIP: extract that outer archive first, hash the inner game ZIP, then extract it.

## Download, verify, and playtest

1. Open the exact workflow execution URL linked in the PM report. Confirm green status and source SHA.
2. Download all three artifacts from the run's Artifacts section (GitHub login may be required). Confirm they are unexpired.
3. Extract the outer platform artifact archive. On macOS use `shasum -a 256 <game.zip>`; on Windows use `Get-FileHash <game.zip> -Algorithm SHA256`. Compare with `zip.sha256` in BUILD_MANIFEST.json. Compare member sizes/hashes if investigating damage.
4. Extract the inner ZIP and run the Windows EXE or macOS app. These are internal alpha candidates. Signing/notarization is deferred; macOS may block opening until the creator reviews it through their normal OS approval process.
5. Back up normal saves before interactive playtesting. The game retains its existing user-save identity. Different executable filenames do not isolate saves. CI profiles are disposable; downloaded native builds use normal platform saves unless launched with deliberate profile isolation.
6. Creator must test actual Windows and Apple Silicon Mac boots, controls, saves and sustained 60 FPS stress scenes. Headless QA and package validation do not certify native rendering, Intel compatibility, Apple Silicon compatibility or sustained 60 FPS.

## Failures, permissions, and rollback

Open the failed job and QA artifact. Start with CI_QA_REPORT.json and the named suite log; check returncode, failure counts, hard_errors, and timeout status. Export logs and pack-audit files distinguish export/package failure from boot failure. GitHub's Re-run failed jobs retries the same source; infrastructure fixes require a new source commit/PR event. No game package is uploaded when QA/export audits fail. A later native startup failure makes the overall workflow red even if export artifacts exist; check the native report before acceptance.

Token permissions are explicitly contents:read; checkout does not persist credentials. No secrets, write token, certificates, signing keys, auto-tags, GitHub Releases or automatic merges. Official actions/checkout@v4 and actions/upload-artifact@v4 and actions/download-artifact@v4 are trusted GitHub-maintained major tags; review upstream changes or pin full immutable SHAs under PM policy. Cross-exporting both platforms in one Linux job minimizes export cost; two short native jobs add Windows/macOS runner usage (macOS may cost more under private-repository billing). Usage/billing depends on account quotas; this report does not claim unlimited/free runner/storage. Expiring downloads consume bounded artifact storage.

Rollback by reverting only the CI implementation commits, or disabling this workflow in Actions if PM authorizes it. Do not revert candidate gameplay or edit specialist branches. Deleting an unmerged draft PR does not install/remove infrastructure on default.

References: [official release](https://github.com/godotengine/godot-builds/releases/tag/4.6.1-stable), [Godot PCK implementation](https://github.com/godotengine/godot/blob/4.6.1-stable/core/io/file_access_pack.cpp), [GitHub workflow triggers](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).
