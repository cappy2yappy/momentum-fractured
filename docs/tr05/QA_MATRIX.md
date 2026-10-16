# TR-05 QA and regression matrix

Official Godot4.6.1 / native Windows / NVIDIA RTX4070 Laptop, OpenGL3.3. Baseline PR37 b950373. Final runtime f168339. No controller, collider, graph, save-schema, progression or original artwork change.

| Requirement | Evidence / result | Limit |
| --- | --- | --- |
| Canal-left automatic | Real A-key R13→R0 walking and double-tap sprint; no E | Seeded Windstep fixture, not earned campaign |
| Bidirectional R13 | Real R13↔R14 crossing, stop, held E, then real reverse in same scene | Sprint fixtures need enough travel time to cover their longer stopping distance |
| All ordinary side passages |39 endpoint directional requests,0.65s load completion, correct inward facing, capsule overlap checks | Not39 human-playtested passages |
| Meaningful E entrances |19 depth/stair/special endpoints retain explicit interaction; shortcut attunement controllers unchanged | Interior entrance presentation may use approved-idle fallback |
| Wrong height/direction/tether | Required pilots reject high, backwards-velocity and attached-tether crossings | Maximum physical swing envelope not swept |
| Loop protection | Outward intent, sampled crossing, inward16px rearm,0.45s arrival cooldown; stationary and held E checks | No proximity-only activation |
| Gates/progression | Existing can_enter/allowed functions exact; negative archive/Windstep and full progression suites pass | Original progression design unchanged |
| Arrival safety | Inward64px landing, nearest existing top within40px; R9 repaired solid-top arrival retained | No save/checkpoint coordinates globally migrated |
| Stair movement |72×36 local ascending/descending render path; distinct ART04 up/down keys | Held drawings are not finished gait cycles; actual body stays frozen during loader |
| Camera | Bounded1.55x close-up; sine envelope blends lens, focus and offset back to recorded gameplay state | No cinematic streaming; discrete0.65s loader remains |
| Reduced motion | F6/CLI; stationary pose and camera, plain fade; on-transition toggle restores state | Preference is session-only, preserving save schema |
| Abort/cleanup | Pause, respawn, rebuild and F6 restore camera/character visibility | Paused presentation can fall back to normal loader after resume |
| PR37 geometry | Bellroof builder byte-exact;25-suite batch includes intentional_space and full room-signature audit | Creator's conditional lower-route acceptance is preserved, not expanded |
| Saves/physics/art | Baseline verifier and PR37 preservation pass; movement/combat/sprite/save suites | No physical gamepad/native macOS/campaign/FPS certification |

Final source batch: **25 suites /1,607 passing assertions**, zero failed assertions or script/parser errors. Four explicitly historical presentation suites run with `--tr05-legacy`; the other21, including new policy and LD03, run the new default. New policy suite independently exercises all58 classified endpoints,39 automatic and19 meaningful interactions. Do not present legacy-mode tests as TR05-native proof.

Native Windows fixture: **54 passing checks**, including walking and real double-tap sprint, held-E stationary waits, eight actual reverse round trips and both stair directions in normal/reduced modes. Raw final log and exported-resource proof are retained separately. Seven real `.cmd` launchers are waited from a path containing spaces; startup banner and script/parser errors checked. ZIP/PCK audit verifies compiled cinematic script and absence of shipped test/doc/build/tool/source_art resources.

Commands: `python tools/run_tr05_qa.py --godot <Godot4.6.1-console>`; `python tools/verify_baseline.py`; `python tools/verify_tr05_preservation.py`; native `--path . --fixed-fps60 --script res://tests/native_cinematic_transitions.gd -- --test` (supply separate `--fixed-fps 60` arguments); exported resources use `tests/packaged_cinematic_transitions.gd`; `python tools/smoke_tr05_launchers.py`. Every test uses disposable data.

Failures corrected rather than hidden: old tests assuming E or exact threshold arrivals were updated to assert new automatic/safe-arrival behavior. Native sprint reverse fixtures initially held direction only22 ticks, insufficient after longer sprint stopping;40-tick approach passes without changing player physics. An initial native probe overlapped first import and failed script loading; settled-import runs supersede it. Older PR33 package proof attempted evidence output into mounted read-only res://; absolute output fixes that harness. Fresh launcher argument forwarding was corrected before final seven-launcher checks. Current inherited editor/export RID/ObjectDB cleanup diagnostics remain; they are not script/assertion failures.

Final exported-resource fixture:54/54,0 failures; seven EXE launchers7/7. [Raw exported-resource log](evidence/packaged-native.log). Hosted build38933528377 succeeded from f168339; reported artifact digest/expiry is in hosted-artifact.json. Hosted cross-export and local Windows proof are separate evidence; no native Mac claim.

Committed log transcripts normalize Windows CR/newline/trailing whitespace only. Original and normalized byte hashes are recorded in log-transcript-hashes.json; no failed checks are removed.
