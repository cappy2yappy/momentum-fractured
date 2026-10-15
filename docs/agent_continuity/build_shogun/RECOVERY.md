# Build Shogun — recovery

1. Read CONTEXT.md and SESSION_LOG.md; verify PR #20 latest SHA and Actions runs. Do not rebuild completed CI-01/CI-02 infrastructure.
2. Inspect run 38674789799 for CI control commit 220b93177b74ac4309fcc45e377e88f04dcaf38e; game source must be e9a2d1ab0537f3f903c543b080451b3556961179. Investigate failures before acceptance.
3. Download Windows/macOS/QA/native artifacts. Check digests, inner ZIP CRC/member SHA-256, source manifest, PCK and actual native outcomes. Preserve ten comparison launchers and fresh profile behavior.
4. Write BUILD03_PM_RETURN_REPORT.md with verified artifact links, expiry, hashes, QA/native limitations and recovery details. Update these records; commit/publish documentation before stopping.
5. No merge/public release/gameplay changes. Report partial if no accessible verified ZIP exists. Prior candidate artifacts cannot substitute for TR-02.
