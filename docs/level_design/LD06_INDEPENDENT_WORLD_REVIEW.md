# LD-06 — Independent world-design review

Reviewer: Level Masta / Codex. Date: 2026-10-19. Documentation only; no merge.

## Judgment and evidence boundary

The world has a useful progression spine, loops, meaningful unlocks and real optional destinations. Its principal design weakness is inconsistent communication of that structure: recovery often reads as abandoned floor, interchangeable shelves compete with destinations, and illustrated doors do not consistently describe physical openings. Preserve movement and purposeful air space. Improve route hierarchy and local architecture before adding more platforms or rewards.

This is an independent **source and existing-image review**, not a new engine playtest or full navigation-volume proof. No Godot executable was available on PATH. No new behavioral pass count is claimed. Existing QA results below are attributed evidence, not rerun results. Player perception, sustained performance, controller input and fresh-save campaign completion remain unverified here.

Primary playable inspection: PR51 `baedd6786ad4bee2123ea872b437bbb98e6d2721`, which includes PR39 and its PR37/PR33 geometry lineage. Other candidate branches were inspected separately; they are not a single integrated current build.

| Reference | Pinned head | Use in review |
|---|---|---|
| PR33 | `1835fcca272fd6a925b3d8ad4834fb225a6caef6` | Perimeter support repair and original geometry audit |
| PR37 | `b950373efb5c4621d7da7e0be1506db048e3043a` | Bellroof solids, recovery steps and existing-log court |
| PR39 | `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` | Playable automatic-passage baseline |
| PR47 | `4b11bef0b3727f1647029cb04568b96a2e09c9fd` | R18 handoff, layout conventions and native-after overview image |
| PR49 | `00d74c36212e0493c242c25e15d4200ef094a49c` | Isolated authoring pilot/migration boundary |
| PR51 | `baedd6786ad4bee2123ea872b437bbb98e6d2721` | Source under review; supported passage recovery |
| PR58 | `0656766d8fe13c702a4808b1d25ddd0855d8922c` | Canal enclosure, contract and exit-audit evidence |
| PR59 | `c44f2b8163867e211f7d2297d6dcfad26c36abe7` | Independent test scope and reported limitations |
| PR60 | `1cf2693a40dd67fe7fe03bc3ae05689e22b4caea` | Pilot composition/status and unresolved decisions |

Implementation inspected: `scripts/world.gd` (construction, interactions, progression, recovery), `world_expansion.gd` (edges, generated routes, gates, lore), `route_extension.gd`, `skyworks_region.gd`, `level_geometry.gd`, `bellroof_walk.gd`, and movement/jump handling in `player.gd`. Supporting historical audits were compared against current conditions rather than adopted as findings.

## Classification rules

| Class | Test | Treatment |
|---|---|---|
| Legitimate exploration | Reachable route reveals a connection, view, encounter or alternate traversal without defeating prerequisites | Keep and make its role understandable |
| Intentional secret | Concealed but discoverable destination has an authored reward and valid return | Keep concealment; signal discoverability locally |
| Optional challenge | More demanding movement provides speed, lore or alternate access | Preserve conventional route and challenge clearance |
| Recoverable mistake | Fall leads to safe footing and a readable return | Measure return burden; do not equate a catch floor with good recovery |
| Unintended geometry escape | Player leaves authored space with no intended destination or route | Repair the specific visible boundary; preserve nearby valid exploration |
| Progression-breaking bypass | Player obtains protected reward, flag or destination with prerequisites false | Require flag/state and traversal evidence; physical gate evasion alone is insufficient |

No newly demonstrated progression-breaking bypass is established by this review. That is not certification that none exists.

## Room-by-room assessment

Coordinates are world pixels, +Y downward; anchors and route air are not filler. Priorities refer to issues below, not permission to redesign every room.

| Room | Intentional route and exploration value | Design assessment / specific recommendation | Class / priority |
|---|---|---|---|
| R0 Canal Haven | Ground shrine/market departure; elevated link at (590,780) to R13 | Preserve shrine-to-ground exit clarity and jump launch space. Give elevated depth entrance a recessed facade distinct from ordinary lateral exits; show the roof branch from the approach without making it the apparent fresh-game objective. | Legitimate branch; P2 |
| R1 Lantern Market | Required sentinel and Windstep on lower route; upper combat shelves | Reward at (1580,1260) follows guard defeat. Use sightline and light from the defeated encounter toward the pickup, then toward east exit. Do not add solids to combat/braking space. | Main progression; P2 |
| R2 Flooded Cistern | Dry islands over water, Wind cache, lower sluice branch | Keep intentional water gaps. Cache at (2300,830) needs a credible alcove around seal x2150 rather than a freestanding bar. Distinguish branch door at (470,1120) from a safe landing. Current cache reward explicitly checks its gate. | Challenge/secret; P1 physical gate clarity, P2 cues |
| R3 Echo Shrine | Lower checkpoint/tether milestone; anchored route; Terrace return | Contrast shrine destination with overhead swing clearance. Recess the return entrance near (2250,790); show its locked state before the player commits to a detour. Preserve arcs at anchors (1090,650)/(2170,610). | Main milestone/shortcut; P2 |
| R4 Broken Span | Fire acquisition, broken crossing and grapple gaps | Fire pickup (1080,990) has purpose; gate `span_fire_cache` at (1990,1080) has no associated reward or explicit gated edge in inspected code. Decide whether it marks an optional future cache or remove its promise in a separate authorized pass; do not invent a current reward. Preserve water and swing route. | Misleading optional barrier; P2 |
| R5 Ascent Tower | Dash/Electric lower milestones; elevated exits and Spire branch | Show lower pickups before emphasizing upper departure. Connect shelf silhouettes into tower architecture without blocking wall jumps or anchors (820,650)/(1900,520). Branch at (2240,930) needs a distinct background entrance treatment. | Main progression/vertical exploration; P2 |
| R6 Tide Warden | Broad required arena with recovery/combat spacing | Retain arena footprint. Door to R7 has drawn feet y1090 against shelf top y1110: align door, trigger/support contract in one focused change. Do not insert columns into the boss lane merely to ground scenery. | Readability mismatch; P1 exit contract |
| R7 Relay Archive | Electric seal then console at (2200,1300) | Current console refuses completion when seal closed. Depict enclosed archive machinery and an obvious powered connection; jumping over bars must not suggest the console is available. Keep anchor routes and lower approach. | Protected objective; P1 physical gate clarity |
| R8 Relay Undercroft | Shrine, named sigil, multiple return/service entrances | Junction has competing destinations. Use distinct architecture for shrine, locked Keeper return, Root and Pump service doors. Pump door at (1090,920) spans beyond shelf ending x1110; provide full visible threshold support or relocate doorway/contract together. Preserve shrine access and upper sigil. | Junction/door overhang; P1 exit, P2 hierarchy |
| R9 Signal Terrace | Two named sigils, Fire cache, Echo return and Skyworks departure | East catch floor is recovery, not a secret. Lead missed jumps toward shelf x380..1180/y1040 with a service-return landmark. Door drawn at (2440,830) sits below actual shelf y810; fix contract rather than hiding offset with trim. Retain semantic Fire cache protection. | Recovery/locked secret; P1 exit, P2 return |
| R10 Skyworks Approach | Three-sigil entry, Wind intake seal, grapple route | Lower x350..1150/y1040 shelf is recovery target; far-east floor lacks a strong return cue. Mark a service route toward it before adding steps. Show intake seal x2110 controlling the east departure; do not imply the upper bar alone blocks access. | Recovery/protected progression; P1 gate clarity, P2 return |
| R11 Storm Foundry | Lower encounter/refuge; elevated Electric relay controls lower exit | Relay (2370,760) and departure (2440,1300) are separated vertically. A visible conduit/shutter relationship can explain the lock without new collision. Keep lower refuge and encounter spacing; distinguish R19 service entrance (890,980). | Cause/effect readability; P1 gate clarity |
| R12 Keeper Relay | Boss arena, post-boss attunement, Undercroft return | Keep arena and optional elevated routing. Make attunement at (2220,1300) visually dormant until Keeper defeat, then the obvious next action. Do not confuse the elevated return with early main progression. | Main milestone/shortcut; P2 |
| R13 Mooring Loft | Vertical junction, Stride at (450,440), roof route | Optional speed reward justifies ascent. PR58 encloses west passage (120,1200), but exterior gatehouse face/right boundary remain escape candidates. Preserve upper branch at (900,400), grapple (900,690), and east route (1680,560). Design local boundary silhouettes around those real routes, not a horizontal lid across them. | Legitimate climb + unintended exterior escape; P1 |
| R14 Bellroof Walk | Upper traversal; lower log court and three returns | Best current reference for deliberate recovery: six masses, six steps, existing log at (1300,1220). Retain west/central/east returns and overhead grapple paths. Judge normal-zoom readability of signs/lamps and reward visibility; do not repeat the redesign or add loot merely because floor remains open. | Exploration/challenge/recovery; P2 acceptance |
| R15 Lower Sluice | Wind-gated ledger, dry descent, Root passage | Return from western catch floor to east x1800/y1120 is long. First cue the ascent with a service arch/lamps; if still burdensome, LD-05 can evaluate one local return near the existing descent. Keep vent at (650,1210) visible and dry route intact. Ledger checks Wind gate. | Recoverable mistake/optional lore; P2 |
| R16 Root Shrine | Checkpoint at (420,1120); junction to R8/R18 | Existing west shelf x80..580/y1120 gives recovery destination. Differentiate upper Pump door (1000,430), east Undercroft exit and shrine through root-supported architecture. Keep central ascent and open anchor lanes. | Junction/exploration; P2 |
| R17 Counterweight Spire | Tall climb with intermediate landings; R5/R14/R20 connections | Vertical space is purposeful, including recovery to y1900 and anchors through y250. Counterweight shafts should explain climb direction and landings. Frame the shutter at (1430,420) and distinguish the stair landing (1680,1300). No blanket ceiling across upper tether exploration. | Vertical challenge; P1 boundary review, P2 cues |
| R18 Pump Gallery | Electric service route, guard, machinery lore and Undercroft return | Five authored shelves plus ten generated slabs blur primary/optional paths. Resolve stacked/near-overlapping caps before fitting final art. Use one obvious conventional lane, retain grapple express route, and distinguish recovery shelf (1040,1180) from undercroft threshold (1200,1180). Far-east floor needs return guidance. LD-05 owns changes. | Route hierarchy/recovery; P1 pilot |
| R19 Coil Service Hall | Fire service branch, Foundry loop, lore | Repeated x430..2150 shelves weaken landmark identity; far-west catch floor has long return. Give the return a service-stair silhouette and coil gate a physically comprehensible housing. Preserve guard lane x700..1200/y980 and optional upper routing. | Challenge/recovery/loop; P2 |
| R20 Relay Junction | Persistent Mooring return and loop closure | Gate needs regional progress and explicit junction activation at (600,520). Present activation before return destination; lower recovery should point to right x1400..2150/y1120 shelf. Keep upper garden destination distinct from catch floor and retain both regional approaches. | Rewarding shortcut/recovery; P2 |

## Prioritized issues and acceptance

P0 means demonstrated broken progression/irrecoverable state; none newly proven here. P1 is route integrity or materially misleading physical affordance; P2 is navigation/recovery quality. Priorities do not imply that all findings reproduce on every candidate.

| ID | Priority / evidence | Recommendation and completion criterion |
|---|---|---|
| LD06-01 | P1; source has side walls to y0 but no top; PR58 exit probe reports above-room escapes | LD-05 should classify each boundary segment as authored exploration or exterior escape. For affected passages, extend visible local masonry/overhang/return geometry into a coherent boundary while retaining designated ascent corridors. Test wall-jump, dash and grapple from both inside and outside each enclosure. If the player can still stand beyond authored space, record it as residual. No movement clamp or invisible blanket wall. |
| LD06-02 | P1; source offsets and PR58 audit | Resolve R6 east (+20px), R9 east (-20px) and R8 Pump threshold (28px visual overhang). Door feet, support, trigger and reciprocal arrival must be one reviewed contract; test walk, stop, reverse, jump, dash, arrival and locked state. Do not globally move all triggers based on these three cases. |
| LD06-03 | P1; `SHELVES` interpolation plus PR47 overlap findings | R18 pilot: replace redundant generated slab relationships with intentionally authored supports under LD-05. Preserve endpoints, guard footprint, anchor access and isolator state. Each route segment must have a stated purpose and independent return; nearby slabs must look traversable in the same way they collide. Do not adopt PR49's edited sample as a finished redesign. |
| LD06-04 | P1; gate geometry is narrow freestanding rectangles, while rewards/exits have state guards | Add visible housing/cause-and-effect for R2/R7/R9/R10/R11/R18/R19 gates. Optional acrobatic bypass of the physical bar must not look like an unlocked objective. Verify false gate states reject protected reward/edge; correct element opens once and persists after reload. Keep accepted ability routes. |
| LD06-05 | P2; authored lower-floor routes and repeated shelf language | Review R9/10/13/15/18/19/20 recoveries with current minimum legitimate kit. Measure time from representative landing to rejoining chosen route, including navigation mistakes. Improve landmark/light/architecture first; add a local return only where actual play shows excessive travel. No arbitrary time threshold is claimed measured here. |
| LD06-06 | P2; R4 gate has no bound optional payoff in inspected logic | Decide the gate's design contract: discoverable optional reward, meaningful shortcut, or future route visibly unavailable. Creator/Story must approve any new reward/canon. Stop presenting an empty barrier as a completed secret. |
| LD06-07 | P2; junction/goal hierarchy in R8/11/16/20 | Give main departure, return shortcut and optional doorway different architectural cues; show locked cause before commitment. Acceptance: fresh tester identifies destination/lock/return at gameplay zoom without relying solely on atlas labels. |

## Movement bypass and progression findings

Do not carry forward obsolete claims from `ABILITY_GATE_AUDIT.md`: the current R2 letter checks `cistern_wind_cache`, R7 console checks `relay_electric_seal`, and `has_required_sigils()` checks the three named IDs. Those historical unguarded-reward findings are no longer current.

`Expansion.allowed()` guards both directions of listed links. `regional()` requires Archive completion, named sigils and Wind intake. R18→R19 adds Electric isolator; R19→R20 adds Fire service. R17→R20 can reach Junction before regional completion, but activation of the Mooring return requires `regional()`; R20→R19 also remains guarded. This is alternate access with downstream locks, not a source-proven bypass. R19→R11 does not itself require the Foundry Electric relay, but R11→R12 still does. Preserve these distinctions when assessing a clever climb.

Future QA should test with each missing prerequisite independently, all other legitimately reachable movement abilities enabled, both approach directions, correct element owned but gate unopened, and after save/reload/death. Record source room, route, position, target, gate/reward flags and resulting room. Teleport tests can isolate semantic guards but do not prove traversal accessibility. Upgraded seeded saves cannot establish fresh-game progression integrity.

## Collision / architecture contract and R18 art review

The inspected PR47 native-after overview makes Pump Gallery substantially more coherent: machinery supports its identity, arch voids expose traversable space, lanterns frame destinations and pale caps identify landings. It also shows the residual problem: closely stacked bright cap lines form a staircase-like visual band that competes with the actual route, while large solid-looking piers can imply blocked space even though the dressing is non-colliding. These are observations from an existing overview image, not a new gameplay-scale acceptance test.

1. Use a shared coordinate source for visible walking edge and collider. Preserve world feet coordinates; sprite transparent bounds are not collision bounds. R13+ 40px shelves become one-way under `add_platform`; a new authoring scene must retain explicit flags instead of inferring solidity from an illustration.
2. Separate one-way catwalk language from solid masonry. Beams/thin caps can read as pass-through ledges; deep masses should agree with physical obstruction. PR47 uses similar cap language for both, so legibility needs a normal-zoom comparison. Background piers should remain recessed/desaturated and must not appear to close a traversable opening.
3. Keep tether anchors and swing arcs, head clearance, guard patrol, doors, lore and vent telegraphs free of foreground occlusion. PR47's clearance checks are useful but do not prove every dynamic arc. Keep the lower void visibly open rather than paint it as solid fill.
4. Prioritize isolator frame at (2370,760), a distinct undercroft recess at (1200,1180), and a readable return from lower east floor. A cracked outlet can explain the existing vent bay; this is dressing, not a proposal for another hazard.
5. Refit art after LD-05 freezes geometry: retire obsolete `interim_catwalk` pieces, regenerate collider registration, then recapture west arrival, guard, lore, lower bay and east gate at native gameplay zoom. Whole-room overview alone cannot establish sightline clarity.
6. PR49 is a disconnected editor laboratory: its frozen scene omits gate/enemy/anchor/hazard/progression systems. Keep runtime collision and support-query data synchronized if adopted later; do not instantiate native bodies and also call `add_platform` for the same geometry. Slopes and ladder markers are not approved mechanics.
7. PR47 JSON export inclusion remains a packaging concern; source-only art validation cannot establish exported visibility. Test actual exported resources after any adoption.

## PM handoff / scope boundary

Recommendation: retain PR51 as the inspected reliability base; assess PR58 as a separate Canal candidate. LD-05 remains sole geometry implementation owner. This report assigns no new implementation and changes no room, controller, gate, save, asset or branch owned by that work.

Suggested order: (1) LD-05 reconcile boundary classification and three concrete threshold mismatches; (2) finish one R18 route/architecture pilot; (3) independent QA verify semantic gates and real-input recovery; (4) Art refit approved collision; (5) creator assess fresh route understanding, then extend the successful pattern to recovery rooms. Preserve R14 as the comparative recovery example, not a template to stamp across every biome.

PM should request from each implementation candidate: exact SHA, room/coordinate issue IDs, before/after gameplay-scale captures, route-purpose notes, collision diff, fresh/minimum-kit and upgraded traversal evidence, save/death/arrival results and honest residuals. Review gate state separately from physical bar traversal. No P0 closure or full-campaign acceptance follows from this document.

Creator decisions: whether R4's Fire barrier represents a secret or a future route; which exterior high spaces should become authored destinations versus visible local boundaries. These choices need no movement change. A global ceiling or wall-jump limit is not the only response to escape evidence and is not recommended here.

Deliverable validation: documentation-only diff; all 21 rooms represented once; reference SHAs pinned; no merge requested. Behavioral QA remains with the independent QA lane. No background continuation is implied.
