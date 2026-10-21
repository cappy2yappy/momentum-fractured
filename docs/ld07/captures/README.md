# Native geometry evidence

Godot 4.6.1 stable, macOS, Apple M4, OpenGL API 4.1 Metal compatibility renderer, 1280 x 720. Captured on 2026-10-21. Actual Godot scenes and runtime collision overlays; no painted replacement geometry. Not a human playtest or creator acceptance.

| Folder | Runtime | Roof mode | Purpose |
|---|---|---|---|
| before-boundaries | 49ae3efe21dea6a9eba556ce2fbc8299b00412b9 | Open top (this runtime predates roof comparison) | R8 unsupported shelf and R13 under-pad nook |
| before-ground | 658ed34c2d182dd650c1d22b8fa6b3a6c43ca837 | --ld05-open-top | R6 dead walking exit and raised water |
| after | fa299cff0afe5172d5e37fad7d8378209425db56 | --ld05-open-top | Same four cameras after recovered ground repairs |
| rooms | fa299cff0afe5172d5e37fad7d8378209425db56 | --ld05-open-top | All 21 rooms, actual geometry overview |

The current LD-07 changes leave runtime files byte-identical to the "after" reference. No roof was selected or modified. Original roof-on/open-top evidence remains under `docs/ld05/`.

`MANIFEST.sha256` covers all 33 PNGs. Scene fixtures are frozen for screenshots; sprite poses are not evidence of walking or landing. Separate real-input headless and rendered test transcripts prove those behaviors. Magenta polygons/rectangles identify additions; cyan is solid, yellow is one-way, red is the transition endpoint. The overlay also outlines polygon bounding boxes; those boxes are annotations, not extra collision.

Reproduction, from an imported checkout:

```sh
python3 tools/ld07/capture_geometry.py --godot /path/to/Godot --ref 49ae3efe --spec docs/ld07/capture_details.json --out build/ld07/before-boundaries
python3 tools/ld07/capture_geometry.py --godot /path/to/Godot --ref 658ed34 --spec docs/ld07/capture_details.json --out build/ld07/before-ground
python3 tools/ld07/capture_geometry.py --godot /path/to/Godot --spec docs/ld07/capture_details.json --out build/ld07/after
python3 tools/ld07/capture_geometry.py --godot /path/to/Godot --spec docs/ld07/capture_all_rooms.json --out build/ld07/rooms
```

The capture helper reads pinned runtime scripts/scenes into disposable snapshots. It does not switch branches, edit the source checkout, publish a site, or produce a release build.
