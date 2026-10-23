# 21-room enhancement matrix (PROPOSED, nothing approved)

The creator's own blueprint markup is authoritative and overrides this document when received. Rows are a starting frame so specialists know where hooks could go. Nothing here is canon. Every "Candidate object", "Enemy opportunity" and "Hazard opportunity" is a PROPOSAL to be accepted, edited or dropped by the creator. Existing mechanics are from code at `c2170032`; narrative purpose is from ST-03 matrix and ST-04 handoff. Complexity: S (data only), M (data plus small script), L (new behavior or art plus tuning). "Approvals" lists creator decisions needed before integration. Art: sizes are not specified until approved.

Reading rules: R0 is not the exact emergency shelter (D5). Convoy and evacuation records stay undated (D6). No confirmed survivor location (D7). No new faction or ownership claims.

| Room | Existing mechanics and encounters | Narrative purpose (ST-03/04) | Candidate interactable objects | Encounter opportunities | Hazard opportunities | Story dependencies | Required art | Complexity | Creator approvals needed |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R0 Canal Haven | Start, checkpoint (220,1300), Haven loop door; no enemies | Temporary foothold after the attack | A worn quay plan (re-uses existing sightline); a tied-off mooring marker | None (keep safe start) | None | Before first leave; no shelter claim | 2 small props | S | D5 geography; object text |
| R1 Lantern Market | Guard x3 (one required for Windstep), Wind Kunai | Civilian life Kaze wants to protect | Evacuation board (no proof of current survivors); provision crates | Re-tune not needed; optional second behavior in the upper lane only | None | Windstep objective string is locked | Board, crates | S to M | Board text; whether enemy variety is wanted here |
| R2 Flooded Cistern | Water pits, Wind cache, one guard, convoy letter (lore) | Civil service routes under the street | Gauge marker; sluice wheel (examine only) | One new-behavior enemy near the cache approach | Optional drip over the narrowest ledge (telegraphed) | Convoy letter stays undated | Gauge, wheel, drip effect | M | Placement; no new letter |
| R3 Echo Shrine | Tether acquisition, checkpoint (1320,1300) | Elemental practice in maintained architecture | Worn inscription at the anchor | None (checkpoint room) | None | Inscription must not name a caretaker | Inscription decal | S | Text |
| R4 Broken Span | Gaps, two guards, Fire cache | Damage interrupts an older route; cause unknown | Repair-mark panel; worker record | Replace one guard with new behavior only if creator wants | Pulse hazard on the middle shelf (bypass kept) | Cause stays unknown | Marks, record | M | Whether pulse is wanted; text |
| R5 Ascent Tower | Vertical climb, two guards | Link of waterfront to relay district | Lift diagram plate | None | Telegraphed steam jet at a rest ledge (not on required launch) | None | Plate | S to M | Placement |
| R6 Tide Warden | Boss, required, gates Archive | Defended threshold, no new biography | Weathered control emblem, post-fight only | Boss unchanged | None | No ownership or allegiance claim | Emblem decal | S | Emblem meaning approval (protected) |
| R7 Relay Archive | Electric seal, restore relay, checkpoint (2200,1300) | First useful recovery widens the search | Routing record rack (examine) | None | None | Not a live survivor tracker | Rack | S | Text |
| R8 Relay Undercroft | Checkpoint, sigil, five exits, Intake Sentinel | Backtracking as a coherent service network | Connection diagram matching real exits | Existing sentinel only | Optional state-gated vent after Keeper return | Gate on `storm_keeper` cleared (read-only) | Diagram | M | Whether to add a post-Keeper change |
| R9 Signal Terrace | Two sigils, Fire cache, Terrace Sentinel, Electric return | Roof-watch and distribution links | Signal post panel | New behavior as a second enemy only after sigil | None | Sigils are access parts, not ancient relics | Panel | S to M | Text |
| R10 SkyWorks Approach | Wind intake gate | District as serviced extension | Maintenance label plate | None | None | Three-sigil entry rule stays | Plate | S | Text |
| R11 Storm Foundry | Electric relay, checkpoint "Foundry Rest Station" (1720,1300), service branch | Respite before a defended relay | Crew isolation record | None near checkpoint | State-gated furnace vent cycling only before relay opened | Name locked by ST-04 | Record, vent visual | M | Whether vent returns after relay opened |
| R12 Keeper Relay | Storm Keeper boss, attunement | Local milestone, circuit usable | Post-attunement light change (visual) | Boss unchanged | None | No Darkness-defeated claim | Light recolor | S | Visual |
| R13 Mooring Loft | Stride I, upper route, late Junction return | Reframe the start from above | Old courier-rest marker | None | None | Not a speed trial | Marker | S | Text |
| R14 Bellroof Walk | Roof route, bell line, stair branch, lower recovery | Quiet convoy route; recovery access | Optional observation stop (after LD geometry review) | One patrol on the upper lane only | None | Records stay old, no rescue promise | Marker, stop prop | M | LD review first |
| R15 Lower Sluice | Dry descent, Wind alcove, vent | Practical water infrastructure | Dry-pump ledger (existing note) | None | Vent exists; make it state aware only if desired | Ledger undated | None new | S | None unless changed |
| R16 Root Shrine | Checkpoint (420,1120), branching | Quiet evidence of care, unnamed | Tended lamp niche | None | None | Cannot name Mizuki or caretaker | Lamp glow | S | Text and tone |
| R17 Counterweight Spire | Long climb, rests, Wind shutter | Worker circulation | Load plaque | Optional one new-behavior enemy at a rest landing | Telegraphed pulse near the shutter | No moving machinery promise | Plaque | M | Placement |
| R18 Pump Gallery | Electric gate, guard, vent | Canal and conservatory as one system | Old routing plate beside newer repair | Existing guard only | Vent state-linked to the Electric isolator | PR47 dressing separate | Plate | M | D4 dressing direction |
| R19 Coil Service Hall | Fire service seal, side bay vent | Safety isolation as navigation | Isolation note (existing) | New behavior in the bypass lane | Vent exists | Motive and date open | Bracket marks | M | None unless changed |
| R20 Relay Junction | Switch opens Mooring loop, optional ledger | Reconnection of the district | Watch ledger (existing) | None | None | No clan-refuge teleport claim | None new | S | None |

## Counts for planning (proposal totals, not commitments)

- Candidate interactables: about 19 (all optional, none mandatory, none gating).
- New-behavior enemy placements: at most 6 across the world.
- New or state-aware hazards: at most 7, each with a bypass.
- Mandatory new reading: zero. Mandatory new gates: zero.

## Pacing intent

The 30-minute figure is the creator's report; no measurement exists in the repo. The plan adds depth through optional discovery (examine, side rooms), a handful of enemy variants that ask for different answers, and a few readable hazards. QA-07 builds a pacing harness (scripted route timings, optional-content completion time) so changes are measured. Targets are the creator's to set.
