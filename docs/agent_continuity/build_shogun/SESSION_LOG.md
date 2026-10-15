# Build Shogun — session log

- 2026-10-14 PM-02 bootstrap recovered: CI-02 PR #14 merged; prior run 38636982092 successful. Read original CONTEXT/SESSION_LOG/RECOVERY from unmerged PR #18 before work.
- 2026-10-15 UTC BUILD-03: independently read PRs #13/#14/#16/#18 and live refs. Prior artifacts unexpired but older candidate. Created isolated checkout; sources and specialist workspaces untouched. Git CLI push unavailable; connected GitHub app publishes successfully.
- Published dedicated CI branch and draft PR #20. Reused CI-02 with explicit approved TR-02 allowlist target and exact pinned PR source. Added committed-recipe packaging, four fixture checks and ten native Windows launcher boots. No permission expansion or gameplay changes.
- Final successful run 38674862607: game source e9a2d1ab0537f3f903c543b080451b3556961179, CI head 7a02be64bfe508f39b1a7a724a2aa5ab2341ede6. 897 assertions; Windows/macOS exports; native Windows and Intel macOS passed. Earlier runs superseded/cancelled, not acceptance evidence.
- Downloaded all five artifacts using Python urllib after PowerShell HTTP failed. Verified outer/inner/member digests, CRC, Windows AMD64 PE, macOS universal header, 529 PCK entries/platform and exact Git world blob. Local archive CRLF conversion corrected before comparison; shipped packages were correct.
- Published BUILD03_PM_RETURN_REPORT.md and BUILD03_VERIFICATION.json; documentation-only publication uses skip-ci. Windows artifact 11945722171; macOS artifact 11945887204. Human gameplay/performance remain untested. No merge or public production release.
