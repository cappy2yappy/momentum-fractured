# AUD02 cue assignment matrix

All reference candidates are provisional signal matches, not auditioned selections. Rights and creator approval remain pending for every supplied source. Default bank stays AUD01. Original alternatives are CC0 and enabled only with --audio-bank=aud02.

| Event | Exact reference filename | AUD02 review behavior | Creator choice |
|---|---|---|---|
| step_stone | commse0 (150).wav | Existing AUD01 / existing hook | Pending |
| step_wood | minigame (11).wav | Existing AUD01 / existing hook | Pending |
| jump | pupSe (14).wav | Existing AUD01 / existing hook | Pending |
| land | pupSe (15).wav | Existing AUD01 / existing hook | Pending |
| dash | missionSe (19).wav | New original / existing hook | Pending |
| slide | commse0 (13).wav | Design proposal; no dedicated new hook | Pending |
| wall_jump | pupSe (20).wav | Design proposal; no dedicated new hook | Pending |
| tether_fire | commse0 (1).wav | New original / existing hook | Pending |
| tether_attach | minigame (7).wav | New original / existing hook | Pending |
| tether_release | pupSe (71).wav | New original / existing hook | Pending |
| tether_swing | pupSe (62).wav | Design proposal; no dedicated new hook | Pending |
| swing | commse0 (8).wav | New original / existing hook | Pending |
| contact | missionSe (46).wav | New original / existing hook | Pending |
| parry | commse0 (56).wav | New original / existing hook | Pending |
| damage | minigame (6).wav | Existing AUD01 / existing hook | Pending |
| enemy_defeat | pupSe (42).wav | Design proposal; no dedicated new hook | Pending |
| kunai_throw | commse0.wav | New original / existing hook | Pending |
| impact_wind | commse0 (5).wav | New original / existing hook | Pending |
| impact_fire | minigame (5).wav | New original / existing hook | Pending |
| impact_electric | pupSe (13).wav | New original / existing hook | Pending |
| elemental_gate | hugebtl (28).wav | Design proposal; no dedicated new hook | Pending |
| checkpoint | missionSe (48).wav | Existing AUD01 / existing hook | Pending |
| room_passage | missionSe (49).wav | New original / existing hook | Pending |
| wind_fold | pupSe (19).wav | Design proposal; no dedicated new hook | Pending |
| collectible | commse0 (147).wav | Design proposal; no dedicated new hook | Pending |
| ui_confirm | commse0 (6).wav | Design proposal; no dedicated new hook | Pending |
| reject | pupSe (61).wav | Existing AUD01 / existing hook | Pending |
| ambience | pupSe (67).wav | Existing loops retained; no new profile | Pending |
| death | No supplied source selected | Existing AUD01 death cue retained | Pending |

Wall jumps continue using the existing jump cue. Elemental gates continue using their actual elemental-contact cue. Slide, continuous tether, enemy defeat, collectibles and general menu notifications have no new emitters in this isolated task; adding them requires separate event-specific integration/QA. Teleport/wind-fold proposals do not add a second transition emitter. No soundtrack is assigned.

See AUD02_SHORTLIST.json for two alternate references per event, source hashes, flags and detailed design briefs.
