# Kaze — Silent District Alpha 0.8.0

Alpha 0.8 is a recovery build made from the retained GitHub combat foundation. It is superseded for playtesting: its room count increased, but it did not preserve the web version's movement, map, authored environments, or tether targeting closely enough.

Development has moved to the `codex/web-parity-restoration` line. The next candidate must pass the GDD's web-parity acceptance slice before it is packaged.

## Web-Parity Restoration Candidate

The current candidate now includes three authored rooms from the five-room acceptance slice:

- Compact Surface Approach with a denser three-lane encounter and raised exits.
- Wind Relay Shaft with a three-screen ascent, deliberate tether anchors, and recovery routes.
- Underground Threshold with a compressed descent, two grounded enemies, one aerial threat, and a visible Fire Reliquary.
- Fire Kunai is no longer silently awarded for clearing Room 7. Clear the chamber, approach the reliquary, and press **E** to claim it.
- Claiming Fire Kunai activates the Underground Threshold checkpoint and opens the canal route.
- Wind Tether targeting is limited to nearby visible anchors and no longer attaches through walls.

The Canal Chamber and Fire-sealed return shortcut are still prototype/generated rooms. This build is a playtest candidate for the restored movement and first three authored rooms, not final visual parity.

## Highlights

- 12 connected rooms with compact, vertical, subterranean, aquatic, and conservatory layouts.
- Two boss milestones: Storm Reliquary and The Borrowed Face.
- Momentum-based Wind Tether on Q or Middle Mouse with a visible rope.
- Dash afterimages and correctly sliced character animation sheets.
- Traversable water with buoyant movement and swim strokes.
- Wind, Fire, and Electric kunai; F throws and the mouse wheel changes unlocked elements.
- Fire and Electric route seals require their matching kunai.
- Character/loadout menu on I.
- Guard Veil on C after defeating The Borrowed Face.
- Persistent room clears, abilities, health, cells, and checkpoints.

## Playtest Focus

1. Swing momentum and tether release speed.
2. Room density and whether vertical layouts feel intentional rather than empty.
3. Swimming control and transitions into and out of water.
4. Enemy hit registration and encounter density.
5. Elemental gate clarity and unlock pacing.
6. Boss health, pressure, and reward communication.
7. Underground Threshold encounter density, reliquary clarity, and **E** interaction reliability.

## macOS Note

This playtest build is not Apple-notarized. Control-click the app and choose Open. If macOS still blocks it, use System Settings > Privacy & Security > Open Anyway.


## September 30 development session — canal integration

- Replaced generated Room 8 with an authored 1920×1080 Canal Chamber, deep alternate route, solid bottom floor, and dry recovery shores.
- Added reciprocal Threshold/return entrances, surface Drone pressure, and two survivable timed current jets with warnings and safe intervals.
- Added W/S swimming, neutral depth hold, time-based acceleration/drag, overlap-safe water detection, and respawn cleanup.
- Prevented tether attachment while fully submerged while retaining surface-band attachment.
- Added swimming and canal regression checks to the Windows/macOS build workflow.

This remains a parity-slice candidate, not an accepted alpha. Current-jet art is provisional. Canonical character art, the Fire return shortcut, underwater presentation, direct playtesting and device-specific 60 FPS validation remain open. Existing smoke/scene shutdown may emit ObjectDB leak warnings.

## October 12 recovery — stability increment

- Preserved both original checkouts and the legacy branch/stash; active candidate is based on September 30 parity development.
- Recovered camera-correct damage numbers and defensive checkpoint/combat lookups.
- Fixed melee repeat damage within one window, already-overlapping combo windows, lethal enemy physics-callback mutations, and pooled projectile monitoring.
- Checkpoint/room arrival restoration now waits for scene_changed, preserving the authored destination marker.
- Added 43 real-collision/checkpoint/audio/feedback regression checks and an isolated-save validation runner.

Alpha acceptance, canonical Kaze art, subjective feel and target-device 60 FPS remain open.
