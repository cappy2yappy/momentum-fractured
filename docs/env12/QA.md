# ENV-12 executed QA

## Fresh execution in this assignment

- Exact reserved base recovered: commit `250afde28517fcc05984038ac9e1487114729b78`, tree `1062f45ec70afef6d8b02a4a3e61ad84f4c41732`. All **1,631 base files** are byte-checked by Git blob identity; the 591-file runtime subset is checked again before native launch.
- Six staged archives and **1,106 extracted source hashes** verified through the read-only ASSET01 verifier; **185** ART11 cached-frame hashes and the entire runtime lineage manifest verified before each native run. No new source or derivative art was authored.
- Four native Godot **4.6.1.stable.official.14d19694e** comparisons: **194 assertions, zero failures**, **61 private 1280×720 captures**. Final runs have zero script/runtime errors. Full original/modified topology snapshots, gate/ability/progression snapshots, pause, reduced motion, B response state, detach/reattach and save suppression checks executed.
- Protected anchors include locked ones: R4 **3**, R14 **3**, R16 **2**. Faces stay inside actual collision; no cosmetic envelope intersects its protected read or landing/feet envelope. Zero new physics nodes or Category C devices.
- `tools/verify_baseline.py`: **0 failures**, approved idle/run/attack/traversal sheets verified.
- `tests/env12/verify.py`: full base preservation, allowed paths, 21-room matrix, native evidence, exact private PNG hashes/dimensions and unchanged ART11 reference HEAD/status. Machine-readable results: [verification.json](evidence/verification.json). These static checks are separate from the 194 native assertions.
- Native image review: all four 1x study views, R0 overview, R14/R16 guide overviews and R4 opposite-exit view inspected; coordinator additionally reviewed the four native art captures and R4/R16 baselines. This is readability review, not creator art acceptance.

## Measured performance

Windows native OpenGL 3.3 Compatibility; NVIDIA GeForce RTX 4070 Laptop GPU, driver 591.44. Each room has a 3-second baseline and 3-second art sampling window after warmup, excluding screenshots. Wall-clock frame time, display-paced near 144Hz; 429-438 samples/window. Baseline loads the same cache, so this measures drawing overhead rather than asset load cost. No averaging across hardware or full-gameplay workload claim.

| Room | Baseline p95 ms | Study p95 ms | Baseline / study p95 draw calls |
|---|---:|---:|---:|
| R0 | 7.757 | 7.913 | 39 / 215 |
| R4 | 8.120 | 7.889 | 90 / 168 |
| R14 | 7.928 | 7.797 | 144 / 411 |
| R16 | 7.960 | 7.933 | 64 / 211 |

All measured windows were below the 16.67ms frame target on this machine. Lower art times are sampling noise, not a speedup claim. The procedural primitives add substantial draw calls, especially in R14; an accepted painted/atlased version needs a fresh budget check. Cache decoded payload is **3,795,784 bytes / 3.62 MiB**, stable through each run, with no additional per-frame decode. This includes unused ART11 candidates.

## Known source-base divergence — pending combined integration

The pinned PR99 runtime predates approved Candidate3 text. Its actual recorded initial objective is `Defeat the Market sentinel and claim Windstep.` The required approved objective is `Search for survivors. Defeat the Market sentinel for Windstep.` The approved opening is absent from this pinned world script, and Foundry source still contains `Foundry Refuge` rather than `Foundry Rest Station`.

An initial copy-presence check correctly exposed two absent approved strings. They are retained as a **known base gap**, not counted as approved-copy runtime acceptance. The final verifier checks approved handoff wording and unchanged base bytes, and reports this gap explicitly. Native evidence keeps the real inherited objective without rewriting it. Host HUD/messages are hidden in the gallery. The coordinator confirmed this divergence is pending combined integration; **no shared source fix is requested or made**.

## Corrections made within ENV12

The first private host omitted `MetSysSettings.tres`, producing map assertions. That settings file was added to the pinned copy manifest; all final runs passed. The first anchor query only returned ability-available anchors; it was replaced with all actual anchor nodes and count assertions. The four rooms were rerun after this change. These were study-harness corrections, not world/controller/geometry changes.

## Inherited evidence, not rerun here

ART11's 580 alpha/animation checks, seam and fixed-pivot metrics, HAZ01 contract/toolkit checks, earlier screenshots and earlier frame-time results remain historical evidence in `docs/art11/`. ENV12 verified their source/cache identity and reused them; it does not report those suites as freshly executed. PR107/108 completion is coordination context, not ENV12 test coverage.

## Still pending

Creator palette/art acceptance; final painted illustrations; Level redlines, return/fire/connector geography and G1/G2 decision; DarkCave independent rights and release packaging; accepted production integration base/copy; normal-speed movement and reciprocal transitions; old/new saves; controller/focus-loss/scene-cancel gameplay; Windows/macOS exports and low-end/GPU performance. Frozen study checks do not certify these. Source art and all production-room files remain unchanged.
