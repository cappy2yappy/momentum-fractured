# Enemy Sprite Placeholders

These are **temporary placeholder sprites** for prototyping the combat system.

## Current Placeholders

- **Echo** (32×48) - Red humanoid, basic enemy
- **Drone** (24×24) - Purple flying bot
- **Golem** (64×64) - Gray tank enemy
- **Ninja** (32×48) - Dark stealth enemy
- **Guardian** (48×56) - Orange armored warrior
- **Sentry** (32×32) - Pink turret

Each has a 4-frame idle animation at 8 FPS.

## Replace With Real Assets

See `ENEMY_ASSETS.md` in project root for sourcing guide.

**Recommended free packs:**
- Ninja Adventure Pack (itch.io) - CC0
- Kenney Monster Pack (kenney.nl) - CC0
- OpenGameArt cyberpunk sprites - CC-BY

**Budget upgrade ($30-50):**
- Craftpix Ninja Pack ($15)
- GameDev Market Mecha Pack ($20)

## Importing Real Sprites

1. Download sprite pack
2. Extract frames to `assets/sprites/enemies/[enemy_name]/`
3. Update `AnimatedSprite2D` in `scenes/enemies/[enemy_name].tscn`
4. Adjust collision shapes to match sprite size
5. Test in combat prototype scene

## Animation Requirements

**Minimum:**
- idle (4-8 frames, looping)
- walk (6-8 frames, looping)
- attack (4-6 frames, non-looping)
- death (6-8 frames, non-looping)

**Optional:**
- hitstun (1-3 frames)
- special ability (varies)

FPS: 12 recommended (8-24 range)
