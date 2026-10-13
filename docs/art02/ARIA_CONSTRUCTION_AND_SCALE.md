# ART-02 Aria construction and scale review

Status: proposed final model references; creator acceptance of model sheets and scale is still required.

## Shared construction

The normal v02 and conditioned v01 turnarounds now use the same body construction. Approved concepts remain authoritative; the earlier normal model-sheet draft is retained for history.

| Detail | Construction rule for review |
| --- | --- |
| Body | Same head size, torso, limb lengths, hips, knees and sole baseline in both states. Conditioned control changes attention/posture rather than anatomy. |
| Hair | Same sandy-blonde high ponytail, short tie and face-framing strands. Group moving locks before animation. |
| Jacket | Cropped charcoal hooded layer; teal lining; hood rests behind neck beneath ponytail. Front sleeve inserts repeat around the sides. Rear uses simple seams. |
| Top and shorts | Same cropped top and waist exposure; matched shorts hem and flat pockets. Rear pocket construction is proposed, not separately approved. |
| Waist tie | Anatomical right hip: viewer-left in a front view. Keep it on that hip when posing; mirroring policy must be explicitly chosen for future sprites. |
| Protection | Separate knee cap, open skin gap, shin shell, ankle strap and boot; keep joints free. Both legs use the same construction. |
| MNEMOSYNE | Conditioned state only. Hairline strip → temple line → compact terminals behind both ears. No crown arch or neck collar. |

Generation QA found a leftover band in the initial normal face closeup; a targeted revision removed it. The conditioned model includes front, right side and back views plus dedicated hairline/side-loop/rear-terminal details. The ponytail partly hides terminals in the full back view; the inset defines their placement.

These images reconcile design intent, not manufacturing geometry. Foreshortening, fine seams, eye construction and protective contours still require final artist acceptance before animation. Do not infer a perfect 3D mesh or machine-accurate orthographic projection from generated turnarounds.

## Active Kaze comparison

Production reference is assets/kaze/cleaned/kaze_idle_strip.png at development base 34be30436996284ec2f783269c40269d321ed427. No historical red-scarf asset is used in this pass.

The accompanying comparison displays exact approved PNGs with viewing crops and scale changes only. It does not redraw either character. Normal and conditioned Aria share the same overall identity.

Kaze has a larger head relative to her body, a more compact youthful silhouette, brighter violet/green clothing blocks and stronger face contrast. Aria's accepted concept is longer-limbed with darker materials and finer face/armor detail. Both use outlined shaded anime rendering, but cast-style compatibility has not been fully resolved. Treat Aria's mature proportions as a proposal to accept alongside Kaze; do not silently replace either approved design. The user must decide whether the difference is acceptable or whether a targeted Aria proportion pass is needed.

## Verified runtime scale evidence

The current player.gd at 12b0c86 uses idle scale 0.2649908807267889, run 0.3825780535911868, attack 0.37875157200639 and traversal 0.33919279345239656. It uses fixed source baselines 591, 491, 498 and 510 respectively. These values supersede the older integration report's initial 80-pixel idle / 0.24 scale.

The final source manifest reports eight 272 × 724 idle/run cells. The active integration report identifies eight 320 × 724 combat/traversal cells. Do not copy one cell size to every character animation by assumption.

Using the manifest's first idle visible bounds, height 367 source pixels × current idle scale = approximately 97.25 world pixels. The eight recorded idle bounds average approximately 96.23 world pixels. This is source/metadata calculation, not a new Godot playtest.

Recommended review candidate: Aria visible standing height approximately 105 world pixels, roughly 1.08 × Kaze's first idle pose, shared exactly by normal and conditioned states. The comparison's small previews are illustrative display crops, not validated sprite exports or integration.

Do not lock canvas dimensions yet. Future canvas planning must allow the ponytail, crouches, airborne poses, hands and oversized effects without clipping. Define a common sole/ground anchor before frame export; leave oversized Air effects separate. Preserve authored registration rather than recentering every frame's alpha bounds.

## Gates still open

Creator must accept the matched model sheets, mature-proportion relationship to Kaze, proposed height, and any final costume corrections. Aria's exact age is not supplied in the brief; stature cannot be derived from an invented age. Sprite-production scope and gameplay animation requirements must be approved separately. No sprite animation production or Godot integration has started.
