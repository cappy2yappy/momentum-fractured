# Shibuya Crossing Room Map

## Main Path

Room 01 (Combat) -> Room 02 (Platforming)  
Room 02 -> Room 03 (Mixed)  
Room 03 -> Room 04 (Checkpoint)  
Room 04 -> Room 05 (Vertical Combat)  
Room 05 -> Room 06 (Hazard Gauntlet)  
Room 06 -> Room 07 (Guardian Intro)  
Room 07 -> Room 08 (Mixed Mayhem)  
Room 08 -> Room 09 (Breather Checkpoint)  
Room 09 -> Room 10 (Pre-Boss)  
Room 10 -> Room 11 (Echo Amalgam Boss)  
Room 11 -> Room 12 (Victory + Ability Unlock)

## Backtracking Links

- Room 02 -> Room 01
- Room 03 -> Room 02
- Room 04 -> Room 01
- Room 05 -> Room 04
- Room 06 -> Room 05
- Room 07 -> Room 06
- Room 08 -> Room 07
- Room 09 -> Room 08
- Room 10 -> Room 09
- Room 11 -> Room 10
- Room 12 -> Room 11

## Room Breakdown

Room 01 (`room_01_combat.tscn`)
- Type: Combat tutorial
- Enemies: 3 Echo
- Purpose: Introduce movement + attack + door unlock flow

Room 02 (`room_02_platforming.tscn`)
- Type: Hazard platforming
- Hazards: Saw, laser, fire pit, kill gaps
- Purpose: Movement and hazard timing

Room 03 (`room_03_mixed.tscn`)
- Type: Mixed combat + hazard
- Enemies: 1 Echo, 1 Guardian, 2 Drone
- Hazards: Crusher, spike pit, void

Room 04 (`room_04_checkpoint.tscn`)
- Type: Safe checkpoint room
- Features: Checkpoint + heal station
- Purpose: Reset before extended run

Room 05 (`room_05_vertical_combat.tscn`)
- Type: Vertical combat arena
- Enemies: 2 Echo, 2 Drone
- Layout: Multi-tier platforms

Room 06 (`room_06_hazard_gauntlet.tscn`)
- Type: Hazard gauntlet
- Hazards: 3 saws, 2 lasers, kill void
- Features: 3 moving platforms

Room 07 (`room_07_guardian_intro.tscn`)
- Type: Combat tutorial (Guardian)
- Enemies: 1 Guardian, 1 Echo
- Purpose: Teach rear/side attacks vs shielded enemy

Room 08 (`room_08_mixed_mayhem.tscn`)
- Type: Mixed combat + hazards
- Enemies: 3 Echo, 1 Drone
- Hazards: Fire pits + crusher + void

Room 09 (`room_09_breather.tscn`)
- Type: Safe checkpoint room
- Features: Checkpoint + heal station
- Purpose: Last checkpoint before boss sequence

Room 10 (`room_10_preboss.tscn`)
- Type: Combat arena (boss warmup)
- Enemies: 4 Echo
- Purpose: Ramp-up before boss room

Room 11 (`room_11_boss.tscn`)
- Type: Boss room
- Enemies: Echo Amalgam
- Exit: Unlocks Room 12 on clear

Room 12 (`room_12_victory.tscn`)
- Type: Victory room
- Features: Grapple ability unlock trigger, completion message

## Door Wiring Validation

Validation run:

- Every `target_scene_path` in `scenes/rooms/room_*.tscn` resolves to an existing scene (`MISSING 0`).
- Headless load validation executed for all new/updated rooms and no parse errors were reported.
