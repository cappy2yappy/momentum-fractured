# DEV-06 world implementation

21 zero-based rooms, IDs 0–20. Old chain 0–12 and both original returns remain. Expansion is implemented in `scripts/world_expansion.gd`; world bounds, saves, map graph and controller integration are in `scripts/world.gd`.

| ID | Room / size | Connections | Content |
|---|---|---|---|
|13|Mooring Loft / 1800×1440|0,14,20|Upper overlook, single-owned Stride I at (450,440), wind-bell anchor, bounded guard, dry recovery|
|14|Bellroof Walk / 2600×1440|13,9,17|Conventional rooftop lane, three optional bell anchors, guard, convoy lore|
|15|Lower Sluice / 2200×1440|2,16|Dry descent, Wind inspection alcove, two rings, warning spill/vent bay, recovery floor|
|16|Root Shrine / 2000×1440|15,8,18|Fifth region, checkpoint (420,1118), exploration lore, broad resting shelves|
|17|Counterweight Spire / 1800×2160|5,14,20|Multi-screen zigzag, intermediate catch shelves, three anchors, Wind shutter, upper lore|
|18|Pump Gallery / 2600×1440|16,8,19|Machinery silhouettes, Electric isolator, optional warning steam bay, three brackets, bounded guard|
|19|Coil Service Hall / 2400×1440|18,11,20|Industrial alternate route, Fire service seal, optional pulsing side bay, bounded guard|
|20|Relay Junction / 2200×1440|17,19,13|Upper/lower loop, persistent return switch, ledger lore, dry recovery and wind relics|

## Connections and safeguards

All 15 new links have explicit reciprocal feet-position endpoints and dedicated arrival pads. Both directions apply the same prerequisites. The implementation checks real seal flags rather than proximity or numeric pickup count.

- 0↔13 and 13↔14: Windstep.
- 14↔9, 15↔16, 16↔8, 16↔18, 18↔8: Archive restored.
- 14↔17 and 5↔17: Tether and Dash.
- 2↔15: Wind Kunai and the Cistern Wind seal opened.
- 17↔20: Archive restored, Tether/Dash and Spire Wind shutter opened.
- 18↔19: regional requirements plus Pump Electric isolator.
- 19↔11: Archive restored, all three named sigils, original SkyWorks Wind intake opened.
- 19↔20: those regional requirements plus Coil Fire service seal.
- 20↔13: those regional requirements plus the switch activated in Junction.

No expansion edge enters Keeper Relay directly or sets keeper/attunement flags. The Foundry Electric gate, Storm Keeper encounter and attunement retain their original protections.

## Traversal decisions

LD-01 coordinates were adjusted with intermediate ledges (rises ≤180 px, short horizontal gaps), generous pads, and a full dry recovery floor. One-way service ledges permit jumping upward through overlapping shelves; existing world geometry remains intact. Optional bell routes use stationary reusable anchor objects and the tested 80–440 radial eligibility. The upper Spire anchor was raised to expose it above the top landing. Mandatory routes do not require Stride or the temporary meter.

Designs are gameplay blockouts with reused backgrounds and geometric identity details. Moving counterweights and falling roof debris were optional proposals and are deferred; fixed rest platforms, guards and telegraphing vents implement the candidate's traversal/encounter roles. No water traversal is required.

## Persistence and controls

Save version 8 adds `expansion_flags` and extends visited data to 21 rooms. Versions 4,6,7 retain earned abilities, tier, old checkpoint positions and existing story state. Missing expansion state defaults locked/unexplored. Original application/save directory and save filename remain unchanged. Prior earned Archive/secret completion is not revoked when importing older saves.

Stride I appears only in Mooring Loft, applies walk420/run630, saves once and stays owned across transitions/death. It has placeholder scroll artwork. Momentum is disabled by default; launch with `--momentum-prototype` (or `--momentum`) to compare using the same save. It resets on room/death/checkpoint; the transient meter is not persisted. Full-meter run target667.8; inherited swing momentum remains unclamped. Movement meter's original gain/decay/damage/anti-farming behavior is covered by MV-01 regression tests.

Campaign route remains baseline-dependent; no claim of an unseeded full campaign playthrough is made.
