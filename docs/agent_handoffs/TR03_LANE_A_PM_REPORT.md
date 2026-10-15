# TR-03 Lane A — Project Management Return

**Date:** 2026-10-15. **Owner:** Level Masta Masta / Level and Transition Implementation.
**Verdict:** scoped mechanics and comparison package ready for creator/PM review; TR-03 final animation and milestone acceptance remain pending. Nothing merged.

## Verified repository recovery

| Item | Identity |
|---|---|
| Dedicated branch | [feature/alpha-0.6.1-tr03-embodied-transitions](https://github.com/cappy2yappy/momentum-fractured/tree/feature/alpha-0.6.1-tr03-embodied-transitions) |
| Draft PR / base | [PR27](https://github.com/cappy2yappy/momentum-fractured/pull/27), base feature/alpha-0.6.1-mixed-transitions |
| Verified published implementation/evidence HEAD before this docs-only return | `a7c1a1f7fe305c4c4844aa7fcbe4effed18f27f8` |
| Windows export source (published tree-equivalent checkpoint) | `3c57ec1b57d0b02ecb9649bfb0b5795f74d0ee70` |
| Local export commit | `a2b0052bca317fa4268d44b3b3df0e6fb5299639` |
| TR-02 recovered head | `e9a2d1ab0537f3f903c543b080451b3556961179` / PR16 |
| Authoritative order | `880718f51b761ffbe40fb028741135b58b00e5f1:docs/agent_assignments/TR03_ALPHA061_EMBODIED_TRANSITIONS.md` |
| Art technical sources | PR25 `85025b1c389d4998805d1a5ff3c856a1b8cc4bea`; PR24 `ecaee8063a418c322fb183e90fe6cf8e2bcb564e` |

No existing Lane A TR-03 branch was found after remote/PR inspection. Continued current TR-02; DEV-06 PR7 and previous TR-01/TR-02 work were not restarted. Local CLI push lacked credentials; connected Git-data publication created recoverable fast-forward commits with explicit expected-head checks, no force updates. Both published implementation/evidence trees were compared with local commit trees. Different commit IDs reflect publication author/time, not different file content. This report and continuity records follow as a docs-only commit; PR27 exposes the final current branch head.

## Requirement return

| Requirement | Result / boundary |
|---|---|
| Endpoint taxonomy | All58 directed endpoints /29 existing links classified. Default2 dynamic grounded horizontal,2 stairs,2 original wind-fold,52 fallbacks. One gated depth demo overrides two existing fallback endpoints. |
| Movement-aware passages | R15↔R16 preserves TR-02 direction, rearm/cooldown, gate and exact x carry. Actual directional double-tap selects run presentation; walk remains a labelled idle-pose placeholder until proper walk art. Air/dash/tether keep original fallback; no speed changes. |
| Stair staging | Existing R14→R17 explicitly stages local ascent, reverse stages descent; anchored approach and three contact positions, event-based arrival. No cross-room altitude inferred from local y. Current run-pose proxy is labelled; anatomical up/down clips remain pending. |
| Depth doorway | One opt-in existing R14↔R13 link, --tr03-depth-demo. Metadata defines headings/depth axis and doorway occlusion. After approach alignment, proxy contracts to a quarter-pose placeholder and moves inward along its depth axis; no sideways substitute for inward motion. Authored rear silhouette is not claimed. |
| Wind-fold | Existing R20↔R13 exceptional effect/policy retained byte for byte in mixed_transitions.gd. |
| Comparisons | Original TR-02, refined, reduced/static and plain flags plus immediate fallback. Original disables new proxies/dressing; reduced removes staged translation/cycling. |
| Structural work | All21 rooms have a ranked map/shelf audit. Only R14 shelf(750,900,400,40) roof backing/braces and R15 shelf(1320,940,400,40) masonry piers/corbels prototyped. Visual-only; existing lip/actor/rope collision untouched. |
| Protected behavior |32 preservation assertions; original player/movement/swing, art bytes/scales, mixed-transition code, HUD, expansion graph, endpoints, gate/save/input functions, project/save identity and loader clock preserved. |
| Keyboard / controller | Existing keyboardE mapping passed. Baseline has no gamepad interaction binding; no hardware controller test or new global controller mapping is claimed. Outstanding input-owner follow-up. |
| Windows delivery | Official4.6.1 cross-export and ZIP CRC pass; embedded resource boot and80 checks pass on Linux engine. Native Windows/PowerShell launcher execution pending. |
| Acceptance | Reviewable mechanics prototype, not final art approval, sustained60FPS certification or complete unseeded campaign. |

## Implemented code and integration contract

New scripts/embodied_transitions.gd is a render-only adapter, attached as a child of the world. Existing world request/can_enter/freeze/build/arrival timing remains authoritative. It snapshots approach before freeze, restores the actual sprite on completion, denial, pause/death/rebuild, and never feeds proxy position/scale back into simulation. Pausing cancels visual staging without silently dropping pending room travel. Full-screen cover and exact arrival still use the original0.65s clock with swap below0.32s; no streaming claim.

Reused clips keep their actual registration: idle scale0.2649908807 / baseline591; run scale0.3825780536 / baseline491. Lane B's proposed new320×724, pivot(160,600), scale0.303125 is retained as a future accepted-art interface, never imposed on current sprites. Current assets were not repainted, trimmed, resized or replaced. No creatively unapproved PR24/25 output or later production art was merged.

Files: scripts/embodied_transitions.gd; minimal world.gd and room_presentation.gd hooks; tests/embodied_transitions.gd, audit_embodied_endpoints.gd, capture_embodied_transitions.gd, capture_structural_pilots.gd; preservation/QA/package/review tooling. [Review guide](../tr03/README.md), [58-endpoint matrix](../tr03/ENDPOINT_MATRIX.md), [structural plan](../tr03/STRUCTURAL_DRESSING_PLAN.md), [QA report](../tr03/QA_RESULTS.md).

## QA evidence

- Final27-action batch:20 behavioral suites plus preservation, imports, cross-process profile and endpoint audit; **1003 PASS assertions,0 failures,0 script errors**. Source runner commands/logs/results committed under tr03_evidence.
- Subsequent stronger test-only refinement uses actual input double-taps: final embodied suite **80 assertions /0 failures**, replacing its earlier78-assertion test variant. Full batch count is not retroactively inflated. Runtime unchanged.
- Windows embedded resource pack loaded from an empty directory using the Linux engine: boot120 frames exit0; final external80-assertion suite against packaged scripts/resources exit0. This is not native Windows execution.
- Four additional packed-profile loads (original/refined/reduced/plain) passed with an absolute save path containing spaces. Creator default profile was not used.
- Eighteen native scripted fixtures: walk/run/up/down/depth/wind-fold × original/refined/reduced. All reached expected destinations and restored the visible character. Full captures1280×720, camera zoom1.0. Three downsampled GIF comparisons and six full-resolution JPGs are committed. These use seeded fixture progress, not earned campaign/human playtesting.
- Native structure comparison reports identical collider counts: R14=23, R15=15. Full platform arrays/gate state also tested with dressing toggled.
- Existing first recovery import produced MetSys editor UID/class-registration errors, preserved in baseline results. Settled current imports have no script errors. Known editor RID/ObjectDB cleanup and container/VSync diagnostics remain; no warning-free claim.

Software OpenGL sample on shared Linux llvmpipe LLVM20.1.2,120 unpaced draw-only wall-time samples after30 warmup frames, no screenshot encoding within measurement:

|Comparison|Mean ms|p95 ms|Max ms|Median draw calls|
|---|---:|---:|---:|---:|
|Original TR-02|13.921|16.775|24.020|114|
|Refined staging|13.711|15.834|24.912|109|
|Reduced|13.299|14.730|19.177|109|

Not randomized; includes engine/render scheduling, not GPU-only timing or a full gameplay run. Do not infer a speedup or sustained60FPS hardware acceptance from these small samples.

## Build, launch and hashes

**Kaze-TR03-Embodied-Transitions-Windows.zip**, 51173375 bytes, delivered as the downloadable chat attachment. Reproduce with tools/package_tr03.py after Windows export. No binary is committed or released publicly.

- ZIP SHA-256: `c900a58829b2d6a1de226f717935525e31b41545626c4e284e6607f04ec23605`
- Executable SHA-256: `2e426f7564be64205fcb78672ff4cc3f2046f3965039e86bbf106ffad22b1289`
- Engine: official Godot4.6.1.stable.official.14d19694e.
- Export source is identified above; later commits add evidence/test refinements/docs, not runtime changes.
- Native Windows boot and PowerShell launchers: **not run, Linux host**. macOS: not exported in this lane.
- Binary product/version strings remain the protected INT-01 candidate values; filename/README identify this TR-03 review package.

Extract first. Start **Play-stair-refined.cmd**, compare **Play-stair-original.cmd**, then passage/depth/special/structure variants. Each launcher creates an isolated profiles/<pilot>-<comparison> folder and passes an explicit --tr03-save; targeted fixtures seed progress once. Play-fresh-refined.cmd is unseeded. Wait1second before approaching the directional culvert so existing rearm/cooldown is ready. Double-tap direction for run; press/releaseE at stairs/depth/wind-fold. Normal existing save is used only when launching the EXE directly. All pose placeholders are labelled.

## Remaining creator decisions and next ownership

1. Creator/PM compare scoped entry timing and explicit local stair orientation, then approve or revise the staging direction. Do not describe quarter-width idle as final rear-facing character art.
2. Art Mane delivers separately approved six-frame walk, distinct stair-up/down, and authored turn/rear/entry/exit/profile frames using the preserved pivot contract. Only then replace labelled proxies; retain immediate original/reduced/plain fallback.
3. Build Shogun/creator performs native Windows launcher/fixture review and sustained rendering measurements on supported hardware. Gameplay/input owner decides gamepad mapping separately; this Lane A pass does not invent it.
4. Keep unclassified endpoints at fallback. Do not convert the whole graph or add exits from appearance alone. Structural global rollout is not approved; review the two pilots and21-room plan first.
5. Full fresh-save playthrough, human approach/turn readability, max-speed/rope/softlock sweep and final creator acceptance remain open.

Recover from the dedicated PR27 branch, read continuity records and verified source/evidence links, rerun tools/run_tr03_qa.py with official4.6.1. Existing TR-02 comparison stays playable. **Do not merge main, candidate, or TR-02 without explicit authorization.**

