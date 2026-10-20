# BUILD-07 PM report, Phase A (prep only)

Report id BUILD07. Branch ci/build07-wave3 on PR56 head 34f308ef. Model: Claude Sonnet 5.5. Environment: Linux cloud container, Godot 4.6.1 headless available, no export templates, so no local export.

## Done
- pins.json: variants w3-control (49ae3efe, tree 2a41ac47 asserted), w3-transition (PR64 775ef9ff), w3-level (PR63 a6e3de25), w3-art (PR62 61b32194), w3-combined (commit null until the coordinator sends it). Allowlists derived from the diff against 49ae3efe; ART-07 and protected gameplay files still refused; ART-08 paths forbidden in the pack for non-art variants.
- demos.json list `w3`: Fresh, Stair-Fullscreen, Stair-Return, Canal-Doorway, Canal-Return, Geometry-Test, Geometry-OpenTop, Reduced-Stair, Reduced-Canal. Isolated profiles and user-data as before. All launchers are marked PROVISIONAL.
- tools/pmpilot/w3_inventory.py: INVENTORY.json and INVENTORY.md per package (source SHA, every ART-08 clip with SHA256, label, alias, in-pack check, LD-05 switches and audited rooms, TR-08 flags, launcher args, export success vs native graphical validation NOT PERFORMED). Fails the build on unlabelled or approved clips, SHA mismatch, unlisted PNGs, ART-07, unexpected ART-08.
- build_package.py: variant tr08 flag, flags_no_tr08, list-valued fixture checks, Wave 3 README (states no clip is creator-approved, headless limits, ART-07 exclusion), GEOMETRY_TEST.txt from docs/ld05/room_audit.json, manifest validation_levels.
- Workflow: pull_request base list now includes ci/pm-pilot-comparisons; INVENTORY files uploaded. actionlint clean.
- tools/pmpilot/w3_prep_check.py local dry run.

## Local validation (real)
Detached worktrees at pinned SHAs: diff violations 0 for all four; inventory problems 0; ART-08 labels in PR62: candidate 11, stand-in 1 (door_turn_to_rear), unfinished 1 (door_turn_to_side, no PNG), 13 entries, 11 PNGs, door_walk_out is an alias; generated seeds equal TR08 fixtures (4 of 4) and pilot fixtures. Changed-file counts vs 49ae3efe: PR64 19, PR63 151, PR62 177. w3-combined plan is refused (no SHA), as designed.
Not run: any export, hosted candidate packaging, graphical capture.
request.json was set to a cheap preparation-smoke (w3-control, windows, quick) so the PR does not trigger candidate packaging; its result is not yet known.

## Observations
- PR63 adds 43 docs .import stubs and .uid files for existing scripts (allowed, docs never packed): owner may want to confirm intent. PR63 touches scripts/world.gd, world_expansion.gd, room_presentation.gd; the PR37 preservation waiver stays.
- TR-08 turns off with --pm-staged-stair; launcher flags handled per variant.
- docs/pm_pilot/build/README.md named in the brief does not exist in this branch; the package README now points to docs/wave3/build/README.md.
- TR08_DEMO_ARGS.md did not exist yet at last check.

## Needed for Phase B
1. Final candidate SHAs for Transition (real clip binding), Level, Art, and the combined Wave 3 branch SHA (and expected tree if known). Owner: coordinator.
2. Transition: confirm launcher args (DEMO_ARGS), especially R17 stair and Canal-Return start poses. Owner: Transition.
3. Level: confirm Geometry-Test start pose and room list. Owner: Level.
4. Whether to wire QA's wave 3 harness as informational. Owner: coordinator/QA.
5. Platforms (windows, macos, apple_silicon) and go for comparison runs.
