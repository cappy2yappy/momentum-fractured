# CIN-04 QA

Godot 4.6.1 stable official `14d19694e`, Windows, native OpenGL/NVIDIA RTX 4070 Laptop GPU.

| Check | Result |
| --- | --- |
| CIN04 runtime, headless | 83 passed, 0 failures |
| CIN04 native authoring controls, headless | 21 passed, 0 failures |
| PR86 legacy fixtures, headless | 25 passed, 0 failures |
| Cut-In Maker runtime regression, headless | 103 passed, 0 failures |
| CIN04 runtime, rendered | 83 passed, 0 failures |
| CIN04 authoring controls, rendered | 21 passed, 0 failures |
| Approved baseline verifier | 0 failures |
| Native-speed rendered recordings | 3 completed; control restored after each |

**336 passing assertions across the final six suite runs.** Raw logs and result manifests are in [qa](qa/). Final runs contain no script errors. Early setup runs found the restricted default APPDATA path and an inherited macOS /tmp sentinel path; the reproducible runner confines both to a writable disposable profile. Early test-fixture namespace/forwarding errors were corrected before these final runs.

## Coverage

Normal completion and early/middle/late keyboard skip for each sequence; synthetic controller B; active duplicate rejection; live reduced-mode switches without rewinding; fixed reduced camera and preserved duration; pause/focus clearing; explicit same-room rebuild cancellation; loader interruption retaining control; death not re-enabling the dead player; stale queued room rejection; missing-sequence and elapsed watchdog recovery; disabling; unknown IDs; exact save sentinel bytes; gameplay camera/progression preservation; native value-only timeline tracks.

The pinned PR89 StoryDirector test places request_cutin before set_flag in the effects array and confirms the director commits the flag before requesting presentation. It dispatches through the real presenter and confirms skip does not roll back director-owned state. This is a contract-level test using the existing world fixture, not a merged INT01 campaign playthrough.

The previous PR86 fixture test uses a disposable copy with its loop scoped to the original COPY IDs, retaining all 25 assertions. The inherited Cut-In Maker test changes only its hard-coded /tmp save path in a disposable copy; all 103 assertions remain unchanged. Original regression files are untouched.

Native preview selector, play, pause, step, scrub and reduced timelines are exercised for all three scenes. Standard screenshots were inspected for framing, text fit, approved Kaze presentation and non-graphic shrouded silhouettes. The revised Fallen Defenders crouch was inspected after the initial standing reaction proved too subtle.

## Timing evidence

| Sequence | Actual completion | Samples | Encoded duration including gameplay return |
| --- | --- | --- | --- |
| Aftermath | 12.013118 s | 249 | 12.44 s |
| Resistance | 14.002800 s | 288 | 14.44 s |
| Fallen Defenders | 16.010011 s | 330 | 16.48 s |

Capture uses Time.get_ticks_usec and actual rendered post-draw frames, with no --fixed-fps. The encoder uses per-frame duration differences and variable frame rate; no acceleration or interpolation. The encodes are silent. Timestamp sidecars accompany each MP4.

## Reproduce

From repository root, with a Godot 4.6.1 executable:
- `python tools/cin04/run_qa.py --godot <absolute executable path>`
- `python tools/cin04/run_qa.py --godot <absolute executable path> --rendered`
- `python tools/verify_baseline.py`
- `godot --path . --script res://tests/cin04/stills.gd -- --test`
- `godot --path . --script res://tests/cin04/capture.gd -- --test`
- `python tools/cin04/encode_capture.py` (requires ffmpeg)

In a restricted Windows shell, set APPDATA for the capture process to a writable disposable directory, as the QA runner does. Do not redirect or edit the normal game save.

## Limits and pending acceptance

- No campaign trigger, room placement, production StoryDirector change, migration or final art adoption.
- Reduced motion is verified in runtime and authoring tests; the three delivery videos show standard playback.
- Windows native rendering was executed. macOS, physical controller hardware, exported standalone builds and full combined INT01 campaign QA remain untested.
- Environments and covered-figure props are authored native-vector review staging; final environment art and bespoke grief animation remain a creator/art decision. Kaze uses approved sheets without pixel changes.
- All new Resistance/Fallen Defenders prose, casualty count, interpretation, precise events, identities and locations are review proposals. No named death or future reveal is confirmed.
- No audio production is claimed.
