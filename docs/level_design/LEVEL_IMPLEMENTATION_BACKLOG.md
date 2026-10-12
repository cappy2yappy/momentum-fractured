**LD-01 / 2026-10-12. Status: design proposal pending creator approval.**

Baseline: `codex/kaze-boundary-sprite-integration` at `0bf37e19ef3498386b133ed5d41e32788c2609d6`. Static source audit; no new engine playthrough or measured MV-01 values claimed. Coordinates are world pixels, origin top-left, y increases down.

## Approval checkpoint

Design-only deliverables are complete for review. Do not implement major level/collision changes until creator design approval. Existing gameplay remains untouched. Preserve work on design/alpha-0.6-world-expansion; never merge main or overwrite MV/art branches. Integration should consume this branch's docs, not replace a newer controller with this baseline.

| Order / priority | Task and owner | Depends on | Measurable acceptance |
|---|---|---|---|
| 1 / P0 | Approve baseline + design network (creator/PM) | this audit | 13 source rooms reconciled; 8 proposed IDs, fifth-region scope and unresolved mechanics approved explicitly |
| 2 / P0 | Measure movement and reconcile attach feedback (MV-01) | restored-size baseline | contract supplies reproducible max/base envelopes, range/LOS/selection; no physics adoption implied by LD |
| 3 / P0 | Close Cistern letter and Archive console logic bypasses (developer/QA) | bounded approval | closed gate refuses reward/console at exact target position; wrong element rejected; correct state persists |
| 4 / P0 | Authoritative named edge/arrival specification (developer) | approved network | all 21 nodes reachable legitimately; every reciprocal portal has safe explicit landing; no new path reaches Foundry before named sigils/Wind flag |
| 5 / P0 | Upgrade/map/save extension plan (developer/MV-01) | approved upgrade contract | old save retains all 13-room progress; new IDs initialized safely; map and portals read same graph; no format change by LD |
| 6 / P1 | Cosmetic room identities and supported anchor kit (art/developer) | approved object family | 13 rooms recognizable without title; art/collision separation; sprites unchanged; no support overlaps approved swing envelope |
| 7 / P1 | Blockout N13/N14 roof loop (developer) | graph + measured envelope | both routes reciprocal; R09 story protection; baseline lane and every miss recovery pass |
| 8 / P1 | Blockout N15/N16 underground loop (developer) | graph/checkpoint | dry ordinary traversal, shrine safe from both entrances, no new HP-loss pit required; completed protection on annex entry |
| 9 / P1 | Blockout N17 vertical room (developer) | per-room bounds/camera + MV envelope | camera follows all shelves; fail each swing lands no more than one designed stage below; no compulsory timed climb |
| 10 / P1 | Blockout N18/N19 machinery loop (developer) | hazard infrastructure + protected edges | steam/coil warnings precede damage; safe wait bays; Wind/Electric requirements survive every alternate entry |
| 11 / P1 | Blockout N20 junction and surface return (developer) | previous loops + switch persistence | opens only from designated junction with required regional flags; return survives reload/death and cannot skip story locks |
| 12 / P1 | Upgrade rewards and optional mastery lanes (MV/developer) | persistent tiers and baseline blockouts | ordinary route passes with zero optional upgrades/bonuses; optional reward thresholds measured, no guessed percentage |
| 13 / P1 | Enemy/hazard placement pass (combat/developer) | bounded guard lanes, approved blockouts | no guard chases beyond platform support; arrival landings safe; no hazard hides attack warnings or gate cues |
| 14 / P0 release gate | Full gate matrix, map/spawn/save and unseeded route QA | all integrated content | 21 rooms visited without seeded progression; each edge tested both ways; every closed barrier tested at max combined movement; new/old saves and every checkpoint/death pass |
| 15 / P1 release gate | Creative and performance playtest (creator/QA) | complete route | creator accepts movement/density/anchor placement; measured 60FPS on agreed reference hardware; record frame-time/load behavior and remaining issues |

## Implementation boundaries and regression evidence

Use existing approved_baseline, approved_combat_swing, annex_expansion, annex_traversal, save_compatibility, skyworks_progression and sprite_integration suites after implementation, updating room-count assertions deliberately while retaining original eight-room preservation checks. Baseline verification tools/verify_baseline.py must continue passing. Add meaningful new traversal/gate/graph tests rather than tests that merely assert an array has 21 entries. Engine playtest proves geometry; static docs do not.

Each implementation PR should record source SHA, changed rooms/edges, movement configuration, measured gate/swing results, before/after map, isolated-save test evidence and performance hardware. Stop and reconcile shared contract changes before retuning room layouts. Native full route acceptance remains pending in current baseline review and should not be relabeled passed by this design assignment.

## Scope exclusions

No controller/combat/save edits, active scene edits or generated art in LD-01. No promise of five new/total keeper fights, swimming or complete web campaign parity. Expansion adds connected exploration; those broader systems require separate approved implementation ownership.

