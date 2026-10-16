# LD03 — collision and environmental art contract

Room14 only. Runtime geometry source: `scripts/bellroof_walk.gd`; baseline PR33. All coordinates are world pixels and top surfaces are feet coordinates.

| Treatment | Actual rectangles (x,y,width,height) | Collision / art constraint |
|---|---|---|
| West approach block |520,1220,180,80| Solid masonry to floor1300; no opaque art beyond its silhouette. |
| Roof-support piers |750,1110,120,190 and1030,1110,120,190| Solid masses below approved ART04 support; retain any narrow/non-standable gaps under existing one-way roofs. Do not imply a walkable floor there. |
| Log plinth |1200,1220,200,80| Solid; existing lore point1300,1220. Cabinet is recessed background art, not another collision wall. |
| East service bases |1780,1220,200,80 and2000,1120,180,180| Solid to1300. Caps communicate hop heights and stop edges. |
| West return |240,1200,240,40| One-way; keep ascent through its underside visually plausible. |
| Central return |1420,1120,240,40 and1480,980,240,40| One-way; maintain jump/head clearance and sightline to830 roof. |
| East return |2340,1200,260,40;2200,1040,280,40;2280,930,260,40| One-way; far-east catch must visibly reconnect to roofs. |

Existing Kaze/ART04 sprites, scales, pivots and approved support transform remain unchanged. Existing terrain atlas provides temporary masonry faces/caps. Background service wall, windows, signs, ties, lamp brackets and cabinet are noninteractive and deliberately recessed. Lamps must remain distinct from green tether anchors. The old large R14 building boxes and repeated V-shaped decorations no longer cover the lower play area.

Requested Art Mane follow-up: authored masonry end caps/plinths matching these silhouettes; a service-wall strip with recessed windows; west/roof/east wayfinding signs; a compact log cabinet; short transitions from the approved roof-support feet into the actual piers. Transparent layers with explicit world placement and a zoom1 game capture are required. Do not expand collision, close upward routes or add support art inside Kaze's landing/rope path without a reviewed geometry revision.

The new12 platform rectangles are both rendered and instantiated physically. Decorative background elements are not collision promises. This is a playable environment pilot using existing artwork, not a claim of a finished original tileset or completed character animation.
