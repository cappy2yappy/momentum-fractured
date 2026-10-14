# KAZE — CI-01 AUTOMATED GODOT BUILD & QA INFRASTRUCTURE

**Owner / role:** Build & Release Engineering Agent (suggested chat title: **The Build Shogun | CI, QA & Releases**)  
**Assignment:** CI-01-0061  
**Issuer:** Project Management (PM-01)  
**Date:** 2026-10-14  
**Engine:** Godot 4.6.1.stable.official.14d19694e  
**Repository:** https://github.com/cappy2yappy/momentum-fractured  
**Authoritative order:** `docs/agent_assignments/CI01_ALPHA061_AUTOMATED_BUILDS.md` on branch `docs/pm-ci01-godot-build-pipeline`  
**Baseline:** `integration/candidate-alpha-0.6.1-gp-ld`, verified initial head `afecef1922231081807a332c511de85c7941fec8`; re-verify remote before editing.  
**Own development branch:** `ci/alpha-0.6.1-automated-godot-builds`  
**Review base:** `integration/candidate-alpha-0.6.1-gp-ld` (draft PR, NO automatic merge)  
**Related PRs:** combined candidate #10; art concepts #11; room transitions #12. Do not merge or cherry-pick these into CI unless expressly needed and approved.

## A. Mission and success definition

Establish reproducible, source-traceable, downloadable **Windows x86_64 and macOS universal** Kaze playtest ZIP builds on GitHub Actions, with automated Godot import and the actual current regression test suite, logs, manifests and conspicuous failures.

**Acceptance is an observed successful GitHub Actions workflow run with BOTH downloadable platform artifacts, source SHA and test result evidence.** A YAML file only, green local tests only, or a GitHub draft PR without successful Actions evidence is **NOT** completion.

Creator verified repository Settings > Actions > General: all actions/reusable workflows allowed; default `GITHUB_TOKEN` has **read repository contents and packages** permissions; PR creation/approval by Actions disabled; retention 90 days; first-time contributor approval required. DO NOT request broader repository permissions or secrets for normal builds.

## B. Scope and source audit (perform before editing)

1. Retrieve and read the entire work order. Confirm assignment, actual baseline SHA, branch ownership, Godot engine and export templates in your first status.
2. Inspect repository structure, `project.godot`, `export_presets.cfg`, `tools/run_int01_qa.py`, `tools/verify_baseline.py`, `tests/`, `scenes/main.tscn`, existing ignored build outputs and any current `.github/workflows/` files. Check branch/default-branch state and access limitations. Work in a clean workspace. Never disturb existing dirty worktrees.
3. Preserve the established configuration: renderer GL Compatibility, 1280×720, restored Kaze sprite sizing, save identity, complete 21-room graph, approved movement floatiness/speed and progression. This is **infrastructure-only**.
4. Preserve both existing preset names `Windows Desktop` and `macOS` and pinned Godot 4.6.1 templates. Existing macOS preset is unsigned/unnotarized, and Windows uses embedded PCK. Keep internal-alpha candidate labeling; do not claim public distribution readiness.
5. Reuse existing full suite runner where possible; currently `tools/run_int01_qa.py` runs import, baseline verifier, 17 named suites plus separate-process save-profile prepare/reload. It accepts `--godot`. Review its HOME and `XDG_DATA_HOME` isolation and timeouts on Linux runner. Preserve its raw log output and fail-on-errors behavior. The suite list may have advanced; discover latest at runtime and ensure known 17 remain.
6. Check how `world/*.txt` and required addons/resources are included in exports. Existing exclude list for `tests/*,docs/*,tools/*,build/*,.autoconverted/*` must remain effective. Verify exported PCK/ZIP is not carrying QA logs, source archives, caches or user profiles.

## C. Minimum automated GitHub Actions workflow

Produce reviewed workflow(s) under `.github/workflows/`, ideally `godot-ci.yml`, with:

### Event strategy
- `pull_request`: CI checks/test reports for development PRs targeting the combined candidate or designated shared integration branch; avoid blindly running expensive exports for every docs-only commit.
- `workflow_dispatch`: manual selection of the branch/ref and/or `build_artifacts` input where GitHub supports it. **Important:** GitHub's "Run workflow" interface requires the workflow definition to be present on the **default branch**. Until PM authorizes the minimal workflow to reach default, demonstrate the pipeline via PR-triggered runs and document this limitation; do not misrepresent the Run workflow button as immediately available on an unmerged feature branch.
- `push` to candidate/integration branches only if appropriate and approved; avoid duplicate triggering on every source change. Use workflow concurrency and cancel-in-progress where safe.
- Bound runtime and artifacts. Use repository-level runner and workflow quotas.

### Execution / reproducibility
- Ubuntu GitHub-hosted runner as initial default. Install **exact Godot 4.6.1 stable official binary and matching export templates** from reputable official releases; verify expected paths/checksums when available; do NOT silently choose latest Godot.
- Prefer pinning third-party Actions to maintained stable major versions or immutable full SHAs, document trust and permissions. For jobs, explicitly use `permissions: contents: read`; upload-artifact uses GitHub artifact service and does not require granting contents:write.
- `godot --headless --path . --import --quit` then baseline preservation verifier and full regression suite in disposable HOME/XDG locations.
- Tests must fail if any assertion returns fail, parser/load error, or nonzero process exit. Preserve nonfatal engine import/shutdown warnings in logs, with severity distinguished from hard failures. Avoid blanket suppression.
- Package both targets as distinct ZIP artifacts; retain project/game name, target architecture, Alpha 0.6.1 candidate label and SHORT_SHA in filenames.
- Generate `BUILD_MANIFEST.json`: branch, full source SHA, Godot version/templates, timestamp UTC, build target, file sizes, SHA-256 hashes, QA outcome and tested/untested architecture.
- Upload separate `Kaze-Windows-x86_64-<sha>`, `Kaze-macOS-Universal-<sha>` and `Kaze-QA-Results-<sha>` artifacts with bounded retention (e.g. 14–30 days rather than automatically using all 90).
- Verify ZIP CRC and expected game executable/PCK after exports. Ensure required data files included, forbidden `build,tests,docs,tools` not packed; inspect via existing or new lightweight deterministic pack checker. Export success alone is not a boot pass.
- Do not add user saves, tokens, certificates, developer profiles or signing credentials to published artifacts.
- If Linux cross-platform export is unreliable, keep Linux QA and use a targeted macOS-hosted export or platform-specific runner as necessary. Explain cost/runtime tradeoffs and execute proof. Prefer the smallest reliable configuration.

### Platform smoke tests
- Mac: native smoke launch on macOS runner if feasible, with isolated profile; unsigned build may require adjustments for CI runner, not user's machine. Do NOT assert Apple Silicon, Intel or full interactive compatibility without specific evidence.
- Windows: test executable launch on Windows runner if feasible. On failed or unavailable native runtime, mark Windows **export/package verified only**, not native launch tested. No Wine claim without actual test.
- 60 FPS requirement: CI may run limited timing diagnostics but **cannot certify sustained 60 FPS** from headless tests. Mark performance as human/native stress-test gate.

## D. Source control, permissions and first-run strategy

- Work only on `ci/alpha-0.6.1-automated-godot-builds`, base verified candidate. Do not edit gameplay, sprites, rooms, save IDs or physics, and do not alter PRs #8–#12.
- Commit and push workflow and helper scripts. Open **draft review PR targeting combined candidate**. Do not merge any branch into `main` or `integration/*`.
- Verify a **real GitHub Actions PR run**. If no run is created because workflow files are not on default / event recognition / workflow restrictions, document actual result, troubleshoot within branch, and ask PM for narrowly scoped permission to land only workflow infrastructure as needed; **never silently merge**.
- For initial PR validation, a temporary throwaway QA branch/PR may be used if authorized to demonstrate supported pull_request triggers. Do not fake screenshots, workflow outputs or success.
- Prefer no added third-party secrets; signing/notarization and release publishing deferred. No auto-tagging, GitHub Release posting, app store submission or production deployment in this milestone.
- Review triggers with a hostile-PR security mindset: **do not use pull_request_target to run untrusted PR code**, avoid writable tokens on checkout; no secrets exposed to contributions.
- Document any GitHub billing/quota implications and artifact retention.

## E. End-to-end QA and operational handbook

Document a repeatable series:
1. Open/test feature PR, observe Actions jobs.
2. Check full QA suite count and actual failure results; preserve logs.
3. Download zipped Windows/macOS artifacts; hash compare to manifest.
4. Extract and run on creator's actual Windows and Apple Silicon Mac.
5. Use isolated profiles or backup normal saves; never assume executable remapping protects saved progress.
6. Show how a creator would use **Run workflow** after default-branch installation, including branch selector and artifact downloads.
7. Explain how to rerun failed jobs, interpret failure flags, and identify source SHA.
8. Provide a safe rollback of workflow-only changes.

Prove at least one **negative-path check** (intentionally failing a validation in temporary test branch or workflow job, then reverting) if safe, to establish failures appear red. Do not break an already running shared job or contaminate gameplay branch.

## F. Required published artifacts and PM handoff

- `.github/workflows/godot-ci.yml` (or separately named validate/build workflows).
- Any helper script(s) confined to `tools/ci/` or similarly named directory, with deterministic checks.
- `docs/build/CI01_AUTOMATED_BUILD_HANDBOOK.md`: purpose, requirements, permissions, triggers, build/download instructions, runtime caveats, troubleshooting.
- `docs/agent_handoffs/CI01_ALPHA061_PM_REPORT.md` containing source refs/SHAs, branch, files changed, test run IDs/URLs, individual statuses, actual artifact names/URLs and hashes, startup scope, known failures, security/usage considerations, and PM decisions.
- `docs/agent_handoffs/CI01_ALPHA061_TEST_RESULTS.json` (or equivalent structured output) with actual run outcomes; no invented metrics.
- If CI cannot pass, publish a precise **PARTIAL HANDOFF** with failure evidence and the next required permission/action. Save work incrementally, no silent stalled execution.

## G. Acceptance thresholds

- Required: workflow committed and pushed; real GitHub workflow run completed successfully; **full test suite passes**, Windows and macOS artifacts downloadable; ZIP audits and SHA manifest; links and usage instructions verifiable; no gameplay regressions and no unauthorized merges.
- Native Windows/macOS boots: strongly desired; any platform not launched stays **untested** and remains a later QA gate.
- If only one platform passes or Actions never executes: **PARTIAL**, not READY FOR ACCEPTANCE.
- Any workflow requiring extra secrets/write token must first receive PM approval, with reason.
- Only creator/PM may authorize promoting this CI infrastructure to production/default branch, changing protections, or declaring it release-ready.

## H. Report structure

Return **KAZE PROJECT MANAGEMENT REPORT — CI-01-0061**:
A. Executive summary / true status
B. Verified source and branch
C. CI architecture and events
D. Godot versions, templates, export presets
E. Test results and failure behavior
F. Exported build artifacts, sizes, checksums and download links
G. Native boot matrix and explicit caveats
H. Security and cost controls
I. GitHub commits / PR / actual Actions run links
J. Creator instructions and remaining decisions
K. Verdict: **READY FOR PM REVIEW** / **PARTIAL — FOLLOW-UP REQUIRED** / **BLOCKED — PM ACTION REQUIRED**.

**DO NOT MERGE. DO NOT CLAIM DONE WITHOUT A REAL GREEN ACTIONS RUN AND BOTH ARTIFACTS.**
