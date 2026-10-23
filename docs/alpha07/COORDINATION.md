# Alpha 0.7 coordination map (2026-10-22, after Gate A0 decision)

Foundation: Candidate 3 `c2170032` for development only, not Alpha 0.6.1 acceptance. Rebase when the accepted source changes. Integration branch: PR #84 `candidate/alpha07-integration`. No change to Candidate 3, no merge into 0.6.1, no new canonical story placements.

| PR | Stream | Owner | Role | Overlap to resolve |
|---|---|---|---|---|
| #88 | INT-01 story director (partial) | Codex | Owns world hooks, flags, save seam | Missing managed defeat hook, request_save, deferral queue, input suppression |
| #87 | Enemy and hazard compliance | Codex | Contract enforcement on EN-01 and HAZ-01 | Contains the HAZ-01 toolkit from #82. #82 and #87 must not both merge; #87 supersedes #82 for integration if the PM agrees. Depends on #88 seam |
| #86 | Story cut-in presenter | Codex | request_cutin sink, three review fixtures | Stacked on #78. Presentation only |
| #85 | Animation audit | Codex | Source audit, Mac staircase launcher | Creator Image4 missing, production animation blocked |
| #83 | EN-01 original | Codex | Base of #87 | Kept as history |
| #82 | HAZ-01 original | Codex | Superseded in part by #87 | See above |
| #81 | ST-05 | Creator-gated | Alias table only | No registration |
| #80 | Docs | Claude | Contracts v1.1, exceptions, this map | Docs only |

Rules: one implementation per stream, Codex lead assigns; Claude reviews and runs combined validation and does not write feature code that duplicates a Codex stream. All PRs stay draft. No merges.

## Dependency register update 2026-10-23 (QA-10 reconciliation)

| Item | Status | Detail |
|---|---|---|
| Native QA blocker (28 and 57 failures in rendered tr08_canal_hang_regression and automatic_passage_reliability) | DIAGNOSIS COMPLETE, correction pending PM acceptance | PR #101 (draft, head `2b727670`, base `tools/cin-tools-03-studio`) reports two inherited test-harness causes: the automation HUD still runs the production focus-pause handler and pause survives world replacement, and an unbounded native screenshot wait. Same mechanisms reproduce on #78 and #100. Not restarted, not duplicated |
| Correction (test-only overlay) | REPORTED, NOT ACCEPTED | Reported: #100 855 native assertions plus 16 contract checks; #78 826 plus 16 with the identical overlay; headless 2,505; 609 production/resource files unchanged. Claude has verified PR metadata only and has not rerun these results |
| Coordinator review of #101 | NEXT GATE, pending | Claude to review scope (test-only, original assertions retained, no production edits) before PM acceptance |
| Windows native validation | PENDING | Not covered by #101 |
| Creator Studio review (#100) | PENDING | Prototype only |
| ART-10 animation fidelity (#95) | PENDING | Production drawings blocked |
| Integration QA | PENDING | Rerun on a combined tree after the above |
| macOS Godot startup crashes | SEPARATE DIAGNOSTIC | #101 does not establish cause or resolution |
| Unresolved in #101 | OPEN | Compositor-specific reason ordinary draws stopped is unknown; legacy PM capture workflow outside certification |

Alpha 0.6.1 tracking (11 failures, 6 skips) is unchanged and separate. All PRs remain draft and unmerged. Production integration stays held until PM disposition of #101.
