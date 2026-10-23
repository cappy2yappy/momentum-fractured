# GP-09 — Story-driven gameplay vertical slice

One isolated, provisional room assembles the existing Alpha 0.7 systems. It does not define new canon or connect to campaign rooms.

## Play on Windows

Extract **Kaze-GP09-Windows.zip** completely. Open **Play.cmd** or **Kaze-GP09.exe**; keep the adjacent PCK file with the executable. Godot does not need to be installed.

- **Play-Fresh.cmd** clears only this demo's save at process startup. F9 reloads thereafter without clearing it.
- **Play-Reduced-Motion.cmd** selects the existing shorter cinematic timeline.
- A/D or arrows move; Space jumps; J attacks; F parries.
- E examines the bundle, advances inspection, heals at a shelter, or uses the exit.
- Esc closes inspection; Space skips the cinematic.
- F5 saves; F9 reloads once pending story work and input ownership are safe.

Explore east from the first shelter, examine the abandoned bundle, close inspection, watch or skip the cut-in, defeat the managed guard, cross the steam vent during SAFE/RECOVERY, heal at the far shelter, and press E at the doorway. The short exit fade places Kaze on a safe apron **within the isolated room** and returns movement. No campaign destination is requested.

The native build has a separate application identity, **Kaze GP09 Provisional Review**, and stores only its own `gp09_vertical_slice_v1.json`. Source launches use that distinct filename under the existing project's user directory. Campaign saves are never loaded.

## Run from source

Godot **4.6.1**, Windows x64:

```powershell
& "C:\path\to\Godot_v4.6.1-stable_win64.exe" --path "." res://scenes/gp09/demo.tscn
```

Run from the repository root. Append `-- --gp09-fresh` or `-- --reduced-motion` when needed. The root project main scene remains the production entry point; choose the demo scene explicitly.

## Integration and boundaries

The base runtime is the exact PR90-authoritative composition **892b1ea29ab459d6e6ece1edba0cb88d3ec24972**, retained on `recovery/alpha07-qa-authoritative-20261022`. The recovery branch's later commits contain only reports and QA fixtures.

- PR84 remains an integration placeholder, not a runtime implementation source.
- INT01 / PR89 supplies the sole StoryDirector, existing inspection panel, object/rule validation, and unchanged version-8 serializer.
- EN01 and HAZ01 come from the consolidated PR87 composition, including its final identifier validation. No PR82 hazard implementation is added or duplicated.
- The approved cinematic presenter handles request/update/cancel, input ownership, skip, reduced presentation, and watchdogs. A local subclass replaces only the provisional copy and rejects repeated requests.
- The room subclasses the approved world and instantiates its unchanged player, combat signals and enemy-spawn path. All new geometry belongs to the demo subclass.
- The root project, production room builders, Canal Doorway, controller, art, shared systems and production story JSON remain unchanged.

## Event and persistence behavior

Examination persists `disc/gp09_bundle`. The composition root reconciles this flag on reload and requests unfinished presentation. Completed or skipped presentation persists `evt/gp09_presented`; interruption retries only after control returns. The encounter is then dispatched once via the registered consumer.

Managed enemy defeat persists through the original `cleared_encounters` dictionary. If saving/reloading separates the defeat from its completion event, the room reconstructs the completion flag from that authoritative dictionary. Alive enemy HP and hazard clock reset on reload, following EN01/HAZ01 contracts; **defeated enemy state persists**.

The exit drains queued events and save retries before taking a 0.5-second control lease. It preserves the same director instance during the fade, so events received during the exit flush when input returns. Death recovery also preserves the director and its pending IDs.

New flags use the established namespaces only. There are no new save fields. Consumers register before data validation; hazard consumers tick every physics frame.

## QA and reproduction

See [QA.md](QA.md), [raw evidence](evidence), and [recorded traversal](gameplay.mp4).

```powershell
& "C:\path\to\Godot_v4.6.1-stable_win64_console.exe" --headless --path "." --script res://tests/gp09/integration.gd -- --gp09-save=res://build/gp09/qa.json
python tests/gp09/run_qa.py --godot "C:\path\to\Godot_v4.6.1-stable_win64_console.exe"
python tools/verify_baseline.py
```

The integration test creates its disposable build directory and removes only the explicit test save supplied to it. It must never point at a campaign save.

Package reproducibly after importing the project:

```powershell
python tests/gp09/package_windows.py --godot "C:\path\to\Godot_v4.6.1-stable_win64_console.exe" --template "C:\path\to\windows_release_x86_64.exe"
```

Packaging makes a separate export staging project. Only that staging copy changes the main scene, application identity and include/exclude filters. Output is under `build/gp09`; generated binaries and saves are not committed.

Draft review only. No merge or production placement approval is implied.
