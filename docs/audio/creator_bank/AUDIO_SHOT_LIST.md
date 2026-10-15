# KAZE Audio Shot List — Creator Sound Bank

**Owner:** Creator / Music Director (sound selection); Sound Shogun (technical mapping and implementation)  
**Status:** Planning checklist, **not sound approval**  
**Version:** AUDIO-SHOTS-01 (2026-10-15)  
**Related:** [AUD-02 PR #21](https://github.com/cappy2yappy/momentum-fractured/pull/21) · [Cue matrix](https://github.com/cappy2yappy/momentum-fractured/blob/feature/alpha-0.6.1-audio-curation/docs/audio/aud02/CUE_MATRIX.md) · [TR-03 brief](https://github.com/cappy2yappy/momentum-fractured/pull/22)

## Purpose

The creator will build a personally selected library **one gameplay action at a time**. This replaces speculative sound generation as the primary creative workflow. The existing AUD-01/AUD-02 audio banks are technical fallbacks and **not approved** as Kaze's sound identity; the latest feedback was *slightly improved, still generic*. The supplied S1PS3SFX references are not automatically approved and their redistribution rights are unverified.

## How to use

1. Work through **P0** gameplay events first. Listen against actual gameplay and select 1–3 candidates per event; multiple surface or intensity variants are valid.
2. Put the selected filename or path into the `Selected File` column in `AUDIO_SHOT_LIST.csv` and annotate why you like it in `Creator Notes`. Each cue has a stable `Cue ID` to survive renames.
3. Mark `Status`: `needed`, `reference_selected`, `original_needed`, `ready_for_impl`, `implemented_test`, `approved`, `revise`, or `retired`. **Blank selections do not imply approval.**
4. Mark `Rights`: `unknown`, `internal_reference`, `original`, or `licensed`, with provenance/license link when applicable. Do not distribute unverified third-party recordings in public builds.
5. The Sound Shogun can generate original sounds inspired by broad attributes (attack, weight, space, timing) and implement creator-approved/right-cleared files. Record in-engine test build ref and final decision; preserve source files and fallback mappings.
6. All future agent handoffs should update the CSV alongside their cue map; **do not overwrite or guess creator choices**. PM should review changes before merging.

## Priorities

- **P0:** critical feedback every player immediately hears, needed for the next sound identity pass.
- **P1:** progression, distinct interactions and biome identity, next selection pass.
- **P2:** secondary/future action or content not yet fully implemented; design targets only, not requests to add unsupported gameplay hooks.

## Shot list by category

### Movement

| Cue ID | Priority | Action / moment | Sonic intent | Current integration note |
|---|---|---|---|---|
| MOV-001 | P0 | Stone footstep | Surface-dependent, short dry contact | Hook exists |
| MOV-002 | P0 | Wood footstep | Hollow muted timber contact | Hook exists |
| MOV-003 | P1 | Metal footstep | Sharper ring for industrial surfaces | Hook to assess |
| MOV-004 | P1 | Water/shallow splash step | Soft splash, not a generic footstep | Hook to assess |
| MOV-005 | P0 | Jump takeoff | Quick agile launch; avoid cartoon boing | Hook exists |
| MOV-006 | P0 | Landing light | Weight and fabric/ground contact | Hook exists |
| MOV-007 | P1 | Landing heavy/fall | Distinct higher-impact landing | Hook to assess |
| MOV-008 | P0 | Dash engage | Compressed burst of air and cloth | Hook exists |
| MOV-009 | P1 | Dash trail / pass-by | Optional soft motion tail | Hook to assess |
| MOV-010 | P1 | Slide begin | Low friction movement contact | No dedicated AUD02 hook |
| MOV-011 | P2 | Slide sustain/end | Surface-dependent scrape and recovery | Hook to assess |
| MOV-012 | P1 | Wall contact / wall slide | Brief stone scrape, restraint | Hook to assess |
| MOV-013 | P1 | Wall jump kick-off | Sharper launch using wall material | Currently shares jump |
| MOV-014 | P1 | Double jump unlock/activation | Second airborne lift, skill identity | Hook to assess |
| MOV-015 | P2 | Sprint start | Controlled acceleration, not constant noise | Hook to assess |
| MOV-016 | P2 | Crouch/stand cloth | Subtle clothing movement | Hook to assess |

### Grapple & Traversal

| Cue ID | Priority | Action / moment | Sonic intent | Current integration note |
|---|---|---|---|---|
| TRV-001 | P0 | Tether launch | Crisp projected line and whoosh | Hook exists |
| TRV-002 | P0 | Tether anchor connect | Precise metallic/rope latch confirmation | Hook exists |
| TRV-003 | P1 | Tether tension/swing | Motion tension, repeat-safe, sparse | No dedicated AUD02 hook |
| TRV-004 | P0 | Tether release | Short release flick, no long decay | Hook exists |
| TRV-005 | P2 | Failed grapple / out of range | Quiet denial, not punishing | Hook to assess |
| TRV-006 | P2 | Climb ledge / mantle | Hands, cloth and exertion | Hook to assess |

### Combat

| Cue ID | Priority | Action / moment | Sonic intent | Current integration note |
|---|---|---|---|---|
| CBT-001 | P0 | Basic melee swing | Fast, readable blade/arm motion | Hook exists |
| CBT-002 | P0 | Melee hit enemy | Impact with weight, distinct from swing | Hook exists |
| CBT-003 | P1 | Hit armored enemy | Sharper resistance and rejection | Hook to assess |
| CBT-004 | P0 | Parry successful | Confident tight metallic contact | Hook exists |
| CBT-005 | P1 | Parry failed/guard break | Danger feedback, not same as success | Hook to assess |
| CBT-006 | P0 | Player damage | Clear damage acknowledgment | Hook exists |
| CBT-007 | P0 | Player death/knockout | Distinct final hit + collapse | Hook exists |
| CBT-008 | P1 | Enemy defeat | Impact/departure responsive to enemy type | No dedicated AUD02 hook |
| CBT-009 | P1 | Enemy telegraph / windup | Short warning before attack | Hook to assess |
| CBT-010 | P1 | Enemy attack | Differentiated by enemy type | Hook to assess |
| CBT-011 | P2 | Boss appearance/introduction | Boss-specific stinger, not music replacement | Encounter not yet locked |
| CBT-012 | P2 | Boss phase shift | Distinct state change, future milestone | Encounter not yet locked |
| CBT-013 | P2 | Boss defeat | Weighty, earned payoff | Encounter not yet locked |

### Kunai & Elements

| Cue ID | Priority | Action / moment | Sonic intent | Current integration note |
|---|---|---|---|---|
| ELM-001 | P0 | Kunai throw | Compact aerodynamic flick | Hook exists |
| ELM-002 | P1 | Kunai strike generic | Light puncture/metal contact | Hook to assess |
| ELM-003 | P0 | Wind kunai impact | Tight gust/slash, airy low tail | Hook exists |
| ELM-004 | P0 | Fire kunai impact | Transient ignition with short crackle | Hook exists |
| ELM-005 | P0 | Electric kunai impact | Controlled spark/snap, avoid tiring fizz | Hook exists |
| ELM-006 | P1 | Element change / ability select | Three recognizable but cohesive UI cues | Hook to assess |
| ELM-007 | P1 | Wind gate activation | Activation distinct from projectile impact | Currently uses element contact |
| ELM-008 | P1 | Fire gate activation | Mechanical/arcane response to ignition | Currently uses element contact |
| ELM-009 | P1 | Electric gate activation | Relay/contact power confirmation | Currently uses element contact |
| ELM-010 | P1 | Ability unlocked / upgrade | Positive but restrained unlock identity | Hook to assess |

### Rooms, Progression & UI

| Cue ID | Priority | Action / moment | Sonic intent | Current integration note |
|---|---|---|---|---|
| WLD-001 | P0 | Horizontal walk passage | Soft spatial swish, not generic teleport | Hook exists |
| WLD-002 | P1 | Running passage | Faster continuation appropriate to velocity | TR03 design pending |
| WLD-003 | P1 | Door turn and enter | Door/frame and footsteps into depth | TR03 design pending |
| WLD-004 | P1 | Stair entry / ascending | Steps recede upward | TR03 art pending |
| WLD-005 | P1 | Stair entry / descending | Steps recede downward | TR03 art pending |
| WLD-006 | P1 | Wind-fold teleport | Distinct special gust/fabric fold identity | No dedicated AUD02 hook |
| WLD-007 | P0 | Checkpoint activate | Memorable safe-rest signal | Hook exists |
| WLD-008 | P0 | Locked passage / denied | Readable no-entry response | Hook exists |
| WLD-009 | P1 | Secret discovered | Discovery hint, not loud collectible jingle | Hook to assess |
| WLD-010 | P1 | Item/collectible pickup | Quick satisfying confirmation | No dedicated AUD02 hook |
| WLD-011 | P1 | Switch/mechanism activate | Gear/relay travel, reusable | Hook to assess |
| WLD-012 | P1 | UI confirm | Original crisp interface tick | No dedicated AUD02 hook |
| WLD-013 | P1 | UI cancel/back | Lower-energy contrasting cue | Hook to assess |
| WLD-014 | P1 | Map open/close | Paper/cloth/arcane scan minimalism | Hook to assess |
| WLD-015 | P2 | Map discovery/new cell | Small progression signal | Hook to assess |
| WLD-016 | P2 | Menu tab/loadout change | Repeat-friendly subtle UI change | Hook to assess |
| WLD-017 | P1 | Low-health warning | Non-fatiguing, accessible warning | Hook to assess |
| WLD-018 | P1 | Save completion | Confirmation, not a second checkpoint | Hook to assess |

### Ambience & World Identity

| Cue ID | Priority | Action / moment | Sonic intent | Current integration note |
|---|---|---|---|---|
| AMB-001 | P1 | Hidden Village daytime | Life, wind, distant settlement; loop-safe | Future biome soundscape |
| AMB-002 | P2 | Hidden Village attack | Urgency without music replacement | Story scene future |
| AMB-003 | P1 | Overgrown Shrine | Air, leaves, stones, subtle resonance | Future biome soundscape |
| AMB-004 | P1 | Canal Remains | Subterranean water and echoes | Existing ambience candidate |
| AMB-005 | P1 | Silent District night | Distant city, rooftop airflow | Existing ambience candidate |
| AMB-006 | P2 | Hillside Shelter | Wind, foliage, refuge | Future biome soundscape |
| AMB-007 | P2 | Underwater entry / exit | Muted immersion boundary | Future mechanic |
| AMB-008 | P2 | Underwater bed | Pressure-damped environmental loop | Future mechanic |
| AMB-009 | P2 | Industrial relay/foundry | Machine hum, controlled electrical texture | Future biome soundscape |
| AMB-010 | P1 | Wind corridor / high rooftops | Directional wind, no constant harsh hiss | Area mix profile |

## Review quality bar

- **In-game fit:** immediate response for fast abilities, controlled decay, no masking hit/parry cues.
- **Variation:** avoid harsh repeated identical samples for rapid events; do not overpopulate with unnecessary layers.
- **Consistency:** sounds form a distinct grounded ninja/fantasy identity across traversal, combat and space.
- **Mix:** practical loudness, gameplay accessibility, elemental recognizability, stable loop seams.
- **Safe change:** do not modify movement, save schema, progression gates, room graph or emitters simply to fill an unimplemented sound slot; coordinate code hookups as separate reviewed implementation work.

### Immediate creator shortlist

Start with **dash, melee swing, melee contact, parry, kunai throw, three elemental impacts, grapple launch/attach/release, footsteps, jump, land, room passage, checkpoint, damage/death**. These give the highest return in your next Windows playtest.
