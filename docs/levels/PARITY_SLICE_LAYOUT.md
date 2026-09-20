# Parity Slice Layout Brief

**Project:** Momentum: Fractured / Kaze
**Slice:** Silent District — Fire Return Loop
**Target viewport:** 1280×720
**Canonical feel/presentation benchmark:** Rush Line web build
**Related requirements:** `GDD.md`, `docs/GAMEPLAY_PARITY_MATRIX.md`

## Slice Goal

Build one authored five-room loop that proves the Godot version can deliver the web benchmark's movement, room density, verticality, subterranean transition, navigable water, map clarity, and ability-gated backtracking.

This slice replaces generated-room thinking with explicit geometry, spawn markers, encounter markers, and reciprocal transitions. It is deliberately small enough to tune thoroughly before its patterns are reused elsewhere.

The loop is:

1. **Compact Surface Approach**
2. **Wind Relay Shaft**
3. **Underground Threshold**
4. **Canal Chamber**
5. **Fire-Sealed Return**
6. Shortcut back to the upper-left landmark in **Compact Surface Approach**

The player may always retreat from the Fire-Sealed Return to the Canal Chamber and backtrack through the long route. Opening the Fire seal creates a shorter optional return path; it must never be the only way to escape the water route.

## Coordinate and Camera Conventions

- World origin is the upper-left of each room.
- Positive X points right; positive Y points down.
- All geometry in this brief uses **center position + size**, matching the existing `StaticBody2D` rectangle convention.
- Standard player body is approximately 24×64. Place standing spawn markers 34 pixels above a platform's top surface.
- Standard door trigger size is 54×160 unless a room-specific size is listed.
- Use `RoomCamera.room_bounds` equal to the authored room bounds.
- Camera zoom remains `(1, 1)`. The viewport remains 1280×720; rooms may extend beyond one viewport.
- Camera transitions must not reveal space outside the room bounds.
- Every transition uses an explicit directional marker. Do not target `spawn_default` for inter-room travel.

Recommended marker vocabulary:

- `entry_left`
- `entry_right`
- `entry_upper`
- `entry_lower`
- `entry_surface`
- `entry_shortcut`
- `spawn_checkpoint`

## Authoritative Room Graph

This graph must drive both door transitions and map rendering. Do not maintain a separate hand-written map edge list.

| Room ID | Display name | Map cell | Runtime bounds | Required state |
|---|---|---:|---:|---|
| `slice_01_surface` | Compact Surface Approach | `(0, 0)` | `Rect2(0, 0, 1920, 720)` | None |
| `slice_02_shaft` | Wind Relay Shaft | `(1, 0)` with vertical span through `(1, 2)` | `Rect2(0, 0, 1280, 2160)` | None; relay activation occurs inside room |
| `slice_03_threshold` | Underground Threshold | `(1, 3)` | `Rect2(0, 0, 1600, 900)` | Wind relay activated |
| `slice_04_canal` | Canal Chamber | `(2, 3)` | `Rect2(0, 0, 1920, 1080)` | None after threshold |
| `slice_05_fire_return` | Fire-Sealed Return | `(0, 2)` | `Rect2(0, 0, 1280, 1080)` | Fire Kunai opens shortcut branch |

### Graph edges and transition markers

| Edge ID | From door → target marker | Reverse door → target marker | Map visibility |
|---|---|---|---|
| `surface_shaft` | Surface `exit_right` → Shaft `entry_surface` | Shaft `exit_surface` → Surface `entry_right` | Reveal after either room is visited |
| `shaft_threshold` | Shaft `exit_lower` → Threshold `entry_upper` | Threshold `exit_upper` → Shaft `entry_lower` | Reveal after relay activation and first traversal |
| `threshold_canal` | Threshold `exit_right` → Canal `entry_left` | Canal `exit_left` → Threshold `entry_right` | Reveal after either room is visited |
| `canal_return` | Canal `exit_lower_right` → Fire Return `entry_water` | Fire Return `exit_water` → Canal `entry_lower_right` | Reveal after either room is visited |
| `fire_surface_shortcut` | Fire Return `exit_shortcut` → Surface `entry_shortcut` | No normal reverse trigger from Surface | Show as discovered locked edge when seal is seen; show open edge after seal opens |

The shortcut's surface-side arrival is a one-way drop into the beginning of the surface route. This prevents the player from entering the shortcut early while still making its destination visible as an environmental landmark.

## Shared Gameplay Markers

Each room scene should contain these named containers even when one is empty:

```text
SpawnPoints/
Doors/
Platforms/
GrappleAnchors/
EnemySpawns/
Checkpoints/
Gates/
Recovery/
Landmarks/
```

Every enemy spawn marker must specify:

- Enemy archetype
- Facing direction
- Activation group
- Patrol or permitted movement bounds
- Whether falling off its platform is allowed

Every grapple anchor must specify:

- Stable anchor ID
- Maximum intended attach distance
- Whether it is required, optional, or recovery-only
- Line-of-sight test origin/clearance

## Room 1 — Compact Surface Approach

### Gameplay sentence

Move through a tight neon service lane, use two elevations to control a compact encounter, and notice the inaccessible shortcut landmark above the entrance.

### Bounds and camera

- Room bounds: `Rect2(0, 0, 1920, 720)`
- Camera bounds: same as room bounds
- Camera starts centered at `(640, 360)` and scrolls horizontally only.
- Vertical camera movement is locked because room height equals the viewport.

### Entrances and exits

| Marker/door | Position | Elevation/use |
|---|---:|---|
| `entry_left` | `(96, 636)` | New-game/default approach from the left |
| `entry_right` | `(1775, 586)` | Arrival from Wind Relay Shaft |
| `entry_shortcut` | `(238, 250)` | One-way arrival from Fire-Sealed Return |
| `exit_right` | `(1878, 552)` | To Shaft `entry_surface`; trigger size 54×210 |
| `shortcut_drop` | `(238, 310)` | One-way platform/drop, not an outbound door |

### Collision platforms

| ID | Center | Size | Purpose |
|---|---:|---:|---|
| `floor_west` | `(300, 700)` | `(600, 40)` | Entry corridor floor |
| `floor_arena` | `(920, 700)` | `(560, 40)` | Main encounter floor |
| `floor_east` | `(1580, 700)` | `(680, 40)` | Exit approach |
| `awning_west` | `(410, 510)` | `(250, 24)` | Early upper lane/recovery |
| `balcony_mid` | `(800, 440)` | `(280, 26)` | High combat lane |
| `sign_bridge` | `(1160, 360)` | `(230, 22)` | Drone pressure/perch line |
| `exit_landing` | `(1640, 560)` | `(360, 28)` | Raised path to shaft exit |
| `shortcut_balcony` | `(238, 300)` | `(250, 24)` | Visible return landmark; one-way drop surface |
| `low_ceiling_west` | `(310, 350)` | `(420, 28)` | Makes entry corridor intimate |
| `arena_canopy` | `(980, 185)` | `(620, 28)` | Frames arena; not traversable from below without intended route |

World boundaries:

- Left wall: center `(10, 360)`, size `(20, 720)`
- Right wall: center `(1910, 360)`, size `(20, 720)`
- Ceiling: center `(960, 10)`, size `(1920, 20)`

### Grapple anchors

| Anchor ID | Position | Role |
|---|---:|---|
| `surface_anchor_01` | `(650, 285)` | Optional traversal into balcony lane |
| `surface_anchor_02` | `(1060, 245)` | Carries momentum across arena |
| `surface_anchor_03` | `(1450, 330)` | Required approach to raised exit landing |

All anchor-to-route distances must remain at or below the approved tether range. The shortcut balcony must not be reachable from these anchors before the shortcut is opened.

### Encounter composition

Activation volume: `Rect2(540, 250, 920, 440)`.

| Spawn ID | Position | Enemy | Rules |
|---|---:|---|---|
| `surface_echo_low` | `(680, 636)` | Echo | Patrol bounds X 590–850; remains on arena floor |
| `surface_drone_high` | `(1010, 300)` | Drone | Hover bounds X 880–1160, Y 260–360 |
| `surface_echo_east` | `(1370, 636)` | Echo | Patrol bounds X 1260–1500; pressures exit landing approach |

Doors lock only while the encounter is active. The player can use the low and high lanes; enemies must not collapse into one floor cluster.

### Recovery and anti-bypass

- Falling from an upper platform returns the player to a valid floor, not a death plane.
- The west awning and exit landing are recovery surfaces for missed tether releases.
- `shortcut_balcony` uses a one-way drop or one-sided collision arrangement that allows arrival from `entry_shortcut` but prevents early upward entry.
- A blocker behind the shortcut landmark remains active until `gate_fire_return` is open.

### Room acceptance tests

- The entry corridor feels enclosed before opening into the arena.
- All three enemies remain in their authored lanes for a full encounter.
- Kaze can move between low and high combat lanes without leaving the encounter bounds.
- The raised shaft exit is readable and reachable using intended movement.
- The shortcut balcony is visible before unlock but cannot be reached or entered early by jump, wall jump, dash, or tether.
- Returning through the shortcut places Kaze safely on the balcony and the one-way drop returns them to the main route.
- The camera never shows outside the 1920×720 room.

## Room 2 — Wind Relay Shaft

### Gameplay sentence

Enter at mid-height, climb an authored tether route to activate the relay, then descend a safer alternate lane to the underground hatch.

### Bounds and camera

- Room bounds: `Rect2(0, 0, 1280, 2160)`
- Camera bounds: same as room bounds
- Viewport remains 1280×720.
- Camera follows vertically and is horizontally centered at X 640.
- Recommended camera dead zone: 140 pixels vertically and 100 pixels horizontally.
- Entry camera target begins near `(640, 1440)`.

### Entrances, internal gate, and exits

| Marker/door | Position | Elevation/use |
|---|---:|---|
| `entry_surface` | `(112, 1476)` | Arrival from Surface right exit |
| `exit_surface` | `(32, 1430)` | Return to Surface `entry_right`; trigger size 54×190 |
| `relay_console` | `(1030, 150)` | Top objective; sets `wind_relay_active` |
| `lower_hatch` | `(640, 2050)` | Closed until relay is activated |
| `entry_lower` | `(640, 2046)` | Arrival from Underground Threshold |
| `exit_lower` | `(640, 2118)` | To Threshold `entry_upper`; horizontal trigger 180×54 |

Relay state must persist across room changes and save/load. Once opened, the lower hatch remains open.

### Collision platforms — ascent lane

| ID | Center | Size | Purpose |
|---|---:|---:|---|
| `entry_ledge` | `(210, 1520)` | `(360, 28)` | Surface entry and return door |
| `ascent_01` | `(430, 1345)` | `(230, 24)` | First jump/tether setup |
| `ascent_02` | `(760, 1165)` | `(220, 24)` | Swing landing |
| `ascent_03` | `(1030, 985)` | `(210, 24)` | Right-side recovery |
| `ascent_04` | `(770, 805)` | `(220, 24)` | Reversal platform |
| `ascent_05` | `(440, 625)` | `(220, 24)` | Left recovery platform |
| `ascent_06` | `(720, 445)` | `(230, 24)` | Final setup |
| `relay_ledge` | `(1010, 245)` | `(300, 28)` | Relay objective landing |

### Collision platforms — descent/recovery lane

| ID | Center | Size | Purpose |
|---|---:|---:|---|
| `descent_01` | `(1120, 470)` | `(180, 22)` | Controlled fall checkpoint |
| `descent_02` | `(980, 700)` | `(180, 22)` | Controlled fall checkpoint |
| `descent_03` | `(1110, 930)` | `(180, 22)` | Controlled fall checkpoint |
| `descent_04` | `(930, 1210)` | `(200, 22)` | Returns toward entry elevation |
| `descent_05` | `(760, 1480)` | `(230, 24)` | Branch below entry |
| `descent_06` | `(540, 1720)` | `(230, 24)` | Lower-shaft recovery |
| `descent_07` | `(700, 1920)` | `(300, 26)` | Hatch approach |
| `bottom_floor` | `(640, 2140)` | `(1280, 40)` | Lower boundary/hatch frame |

World boundaries:

- Left wall: center `(10, 1080)`, size `(20, 2160)`
- Right wall: center `(1270, 1080)`, size `(20, 2160)`
- Ceiling: center `(640, 10)`, size `(1280, 20)`

### Grapple anchors

| Anchor ID | Position | Role |
|---|---:|---|
| `shaft_anchor_01` | `(335, 1260)` | Required first lift |
| `shaft_anchor_02` | `(650, 1080)` | Required crossing |
| `shaft_anchor_03` | `(930, 900)` | Required right-side catch |
| `shaft_anchor_04` | `(745, 720)` | Required reversal |
| `shaft_anchor_05` | `(485, 540)` | Required left-side lift |
| `shaft_anchor_06` | `(700, 360)` | Required final swing |
| `shaft_anchor_07` | `(970, 165)` | Relay approach |
| `shaft_recovery_01` | `(1030, 590)` | Optional descent correction |
| `shaft_recovery_02` | `(870, 1340)` | Optional missed-release recovery |
| `shaft_recovery_03` | `(620, 1810)` | Optional lower-shaft recovery |

Required anchors must have unobstructed line-of-sight from their setup platforms. Recovery anchors should never outscore the intended required anchor when the cursor is aimed at the required route.

### Encounter composition

First implementation:

| Spawn ID | Position | Enemy | Activation |
|---|---:|---|---|
| `shaft_drone_mid` | `(890, 1030)` | Drone | Activates after landing on `ascent_02` |

Approved escalation after movement tuning:

| Spawn ID | Position | Enemy | Activation |
|---|---:|---|---|
| `shaft_drone_high` | `(560, 500)` | Drone | Activates after `ascent_05`; omit until the route is proven readable |

No ground enemy should be placed on the narrow ascent ledges.

### Recovery and failure rules

- Missing an ascent anchor should normally land Kaze on the prior ledge or a recovery ledge.
- The only full reset volume sits below the bottom boundary and respawns Kaze at the most recent safe shaft marker.
- Safe shaft markers: `recover_entry`, `recover_mid`, `recover_high`, `recover_lower` at Y 1476, 1030, 500, and 1900.
- Activating the relay creates a visible wind pulse down the shaft and opens the lower hatch.
- The descent route must not require the same precision as the climb; it is a spatial payoff and transition underground.

### Room acceptance tests

- The complete climb is possible without enemies and without exceeding the approved tether range.
- Each required anchor is selected when aimed at, with no through-wall attachment or competing recovery-anchor snap.
- A missed release has a readable recovery outcome rather than an unexplained death.
- One Drone adds timing pressure without obscuring the next anchor.
- The camera follows across at least three viewport heights without exposing outside geometry or losing Kaze.
- Relay activation is clearly communicated, opens the lower hatch, updates the map, and persists after leaving/reloading.
- The descent lane is visually distinct from the ascent lane.
- Surface and lower exits return to the correct corresponding markers.

## Room 3 — Underground Threshold

### Gameplay sentence

Descend through a compressed maintenance passage, clear a short encounter, then reach a safe reliquary where Fire Kunai and the underground checkpoint are established.

### Bounds and camera

- Room bounds: `Rect2(0, 0, 1600, 900)`
- Camera bounds: same as room bounds
- Camera scrolls horizontally and up to 180 pixels vertically.
- Entrance begins near the upper-left; route descends toward the lower-right.

### Entrances and exits

| Marker/door | Position | Elevation/use |
|---|---:|---|
| `entry_upper` | `(170, 126)` | Arrival from Shaft lower hatch |
| `exit_upper` | `(170, 64)` | Return to Shaft `entry_lower`; horizontal trigger 180×54 |
| `spawn_checkpoint` | `(1120, 746)` | Authored checkpoint/reliquary spawn |
| `entry_right` | `(1465, 746)` | Arrival from Canal Chamber |
| `exit_right` | `(1568, 700)` | To Canal `entry_left`; trigger size 54×210 |

### Collision platforms

| ID | Center | Size | Purpose |
|---|---:|---:|---|
| `upper_entry` | `(190, 185)` | `(300, 26)` | Shaft arrival landing |
| `step_01` | `(420, 320)` | `(230, 24)` | Descending maintenance ledge |
| `step_02` | `(670, 455)` | `(220, 24)` | Encounter high lane |
| `lower_corridor` | `(620, 820)` | `(920, 40)` | Encounter and descent floor |
| `reliquary_floor` | `(1180, 820)` | `(360, 40)` | Safe checkpoint zone |
| `canal_approach` | `(1460, 820)` | `(280, 40)` | Exit approach |
| `low_ceiling` | `(600, 585)` | `(720, 30)` | Compresses the encounter corridor |
| `reliquary_arch` | `(1180, 560)` | `(360, 30)` | Frames reward space without blocking view |

World boundaries:

- Left wall: center `(10, 450)`, size `(20, 900)`
- Right wall: center `(1590, 450)`, size `(20, 900)`
- Ceiling: center `(800, 10)`, size `(1600, 20)`

### Grapple anchors

| Anchor ID | Position | Role |
|---|---:|---|
| `threshold_anchor_01` | `(350, 175)` | Return route to upper exit |
| `threshold_anchor_02` | `(590, 310)` | Supports controlled descent/reversal |
| `threshold_anchor_03` | `(830, 430)` | Optional combat mobility |

### Encounter and reward composition

Encounter activation volume: `Rect2(340, 360, 610, 440)`.

| Spawn ID | Position | Enemy | Rules |
|---|---:|---|---|
| `threshold_echo_01` | `(500, 756)` | Echo | Patrol X 400–620 |
| `threshold_echo_02` | `(800, 756)` | Echo | Patrol X 700–910 |
| `threshold_drone_01` | `(720, 390)` | Drone | Hover X 610–840, Y 350–450 |

After encounter clear:

- Open the reliquary barrier.
- Present Fire Kunai inside an authored world object.
- Unlock `fire_kunai` only when the player claims the reward.
- Activate the checkpoint only through the checkpoint/reliquary interaction.
- Show the newly available Fire slot in the loadout panel.

### Recovery and spatial communication

- A safe drop route from `upper_entry` leads toward `step_01`; falling past a ledge lands in the lower corridor.
- The room's palette, materials, ambience, and reverb transition from surface architecture to damp infrastructure.
- A canal sound and reflected cyan light should pull the player right after the reliquary.
- The shaft entrance remains visually identifiable behind the player.

### Room acceptance tests

- Arrival from the shaft clearly reads as a descent underground.
- The encounter occupies both floor and upper lane without enemies escaping their authored bounds.
- The low ceiling makes the encounter intimate without causing camera or collision frustration.
- Fire Kunai is granted only through the reliquary interaction and persists after save/load.
- The checkpoint is visible, interactive, and communicates successful activation.
- Death after activation respawns at `spawn_checkpoint` with correct health/state.
- Both shaft and canal transitions use the corresponding directional markers.

## Room 4 — Canal Chamber

### Gameplay sentence

Enter from a dry maintenance ledge, descend into deep traversable water, navigate submerged ruins and a water-specific threat, then surface at the return-route intake.

### Bounds and camera

- Room bounds: `Rect2(0, 0, 1920, 1080)`
- Camera bounds: same as room bounds
- Water surface: Y `430`
- Water bottom: Y `1040`
- Camera follows horizontally and vertically, including underwater.
- Apply a gradual underwater visual/audio treatment based on camera/player depth; do not snap the entire room tint on a single frame.

### Entrances and exits

| Marker/door | Position | Elevation/use |
|---|---:|---|
| `entry_left` | `(105, 336)` | Arrival from Underground Threshold |
| `exit_left` | `(32, 300)` | Return to Threshold `entry_right`; trigger size 54×210 |
| `entry_lower_right` | `(1770, 866)` | Arrival from Fire-Sealed Return |
| `exit_lower_right` | `(1888, 820)` | To Fire Return `entry_water`; trigger size 54×230 |

### Collision platforms and ruins

| ID | Center | Size | Purpose |
|---|---:|---:|---|
| `left_dry_ledge` | `(220, 400)` | `(440, 30)` | Entry shore and dry footing |
| `surface_ruin` | `(650, 500)` | `(260, 24)` | Near-surface reference/recovery |
| `mid_ruin_01` | `(920, 660)` | `(230, 24)` | Underwater navigation landmark |
| `mid_ruin_02` | `(1260, 570)` | `(260, 24)` | Underwater/surface route split |
| `deep_ruin` | `(1080, 900)` | `(300, 26)` | Deep-route landmark |
| `right_intake_ledge` | `(1680, 900)` | `(420, 32)` | Exit intake and surfacing point |
| `bottom_west` | `(420, 1050)` | `(840, 40)` | Water floor |
| `bottom_east` | `(1420, 1050)` | `(1000, 40)` | Water floor |
| `overhang_west` | `(650, 230)` | `(520, 30)` | Frames entry and prevents empty upper space |
| `intake_arch` | `(1650, 510)` | `(360, 30)` | Frames return-route destination |

World boundaries:

- Left wall: center `(10, 540)`, size `(20, 1080)`
- Right wall: center `(1910, 540)`, size `(20, 1080)`
- Ceiling: center `(960, 10)`, size `(1920, 20)`

### Water volume

- Primary water volume: center `(960, 735)`, size `(1880, 610)`
- Water surface band: Y 420–445 for splash/transition handling
- No death plane exists beneath navigable water.
- A recovery volume below Y 1075 returns Kaze to the nearest dry or submerged recovery marker only if they escape collision bounds.
- Required controls: ascend/stroke, descend, horizontal swim, neutral buoyancy/drag, controlled surface exit.

### Grapple anchors

| Anchor ID | Position | Role |
|---|---:|---|
| `canal_anchor_dry` | `(480, 255)` | Optional dry entry movement |
| `canal_anchor_surface` | `(1420, 315)` | Surface route/recovery |

Default slice rule: tether cannot attach while Kaze is fully submerged. It may attach from the surface band to an above-water anchor. If this rule changes, update the GDD and acceptance tests before implementation.

### Encounter and hazard composition

Initial authored composition:

| Spawn ID | Position | Type | Rules |
|---|---:|---|---|
| `canal_drone_surface` | `(690, 330)` | Drone | Pressures the first water entry; hover X 560–820 |
| `canal_mine_01` | `(1040, 735)` | Stationary electric mine/hazard | Pulses with a readable safe interval |
| `canal_mine_02` | `(1450, 690)` | Stationary electric mine/hazard | Guards the upper intake route; does not block the deep alternate route |

If electric mines are not ready, use clearly telegraphed timed current jets in the same positions. Do not substitute instant-kill water.

### Recovery and route choices

- Main route: enter water near X 500, pass `mid_ruin_01`, choose above or below `mid_ruin_02`, then surface at `right_intake_ledge`.
- Deep route: descend around `deep_ruin` for an optional cell cache/lore pickup before approaching the intake from below.
- Surface recovery ledges exist at X 220, 650, 1260, and 1680.
- Current/hazard knockback must not pin the player against room boundaries.

### Room acceptance tests

- Kaze can enter slowly, fall in, dash in, and exit without state flicker.
- Ascend, descend, neutral hold, and horizontal swim are controllable and distinct from air movement.
- Surface transitions do not cause double jumps, repeated swim impulses, or camera snapping.
- The dry, surface, mid-water, and deep routes remain visually readable.
- The player can recover from hazards without being chain-hit or trapped.
- The water route reaches the correct return-room entrance, and backtracking returns to `entry_lower_right`.
- No navigable water overlaps an instant-death zone.

## Room 5 — Fire-Sealed Return

### Gameplay sentence

Climb from the canal intake to a visible Fire seal, open a persistent shortcut, and emerge above the starting lane to complete the world loop.

### Bounds and camera

- Room bounds: `Rect2(0, 0, 1280, 1080)`
- Camera bounds: same as room bounds
- Camera follows vertically through approximately one and a half viewport heights.
- The shortcut door and seal should be visible from the first major landing.

### Entrances and exits

| Marker/door | Position | Elevation/use |
|---|---:|---|
| `entry_water` | `(1160, 936)` | Arrival from Canal Chamber |
| `exit_water` | `(1248, 900)` | Always-open return to Canal `entry_lower_right`; trigger size 54×230 |
| `fire_seal` | `(430, 455)` | Persistent elemental gate on shortcut branch |
| `exit_shortcut` | `(32, 170)` | To Surface `entry_shortcut`; trigger size 54×190 |

The water exit remains available regardless of seal state. The Fire seal controls only the shortcut branch.

### Collision platforms

| ID | Center | Size | Purpose |
|---|---:|---:|---|
| `intake_floor` | `(1030, 1020)` | `(500, 40)` | Canal arrival and retreat route |
| `climb_01` | `(930, 845)` | `(240, 24)` | First dry landing |
| `climb_02` | `(700, 690)` | `(220, 24)` | Route toward seal overlook |
| `seal_overlook` | `(520, 545)` | `(300, 26)` | Presents seal and shortcut destination |
| `gate_floor_east` | `(570, 780)` | `(500, 34)` | Approach side of gate |
| `gate_floor_west` | `(250, 780)` | `(260, 34)` | Reward side of gate |
| `shortcut_step` | `(250, 560)` | `(220, 24)` | Post-gate ascent |
| `shortcut_landing` | `(160, 260)` | `(300, 28)` | Final return door landing |
| `ceiling_frame` | `(640, 10)` | `(1280, 20)` | Boundary |
| `bottom_floor` | `(640, 1060)` | `(1280, 40)` | Boundary |

World boundaries:

- Left wall: center `(10, 540)`, size `(20, 1080)`
- Right wall: center `(1270, 540)`, size `(20, 1080)`

### Grapple anchors

| Anchor ID | Position | Role |
|---|---:|---|
| `return_anchor_01` | `(940, 690)` | Intake climb |
| `return_anchor_02` | `(690, 530)` | Seal approach |
| `return_anchor_03` | `(270, 390)` | Post-gate shortcut climb; disabled/unreachable until gate opens |

### Fire gate specification

- Gate ID: `gate_fire_return`
- Required element: `fire`
- Gate center: `(430, 650)`
- Blocking collision size: `(42, 260)`
- Detection/hit Area must cover the full visual seal.
- Gate collision must connect floor and overhead architecture so it cannot be jumped, dashed, wall-jumped, or tethered around.
- `return_anchor_03` must not create a pre-unlock bypass.
- Wrong element response: distinct deflection flash, short sound, and readable Fire icon pulse.
- Correct response: Fire impact, seal fracture animation, blocker disable, map update, and persistent `opened_gates[gate_fire_return] = true` state.
- On reload or room re-entry, an opened gate begins open and does not replay the full unlock sequence.

### Encounter composition

The room is primarily a traversal reward. Keep combat short.

| Spawn ID | Position | Enemy | Rules |
|---|---:|---|---|
| `return_echo_guard` | `(760, 956)` | Echo | Patrol X 670–870; first-visit only |
| `return_drone_guard` | `(570, 610)` | Drone | Activates near `climb_02`; omit if it obscures seal readability |

The gate can be opened during or after combat, but enemy pressure must not hide the elemental lesson. Once the encounter is cleared, its cleared state persists.

### Recovery and anti-bypass

- Falling during the climb returns Kaze to `intake_floor` or `gate_floor_east`.
- The Fire seal occupies the entire shortcut passage cross-section.
- The left shortcut route has no alternate anchor or wall-jump seam around the blocker.
- The player can always return through `exit_water` if Fire is unavailable or if they choose not to open the seal.

### Room acceptance tests

- The Fire seal and shortcut destination are visible before the player reaches the gate.
- Wind and Electric impacts produce clear wrong-element feedback without opening the gate.
- Fire opens the gate exactly once and updates the map immediately.
- Gate state persists across room transitions, death, checkpoint reload, and full save/load.
- The gate cannot be bypassed with every available movement combination.
- The canal return remains available before and after gate opening.
- The shortcut door arrives at Surface `entry_shortcut`, not the surface default spawn.
- Completing the shortcut materially reduces return travel time.

## Spatial and Visual Continuity

### Surface → Shaft

- Carry the surface district's indigo/violet shadows and cyan wind language into the shaft.
- The shaft entrance should visibly belong to the raised east-side infrastructure in the Surface Approach.
- Wind particles and anchor motifs increase toward the relay.

### Shaft → Underground

- Relay activation sends a visible pulse downward and opens the bottom hatch.
- During descent, surface neon gives way to utility lighting, damp masonry, roots, and reflected water light.
- The Underground Threshold entrance should visually echo the shaft hatch shape.

### Underground → Water

- Canal sound, mist, cyan reflections, and damp surfaces begin before the water becomes visible.
- The Threshold's right exit elevation aligns with the Canal's dry left ledge.
- Water is introduced as navigable space, never as the same visual language used for death pits.

### Water → Fire Return → Surface

- The return intake uses warmer emergency lighting that foreshadows Fire.
- The Fire seal is a clear authored landmark, not an unframed colored rectangle.
- The final shortcut door uses architecture visible from the Surface Approach's upper-left balcony, closing the spatial loop.

## Map Presentation

The map should render the following arrangement:

```text
Surface Approach ── Wind Relay Shaft
      ▲                    │
      │                    │
Fire Return                │
      ▲                    │
      └── Canal Chamber ── Underground Threshold
```

This diagram describes topology, not literal door direction. The shaft occupies multiple vertical cells; its map shape should communicate height.

Required map states:

- **Unvisited:** hidden unless revealed by an approved map upgrade.
- **Visited:** room shape visible.
- **Current:** high-contrast cyan highlight.
- **Discovered locked Fire shortcut:** dashed warm-red/orange edge with Fire icon.
- **Opened Fire shortcut:** solid warm edge.
- **Relay inactive/active:** icon state on the shaft.
- **Checkpoint:** icon on Underground Threshold after activation.
- **Water:** blue/cyan fill treatment on Canal Chamber.

Map topology and scene transitions must be generated from the same room/door metadata. Automated validation should reject an edge without a valid reciprocal target unless explicitly marked `one_way`, as with the surface shortcut drop.

## Slice-Wide Acceptance Tests

### P0 — Required before external playtest

- Every standard edge works in both directions and lands at the corresponding directional spawn marker.
- The one-way shortcut is explicitly identified as one-way and cannot be entered early from Surface.
- Runtime transitions and map edges match exactly.
- Dash preserves the approved amount of incoming momentum.
- Tether selection respects range, aim tolerance, and line-of-sight.
- Tether constraint does not clip Kaze through platforms, walls, or ceilings.
- Player and enemy strikes register once per intended active window.
- The relay, checkpoint, Fire unlock, encounter clears, and Fire gate persist correctly.
- The player can complete the long route and safely backtrack even without opening the Fire shortcut.
- No required route depends on an undocumented exploit.

### P1 — Required for parity-slice approval

- Surface, shaft, underground, water, and return spaces are visually and spatially distinct but coherent.
- Each room has a clear gameplay purpose and no large unused volume.
- The shaft uses multiple screen heights with readable recovery routes.
- Water supports descent, ascent, neutral control, surfacing, and controlled exits.
- Encounters occupy authored lanes and support each room's traversal idea.
- Fire gate feedback and map state are immediately understandable.
- Loadout UI reflects Fire unlock and equipped kunai accurately.
- Audio and VFX communicate environment and state changes without masking hazards.

### P2 — Required before propagating the room kit

- Automated graph, spawn-marker, state-persistence, and gate-bypass tests pass.
- Matched web/Godot capture review approves movement, dash, tether, combat, and environmental pacing.
- Performance remains at the target frame rate through the full shaft and water room.
- The creative director approves density, navigation, game feel, atmosphere, and shortcut payoff.
- Reusable room metadata, anchor, gate, checkpoint, and encounter patterns are documented for the next biome.

## Implementation Order

1. Define authoritative room/door metadata and directional spawn validation.
2. Greybox Surface Approach and Wind Relay Shaft without enemies.
3. Fix dash and tether behavior against the greybox.
4. Greybox Underground Threshold, Canal Chamber, and Fire-Sealed Return.
5. Implement relay, checkpoint, Fire reliquary, persistent gate, and map states.
6. Complete water movement before adding water hazards.
7. Add authored encounter markers and validate combat/hitboxes.
8. Apply environment art, lighting, VFX, audio, landmarks, and UI treatment.
9. Run the full manual acceptance pass and matched web/Godot capture review.
10. Package a Windows playtest build only after all P0 criteria pass.
