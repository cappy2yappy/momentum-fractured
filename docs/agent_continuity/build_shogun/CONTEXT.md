# Build Shogun — BUILD-03 complete

Verified 2026-10-15 UTC. Mission delivered: downloadable TR-02 Windows x86_64 playtest, plus separate macOS universal artifact.

Game source: feature/alpha-0.6.1-mixed-transitions @ e9a2d1ab0537f3f903c543b080451b3556961179; PR #16 open. CI branch: ci/build03-tr02-playtest; PR #20 open. Main remains c69efbb43aa49b71dc6c541820934487a170fa7b. Successful run 38674862607 at CI head 7a02be64bfe508f39b1a7a724a2aa5ab2341ede6; subsequent commits documentation only.

897 assertions passed; exported Windows/macOS ZIP/PCK audits passed; Windows native main startup and ten isolated comparison launcher boots passed; Intel macOS native startup passed. All five artifacts downloaded and independently outer/inner/member-hash/CRC verified, 529 PCK entries per target. Windows inner ZIP SHA-256 edd8661a7a6b1bb2b528eb4c205e22ee84bae9629fe58c69daaae7ca998c2350.

Windows: https://github.com/cappy2yappy/momentum-fractured/actions/runs/38674862607/artifacts/11945722171 (expires 2026-11-05 UTC). Report/evidence: docs/agent_handoffs/BUILD03_PM_RETURN_REPORT.md and BUILD03_VERIFICATION.json.

No merge, release, gameplay changes or specialist combination. Sound branch not included. Human gameplay, Apple Silicon native startup and sustained 60 FPS unverified. Next: creator compares treatments; PM reviews CI/gameplay separately.
