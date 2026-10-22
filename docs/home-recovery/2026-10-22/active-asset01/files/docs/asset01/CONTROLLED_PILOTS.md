# ASSET-01 controlled Alpha 0.7 pilots

2026-10-22. Follow-up to draft [#92](https://github.com/cappy2yappy/momentum-fractured/pull/92), head `2dd5c4f671a34424e65c8399013d3a44e50b1350`, tree `5421f0a8e4aed72f964fd89dc17e6ae5a05536b1`. The recovered local intake at `9439b1f7db804745463f3103a83981daae8e24b4` has that identical tree. Work is isolated on `codex/asset01-controlled-pilots`.

The creator's six-pack license attestation authorizes controlled pilots. [LICENSES.md](LICENSES.md) and the JSON/CSV register retain publisher evidence separately, including the two DarkCave downloads' incomplete independent terms. Every pilot has `production_placement_approved: false` and no campaign room/anchor. No merge, candidate rewrite, new canonical identity or raw-asset publication is requested.

## Review selections

[pilot-plan.json](pilot-plan.json) supplies exact inventory IDs and candidate component indices. These are proposed selections for review, not accepted sprites or room placements. Art Mane may reject any of them. Rates (12 FPS) and comparison scale (0.25) remain review assumptions; source timing is unknown.

| ID | Pack / selection | Purpose and owner decision |
| --- | --- | --- |
| FOL-01 | Plant Animations / BlueFlower1 | First decorative-motion pilot. Art reviews color/edge/loop; Level reviews foot registration and contrast. |
| FOL-02 | PlantsAnimated / Grass2 | Secondary grass motion. Retain DarkCave source-verification status; review silhouette stability. |
| SCN-01 | Mossy Assets / Hanging Plants / region 0 | Overhead organic framing. Component bounds are provisional; Art checks slicing; Level checks occlusion. |
| SCN-02 | CaveAssetsMaaot / BigRocks1 / region 1 | Backdrop depth study. Never infer a floor, platform or collider from the painted silhouette. |
| EN-VIS-01 | Slimes / SlimeGreen | Conditional companion comparison beside the existing EN-01 guard. Original guard, target, hit volume and action cues stay visible. No accepted slime combat skin. |
| HAZ-VIS-01 | Plant Animations / Plant 8 Poison | Conditional motion study beside the existing steam hazard. Its filename supplies no poison mechanics; original warning/danger/recovery cues stay visible. No accepted hazard skin. |
| REF-01 | BlueWizard Animations / walk | Reference-only. Weak style fit; no new character or Kaze substitution. Excluded from host labs. |

## Run locally without copying asset payloads

The six already-staged originals remain in the original local `asset01-staging` directory. The launcher checks all archive pins and all 1,106 extracted hashes against the tracked inventory before opening anything. It reads sources in place; no raw images, runtime atlases or editable projects enter Git or a build artifact.

```sh
python3 tools/asset01/review_pilot.py --stage /absolute/local/asset01-staging --check
python3 tools/asset01/review_pilot.py --stage /absolute/local/asset01-staging --pilot FOL-01
```

All seven IDs can open directly in the existing gallery. Its usual scale/filter/frame controls remain available. The Python launcher and the Godot selector reject missing sources and invalid IDs/regions.

Optional **host labs** use a separate clean checkout of the existing compliance draft [#87](https://github.com/cappy2yappy/momentum-fractured/pull/87), exact commit `5172db6898f3efc35b74f3c134293049165b9bf7`. Do not point this at Candidate 3. Import that scratch checkout with Godot 4.6.1 first. The launcher refuses a different commit or tracked modifications.

```sh
python3 tools/asset01/review_pilot.py --stage /absolute/local/asset01-staging --host-project /absolute/local/compliance-scratch --host-mode enemy
python3 tools/asset01/review_pilot.py --stage /absolute/local/asset01-staging --host-project /absolute/local/compliance-scratch --host-mode hazard
```

The external `host_pilot.gd` opens the existing guard lab or hazard course and adds only non-physics Node2D presentation children. It creates no CollisionObject/CollisionShape, changes no collider transform, and writes no story/save state. EN-01 is launched with `--test` and its existing demo save overrides; HAZ-01 retains its dedicated course save path. Existing lab controls still apply. These are the labs' existing authored surfaces, not new campaign room geometry. The pre-existing collapse prototype remains visible in the hazard course; this pilot does not adopt it or make it production-eligible.

`--host-check` positions the test player in the guard approach range for the enemy lab, runs eight seconds, and reports unchanged collision topology and observed real EN-01 or HAZ-01 states. `--capture /absolute/local/pilot.png` saves a native view locally; never upload asset-only captures. The companion visuals run independent review loops and read state for labels only. Attack timing, damage, hitboxes and hazard phases remain owned by existing gameplay code. Missing action poses remain an Art/Gameplay acceptance issue.

## Owner handoff and acceptance gates

**Art Mane:** prioritize FOL-01/FOL-02/SCN-01, then SCN-02. Record the chosen sequence/frame or component, palette/tint, filtering, crop/gutters, fixed pivot/offset, final display size and source-to-derivative hash lineage. Review beside approved Kaze at actual display scale. Check complete loops, alpha fringes, painted style and UI/actor readability. Slimes lack authored windup/strike/recovery/hurt/death; BlueWizard is reference only until a separate creator decision. Do not stretch ambient loops into combat telegraphs.

**Level / Level Masta:** choose an isolated fixture or a copied review-only view of a creator-marked existing room after Art selection. Organic Root Conservatory/Root Shrine context is a candidate, not a placement approval. Source geometry from that exact room revision; preserve all platform/collision polygons, gaps, recovery floors, doors/checkpoints/interactables, tether routes and room bounds. Decorations cannot imply false walkability, hide safe surfaces or cover attack cues. Provide collision-overlay and art-on/off captures, anchor/occlusion checks and a mixed-load frame/texture budget. A gallery benchmark is insufficient. No campaign placement is present in this draft.

**Gameplay:** use the existing interfaces at PR87's pin, retaining their underlying EN-01 [#83](https://github.com/cappy2yappy/momentum-fractured/pull/83) and HAZ-01 [#82](https://github.com/cappy2yappy/momentum-fractured/pull/82) lineage. Do not modify shared `world.gd`, player movement, StoryDirector, save schema or damage timing to accommodate art.

- EN-01: `Encounter.configure(host, entries)` validates against `host.platforms` and spawns through `world.spawn_enemy`. Add a presentation child after spawn; read `enemy.state`/facing/config without owning timers, damage, defeat or persistence. Preserve at least 0.5s windup, safe activation, existing recovery and target bounds. No new species/faction or completion event is implied by a slime.
- HAZ-01: `EnvironmentalHazard.phase_changed(phase)` and `enabled_changed(enabled)` are presentation seams. Existing `HazardPlacement`, phase clock, player damage/i-frames and recovery windows stay authoritative; warning remains at least 0.6s. Keep the default cue visible until replacement cues are approved. No new poison type or collision follows from pack names. Future real placements must pass `production_placement.gd` against surveyed platforms, recovery floors, 200px door approach, checkpoints and interactable exclusions; no collider-producing collapse adoption.
- Run relevant existing suites with disposable saves and native comparison. Verify pause/control lock, room exit/re-entry, interruption, reset, defeat and save/reload behavior when an actual state-driven skin is proposed. The current companion labs do not establish production combat-pose or campaign-placement acceptance.

**Creator / Claude integration owner:** review the concrete per-asset treatment, exact room/anchor, layer/occlusion, collision proof, source evidence and budget. Record explicit approval before production placements are implemented. Retain individual source verification and reconcile any conflicting terms before shipping. Publish a separate draft for any approved production use; no merge into Candidate 3 is authorized here.

Approval record fields: pilot ID; source archive/file hash; derivative hash and edit recipe; host commit; exact room/anchor/layer; Art decision; Level geometry/safety evidence; Gameplay interface/timing evidence; creator decision/date/reference; release-packaging decision. All are pending except source identity and authorization for isolated review.
