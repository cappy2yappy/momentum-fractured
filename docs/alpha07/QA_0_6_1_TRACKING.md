# Alpha 0.6.1 QA tracking (kept separate from Alpha 0.7)

Subject: Candidate 3, `candidate/wave3-targeted-3` at `c2170032d08ea55268313e0020676c743251deab` (draft PR #77). Creator verdict: needs work, 3 of 28 checklist items complete. Not an acceptance. Nothing here is waived.

## Counted failures (QA W6, 162 pass, 8 fail, 6 skip)
| Check | Status | Note |
|---|---|---|
| W3-STAIR-ASCEND-NO-LETTERBOX | FAIL | 7.8% vs 2% gate, creator decision |
| W3-STAIR-DESCEND-NO-LETTERBOX | FAIL | same |
| W3-DOOR-CANAL-OUT-FULLSCREEN | FAIL | Canal is a world-camera presentation, informational per PM, not waived |
| W3-DOOR-CANAL-IN-FULLSCREEN | FAIL | same |
| W3-DOOR-CANAL-OUT-NO-LETTERBOX | FAIL | same |
| W3-DOOR-CANAL-IN-NO-LETTERBOX | FAIL | same |
| W3-DOOR-CANAL-OUT-KAZE-SCALE | FAIL | same |
| W3-DOOR-CANAL-IN-KAZE-SCALE | FAIL | same |

## Failures outside the 176 counted
| Check | Status | Note |
|---|---|---|
| ART08:true_animation | FAIL | door_turn_to_side PNG missing |
| W3-REACH-ROUTES vs c49 | FAIL | R13 2>0, R15 0>1 (base inconclusive, needs Level), R16 2>0 |
| W3-REACH-ROUTES vs pr51 | FAIL | same |

Total real automated failures: 11.

## Skips (6)
Four cancel-timeout (watchdog), two roof-visible (human check).

## Other open 0.6.1 items
Missing door_turn_to_side, door_turn_to_rear stand-in, residual descent art flaws, pier wall-slide (about 1.2 s, pre-existing), universal roof not approved (roof-on and `--ld05-open-top` both stay), Level creator questions (pit penalty, service routes R9/R10/R13/R16/R17/R20, 38 strips beyond doors), no validation on Windows/macOS graphics, gamepad, FPS or full campaign.

## Rule
Alpha 0.7 work must not change any row above, and no row is closed by an Alpha 0.7 PR.
