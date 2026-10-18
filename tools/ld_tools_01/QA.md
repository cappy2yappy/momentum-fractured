# LD-TOOLS-01 QA

Native Windows work and captures: 2026-10-16; final package/publication preparation: 2026-10-18. Engine: official Godot `4.6.1.stable.official.14d19694e`; native renderer: OpenGL Compatibility, NVIDIA RTX 4070 Laptop GPU. Baseline: PR39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`, tree `89d6d6052e68fccaad0d0c696c12ba568d3bc124`, incorporating PR37. Work used a dedicated Git worktree; creator's active checkout was inspected read-only.

## Acceptance results

| Requirement | Status and evidence |
| --- | --- |
| Select and move platform visually | **PASS, actual editor mouse input.** Selected Platform_01/Surface; dragged interior. Saved center `(1270,1170)`. |
| Resize and choose solid / one-way | **PASS, editor + physics.** Dragged native right shape handle, saved `380x40`; toggled One Way Collision off. Both directions blocked by solid; upward passage and downward catch verified for one-way. |
| Place non-solid decoration | **PASS, actual editor mouse input.** Ctrl+D on Polygon2D pump housing, Move tool drag; saved second prop at `(1540,1100)`. Structural tests verify decoration branches have no physics bodies. |
| Save survives closing/reopening Godot | **PASS.** Saved separate `r_18_pump_gallery_layout.tscn`, closed pilot editor, reopened exact saved bytes in standalone project; inspector and screenshot show dimensions, position, solid checkbox and added prop. Scripted PackedScene edit/save/cache-bypass reload also passes. |
| Test scene runs authored layout | **PASS.** Both baseline and edited previews launched with native renderer; standalone F5 run and real mouse-dropped probe observed. |
| Source and visual collision agree | **PASS within laboratory scope.** Render rectangle reads the native collider Shape.size on the same node. 18 frozen rectangles match actual R18 builder. Native solid/one-way/disabled tests and slanted polygon edge probe pass. Editor handles/visuals and native screenshot inspected. |
| Existing 21-room gameplay unchanged | **PASS for source preservation/regressions.** Every one of 1,101 baseline tracked blobs byte-exact; 25 regression suites/1,607 assertions pass; no runtime imports of this tools folder. No new human full-campaign acceptance claimed. |
| Reversible migration documented | **PASS, design delivered.** MIGRATION.md provides default-off R18 adoption and rollback with no save conversion. No gameplay migration executed. |

## Executed checks

- `qa.gd`: **95 passes, 0 failures**. See [raw log](evidence/qa.log). Includes baseline freeze equivalence, physics flags, decoration/ladder exclusions, saved edit roundtrip, independent initial resources, solid/one-way/disabled behavior, slope edge collision, and adapter rejection of rotation/enabled slopes.
- Existing `run_tr05_qa.py`: **25 suites, 1,607 PASS lines, 0 failures, 0 script errors**, all exit 0. [Per-suite results](evidence/regressions.json). Four suites explicitly use the runner's `--tr05-legacy` mode; they verify historical comparisons, not current transition behavior alone.
- `verify_baseline.py`: **0 failures** (approved character/art preservation).
- `verify_tr05_preservation.py`: **0 failures** (PR37 protected scripts, assets and policy functions).
- `verify_preservation.py`: **1,101/1,101 original tracked blobs exact**. [Report](evidence/preservation.json). Repeat before committing; compare bytes, not only a whitespace-normalized diff.
- Root project import: no parse/load/script errors. Native frozen/edited laboratory launches exit 0. [Import log](evidence/pilot-import.log), [frozen run](evidence/preview.log), [edited run](evidence/edited-preview.log).

The native editor screenshot is evidence of mouse editing and persistence; it is not a gameplay route review. The geometry preview uses physics probes, not a modified Kaze controller. The ladder remains a marker. Slope contact is verified with a native probe; player slope traversal is not approved or certified.

## Diagnostics and limits

The first headless extraction without an isolated writable APPDATA crashed before engine initialization. Setting APPDATA to the task's disposable profile resolved it; the freeze and tests then completed. All game-bearing tests use `-- --test` and disposable data.

The full project's editor import logs inherited exit-time CanvasItem, dummy texture, text/font RID and ObjectDB leaks. No pilot script parse errors were reported. Opening the full project's existing MetSys editor caused automatic theme-resource reserialization; those generated edits were restored to the pinned bytes and verified. The standalone deliverable has no autoloads/plugins and avoids that workflow.

The initial standalone reopen omitted `.gd.uid` sidecars, producing two UID-fallback warnings while correctly loading by path. The packager was corrected to include source UID sidecars. Final standalone import/launch evidence is recorded in `evidence/package-check.json`; do not substitute the initial warning-bearing reopen for that package check.

Creator workflow comfort, real Kaze route/recovery playtest, slope movement behavior, finished art, Mac/editor UI validation, and issue43's purpose-driven room redesign remain **PENDING**. No runtime MCP dependency, plugin update, engine update, main edit or merge occurred. Hosted CI is not claimed by this local QA report.

## Creator interaction still requested

In the standalone project, move/resize one platform, toggle one-way, place a prop, save/reopen, and run the preview. Confirm the tool feels usable. Try the optional disabled slope only in this laboratory. Report any confusing selection or collision display. Gameplay adoption and route redesign require their own approval and QA.
