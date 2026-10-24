# ST-06 — Presentation Order, Chronology and Ability Visuals

**Documentation-only revision • October 24, 2026.** The creator confirmed the order below. Exact trigger rooms/conditions, flashback scenes and return handling remain pending. No runtime is implemented or authorized.

## Player-experience timeline — no assumed clock or new room IDs

| Phase | Player experience | Ownership / preserved state | Pending review |
|---|---|---|---|
| A — Present gameplay | Existing trap/cave post-attack sequence as currently developed; survivor search begins | Existing gameplay/sequence owners, approved opening/objective and present abilities remain unchanged | Exact trap/cave coordinates and relation to R0 are not assigned here |
| B — Pending flashback trigger | Explore and clear selected rooms before the later flashback | Existing progression stays authoritative; no new flags, thresholds or route gates | Creator chooses exact rooms and conditions; no duration assumed |
| C — Powerless flashback | Play Kaze's earlier life before she has powers, following original Story Bible and ST-01 | Powerless is a narrative/design constraint; separate experience design must preserve current campaign unlocks/progress/saves | Activities, scenes, allowed interactions, controls, completion, skip and reentry require creator/Gameplay/INT review |
| D — Return to present | Resume the existing present world and then-current objective | Preserve earned unlocks, gameplay progress and saves; no duplicate rewards or forced initial-objective replay | Return location, save/reload, interruption and resume policy require separate decisions |

## Story chronology — different from presentation order

1. **Earlier clan life before powers.** Playable flashback C draws from this period; exact scenes and interactions remain pending.
2. **Trial reveals potential; later outside rescues expose elemental traces.** Story Bible chronology retained. Exact playable coverage and transition out of the powerless period are not selected here.
3. **Refuge attack, unnamed parents' sacrifice, separation/fall and recovery.** ST-01 and creator direction retained. P01–P08 illustrate candidate attack/aftermath material; their placement inside a later flashback or memory remains pending.
4. **Present post-attack survivor search.** Player starts here in A, explores through B, experiences earlier life in C, then returns here in D. No later reveal is brought forward.

The powerless flashback draws from earlier life. It does not retcon the trial, later powers or attack, nor select how far the playable flashback extends. Kenji remains Kaze's brother; Aria remains Kenji's missing partner; the parents remain unnamed. Later Mizuki/Darkness revelations stay protected.

## Retained attack/fall study — relative offsets only

This is the eight-card legacy study, preserved for possible later flashback or memory treatment. **It is not the game's first 90 seconds, a complete playable prologue, or new-game autoplay.** The former 17-second pre-control proposal has no authority over boot or current gameplay.

| Relative study window | Retained concept | Control / accessibility proposal |
|---|---|---|
| +0–3 s | P01 ordinary refuge fragment interrupted | Candidate framing only; static fragment and readable description |
| +3–6 s | P02 unnamed parents protect Kaze | Candidate protective silhouettes; no explicit fatal aftermath |
| +6–9 s | P03 impact separates her downward | Presentation only; dissolve without white flash |
| +9–13 s | P04 fall | Two stable levels/captions; no controller velocity or fall-damage edits |
| +13–17 s | P05 landing/recovery | Recovery composition only; actual handback is owner-reviewed, not tied to +17 s |
| +17–45 s | P06 blocked return | Candidate boundary read; no current ability disabling, collision change or opening-text replay |
| +45–70 s | P07 first evidence | Neutral trace, no required examine; D13 remains pending |
| +70–90 s | P08 search continuity / Market direction | Original first-objective reference only; return preserves the then-current objective/reward state |

Exact placement, length and whether any candidates accompany the flashback remain creator decisions. P01–P08 are not a replacement for developing the playable earlier-life segment after approval.

## Safe presentation contract — future owner validation

- A / existing new game: preserve current trap/cave and boot/load behavior. Do not insert the eight-card study at startup.
- B / trigger: no selected IDs, room-count threshold, flag schema or activation code. Future eligibility must be approved by creator and Gameplay/INT.
- C / powerless experience: do not remove, reset or save over present-day abilities. How a separate playable experience represents this period needs implementation review; this package supplies no controller or ability changes.
- D / completion, skip or cancellation: require owner-controlled return preserving present unlocks, gameplay progress, saves and then-current objective. Exact return/resume/reentry policy remains unresolved; no destination is invented.
- Save/reload, old saves and repeated entry: future review must establish consistent outcomes without lost progress, duplicate rewards or replaying boot. No save field, migration or test is implemented here.
- Pause/menu/focus loss: future owners review clock suspension, safe resume/cancel and single control handback. These are acceptance requirements, not implemented support.
- Damage/death/room rebuild: authoritative world owns cancellation; presentation must not teleport, resurrect, re-grant or overwrite a newer control owner.
- Remapped keyboard/controller: future prompts use actual bindings; no hardcoded button art or audio-only/color-only evidence.
- Reduced motion/reduced flash: stable equivalent cards/text; no shake, tracking, parallax, speedline/flicker or white-flash dependency. The playable flashback's accessibility/skip coverage remains to be designed.
- Fire: Level/HAZ must approve credible unsafe standing/return conditions and safe retreat. No flame artwork implying blocked collision that does not exist.
- Canal Doorway and automatic transitions retain existing ownership. No new prompt overlaps a passage, checkpoint, pickup, enemy/hazard or rope envelope.

These are documentation requirements awaiting separately authorized implementation and testing, not proof of CIN/INT or runtime support.

## Spoiler-safe read-through by experience phase

- **A:** Retain the approved opening: **The refuge was attacked. I have to find the others.**
- **A / existing first objective:** **Search for survivors. Defeat the Market sentinel for Windstep.**
- **B:** Present exploration and selected room clears. No invented automatic line, forced clue or trigger assignment.
- **C:** Play earlier life before powers; clan life, relationships and training follow original canon. Exact activities and dialogue remain pending. No new mandatory spoken dialogue or early Mizuki/Darkness reveal.
- **D:** Continue the authoritative present objective and progress; do not reissue the first objective over later progress. Approved ST-05 writing remains unchanged.
- **P01–P08 if later selected:** Environmental/caption and unnamed protective-action concepts only; no named survivor, helper identity, corporate disclosure, dated evacuation, body reveal or revenge framing.

## Ability visual specifications — present progression only

The following existing review specifications remain unchanged. They do not grant abilities in the powerless flashback or select its ending.

## Windstep + Wind Kunai — R1 reward (E mechanics; P art)
Source grants `player.double_jump=true`, `unlock_kunai("wind")` and saves together after existing sentinel/reward eligibility. Art never splits the bundle.
P sequence 0–0.6s: approved-proportion Kaze poised on same safe Market landing, training recognition without invented orb.
0.6–1.5s: paired silhouette distinguishes first jump and **second airborne jump**; upward redirection, not horizontal dash. This is a proposed still-panel arc, not simulated physics/timing.
1.5–2.4s: same safe landing; separate small Wind Kunai illustration + actual bound jump/kunai prompts. No new projectile/collider is spawned by presentation.
Art handoff: 2–3 original artist-reviewed drawings with transparency, unchanged body proportions/pivot/feet metadata, separate effect alpha; no image generation or claim of completed art.
Skip/static: one composite still labelled Windstep + Wind Kunai; authoritative ownership unchanged. Practice only in existing safe area verified by Level; no new mandatory second-jump test.

## Wind Tether — R3 (E mechanics; P art)
Existing tether_unlocked; held airborne attachment and momentum swing, not grapple teleport/grab-and-release.
P sequence 0–0.7s: reach/grip close detail with actual supported anchor silhouette.
0.7–1.6s: clear line/arc around anchor; slack/release state cannot imply a different rope integrator or range.
1.6–2.4s: return to same safe platform with bound attach/hold/pump guidance; no actual automatic grapple.
Separate hand/grip, body and line alpha layers; preserve silhouette and rope clearance. Static mode shows anchor–line–player relationship. Owner validates input device mapping and accepted anchor range, not ST06.

## Gale Dash — R5 (E mechanics; P art)
Existing dash_unlocked reward and approved Dash behavior; no new unlock or wind-step substitution.
P sequence 0–0.5s: anticipation silhouette.
0.5–1.3s: horizontal/approved-direction streak illustration with consistent proportions; **illustrative timing is not controller timing**.
1.3–2.2s: anchored finish/recovered stance on same safe landing, bound Dash prompt. No new speed, invulnerability or aerial-use promises beyond source.
Separate afterimage/effect alpha from body; no leg-size changes or stretched character. Static mode uses start/end silhouettes. Actual braking animation belongs to existing animation owner.

## Shared ability and tool handoff
World/StoryDirector grants once before accepted optional presenter request; play/skip/focus loss cannot change earned state. Use T2 one-to-three panels, never a new production editor. Map approved art later into existing CIN04/Studio interfaces through their owners; no duplicate clips/interface or adoption implied. Existing fixed presentation constraints remain; proposed 2.2–2.4s art candidates are not overrides of any accepted runtime duration.
All reveal origins ("training remembered" vs "new technique") remain creator decisions, not retroactive power-loss lore.
