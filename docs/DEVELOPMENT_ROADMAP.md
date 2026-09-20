# Development Roadmap

## Baseline rule

The canonical web build is the quality target for feel, presentation, density, interface, and world coherence. The Godot build may add depth, but it must not regress those qualities. The current twelve-room campaign is a systems prototype, not twelve finished rooms.

## Milestone 0 — Recovery baseline

**Exit criteria:** the recovered branch is published, boots in Godot 4.6.1, loads every room, and has reproducible Windows/macOS export settings.

- [x] Publish `codex/web-parity-restoration`.
- [x] Keep engine and build documentation on Godot 4.6.1.
- [x] Preserve the current smoke suite and add focused regression tests with each system fix.
- [x] Identify generated metadata that belongs in source control.

## Milestone 1 — Five-room parity slice

Build one authored, connected loop that proves the game's intended identity:

1. compact Silent District surface approach;
2. purposeful vertical shaft with tether routing;
3. subterranean checkpoint/reliquary room;
4. traversable aquatic chamber with distinct physics;
5. elemental-gated return shortcut to the surface route.

Implementation status:

- [x] Authoritative graph and reciprocal directional spawns.
- [x] Wind Tether aim, line-of-sight, and collision-safety hardening.
- [x] Compact Surface Approach first authored conversion (`room_05_route.tscn`).
- [x] Multi-screen Wind Relay Shaft (`room_06_route.tscn`).
- [ ] Underground Threshold and authored reliquary/checkpoint.
- [ ] Deep traversable Canal Chamber.
- [ ] Persistent Fire-sealed return shortcut.

**Exit criteria:** correct bidirectional spawns and map links; reliable damage; authored enemy placement; visible tether anchors and elemental locks; working map/loadout UI; no automatic-death water; movement accepted through direct playtesting.

## Milestone 2 — Canonical character presentation

- Produce clean, transparent canonical Kaze sheets with fixed proportions and costume details.
- Implement idle, run, crouch, slide, jump, fall, wall movement, dash, tether, attack, kunai, hurt, and death states.
- Add crouch collision/clearance behavior and progression-gated momentum slide.
- Tune dash afterimages, wind tether VFX, and elemental kunai readability.

**Exit criteria:** no legacy red-scarf Kaze art appears in a candidate build, and every implemented action has a readable animation state.

## Milestone 3 — Campaign architecture

- Replace formulaic route generation with authored room data/scenes.
- Make the runtime topology, survey map, entrances, and return routes use one authoritative graph.
- Add persistent gates, shortcuts, checkpoint state, and room-clear state.
- Establish real enemy archetypes and authored keeper encounters.

**Exit criteria:** the campaign can expand without duplicating transition logic or allowing the map and runtime topology to drift.

## Priority policy

- **P0:** blocks a trustworthy playtest or contradicts canonical behavior.
- **P1:** required for the five-room parity slice or core presentation.
- **P2:** campaign expansion, polish, and optional depth after the slice is accepted.

The next implementation task is the Underground Threshold: a compressed descent, explicit checkpoint/reliquary interaction, and Fire Kunai reward presentation.
