# Character audit and minimal production brief

## Observed and protected

All four active cleaned sheets were visually inspected at source resolution. Kaze has brown skin, long dark purple hair, a bright green hair ribbon/chest bow, purple jacket, dark pleated skirt and purple boots. Preserve apparent age, face, outfit, proportions and silhouette; no new weapon, emblem, costume or character identity. Rear views need creator review because they reveal previously unseen construction. Existing artwork is retained byte for byte.

| Asset | Existing status / use | New work |
| --- | --- | --- |
| cleaned idle | Active, eight 272×724 cells; fixed baseline 591; scale 0.2649908807267889 | Reference for face and upright proportion; do not animate walking by sliding idle |
| cleaned run | Active, eight 272×724 cells; baseline 491; scale 0.3825780535911868; 0.08 s/frame | Reuse for horizontal_run, preserve phase and ninja lean |
| cleaned combat | Active, eight 320×724 cells; baseline 498; scale 0.37875157200639 | Reference only; not a turning animation |
| cleaned traversal | Active, eight 320×724 cells; baseline 510; scale 0.33919279345239656 | Reference only; jump/crouch frames do not prove stair poses |
| depth_turn_enter | Absent | Four turn keys + three entering keys, three leaving keys + two return-to-profile keys; see SPRITE_PACK_SPEC.md |
| stair_up / stair_down | Absent | Six frames each, independently authored; descending is not reversed ascending |
| walk_continue | Absent | Six new upright heel-to-toe walk frames; a slowed ninja run is not a walk |
| wind_fold | TR-02 expressive prototype | Preserve; no replacement sheet in this assignment |

Accepted here means previously active source, not a new quality acceptance. Combat/traversal visibly retain boundary fragments/cut source detail; do not silently repair them or copy detached fragments into new work. Prior integration documentation already flags incomplete source reconstruction.

## Proposed export and pivot contract

Use [SPRITE_PACK_SPEC.md](SPRITE_PACK_SPEC.md) and [transition_art_contract.json](transition_art_contract.json) from recovered checkpoint 0d96f939641c0815b16813c2382b607a5eb34f28 as the single proposed production contract. New cells320×724, ground pivot(160,600), target upright occupied height320px, initial scale0.303125. Centered Sprite2D offset(0,−238). Keep at least12px alpha margin; never scale/recenter each frame. New variable clip counts require a render-only adapter; the current controller assumes eight hframes. No production strip/source is delivered here. Aseprite sources, tag names, frames and export dimensions follow that specification. Existing strips keep their exact original pivots/scales.

Right is the reference lateral direction. Left may mirror only after checking face, hair ribbon and costume asymmetry against approved art. Depth turn must be delivered for both approach sides when mirroring fails identity review; depth does not mean flip_v. Ascending and descending each need both lateral directions. Stair facing comes from endpoint metadata, never inferred from current sprite facing alone.

Godot 4.6.1 proposal: lossless compress/mode=0; mipmaps/generate=false; process/fix_alpha_border=true; process/premult_alpha=false; size_limit=0. Match the existing project texture filter initially and compare edges at zoom 1.0 before changing it. New resources must receive fresh Godot UIDs; do not copy existing .import files. AnimatedSprite2D/SpriteFrames or a dedicated presentation Sprite2D may consume metadata later; the current controller is Sprite2D with eight hframes. Nothing is installed by this document.

## Staging and timing for Level Masta Masta

All beats fit the existing39 ticks /0.65s; no added preparation delay. They follow loader cues rather than extending nominal clip durations end to end. Level owns authoritative swap timing, eligibility, cooldown and restoration. Labels in STORYBOARDS.svg show action order, not additional waiting time.

| Mode | Source ticks0–18 | Cover/swap ticks18–21 | Arrival ticks21–38 / resume39 |
| --- | --- | --- | --- |
| depth_door | Planted profile→quarter-back→rear; two depth contacts toward inner marker | Near jamb occludes; follow existing room-swap event | Leave-depth front-quarter steps then return_profile; show actual destination heading |
| stair_up | Knee leads, upper foot contacts, trailing toe pushes; local step fragment only | Landing cheek/return wall hides discrete swap | Upper landing settling contact; restore authoritative position |
| stair_down | Toe reaches lower tread then knee absorbs; independent art | Landing cheek hides swap | Lower landing settling contact; no reverse ascending playback |
| horizontal_walk | Six-frame10FPS upright walk, actual approach displacement | Existing safe carry policy | Preserve phase; never call a slowed run a walk |
| horizontal_run | Reuse eight-frame12.5FPS ninja run and current phase | Existing safe carry policy | Continue reciprocal direction without forced braking or acceleration |
| wind_fold | Existing exceptional treatment | Existing special swap | Preserve original/plain/reduced choices |

Placeholder gate: run is available; depth/stair staging may use visibly labeled planted poses and fade, but must not be reported as finished turning/stair animation. Missing walk art retains the existing comparison rather than relabeling run. No lateral sprite shrinking as a substitute for turning.

For depth/stairs, only a presentation proxy follows art markers; collision body, save and authoritative destination remain Level-owned. Suppress duplicate visible player render while proxy is active, restore on cancellation/failure, and use existing transition guards. Do not add root motion to the controller. Arrival must never render inside a wall or beyond a collision lip.

Proposed metadata (design only): `presentation_mode`, `approach_side`, `threshold_anchor`, `inner_anchor`, `arrival_anchor`, `occlusion_polygon`, `step_contacts`, `asset_id`, `fallback_mode`. Coordinates are room-local world pixels; links/gates are existing endpoint IDs. Lane A must validate and map this schema to its real endpoint structure; no new door location is asserted.

Reduced motion: same readable plant/turn/contact, plain fade, no forced camera movement, spin, flash, shake or perspective pulse. Preserve original graphic/refined/plain comparisons. Local stair fragments fit the loader envelope; a complete staircase performance is a separate scope decision.

## Production gates and schedule

1. This session: audit, technical storyboards, original architecture kit and machine-readable brief ready for Lane A placeholders.
2. After creator storyboard review: first produce depth turn key poses and one up/down contact pair; verify actual Kaze identity, scale and foot registration before inbetweens. One art iteration, not a promised date.
3. Next production pass: complete30 minimum new master frames (6 walk +4 turn +3 enter +3 leave +2 profile return +6 up +6 down); extra authored direction variants may increase this. Run reuses8 existing frames. Export editable Aseprite sources and PNG/JSON only after creator compatibility review.
4. Integration gate: Lane A implements isolated pilots and in-engine capture. Review 1280×720/zoom1.0, both directions and reduced motion. Final frame acceptance precedes any sprite replacement or merge.

Final art QA still required: decode all RGBA pixels; check every cell alpha bounds and 12px padding; no detached fragments; anchor overlay and floor-contact parity; no hair/boot clipping; frame count/duration parity; black/white/checker edges; idle-to-turn scale; gameplay-size readability, left/right and rear identity. This delivery has no finished new PNG animation and makes no final frame-boundary, in-engine or60 FPS claim.
