# EN-02 executed validation

Official Godot `4.6.1.stable.official.14d19694e`, Windows, NVIDIA RTX4070 Laptop OpenGL3.3 driver591.44. Base PR87 `5172db6898f3efc35b74f3c134293049165b9bf7`.

| Check run here | Result | Scope |
| --- | --- | --- |
| `tests/en02/behavior.gd`, headless | 61 checks, 0 failures| Two actual prototype scenes, real player interfaces, conservative threat envelope and actual damage-edge probes |
| Same test, native renderer | 61 checks, 0 failures| Same behavioral checks under Windows OpenGL; test-only HUD removal avoids unrelated OS-focus pause |
| Existing `tests/en01/framework.gd` | 52 checks, 0 failures| Actual unchanged existing encounter validation, combat, persistence fallback and cleanup |
| `tools/verify_baseline.py` | 0 failures| Approved sprite/controller preservation contract |
| Git diff of all 715 pinned tracked files |No differences| Existing tracked source/resources unchanged; new paths only |

Focused tests cover complete-batch managed registration; HP and warning limits; no dormant/wake damage; locked facing; interruption by lost player input ownership; fresh grace on control return; real facing parry/melee/dash; existing v8 disk serialization and loading; deferred completion/persistence during transition; no duplicate completion or respawn after restoration; bounded retreat, cooldown and edge rejection; same-platform lunge; harmless landing; teardown during movement. The final 15 added checks exercise actual inherited strike reach/rear/vertical boundaries and a 300ms-step lunge at its conservative outer warning edge. No mock damage method is used.

Earlier local failures were a new-script type-inference error, then a test attempting dash while the existing attack animation still owned its cooldown. The script type was made explicit and the fixture now waits for the actual attack to finish. No controller timing was changed. The initial import emitted preexisting MetSys/editor RID/ObjectDB shutdown diagnostics. Final combat suites completed with zero script errors or nonzero exits.

## Reproduce in a disposable profile

Set APPDATA to a dedicated empty test folder. Never point tests at a normal gameplay profile. From the source root:

```powershell
& $godot --headless --path . --script res://tests/en02/behavior.gd --quit-after 2400
& $godot --path . --rendering-method gl_compatibility --audio-driver Dummy --script res://tests/en02/behavior.gd --quit-after 2400
& $godot --headless --path . --script res://tests/en01/framework.gd --quit-after 5000 -- --test
python tools/verify_baseline.py
```

The new native tests deliberately remove the inherited HUD **inside the test fixture only**, then unpause the tree; the interactive scenes keep the real HUD. These tests prove combat/control-state behavior, not native OS focus handling, UI usability, physical-controller input, or QA10 certification.

## Native footage and timing

`tests/en02/capture.gd` records actual Windows-rendered frames at approximately 12Hz with wall-clock timestamps while scripted inputs drive the approved player. `encode_capture.py` uses each measured interval in a variable-frame-rate MP4; no speed-up/slow-down is applied. Each clip is approximately 14 seconds at 1280x720 and camera zoom 1.0. They show actual prototype warning/strike/recovery and jump/dash/parry/kunai attempts, not a human balance session. Dedicated parry, damage, defeat/reload and teardown assertions are established by the automated suites, not inferred solely from a video.

The labelled amber warning now conservatively contains travel plus inherited forward reach, 14px rear tolerance and 85px vertical extent. It is distinct from the movement cue and the 42px radius marker. This addresses the coordinator's readability finding; older captures without the envelope are superseded and stay private.

Private MP4s, raw PNGs, profiles and detailed timestamp streams remain local under `docs/gameplay/en02/private-capture/`, ignored by Git. `EVIDENCE.json` contains hashes, timings and measured performance; code and textual reports/logs are the only publication payload. Original approved art and all six licensed raw packs remain untouched.

Performance is measured separately with readback disabled using `measure_native.py`. Its process CPU total includes startup; the frame p50/p95 comes from14 seconds of actual process frames in one lab. Capturing PNGs adds substantial frame stalls and those captured frame times are not a 60fps certification. Hardware, background load and the simplified lab limit all performance conclusions.

Final direct-engine sample: 2,029 process frames over14.006s; frame p50=6.919ms, p95=8.252ms with readback off. The actual engine process consumed4.9375 CPU seconds during15.438 wall seconds including startup (31.98% of one logical core on average). The initial console-wrapper CPU measurement was discarded because it measured the launcher; the helper now rejects that executable. This is one simplified lab on one Windows GPU, not a campaign, low-end or macOS performance promise.

## Pending

Creator balance and visual acceptance; missing slime action drawings; true physical-hop design if requested; combined enemy/hazard fairness; exact Level territory/clearance approval; authoritative INT01/GP09 combined-tree validation; save tests on that final composition; physical controller, macOS, exports and full campaign playthrough. Current Studio/QA10 certification is unrelated and not claimed.
