# LD-05 room-by-room audit (21 rooms)

Base candidate 49ae3efe. Data: `docs/ld05/room_audit.json`, probes `tools/ld05/room_probe.gd` and `tools/ld05/gate_probe.gd`, builder `tools/ld05/build_audit.py`. All movement probes use real InputEventKey input and real physics (no position or velocity writes except the fixture start pose); `player.gd` is untouched.

Classes: **legit** legitimate vertical exploration (keep), **escape** unintended escape (fix), **misleading** misleading platform, **dead** dead reachable space, **approach** unsupported approach.

Totals: wall-chain and face probes before 91 (68 escaped), after 91 (0 escaped); double jump + dash probes escaped before 4, after 0. 122 findings.

Method limits: one scripted bot per probe, not exhaustive jump-arc proof. Ledge height classes come from a static kinematic model (labelled in the finding), not from play. No human playtest.

## R0 CANAL HAVEN (2600x1440)

Intended route: Spawn at the Haven shrine (220,1300). East walk-through (2440,1300) to R1. Depth door (590,780) to R13 (needs Windstep).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 2 / 2 / -108, then 2 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-001 | escape | left wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-002 | escape | right wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-003 | legit | 2 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[860.0, 780.0, 420.0, 48.0], [260.0, 780.0, 390.0, 48.0]]. Ability gating by height; kept. | kept |
| LD05-004 | dead | Wall column between the highest ledge (y 780) and the roof underside (feet y 116) is 664 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-005 | dead | 1 wall-side walk-through exit(s) leave 98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R1 LANTERN MARKET (2600x1440)

Intended route: West door back to R0. Windstep pickup (1580,1300) after the market guard. East walk-through (2440,1300) to R2 (needs Windstep).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 3 / 3 / -158, then 3 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-006 | escape | left wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-007 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -158, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-008 | dead | Wall column between the highest ledge (y 720) and the roof underside (feet y 116) is 604 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-009 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R2 FLOODED CISTERN (2600x1440)

Intended route: West door to R1. Pit-and-ledge ascent east. Wind kunai gate (2150,850) opens the cistern cache. East walk-through (2440,850) to R3. Depth door (470,1120) to R15 (needs the cache and Wind kunai).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 3 / 2 / -151, then 3 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-010 | escape | left wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-011 | escape | right wall: chained wall jumps from ledge leave the world (feet y -151, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-012 | legit | 3 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[1510.0, 870.0, 300.0, 40.0], [1980.0, 1050.0, 250.0, 40.0], [2220.0, 850.0, 380.0, 40.0]]. Ability gating by height; kept. | kept |
| LD05-013 | dead | Wall column between the highest ledge (y 850) and the roof underside (feet y 116) is 734 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-014 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-015 | legit | Water pits between floor segments are the room's hazard (fall recovery returns Kaze, costs 1 hp). Intended. | kept |
| LD05-016 | legit | Gate cistern_wind_cache (250x30 body at [2150.0, 850.0]) floats over a gap with no ledge at its base: the wall-jump bypass probe could not be started supported and is not evaluated. | kept, not evaluated |

## R3 ECHO SHRINE (2600x1440)

Intended route: West door (120,850) to R2. Wind Tether pickup (1320,1300). East walk-through (2440,1300) to R4 (needs Tether). Depth door (2250,790) to R9 return seal.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 3 / 2 / -151, then 3 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-017 | escape | left wall: chained wall jumps from ledge leave the world (feet y -151, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-018 | escape | right wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-019 | legit | 5 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[0.0, 850.0, 300.0, 40.0], [420.0, 1060.0, 330.0, 40.0], [920.0, 830.0, 360.0, 40.0]]. Ability gating by height; kept. | kept |
| LD05-020 | dead | Wall column between the highest ledge (y 790) and the roof underside (feet y 116) is 674 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-021 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R4 BROKEN SPAN (2600x1440)

Intended route: West door to R3. Fire kunai (1080,980). Span fire cache gate (1990,1080). East walk-through (2440,1080) to R5.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 3 / 2 / -129, then 3 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-022 | escape | left wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-023 | escape | right wall: chained wall jumps from ledge leave the world (feet y -129, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-024 | dead | Wall column between the highest ledge (y 890) and the roof underside (feet y 116) is 774 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-025 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-026 | legit | Water pits between floor segments are the room's hazard (fall recovery returns Kaze, costs 1 hp). Intended. | kept |
| LD05-027 | legit | Gate span_fire_cache (270x30 body at [1990.0, 1080.0]) floats over a gap with no ledge at its base: the wall-jump bypass probe could not be started supported and is not evaluated. | kept, not evaluated |

## R5 ASCENT TOWER (2600x1440)

Intended route: West door (120,1080). Gale Dash (1320,1300), Electric kunai (1510,930). East walk-through (2440,1300) to R6 (needs Dash). Depth door (2240,930) to R17 (needs Tether and Dash).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 2 / -129, then 4 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 2 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-028 | escape | left wall: chained wall jumps from ledge leave the world (feet y -129, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-029 | escape | right wall: chained wall jumps from ledge leave the world (feet y -121, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-030 | legit | Tether anchors: 0 of 2 scripted swings attach, best height feet y 505. Grapple never reaches the room top. | kept |
| LD05-031 | legit | 2 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[1760.0, 700.0, 280.0, 40.0], [2130.0, 930.0, 470.0, 40.0]]. Ability gating by height; kept. | kept |
| LD05-032 | dead | Wall column between the highest ledge (y 680) and the roof underside (feet y 116) is 564 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-033 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-034 | legit | Water pits between floor segments are the room's hazard (fall recovery returns Kaze, costs 1 hp). Intended. | kept |

## R6 TIDE WARDEN (2600x1440)

Intended route: Boss arena. East walk-through (2440,1090) to R7 (needs the Tide Warden defeated).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 3 / 2 / -108, then 3 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-035 | escape | left wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-036 | escape | right wall: chained wall jumps from ledge leave the world (feet y -99, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-037 | dead | Wall column between the highest ledge (y 1000) and the roof underside (feet y 116) is 884 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-038 | approach | Door to R7 at (2440,1090): walkable top is +20 px from the door feet (door drawn floating above its shelf). | fixed by door seating (LD05-F4); endpoint and trigger unchanged |
| LD05-039 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R7 RELAY ARCHIVE (2600x1440)

Intended route: Relay Archive: electric seal gate (2000,1300), control (2200,1190). East walk-through (2440,1300) to R8 (needs Archive restored).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 3 / 2 / -119, then 3 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 2 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-040 | escape | left wall: chained wall jumps from ledge leave the world (feet y -119, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-041 | escape | right wall: chained wall jumps from floor leave the world (feet y -108, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-042 | legit | Tether anchors: 0 of 2 scripted swings attach, best height feet y 455. Grapple never reaches the room top. | kept |
| LD05-043 | dead | Wall column between the highest ledge (y 650) and the roof underside (feet y 116) is 534 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-044 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-045 | legit | Gate relay_electric_seal (300x30 body at [2000.0, 1300.0]): held by wall jumps up its side (probe passed=False). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R8 RELAY UNDERCROFT (2600x1440)

Intended route: Undercroft shrine (2060,1300), sigil (1470,690). West to R7, east (2440,830) to R9. Depth doors to R16 (550,1110), R18 (1090,920), R12 return (1470,740).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 2 / -119, then 4 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 4 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-046 | escape | left wall: chained wall jumps from ledge leave the world (feet y -119, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-047 | escape | right wall: chained wall jumps from ledge leave the world (feet y -102, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-048 | legit | Tether anchors: 0 of 4 scripted swings attach, best height feet y 545. Grapple never reaches the room top. | kept |
| LD05-049 | dead | Wall column between the highest ledge (y 740) and the roof underside (feet y 116) is 624 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-050 | approach | Door to R18 at (1090,920): the shelf under it ends at x 1110; the drawn door spans x 1042..1138, so 28 px overhang empty space. | fixed by the 40 px shelf seat (LD05-F3) |
| LD05-051 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R9 SIGNAL TERRACE (2600x1440)

Intended route: Three relay sigils: west (1490,600), fire cache (2240,770, behind gate 2110,810). East walk-through (2440,830) to R10 (needs all sigils). Depth doors to R14 (1100,1040) and R3 return (160,620).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 5 / 3 / -163, then 5 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 6 swings, 2 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-052 | escape | left wall: chained wall jumps from ledge leave the world (feet y -163, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-053 | escape | right wall: chained wall jumps from ledge leave the world (feet y -122, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-054 | legit | Tether anchors: 2 of 6 scripted swings attach, best height feet y 445. Grapple never reaches the room top. | kept |
| LD05-055 | legit | 6 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[0.0, 830.0, 650.0, 40.0], [80.0, 620.0, 440.0, 40.0], [380.0, 1040.0, 800.0, 40.0]]. Ability gating by height; kept. | kept |
| LD05-056 | dead | Wall column between the highest ledge (y 620) and the roof underside (feet y 116) is 504 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-057 | approach | Door to R10 at (2440,830): walkable top is -20 px from the door feet (door drawn sunk into its shelf). | fixed by door seating (LD05-F4); endpoint and trigger unchanged |
| LD05-058 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-059 | legit | Gate terrace_fire_cache (280x30 body at [2110.0, 810.0]): bypassed by wall jumps up its side (probe passed=True). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R10 SKYWORKS APPROACH (2600x1440)

Intended route: Skyworks approach. Wind intake gate (2110,810) must be opened to enter R11. East walk-through (2440,760).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 2 / -160, then 4 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 8 swings, 8 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-060 | escape | left wall: chained wall jumps from ledge leave the world (feet y -102, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-061 | escape | right wall: chained wall jumps from ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-062 | legit | Tether anchors: 8 of 8 scripted swings attach, best height feet y 497. Grapple never reaches the room top. | kept |
| LD05-063 | legit | 6 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[0.0, 830.0, 300.0, 40.0], [350.0, 1040.0, 800.0, 40.0], [920.0, 830.0, 300.0, 40.0]]. Ability gating by height; kept. | kept |
| LD05-064 | dead | Wall column between the highest ledge (y 620) and the roof underside (feet y 116) is 504 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-065 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-066 | legit | Gate skyworks_wind_intake (280x30 body at [2110.0, 810.0]): bypassed by wall jumps up its side (probe passed=True). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R11 STORM FOUNDRY (2600x1440)

Intended route: Foundry refuge (1720,1300). Electric relay gate (2370,760) must be opened to enter R12. Depth door (890,980) to R19.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 2 / -160, then 4 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 6 swings, 2 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-067 | escape | left wall: chained wall jumps from ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-068 | escape | right wall: chained wall jumps from ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-069 | legit | Tether anchors: 2 of 6 scripted swings attach, best height feet y 365. Grapple never reaches the room top. | kept |
| LD05-070 | legit | 6 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[0.0, 760.0, 310.0, 40.0], [420.0, 980.0, 600.0, 40.0], [1100.0, 780.0, 380.0, 40.0]]. Ability gating by height; kept. | kept |
| LD05-071 | dead | Wall column between the highest ledge (y 560) and the roof underside (feet y 116) is 444 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-072 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-073 | legit | Gate foundry_electric_relay (300x30 body at [2370.0, 760.0]): bypassed by wall jumps up its side (probe passed=True). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R12 KEEPER RELAY (2600x1440)

Intended route: Storm Keeper arena (boss 1320,1300), relay (2220,1300). Depth door (220,830) back to R8 after the Keeper.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 3 / -159, then 4 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-074 | escape | left wall: chained wall jumps from ledge leave the world (feet y -102, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-075 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -159, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-076 | legit | 5 ledge(s) need the double jump (static model: rise above 225 px from every ordinary support): [[80.0, 830.0, 480.0, 40.0], [580.0, 1070.0, 320.0, 40.0], [1040.0, 850.0, 350.0, 40.0]]. Ability gating by height; kept. | kept |
| LD05-077 | dead | Wall column between the highest ledge (y 830) and the roof underside (feet y 116) is 714 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-078 | dead | 1 wall-side walk-through exit(s) leave 58 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R13 MOORING LOFT (1800x1440)

Intended route: Canal Haven door (120,1200) at the foot of the gatehouse hallway, stepped shelves climb right to the R14 walk-through (1680,560). Stride I (450,440), wind-fold door (900,400) to R20.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 11 / 4 / -165, then 11 / 0 / 116. Double jump + dash from near-top ledges: 6 probes, 2 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-079 | legit | left wall: owned by the Canal gatehouse mass and back pier (contract); chains inside the hallway hold at feet y 1018..1080 under the lintel. Unchanged. | kept (creator-approved Canal geometry) |
| LD05-080 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -144, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-081 | escape | Outer face of solid mass [0.0, 0.0, 296.0, 1020.0]: wall jumps from a ledge reach feet y -165 and leave the world. | fixed by the roof course (LD05-F1) |
| LD05-082 | escape | Jump + double jump (+ dash) from the ledge at (324,438) toward the left wall reaches feet y -15: above the top of the room, on the wall top. | fixed by the roof course (LD05-F1) |
| LD05-083 | dead | Wall column between the highest ledge (y 400) and the roof underside (feet y 116) is 284 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-084 | dead | 1 wall-side walk-through exit(s) leave 58 px of floor beyond the drawn door where Kaze can stand with the door behind. (R13 to R0 is already closed by the Canal back pier and is not counted.) | residual (creator decision, see report) |
| LD05-085 | misleading | Dashed grey truss lines (two 9 px strokes per bay) read as walkable ramps; now thin, dim and dashed. | fixed (LD05-F5), presentation only |
| LD05-086 | dead | 60 px crawlspace under the Canal hallway pad (x 0..360, y 1240..1300): Kaze could walk in from the quay floor and stand at the wall. | fixed by the plinth (LD05-F2) |

## R14 BELLROOF WALK (2600x1440)

Intended route: Bellroof Walk: west door (120,1100) from R13, long roof walk east to R9 walk-through (2440,830). Local stair (1450,480) up to R17.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 8 / 8 / -160, then 8 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-087 | escape | left wall: chained wall jumps from floor/ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-088 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -140, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-089 | dead | Wall column between the highest ledge (y 480) and the roof underside (feet y 116) is 364 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-090 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R15 LOWER SLUICE (2200x1440)

Intended route: Lower Sluice: from the R2 door (120,500) a dry descent east to the R16 walk-through (2080,1120). Optional wind gate (500,500).

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 4 / -161, then 4 / 0 / 116. Double jump + dash from near-top ledges: 2 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-091 | escape | left wall: chained wall jumps from floor/ledge leave the world (feet y -158, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-092 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -161, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-093 | dead | Wall column between the highest ledge (y 500) and the roof underside (feet y 116) is 384 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-094 | dead | 2 wall-side walk-through exit(s) leave 58 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-095 | misleading | Four full-width 12 px 'service rails' and 150 px arches read as ledges; now dim and dashed. | fixed (LD05-F5), presentation only |
| LD05-096 | legit | Gate lower_sluice_wind (240x30 body at [500.0, 500.0]): bypassed by wall jumps up its side (probe passed=True). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R16 ROOT SHRINE (2000x1440)

Intended route: Root Shrine (420,1120) save. West door R15, east (1880,760) to R8, depth door (1000,430) to R18.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 4 / -161, then 4 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-097 | escape | left wall: chained wall jumps from floor/ledge leave the world (feet y -161, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-098 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-099 | dead | Wall column between the highest ledge (y 430) and the roof underside (feet y 116) is 314 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-100 | dead | 2 wall-side walk-through exit(s) leave 58 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |

## R17 COUNTERWEIGHT SPIRE (1800x2160)

Intended route: Counterweight Spire: climb from the R5 door (120,1900) by landings to the top. Stair down (1680,1300) to R14, depth door (1500,420) to R20 behind the spire wind shutter.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 6 / 6 / -154, then 6 / 0 / 116. Double jump + dash from near-top ledges: 2 probes, 2 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-101 | escape | left wall: chained wall jumps from floor/ledge leave the world (feet y -104, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-102 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -154, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-103 | escape | Jump + double jump (+ dash) from the ledge at (1626,418) toward the right wall reaches feet y -35: above the top of the room, on the wall top. | fixed by the roof course (LD05-F1) |
| LD05-104 | dead | Wall column between the highest ledge (y 420) and the roof underside (feet y 116) is 304 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-105 | dead | 1 wall-side walk-through exit(s) leave 58 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-106 | misleading | Five full-width 'LIFT' landing lines read as ledges; truss lines as R13; now dashed and dim. | fixed (LD05-F5), presentation only |
| LD05-107 | legit | Gate spire_wind_shutter (240x30 body at [1430.0, 420.0]): bypassed by wall jumps up its side (probe passed=True). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R18 PUMP GALLERY (2600x1440)

Intended route: Pump Gallery: from R16 door (120,1000) east along the pump walk to the R19 walk-through (2440,760) behind the electric isolator. Depth door (1200,1180) to R8.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 4 / -160, then 4 / 0 / 116. Double jump + dash from near-top ledges: 0 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-108 | escape | left wall: chained wall jumps from floor/ledge leave the world (feet y -158, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-109 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-110 | dead | Wall column between the highest ledge (y 620) and the roof underside (feet y 116) is 504 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-111 | dead | 2 wall-side walk-through exit(s) leave 58/98 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-112 | legit | Gate pump_electric_isolator (240x30 body at [2370.0, 760.0]): bypassed by wall jumps up its side (probe passed=True). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R19 COIL SERVICE HALL (2400x1440)

Intended route: Coil Service Hall: from R18 (120,760) across service bays; east walk-through (2280,980) to R11; depth door (1800,480) to R20 behind the coil fire gate.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 5 / 5 / -161, then 5 / 0 / 116. Double jump + dash from near-top ledges: 4 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-113 | escape | left wall: chained wall jumps from floor/ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-114 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -161, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-115 | dead | Wall column between the highest ledge (y 480) and the roof underside (feet y 116) is 364 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-116 | dead | 2 wall-side walk-through exit(s) leave 58 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
| LD05-117 | misleading | Overhead 10 px conduit across the room read as a ceiling ledge; arches as R15; now dashed and dim. | fixed (LD05-F5), presentation only |
| LD05-118 | legit | Gate coil_fire_service (240x30 body at [1730.0, 480.0]): bypassed by wall jumps up its side (probe passed=True). Not a progression defect: entry to the next room is enforced by world.can_enter / expansion.allowed flags, not by collision. | kept, documented |

## R20 RELAY JUNCTION (2200x1440)

Intended route: Relay Junction: from R17 (120,760) up to the wind-fold (600,520) to R13; east walk-through (2080,1120) to R19.

Probes before, after (wall chains incl. faces / escaped / lowest feet y): 4 / 4 / -161, then 4 / 0 / 116. Double jump + dash from near-top ledges: 4 probes, 0 escaped before, 0 after. Grapple: 0 swings, 0 attached.

| Id | Class | Finding | Status |
|---|---|---|---|
| LD05-119 | escape | left wall: chained wall jumps from floor/ledge leave the world (feet y -160, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-120 | escape | right wall: chained wall jumps from floor/ledge leave the world (feet y -161, x outside the room). | fixed by the roof course (LD05-F1) |
| LD05-121 | dead | Wall column between the highest ledge (y 520) and the roof underside (feet y 116) is 404 px of bare wall; reachable only by sustained wall jumps, now bounded and harmless. | kept, bounded |
| LD05-122 | dead | 2 wall-side walk-through exit(s) leave 58 px of floor beyond the drawn door where Kaze can stand with the door behind. | residual (creator decision, see report) |
