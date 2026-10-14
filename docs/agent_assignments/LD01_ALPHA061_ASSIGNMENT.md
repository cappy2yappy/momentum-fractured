# Kaze Alpha 0.6.1 — Level Masta Masta Work Order

**Assignment ID:** LD-01-0061
**Agent:** Level Masta Masta
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Engine:** Godot 4.6.1
**Authoritative source:** this document on the PM documentation branch `docs/pm-agent-work-orders-alpha-0.6.1`
**Starting code branch:** `integration/alpha-0.6-world-momentum`
**Historical starting SHA:** `34be304` (fetch and confirm current branch tip)
**Feature branch:** `design/alpha-0.6.1-world-cohesion`
**Target integration branch:** `integration/alpha-0.6-world-momentum`

## Mission
Improve the **existing** Alpha 0.6 Metroidvania world. Address empty sprawling rooms, unclear exits, oversized floating door presentations, weak biome identity, and underused vertical traversal. Prefer carefully improved existing rooms to unnecessary expansion. Maintain creator-approved movement feel and progression.

## Baseline audit
1. Fetch remote branches and verify baseline. Review prior `design/alpha-0.6-world-expansion` including `docs/level_design/LD01_PM_HANDOFF_2026-10-12.md` if present.
2. Inventory room connections, critical path, elemental/ability gates, transitions, checkpoints, landmarks, and hazards.
3. Identify 3–5 highest-impact rooms for refinement and explain the prioritization. Record before-state evidence.
4. Keep this work isolated from The Gameplay Masta's current stabilization.

## Work priorities
**P0 — Room quality and density:** Improve traversal, secrets, platform routes, purposeful horizontal and vertical space, readable routes and visual landmarks, ideally in a few representative existing rooms. Avoid bottomless death pits; preserve logical fall destinations.
**P0 — Exits and navigation:** Contextualize floating exit presentations where possible without changing shared transition logic. Verify entry/exit reachability and destinations.
**P1 — Biome identity:** Differentiate Silent District, underground routes, and SkyWorks as appropriate through existing assets, environmental composition, geometry, background depth, and documented Art Agent requests.
**P1 — Exploration:** Provide meaningful alternate routes, return loops, grapple and wall-jump opportunities, and discovery incentives consistent with existing unlocked skills.

## Hard boundaries
Do not alter Kaze's movement physics, dash, grapple algorithm, combat code, save architecture, player sprite scale, or ability implementation. Do not overwrite another agent's work. Do not add major regions, bosses, or mechanics without PM approval. Work only on the assigned feature branch; do not merge to integration or main, and do not force push. If a design requires Gameplay or Art changes, document a cross-agent dependency for PM instead.

## Deliverables and tests
- Prioritized room-by-room audit with gaps and proposed fixes.
- Actual focused room-layout changes with exact file paths (or a candid blocked report if execution unavailable).
- Before/after screenshots or reproducible visual evidence when possible.
- Verification of connectivity, exits, traversal, critical progression and absence of accidental softlocks; run available Godot tests, report exact commands, results and limits. Never invent test claims.
- Push commits on `design/alpha-0.6.1-world-cohesion`, and open a review PR against integration where authorized; do not merge.
- Save the full PM report at `docs/agent_handoffs/LD01_ALPHA061_REPORT.md` in your feature branch.

## Required closed-loop handoff
At task start, confirm this exact assignment file is accessible, quote the assignment ID, describe the mission and show the verified starting commit. If access fails, report BLOCKED and do not invent instructions.

At task end, output a self-contained **KAZE — PROJECT MANAGEMENT RETURN REPORT**, with these sections:
A. Executive summary
B. World audit and prioritized rooms
C. Implemented changes (files and commits)
D. Gameplay compatibility and cross-agent dependencies
E. Testing and QA evidence (actual commands/results)
F. GitHub publication (branch, commit, PR, push confirmation)
G. Risks and blockers
H. Recommended next actions
I. PM decisions required
J. Final verdict

Use exactly one verdict: **READY FOR PM REVIEW**, **PARTIAL HANDOFF — CONTINUATION REQUIRED**, or **BLOCKED — PM DECISION REQUIRED**. Include clear creator playtest instructions where applicable. Publish the report and give the user its URL or exact path so they can return it to PM. If nearing task/usage limits, preserve work and issue a partial report. Completion does not authorize integration: PM approval is mandatory.
