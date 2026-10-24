# Balance proposals and ecology boundaries

All values below are first-test values, not creator-approved balance. These are mechanical labels; no species, uniform, corporate or Darkness allegiance is established.

| Behavior | Existing/new role | Commitment and counterplay | Boundaries |
| --- | --- | --- | --- |
| EN01 guard | Existing patrol and pursue | Locked facing during >=0.5s warning; jump/dash/parry/retreat | Existing module unchanged |
| EN01 ranged | Existing cover/sightline challenge | Locked aim; cover and jump response | Existing module unchanged |
| EN01 ambush | Existing dormant proximity threat | Visible awakening before full attack warning | Existing module unchanged |
| EN02 skirmisher | Proposed corridor timing challenge | 0.80s wake, 0.65s strike warning, <=0.16s active window, 1.0s recovery; reposition only before commitment | HP4; speed80; 60px maximum backstep; 2s cooldown; extra42px end margin; cannot repeatedly read every attack |
| EN02 slime lunge | Proposed damp-space rhythm | 0.80s wake, 0.70s compression, 0.30s ground travel; inherited single strike at0.16s; 0.12s harmless landing, 1.10s recovery | HP4; <=120px same-platform travel, no midair seeking, no passive touch/poison/status effect |
| Sentry awareness | **Design only** | Local LOS alert after delay, cancellable while control unavailable | No implementation, global director, instant offscreen damage or extra spawning |

The lunge uses `attack_range=110` plus inherited `hit_radius=42`. The separately labelled amber threat rectangle conservatively contains the entire committed 120px travel plus 152px forward strike reach, 14px rear tolerance and 85px vertical window above/below the feet. It remains conservative for a long physics step that evaluates the single hit later in travel. The short line denotes movement/presentation, not the full damage range. Skirmisher's rectangle similarly contains its 130px static forward reach. Both labs have a clear retreat outside the 600â€“1300 territory. No hazard is active in these two first-pass scenes. Combined telegraph/hazard fairness is pending and must precede any placement.

## 21-room candidate assessment â€” no placements

| Room | Proposal or exclusion |
| --- | --- |
| R0 Canal Haven | Excluded: safe start; no new enemies or fire collider. |
| R1 Lantern Market | ST05 candidate only: skirmisher on a future accepted side territory, outside sentinel/reward runway. No replacement sentinel or gate. |
| R2 Flooded Cistern | ST05 candidate only: slime on a dry, fixed, wide ledge after geometry approval. Never a blind water landing. |
| R3 Echo Shrine | Excluded from this wave: checkpoint/Tether teaching clearance. |
| R4 Broken Span | ST05 candidate only: pre-crossing fixed platform; no lunge across gap, grapple interference or damage-causation claim. |
| R5 Ascent Tower | No placement proposed; vertical movement exceeds current surface contract. |
| R6 Tide Warden | Excluded: existing production boss. |
| R7 Relay Archive | No placement proposed; preserve restoration and checkpoint. |
| R8 Relay Undercroft | No placement proposed; hub/checkpoint, no casualty implication. |
| R9 Signal Terrace | ST05 candidate only: one accepted wide lane separated from sigil/return envelopes. |
| R10 SkyWorks Approach | No placement proposed; preserve intake/three-sigil approach. |
| R11 Storm Foundry | Excluded from rest/save safety envelopes. |
| R12 Keeper Relay | Excluded: existing production boss and return. |
| R13 Mooring Loft | No placement proposed; preserve LD08 open top and ability return. |
| R14 Bellroof Walk | No placement proposed; preserve stairs and lower recovery. |
| R15 Lower Sluice | Ecology resemblance only; no current ST05 encounter candidate or commission. |
| R16 Root Shrine | Excluded: safe checkpoint and ambiguous care. |
| R17 Counterweight Spire | ST05 candidate only on an approved fixed rest-independent lane; no vertical pursuit or open-top change. |
| R18 Pump Gallery | No placement proposed; existing guard/vent/readability and PR47 art retained. |
| R19 Coil Service Hall | ST05 candidate only after HAZ owner proves nonoverlapping escape windows and Fire-seal clearance. |
| R20 Relay Junction | No placement proposed; preserve return-switch travel. |

At most the six ST05 opportunities R1/R2/R4/R9/R17/R19 remain candidate spaces. Creator geometry comes first. No EN02 code references production room placement data.

## Creator review questions

1. Is the skirmisher's occasional retreat readable and fair, or does 60px feel evasive?
2. Does the lunge telegraph communicate its effective reach at normal gameplay scale? Should travel/reach be shortened?
3. Is the non-damaging landing and 1.10s recovery long enough for a clear punish?
4. Accept fixed-ground slime behavior, or request a separately scoped physical-hop experiment?
5. Which, if any, of the six existing Story/Level opportunities should receive a later territory audit?
6. Commission dedicated slime action poses only after behavior choice; ART11 skins do not supply missing attack/hurt/death drawings.

Human balance, physical-controller input, macOS, full campaign save/load, combined hazards and production placement remain unapproved.
