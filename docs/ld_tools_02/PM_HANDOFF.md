# LD-TOOLS-02 — PM handoff

**Branch:** `tools/ld-tools-02-room-creator`

**Base:** PR49 `00d74c36212e0493c242c25e15d4200ef094a49c`

**Status:** draft for review; default adoption and creator workflow acceptance pending. Do not merge.

## Delivered

- Reusable native PackedScene editing, templates, unique-shape duplication, foreground/background decorations and five metadata marker types.
- Normal Godot snapping, shape handles, exact Inspector coordinates, Delete, Save As and scene Undo/Redo.
- Versioned rectangle validation and a version 2 editable R18 example. The version 1 frozen scene remains byte-exact.
- R18-only, default-off native geometry integration with the existing game/controller, single terrain rendering, preserved support rectangles and existing world-owned gameplay systems.
- Explicit save-and-play workflow, native gameplay captures, creator guide, schema and reproducible headless/native QA runners.
- Save/reload and cross-process compatibility evidence; rollback requires no save conversion.

## Verification and open work

Read [QA](QA.md) for exact counts, retained failures and limits. Runtime regression success does not establish creator workflow comfort or a fresh campaign playthrough. Programmatic editor actions and native rendering are separate evidence from mouse-driven UI acceptance. The Mac was locked during the attempt to inspect the new dock; an updated dock screenshot and manual editing comfort check remain pending.

Issue43's purpose-driven R18 redesign, purpose map, encounter/story choices, finished environment art, slope/controller approval, other-room runtime adoption and human traversal acceptance are outside this tooling change. PR63's ground fixes, roof decision and GN-06 remain with their existing owners; this branch does not waive or fix them. PR49, PR63 and PR74 were not modified. No Wave 3 merge or second world runtime was introduced.

## Rollback

1. Close any room preview window. Launch the ordinary game without `--authored-r18`. The original generator supplies R18 and all existing saves remain readable.
2. To undo an editing experiment, reopen `tools/ld_tools_01/r18_layout.tscn` or discard the separate Save As copy. Earned campaign state is not stored in a room layout.
3. To remove integration in a later revert, remove the exact nine added lines in `scripts/world.gd` from this PR, then remove the new `tools/ld_tools_02`, `addons/room_creator` and documentation files. Preserve `tools/ld_tools_01` and its frozen scene. No graph, controller, save or asset rollback is needed.
4. Disable the Room Creator editor plugin if removing its source. This plugin preference is local and independent of the runtime flag.

## Next review

Creator: follow [the opening/editing/preview sequence](USER_GUIDE.md), confirm the workflow feels usable, and return to the frozen layout after the experiment. PM: review the narrow world hooks, contract errors, evidence and pending UI acceptance. Adopt onto a later combined candidate only through a separately tested integration branch. This draft does not authorize a default-on rollout.
