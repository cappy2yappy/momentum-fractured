# TRANSITION pilot: demo entry arguments

Branch `feature/pm-pilot-transitions`. Godot 4.6.1. For Build Shogun launchers. All user arguments go after `--`, for both the source project (`godot --path <repo> -- ...`) and an exported executable (`<exe> -- ...`). Fixtures are deliberate seeded QA saves (abilities and route progress), not earned progression.

## Isolated saves

`--tr05-save=<ABSOLUTE path to a .json file>` replaces the save file before load (existing TR05 mechanism, `scripts/cinematic_transitions.gd` configure). Relative paths are ignored. Each launcher should copy its reviewed fixture over its own profile file on every launch, exactly as `tools/package_tr05.py` does for `Play-Canal-Automatic`:

| Launcher | Fixture to copy (in this branch) | Start |
| --- | --- | --- |
| Play-Canal-Left | `docs/pm_pilot/transition/fixtures/PM-Canal-Left.json` | R13 Mooring Loft, feet (330,1158) on the shelf inside the gatehouse hallway |
| Play-Stair-Cinematic | `docs/pm_pilot/transition/fixtures/PM-Stair-Cinematic.json` | R14 Bellroof Walk, feet (1410,478), 40 px left of the stair contact (inside the 85 px E radius) |

The `--tr05-save` flag only redirects the save file. For full isolation of other `user://` data (logs, caches) also point `APPDATA` (Windows) or `HOME`/`XDG_DATA_HOME` (Linux/macOS) at a launcher-owned folder.

## Command lines

Canal-left automatic passage (hold A; no E needed):

```
<godot-or-exe> [--path <repo>] -- "--tr05-save=<PROFILE>/PM-Canal-Left.json"
```

Staged stair cinematic, R14 to R17 (press E beside the stair):

```
<godot-or-exe> [--path <repo>] -- --pm-staged-stair "--tr05-save=<PROFILE>/PM-Stair-Cinematic.json"
```

Same, starting in reduced motion (F6 still toggles live):

```
<godot-or-exe> [--path <repo>] -- --pm-staged-stair --tr05-reduced-motion "--tr05-save=<PROFILE>/PM-Stair-Reduced.json"
```

(copy `PM-Stair-Cinematic.json` to `PM-Stair-Reduced.json` for the separate profile).

Fresh unseeded campaign with the pilot on (persistent, never reset by the launcher):

```
<godot-or-exe> [--path <repo>] -- --pm-staged-stair "--tr05-save=<PROFILE>/Fresh.json"
```

## Flags

| Flag | Effect |
| --- | --- |
| `--pm-staged-stair` | NEW, opt-in. Enables the staged R14 to R17 stair sequence (about 2.35 s). Without it the game is byte-for-byte the PR51 behavior for that stair (inherited 0.65 s TR05 presentation). |
| `--tr05-reduced-motion` | Existing. Reduced motion from launch; the staged stair shortens to about 0.95 s with no camera move or proxy travel. F6 toggles at runtime. |
| `--tr05-plain` | Existing. Plain fade; bypasses the staged stair (inherited loader only). |
| `--tr05-legacy` | Existing. Disables TR05 policy entirely (stair staging off). |
| `--tr05-save=<abs>` | Existing. Isolated save file. |

The Canal-left passage needs no flag: it is the ordinary automatic side passage. Its door art follows the LEVEL contract rectangles in every launch mode; Art Mane layers appear automatically once `assets/pm_pilot/canal/*.png` are combined into the build.

## Verified here

Both entries were launched from source with these exact user arguments under xvfb (Mesa llvmpipe, `--write-movie`, 30 frames) and start in the stated room and position. No exported build, Windows or macOS launch was made by TRANSITION.

Controls: A/D move, double-tap run, Space jump, E use, Shift dash, Esc pause, F6 reduced motion.
