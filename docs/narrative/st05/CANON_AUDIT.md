# Canon preservation audit

## Authority ledger
All five requested PRs were inspected through their current GitHub metadata and actual repository documents/source. All were open drafts, unmerged, on 2026-10-22. Approval comments have narrower scope than the documents containing them.

| Reference | Pinned head / material reviewed | Authority and consequence |
|---|---|---|
| [PR38](https://github.com/cappy2yappy/momentum-fractured/pull/38) | `553285f1e8a3961c6b7c1c83ba861bbd4ee21438`; ST03 CANON_RECOVERY | Recovered world/character canon; its old unresolved naming and placement status is superseded by the creator comment below |
| [PR38 creator decision](https://github.com/cappy2yappy/momentum-fractured/pull/38#issuecomment-6220547422) | 2026-10-16 decision, read directly | C: Mizuki is one canonical character; 21-room section immediately follows attack; R0 must not become original refuge |
| [PR50](https://github.com/cappy2yappy/momentum-fractured/pull/50) | `6fc93d8e96af8318185bec8dd67cd8ab8b04b1a0`; CANON_DECISION_DELTA, ENVIRONMENTAL_BEAT_MAP | Confirmed chronology separated from proposed placement; no shelter geography or survivor confirmation approved |
| [PR68](https://github.com/cappy2yappy/momentum-fractured/pull/68) | `3e6664b65806e4b2b216ff6396eba2be98144add`; ROOM_AUDIT, ENVIRONMENTAL_PROPOSALS | Independent room/function audit; protects undated records and identifies superseded Canal geometry advice |
| [PR68 exact-copy approval](https://github.com/cappy2yappy/momentum-fractured/pull/68#issuecomment-6295657738) | 2026-10-20 comment, read directly | C: three exact display changes only; no new dialogue, scenes, flags, quests or merge |
| [PR72](https://github.com/cappy2yappy/momentum-fractured/pull/72) | `5251848b5d222a03de5d6e9416f3f37b4be9e710`; implementation description; current runtime strings independently checked | Exact opening/objective and Foundry Rest Station implemented in inspected candidate; Storm Foundry remains room name |
| [PR54](https://github.com/cappy2yappy/momentum-fractured/pull/54) | `6cb4b6bb61f064c310d92a75b3fdcda4ab351398`; NARRATIVE_PLACEMENT | Covered Canal service passage and worker stair remain proposals; no new clan route or guaranteed global elevation |
| [Current world source](https://github.com/cappy2yappy/momentum-fractured/blob/c2170032d08ea55268313e0020676c743251deab/scripts/world.gd) | ROOM_NAMES, current_objective, can_enter, interact, pickup/save logic | E: 21 rooms, original gates, exact approved strings, letter collection |
| [Expansion source](https://github.com/cappy2yappy/momentum-fractured/blob/c2170032d08ea55268313e0020676c743251deab/scripts/world_expansion.gd) | EDGES, allowed, regional, LORE, NOTES, interact/update | E: 15 expansion links, seven existing notes, branch guards, persistent return |
| [Annex source](https://github.com/cappy2yappy/momentum-fractured/blob/c2170032d08ea55268313e0020676c743251deab/scripts/route_extension.gd) / [SkyWorks source](https://github.com/cappy2yappy/momentum-fractured/blob/c2170032d08ea55268313e0020676c743251deab/scripts/skyworks_region.gd) | Sigils, return seals, checkpoints, Keeper attunement | E: actual gating and milestones; no survivor scanner |

## Internal continuity — contains later-story spoilers
C/source-recovered: Kaze's compassionate rescues leave elemental traces that narrow the general vicinity. Mizuki's infiltration discloses the actual concealed refuge. Darkness attacks; Kaze's parents sacrifice themselves to save her. Do not replace this causality with a beacon, omniscient tracking or Kaze knowingly betraying the clan.

Preserve Kenji's absence on his investigation/search for Aria, surviving trainees, Aria's later nonlethal rescue, and the later forest sanctuary. Mizuki's masked-helper identity and betrayal are disclosed together later. No ST-05 prop, silhouette, signature, voice, emblem or corpse may identify any of these people. Do not reveal Darkness's hidden identity, ArcuTech connection, control methods or current enemies' allegiance. Parents' established deaths do not authorize their bodies or a flashback here.

## Findings and disposition
| Topic | Confirmed / observed | Must remain unresolved or proposed |
|---|---|---|
| Time and motivation | C: immediate aftermath; survival/search | No pre-attack relocation, revenge opening or time skip |
| R0 | E: safe start/checkpoint, Canal Haven | Emergency shelter interior/adjacency unresolved; no original-refuge devastation tableau |
| R11 | C exact label: Foundry Rest Station; E room: Storm Foundry | Not the lost refuge or future sanctuary; rest gives no guarantee of inhabitants |
| District damage | E: damaged structures | Attacker, date, and relation of each break to the refuge attack unknown |
| Records | E: before-dawn convoy, dry pumps before evacuation, bellkeeper route | No calendar, live deadline, proof of present clan escape or evacuation direction inferred from them |
| Lamps | E: existing tended-lamp note | Caretaker, recency and survivor identity unknown |
| Relays | E: access restoration, returns and sigils | No live distress reception, tracking response or survivor coordinates |
| Victims | User requests exploration of discoveries, not deaths | N: anonymous casualty only after separate approval of death, clan affiliation, visual treatment and placement |
| Recognition | No approved clan belongings in this district | N: communal mending style; no named ownership, invented relationship history or distinctive named-character costume |
| Canal / stair | E: Windstep Canal return; climb-gated R14↔R17 | PR54's ~320 px ceiling recommendation is superseded in PR68 by PR58's 180 px corridor contract. Fit current geometry; never use old advice to resize it. “Home” lighting must not imply R0 is the clan refuge |
| Bellroof / Pump Gallery | E: purposeful lower service walk; pump network and guarded shelf | Preserve recovery and hazard clarity. ST04's visual pilot is not approval of every R18 slab or new ST05 prop |

## Preservation decision
No existing text is silently rewritten. Existing source text is evidence, not a license to expand its meaning. New records will not acquire dates or named authors. New optional narration cannot overwrite mechanic instructions or alter reward, gate, combat, checkpoint, movement or transition behavior. This PR adds Markdown only; all proposed narrative flags remain design identifiers, absent from saves and runtime.
