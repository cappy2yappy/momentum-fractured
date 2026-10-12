**LD-01 / 2026-10-12. Status: design proposal pending creator approval.**

Baseline: `codex/kaze-boundary-sprite-integration` at `0bf37e19ef3498386b133ed5d41e32788c2609d6`. Static source audit; no new engine playthrough or measured MV-01 values claimed. Coordinates are world pixels, origin top-left, y increases down.

## Classification

Source-proven semantic protection is separate from a predicted geometric bypass. A 30px-wide wall of height 250-300 is not a complete enclosure. Baseline full jump impulse is -900 with gravity 1800: ideal single jump rise is about 225px before discrete/collision effects; a second jump and wall-jump can defeat height-only reasoning. Maximum upgraded/momentum values are unmeasured. No claimed runtime exploit demonstration was performed.

| Barrier | Geometry / implementation | Assessment | Remedy proposal |
|---|---|---|---|
| R02 cistern_wind_cache | x2150, y600..850; letter (2300,830), no flag at pickup | High-confidence geometric risk; top/other-side approach possible with double jump; letter check is source-proven unguarded | Enclose alcove with floor/ceiling/sides and check cistern_wind_cache before collection; use Wind projectile as the unlock |
| R04 span_fire_cache | x1990, y810..1080 | Freestanding physical wall; no bound reward found; main progression does not require Fire here | Specify an optional Fire cache reward or return passage; gate its reward/edge semantically and roof the alcove. Do not invent an existing reward |
| R07 relay_electric_seal | x2000, y1000..1300; console (2200,1300) | Mandatory relay appears guarded only by height; console sets completed regardless of seal | Require relay_electric_seal at console; connect visible enclosing machinery to collision, preserve alternate exploration without console bypass |
| R09 terrace_fire_cache | x2110, y530..810 | Physical bypass risk, but fragment collection explicitly checks gate flag | Retain semantic protection; enclose cache and make denied collection legible |
| R09 terrace_return_relay | x360, y340..620 | Shortcut interaction checks flag from both rooms | Preserve flag check and clear portal cues; enclosure improves physical consistency |
| R10 skyworks_wind_intake | x2110, y530..810 | R10R11 checks opened flag; geometric bypass cannot alone unlock door | Preserve outgoing lock on every new incoming edge to Foundry; show physical shutter controlling door |
| R11 foundry_electric_relay | x2370, y460..760; exit at y1300 | Physical barrier is on upper platform while main exit is lower; outgoing edge checks flag | Preserve semantic guard; depict wired relay/shutter so lower locked exit has understandable cause |
| R01R02, R03R04, R05R06 | Windstep/Tether/Dash checked by can_enter | Protected on these explicit directed edges | New paths must not introduce bypass to their protected progression objectives without documented approval |
| R06R07 / R07R08 | boss_defeated / completed | Protected on ordinary forward edges; reverse open | New annex entry must require completed; no alternate early entry |
| R09R10 | relay_fragments.size �3 | Current three known pickups protected in part; future unrelated fragments could satisfy count | Use three named required sigils in future expansion integration, preserving current save flags |
| R12 attunement/return | keeper defeat for attunement; skyworks_restored for return | Semantic protection present | New expansion must not set these flags or bypass Keeper claim |

Fire currently controls a required SkyWorks sigil, not the main R04R05 edge. Make that causality visible. Windstep and Wind Kunai arrive together; physical Wind gate tests still require the matching projectile rather than possession of double jump.

## QA bypass matrix

For each barrier above, start closed with its required unlock flag false and all *other* legitimately reachable movement abilities enabled. Test (1) normal held/tap jump, (2) double jump at early/apex/late timing, (3) repeated wall jumps on each face, (4) ground and aerial dash both directions, (5) every reachable anchor and release angle, (6) each permanent upgrade tier, (7) maximum temporary momentum and combined maximum, (8) all alternate room arrivals and reverse approaches. Repeat with correct ability owned but seal unopened. Record actual positions, velocities, gate flag, reward flag and pending_room.

Expected: physical enclosure blocks traversal or intentional alternate geometry may pass, but reward/mandatory transition remains rejected until the correct gate flag. Wrong Wind/Fire/Electric projectile must not change flags; correct projectile opens once. Save/reload, leave/reenter, death and room rebuild preserve opened state and deny closed rewards. High-speed projectile/gate detection needs swept collision verification by developer/QA because current resolve_kunai uses sampled proximity; no LD controller edit.

Specific cases: put player at letter (2300,830) with Wind cache closed (currently expected to expose failure); put player at console (2200,1300) with Electric seal closed (currently expected to expose failure); place player at terrace Fire fragment with gate closed (must reject); place player on R10/R11 exit with corresponding seal closed (must reject). These semantic tests isolate logic from skill and should be followed by live traversal proofs.

No deliberate mandatory-gate sequence breaks are approved. Optional speed shelves in new rooms are documented alternate traversal, never shortcuts around elemental flags. Do not disable double jump, wall jump, dash or grapple to conceal a barrier flaw.

