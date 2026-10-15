# Art Mane TR-03 — verified recovery checkpoint

1. Fetch art/alpha-0.6.1-tr03-entry-poses; inspect PR#25 actual HEAD, CONTEXT.md, SESSION_LOG.md, next-task.md and the complete PM report. Do not trust a historical SHA as live HEAD.
2. Existing completed requirements/storyboards are published at0d96f93 and45ed20b; the final report/continuity follows. Inspect docs/art/tr03/previews before any new media creation. Never regenerate ART-01 or replace accepted Kaze art by default.
3. Next: PM/creator reviews storyboards; Level consumes LANE_B_IMPLEMENTATION_HANDOFF.md and transition_art_contract.json and chooses explicit door/stair metadata. No final new sprite art is approved yet. New frame production requires creator storyboard/compatibility review.
4. Reproduce technical boards/contact/audit with official Godot4.6.1 graphical GL renderer and disposable APPDATA: --path . --script res://docs/art/tr03/render_review.gd -- --test. This fixture is not gameplay. Aseprite batch probes failed; do not assert editor authoring until outputs are verified.
5. Preserve load clock, scale, collisions, graph, endpoints, gates, physics, saves and current comparison branches. No merge. Record source versus gameplay/export QA accurately.

Inherited untracked metadata at session start, outside this task's commits:

- scripts/grapple_anchor.gd.uid
- scripts/momentum_profile.gd.uid
- tests/capture_dev06.gd.uid
- tests/expansion_gates_save.gd.uid
- tests/expansion_traversal.gd.uid
- tests/fixtures/player_alpha052.gd.uid
- tests/measure_sprite_size.gd.uid
- tests/movement_momentum.gd.uid
- tests/world_expansion.gd.uid
