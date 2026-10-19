# Narrative placement: Canal passage and the doorway/stair pilot

Story Agent (ST-PILOT), 2026-10-19. Doc only. Base PR51 `baedd67`. No canon rewritten, no code, collision, flag, gate or asset touched.
Sources: **S3** = PR #38 `553285f1` `docs/narrative/st03/*`; **S4** = PR #50 `6fc93d8e` `docs/narrative/st04/*` (read-only, not imported; S4 supersedes S3 where they differ). Repo citations are `file:line` at this base. `GDD.md` does not exist in this tree; nothing below cites it.

## 1. DOCUMENTED CANON

**Where it sits.** The 21-room district is the immediate post-attack area. Kaze (16) wakes alone after the attack, must survive and look for other survivors, not seek revenge (S4 CANON_DECISION_DELTA:21; S3 CANON_RECOVERY:21,26). The district is not the original refuge, not R11 "Foundry Refuge", not the later forest sanctuary (S4 DELTA:5-13). Whether R0 is or borders her emergency shelter is OPEN (S4 DELTA:13,31).

**Rooms and purpose (implemented fact + S3 matrix).**
- R0 Canal Haven: safe start, checkpoint at (220,1300) (`world.gd:589`); upper walkway platform x260-650, top y780 (`world.gd:173`). S3 matrix:7 "temporary foothold after catastrophe".
- R0 to R13 link: portal R0 (590,780) to R13 (120,1200), requires Windstep (`world_expansion.gd:11`). Windstep is earned in R1, so Kaze first sees the loft on a return to the Haven. R13 purpose: "compact return overlook above the Haven; first optional branch" (`EIGHT_ROOM_EXPANSION.md:16`); S3 matrix:20 "reframe starting area from above and make return legible". Stride I lives here.
- R13 to R14 (Windstep, `world_expansion.gd:12`). R14 Bellroof Walk: roof promenade, "steady stair route and faster hanging-bell line" (`EIGHT_ROOM_EXPANSION.md:55`); in-game note "Bellkeepers marked this roof as the convoy's quiet route" (`world_expansion.gd:41`, undated).
- R14 to R17 stair: R14 (1450,480) to R17 (1680,1300), requires climb (`world_expansion.gd:14`). R17: worker circulation, "Counterweights once carried workers above the storm line" (`world_expansion.gd:41`); S3 matrix:24 "connects roof and relay garden".
- Regions: R13, R14 are Canal Ward; R17 is Echo Works (`world_expansion.gd:7`). The stair crosses a region boundary.
- Pilot set: exactly `14:17` (`stair_up`, exit heading 1, arrival heading -1) and `17:14` (`stair_down`) (`embodied_transitions.gd:7-10`). `13:14`/`14:13` is only an opt-in `DEPTH_DEMO` (line 11). The stair's up/down labelling is "provisional presentation orientation ... not derived world altitude" (`docs/tr03/README.md:25`). Stairs need "coherent paired landing elevations"; lateral passages read as adjoining passages (S3 ENVIRONMENTAL_HANDOFF:31).
- Art state: only four held ART04 keys; no complete walk or ascent/descent cycles; do not mirror a rear entry into an exit (`docs/tr04/ART_REQUESTS_AND_NARRATIVE.md:20-22`). R13/R14 left exits need quay/roof wall returns drawn to x0 (same file:9); R17 stair needs a right wall return at x1800 (file:12).

**Canon guardrails for any copy or dressing.** Do not show clan devastation, dead parents, a named refugee or an interior shelter at R0 (S4 BEAT_MAP:14). Undated convoy/evacuation records are not proof of the attack (S4 DELTA:32; S3 CANON_RECOVERY:42). Do not reveal Mizuki's involvement, Aria's whereabouts or the ArcuTech link (S4 DELTA:25-29). Name note: the assignment's "Mikaze" and "Mentals" are, per S4 DELTA:9-10, verbal aliases of **Mizuki** (one character) and **elemental practitioners**; no new person or faction.

## 2. Best pilot: R14 to R17 stair (recommended)

Best supported by canon: it is the only doorway/stair pair with canon on both ends (bellkeepers' convoy route, worker counterweights), the only one in `PILOTS`, and a stair is the natural form for a service route between roof and tower. The R13/R14 doorway has no extra story weight and is already a lateral passage; keep it plain.

## 3. NEW PROPOSALS (not canon, need creator approval)

**Canal passage (R13 left to R0 walkway).**
- Read it as a covered masonry gallery through the mooring wall, a service passage a courier or bellkeeper would use between the quay walkway and the loft. Use arched brick/timber lining, tide stain low on the walls, a worn lintel. Canon gives no cave; if a "cave mouth" is wanted, make it a built culvert arch, not natural rock.
- Why enclosed: it is a threshold between "foothold" and "overlook"; enclosure makes the transition feel like entering a building, and supports the creator rule against wall-jumping above a mandatory exit. Solid wall returns to x0 on the R13 side.
- Ceiling: a roof slab or lintel only over the last approach to the door, not a blanket ceiling. Kaze's capsule is 60 tall and a full jump rises about 225 px (900 up speed, gravity 1800: `player.gd:72-73,167,171`), a wall jump about 215 px (line 173). Suggest the slab underside at least ~320 px above the walking surface, and Level to verify against live measurements (not measured here).
- Front-of-door mood: low warm lamp at the R0 end (home), cooler light and rope/mooring cleats at the R13 end. No crests, no new text.

**Stair (R14 end).** A narrow, old, maintained staff stair inside a roof-access structure: worn treads, rail polished by hands, a bellkeeper's convoy mark and a load plaque. It says "this was a quiet route for people carrying things", not "grand entrance". Doorframe must sit on the real threshold (E and pilot anchor), and the staged 2-3 s sequence is wipe-style and original (no borrowed Persona assets: `docs/level_design/alpha061/TR02_MIXED_TRANSITION_SPEC.md:21`). R17 end: stair emerges at the worker landing on the 1300 shelf, counterweight beams and numbered levels behind (S3 matrix:51), wall return at x1800.

## 4. Contradictions and ambiguities (flagged, not fixed)

1. R0 as shelter: S3 proposed it, S4 later marks it OPEN. Use S4.
2. Elevation: R13's left exit is at y1200 (lower landing) but the R0 portal is on the y780 walkway; treat the passage as a gallery and do not draw a ramp that implies continuous slope.
3. Stair altitude: "stair_up" 14 to 17 goes from R14's highest roof shelf (y480) to a mid-shaft R17 shelf (y1300 of a 2160 tall room). Orientation is provisional (`tr03/README.md:25`); do not draw sky or ground cues that fix absolute altitude.
4. Windstep gate: R13 is reached only after Windstep, so "reframe the start from above" works only on return, not on first arrival.
5. Stale docs: `CANONICAL_BASELINE.md:13` still says 13 rooms/4 regions; `docs/tr04/ART_REQUESTS_AND_NARRATIVE.md:24-27` "ruins escape" is proposal only and S4 supersedes with post-attack placement.
6. "Foundry Refuge" (R11) naming is under review (S4 DELTA:14); never use "refuge" for Canal spaces.
