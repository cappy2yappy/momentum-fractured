# Gameplay Parity Matrix

**Project:** Momentum: Fractured / Kaze
**Baseline branch:** `codex/web-parity-restoration`
**Baseline commit:** `298faee`
**Canonical benchmark:** [Rush Line web build](https://rush-line.thacap.chatgpt.site)
**Audit type:** Static scene, script, progression, map, and test review
**Last updated:** September 20, 2026

## Purpose

This document tracks whether the Godot build matches the web benchmark in behavior and player experience. A feature is not at parity merely because a rough implementation exists. It must also meet the benchmark for feel, clarity, level integration, presentation, and reliability.

Status terms:

- **Implemented:** Present and structurally complete, but still subject to normal playtesting.
- **Partial:** Present as a prototype, with confirmed gaps between it and the intended experience.
- **Missing:** Not currently represented in a meaningful playable form.
- **Confirmed issue:** Demonstrable from the current files without subjective playtesting.
- **Playtest required:** Requires direct comparison with the web build or hands-on validation in Godot.

The current recovered branch restores important systems, but rooms 5–12 remain content prototypes rather than the final level-design baseline. The first parity milestone is an authored five-room loop, not further expansion of the generated room sequence.

## Web-Target Parity Matrix

| Area | Current Godot implementation | Status | Confirmed gaps | Playtest-required questions | Priority |
|---|---|---|---|---|---|
| Movement | Run, variable jump, wall jump, wall slide, coyote time, jump buffering, ground/air acceleration | Partial | No dedicated movement test room or recorded reference metrics. Controller only reads horizontal movement outside water. Action-cancel rules are not formally defined. | Does acceleration, reversal, short/full jump, apex, landing, and wall-jump response match the web build? | P0 |
| Dash | Ground/air dash, one air charge, cooldown, cyan afterimages, ability gating, and preserved greater incoming horizontal/vertical momentum | Partial | The P0 momentum snap and gating regressions are fixed and covered by smoke tests. Dash still uses facing direction rather than directional aiming, and no dash invulnerability is implemented although the GDD promises it. | Is the dash distance, duration, recovery, afterimage density, direction, and cancel behavior correct? Should dash retain web-build invulnerability? | P0 |
| Combat | Three-step light combo, facing-aware restartable 0.15-second hit windows, knockback, combo counter, Echo melee, Drone ranged | Partial | Fresh combo windows and single health-state signaling are now regression-tested. Only two true enemy archetypes exist. Bosses are enlarged Echo instances. Heavy attack, dodge, parry, aerial attack, and dash-strike described in the GDD are absent. | Does every visible player and enemy strike register exactly once during live collisions? Are active frames readable? Are damage, recovery, hitstun, and knockback comparable to the web build? | P0 |
| Wind Tether | Q/Middle Mouse hold, authored anchors, 410-pixel range, tangent pumping, momentum release, animated energy strand | Partial | Tether is always unlocked. It has no line-of-sight or obstruction check and no maximum cursor-to-anchor aim tolerance. Rope correction directly rewrites `global_position` after `move_and_slide()`, which can bypass collision resolution. | Does tether ever select an unintended anchor? Can it attach through walls? Does pumping build momentum naturally in both directions? Is release speed preserved without jitter or clipping? | P0 |
| Water | Water Areas in rooms 8 and 10, reduced gravity, drag, fall-speed cap, Space swim stroke | Partial | Each water area is a shallow 150-pixel strip at the bottom of a one-screen room. There is no descend input, directional swim, stable buoyancy behavior, water animation, or meaningful aquatic route. | Can Kaze descend, hover, surface, and exit consistently? Which actions should work underwater? Does entering water at speed feel coherent? | P1 |
| Map | Persistent visited-room data, always-visible mini-map, M-key full overlay, current-room highlight | Partial | The drawn graph does not match runtime transitions. It lacks doors, elevations, gates, shortcuts, secrets, and region information. | Is the current room immediately readable? Does exploration reveal information at the right time? Is the full map useful for navigation without overexplaining? | P0 |
| Character/loadout | I-key panel showing HP, tether, dash, current kunai, and Guard Veil status | Partial | It is a text readout rather than a loadout interface. It has no character presentation, icons, locked slots, descriptions, selection controls, or meaningful equipment decisions. | Is the panel readable during play? Does it provide enough information to support switching and progression decisions? | P1 |
| Verticality | Elevated exits, stepped platforms, visible anchors, wall movement | Partial | Generated rooms remain one 1280×720 screen with three or four staircase-like platforms. There are no multi-screen shafts, meaningful vertical camera travel, branching elevations, fall recovery routes, or layered encounters. | Does each rise create a traversal decision? Is height filled with meaningful movement and encounter pressure rather than empty space? | P0 |
| Subterranean routes | Rooms 8, 10, 11, and 12 use darker terrain crops and overlays | Missing as level structure | “Subterranean” is currently a visual treatment on the same one-screen room generator. There is no authored descent, tunnel topology, underground landmarking, or coherent surface-to-water geography. | Is the transition underground spatially understandable? Does the underground area feel distinct without losing the established visual identity? | P1 |
| Elemental kunai | Wind from start; Fire and Electric unlocks; F throws; mouse wheel cycles unlocked elements | Partial | All elements share the same movement, damage, and enemy effect. Selection is not integrated into the loadout panel. Element identity is currently color plus gate compatibility. | Are elements distinguishable in motion and impact? Is cycling reliable under combat pressure? Does each element earn a combat and exploration identity? | P1 |
| Kunai gates | Fire gate in room 8 and Electric gate in room 12 | Partial | Gates block the linear forward route instead of opening optional or return paths. Open state is not persisted; `gate_id` is unused. Wrong-element feedback is absent. The room 8 Fire gate may be bypassable because its vertical span does not fully cover the elevated exit approach. | Is the required element obvious before firing? Can gates be bypassed with jump, dash, wall movement, or tether? Does opening one feel like a meaningful world change? | P0 |
| Enemies | Rooms 5–11 request four to six enemies; Echo/Drone mix; rooms 7 and 12 request one scaled Echo boss | Partial | Generated positions follow a formula rather than platform geometry or encounter purpose. Ground enemies can fall or cluster instead of occupying intended lanes. There are no aquatic enemies, tether-pressure enemies, or bespoke boss moves/phases. | Do enemies remain on intended platforms? Do attacks connect from both facings and elevations? Does each encounter activate the room's geometry? | P0 |
| Room density | Four explicit early-room scenes and eight generated route-room layouts | Below parity | Rooms 5–12 share boundaries, spawn logic, anchor patterns, environmental treatment, and progression logic. Most are open single-screen boxes with sparse platforms. Intimate corridors, authored shortcuts, reliquaries, secrets, and route choices are absent. | Can the purpose of each room be stated in one sentence? Does each room introduce, combine, or test a meaningful idea? | P0 |

## Topology and Spawn Status

These findings are file-verifiable and do not require subjective playtesting.

### Resolved in the recovery baseline

1. **Generated-room backtracking now uses directional arrival markers.**
   Rooms 5–12 create `entry_from_roomN` markers for every incoming connection. Forward traversal arrives at the left side and backtracking arrives at the right side.

2. **Room 4 now returns to Room 3 and accepts Room 5 backtracking.**
   Its explicit scene data matches the canonical graph and includes `entry_from_room5`.

3. **Runtime transitions and the map now consume one authoritative graph.**
   `scripts/rooms/room_graph.gd` defines canonical scenes, positions, connections, and marker naming. The map now includes Room 9 → Room 10 and the one-way Room 12 → Room 5 prototype loop.

4. **Topology integrity is covered by automated checks.**
   The smoke suite verifies canonical targets, valid arrival markers, reciprocal standard links, and the intentional one-way loop across all twelve rooms.

### Remaining confirmed limitations

1. **Room 3 Safe remains historical and unused.**
   `room_03_safe.tscn` is excluded from the canonical twelve-room graph and has no current inbound runtime transition.

2. **The Room 12 → Room 5 prototype loop is intentionally one-way.**
   The map shows the connection as an undirected line because it does not yet render directional arrows. The authored parity slice must replace or deliberately justify this structure.

3. **There is no ability-gated return path.**
   The current Fire and Electric gates are mandatory forward blockers. They do not satisfy the GDD requirement for an unlock that changes an earlier route, reveals a shortcut, or rewards backtracking.

4. **Room 8 silently becomes a checkpoint on entry.**
   `route_room.gd` sets the checkpoint during `_ready()` without an authored checkpoint object, interaction, or clear player-facing confirmation.

5. **Generated enemy placement is disconnected from layout geometry.**
   Enemy positions are produced by one formula instead of authored spawn markers. The formula does not verify ground beneath Echoes or reserve meaningful positions for Drones.

## Confirmed System and Test Gaps

### P0

- Replace direct tether position teleportation with a collision-safe rope constraint.
- Add tether line-of-sight and aiming acceptance checks.
- Validate the new restartable melee windows through live collision playtests, not only direct regression calls.
- Reconcile the GDD's later-unlock language with the current baseline Dash and Wind Tether decision.
- Persist gate state and make the room graph authoritative rather than maintaining separate, contradictory transition and map definitions.

### P1

- Define water as a complete movement state with descend/surface behavior and appropriate animations and effects.
- Give Fire, Electric, and Wind distinct combat or world interactions beyond shared damage and gate color.
- Replace scaled-Echo bosses with encounter-specific behavior before treating boss rooms as parity content.
- Make the loadout panel interactive and progression-aware.

### Automated coverage gap

`tests/alpha_08_smoke.gd` currently verifies scene loading, method presence, selected constants, run-animation slicing, anchor presence, rewards, ability save/load, dash momentum preservation, restartable melee windows, and single health-event propagation. It directly calls room death handlers to simulate progression. It does **not** verify:

- Player reachability through a room
- Movement distances or timings
- Measured dash distance or live tether momentum
- Tether collision or line-of-sight
- Water entry, exit, descent, and surfacing
- Gate persistence or bypass resistance
- Actual player/enemy collision registration
- Pause, map, and character-panel state interaction

The full smoke suite was executed with the official Godot 4.6.1 Linux binary after the P0 integrity pass: all checks passed across 12 rooms. Godot still reports an ObjectDB leak warning during test shutdown.

## First Authored Vertical Slice

The next acceptance target is a five-room loop. It should replace a small part of the generated campaign for validation rather than add five more rooms after Room 12.

### World loop

1. **Compact Surface Approach**
2. **Wind Relay Shaft**
3. **Underground Threshold**
4. **Canal Chamber**
5. **Fire-Sealed Return Route**

The route must connect back toward the surface after the Fire unlock, demonstrating real Metroidvania backtracking rather than a linear sequence of colored locks.

### Room 1 — Compact Surface Approach

**Purpose:** Establish movement, atmosphere, and encounter density.

- Use an intimate corridor opening into a compact arena.
- Place three enemies across low and high lanes, with every spawn tied to authored geometry.
- Provide one visible but initially inaccessible return-route landmark.
- Avoid empty full-screen height.

**Acceptance:** The player understands the route, the encounter uses both elevations, and no enemy falls away from its intended position.

### Room 2 — Wind Relay Shaft

**Purpose:** Prove vertical traversal and tether quality.

- Extend across two or three camera heights.
- Use intentionally spaced anchors, fallback ledges, wall-jump surfaces, and an upper exit.
- Validate the route without enemies first; then add one pressure enemy that does not obscure learning.
- Provide safe recovery from most failed swings without removing consequences.

**Acceptance:** The player can read the intended line, pump the swing, preserve release momentum, and reach the upper exit without collision clipping or unintended anchor selection.

### Room 3 — Underground Threshold

**Purpose:** Make the descent and region transition spatially coherent.

- Transition lighting, materials, sound, and architecture from surface to underground.
- Include an authored checkpoint or reliquary rather than a silent auto-checkpoint.
- Add a landmark visible on both the room and map.
- Establish the route toward water and the future return shortcut.

**Acceptance:** The player can explain where they came from, where they are going, and how this location relates to the surface.

### Room 4 — Canal Chamber

**Purpose:** Validate water as traversal rather than damage or decoration.

- Give the water enough depth for ascent, descent, suspended movement, and controlled exits.
- Combine dry ledges with one underwater route and one water-specific threat or timing problem.
- Define underwater dash, tether, attack, and kunai behavior explicitly.
- Avoid placing an instant-death plane under navigable water.

**Acceptance:** Kaze can enter at speed, descend, surface, exit, and recover consistently. Water changes movement without feeling unresponsive.

### Room 5 — Fire-Sealed Return Route

**Purpose:** Demonstrate an ability-gated world change.

- Place a clearly telegraphed Fire seal on an optional shortcut or secret path.
- The main forward route must remain logically separate from the locked return path.
- Persist the opened gate across room transitions and save/load.
- Update the map when the gate is discovered and again when it is opened.
- Route the opened shortcut back toward the Surface Approach or Wind Relay Shaft.

**Acceptance:** The player recognizes the Fire requirement, cannot bypass the gate with traversal exploits, opens it with clear feedback, and experiences meaningfully shorter return travel.

## Implementation Priorities

### P0 — Truthful foundation

1. ~~Correct all bidirectional door targets and directional spawn markers.~~ Completed in `298faee`.
2. ~~Define one authoritative room graph used by both transitions and the map.~~ Completed in `298faee`.
3. Fix tether collision/aiming and validate the corrected dash/combat behavior through direct playtesting.
4. Resolve starting-ability versus unlock contradictions.
5. Author the five-room geometry and entrance/exit metadata.
6. Move the Fire gate from the mandatory forward line to the return shortcut.
7. Place enemies with explicit encounter spawn markers.

### P1 — Complete the experience

1. Build the full vertical shaft with camera travel and recovery routes.
2. Build the underground transition and authored checkpoint/reliquary.
3. Implement complete water traversal and the Canal Chamber.
4. Persist gate state and show gates/shortcuts on the map.
5. Upgrade the character/loadout interface.
6. Add area-specific art, lighting, audio, VFX, and combat pressure.

### P2 — Validate and scale

1. Add automated graph reciprocity and spawn-marker validation.
2. Add deterministic movement and momentum measurements.
3. Add gate persistence, bypass, water-state, and combat-window tests.
4. Record matched web/Godot captures for movement, dash, tether, combat, and water.
5. Expand the authored room kit only after creative-direction approval of the slice.

## Manual Acceptance Tests

### Movement

- Reverse direction at walk and full run. Confirm responsiveness without sliding.
- Compare tap jump and held jump for height, time to apex, and landing control.
- Walk off an edge and use the coyote window.
- Press jump shortly before landing and confirm the buffered jump occurs once.
- Wall-jump in both directions and confirm lateral momentum is predictable.
- Test jump, attack, dash, and tether cancellation at takeoff, apex, fall, and landing.

### Dash

- Dash from idle, full run, backward movement, jump ascent, fall, and tether release.
- Record velocity immediately before dash, during dash, and on the first frame after dash.
- Confirm the intended amount of incoming momentum is preserved.
- Verify air-dash recharge only occurs under the intended condition.
- Confirm afterimages remain readable without obscuring Kaze or nearby hazards.
- Confirm whether dash grants damage immunity; make behavior and documentation agree.

### Wind Tether

- Aim directly at each anchor, between anchors, away from anchors, and through a wall.
- Confirm only a valid visible target is selected.
- Pump left and right from both sides of an anchor.
- Release at the bottom, side, and top of a swing and compare exit velocity.
- Swing beside floors, walls, corners, and ceilings; confirm no clipping or teleporting.
- Test tether-to-dash, dash-to-tether, tether-to-attack, and wall-jump-to-tether transitions.

### Combat and enemies

- Attack every enemy from left, right, above, below, and at maximum reach.
- Confirm each visible strike registers once and each miss remains a miss.
- Attempt the next combo input at minimum cooldown to expose dead hitbox windows.
- Let each enemy attack from both facings and on every intended elevation.
- Confirm ground enemies remain on their assigned platforms.
- Confirm flying enemies pressure traversal without occupying inaccessible or unfair positions.
- Verify death, room-clear count, door unlock, rewards, and persistence after leaving and returning.

### Water

- Enter slowly, fall into water, dash into water, and swing into water.
- Descend, stop, ascend, surface, and exit from both sides.
- Test jump/swim input at the surface boundary to detect flicker or double impulses.
- Test dash, tether, melee, and all kunai underwater according to the approved rules.
- Confirm water never overlaps an instant-death zone unless explicitly designed and communicated.

### Map, transitions, and progression

- Traverse every connection in both directions and verify arrival at the corresponding doorway.
- Compare every runtime connection with the mini-map and full map.
- Save and reload in each room and at the authored checkpoint.
- Discover the Fire seal before acquiring Fire; verify its map state and visual communication.
- Strike it with Wind, Electric, and Fire; confirm clear wrong/correct feedback.
- Leave and reload after opening the gate; confirm it remains open.
- Use the shortcut and confirm return travel is materially shorter.

### Level-design acceptance

- State each room's gameplay purpose in one sentence after completing it.
- Identify at least one meaningful choice, test, or combination introduced by each room.
- Confirm vertical space contains routes, recovery, combat pressure, or landmarks rather than empty height.
- Confirm surface, underground, and water areas form understandable geography.
- Confirm exits occur at elevations that follow the route's spatial logic.
- Confirm encounter density supports the room instead of filling it indiscriminately.

## Slice Exit Criteria

The authored loop is ready to propagate only when:

- All P0 topology, movement, tether, combat-window, and gating defects are closed.
- Every connection works bidirectionally with correct directional spawns.
- Runtime topology and the map share one authoritative graph.
- The vertical shaft, underground transition, aquatic room, and Fire return shortcut are all functional and readable.
- Gate state, visited rooms, checkpoint state, abilities, and cleared encounters survive save/load.
- Manual parity captures show acceptable movement, dash, tether, combat, and water behavior against the web benchmark.
- The creative director approves room density, navigation clarity, game feel, and presentation.
