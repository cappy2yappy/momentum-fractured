# ART-10 production staircase checkpoint

Status: **incomplete; new drawings blocked**. This change supplies review tooling,
not completed animation, a playable TR08 integration, or creator-approved art.
Do not merge as fulfillment of ART-10.

## Pinned foundation

PR85 head `378b86ca47130ede1663674d82f3cfe6bd00511f`, branch
`codex/alpha07-animation`. Identity reference PR30 head
`a6b76b9938825307bdcd4efb687c7198ea0d8681`.
Reviewed PR62 and PR64 metadata, PR85 source manifest/viewer, and
`scripts/tr08_stair_stage.gd`. The Image4 extraction has only three selected
sprint keys, not completed stair gait. Source keys 138/139/140 remain unchanged.

No production scripts, shared clip manifests, Canal Doorway files, player,
physics, routing, saves, or approved sprites are modified. No activation flag
has been added to live gameplay. `production_enabled:false` is descriptive
metadata, not a runtime feature toggle.

## Work completed

- Separate grounded/expressive ascent/descent manifest slots.
- Isolated viewer with per-frame duration, pause, restart, stepping, candidate
  selection, direction selection, and contact-marker overlay.
- Validation of ordered approach/sprint/stairs/brake/settle phases, finite
  durations, frame regions, fixed tread bounds, measured contact markers,
  consecutive plant stability, alternating contacts and stationary final settle.
- Pending clips fail closed; viewer displays a clear missing-drawings notice.
- 31 contract/viewer checks passed in Godot 4.6.1 on Windows, using a minimal
  isolated validation project and disposable APPDATA. No full upstream game
  regression run is claimed. Initial run without disposable APPDATA failed
  because user-data directories were inaccessible; the isolated rerun passed.

The tests use numerical fixtures without drawings. Frame-region uniqueness does
not prove distinct pixel content, correct anatomy, identity, fabric attachment,
or visible foot placement. Contact markers must be manually measured against
the drawings; automated marker agreement alone is not visual approval.

## Run in the pinned repository

```sh
godot --path . res://tools/art10/viewer.tscn
godot --headless --path . --script res://tests/art10/contract_test.gd
```

Use disposable user data for tests. The local minimal test project is temporary
and is not committed over the real project's project.godot.

Controls: 1 grounded, 2 expressive, A ascent, D descent, Space pause/resume,
R restart, Right advance one frame, C contact overlay. Clips play once and hold
the final pose. Camera follows the authored root. Root values are sampled per
drawing, never interpolated to slide a static pose diagonally.

## Clip schema

Each candidate/direction contains `treads` and `frames`.
Treads are fixed `[left, right, top]` coordinates, in the same pixel units as
the artwork and root. They must be authored first, not fitted to faulty feet.

Each frame contains:

- `asset`: res://assets/art10/... PNG
- `region`: integer [x,y,width,height] in its sprite strip
- `duration`: seconds
- `phase`: approach, sprint, stairs, brake, or settle
- `root`: [x,y] presentation position
- `pivot`: [x,y] inside the frame region
- `contacts`: zero or more {foot: left/right, sole: [x,y], tread: integer}
  where sole is the measured contact point inside the frame region

Contact world position is root + sole - pivot. Consecutive contact by the same
foot must remain within one pixel; a release frame ends a plant. At least twelve
distinct regions, all five phases, four alternating stair contacts, and a final
two-foot settle are required. These are minimum structural checks, not a target
frame count or proof of production quality.

## Concrete next work

Grounded: restrained lean, clear weight transfer, compressed descent landings,
small hair/sleeve follow-through. Expressive: more anticipation, stronger
silhouette and overlapping hair motion, while retaining the same proportions,
tread geometry and planted-foot discipline. Both require complete approach,
arms-back transition, alternating contacts/passing poses, exit, braking and
natural idle drawings. Keep face/head upright and spine elongated.

1. Author drawings using the approved PR30 image and Image4 sprint reference.
2. Inspect identity/anatomy and correct missing contact/passing/stop in-betweens.
3. Produce transparent strips; measure each sole, pivot and root; populate manifest.
4. Verify strips visually at native speed and frame by frame; validate hashes.
5. Record native-speed videos with real timestamps, not slowed clips.
6. Build an opt-in R14/R17 integration fixture using TR08's existing request,
   loader and restoration ownership. Do not patch Canal Doorway.
7. Run baseline preservation and TR08 interruptions/reduced-motion regressions.
8. Obtain creator approval before any live replacement.

## Blockers and remaining deliverables

The built-in image tool rejected Windows reference paths before generation.
Higgsfield generation was rejected by automatic approval review: explicit
authorization is required to send the approved Kaze reference and Image4 sprint
reference to that external service. No generation was submitted.

Still missing: both complete candidate sprite strips, measured production
manifest entries, native-speed videos, playable TR08 integration demo, and
integration/regression certification. This checkpoint must not be represented
as finished production animation.
