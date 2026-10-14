# TR-02 — Mixed Room Transition Playable Comparison

**Assignment:** TR-02-0061
**Owner:** Room Transition Specialist; coordinate with Level Masta Masta and The Art Mane only for bounded prototype input.
**PM date:** 2026-10-14
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Engine:** Godot 4.6.1
**Source baseline:** TR-01 reviewed implementation, `feature/alpha-0.6.1-room-transition-prototype` at observed head `c26cb7fa23131c2fd9c8deae288f7d0d468a6b52`; re-verify branch SHA, then create clean feature branch `feature/alpha-0.6.1-mixed-transitions`.
**Draft PR review base:** TR-01 feature branch, not shared integration or main.
**Existing reviewed references:** PR #10 combined candidate; PR #12 TR-01 contextual entrances; creator discussion `docs/agent_handoffs/TR01_CREATOR_DISCUSSION_PM_SUMMARY_2026-10-14.md` on TR-01 head.

## Creator direction and PM decisions
Creator **likes R14 service stairwells**, considers generic doors too small despite 80x108 revision, and explicitly favors **walk-through passage transitions**, citing Shadow Complex for meaningful verticality and possible multiple exits at different heights. Approved Kaze speed, floatiness, sprite sizing, dash/tether physics, combat, saves, gate conditions must remain unchanged. Current visual art remains placeholders. The desired future vocabulary is:
- Walk-through: continuous rooftops/streets/open culverts; threshold crossing rather than E.
- E-interactive: building doorways and stairwells, retain TR-01 R14 stairwell treatment.
- E-interactive special: ninja wind-fold/teleporter portal on an existing appropriate connection.
No new map topology/room exits is approved for implementation in this pass.

## Scope
1. Inspect actual existing exit graph, spawn/arrival/camera code, interaction ranges, prior TR-01 tests and current 21 rooms. Identify **three real existing connections** for a side-by-side prototype without creating or redirecting links. Choose a rooftop/open tunnel for walk-through, existing liked R14 stairwell for interactive, and another suitable existing connection for special teleporter. Document room IDs, coordinates, prerequisites, reciprocal arrival and rationale before editing; prefer a walk-through on a connection currently E-activated, with explicit feature-scoped conversion.
2. Implement one **momentum-compatible walk-through** opening: visible full-height architecture and directional threshold detection when Kaze intentionally crosses it while traveling toward opening. Do not require E. Avoid proximity-only activation, accidental crossing during grapple/dash near a gate, immediate backtracking loops, death/respawn reactivation and held-input bounce-back. Design an exit-plane + crossing-direction/hysteresis/arrival-cooldown system respecting movement continuity and wall/ceiling collisions.
3. Preserve R14 contextual service stairwell as interactive E-based control condition. Avoid changing its art, ability restrictions or interaction radius unless unavoidable and reported.
4. Implement one distinctly readable special wind-fold/teleporter visual and E semantics on a suitable existing gated or special connection. No gameplay unlock, lore or new travel powers. Existing reduced-motion option must have a safe, non-flashing alternative.
5. Camera: prototype modest directional framing/scroll that respects room bounds, safe landings, HUD readability, normal 1280x720 camera zoom 1.0. Existing discrete room loading may require short controlled pan/fade rather than false seamless rendering across room bounds; do not promise continuous streaming until implemented.
6. An existing required gate MUST reject crossing and signal why; no bypasses, wrong-target links, save version changes or player controller tuning. Exit state logic must survive fresh and upgraded saves. Both ends of a converted connection must support safe reverse traversal, coherent on-screen cue and map link.
7. **Multiple same-wall high/low exits:** deliver separate `docs/level_design/alpha061/TR02_MULTILEVEL_EXIT_DESIGN.md` depicting upper rooftop and lower canal/street branch candidate, with graph/arrival/gating/map implications. NO new exit, room graph, platform geometry, or map state implementation without another creator/PM approval.

## Implementation and testing
- Bounded per-edge transition policy, not a global rewrite of `world.interact()`. Preserve all other E exits unchanged.
- Add dedicated tests: directional intentional crossing, walking/running/dashing toward portal, invalid/corner contact, reverse travel, arrival cooldown, save/reload, death mid-transition, held E on stairwell/teleporter, every gate and reciprocal position, map labels and no regression in other exits.
- Run existing TR-01 109 assertions and full 691-assertion combined baseline (or accurate updated counts) where feasible, plus TR-02 tests, preserve raw logs with pass/fail counts and engine warnings.
- Capture normal-zoom before/after and a real playable GIF/video if possible, preferably creator-usable Mac and Windows ZIPs. The newly approved CI-01 GitHub Actions infrastructure PR #13 is still unmerged; do NOT rely on its workflow being available on this branch. Build locally or explicitly coordinate a separate safe CI testing request without merging features.
- 60 FPS expectation persists. Measure frame-time spikes during effects, no false sustained 60 FPS claim. The playtest must let the creator compare all three transition types without unearned permanent saves; provide isolated profile launchers/fixtures.


## Creator addendum — Persona 5-inspired graphic transition presentation (2026-10-14)

**New creator preference:** When exiting a room, the transition's presentation should capture some of the stylish, kinetic graphic-design energy associated with **Persona 5**. This is an **aesthetic reference, not a request to copy its trademarked graphics, fonts, music, characters, logos or exact animation sequences**. The goal is a Kaze-original visual identity that complements ninja movement, the approved city-pop/jazz-hop soundtrack direction, and the early city's indigo/rose palette.

**Required bounded prototype:** Alongside the TR-02 comparison, include at least one **Kaze-original graphic transition treatment** for the pilot walk-through and/or special transition. Explore directional motion graphics (angled panel/wind-cloth wipes, silhouette streaks, impact framing, punchy 2D layering) that track Kaze's travel direction and communicate entry and arrival. Permit a brief district/room destination title only if legible and nonintrusive. Prefer a concise 0.2–0.6 second presentation study that does not change the underlying transition clock or navigation timing; timings are exploratory, not a mandate to alter game physics. The approved stairwell should remain grounded and readable, with any new graphic flourish modest by default.

**Camera/gameplay constraints:** Preserve the player's sense of forward momentum, the actual safe landing position and reciprocal traversal. No frame-hiding trick may mask a wrong spawn, sequence break or gate bypass. Do not force a long freeze, strong camera shake or repeated strobing. Support the existing reduced-motion flag with a straightforward fade/static directional graphic alternative. Maintain 1280×720 viewport, normal zoom, HUD legibility, at least 60 FPS target, and visibility of interactable gates. If smooth scroll between discrete rooms cannot be genuinely implemented with current room loader, prototype a deliberate graphic wipe instead and label that limitation.

**Evidence & creator sign-off:** Provide side-by-side capture or short GIF/video of (1) ordinary walk-through, (2) Persona 5-*influenced*, Kaze-original graphic wipe, and (3) reduced-motion treatment. Record effect timings, actual draw-frame performance samples and any spikes. Let creator select the preferred graphic intensity before expanding globally. Treat music beat-sync as a later optional polish layer, not a dependency or blocking requirement for this milestone.

## Branch, handoff and acceptance
- Branch `feature/alpha-0.6.1-mixed-transitions`, draft PR targeting TR-01 branch. Do not merge `main`, shared integration, PR #10, PR #12 or art PR #11.
- Commit and push incrementally; preserve completed work if stalled.
- Deliver `docs/level_design/alpha061/TR02_MIXED_TRANSITION_SPEC.md`, multi-height exit proposal doc, source changes and preview files.
- Deliver `docs/agent_handoffs/TR02_ALPHA061_PM_REPORT.md` and actual structured test results with source SHA, PR, builds, limitations, creator test instructions.
- Full PM return sections: baseline verification; audited graph; exact pilot choices; implementation; preservation; QA; artifact links/local paths; risks; creator comparison test; next approval.
- **Ready for PM review** only if three modes can be compared in actual playable prototype and relevant gates, arrivals and saves pass. If not, provide partial report.
- No automatic global roll-out or topology additions. Creator chooses preferred treatment after playtesting.
