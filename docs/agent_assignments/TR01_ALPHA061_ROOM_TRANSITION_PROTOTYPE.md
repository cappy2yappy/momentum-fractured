# KAZE ALPHA 0.6.1 — TR-01-0061 ROOM TRANSITION PROTOTYPE

**Assignment:** TR-01-0061
**Issued by:** Project Management (PM-01), with creator feedback 2026-10-14
**Role:** Room Transition Systems / Level Presentation / Gameplay Integration specialist
**Game/repository:** Momentum Fractured / Kaze — https://github.com/cappy2yappy/momentum-fractured
**Engine:** Godot 4.6.1
**Authoritative work order branch:** `docs/pm-tr01-alpha-0.6.1-room-transitions`
**Source baseline:** `integration/candidate-alpha-0.6.1-gp-ld`, observed review head `afecef1922231081807a332c511de85c7941fec8` (fetch and reverify before starting)
**Related combined review PR:** https://github.com/cappy2yappy/momentum-fractured/pull/10
**Target feature branch:** `feature/alpha-0.6.1-room-transition-prototype`
**Desired review PR base:** `integration/candidate-alpha-0.6.1-gp-ld` (do not target main or automatically merge)
**Milestone:** Alpha 0.6.1 polish candidate; *not* a release approval

## 1. Why this exists / creator decisions

The creator likes the combined Alpha 0.6.1 movement and feels its **current speed is fine**. Preserve controller movement, floatiness, dash timing, tether momentum, Kaze size/anchors, progression and saved profiles. Creator accepts current biome direction only as **placeholder art**.

The first door presentation felt like an oversized floating outline; LD-01 replaced it with compact housings. The creator now finds the new doors **too small** and wants a more natural, visually coherent way to move between rooms. This is a transition-*presentation and usability* redesign, not authorization to alter world topology, scene graph architecture, game balance, or transition destinations.

High-level visual directions: Hidden Village peaceful prologue; Overgrown Shrine is the approved *proposed* awakening environment; Canal Remains leads toward City/Silent District. These future environments do not require new rooms under this assignment. Reference library and decision record:
- `docs/project_management/PM_DECISIONS_2026-10-14_CREATOR_REVIEW.md` on `docs/pm-shared-art-asset-registry`, decision commit `9fc5b52`.
- Art concept branch `art/alpha-0.6.1-biome-identity` (PR #11); *draft placeholders*, not automatically merged.
- Level Design PR #9, included in combined candidate PR #10.

## 2. Starting source audit

1. Read this entire document. Acknowledge assignment ID and verified source ref/SHA in your chat before editing.
2. Fetch relevant refs, verify `integration/candidate-alpha-0.6.1-gp-ld` head, and create a **separate clean feature branch/worktree**. Preserve dirty working trees; never force-push, amend unrelated work, or merge PRs #8–#11.
3. Inspect existing `scripts/world.gd` `draw_door()`, `scripts/room_presentation.gd`, original and expansion door drawing, player E interaction, room transitions, portal arrival coordinates, save/progression/gate checks, collision/visibility, HUD and labels. Document actual technical interface and exit sizes (the existing LD housing is 64×84 with 48×65 inset; do not assume all doors use a uniform interaction range).
4. Review PR #9 room evidence and combined PR #10 54 captured exits at 1280×720 zoom 1.0. Verify potential prototype rooms are playable with current source; do not invent room IDs.
5. Check asset sizes, camera framing and art constraints. Do not make test environments depend on unmerged placeholder Art PR #11.

## 3. Proposed visual treatments (prototype only)

Build two context-sensitive treatments **on two selected existing, connected rooms**, not all 21 rooms:

**A — Night-city rooftop / service passage.**
- A materially legible, character-scale entrance shaped as architecture, e.g. lit stairwell, side alley, maintenance gate, rooftop access.
- Distinguishable from ordinary scenery and from elemental-locked gates. An active entry cue must clearly read at gameplay camera scale, not tiny text only.
- Appropriate city palette and strong contrast with characters/hazards without overwriting Art Mane's biome production work.

**B — Canal/underground masonry passage.**
- Integrated arch, tunnel mouth, culvert or maintenance threshold with readable entry affordance and usable landing base.
- Use existing neutral assets/placeholder geometry to demonstrate treatment without assuming final Ruins canon or inserting a prologue scene.

Provide **at least two visual alternatives** for entry affordance: a contextual architectural entrance and a stylized ninja transition moment. A ninja smoke/wind-fold/teleport effect is welcome if concise, readable and consistent with Kaze, but it should *accent* the transition rather than replacing navigable entrance clarity.

Decide in-world treatment based on **per-exit type metadata / palette or a bounded room-presentation map**, not sweeping `draw_door()` substitutions for every exit. Unchanged rooms retain the current functional presentation. Prefer data-driven parameters over hard-coded destination rewrites.

## 4. Implementation boundaries and behavior

- Preserve **all** existing connectivity/reciprocal arrival points, portal target IDs, collision geometry, gates, ability requirements, room state, save files, checkpoints, input semantics, and interaction activation. `E` remains the primary input; avoid accidental triggers.
- Preserve regular exit interaction radii, even if new visual entrance art is larger. Keep activation affordances visible and not obscured by HUD, damage effects or scenery.
- No changes to player movement physics, speed, dash impulse/timing, jump floatiness, grapple swing, sprite dimensions/anchors or kunai/elemental logic.
- No new bosses, rooms, sequence changes, or finalized Ruins location. No mandatory shader-intensive full-screen effects. Target native 60 FPS and reduced-motion-friendly transition option if feasible.
- If an exit is gated, keep a visible locked/rejected signal; non-gated entrances must never imply a new elemental requirement.
- Ensure a transition effect cannot leave the character invisible, stuck, invulnerable indefinitely, or double-trigger on repeated input. Check input lock and restoration timing if using effects. Prefer not to modify the player controller.
- Proposed global migration must be a separate creator/PM decision following prototype review; default appearance outside pilot rooms must remain unchanged.

## 5. QA and evidence requirements

Run Godot 4.6.1 import, preservation verifier and existing relevant suites (at minimum approved baseline, movement_momentum, gameplay_stabilization, traversal_transitions, world_cohesion_traversal, integration_candidate, save_compatibility, expansion_gates_save, expansion_traversal). Run full combined QA runner where environment permits, with actual outputs.
Add dedicated transition regression checks to cover:
- Both prototype entrances/return paths, normal E activation and rejection from outside ordinary range.
- Destination and safe spawn correctness in both directions.
- All relevant ability/element gates remain enforced, without sequence breaks.
- No save/checkpoint corruption or repeated-input transition glitches.
- Visual state resets on room entry and on death/reload, if effects introduce state.
- Other rooms untouched and existing transitions functional.
- Rendering at **1280×720, camera zoom 1.0**, Kaze at approved size, including at least one before/after image per prototype, with prompts visible. Video/GIF is desirable for effects if tools allow, not a fabricated requirement.
- Frame-time measurements during effects when renderer available. Distinguish test averages from sustained 60 FPS. Report any nonfatal engine shutdown warnings.
- Native playable prototype for macOS and/or Windows if export tooling exists; provide exact safe-access path/ZIP and tested-platform statement. Do not claim remote binary publication unless verified.

## 6. Handoff package and GitHub rules

Commit and push to `feature/alpha-0.6.1-room-transition-prototype`; open a **draft PR targeting the combined candidate** `integration/candidate-alpha-0.6.1-gp-ld`. Do **not** merge to that candidate, shared integration or main. Do not rebase/overwrite specialist branches.

Save:
- `docs/level_design/alpha061/ROOM_TRANSITION_PROTOTYPE_SPEC.md` including audited exits/technical constraints, two contextual concepts, alternatives, how pilot rooms were selected, and rollout hazards.
- `docs/agent_handoffs/TR01_ALPHA061_PM_REPORT.md` complete PM handoff.
- `docs/agent_handoffs/TR01_ALPHA061_TEST_RESULTS.json` or markdown containing reproduction commands, results and limitations.
- Source changes and preview evidence in organized project-appropriate paths with asset provenance.
- Creator playtest instructions for the two entrances.

At the very end produce full **KAZE — PROJECT MANAGEMENT RETURN REPORT**, with sections:
A Executive Summary
B Source/Branch Verification
C Existing Transition Audit and Problem
D Two Proposed Treatments + Prototype Room IDs
E Actual Implementation and Files
F Preservation and Gameplay Compatibility
G QA Evidence / Measured Performance / Preview or Builds
H GitHub Publication (branch, commit, PR, pushed status)
I Risks / Unresolved Questions
J Creator Playtest Steps and PM Decisions Required
K Verdict: **READY FOR PM REVIEW**, **PARTIAL HANDOFF — CONTINUATION REQUIRED**, or **BLOCKED — PM DECISION REQUIRED**.

If a required executable, screenshot tool, or GitHub permission is unavailable, state the limitation, commit safe partial deliverables, and return a partial report. Do not quietly stop without a report when possible.

## 7. Acceptance / explicit PM hold points

**Pass requires** two distinguishable architecturally contextualized entry/exit prototypes with readable interaction, maintained route/ability/save correctness, preservation regression, and real QA report. Human creator approval is still required for visual feel. **Do not** scale the design to every room before creator approval.

Once TR-01 handoff is published, return its exact committed GitHub report permalink to PM-01 for review. Final milestone acceptance and integration remain with the creator/PM.
