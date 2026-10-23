# CIN-04 — Story cinematics creator review

Three native Godot narrative sequences, isolated from the campaign. Draft only; no merge.
Branch: `codex/cin04-story-cinematics`. Parent: PR #86 at `2d459743bce4a11a2d6bed1ae75d0c6d3adf3d5f`.

## Watch at native speed

| Sequence | Recording | Still | Authored length |
| --- | --- | --- | --- |
| Aftermath | [Watch](captures/aftermath.mp4) | [Capture](captures/aftermath.png) | 12 seconds |
| Evidence of Resistance | [Watch](captures/resistance.mp4) | [Capture](captures/resistance.png) | 14 seconds |
| Fallen Defenders — provisional | [Watch](captures/fallen_defenders.mp4) | [Capture](captures/fallen_defenders.png) | 16 seconds |

Recordings preserve actual rendered wall-clock timestamps. They are silent: no music, voice or sound asset is presented as approved. A brief return to live gameplay at each end demonstrates control restoration.

## Play and review

Open the root `project.godot` in Godot 4.6.1. Open `tools/cin04/demo.tscn` and run that scene with F6 (Godot's editor command). Within the running game:
- **1 / 2 / 3:** select and play a sequence; **R:** replay the selected sequence.
- **Space / controller B:** skip; **F6:** toggle reduced motion; **Esc:** pause.
- After playback, use the existing movement controls to verify control has returned.

This separate process assigns a disposable review save path before the world initializes, then disables saving. It never reads the normal campaign save. It does not install campaign triggers or change room placement. Use a separate game process, not a hot-injected review node in an existing campaign.

Command line: `godot --path . res://tools/cin04/demo.tscn -- --test`.

## Intended story beats

**Aftermath:** wide damaged passage → unfastened satchel, cup and repaired cloth → Kaze's search intention. The exact approved line is preserved: “The refuge was attacked. I have to find the others.” There is no owner identification, death confirmation or assertion that Canal Haven is the refuge.

**Evidence of Resistance:** a scarred, braced shield faces the damaged approach; an empty carrying frame and blanket sit behind it. Camera emphasis makes the attempted protection readable. The candidate reaction, “They held this passage... so others could get through,” suggests sacrifice without naming defenders or proving anyone escaped. This exact line and these props are new review proposals.

**Fallen Defenders:** a longer reveal of two anonymous, fully covered figures, followed by Kaze lowering to the ground and a held pause. “I'm sorry” is proposed copy. The lowering pose reuses the approved traversal/crouch art; it is not a newly drawn grief performance. No blood, anatomical detail, loot, identity, date, named death, canonical crest or memorial action is added. The composition represents the requested fallen-clan concept provisionally; no clan insignia establishes new material-culture canon.

The background is a stylized native-vector review set. It is not a newly assigned campaign location or approved final environment-art package. The two covered figures, their defender/clan interpretation, precise circumstances and later placement all remain provisional.

## Decisions for creator review

1. Does Aftermath communicate uncertainty without implying a named possession or casualty?
2. Does the shield/frame relationship make the protection attempt understandable? Approve or revise the proposed Resistance line.
3. Approve, revise or reject the two-figure Fallen Defenders treatment and crouched reaction. Location, identities, clan affiliation, timing and precise events require separate approval.
4. Review the 12/14/16-second pacing and the equal-duration reduced-motion versions.
5. Decide whether this visual staging should proceed to a dedicated environment-art and bespoke character-reaction pass.

These decisions do not block viewing the deliverables. No production placement is included.

## Edit in Cut-In Maker

Open `tools/cin04/preview.tscn` to select, play, pause, scrub, frame-step and compare standard/reduced timelines. This subclasses PR #78's preview; it neither saves progress nor edits the source scene while scrubbing.

Editable source scenes:
- `presets/cutins/story/aftermath.tscn`
- `presets/cutins/story/resistance.tscn`
- `presets/cutins/story/fallen_defenders.tscn`

Open a scene and select **AnimationPlayer**. Edit `standard`, `reduced`, or `RESET`. Props under **Framing/Shake/Evidence** and architecture under **Framing/Shake/Set** are native independent nodes. Framing is a presentation canvas transform, never the gameplay Camera2D. Change the evidence framing, timing, character frame/texture, subtitle and fade tracks directly, then save the scene.

Reduced motion retains the full observation and reading time, with a fixed composition and no approach translation or parallax. Idle frames and the discrete lowering pose remain. Switching modes during playback preserves the elapsed timeline position.

All tracks are property/value tracks. Do not add calls that mutate saves, progression, room routing or player movement. The final `handoff` property only ends presentation. `tools/cin04/build_sequences.py` reproduces the initial scenes but overwrites manual timeline changes; it is not needed at runtime.

## Integration boundary

The presentation registry adds `cin04_aftermath`, `cin04_resistance`, and `cin04_fallen_defenders` to the existing `request_cutin(id)` sink. PR #89's StoryDirector remains the owner of eligibility, effects, once/read flags, persistence and state-before-presentation ordering. The presenter writes none of those fields and never calls `request_room`.

The owner must call `cancel("room_loaded")` before a same-room rebuild, death/reset or teardown, as in the existing INT-01 contract. The sink also discards queues on changed room/player identity or death, avoids active duplicates, and releases its input lease on completion/skip/pause/focus loss/watchdog. An active loader or death keeps control ownership. Native inspector scrubbing has no world reference.

This PR is stacked on #86/#78. #81 informs canon and proposal boundaries; #89 is a pinned test-only contract reference, not merged into production. There are no campaign room, player, StoryDirector, save schema, project-setting or approved-art changes. The three previous PR #86 fixtures remain available unchanged.

See [QA and limitations](QA.md) and [reference provenance](REFERENCES.md).
