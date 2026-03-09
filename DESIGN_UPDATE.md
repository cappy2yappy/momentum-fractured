# FRACTURED Design Update - Metroidvania Structure

**Date:** March 9, 2026  
**Change:** From roguelite (Dead Cells) to Metroidvania (Metroid/Hollow Knight)

---

## Structure Change

### ❌ OLD (Roguelite - Dead Cells)
- Procedurally arranged rooms
- Death resets the run
- Meta-progression (cells, unlocks)
- Randomized enemy placement

### ✅ NEW (Metroidvania - Metroid Dread)
- **Interconnected map** (hand-designed rooms)
- **Room-to-room combat** (enter room → kill all enemies → unlock exit)
- **Checkpoints** between major areas
- **Ability-gated progression** (need grapple to reach X area, dash to cross Y gap)
- **Backtracking** with new abilities unlocks shortcuts
- **No death reset** - respawn at last checkpoint

---

## Core Loop (Metroidvania)

1. **Enter Room**
   - Doors lock behind you
   - Music shifts to combat theme
   - 2-5 enemies spawn

2. **Combat Encounter**
   - Use movement (dash, wall jump, grapple) + attacks
   - Defeat all enemies
   - Collect cells (currency) from kills

3. **Room Clear**
   - Doors unlock
   - Save checkpoint (auto-saves progress)
   - Move to next room or backtrack

4. **Ability Unlock**
   - Find new ability (grapple, dash, double jump)
   - Opens new paths in previous areas
   - Backtrack to explore newly accessible rooms

5. **Boss Fight**
   - End of each biome (6 total)
   - Unlock major ability or story progression
   - Checkpoint before boss room

---

## Map Structure (Metroid-Style)

### Hub Area: The Refuge
- Safe zone (no combat)
- Upgrade station (spend cells on permanent upgrades)
- Fast travel points (unlock after each boss)
- 6 exits (one to each biome)

### 6 Biomes (Hand-Designed)

**1. Shibuya Crossing** (Tutorial)
- 10-15 rooms
- Echo enemies (basic)
- Teaches: movement, combat basics
- Boss: Echo Amalgam

**2. Temple District**
- 15-20 rooms
- Guardian enemies (armored)
- Teaches: parry, timing
- Ability unlock: Grapple Hook
- Boss: Kitsune Matriarch

**3. Underground Metro**
- 15-20 rooms
- Drone + Sentry enemies
- Teaches: ranged combat, platforming under pressure
- Ability unlock: Dash (mid-air)
- Boss: Steel Serpent

**4. Rooftop Gardens**
- 20-25 rooms
- Ninja enemies (stealth, ambush)
- Vertical traversal focus
- Ability unlock: Double Jump
- Boss: Sky Sentinel

**5. Industrial Docks**
- 20-25 rooms
- Golem enemies (tanks)
- Heavy combat, hazard navigation
- Ability unlock: Slide (crouch + dash)
- Boss: Dockmaster Titan

**6. The Fractured Core**
- 30+ rooms
- All enemy types
- Elite variants, harder encounters
- Final Boss: The Architect

**Total:** ~120-140 hand-designed rooms

---

## Room Types

### Combat Room (70% of rooms)
- Locked doors
- 2-5 enemies
- Clear = doors unlock
- Cell drops

### Platforming Challenge (15%)
- No enemies
- Environmental hazards (saws, lasers, spikes)
- Tests movement skills
- Optional shortcuts unlocked with abilities

### Safe Room (10%)
- Checkpoint (save point)
- Health refill station
- Shop (spend cells on consumables)
- No combat

### Secret Room (5%)
- Hidden behind breakable walls or ability-gated paths
- Extra cells, health upgrades, lore items
- Optional but rewarding

---

## Progression (Ability-Gated)

### Early Game (Shibuya + Temple)
**Available:** Run, Jump, Wall Jump  
**Unlock:** Grapple Hook (after Temple boss)

### Mid Game (Metro + Rooftops)
**Available:** + Grapple Hook  
**Unlock:** Dash (after Metro boss), Double Jump (after Rooftops boss)

### Late Game (Docks + Core)
**Available:** Full movement kit  
**Unlock:** Slide, advanced combat abilities

---

## Combat System (Same as Before)

- **Melee combos** (3-hit light attack)
- **Dodge roll** (i-frames)
- **Parry** (timing-based counter)
- **Dash-strike** (movement + attack)
- **Grapple-slam** (aerial finisher)

Health system, hitbox/hurtbox, same as Dead Cells style but in Metroidvania structure.

---

## Metroidvania vs Roguelite

| Feature | Metroidvania | Roguelite (OLD) |
|---------|--------------|-----------------|
| Map | Interconnected, hand-designed | Procedurally arranged |
| Death | Respawn at checkpoint | Restart run |
| Progression | Abilities unlock areas | Meta-upgrades |
| Difficulty | Gradual curve | Spike with elite enemies |
| Replayability | Speedruns, 100% completion | Different runs |

---

## Why This Change?

**Cap's preference:** "Room-to-room combat similar to Metroid"

**Benefits:**
- More controlled pacing (design each encounter)
- Ability-gating creates satisfying progression
- Backtracking rewards exploration
- Better for storytelling (hand-placed lore)
- Clearer structure for level design tool

**Trade-offs:**
- Less randomness (but more polish)
- More design work (120 rooms vs 60 procedural)
- Replayability through mastery, not variety

---

## Player Character: Kaze

**Sprite:** Use existing M0M3NTUM Kaze sprite (KEEP original)  
**Animations:** idle, run, jump, fall, dash, wall_slide, crouch, land  
**Source:** `~/Documents/Playground/m0m3ntum/godot-project/assets/sprites/kira/`

**Combat animations (add new):**
- attack_1, attack_2, attack_3 (combo)
- dodge (roll)
- parry (block stance)
- grapple_slam (aerial attack)

---

## Enemy Sprites

**Use free assets:**
- Ninja Adventure Pack (itch.io) - Echo, Ninja
- Kenney Monster Pack - Golem
- OpenGameArt cyberpunk - Drone, Sentry
- Commission or buy: Guardian (samurai style)

---

## Next Steps

1. ✅ Combat prototype (Phase 2) - in progress
2. Create first combat room (1 room, 3 Echo enemies)
3. Add room transition system (locked doors)
4. Build 3-room sequence (combat → platforming → checkpoint)
5. Design full Shibuya map (10-15 rooms)
6. Implement ability unlock system
7. Build remaining 5 biomes

---

**Timeline:**
- **Week 1-2:** Combat prototype (Kaze vs Echo in 1 room)
- **Week 3-4:** Room system + 3-room sequence
- **Month 2:** Shibuya biome complete (10-15 rooms)
- **Months 3-6:** Remaining biomes + bosses
- **Month 7-8:** Polish, balance, playtesting

**Target:** Vertical slice (Shibuya biome) in 2 months
