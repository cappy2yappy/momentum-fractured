# TR-03 — accepted-versus-new asset audit

| Asset / source | Observed state | Approved use / limitation |
| --- | --- | --- |
| assets/kaze/cleaned/kaze_idle_strip.png | 2176×724,8cells,baseline591,scale0.264990881 | Current approved identity/upright reference; no newly approved rear pose |
| assets/kaze/cleaned/kaze_run_strip.png | 2176×724,8cells,baseline491,scale0.382578054 | Reuse current run for running approach/continuation; cannot relabel it as walk |
| assets/kaze/cleaned/kaze_combat_strip.png | 2560×724,8cells,baseline498,scale0.378751572 | Preserve combat art; not used as a door turn |
| assets/kaze/cleaned/kaze_traversal_strip.png | 2560×724,8cells,baseline510,scale0.339192793 | Preserve current jump/wall/tether/dash mapping; no accepted stair cycle present |
| assets/web/kaze_*.png | Original approved sheets retained | Historical identity/proportion comparison; no replacement or re-slicing |
| ART-01 biome board / layered prototypes | Published under PR#11; creator continuity record permits placeholders, not production acceptance | Reuse village warmth, city indigo/rose restraint, culvert architecture vocabulary without regenerating concepts |
| TR-02 scripts/mixed_transitions.gd | Existing run/walk pilot and wind-cloth graphic; source reviewed at e9a2d1a | Preserve comparison; lane B owns no implementation edit |
| New door/stair/walk art | Required; not in current accepted clip set | Only schematic key-pose/storyboard and frame specs supplied now; no claim of finished character frames |
| Structural backing kit | Original technical concepts in this branch | Review-only visual supports; never add collision or repaint traversal edge semantics implicitly |

Current controller does not contain a separate walk clip: low-speed ground movement selects the same run sheet. This visual limitation is explicitly separated from approved gameplay speed. A new walk cycle fixes presentation later, without altering locomotion.
