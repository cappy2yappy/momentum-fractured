# Room Creation Tools

Two ways to create rooms for MOMENTUM: FRACTURED:

---

## Method 1: Web Room Editor (Recommended for Quick Design)

**URL:** https://laibyrinth.com/fractured-room-editor.html

### Steps:
1. Open the web editor in your browser
2. Design your room:
   - Click tools (Platform, Enemy, Hazard, etc.)
   - Click/drag to place objects
   - Use subtype picker for variations
3. Click "Export JSON"
4. JSON auto-copies to clipboard
5. Save as `tools/room_import.json` in this project
6. In Godot: **File → Run** → Select `tools/import_room_json.gd`
7. Your room appears in `scenes/rooms/[room_name].tscn`
8. If this is a fresh checkout, open the project in Godot once first so sprite imports are generated before running the importer

**Pros:**
- Fast (5 minutes per room)
- Visual, intuitive
- Generates a playable room shell (camera, player, HUD, room bounds)
- No Godot knowledge needed

**Cons:**
- Manual import step
- Door links still need to be set manually after import

---

## Method 2: Godot Editor (Manual)

### Steps:
1. Create new scene: **Scene → New Scene**
2. Add root node: `Node2D` (name it `Room02` or similar)
3. Add child nodes:
   - `Environment` (Node2D)
   - `Enemies` (Node2D)
   - `SpawnPoints` (Node2D)
4. Under Environment, add:
   - `StaticBody2D` for platforms
   - `ColorRect` for visuals
   - `CollisionShape2D` for collision
5. Under Enemies, instance:
   - `scenes/enemies/echo.tscn`
   - Position them
6. Add `RoomController` script to root
7. Configure exports:
   - `enemies_node`: NodePath to Enemies
   - `door_barriers`: Array of door barriers
   - `door_exits`: Array of exits
8. Save scene

**Pros:**
- Full control
- Test immediately (F6)
- No import needed

**Cons:**
- Slower (15-20 minutes per room)
- Requires Godot knowledge

---

## Room Structure Template

Every room should have:

```
RoomName (Node2D)
├── RoomController (script attached)
├── Camera2D (follows player)
├── SpawnPoints (Node2D)
│   ├── spawn_default (Marker2D)
│   └── entry_from_room2 (Marker2D)
├── Environment (Node2D)
│   ├── Floor (StaticBody2D)
│   ├── Walls (StaticBody2D)
│   ├── Platforms (StaticBody2D)
│   ├── LeftDoorBarrier (StaticBody2D)
│   └── RightDoorExit (Area2D + DoorExit script)
├── Enemies (Node2D)
│   ├── Echo1 (instanced scene)
│   └── Echo2 (instanced scene)
└── UI (CanvasLayer)
    └── EnemyCounter (Label)
```

---

## RoomController Setup

Required exports:
- `room_id`: Unique string (e.g., "room_02_platforming")
- `player_node`: NodePath to player (usually auto-found)
- `enemies_node`: NodePath("Enemies")
- `door_barriers`: Array of barrier NodePaths
- `door_exits`: Array of exit NodePaths
- `enemy_counter_label`: NodePath("UI/EnemyCounter")

---

## Room Types

### Combat Room
- 2-5 enemies
- Flat or multi-level platforms
- Doors lock on entry
- Doors unlock when all enemies dead

### Platforming Room
- No enemies
- Hazards (spikes, saws, lasers)
- Moving platforms
- Precision jumps required

### Mixed Room
- 1-3 enemies on platforms
- Requires platforming + combat
- Harder than pure combat

### Safe Room / Checkpoint
- No enemies, no hazards
- Checkpoint (saves progress)
- Health refill station
- Multiple exits (forward + backtrack)

---

## Testing Checklist

Before marking a room complete:
- [ ] Player spawns at spawn_default
- [ ] Can move/jump/attack
- [ ] Enemies spawn correctly
- [ ] Enemies can be killed
- [ ] Doors unlock when cleared (combat rooms)
- [ ] Exit trigger works
- [ ] No collision gaps in floor/walls
- [ ] Camera bounds set correctly
- [ ] Room ID is unique
- [ ] Visual feedback (enemy counter updates)

---

## Tips

**Grid snapping:** Enable in Godot (View → Grid Snap = 10px)

**Copy/paste rooms:** Duplicate an existing room scene, rename, modify

**Test early:** Run scene (F6) after every major change

**Commit often:** `git add . && git commit -m "Add room_02"` after each room

**Reference existing:** See `scenes/rooms/room_01_combat.tscn` for example

---

**Questions?** Check `GDD.md` Section 3 (Room Structure) or ask in Discord.
