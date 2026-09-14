# Kaze: Canal Route — recovery milestone

This is a reconstruction of the September Godot prototype from recorded source.
Open **rebuild/project.godot** in Godot **4.6.1** and press F6 on scenes/main.tscn, or F5.
The repository-root project is the older March prototype.

## Status
Source restored, not yet alpha quality. The recovery commit has not been locally executed.
CI must pass the actual-engine playthrough before distributing its Windows/Web artifacts.
Earlier test results do not certify this reconstruction.
Legacy sprites and blockout scenery are temporary; restore the approved purple/green Kaze
and painted canal assets before judging visual fidelity. Legacy strip frame sizing requires review.
No claim of 60 FPS, physical mobile testing, five bosses, or 30 minutes of content.

## Route and controls
Two 2600×1440 rooms. Head right from the shrine, use the passage, parry/defeat
the guard, collect Windstep, return, climb to the rooftop relay, and press E.
An optional upper-room letter restores health. Falls land on solid floors.
A/D or arrows move; double-tap direction runs; Space jumps.
LMB/J attacks; RMB/F/K parries. Attack during recovery to queue a three-hit combo.
E interacts; M opens the map; Esc pauses. Touch controls support separate fingers.
The shrine heals and saves. Upgrade/relay progress saves on acquisition.
A separate save filename prevents overwriting older prototype saves.

## Build and test
Install Godot 4.6.1 and its matching official export templates.
From this directory:
```sh
godot --headless --editor --import
godot --headless --script tests/playthrough.gd -- --test
mkdir -p build/windows build/web
godot --headless --export-release Windows build/windows/Kaze.exe
godot --headless --export-release Web build/web/index.html
```
Windows: extract the artifact ZIP and launch Kaze.exe.
Web: serve the entire build/web directory over HTTP; opening index.html as a local file is insufficient.
The GitHub workflow retains successful build artifacts for 14 days. It does not deploy the existing website.
Keep source commits in GitHub at every working milestone.

## Next alpha gates
- Inspect and correct all sprite frame boundaries and fixed-scale jump/run registration.
- Restore approved art and improve scenery, transitions and combat sound/feedback.
- Test restart/death, touch cancellation, portrait/landscape and map interactions on actual devices.
- Profile frame-time distribution with a 16.7 ms target on named Windows/mobile devices.
- Expand only after this loop passes: distinct enemies, five boss encounters, larger connected regions,
  secrets and earned movement abilities. This recovery milestone is not the full alpha.
