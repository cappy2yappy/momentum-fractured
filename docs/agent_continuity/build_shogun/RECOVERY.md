# Build Shogun — recovery after BUILD-03

1. Read CONTEXT.md, SESSION_LOG.md and docs/agent_handoffs/BUILD03_PM_RETURN_REPORT.md; verify live GitHub state. Completed CI-01/CI-02/BUILD-03 must not be recreated.
2. Acceptance run: 38674862607, CI branch head 7a02be64bfe508f39b1a7a724a2aa5ab2341ede6; exported game source e9a2d1ab0537f3f903c543b080451b3556961179. Subsequent publication changes docs/evidence only.
3. Windows artifact 11945722171 includes TR-02 ZIP, manifest and ten isolated launchers. Verify expiry/digest before redistributing; current expiry November 5 UTC. Source/CI are published and reproducible. BUILD03_VERIFICATION.json preserves exact manifests and native/QA results.
4. If artifacts expire, rebuild the exact documented source through reviewed CI controls. No merge of gameplay is necessary. Current main still has older allowlist until PR #20 separately approved; tested BUILD-03 route is PR execution.
5. Await creator comparison feedback and PM-selected future targets. Never combine unfinished sound/art/gameplay branches automatically. Native Apple Silicon, human gameplay/graphics and sustained 60 FPS remain open.
6. Preserve source SHA, CI SHA, artifact links and precise test scopes in any follow-up; publish continuity changes before stopping. No merge or public release without explicit creator approval.
