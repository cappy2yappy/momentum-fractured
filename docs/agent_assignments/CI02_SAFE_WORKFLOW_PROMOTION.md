# CI-02 — Promote Verified Godot CI to Default Branch Safely

**PM authorization:** 2026-10-14; approved *infrastructure-only* promotion work. 
**Owner:** The Build Shogun | CI, QA & Releases
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Source evidence:** PR #13 (head e0b70b6371342907fcaff1060e551ab3a6418860), successful workflow run https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844
**Destination:** default branch `main` through a **new dedicated PR originating from current main**, not a merge of PR #13.
**Implementation branch:** `ci/default-branch-godot-builds`
**Authority:** May create isolated branch, copy/adapt only CI files, test, push and open draft PR. Creator approves the *infrastructure-only deployment path*; DO NOT directly push/merge into main or change repo security settings without separate explicit final PM review.

## Objectives
Make automated Godot 4.6.1 builds part of normal Kaze workflow, preserving current main gameplay until separately approved. Ensure GitHub's manual `workflow_dispatch` control becomes available *when the new infrastructure-only PR is subsequently merged into default*, and allow builds of approved refs only.

## Source and safety checks
1. Read this file entirely and inspect `main`, PR #13 and the verified CI source; compare trees/diffs. Re-verify current branches and sha. Check workflow actions permissions and events.
2. Start clean from current `main` (NOT candidate Alpha 0.6.1) to avoid accidentally merging new rooms, movement and art. Cherry-pick only explicitly enumerated infrastructure changes, or copy reviewed file contents without cherry-picking gameplay history.
3. Approved file categories only: `.github/workflows/godot-ci.yml`, `tools/ci/*`, `docs/build/CI01_AUTOMATED_BUILD_HANDBOOK.md`, and the CI-02 test/report files. Exclude `scripts/`, `scenes/`, `assets/`, `project.godot`, `export_presets.cfg`, `tests/`, root gameplay and older integration commits.
4. **Important compatibility:** main may predate Alpha 0.6.1 and lack `tools/run_int01_qa.py`, the exact export presets or 17 suites. Adapt CI as a **feature-detecting, fail-honest** workflow that can run on main and Alpha 0.6.1 branches without silently skipping mandatory checks. Never overwrite old game assets or import modern gameplay merely to make CI pass. Document differing test suite counts explicitly.
5. Align PR trigger strategy: workflows on default branch need to be recognized for PRs targeting `main` and relevant integration branches; verify GitHub event behavior empirically. `workflow_dispatch` default-branch presence is mandatory for the manual UI. Safeguard workflows against untrusted PR code, avoid `pull_request_target`, use contents:read and do not request secrets.
6. When manual builds select another ref, ensure checkout ref and manifest source SHA match selected ref, not a convenient default. Do not build arbitrary secret-bearing refs, and do not publish production releases.
7. Keep pinned Godot/templates, Windows/macOS ZIP packaging, manifest hashes, isolated saves, QA artifacts, expiry, negative-path validation from CI-01 wherever applicable.

## Evidence / completion
- Branch `ci/default-branch-godot-builds` based strictly on verified `main`.
- Draft PR targeting **main** containing ONLY infrastructure/docs; review actual diff and prove it carries no gameplay/art, project or export preset modifications.
- Run full supported CI on real PRs; if default branch workflow recognition blocks test, document this and provide tested fallback evidence. **Do not say manual Run workflow is live before workflow appears in default branch.**
- Provide direct before/after workflow capability explanation for main and candidate branches and rollout/rollback plan.
- Publish `docs/agent_handoffs/CI02_PM_REPORT.md`, evidence, observed run links and manifests.
- Verdict `READY FOR PM REVIEW` only after green runs and a clean infrastructure-only diff; otherwise return PARTIAL with concrete blocker.

**Hold point:** Submit infrastructure-only PR for PM/creator final approval; DO NOT merge it yourself. Keep PR #13 intact, unmerged.
