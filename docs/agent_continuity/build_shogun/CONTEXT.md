# The Build Shogun — CONTEXT

**Role:** Godot CI, automated QA, Windows/macOS builds and release engineering.
**CI-01:** [PR #13](https://github.com/cappy2yappy/momentum-fractured/pull/13), full candidate pipeline test [run 38625422844](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38625422844).
**CI-02:** Infrastructure-only [PR #14](https://github.com/cappy2yappy/momentum-fractured/pull/14) merged to `main`, commit `c69efbb43aa49b71dc6c541820934487a170fa7b`. Candidate verification [run 38632031577](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38632031577).
**Manual workflow:** [run 38636982092](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38636982092) passed QA/build and native smoke checks; Windows/macOS artifacts available until scheduled expiry 2026-11-04.
**Scope caveat:** Historical main has zero regression suites and Intel Mac fallback; Alpha 0.6.1 candidate has 691 assertions and universal macOS. Artifacts are time-limited. Headless boot is not interactive gameplay or sustained 60 FPS. Maintain least-privilege Actions permissions.
**Next:** Build new feature integration candidates with correct SHA and approved source selection. New developer branches are not automatically included in manual allowlist. No gameplay changes, releases or merges without PM approval.
