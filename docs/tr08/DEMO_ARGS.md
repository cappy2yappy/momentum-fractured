# TR-08 demo entry arguments (for Build Shogun launchers)

Branch `feature/tr08-fullscreen-embodied-cinematics`, Godot 4.6.1. Same format as `/home/claude/pilot_shared/TRANSITION_DEMO_ARGS.md`.

All user arguments go after `--`, both for the source project (`godot --path <repo> -- ...`) and for an exported executable (`<exe> -- ...`).

TR-08 is the default presentation, so the launchers below need no feature flag. The fixtures are deliberately seeded QA saves (abilities and route progress), not earned progression.

## Isolated saves

`--tr05-save=<ABSOLUTE path to a .json file>` replaces the save path before load. Relative paths are ignored.

On every launch, each launcher should copy its fixture over its own profile file. For full isolation of other `user://` data, also point `APPDATA` (Windows) or `HOME`/`XDG_DATA_HOME` (Linux/macOS) at a folder the launcher owns.

| Launcher | Fixture (this branch) | Start | Action |
| --- | --- | --- | --- |
| Play-TR08-Stair-Ascend | `docs/tr08/fixtures/TR08-Stair-Ascend.json` | R14 Bellroof Walk, feet (1410,478), 40 px left of the stair | press E: full-screen ascent to R17 |
| Play-TR08-Stair-Descend | `docs/tr08/fixtures/TR08-Stair-Descend.json` | R17 Counterweight Spire, feet (1650,1298), 30 px left of the stair | press E: full-screen descent to R14 |
| Play-TR08-Canal-Exit | `docs/tr08/fixtures/TR08-Canal-Exit.json` | R13 Mooring Loft, feet (330,1158) on the hallway shelf | hold A (no E): through the Canal doorway to R0 |
| Play-TR08-Canal-Return | `docs/tr08/fixtures/TR08-Canal-Return.json` | R0 Canal Haven, feet (650,778), 60 px right of the Mooring Loft door | press E: through the R0 door, emerging from the Canal doorway in R13 |

## Command lines

```
<godot-or-exe> [--path <repo>] -- "--tr05-save=<PROFILE>/TR08-Stair-Ascend.json"
<godot-or-exe> [--path <repo>] -- "--tr05-save=<PROFILE>/TR08-Stair-Descend.json"
<godot-or-exe> [--path <repo>] -- "--tr05-save=<PROFILE>/TR08-Canal-Exit.json"
<godot-or-exe> [--path <repo>] -- "--tr05-save=<PROFILE>/TR08-Canal-Return.json"
```

Reduced-motion variants add `--tr05-reduced-motion`; F6 still toggles it at runtime. Give each variant its own profile copy, for example `TR08-Stair-Ascend-Reduced.json`:

```
<godot-or-exe> [--path <repo>] -- --tr05-reduced-motion "--tr05-save=<PROFILE>/TR08-Stair-Ascend-Reduced.json"
```

Comparison launchers (optional) that restore the previous candidate:

```
<godot-or-exe> [--path <repo>] -- --tr08-off "--tr05-save=<PROFILE>/TR08-Stair-Ascend-Old.json"        # PR61 default: 0.65 s stair, Canal wipe
<godot-or-exe> [--path <repo>] -- --pm-staged-stair "--tr05-save=<PROFILE>/TR08-Stair-Ascend-PM.json"   # PR57 opt-in staged stair
```

## Flags

| Flag | Effect |
| --- | --- |
| (none) | TR-08 on. The R14 <-> R17 stair is the full-screen cinematic, about 2.9 s with the current clips. The Canal doorway is the embodied passage: about 1.9 s for R13 to R0, about 3.0 to 3.5 s for R0 to R13 (includes the walk to the R0 door and the walk out to the arrival point). |
| `--tr05-reduced-motion` | Reduced motion from launch. Stair about 1.3 s: no wipe panels, no camera zoom or pan, true frames played faster on a fixed stage. Canal about 1.4 to 2.5 s: faster frames, no depth recession. F6 toggles at runtime. |
| `--tr08-off` | TR-08 off. Exactly the PR61 candidate: inherited 0.65 s stair, Canal wipe. |
| `--pm-staged-stair` | TR-08 off, plus the PR57 opt-in staged stair (R14 to R17 only). |
| `--tr05-plain` | Plain fade; TR-08 bypassed. |
| `--tr05-legacy` | TR05 policy off entirely (TR-08 off too). |
| `--tr05-save=<abs>` | Isolated save file. |

## Verified here

- All four fixtures were launched from source with exactly these user arguments, under xvfb (Mesa llvmpipe, `--write-movie`, 40 frames). Each started in the stated room and position.
- The sequences themselves were captured by `tests/capture_tr08.gd`, using real key events (`docs/tr08/captures`).
- TR-08 made no exported build and no Windows or macOS launch.

Controls: A/D move, double-tap run, Space jump, E use, Shift dash, Esc pause, F6 reduced motion.
