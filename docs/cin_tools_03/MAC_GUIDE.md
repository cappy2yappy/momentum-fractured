# Tonight's Mac authoring workflow

Tested on macOS Apple M4 with **Godot 4.6.1.stable.official.14d19694e**, native OpenGL. Studio is the existing Cinematic Studio 2.0 scene, extending Cut-In Maker's transport. No plugin installation or seed rebuild is needed.

## 1. Launch directly

Install the Godot 4.6.1 application as `/Applications/Godot.app`. In this checkout, double-click `tools/cin_tools_03/launch.command` in Finder. It is executable and opens Studio directly. The tested Terminal equivalent, which also works when Finder does not open `.command` files in Terminal, is:

```sh
cd "/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/cin-tools-03"
zsh tools/cin_tools_03/launch.command
```

For a checkout elsewhere, change only the `cd` path. The launcher resolves its own project root, checks the engine version, and prints its log path. It also finds `~/Applications/Godot.app`. For another installation path:

```sh
GODOT_BIN="/absolute/path/to/Godot.app/Contents/MacOS/Godot" zsh tools/cin_tools_03/launch.command
```

An absent engine or a version other than 4.6.1 produces a specific Terminal error. The launcher never runs `build.gd`. Studio starts in **Animator** with a detached seed clip. On every new launch, press **Reload** to open your previous saved session.

## 2. Select, pose and key

**New direct controls:** [click/drag joint guide and native demo](DIRECT_FK.md). At 1.9 s, click a cyan dot, drag to move, or drag its gold grip to rotate. Alt-drag also rotates. Undo restores one drag; Key pose explicitly commits the preview. Hand and Boot child pivots are included. Fit/150%/200% changes the canvas view only. Numeric fields below remain available.

1. Leave **Reduced motion** off. In **Timeline (seconds)**, enter `1.9` and press Return. You can also drag the slider or use **Step 1/60 s**. Timeline numbers show sequence time; the nearby readout also shows local clip time.
2. In the joint selector on the right, choose **Torso**. It is an existing joint in `Rig/Torso`. The gold joint ring identifies the selection; green dots below the timeline show that joint's rotation keys.
3. Enter `12` in **Rotation (degrees)** and press Return. This previews the pose. Press **Key pose** to store position and rotation at the playhead. The confirmation gives the local clip time. Scrubbing discards unkeyed previews; Save asks you to key them first.
4. Scrub around `1.9` to see the interpolation. **Restart**, then **Play**, previews at native **1.0×** speed. **Pause** stops playback. **Undo** restores the previous keyed edit; **Remove rotation key at playhead** removes only a rotation key, keeping position keys.

The stage fits the window. At 1280×720 and 1440×900 the inspector has more space; 1024×640 is the supported minimum. Scroll **inside the right inspector** to reach lower pose/view controls on a small window. The joint selector begins at the top; **Key pose**, **Undo**, **Save clip + shots**, **Reload**, and the timeline stay visible outside that scroll area. Use the window's edges to resize it normally.

Hybrid follows the clip: approved run-sheet frames, a short 1.42–1.58 s blend, then the candidate cutout rig. **Rig only** and **Sprite only** are temporary inspection modes; they are not stored as clip edits. Pose the rig after 1.58 s to see it clearly. This is a timing and authoring study; foot contact and flat-art seams remain unfinished.

## 3. Save, close, reopen and reload

1. Press **Save clip + shots**. Wait for **Saved clip + both shots. Ready to reopen.** A failure message keeps your in-memory edit; do not close until the save succeeds.
2. Press **Open saved folder** to reveal the exact folder in Finder. Hover over the folder label for its absolute path.
3. Confirm these files exist:
   - `sprint_stop.tres` — standalone reusable Godot `Animation`.
   - `director_shots.tres` — standalone native Director tracks.
   - `studio_session.tres` — native `AnimationLibrary` containing the matched clip and shots. This is the authoritative reload snapshot, replaced atomically.
4. Close the Studio window. Run the same launcher again, then press **Reload**. Studio reports **Reloaded. Both Director shots share this clip.**
5. Enter `1.9`, choose **Torso**, and confirm **12°** is restored. The automated QA performs this same round trip using separate writer and reader OS processes, with disposable files.

Ordinary creator files live at `user://cin_tools_03/`, beneath Godot's application user-data directory. On this Mac that is `~/Library/Application Support/Godot/app_userdata/Kaze — Silent District Alpha 0.5.0/cin_tools_03/`. Studio does not save to the gameplay save file or overwrite the repository seeds. Save replaces the previous Studio session; copy the three files to another folder in Finder to keep named versions. Keep the snapshot and exports together. If you edit only an exported `.tres` externally, Reload continues to use the snapshot; it does not silently combine mismatched files. The previous two-file Studio format is accepted only when both files validate and no snapshot exists.

## 4. Reuse the exact clip in two shots

1. Select **Director** in the workspace menu at the top right. The same loaded clip is sampled twice: shot 1 at `0–4.2 s`, shot 2 at `4.2–8.4 s`. No duplicate pose authoring is needed.
2. Enter `1.9` and confirm the Torso pose. Press **Shot 2**: sequence time becomes `6.1`, local clip time stays `1.90`. The same 12° pose appears again. **Shot 1** returns to the matching time in the first shot.
3. Choose **Shot framing • Director** in the joint selector. At shot 2, enter **X = -70**, **Y = -35**, **Shot zoom = 1.15**, **Rotation = 0**, pressing Return after each. Press **Key pose**. This sets the current shot's framing as a constant native track; it leaves the other shot's framing independent.
4. Use **Shot 1** to inspect its wide framing, then **Shot 2** to inspect its closer framing. Clip joint edits still affect both. Press **Save clip + shots** again to keep the framing too.
5. Press **Restart**, then **Play**. Watch the whole 8.4-second sequence at **1.0× real time**. The gold timeline divider marks the cut. There is no speed override.
6. Toggle **Reduced motion**, then **Play** to check the equal-duration static alternative: final actor pose, fixed framing, no inherited shot rotation. Editing is disabled during reduced preview. Turn it off to resume authoring.

The other workspace options — **Special transition**, **Major biome**, **Boss intro** — open the original Cut-In Maker presets. Their native timelines and reduced previews are preserved. Studio previewing does not trigger room traversal.

## Review resources and recording

The committed authored example has the Torso key and two independent framings described above:

- `res://presets/cutins/studio/authoring_example/sprint_stop.tres`
- `res://presets/cutins/studio/authoring_example/director_shots.tres`
- `res://presets/cutins/studio/authoring_example/studio_session.tres`

The [native-speed review](captures/native-speed.mp4) loads that saved snapshot in a fresh process before playing the sequence. To inspect it interactively without changing the delivered example, copy it into a disposable profile, launch and press Reload:

```sh
mkdir -p build/cin_tools_03/example_profile
cp presets/cutins/studio/authoring_example/*.tres build/cin_tools_03/example_profile/
CIN_STUDIO_SAVE_DIR="$PWD/build/cin_tools_03/example_profile" zsh tools/cin_tools_03/launch.command
```

Malformed, missing, executable-track, unknown-path, mismatched-duration and nonfinite resources are rejected before replacing the current clip/shot pair. External/script dependencies are rejected before resource instantiation. Reload failures retain current resources and undo history. See [scoped QA](QA.md) and [draft handoff](HANDOFF.md) for exact coverage and remaining acceptance.
