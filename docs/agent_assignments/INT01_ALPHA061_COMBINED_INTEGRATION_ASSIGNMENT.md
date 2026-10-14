# KAZE — ALPHA 0.6.1 COMBINED INTEGRATION & WINDOWS PLAYTEST WORK ORDER

**Assignment ID:** INT-01-0061
**Assigned to:** Kaze Integration / Build / QA specialist (new dedicated Work request, not a rename of the existing agents)
**Authority:** PM-01 Project Management; creator authorizes implementation and testing, **not** release or merging to main
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Godot target:** 4.6.1
**Documentation branch:** `docs/pm-int01-alpha-0.6.1-integration-order`
**Starting source:** `integration/alpha-0.6-world-momentum` historically `34be30436996284ec2f783269c40269d321ed427`; fetch and verify actual remote head
**Integration candidate branch:** `integration/candidate-alpha-0.6.1-gp-ld` (create anew if absent; if present, inspect and do not overwrite)
**Gameplay PR:** https://github.com/cappy2yappy/momentum-fractured/pull/8
**Gameplay review head:** `70a0a83bd6076c9c711a43bcaafb3c79a8ad20a2`
**Level Design PR:** https://github.com/cappy2yappy/momentum-fractured/pull/9
**Level Design review head:** `a4926e9f0667168f390ab99279efe3243055aa3f`
**Status:** APPROVED FOR INTEGRATION CANDIDATE CONSTRUCTION; RELEASE/MERGE PENDING CREATOR AND PM ACCEPTANCE

## 0. Read and acknowledge

Retrieve **this exact work order** from its GitHub branch. Read the full document before changes. Confirm assignment ID INT-01-0061, both PR references, verified branch SHAs, engine availability and your workspace path. If the repository is inaccessible or you lack executable Godot/Windows export capability, state the precise limit. Do not represent instructions as completed code work.

## 1. Mission and acceptance boundaries

Produce a **separate, reversible, testable Alpha 0.6.1 combined integration candidate** incorporating the accepted GP-01 stabilization and LD-01 room-cohesion changes, then publish build evidence and a Windows candidate where the execution environment permits.

Preserve the creator-approved current movement feel, jump floatiness, grapple swing, dash timing, Kaze sprite proportions/anchors, save identity, and existing story/ability progression. **Do not** lower speed, rewrite controller physics, import old Alpha 0.5 architecture, or invent extra rooms/art.

Current acceptance is bounded: Gameplay and Level Design implementations were reviewed for integration testing, **not** cleared for direct merge into `integration/alpha-0.6-world-momentum` or `main`.

## 2. Baseline and isolation

1. `git fetch --all --prune`; inspect active branches, logs, clean worktree status and both PR heads.
2. Verify the original integration base and whether any remote heads advanced since this work order. If they advanced, record divergences and review new commits before proceeding.
3. Use a dedicated checkout or worktree and create `integration/candidate-alpha-0.6.1-gp-ld` **from the verified integration HEAD**, not from `main`.
4. Integrate both reviewed PR heads using small, auditable merges/cherry-picks or equivalent with explicit parent/commit history. Start with Gameplay stabilization, then apply Level Design; explain any deviation. Never modify or force push either specialist's feature branch.
5. Compare the resulting diff against base to confirm both intended changes are present and no unrelated source or art was dropped.
6. Keep every operation reversible. Do not commit generated caches (`.godot`, temp/user save data) or secrets.

## 3. Required cross-branch conflict review

Both PRs modify `scripts/world.gd`. GP-01 changes save/progression normalization; LD-01 adds `RoomPresentation` preload and background/door drawing hooks. Resolve overlaps while preserving **both** sets of behavior. Review `scripts/world_expansion.gd`, `scripts/room_presentation.gd`, `scripts/player.gd`, `scripts/kunai.gd`, test files, `assets/web/kaze_manifest.json`, and Windows export metadata.

DO NOT silently accept Git merge conflict choices. If the conflict is in unrelated sections, demonstrate both final hunks. If same functions overlap, reason about semantics and add or extend a targeted regression.

### Specific concerns
- Correct kunai collision through crossed enemies and elemental seals, including bad frame steps.
- Dash detaches tether and cannot reattach during dash without changing approved momentum.
- Sparse and malformed save states normalize without stale progression; existing earned saves still load.
- Four refined rooms: R14 Bellroof Walk, R15 Lower Sluice, R17 Counterweight Spire, R19 Coil Service Hall.
- Compact exit presentation applies globally via `draw_door`; audit original rooms and all exit interaction cues, not only four refined rooms.
- Check all door targets, reciprocal arrivals, collision geometry, ability gates, checkpoints, hazard warnings and no inadvertent softlocks.
- Ensure global room presentation does not cover relevant HUD/effects or obscure exit affordances.

## 4. Required validation

Run import/parser check, the existing approved baseline and regression suites, **both newly introduced GP-01 suites** (`gameplay_stabilization.gd`, `traversal_transitions.gd`), and **the new LD-01 suite** (`world_cohesion_traversal.gd`), plus existing expansion/progression/movement/sprite tests, save compatibility, and `tools/verify_baseline.py`. Use **actual executable engine/version** and log all command lines, counts, failures, warnings and output locations. Do not simply add historic suite totals; counts can overlap.

Additional manual or scripted QA:
- Try ordinary, upgraded Stride and optional momentum configurations; keep physics constants unchanged.
- Verify fresh-save progression using isolated user profile, and upgraded save/reload without deleting creator data; log exact launcher/profile paths.
- Exercise four refined rooms both forward and reverse, intentional fall/missed shelves, compact door interaction at ordinary camera zoom, normal returns, and critical gate rejection.
- Recheck original 8 rooms' geometry and revised global doors.
- Attempt representative continuous route through major unlock/gate milestones; distinguish local seeded probes from authentic start-to-finish traversal.
- Check Linux/headless or Windows packaged boot only if actually available. Measure *rendering* FPS/frame times on supported hardware for 60 FPS goal; if no renderer/performance tooling, mark NOT TESTED.

## 5. Windows playtest artifact

If Windows Godot 4.6.1 and export template are available, produce a downloadable Windows x86_64 **candidate** under an untracked output directory, e.g. `builds/windows/Kaze-Alpha-0.6.1-Combined-GP-LD-Windows.zip`, including executable/PCK, a concise README, documented controls, the source commit SHA and hash(es), and safe fresh-save versus existing-save launch guidance. Test archive integrity and packaged startup. Do not embed personal profile data. Avoid overwriting earlier candidate ZIPs.

If build files cannot be uploaded as GitHub release/artifacts with available permissions, preserve them in the available Work/session output and give exact validated download paths; do not pretend a cloud file automatically exists on the creator's PC or in GitHub. Source/QA handoff must still be pushed to GitHub.

## 6. GitHub publication and handoff

Commit and push the integration candidate **only** to `integration/candidate-alpha-0.6.1-gp-ld`. If permitted, open a **draft PR** targeting `integration/alpha-0.6-world-momentum`, but do not merge or close PR #8 or #9. Report any unpushed items frankly.

Add:
- `docs/agent_handoffs/INT01_ALPHA061_COMBINED_PM_REPORT.md`
- `docs/agent_handoffs/INT01_ALPHA061_TEST_RESULTS.md` or JSON equivalent
- Changelog entry noting this is a review candidate and listing inherited PRs without falsely calling milestone complete

Provide source SHA, merge/cherry-pick history, comparison with both specialist heads, QA reproduction commands, exact source/build links, binary hash and size (if generated), and creator playtest instructions.

If blocked midway, preserve safe progress and deliver a partial report with blockers, commands attempted, branch state, and next steps.

## 7. Acceptance matrix

Mark each PASS / FAIL / PARTIAL / BLOCKED / NOT TESTED with evidence:
1. GP-01 kunai, save and dash/tether fixes present.
2. LD-01 four-room layouts, environmental cues, compact doors present.
3. No unintended controller/sprite change.
4. All available merged regression suites actually run and pass.
5. Save/load across fresh and upgraded profiles.
6. Critical route/gate/exits accessible with expected abilities.
7. Natural descent, missed landings and return navigation at normal zoom.
8. Packaged Windows candidate integrity and launch, if supported.
9. Native rendering 60 FPS measured, if supported.
10. Exact GitHub commit, report and draft PR published, with integration and main unchanged.

## 8. Required last message: PM return report

At the very end, deliver a complete **KAZE — PROJECT MANAGEMENT RETURN REPORT** headed **INT-01-0061**, using:
A. Executive summary
B. Verified inputs and provenance of PR #8 / PR #9
C. Integration strategy, conflict resolutions and file-level changes
D. Acceptance checklist with evidence
E. Automated and manual QA results (actual counts, warnings, failures)
F. Windows candidate build / packaging / playtest access
G. GitHub publication (branch, SHA, PR, pushed status)
H. Risks, blockers and missing verification
I. Creator playtest instructions
J. PM decisions required and recommended next actions
K. Final verdict: **READY FOR PM REVIEW**, **PARTIAL HANDOFF — CONTINUATION REQUIRED**, or **BLOCKED — PM DECISION REQUIRED**.

The creator transports this report to the existing **Project Management** chat. No code is accepted for mainline integration until PM review and creator playtesting.
