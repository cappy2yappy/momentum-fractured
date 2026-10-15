# Build Shogun — session log

- 2026-10-14 PM-02 bootstrap recovered from docs/pm02-agent-continuity: CI-02 merged, prior run 38636982092 successful.
- 2026-10-15 UTC BUILD-03: independently read PRs #13/#14/#16/#18 and live remote refs. Prior run artifacts confirmed unexpired through 2026-11-04, but they contain the older candidate and are not TR-02 delivery.
- Created isolated build03-repo checkout; left existing specialist workspaces and sources untouched. Git CLI has no usable push authentication; connected GitHub app successfully publishes commits. Created dedicated CI branch and draft PR #20. No permission expansion.
- Added exact TR-02 pinned source for BUILD-03 PR validation, explicit manual source allowlist entry, committed-recipe comparison packaging, explicit four source fixture checks and ten native Windows launcher boots. First run superseded by improved validation. Run 38674789799 pending at checkpoint; no test pass or downloadable TR-02 artifact claimed yet.
