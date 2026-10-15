# TR-03 Lane A recovery — 2026-10-15

Authoritative work order: `880718f51b761ffbe40fb028741135b58b00e5f1:docs/agent_assignments/TR03_ALPHA061_EMBODIED_TRANSITIONS.md`.

Recovered TR-02 PR16 at `e9a2d1ab0537f3f903c543b080451b3556961179`. DEV-06 PR7 is historical, not the current code foundation. Remote branches inspected: TR-01, TR-02, current candidate, and both TR-03 art branches. No Lane A TR-03 implementation branch existed at recovery. New isolated branch: `feature/alpha-0.6.1-tr03-embodied-transitions`, PR base TR-02. Nothing was merged or restarted.

Art coordination sources: PR25 `85025b1c389d4998805d1a5ff3c856a1b8cc4bea` (entry-poses), PR24 `ecaee8063a418c322fb183e90fe6cf8e2bcb564e` (review-kit). Read Lane B handoff, frame/pivot specification, both matching 30-frame contracts, architecture plan. Technical specification copy is `LANE_B_TECHNICAL_CONTRACT.json`. No final artwork is creatively approved; none is imported. New320x724/pivot(160,600)/scale0.303125 contract is reserved for accepted future clips; existing clips retain their actual individual pivots/scales. Separate up/down, rear/turn and walk sprites remain pending.

Baseline recovery ran the nineteen existing behavioral suites plus prepare/reload profile checks:893 PASS assertions, no behavioral failures. First editor import emitted existing MetSys UID/editor-class lookup errors; a repeat import resolved these. Original first-run logs/results are retained as baseline evidence, not described as clean import. Source/visual QA for this change follows separately.

Scoped staging: R15↔R16 directional carry/rearm unchanged; R14→R17 explicitly authored local stair-up staging and reverse stair-down (not inferred from unrelated room y coordinates); R20↔R13 original wind-fold unchanged. One opt-in existing R14↔R13 link is a depth-facing metadata demonstration with --tr03-depth-demo. Other endpoints remain explicit fallback until orientation is authored. No topology, endpoint, clock, save or controller changes. Rendering proxies never feed simulation; pause/respawn/direct rebuild cancel them. Ordinary stairs and inward-door poses are labeled placeholders, not finished character animation.

Only two noninteractive structure pilots: existing R14 shelf(750,900,400,40), existing R15 shelf(1320,940,400,40). Supports are drawn in the background before platform lips and live actors. No collider/navigation changes. Original comparison disables these additions.

CLI push lacks credentials in this environment. Connected GitHub Git-data publication will preserve tree-equivalent recoverable checkpoints with different commit IDs. No force ref updates. Continue on the remote branch, not an old DEV-06 build.
