# ART-11 — Environmental asset integration pilots

Creator review draft for Alpha 0.7, 2026-10-23. This branch adds native review tools and metadata only. It does not replace production art or change movement, room geometry, damage, exits, progression, or the save schema.

Built on PR #94 at `815bceb98e2560a2869a5534a34cd155c15b0dc1`, retaining PR #92's audited sources and licensing register. PR #47 informed the exact-surface registration and recessed-architecture approach; its R18 artwork and runtime remain untouched. EN-01/HAZ-01 run in a separate, content-pinned PR #87 host at `5172db6898f3efc35b74f3c134293049165b9bf7`.

## Review contents

| Native view | Content | Approval |
| --- | --- | --- |
| Candidate gallery | Ten selected modules beside approved Kaze; linear/nearest comparison | Pending |
| R16 Root Shrine | Moss surface inlays, sparse grass/flowers, recessed overgrowth on runtime geometry | Pending |
| R15 Lower Sluice | Cave surfaces and recessed rocks on runtime geometry | Pending |
| HAZ-01 course | Poison-plant artwork inside the existing steam sensor; existing phase/damage/cues preserved | Pending; no new poison mechanic |
| EN-01 guard lab | Green slime preferred, amber alternate; original guard can be restored with F4 | Provisional; authored action poses absent |

The existing ASSET-01 six-pack galleries remain available under `tools/asset01`. BlueWizard is reference-only and absent from the new runtime cache.

Review [selected candidates](SELECTED_CANDIDATES.md), [geometry and owner handoff](PLACEMENT_AND_HANDOFF.md), [licensing inventory](LICENSES.md), and [validation/performance](QA.md). Native screenshots are delivered separately to the creator, with hashes in [capture-manifest.json](capture-manifest.json). No screenshots or asset payloads are committed here.

## Local setup

Use Godot **4.6.1** and Python 3.10+. No image library is required. Keep both source ZIPs and staging outside Git. Existing ASSET-01 staging can be reused.

```sh
python tools/asset01/stage.py --source /local/supplied-zips --stage /local/asset01-staging
```

For a new stage, copy the tracked `docs/asset01/inventory/packs.json` to `/local/asset01-staging/gallery.json`. This reuses the audited inventory; do not regenerate or weaken its hashes. The launcher checks all six ZIPs and 1,106 extracted files before every run.

Import this checkout and the separate pinned PR87 host once with Godot `--headless --editor --import`. The launcher verifies relevant source and approved-art Git blob hashes before running a world/host. It refuses changed controller, geometry, scene or art content. It does not accept a different project merely because its folder name matches.

```sh
python tools/art11/launch.py --stage /local/asset01-staging --godot /path/to/godot --mode prepare
python tools/art11/launch.py --stage /local/asset01-staging --godot /path/to/godot --mode gallery
python tools/art11/launch.py --stage /local/asset01-staging --godot /path/to/godot --mode moss
python tools/art11/launch.py --stage /local/asset01-staging --godot /path/to/godot --mode cave
python tools/art11/launch.py --stage /local/asset01-staging --godot /path/to/godot --mode hazard --host /local/pr87-host
python tools/art11/launch.py --stage /local/asset01-staging --godot /path/to/godot --mode enemy --host /local/pr87-host
python tools/art11/launch.py --stage /local/asset01-staging --godot /path/to/godot --mode validate --host /local/pr87-host --check
```

Quote Windows paths containing spaces. The native gallery project is `tools/art11/gallery/project.godot`; the launcher supplies its verified cache and script location. Defaults write derivatives, logs and disposable profiles only beneath ignored `build/art11`. `--cache` and `--output` can select other local directories.

For each room/lab, `--check` runs a 12-second native inspection and saves captures/results. `--check --baseline` measures the same host with art disabled. The world captures freeze player/enemy movement for reproducible framing; these are not real-input traversal tests. Interactive launches retain ordinary gameplay controls and use separate review saves. Do not point them at a campaign save.

Room/lab controls: **F4** art toggle, **F7** collision/target guides, **F8** reduced motion, **F10** slime color, **Esc** close. Existing F5/F9 hazard save/restore and F6 cinematic preference remain untouched. Gallery controls: Space pause, F filtering comparison, Esc close.

## Boundaries

No merge or production placement is authorized by this draft. All manifests retain `production_approved: false`. Scene changes are made only in disposable runtime instances. Leaving the nominated room removes its visual overlay. The slime does not gain a new identity, faction, species behavior, damage profile, or save event.

Original archives, source rasters, editable files and prepared textures must remain local. To share a playable game export later, review selected-use packaging separately; this draft is not release approval.
