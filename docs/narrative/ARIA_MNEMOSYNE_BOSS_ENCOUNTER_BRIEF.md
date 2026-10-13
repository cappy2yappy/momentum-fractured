# Kaze / Momentum Fractured | Aria (Air) Boss Encounter Brief

**Design ID:** BOSS-ARIA-01  
**Working title:** Aria, Eye of the Tempest  
**Supporting system codename:** Project MNEMOSYNE (**working**, not final name)  
**Engine target:** Godot 4.6.1; 2D Metroidvania; 60 FPS target  
**Status:** Narrative premise creator-approved; encounter, implementation and placement are design proposals. No existing gameplay or repo files are changed by this brief.

## 1. Narrative requirements and hard boundaries

**CONFIRMED:** Aria Zephyros is the Air elemental, Kenji Harima's missing investigation partner and close friend with developing romantic feelings. Darkness holds her to lure **Kaze**, not merely Kenji. She has undergone **technology-driven neural conditioning**; her memory of Kenji is suppressed. She fights Kaze as a boss, survives, is freed from control and can be recruited. Kenji is 22, Fire-aligned and Kaze's protective elder brother; Kaze is 16. Mizuki's long-term psychological grooming is categorically distinct from Aria's forced technological manipulation.

**Nonnegotiable story experience:** This is a **nonlethal rescue battle**, not execution or punishment of Aria. Aria remains intelligent and dangerous; Kenji's presence creates emotional stakes, but does not remove player agency or require a second controllable character. Never disclose Mizuki's later betrayal through this encounter.

**ENDORSED CONCEPT, not finalized:** Tiny visible behind-ear neural interface linked to ArcuTech infrastructure; control signal degradation releases access to suppressed memories. **Project MNEMOSYNE** and exact hardware form are working ideas pending explicit design confirmation.

## 2. Intended player experience

- Feel: a skilled, emotionally consequential duel against an agile Air practitioner whose positioning challenges Kaze's established momentum mechanics.
- Challenge: read wind telegraphs, use wall jumps, dash and limited grapple intelligently, create safe openings, and disable a control source.
- Resolution: **subdue and liberate**, without lethal framing. Kenji recognizes Aria; she does not recognize him until control falters.
- Emotional arc: anticipation of reunion -> shock at her hostility -> growing evidence of imposed control -> hard-won recognition -> uncertain, humane recovery.

## 3. Setting proposal

**PROPOSED:** An ArcuTech atmospheric-testing and neural-control chamber integrated into an existing industrial/vertical region. Industrial fans, movable blast shields and maintenance rails justify Air mechanics without arbitrary floating platforms. Multiple tiers must have meaningful connected traversal, stable landings and no bottomless pits, respecting Alpha 0.6.1 world-cohesion feedback. Aesthetic: corporate clinical machinery overtaken by violent Air effects, readable silhouettes, no generic empty mega-room.

**DO NOT ASSUME:** Which of the 21 existing rooms houses this fight, whether ArcuTech currently owns that room, or when in the critical path it occurs. Coordinate with LD-01/DEV-06 and PM before implementation.

## 4. Proposed phase specification

| Phase | Trigger (proposal) | Combat identity | Narrative beat | End condition |
|---|---|---|---|---|
| 0: Reveal | Enter arena / short in-engine scene | Aria intercepts Kaze | Kenji calls to her; no recognition | Player movement restored; encounter begins |
| 1: Wind Guardian | Boss engaged | Directed gusts, air blades, pressure barrier, controlled short aerial repositioning | Aria labels them intruders | First suppression threshold and readable network cue |
| 2: Tempest | Control node destabilizes / health threshold | Crosswind zones, airborne openings, arena fan interactions, wind-assisted attacks | Brief memory glitches emerge | Safely disable control node(s) and reduce combat aggression |
| 3: Release | Node(s) offline and Aria subdued nonlethally | Combat resolves into short staged recovery scene | Aria struggles to recognize Kenji, then begins recovering | Quest completion; no lethal defeat animation |

**Note:** Stage count, boss HP thresholds, number of nodes and attacks are **PROPOSED**. The player should never be required to strike Aria's implant. Preferred mechanic is disrupting an **external control relay**, visually reducing conditioning influence. No graphic surgical removal. A medically safe recovery path is to be defined narratively rather than claiming real medical realism.

## 5. Moveset proposals and counterplay

| Ability | Telegraph | Threat | Counterplay / fairness rule |
|---|---|---|---|
| Crescent Air Blade | Aria traces a bright curved arm gesture with distinct wind buildup | Horizontal/diagonal projectile | Dash past or jump through intentional gap; maintain clear collision edges |
| Crosswind Sweep | Fan and floor banners stream toward one side before gust | Temporary horizontal force | Shelter behind grounded geometry or exploit deliberate traversal route |
| Pressure Dome | Concentric air rings visibly compress around Aria | Temporary frontal defense | Reposition rather than spam melee; dome ends on a readable timer |
| Updraft Pillar | Ground dust forms a narrow cyclone column | Launch hazard or vertical lift | Dodge or optionally ride to upper route; no unavoidable knockback loop |
| Tempest Dive | Suspended charge pose and landing reticle | Quick aerial strike | Commit to dodge window with generous warning and recovery |
| Neural Feedback Glitch | Interface/relay flashes, audio stutter | Momentary pattern disruption | Telegraphed pause produces a safe window; avoid seizure-like full-screen flashes |

Maintain reasonable projectile counts and minimize particles; stability at 60 FPS and combat readability outweigh spectacle. All attacks must operate with source-validated character sizes and approved control bindings.

## 6. Nonlethal victory system (proposal)

- Aria has a **stability / suppression** state separate from conventional enemy death.
- Disabling relay interactables weakens behavioral control while she is contained in the arena; any boss HP depletion means **stagger/subdue**, not death.
- Player can't soft-lock the rescue by destroying required nodes out of order; nodes clearly distinguish enabled, vulnerable and disabled states.
- Kenji can provide story dialogue/audio cues, not uncontrolled AI damage or invincible boss-cheese assistance.
- When rescue conditions are satisfied, boss AI stops, hurtbox becomes non-hostile, cutscene begins and quest state commits once.

## 7. Suggested implementation architecture (Godot, not committed)

- `AriaBoss` (CharacterBody2D or preexisting compatible enemy base) using a deterministic finite-state machine: `INTRO`, `DUEL`, `TEMPEST`, `STAGGER`, `FREED`.
- `NeuralRelay` interactable(s) with `ONLINE`, `EXPOSED`, `DISABLED`, signals `relay_disabled` and optional `interference_changed`.
- `AirHazard` scene variants with Area2D telegraphs, velocity fields and explicit impact bounds. Test against momentum/grapple/dash code rather than reinventing traversal.
- `EncounterController` manages triggers, camera bounds, fail/retry, pause, doors/exit, rescue cutscene and persistent quest completion.
- **Proposed persisted identifiers** (must be reconciled to project save schema before use): `aria_encounter_started`, `aria_relay_disabled`, `aria_rescued`, `aria_recruited`. These are not live save flags.
- Clear separation between scene effects, AI behavior, narrative dialogue and persistence to facilitate QA.

## 8. Dialogue tone examples (DRAFT, not canon)

**Kenji, on seeing her:** “Aria? Hey. It's me. Kenji.”  
**Aria:** “That name means nothing to me. Leave this facility.”  
**Kaze:** “She's not choosing this. We have to break whatever they're doing to her.”  
**Kenji, after the relay dies:** “You don't have to remember everything right now. You're safe.”

Avoid a single convenient speech overriding technical conditioning. Aria's remembered bond should emerge through the shutdown and later recovery, not because the characters say the correct magic words.

## 9. QA and accessibility acceptance criteria

**Narrative/experience**
- [ ] Darkness uses Aria specifically to lure Kaze; the game does not accidentally reframe Kenji as the true bait target.
- [ ] Aria cannot recognize Kenji during active conditioning; potential flashes only after system disruption.
- [ ] Encounter is nonlethal and leads to recruitment, with credible continued recovery.
- [ ] Mizuki's betrayal, disguise and alliance remain unspoiled.

**Gameplay**
- [ ] Encounter starts, resets and completes reliably after death/reload.
- [ ] All attacks have clear advance cues, safe answers and tuned damage/knockback.
- [ ] No bottomless pits, impossible grapple targets, permanently inaccessible nodes or soft-locks.
- [ ] Camera scale and arena geometry meet Alpha 0.6.1 density/readability feedback.
- [ ] No broken traversal physics, weapon collisions, enemy damage or persistent HUD/minimap regressions.
- [ ] Tested at 60 FPS target with stress-test effects and repeated retries; performance numbers recorded rather than assumed.
- [ ] Verified at keyboard/mouse and controller mappings in the project; telegraphs aren't color-only, flashes remain subdued.

**Implementation gate**
- [ ] LD-01 and PM approve room placement, combat pacing and world connectivity.
- [ ] Art agent approves sprites/VFX scale and readable silhouettes.
- [ ] Gameplay lead confirms compatibility with current movement, save and room-transition systems.
- [ ] Creator approves boss prototype via playtest before declaring integration-ready.

## 10. Proposed agent tasks

1. **ST-01 Narrative:** final dialog beats, Aria agency/recovery timeline, Kenji emotional arc, memory suppression rules and terms.
2. **LD-01 World:** select grounded facility room/route, optional stealth or exploration lead-up, meaningful terrain and relay positioning.
3. **Gameplay/Combat:** prototype Air moveset and nonlethal relay logic in isolated feature branch, preserve traversal.
4. **Art/Animation:** Aria turnaround, air effects, behind-ear tech visualization, readable boss telegraphs.
5. **QA/Integration:** automated scene validations, navigation/camera regression, save-state and performance testing.

## 11. Dependencies and unresolved questions

Aria's exact age; finished program codename; implant design and whether physically implanted; control source/network limits; how Aria was captured; precise reunion sequence; room/biome placement; boss phase count; how and when memory returns; mission vs hub role after rescue; whether an Air ability unlock is appropriate. None should be silently treated as approved.

## 12. Sources and publication

**Story source:** Creator conversation through 13 October 2026.  
**Character reference:** *The Elements: Complete Story Compilation.pdf*, pp. 3–5 and 12–13 for Kenji, Aria, their friendship and elemental capabilities. Its original events are not automatically game canon.  
**Git policy:** Commit on review branch, open PR, do not merge into `main` or alter code without creator direction.

**Publication status:** Document drafted for PM and engineering review; not an implemented Godot encounter.
