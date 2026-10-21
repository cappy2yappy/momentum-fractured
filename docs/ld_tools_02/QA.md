# LD-TOOLS-02 QA — 2026-10-21

**Source:** PR49 `00d74c36212e0493c242c25e15d4200ef094a49c`, with this branch's narrow R18 hooks. **Engine:** official Godot 4.6.1 `14d19694e`. **Platform:** native macOS / Apple M4. Rendered checks use OpenGL 4.1 Metal compatibility at 1280×720. Unique disposable Godot profiles protect personal saves. No movement/controller edits or save-schema edits.

| Check | Result |
|---|---|
| 25 stock source suites, feature off | 1,607 passes / 0 failures |
| Same 25 stock suites, feature on | 1,607 passes / 0 failures |
| Original LD-TOOLS-01 laboratory suite | 95 passes / 0 failures |
| Room Creator gameplay/format/roundtrip suite, both states | 163 passes / 0 failures |
| Negative contract / live fallback checks | 12 passes / 0 failures |
| Cross-process save preparation, reload on, reload off | 11 passes / 0 failures |
| Complete headless matrix | **56 invocations, 3,495 passes / 0 failures / 0 script errors** |
| Native rendered Room Creator + contract + save fixtures | **5 invocations, 186 passes / 0 failures / 0 script errors** |
| Real EditorPlugin + EditorUndoRedoManager, headless editor | 14 passes / 0 failures / 0 script errors; thumbnail diagnostic below |
| Native rendered editor plugin checks | 14 passes / 0 failures / 0 script errors; engine diagnostics retained |
| Approved artwork/controller baseline verifier | 0 failures |
| Exact inherited-tree + reverse-hook verifier | 1,136 inherited files byte-exact; world.gd differs only by nine explicit added lines; 0 failures |
| Historical TR05 preservation checker | **1 expected incompatibility: add_platform exact-function lock**; see below |
| Native gameplay captures | generated, unchanged authored and edited authored R18, 1280×720 |
| Mouse-driven new dock verification | **Pending — computer-use tool reports Mac locked** |
| Human traversal / fresh campaign / creator workflow acceptance | **Not run** |

The four historical transition suites explicitly use their stock runner's `--tr05-legacy` mode in each matrix. These are historical comparisons, not independent proof of current automatic transitions. `cinematic_transitions.gd` tests current behavior. No Wave 3 certification is claimed.

## What the live pilot tests prove

The Room Creator suite instantiates the **real game scene**, not the old physics-probe laboratory. It compares ordered native collider rectangles, disabled/one-way/margin/layer/mask values, the complete `world.platforms` array, legacy route bookkeeping, hazards, encounters, gate definitions and anchor positions/requirements across all 21 rooms with the feature disabled and enabled. R18 has exactly 18 authored rectangle bodies plus its independently owned electric gate when closed. Other rooms remain generated. The native renderer uses a single terrain draw owner; tool ink and markers are hidden.

Kaze's actual unchanged CharacterBody2D lands on an R18 one-way ledge. Input actions drive both directions of all three R18 connections: R16↔R18, R8↔R18 and R18↔R19. The depth doors use the existing interact action; ordinary side passages use directional movement. Loaded arrivals settle on supported landings. Test fixture progression opens the relevant route requirements; the stock gate/progression suites separately check closed and open prerequisites with both runtime states.

Edited-scene checks move/resize a platform, make it solid, disable another, save, reload with cache bypass, instantiate the result into live R18, and verify its support rectangles and native collision flags. They restore the original freeze and then disable the feature, comparing both to the original generated snapshot. Same-process and separate-process save fixtures retain checkpoint position, earned abilities, speed upgrade, opened electric gate and lore, with either runtime choice. The opt-in is absent from the save schema.

The negative suite rejects unsupported shape/version/identity, root scaling, ancestor rotation, negative margins, enabled polygons and moving surfaces. It verifies translated ancestors and disabled-polygon exclusion. Two deliberately invalid live layouts produce **expected validation error messages**, then restore complete legacy geometry. Those diagnostics are part of the negative test, not unexpected engine failures.

The actual plugin tests create/open a template, insert geometry, exercise the editor's scene history through undo/redo, duplicate unique shape resources, move/resize through native property actions, add decoration/markers, save through EditorInterface, and reload the saved bytes. They are programmatic integration tests. They do not prove mouse usability, snap-button discoverability or creator comfort.

## Preservation guard interpretation

The original `tools/verify_tr05_preservation.py` is intentionally unchanged. Its exact `add_platform` function check rejects the new two-line early-return hook; every other check passes. This is recorded as a failing historical guard, **not a green result**. `tools/ld_tools_02/verify_preservation.py` supplies the applicable extension: it permits exactly the explicit R18 preload/state/preparation/collision/drawing additions and reverses them before byte-comparing `world.gd` to PR49. Every other inherited tracked file, including the controller, geometry helpers, graph, progression, save implementation, settings, artwork and all LD-TOOLS-01 resources, must be byte-exact. This is narrower than waiving a whole function or script.

## Evidence and reproduction

[Machine-readable matrix](evidence/results.json), [stock matrix](evidence/stock-matrix.txt), [Room Creator headless log](evidence/headless-room_creator.txt), [native gameplay log](evidence/rendered-room_creator.txt), [negative tests](evidence/headless-contract_negative.txt), [native negative tests](evidence/rendered-contract_negative.txt), [editor log](evidence/editor-qa.txt), [preservation](evidence/preservation.txt), [historical guard](evidence/historical-tr05-preservation.txt), [baseline guard](evidence/approved-baseline.txt), and [capture identity](evidence/captures.json). Full stock logs are under `evidence/stock/`.

```sh
python3 tools/ld_tools_02/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot
python3 tools/ld_tools_02/run_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot --rendered --pilot-only
python3 tools/ld_tools_02/run_editor_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot
python3 tools/ld_tools_02/run_editor_qa.py --godot /Applications/Godot.app/Contents/MacOS/Godot --rendered
python3 tools/ld_tools_02/verify_preservation.py
python3 tools/verify_baseline.py
```

Native captures are generated by `tools/ld_tools_02/capture.gd` with `-- --test` in a rendered Godot process. Initializing Kaze's normal animation and settling actual collision precede the final captures. `before-legacy.png` and `after-authored.png` are the unchanged-layout comparison; `edited-authored.png` uses the inherited edited example, not a redesign proposal. Captures do not replace exit/progression/save tests.

## Retained failures and limits

- An initial sandboxed invocation without an explicit writable log path crashed in Godot's RotatedFileLogger before tests initialized. The final runners use writable logs and disposable profiles. [Initial startup failure](evidence/initial-startup-failure.txt).
- An early fixture incorrectly assumed an R18↔R17 link. It failed and then errored on missing metadata; the actual graph is R16/R8/R19 and was left unchanged. Final tests use those real endpoints. [Initial fixture failure](evidence/initial-fixture-failure.txt).
- The first cross-process test treated `load_progress()` as a boolean; that function returns no value. The corrected test checks file existence and actual restored state. No production save function changed.
- The initial editor harness lost its temporary RefCounted test object before its deferred callback. Retaining it fixed the test timeout. Headless editor thumbnail creation reports the engine dummy renderer's `Parameter "t" is null` diagnostic while saving succeeds; the log is retained. Programmatic assertions and saved bytes pass. The native rendered editor also logged `p_name.is_empty()` at startup and exit-time ObjectDB/resources-in-use diagnostics; the cause is unresolved. All 14 assertions and saved-byte checks pass; this is not classified as a warning-free editor run.
- The new dock's manual mouse workflow and updated dock screenshot remain pending because the Mac was locked. The guide labels the inherited LD-TOOLS-01 editor screenshot explicitly. No human acceptance is claimed.
- Other-room authoring is a disconnected geometry laboratory. It has no progression or map registration, and no fall-recovery/reset interface beyond closing/relaunching. R18 preview supplies explicitly labelled fixture abilities/progression for testing routes; the electric gate, hazard and enemy retain their normal gameplay behavior. It deliberately does not load or save personal campaign progress.
- Slopes, arbitrary collision polygons, controller changes, room redesign, finished art, physical gamepad, other OS/export builds, sustained performance and a fresh full campaign were not validated. PR63/PR74 repairs and GN-06 belong to later integration review; their acceptance is not implied here. Roof status is unchanged.
