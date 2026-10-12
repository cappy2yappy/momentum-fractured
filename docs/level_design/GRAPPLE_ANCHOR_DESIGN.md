**LD-01 / 2026-10-12. Status: design proposal pending creator approval.**

Baseline: `codex/kaze-boundary-sprite-integration` at `0bf37e19ef3498386b133ed5d41e32788c2609d6`. Static source audit; no new engine playthrough or measured MV-01 values claimed. Coordinates are world pixels, origin top-left, y increases down.

## Verified mechanical mismatch

world.gd draws anchors as green circles/arcs/crosses and marks proximity at player.position distance <520. Actual selection initializes nearest distance to 401 and delegates to player.can_tether_anchor: airborne only, rope origin position+(0,-55), radial distance 80..400 inclusive, vertical offset �-35 and facing-relative horizontal offset -100..400. Thus the 520 visual prompt is not an attachment guarantee. No raycast/rope obstruction check appears in this approved foundation. The collision-aware swing integrator releases on player collision; that does not establish rope line-of-sight or rope wrapping. Do not port alternative-controller behavior silently.

Send mismatch and creator's longer-reach request to MV-01. LD proposes that feedback and actual target eligibility use one contract. Final range, selection, obstruction, retry, pumping and momentum rules remain pending MV-01 measurement and approval.

## Object family proposal

| Object | Natural support | Use | Shared interaction language |
|---|---|---|---|
| Wind bell | chain under shrine/roof beam | teaching and rooftop routes | central pale green ring, dark silhouette, visible attachment core |
| Tether ring | masonry eyelet or riveted beam bracket | canal ruins and industrial paths | same core/ring scale, directional support separate from rope |
| Ancient wind relic | supported shrine arch or plinth arm | optional mastery loops | same core; stone surround, restrained particles |

Shared core remains stable, decorative bell sway must not move the mechanical anchor. In-range, selected and blocked states must use shape/contrast as well as color. Art pass cannot change positions or add supporting collisions silently. Decorative supports stay above/outside the swept rope/player region. No purchase/generated assets required in this design phase.

## Existing sections: static candidates

Every anchor listed below is the existing attachment point; supports and recoveries are proposals. Attachment range is current 80..400 from tether_origin with directional constraints, never a final Alpha 0.6 distance. Test each anchor from both facings; not every drawn anchor is reachable from every approach.

### R03 ECHO SHRINE

- Anchors: (1090,650), (2170,610). Supports: Rings on shrine beams.
- Approach/landing: Practice from (920,830), then (2000,790).
- Clearance/obstruction: Upper platform lies 180px below each anchor; a long rope can collide with its top/edge. Teach short release before landing.
- Failure: same raised platforms or full lower floor; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R04 BROKEN SPAN

- Anchors: (780,720), (1370,610), (1940,650). Supports: Rings on broken bridge trusses.
- Approach/landing: From (300,1110) toward (930,1030), then (1530,890), then (2130,1080).
- Clearance/obstruction: First origin at platform y1110 is ~335px below anchor; limited horizontal range means attach near right edge, after jumping. Middle spacing 590px needs release/rejump rather than assuming anchor chaining.
- Failure: existing islands; propose continuous lower recovery ledges after approval; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R05 ASCENT TOWER

- Anchors: (820,650), (1900,520). Supports: Tower beam bells.
- Approach/landing: From (680,900) and (1760,700), climbing to side landings.
- Clearance/obstruction: Anchor/platform separations 250 and 180px; avoid support beams crossing short rope arcs.
- Failure: floor islands and lower platform ladder; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R07 RELAY ARCHIVE

- Anchors: (990,650), (1480,430). Supports: Archive rings.
- Approach/landing: From (820,870) through (1300,650).
- Clearance/obstruction: Upper lane may route over the Electric seal: gate semantics must guard console separately.
- Failure: full ground floor; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R08 RELAY UNDERCROFT

- Anchors: (750,660), (1220,500), (1800,570), (2250,530). Supports: Pipe-bracket rings.
- Approach/landing: Follow ledges y1110920740900830.
- Clearance/obstruction: Several platform-to-anchor height gaps exceed current reach before takeoff; stage reachable takeoff volumes, especially first anchor.
- Failure: full ground floor and checkpoint; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R09 SIGNAL TERRACE

- Anchors: (670,480), (1250,400), (1850,430). Supports: Signal-beam bells.
- Approach/landing: Upper ledges y620640810; lower alternate y1040/850.
- Clearance/obstruction: Return seal at x360 top340 intersects upper approach; keep its support distinct and do not let rope cross the seal.
- Failure: full floor and lower wide platform; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R10 SKYWORKS APPROACH

- Anchors: (620,560), (1220,460), (1880,480), (2320,420). Supports: Intake-frame rings.
- Approach/landing: Lower ledge (350,1040) to (920,830), upper (1400,620), exit (2240,760).
- Clearance/obstruction: First anchor is 425px above rope origin from y1040; attachment requires jump. Final anchor is near gate; do not imply swinging bypasses Wind lock.
- Failure: full floor, wide lower platform; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R11 STORM FOUNDRY

- Anchors: (700,560), (1300,460), (1940,460). Supports: Insulated overhead brackets.
- Approach/landing: From y980 to y780/560 then exit y760.
- Clearance/obstruction: First anchor similarly needs airborne ascent; third is close to platform x1500..1900 and can snag player trajectory near its edge.
- Failure: full floor and refuge; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

### R12 KEEPER RELAY

- Anchors: (760,790), (1230,590), (1870,730). Supports: Relay mast rings.
- Approach/landing: Raised perimeter y1070/850/1030; arena floor kept clear.
- Clearance/obstruction: Grappling may avoid ground pulse; verify boss combat independently; do not shift anchors into attack telegraph silhouettes.
- Failure: full arena floor; R04/R05 existing failed falls cost HP until an approved recovery change.
- Momentum: rewarded on high/fast line; current ordinary progression is flag-gated, not measured swing-threshold gated. No new mandatory momentum requirement.
- QA: overlay current eligibility volume at launch, sample rope/player arc through 360� where reachable, verify landing at low/high incoming speed and no accidental nearest-anchor selection. Reserve an empty swept volume equal to approved rope length plus player collider clearance; MV-01 must supply collider and swing-envelope measurements.

## New-room anchor plans

See EIGHT_ROOM_EXPANSION.md for exact proposed points, takeoff/landing and fall recovery. Default core lane uses isolated anchors with safe rest ledges; mastery lane may chain bells but must return to the core lane after a miss. No anchor behind a closed elemental bulkhead can be selected. Expected reach is the MV-01-approved attach radius; arrange takeoff envelopes within that range after measurements, rather than extending physics to fit an untested layout.

