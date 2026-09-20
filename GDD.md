# MOMENTUM: FRACTURED - Game Design Document

**Genre:** 2D Metroidvania Action-Platformer  
**Style:** Tokyo Noir / Cyberpunk / Anime  
**Core Loop:** Room-to-room combat + ability-gated exploration  
**Inspiration:** Metroid Dread, Hollow Knight, Dead Cells (combat feel)

**Target:** Vertical slice (Shibuya biome) in 2 months  
**Early Access:** Q4 2026

---

## Table of Contents

1. [Vision & Concept](#vision--concept)
2. [Core Mechanics](#core-mechanics)
3. [Game Structure](#game-structure)
4. [Player Character](#player-character)
5. [Enemy Roster](#enemy-roster)
6. [Six Biomes](#six-biomes)
7. [Progression System](#progression-system)
8. [Combat System](#combat-system)
9. [Room Types](#room-types)
10. [Technical Specs](#technical-specs)
11. [Current Status](#current-status)
12. [Development Timeline](#development-timeline)

---

## Vision & Concept

### High Concept
**"Metroid meets Tokyo at midnight."**

You play as Kaze, a fractured soul navigating a shattered neon metropolis. Each room is a self-contained combat encounter. Defeat all enemies to unlock the exit. Gain new abilities to access previously unreachable areas. Explore an interconnected world that rewards curiosity and mastery.

### Aesthetic
- **Visual:** Neon-lit Tokyo districts, dark alleyways, industrial decay
- **Tone:** Moody, atmospheric, high-contrast lighting
- **Color palette:** Deep blues, electric purples, harsh reds, neon greens
- **Audio:** Synthwave combat themes, ambient exploration tracks

### Core Pillars
1. **Precision movement** - Wall jumps, dashes, grappling hooks feel tight
2. **Room-to-room combat** - Metroid-style locked encounters
3. **Ability-gated exploration** - New powers unlock shortcuts and secrets
4. **Interconnected world** - Backtracking reveals new paths

### Canonical Web-Parity Direction (September 2026)

The playable web version is the canonical benchmark for the Godot build's game feel, visual language, interface, and world structure. A Godot feature does not count as parity merely because a rough mechanical substitute exists.

**Accepted campaign benchmark:** 21 areas, 5 regions, and 5 keeper encounters. Alpha milestones may expose a smaller slice, but every shipped room must feel authored and belong to the eventual interconnected world.

**Non-negotiable parity requirements:**

- Kaze's acceleration, reversal, jump arc, coyote time, jump buffering, dash timing, animation alignment, and action cancellation must be tuned against the web version.
- Wind Tether connects only to visible authored anchor points inside a deliberately limited range. Holding the input creates a pendulum constraint; directional input pumps the swing; releasing preserves tangential momentum. Q and Middle Mouse are equivalent inputs.
- The tether must have a readable wind-energy strand, anchor contact, and motion pulses. A plain debug line is not final presentation.
- Dash creates a readable, short-lived afterimage trail without concealing Kaze or nearby hazards.
- The room map and character/loadout menu are core systems, not optional placeholders. The map records explored rooms and current position; loadout shows HP, traversal abilities, the equipped kunai, and Guard Veil state.
- Water is traversable and changes movement physics. It is not an automatic death plane. Surface, underground, and aquatic routes must connect coherently.
- Wind, Fire, and Electric kunai support combat and explicit ability gates. Locked paths visually communicate which element is required.
- Rooms alternate intimate corridors, compact encounters, purposeful vertical climbs, subterranean passages, aquatic spaces, and selected open vistas. Empty height is not content.
- Exits may occur at lower, middle, or upper elevations. Their placement must continue the spatial logic of the route instead of defaulting to the lower-right corner.
- Encounters use enough enemies to activate the geometry, with reliable player/enemy hitboxes and readable damage feedback.
- Power-ups appear in authored reliquaries or equivalent world objects rather than unframed blocks.

**Visual language:** painted Tokyo-noir environments, deep indigo and violet shadows, cyan wind energy, warm window light, moss/roots in reclaimed spaces, and textured architecture. Flat rectangles may remain as collision geometry during development but must be covered by coherent environmental art before a playtest candidate is labeled parity-ready.

**Canonical Kaze design:** the purple-and-green Kaze shown in the web benchmark and the source sheets under `rebuild/assets/idle.png` and `rebuild/assets/run.png` is the active character design. Her defining features are dark skin, long dark-purple hair, a large vivid-green hair ribbon, fitted purple jacket with white cuffs/collar, green chest bow, dark pleated skirt, purple thigh-high stockings, and purple ankle boots. The red-scarf, cropped-top, loose-pants sprite set under `assets/sprites/kaze/` is a deprecated legacy design and must not be used as an identity reference for new art. The recovered Godot scene currently points at that legacy set and must be migrated only after clean production-ready sheets for canonical Kaze are prepared.

**Character-art pipeline:** concept sheets and generated pose studies are references, not automatically shippable sprites. Production assets require consistent proportions, costume details, frame scale, transparent backgrounds, clean silhouettes, and animation continuity. Required movement coverage includes idle, run, crouch, slide, jump start, rise, fall, wall slide, wall jump, dash, tether attach/swing/release, attack, kunai throw, hurt, and death.

**Current recovery warning:** the first recovery-labeled Alpha 0.8 package was rebuilt on the older four-room foundation and is not a parity baseline. It regressed movement tuning, replaced authored environments with repeated procedural layouts, used an overlong tether range, and reduced the map to a placeholder. Do not use that package as the design reference.

**Next acceptance slice:** one representative route must combine a compact surface approach, purposeful vertical traversal, an underground entrance, contained traversable water, at least one ability-gated return path, functioning map/loadout UI, and an encounter that uses the room geometry. Only after that slice passes movement and presentation review should the treatment expand across the campaign.

---

## Core Mechanics

### Movement (Available from Start)
- **Run** - WASD movement (8-direction)
- **Jump** - Space (variable height based on hold)
- **Wall Jump** - Jump while touching wall (maintains momentum)
- **Wall Slide** - Hold against wall to slow descent
- **Crouch** - Hold Down/S while grounded
  - Uses a reduced collision profile to pass beneath low hazards and geometry
  - Cannot stand when overhead clearance is blocked
  - Requires dedicated enter, hold, and exit animation coverage
- **Momentum Dash** - Shift; available in the baseline kit
  - Can be used once in mid-air before landing
  - Preserves greater incoming horizontal momentum and meaningful vertical momentum
  - Produces a short cyan afterimage trail
- **Wind Tether** - Hold Q or Middle Mouse; available in the baseline kit
  - Attaches only to visible authored anchors within limited range
  - Directional input pumps the pendulum swing
  - Release preserves tangential momentum
- **Wind Kunai** - F; available in the baseline kit

### Unlockable Abilities (Progression-Gated)
- **Fire Kunai** - Opens Fire seals and gains a distinct fire interaction set
- **Electric Kunai** - Opens Electric seals and gains a distinct electric interaction set
- **Guard Veil** - Timed defensive wind state earned from The Borrowed Face
  
- **Double Jump** - Unlocked after Rooftop Gardens boss
  - Press Space again in mid-air
  - Full height second jump
  
- **Slide** - Unlocked after Industrial Docks boss
  - Crouch + Dash
  - Pass under low obstacles
  - Maintain speed through tight spaces
  - Preserve meaningful incoming horizontal momentum instead of snapping to a fixed speed
  - Use the crouched collision profile for the full slide
  - Transition cleanly into jump, attack, or tether where geometry permits

### Combat Actions
- **Light Attack** - Left mouse click (3-hit combo)
- **Heavy Attack** - Hold left click (slower, more damage)
- **Dodge Roll** - Right mouse click (invincibility frames)
- **Parry** - Timed block (E key) - reflects projectiles, stuns melee
- **Aerial Attack** - Attack while airborne (downward strike)
- **Dash-Strike** - Dash + Attack (knockback)

### Systems
- **Health** - HP bar (starts at 100, upgradeable to 200)
- **Stamina** - Used for dodge, parry, dash (regenerates quickly)
- **Cells** - Currency dropped by enemies (spend on upgrades)
- **Checkpoints** - Auto-save progress, respawn point on death
- **Fast Travel** - Unlocked after each boss, return to Hub

---

## Game Structure

### World Layout (Metroidvania)
**Hub:** The Refuge (safe zone, no combat)  
**6 Biomes:** Interconnected, hand-designed rooms  
**Total rooms:** 120-140 (varying sizes and complexity)

### Core Loop
1. **Enter Room**
   - Doors lock behind player
   - Combat music starts
   - Enemies spawn (2-5 per room)

2. **Combat Encounter**
   - Use movement + attacks to defeat all enemies
   - Dodge attacks, parry when possible
   - Enemy counter UI shows progress

3. **Room Clear**
   - Doors unlock
   - Cell drops collected
   - Checkpoint auto-saves (if checkpoint room)
   - Exit to next room OR backtrack

4. **Ability Unlock**
   - Boss defeated → gain new ability
   - Previous areas now accessible
   - Backtrack to find secrets, shortcuts

5. **Repeat**
   - Progress through biomes
   - Collect upgrades
   - Master combat + movement

### Death & Respawn
- **No permadeath** (NOT a roguelite)
- Respawn at last checkpoint
- Enemies in cleared rooms stay dead
- Keep all collected cells (no loss on death)

---

## Player Character

### Kaze (Protagonist)
**Appearance:** Sleek, athletic build (Zero Suit Samus energy, NOT chibi). Canonical costume and silhouette use the purple-and-green web/rebuild design documented above; legacy red-scarf artwork is deprecated.  
**Personality:** Silent protagonist (environmental storytelling)  
**Backstory:** A fractured soul navigating a shattered reality

### Sprite Specs
- **Source:** Canonical purple-and-green Kaze web/rebuild art (already created)
- **Current source references:** `rebuild/assets/idle.png`, `rebuild/assets/run.png`
- **Legacy warning:** `assets/sprites/kaze/` currently contains the deprecated red-scarf design and is not authoritative
- **Format:** Horizontal sprite strips (frames side-by-side)
- **Size:** 64×64 per frame (scalable)

### Animation List
**Movement:**
- idle (4 frames)
- run (8 frames)
- jump (4 frames)
- fall (4 frames)
- dash (6 frames)
- wall_slide (4 frames)
- crouch enter / hold / exit
- slide
- land (3 frames)

**Combat (to be added):**
- attack_1 (4 frames) - First hit of combo
- attack_2 (4 frames) - Second hit
- attack_3 (6 frames) - Finisher
- heavy_attack (8 frames) - Charged strike
- dodge (6 frames) - Roll animation
- parry (4 frames) - Block stance
- aerial_attack (6 frames) - Downward slam
- grapple_slam (8 frames) - Grapple finisher
- hurt (3 frames) - Damage reaction
- death (8 frames) - Fall and fade

---

## Enemy Roster

### Design Principles
- **Readable silhouettes** - Clear at-a-glance identification
- **Telegraphed attacks** - Wind-up animations before strikes
- **Varied behaviors** - Mix of melee, ranged, tank, fast
- **Escalating difficulty** - Later biomes = elite variants

---

### 1. Echo (Basic Humanoid)
**Role:** Tutorial enemy, early game fodder  
**Biome:** Shibuya Crossing  
**HP:** 50  
**Speed:** Slow (60% of Kaze)  
**Attacks:**
- Melee swipe (5 damage)
- Slow charge attack (10 damage, telegraphed)

**Behavior:**
- Patrols set path when idle
- Aggros when Kaze enters range (5 tiles)
- Charges forward when close
- Retreats when HP < 20%

**Visual:** Shadowy humanoid figure, neon outline  
**Asset source:** Ninja Adventure Pack (FREE, itch.io)

---

### 2. Guardian (Armored Warrior)
**Role:** Tank, blocks frontal attacks  
**Biome:** Temple District  
**HP:** 100  
**Speed:** Very slow (40% of Kaze)  
**Attacks:**
- Shield bash (8 damage + knockback)
- Heavy slash (15 damage, slow wind-up)
- Counter-attack (parries player attack, 12 damage)

**Behavior:**
- Holds shield forward (blocks frontal attacks)
- Vulnerable from behind or after parry
- Aggressive when HP < 50% (drops shield, faster attacks)

**Visual:** Samurai armor, glowing katana, oni mask  
**Asset source:** Commission custom ($50-80) OR GothicVania pack (recolor)

---

### 3. Drone (Flying Ranged)
**Role:** Harassment, ranged pressure  
**Biome:** All biomes (appears after Metro)  
**HP:** 30  
**Speed:** Fast (120% of Kaze)  
**Attacks:**
- Laser shot (3 damage, homing)
- Strafe pattern (fires 3 shots in arc)

**Behavior:**
- Hovers above player
- Maintains distance (6-8 tiles)
- Fires when player is grounded
- Flees when Kaze gets close (< 3 tiles)

**Visual:** Compact flying bot, red targeting laser  
**Asset source:** Mecha Enemy Pack ($20) OR OpenGameArt (FREE)

---

### 4. Ninja (Stealth Assassin)
**Role:** Fast, evasive, ambush  
**Biome:** Rooftop Gardens  
**HP:** 60  
**Speed:** Very fast (140% of Kaze)  
**Attacks:**
- Dash-slash (8 damage, teleports behind player)
- Shuriken throw (5 damage × 3)
- Smoke bomb (becomes invisible for 3 seconds)

**Behavior:**
- Waits in hiding until player enters room
- Teleports around arena (unpredictable)
- Throws shurikens from distance
- Retreats when cornered (smoke bomb escape)

**Visual:** Dark ninja garb, glowing eyes, afterimage trails  
**Asset source:** Craftpix Ninja Pack ($15) - **PRIORITY BUY**

---

### 5. Golem (Heavy Tank)
**Role:** Slow, massive damage, AoE attacks  
**Biome:** Underground Metro, Industrial Docks  
**HP:** 200  
**Speed:** Very slow (30% of Kaze)  
**Attacks:**
- Ground slam (20 damage, AoE shockwave)
- Overhead smash (25 damage, cracks floor)
- Charge (15 damage, knockback)

**Behavior:**
- Stationary until aggro'd
- Slow wind-up attacks (2-second telegraphs)
- Immune to knockback
- Enrages at 30% HP (attacks faster)

**Visual:** Massive industrial robot, exposed core (weak point)  
**Asset source:** Kenney Monster Pack (recolor, FREE) OR commission ($80)

---

### 6. Sentry Bot (Turret)
**Role:** Area denial, stationary threat  
**Biome:** Industrial Docks, Fractured Core  
**HP:** 80  
**Speed:** Immobile  
**Attacks:**
- Tracking laser (4 damage/sec, continuous beam)
- Bullet spread (6 damage × 5 shots)
- Overheat mode (stops firing for 5 seconds after 10 shots)

**Behavior:**
- Wall-mounted or ceiling-mounted
- 270° rotation (has blind spots)
- Locks onto player when in range
- Fires in bursts, then overheats

**Visual:** Mechanical turret, red targeting reticle  
**Asset source:** Mecha Enemy Pack ($20)

---

### Boss Enemies (6 Total)
1. **Echo Amalgam** (Shibuya) - Swarm of Echos fused together
2. **Kitsune Matriarch** (Temple) - Nine-tailed fox spirit, teleports
3. **Steel Serpent** (Metro) - Mechanical snake, segmented body
4. **Sky Sentinel** (Rooftops) - Aerial boss, flying arena
5. **Dockmaster Titan** (Docks) - Giant industrial mech
6. **The Architect** (Core) - Final boss, multi-phase

*Boss designs detailed in separate boss_design.md doc*

---

## Six Biomes

### Hub: The Refuge
**Purpose:** Safe zone, no combat  
**Features:**
- Upgrade station (spend cells on permanent upgrades)
- Fast travel hub (unlocks after each boss)
- NPC dialogue (lore, hints)
- 6 exits (one to each biome)

**Upgrades Available:**
- Max HP (+10 HP, 5 tiers → 150 HP max)
- Attack damage (+10%, 5 tiers)
- Dash cooldown reduction
- Extra stamina
- Cell magnet range

---

### 1. Shibuya Crossing (Tutorial Biome)
**Theme:** Neon-lit streets, crowded plazas (now empty and fractured)  
**Enemy types:** Echo (basic), Drone (introduced late)  
**Room count:** 10-15 rooms  
**Difficulty:** Easy (introduces combat, movement)

**Key features:**
- Tutorial messages (teach controls)
- Simple combat encounters (1-3 enemies per room)
- First checkpoint system
- Safe rooms with health refills

**Boss:** Echo Amalgam (teaching pattern recognition)  
**Ability unlock:** None (tutorial biome)  
**Progression gate:** Must clear to unlock Temple District

---

### 2. Temple District
**Theme:** Ancient shrines, torii gates, stone gardens  
**Enemy types:** Guardian (armored), Echo (patrol), Drone  
**Room count:** 15-20 rooms  
**Difficulty:** Medium (teaches parry, timing)

**Key features:**
- Vertical platforming challenges
- Guardian enemies require parry or backstab
- First ability-gated secrets (grapple points visible but unreachable)
- Larger combat arenas (4-5 enemies)

**Boss:** Kitsune Matriarch (teleport, multi-phase)  
**Ability unlock:** To be reassigned during campaign restructuring
**Progression gate:** Must build on the baseline Wind Tether rather than withholding it

---

### 3. Underground Metro
**Theme:** Abandoned subway tunnels, flickering lights, rail tracks  
**Enemy types:** Drone (swarms), Golem (first appearance), Sentry Bot  
**Room count:** 15-20 rooms  
**Difficulty:** Medium-Hard (ranged enemy pressure)

**Key features:**
- Moving platforms (trains on tracks)
- Environmental hazards (electrified rails, steam vents)
- Drone swarms (3-4 at once)
- Wind Tether shortcuts back to Hub

**Boss:** Steel Serpent (chase sequence + arena fight)  
**Ability unlock:** To be reassigned during campaign restructuring
**Progression gate:** Must build on the baseline Momentum Dash rather than withholding it

---

### 4. Rooftop Gardens
**Theme:** Skyscraper tops, bamboo groves, zen gardens in the sky  
**Enemy types:** Ninja (primary), Guardian, Drone  
**Room count:** 20-25 rooms  
**Difficulty:** Hard (fast enemies, vertical focus)

**Key features:**
- Tall vertical rooms (grapple + wall jump required)
- Ninja ambushes (hidden until aggro)
- Wind currents (affect jump arcs)
- Secret rooms behind breakable walls

**Boss:** Sky Sentinel (aerial battle, requires grapple + dash)  
**Ability unlock:** Double Jump  
**Progression gate:** Double jump opens path to Docks

---

### 5. Industrial Docks
**Theme:** Cargo shipyards, cranes, oil rigs, rusted metal  
**Enemy types:** Golem (heavy), Sentry Bot (turrets), all previous types  
**Room count:** 20-25 rooms  
**Difficulty:** Very Hard (tank + ranged combos)

**Key features:**
- Hazardous environments (oil spills, crushers, moving cranes)
- Elite enemy variants (faster, more HP)
- Large arenas with cover (use to avoid Sentry lasers)
- Checkpoint scarcity (longer room chains)

**Boss:** Dockmaster Titan (multi-stage mech fight)  
**Ability unlock:** Slide  
**Progression gate:** Slide required to enter Core's ventilation shafts

---

### 6. The Fractured Core
**Theme:** Reality collapsing, glitching environments, void spaces  
**Enemy types:** All previous types, elite variants, new Core-specific enemies  
**Room count:** 30+ rooms  
**Difficulty:** Extreme (gauntlet, tests all skills)

**Key features:**
- Mixed enemy compositions (all types together)
- Elite variants (2× HP, new attacks)
- Environmental chaos (shifting platforms, disappearing floors)
- Point of no return (must complete or respawn at entrance)

**Boss:** The Architect (final boss, 4-phase fight)  
**Ability unlock:** None (final area)  
**Ending:** Story resolution, unlock New Game+

---

## Progression System

### Ability Gating (Metroidvania Standard)

**Early game (Shibuya + Temple):**
- Available: Run, Jump, Wall Jump, Wall Slide, Crouch, Momentum Dash, Wind Tether, Wind Kunai, Basic Attack
- Unlock: Fire Kunai during the first authored progression loop
- Gates: Authored anchors teach Wind Tether routes; discovered Fire seals preview return paths

**Mid-game (Metro + Rooftops):**
- Available: Baseline movement kit + Fire Kunai
- Unlock: Electric Kunai and Double Jump (exact campaign milestones pending restructure)
- Gates: Elemental circuits, chained tether routes, and tall shafts

**Late-game (Docks + Core):**
- Available: Full movement kit
- Unlock: Slide (Docks boss)
- Gates: Low crawl spaces, speed-based platforming

### Backtracking Rewards
- **With baseline Wind Tether:** Authored anchors expose skill routes and later shortcuts
- **With baseline Momentum Dash:** Movement mastery creates optional speed routes
- **After Fire/Electric unlocks:** Return to earlier elemental seals for shortcuts and secrets
- **After Double Jump:** Access rooftop secrets in all previous areas
- **After Slide:** Speed-run optimizations

### Upgrades (Spend Cells at Hub)
- **Health** - +10 HP per tier (5 tiers, costs scale: 50 → 100 → 200 → 400 → 800 cells)
- **Attack** - +10% damage (5 tiers, same cost scaling)
- **Stamina** - +1 extra dodge/dash (3 tiers)
- **Cell Magnet** - Increase pickup range (3 tiers)
- **Dash Cooldown** - Reduce from 1.0s to 0.5s (3 tiers)

**Total cells needed for max upgrades:** ~4,000 cells  
**Average cells per enemy:** 5-10 cells  
**Encourages:** Combat engagement, exploration

---

## Combat System

### Player Combat
**Attack chain:**
1. **Light attack** - 10 damage, 0.3s cooldown
2. **Light attack** - 10 damage (if pressed again within 0.5s)
3. **Finisher** - 15 damage + knockback (third hit in combo)

**Heavy attack (hold):** 25 damage, 1.0s wind-up, stuns enemy briefly

**Aerial attack:** 12 damage, downward hitbox, bounces Kaze upward on hit

**Dash-strike:** 15 damage + large knockback, requires dash ability

**Parry:** Timed block (0.2s window), reflects projectiles, stuns melee enemies for 1.5s

### Hitbox System (Godot Implementation)
**Components:**
- `health.gd` - Tracks HP, emits damage/death signals
- `hurtbox.gd` - Area2D that receives damage (attached to entities)
- `hitbox.gd` - Area2D that deals damage (attached to attacks)

**Flow:**
1. Player attacks → activates Hitbox (0.15s duration)
2. Hitbox overlaps enemy Hurtbox → applies damage
3. Hurtbox sends damage to Health component
4. Health emits `damage_taken` signal → enemy enters hitstun
5. If HP reaches 0 → `died` signal → enemy death animation

**Hitstun:** 0.3s freeze on damage (enemy can't act)  
**Invincibility frames:** 0.5s after taking damage (flashing sprite)  
**Knockback:** Applied in direction of attack (vector-based)

### Enemy AI States
1. **Idle** - Patrols or stands still
2. **Alert** - Player detected, moves toward
3. **Attack** - Within range, executes attack pattern
4. **Hitstun** - Just took damage, frozen briefly
5. **Retreat** - Low HP, backs away
6. **Death** - Plays death animation, drops cells

---

## Room Types

### Combat Room (70% of total rooms)
**Purpose:** Main gameplay loop  
**Features:**
- Locked doors (red barrier appears)
- 2-5 enemies spawn
- Enemy counter UI (top-right)
- Doors unlock when all enemies defeated
- Cell drops collected

**Variants:**
- Small (1-2 enemies, tight space)
- Medium (3-4 enemies, standard arena)
- Large (5+ enemies, multiple platforms)

---

### Platforming Challenge (15%)
**Purpose:** Test movement skills, no combat  
**Features:**
- Environmental hazards (saws, lasers, spikes, crushers)
- Timed sequences (moving platforms)
- Optional shortcuts (unlocked with abilities)

**Examples:**
- Saw gauntlet (precise wall jumps)
- Laser grid (dash through gaps)
- Vertical shaft (grapple + double jump challenge)

---

### Safe Room (10%)
**Purpose:** Checkpoints, respite  
**Features:**
- Auto-save checkpoint
- Health refill station (free, unlimited use)
- Shop (buy consumables with cells)
- No enemies, no combat

**Shop items:**
- Health potion (instant 50 HP heal) - 20 cells
- Damage boost (30s buff, +50% damage) - 40 cells
- Invincibility potion (10s immune) - 100 cells

---

### Secret Room (5%)
**Purpose:** Reward exploration  
**Features:**
- Hidden behind breakable walls OR ability-gated
- Contains: extra cells (50-100), health upgrades, lore items
- Optional content (not required for progression)

**Discovery methods:**
- Breakable walls (visual cracks in wall)
- Grapple-only paths (above normal reach)
- Dash-required gaps (speedrun tech)

---

## Technical Specs

### Engine
**Godot 4.6.1** (GDScript)

### Project Structure
```
momentum-fractured/
├── assets/
│   ├── sprites/
│   │   ├── kaze/ (player character)
│   │   └── enemies/ (Echo, Guardian, Drone, Ninja, Golem, Sentry)
│   ├── tilesets/ (environment tiles)
│   ├── audio/
│   │   ├── music/ (combat, exploration, boss themes)
│   │   └── sfx/ (attacks, hits, deaths)
│   └── vfx/ (hit sparks, death particles)
├── scenes/
│   ├── kaze.tscn (player)
│   ├── enemies/ (6 enemy types)
│   ├── rooms/ (120+ room scenes)
│   ├── ui/ (HUD, menus)
│   └── hub.tscn (The Refuge)
├── scripts/
│   ├── player/ (kaze_base.gd, movement, combat)
│   ├── enemies/ (AI behaviors)
│   ├── combat/ (health.gd, hitbox.gd, hurtbox.gd)
│   ├── rooms/ (room_controller.gd, door logic)
│   └── ui/ (HUD updates, menus)
└── tools/
    └── room_editor/ (web-based level design tool)
```

### Animation Specs
- **Frame size:** 64×64 pixels (scalable to 128×128 for HD)
- **Format:** PNG sprite strips (horizontal layout)
- **FPS:** 12 fps (smooth, cinematic)
- **Sprite sheets:** One per animation (idle_strip.png, run_strip.png, etc.)

### Room Design Tool
**Web app:** `https://laibyrinth.com/fractured-room-editor.html`  
**Features:**
- 8 tool types (Platform, Enemy, Hazard, Moving, Breakable, One-Way, Checkpoint, Exit)
- Click to place, drag to move
- Export to JSON
- Import JSON into Godot scenes

**Workflow:**
1. Design room layout in web tool
2. Export JSON
3. Send to Cappy (or commit to repo)
4. Cappy converts JSON → Godot scene
5. Test in editor

---

## Current Status (Phase 2 Complete)

### ✅ Completed
- **Combat system:** Hitbox/Hurtbox/Health components working
- **Player character:** Kaze sprite integrated, attack functional
- **Enemy prototype:** Echo (basic humanoid) with AI
- **Room controller:** Locked doors, enemy counter, unlock on clear
- **Test scene:** 1 combat room with 3 Echos (playable)

### 🚧 In Progress
- Tuning combat feel (knockback, hitstun, damage values)
- Adding visual feedback (hit flash, damage numbers)
- Enemy AI improvements (aggro range, attack patterns)

### 📋 Next Steps (Phase 3)
1. **Room transition system** (door → next scene, scene persistence)
2. **3-5 interconnected rooms** (combat → platforming → checkpoint)
3. **Checkpoint system** (save progress, respawn point)
4. **Health bar UI** for player
5. **Camera system** (room constraints, smooth follow)

### 🎯 Milestones
- **Week 1-2:** Room transitions + persistence working
- **Week 3-4:** First 3-room sequence playable
- **Month 2:** Shibuya biome complete (10-15 rooms)
- **Month 3-6:** Remaining 5 biomes + bosses
- **Month 7-8:** Polish, balance, playtesting
- **Q4 2026:** Early Access launch

---

## Development Timeline

### Phase 1: Foundation (Complete)
- ✅ Movement prototype (M0M3NTUM)
- ✅ Combat mechanics design

### Phase 2: Combat System (Complete)
- ✅ Hitbox/Hurtbox/Health system
- ✅ Player attack implementation
- ✅ Enemy AI prototype (Echo)
- ✅ Room-based combat (locked doors)

### Phase 3: Room System (2 weeks)
- [ ] Room transitions (door → scene load)
- [ ] Scene persistence (dead enemies stay dead)
- [ ] Checkpoint save/load system
- [ ] 3-room playable sequence

### Phase 4: First Biome (4 weeks)
- [ ] Shibuya Crossing (10-15 rooms)
- [ ] 2 enemy types (Echo + Drone)
- [ ] First boss (Echo Amalgam)
- [ ] Tutorial messaging
- [ ] Health/stamina UI

### Phase 5: Core Abilities (6 weeks)
- [x] Wind Tether baseline implementation
- [x] Momentum Dash baseline implementation
- [ ] Fire and Electric Kunai progression routes
- [ ] Double Jump (Rooftops boss unlock)
- [ ] Ability tutorial rooms

### Phase 6: Remaining Biomes (12 weeks)
- [ ] Temple District (15-20 rooms)
- [ ] Underground Metro (15-20 rooms)
- [ ] Rooftop Gardens (20-25 rooms)
- [ ] Industrial Docks (20-25 rooms)
- [ ] Fractured Core (30+ rooms)
- [ ] 6 boss fights

### Phase 7: Polish (4 weeks)
- [ ] Visual effects (hit sparks, screen shake)
- [ ] Audio (music, SFX)
- [ ] Balance pass (damage, HP, enemy placement)
- [ ] Playtesting + bug fixes

### Phase 8: Launch Prep (4 weeks)
- [ ] Steam page + trailer
- [ ] Marketing campaign
- [ ] Early Access build
- [ ] Community Discord

**Total timeline:** 8 months (March 2026 → October 2026)  
**Vertical slice target:** 2 months (Shibuya biome)

---

## Asset Budget

### Enemy Sprites
**Free assets (prototype):**
- Ninja Adventure Pack (Echo) - $0
- Kenney Monster Pack (Golem) - $0
- OpenGameArt (Drone) - $0

**Paid assets (polish):**
- Craftpix Ninja Pack - $15
- Mecha Enemy Pack - $20
- Roguelike pack (Guardian) - $15

**Custom commissions (final):**
- Boss sprites (6 bosses) - $300-500
- Elite enemy variants - $100-200

**Total budget:** $450-750

### Music & SFX
- Purchase royalty-free packs - $50-100
- OR commission custom tracks - $500-1000

**Total budget:** $50-1000 (depending on custom vs stock)

### Total Asset Budget: $500-1750

---

## Design Documents (Reference)

- **DESIGN_UPDATE.md** - Metroidvania structure notes
- **PHASE_2_COMPLETE.md** - Combat system implementation details
- **ENEMY_ASSETS.md** - Enemy sprite sourcing guide
- **ASSET_GUIDE.md** - General asset recommendations
- **boss_design.md** - Boss fight mechanics (TBD)
- **ability_design.md** - Detailed ability mechanics (TBD)

---

## External Links

**GitHub:** https://github.com/cappy2yappy/momentum-fractured  
**Room Editor:** https://laibyrinth.com/fractured-room-editor.html  
**Original M0M3NTUM prototype:** `~/Documents/Playground/m0m3ntum/`

---

**Document version:** 1.0  
**Last updated:** March 9, 2026  
**Status:** Living document (update as design evolves)

---

*This GDD is a working document. Mechanics, numbers, and features may change during development. Refer to GitHub commit history for latest updates.*

---

## Alpha 0.8 Playtest Milestone — September 2026

Alpha 0.8 rebuilds the playable campaign on the retained GitHub foundation and makes clean checkout/export reliability part of the milestone definition.

### Playable Scope
- 12 connected rooms: four original combat/platforming rooms plus Broken Span, Wind Relay, Reliquary Approach, Canal Undercroft, Conservatory Walk, The Rootwell, Hall of Borrowed Faces, and Borrowed Face Sanctum.
- Two boss milestones: Storm Reliquary and The Borrowed Face.
- Vertical rooms use elevated exits, compact platform clusters, and visible tether anchors.
- Water is traversable. Entering water applies drag, lowers gravity and fall speed, and Space provides a swim stroke.

### Traversal and Combat
- Wind Tether: hold Q or Middle Mouse. The rope constrains distance while preserving tangential velocity, allowing momentum-based swings.
- Momentum Dash: Shift. Dash produces a short cyan afterimage trail.
- Elemental Kunai: F throws; mouse wheel cycles unlocked Wind, Fire, and Electric variants.
- Fire and Electric seals are physical route gates and only open when struck with their matching kunai.
- Guard Veil: C grants a three-second defensive state with an eight-second cooldown after the Borrowed Face reward.

### Progression
- Wind Kunai is available from the start.
- Storm Reliquary unlocks Fire Kunai.
- Clearing the Hall of Borrowed Faces unlocks Electric Kunai.
- Defeating The Borrowed Face unlocks Guard Veil.
- Room clears, health, cells, checkpoints, and ability unlocks persist in the save file.

### UI and Testing
- I opens the character/loadout screen with HP, traversal tools, equipped kunai, and Guard Veil state.
- HUD displays tether/kunai/veil controls, encounter state, and boss framing.
- Automated Alpha 0.8 smoke coverage loads all 12 rooms, validates player systems and animation slicing, verifies grapple anchors, and exercises all three progression rewards.
