# LD03 — Bellroof Walk: the service walk below the roofs

Geometry baseline: PR33 `1835fcca272fd6a925b3d8ad4834fb225a6caef6`.

The old lower area was a flat2600px catch floor behind large decorative building rectangles. It had no destination of its own and a weak return structure. The redesign keeps that safe catch floor, but turns the space above it into a lower service route with a small exploration destination and three returns to the roofs. The upper route remains the faster way across.

## What the player can do

| Space | Purpose | Geometry / interaction |
|---|---|---|
| West landing and steps | Recover a missed roof jump and regain the Mooring landing | One-way step at240,1200, then the retained0-600 shelf at1100. |
| Roof support bays | Read the building as supported; hop through grounded service obstacles | Solid80px approach block and two120px-wide masonry piers. Grounded at1300, under the approved ART04 support. |
| Bellkeeper log court | Explore a lower destination and find an existing optional story item | Solid plinth at1200,1220; existing log moved from1700,700 to1300,1220. Same text and `lore_14` flag. |
| Central return | Resume the upper route without retracing the whole room | One-way landings at1420,1120 and1480,980, then the retained roof at830. |
| East service bays | A short grounded jump sequence and safe fall space | Solid80px approach block and180px pier; no damage or new ability requirement. |
| East return | Recover near the Terrace side without a long walk west | Steps at2340,1200;2200,1040;2280,930; then retained roof830. |
| Existing roofs / suspended anchors | Faster traversal, optional tether movement and the Spire branch | All PR33 platforms, anchors and three exits retained. |

Six solid masses and six one-way ledges are defined in `scripts/bellroof_walk.gd`. Those same rectangles feed platform collision and the existing material renderer. No invisible boundary, kill plane or decorative solid-column substitute is used. Original floor remains1300 and catches every failed lower jump. No new hazard or enemy was added.

The lower route is optional. It does not bypass the existing Windstep, relay or climb requirements. Its jumps were tested at400px/s with double-jump, dash, tether, Stride and momentum disabled. A leap may legitimately reach an overlapping higher roof landing; tests accept that recovery rather than disabling Kaze's mobility to force a particular step.

## Art and collision coordination

The approved ART04 roof support stays at its original transform. Masonry piers below it now run to the real recovery floor. New faces/caps reuse the existing terrain atlas. The old large opaque R14 background building blocks and repeated diagonal roof scribbles are suppressed in favor of a recessed service wall, log alcove and readable return signs. Background windows, ties and lamps remain visibly recessed and non-colliding. Authored final service-wall, pier-cap and sign textures are still an Art Mane follow-up; these are existing assets plus procedural dressing.

Solid masses retain platform layer1 and full collision. New40px steps retain the existing one-way collision/margin8 behavior. The controller, slopes, floor snap, jump/dash/tether timing and enemy combat were not changed. No new grapple object is implied by a decorative lamp.

## Existing saves

Some old seeded R14 profiles can name a floor position now inside a new mass. At startup/respawn, only a capsule overlapping one of the six new solids is staged upward at the same x, with head clearance against actual platform rectangles. Unobstructed R14 positions and every other room remain unchanged. Schema8, save identity, abilities, opened gates and lore flags are preserved. Existing `lore_14=true` remains collected; older uncollected saves can find the relocated log. Real normal checkpoints elsewhere are untouched.

## Captures

Both sides use the same PR33 game source foundation, ART04 preview, viewport and fixed camera framing. Court player feet differ because the new plinth is80px higher. Overview uses fitted0.46 zoom for inspection; the other views use ordinary zoom1. These are native Windows staged game captures, not paintings or human-playthrough proof. JPEG review copies are derived from native PNGs.

| View | Before | After |
|---|---|---|
| Entire room | [Before](evidence/overview_before.jpg) | [After](evidence/overview_after.jpg) |
| West recovery | [Before](evidence/west_before.jpg) | [After](evidence/west_after.jpg) |
| Log court / central return | [Before](evidence/court_before.jpg) | [After](evidence/court_after.jpg) |
| East recovery | [Before](evidence/east_before.jpg) | [After](evidence/east_after.jpg) |
