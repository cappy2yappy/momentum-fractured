# Build Shogun — BUILD-03 context

Mission: deliver TR-02 Windows playtest through GitHub without gameplay merges.

Verified 2026-10-15 UTC: main c69efbb43aa49b71dc6c541820934487a170fa7b; CI-02 PR #14 merged. CI-01 PR #13 remains open. PM-02 PR #18 remains open; its Build Shogun bootstrap records were read.

Game source: feature/alpha-0.6.1-mixed-transitions @ e9a2d1ab0537f3f903c543b080451b3556961179 (PR #16 open). Dedicated CI branch: ci/build03-tr02-playtest; review PR #20. Last executable CI change: 220b93177b74ac4309fcc45e377e88f04dcaf38e. Workflow run 38674789799 queued at checkpoint. No success/artifact acceptance yet.

Recovered checksum-pinned Godot 4.6.1 Linux QA/export, Windows x86_64 and macOS universal target support, native Windows/Intel macOS headless checks. Read-only Actions token and credential-free checkouts retained. TR-02 packaging reuses committed launch.ps1/README and ten isolated profile launchers. Audio branch is not included. Existing game audio startup only is in scope.

No merge, tag, release or repository security change authorized. Human gameplay and sustained 60 FPS remain unverified.
