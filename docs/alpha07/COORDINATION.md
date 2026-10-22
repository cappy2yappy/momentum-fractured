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
