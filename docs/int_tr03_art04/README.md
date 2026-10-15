# INT-TR03 / ART-04 — playable production-asset comparison

Continue PR27 `c2c002267c58e991966c0eebf7e098c6e7fff769`; selectively import **only** `assets/art04/` from PR30 `a6b76b9938825307bdcd4efb687c7198ea0d8681`. No art-branch gameplay foundation, accepted active sprite replacement or mainline merge.

Runtime/art checkpoint: `e91e49caeada21baad5ab25e5080e67ab16a4094` (implementation `295ee2d`, pinned asset import `e91e49c`). Later review/evidence commits do not change game behavior.

## Compare

| Option | Engine user arguments (after `--`) |
|---|---|
| Original TR02 | `--tr03-original` |
| Refined TR03 placeholders (existing default) | none |
| ART04 preview | `--tr03-art-preview` |
| Static/reduced ART04 preview | `--tr03-art-preview --tr03-reduced-motion` |
| Plain fallback | `--tr03-art-preview --tr03-plain` |

For the existing R14/R13 doorway demonstration add `--tr03-depth-demo`. It does not add a link. Use `--tr03-save=/absolute/path/to/comparison.json` to isolate saves; paths containing spaces are tested. No mode changes physics or progression. `--tr03-no-dressing` still disables structural dressing only.

- R14→R17: authored right-up contact; R17→R14: separately drawn left-down contact.
- R14→R13: one quarter-back turn key, then one inward key. They are held on the inherited loader, not looped.
- Unsupported outward, front-quarter and arrival facings use labelled approved-idle fallback; no mirrored rear-as-front or squeezed production character.
- R15/R16 walk/run and R20/R13 exceptional wind-fold retain their existing behavior and assets.
- The 0.65s loader, actual room swap below0.32/tick20, exact reciprocal arrivals, collider arrays, gates and default save identity remain authoritative.
- R14 timber / R15 masonry replace the two scoped procedural support pilots in art-preview only. Overlapping roof/arch decorations are skipped by bounded intersection; unrelated decorations, collision lips, hazard/gate rendering and pickups remain.
- Door interior/back → actor/proxy → foreground jamb/threshold → cue. Stair flight → held contact → front lip. R17 artwork is clipped at its existing room boundary, not stretched.

The four supplied drawings **are not completed animation cycles**. Walk, additional turn/entry frames, outward/front-quarter/reorientation and opposite-facing poses remain art work. Reduced mode holds one pose without staged movement/cycling. Creator art/feel acceptance and full campaign review remain pending.

## Actual verification

- Official Godot4.6.1, native macOS Apple M4 / OpenGL compatibility, viewport1280×720, zoom1.
- Full29-action batch:21 behavioral suites plus preservation/profile actions; **1,158 PASS checks, zero assertion failures or script/parser errors**. Includes32 TR02 preservation and42 pinned-asset/PR27 checks. Totals count executed checks, including overlapping suites, not unique cases.
- Five CLI comparisons with explicit save paths containing spaces:21 additional passes.
- Native engine:20 rendered transition fixtures across five comparisons/four directions pass destination and cleanup checks;126 full-resolution screenshots generated. R14 collider count23, R15 count15 across comparisons.
- Static leading-boot registration error against authored tread: up1.297px, down0.164px. These are single contact checks, not full-cycle drift certification.
- Native unpaced render-interval samples:120 intervals per mode/room,30 warmup,12 mode/scene combinations. Values in `evidence/PERFORMANCE.json`; real hardware drawing, not a sustained full-game/display-FPS certification. No screenshot encoding inside measurement.
- Isolated profiles used throughout. No creator save was read/deleted. Known isolated-HOME certificate and import shutdown RID/ObjectDB diagnostics remain recorded.
- First native capture attempt falsely failed exact arrival checks after it allowed resumed gravity to settle the actor before asserting. Fixture now freezes immediately on loader completion; final20/20 pass. Both logs are retained. No gameplay code was changed for that harness correction.

Reproduce source regression:

```sh
python3 tools/run_int_tr03_art04_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot
```

Native visual/benchmark scripts: `tests/capture_art04_comparison.gd`, `tests/benchmark_art04.gd`; pass `-- --test`. Capture code uses seeded fixtures/manual60Hz loader stepping and is not human gameplay.

## Review

![In-engine transition comparison](evidence/TRANSITION_COMPARISON.jpg)
![In-engine structural comparison](evidence/SUPPORT_COMPARISON.jpg)

Full gameplay PNGs, final/first native logs, exact commands/profiles/counts and contact data are under `evidence/`. Packaging coordination: `../agent_handoffs/INT_TR03_ART04_BUILD_HANDOFF.md`. Full PM return follows with publication/build references. **Do not merge.**
