# R18 visual room authoring pilot

Godot **4.6.1**, baseline PR39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`. This is a geometry authoring laboratory, not an adopted room redesign. No plugin install or upgrade is required. No movement, map, progression, gate, save or gameplay code changes.

## Open and try it

The easiest route is the standalone ZIP: extract it to a new folder, import its `project.godot` in Godot 4.6.1 and open it. Its title is **Kaze LD-TOOLS-01 Isolated Authoring**; it has no autoloads or enabled plugins. F5 runs the geometry laboratory. It does not load personal Kaze saves.

In a source checkout, open this branch's root project and use **F6 on `tools/ld_tools_01/preview.tscn`**. F5 there still runs the unchanged Kaze game. Keep this checkout separate from the creator's active project. The standalone package avoids the baseline MetSys editor plugin's automatic resource reserialization.

1. Open `tools/ld_tools_01/r18_layout.tscn`. Select `Geometry/Platform_01/Surface` in the Scene tree. Click the 2D viewport with the middle mouse button, then press **F** to frame the selection. F while the tree has focus searches the tree instead.
2. **Move:** drag the platform interior in the viewport. Inspector > Node2D > Transform > Position provides exact coordinates. Select the `Surface` child; its drawing and native collider move together.
3. **Resize:** drag a native shape handle, or expand Inspector > Shape > RectangleShape2D > **Size**. Keep Scale `(1,1)`, Rotation `0` and Skew `0`. Do not scale collision nodes to resize them.
4. **Solid / one-way:** leave Disabled off. One Way Collision **off** makes a teal solid; **on** makes a gold platform with a bright top edge. The frozen ledges retain margin `8`. **Disabled on** removes collision and draws translucent geometry.
5. **New platform/wall:** duplicate a whole StaticBody2D with Ctrl+D. On the new Surface's Shape resource menu choose **Make Unique** before changing its size; duplicated nodes can share a resource. Existing example bodies already have independent resources. Rename the body for its purpose. Walls use the same rectangle tool with One Way Collision off.
6. **Decoration:** select `Background/PumpHousing_Decoration`, Ctrl+D, choose the Move tool and drag the duplicate. Or add a Sprite2D with an approved texture under Background or Foreground. These nodes have no collision. Background has z=-10, Foreground z=10. Do not add physics children to decorative nodes. The silhouettes supplied here are placeholders, not finished environment art.
7. **Optional slope:** select `SlopeExample_DISABLED/Surface`. Edit its polygon vertices in the 2D editor. Uncheck Disabled to test it only in the laboratory. It is a native CollisionPolygon2D; the same polygon is drawn. The legacy rectangle adapter deliberately rejects an enabled slope. Kaze controller slope traversal remains unapproved and untested.
8. **Ladder marker:** move `Markers/Ladder_Proposal_NoTraversal`. It has no collision, trigger, destination, graph edge or climbing script. Set a design note in its metadata if useful. A marker does not authorize a climbing ability.
9. Ctrl+S, close/reopen the project, and reopen the scene. Run `preview.tscn` with F6 (or F5 in the standalone project). Left click drops a physics probe; wheel zooms; middle drag pans; R resets the view and removes probes. Physics probes are Godot RigidBody2D objects, not a replacement character controller.

## Included comparisons

| File | Purpose |
| --- | --- |
| `r18_layout.tscn` | Frozen runtime R18: 2 walls, 1 floor and 15 ledges; placeholder scenery, disabled slope and ladder marker |
| `r18_frozen.json` | Exact rectangles, layers, masks, one-way flags and margins captured from the actual baseline builder |
| `r_18_pump_gallery_layout.tscn` | Actual mouse-edited/save-as example: first platform moved/resized/made solid and second background prop placed |
| `preview.tscn` | Runnable laboratory using the frozen layout |
| `preview_edited.tscn` | Runnable laboratory using the saved mouse-edited example |
| `layout_records.gd` | Read-only rectangle adapter; no world mutation or gameplay activation |

The edited example has Platform_01 center `(1270,1170)`, size `(380,40)`, One Way Collision off; the original is center `(1200,1200)`, size `(320,40)`, one-way. Its second pump prop is at `(1540,1100)`. These edits demonstrate authoring only and are not a route design recommendation. Preview references are explicit: edits to the frozen file appear in `preview`; edits to the separate example appear in `preview_edited`.

## Evidence and next decision

- [QA and exact acceptance status](QA.md)
- [Installed MetDevSys evaluation](PLUGIN_EVALUATION.md)
- [Representation and reversible migration](MIGRATION.md)
- [Reopened editor screenshot](evidence/editor-reopened.jpg)
- [Frozen native preview](evidence/layout-runtime.png), [edited native preview](evidence/edited-runtime.png), [mouse-dropped probe](evidence/native-probe.jpg)

The next creator decision is whether this editing workflow is comfortable. Adoption into R18 gameplay is a later explicit migration. Issue43's purpose map, gate clarity, real-player routes/recovery, and final artwork remain separate design work.

## Reproduce engineering checks

Run from a full checkout at the pinned baseline plus this additive pilot. Set APPDATA to an empty disposable folder before invoking Godot on Windows. Use the explicit 4.6.1 binary. The standalone ZIP does not contain Kaze gameplay and cannot run baseline regression suites.

```powershell
$env:APPDATA = Join-Path (Get-Location) 'build/ld-tools-01-userdata'
New-Item -ItemType Directory -Force $env:APPDATA | Out-Null
# Set $godot to your existing Godot 4.6.1 console executable.
& $godot --headless --editor --path . --import --quit
& $godot --headless --path . --script res://tools/ld_tools_01/qa.gd -- --test
python tools/ld_tools_01/verify_preservation.py
python tools/verify_baseline.py
python tools/verify_tr05_preservation.py
python tools/run_tr05_qa.py --godot $godot
& $godot --path . res://tools/ld_tools_01/preview.tscn -- --capture-layout
python tools/ld_tools_01/package_pilot.py build/R18-Authoring
```

`freeze_r18.gd` is a baseline extraction utility, not a normal editor action: it overwrites the frozen JSON and requires `-- --test`. Never regenerate the freeze to make an unintended gameplay change pass. Do not run it on an unapproved baseline. Re-importing a full checkout can reserialize MetSys theme resources; review and discard those unrelated generated edits before committing. The standalone project avoids this behavior.
