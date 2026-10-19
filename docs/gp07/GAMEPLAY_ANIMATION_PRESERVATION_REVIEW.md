# GP-07 — Gameplay feel and animation preservation review

Reviewer: Gameplay Masta (Codex). Date: 2026-10-19. Status: independent source review complete; implementation and runtime acceptance pending. Claude owns TR-08 and ART-08. This change is documentation only; no controller edit, merge, or approval of new animation is implied.

## 1. Evidence and scope

The reviewed gameplay is the `scripts/player.gd` instantiated by `scripts/world.gd` (`Player` preload and `Player.new()`), reached through `scenes/main.tscn`. Other historical player scripts are not the active baseline. Main is not the gameplay reference.

| Reference | Exact reviewed head | Use |
| --- | --- | --- |
| PR30 | `a6b76b9938825307bdcd4efb687c7198ea0d8681` | Approved ART04 art identity and registration; four held keys, not completed cycles |
| PR39 | `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` | Approved movement/control reference |
| PR41 | `60859a861b4dbcde25f2fe274bae7400bd9eb11b` | Manifest, candidate adapter and transition handoff |
| PR51 | `baedd6786ad4bee2123ea872b437bbb98e6d2721` | Review branch base; passage reliability fix |
| PR57 | `903634afa51237e29fd306ae815c880415230f17` | Staged stair, world integration and pilot data |
| PR60 | `1cf2693a40dd67fe7fe03bc3ae05689e22b4caea` | Coordinator evidence and limits |

Read the actual player, world, HUD, cinematic/embodied/art04 adapters and PR57 staged implementation, plus PR41 adapter and manifest. Player and HUD have no diff between PR39 and PR57. References below use repository paths and function names against these immutable pins. New TR08/ART08 branches were not treated as accepted baselines or modified.

Local verification: `python tools/verify_baseline.py` and `python tools/verify_tr05_preservation.py` both returned zero failures on the PR51-based review branch. No Godot executable was found on PATH. No native playtest, runtime reproduction, new timing measurement, visual seam certification, gamepad check or FPS result is claimed. PR60 test counts are prior evidence, not tests executed by GP07.

## 2. Preservation contract

Animation must consume gameplay state. It must not become the clock for acceleration, impulses, collision, attacks, input eligibility or progression. No root-motion track may drive the live body. Any controller change requires explicit PM approval, including an apparently harmless animation hook. Preserve the following values **and execution order**, not merely their numeric literals.

| System | Actual baseline in `scripts/player.gd` | Requirement |
| --- | --- | --- |
| Horizontal | Walk 400; sprint 600; stride_1 multiplier 1.05; sprint-only momentum multiplier when prototype enabled | Preserve double-tap run window <0.25 s; release with no direction clears run; preserve excess momentum rather than imposing a new speed cap |
| Acceleration | Ground 2600; air 1200; grounded no-input braking 2600 | No animation anticipation delay, turn lock or blend-driven velocity |
| Jump | Buffer 0.16 s; coyote 0.12 s; impulse -900; gravity 1800; release clamp -360 | Same early release, apex and landing response; no mandatory landing recovery |
| Wall | Falling wall slide caps downward speed at 100; wall jump (normal.x ×480, -880) | Preserve repeated wall jumping and legitimate vertical routes; animation is not permission to add ceilings or cooldowns |
| Double jump | -900; consumes air_used; floor and successful tether reset it | No extra/removed jump from animation state transitions |
| Dash | 920 horizontal; 0.18 s; cooldown 0.58 s; invulnerability at least 0.24 s; ghosts every 0.03 s | Preserve tether release before dash impulse and attack restriction |
| Grapple | Range 440 default, clamp 80–480; origin y=-55; forward/height/path checks; pump 130; gravity 1800; release cooldown 0.2 | Preserve swing integrator, momentum, collision release and jump-button release behavior |
| Melee | Durations 0.36/0.41/0.57 s; strike thresholds 0.105/0.12/0.20 s; damage 1/1/2; reach 95/95/115 | Gameplay emits strike once; never move hit timing into frame events. Queue only when attack_time >0.1; grounded attack halves target speed |
| Other combat | Parry 0.23 s / cooldown 0.48; kunai cooldown 0.32; damage invulnerability 1.2 s | Keep input restrictions, feedback and projectile timing |
| Body | Capsule radius 14, height 60, local y=-30; layer 2, mask 1 | Sprite size, pose or camera zoom must not resize this body |

Input edges are processed before hitstop's early return. Dash and tether branches return before normal attack timer advancement. These details can produce apparent animation/timer conflicts; they are existing behavior, not an invitation to silently rebalance combat. Use separate fixtures for default movement, stride upgrade and optional momentum mode.

## 3. Animation state and timing audit

`player.animate(dt)` assigns states in order; the last applicable assignment wins:

`idle → run if |vx|>40 → airborne → wall → tether → attack → dash`.

| State | Playback now | Integration implication |
| --- | --- | --- |
| Idle | 8 frames, 0.16 s/frame, 1.28 s loop | Visual only; must yield immediately to input/gameplay |
| Run | 8 frames, 0.08 s/frame, 0.64 s loop | Triggered by speed, not run flag; walk-speed movement also uses this strip |
| Air | Traversal held frames 1/2/3 at vy thresholds -150 and +150 | Do not introduce jump startup or apex locks |
| Wall / tether | Traversal frames 5 / 6 | Preserve priority and release on actual physics state |
| Attack | 8 frames sampled from elapsed attack_time / combo duration | Cosmetic retiming must retain strike thresholds; same-clip combo restarts use timer, not animation_clock |
| Dash | Traversal frame 7 while dash_time >0 | Last dash tick decrements timer before animate; verify its handoff rather than extending dash to finish a drawing |
| Parry / hurt | Parry arc and invulnerability alpha; no dedicated clip | New art must preserve readability without taking input ownership |
| Long-idle / crouch / slide | No such active player state or input in this reviewed implementation | Treat as new presentation/design requirements, not completed features |

`animation_clock` resets only when the clip name changes. Air/wall/tether/dash share traversal; phase must not leak into future multiframe states. Clock freezes when player physics is disabled or hitstop returns early. A separate renderer clock must not unintentionally animate combat through hitstop.

Registration is intentionally clip-specific:

| Clip | Cell width × height | Uniform scale | Foot baseline in source pixels |
| --- | --- | --- | --- |
| Idle | 272×724 | 0.2649908807267889 | 591 |
| Run | 272×724 | 0.3825780535911868 | 491 |
| Attack | 320×724 | 0.37875157200639 | 498 |
| Traversal | 320×724 | 0.33919279345239656 | 510 |
| ART04 / ART05 candidate | 320×724 | 0.303125 | 600; pivot (160,600), offset (0,-238) |

Do not normalize all strips to one scale: transparent padding and drawn proportions differ. Numeric scale differences alone do not prove a visible size pop. Compare rendered head/torso and planted foot registration at zoom 1, both facings, and identical ground anchors. Review cinematic zoom separately from character size. PR41 supplies only a four-frame 20fps (0.20 s) right-to-rear turn candidate; entry is WIP and stair rejected. Its adapter requires explicit candidate opt-in and refuses WIP. Do not use rear art as front emergence, reverse ascent into descent, or assume mirrored keys are approved.

## 4. Independent findings and risk assessment

| ID / priority | Evidence | Consequence and required response |
| --- | --- | --- |
| GP07-01 / high | HUD `_input` directly calls `player.press(action)` for touch, without a physics/transition guard. `press` itself has no lock guard. Loader and staged intercept only disable physics and clear existing touches. | New touches during a lock can set jump_buffer, attack/dash/parry state or emit kunai/tether signals. This is a source-confirmed ingress gap; in-engine reproduction remains pending. TR08 must cover all input ingress, not only keyboard physics polling. Any controller fix needs PM approval. |
| GP07-02 / high | PR57 `restore` deliberately leaves physics to loader if cancelled in `load`; the load watchdog calls restore but does not clear world.transition/pending_room or enable physics. | A stalled loader is not covered by a blanket “control always returns” claim. Normal loader completion may recover; a stuck clock may not. Force watchdog in each phase, especially load, and prove bounded recovery with coherent room/pending state. Do not just enable physics mid-swap. |
| GP07-03 / medium | PR57 freezes physics for enter/arrive; world and other actors are not globally frozen. Player timers freeze; HUD remains ALWAYS. | Define enemy/projectile and damage behavior during the extra hold. Do not grant permanent invulnerability or let invisible player take unexplained hits. Treat any changed damage/timer policy as PM-reviewed gameplay work. |
| GP07-04 / medium | Loader preserves many player timers; `request_room` does not clear attack/queued/jump_buffer/dash_time. PR57 intercept zeroes velocity but not these states. | In-flight actions can resume on arrival, or touch can create new ones during lock. Preserve existing ordinary-passage semantics; explicitly decide meaningful-cinematic action cancellation versus suspension. Test both rather than clearing every timer. |
| GP07-05 / medium | Multiple owners: world loader, embodied proxy, cinematic camera, staged proxy; staged restore forces sprite.visible=true. | Cancellation can restore an outdated visibility/camera state or collide with death/respawn ownership. Use one transaction owner and idempotent release; no late callback may restore a previous room/camera. |
| GP07-06 / visual gate | Gameplay↔ART04 switches texture grid, registration and pose; PR57 approach uses smoothstep over 0.25 s with fixed run cadence, then held key, arrival idle restarts from frame 0. | Potential foot sliding, pose/size seam and phase pop; not certified observed defects. Capture each boundary. No fake gait by translating a held key; labels remain until accepted cycles exist. |
| GP07-07 / state conflict | Attack outranks tether visually, but tether branch does not advance attack_time; no dedicated parry/hurt pose. | Preserve existing mechanics while reporting misleading pose combinations. Do not “fix” by blocking grapple or shortening combat. PM decides any behavioral correction. |

PR51's recovery logic must survive: outward intent, matching height/support, inward arming, tether rejection and cooldown. Preserve specific locked-route hints. A cinematic or long-idle must not consume the crossing sample or require E on Canal-left/R13↔R14.

## 5. Recommendations for ART08

- **Idle:** retain existing gameplay size and planted root; secondary cloth/hair/breathing can loop independently. No hitbox breathing, body bob that moves collision, or repeated clip restart every frame.
- **Long-idle:** proposed eligibility is grounded, stationary, no action/queued action, no damage/hitstop, no active UI or transition. A proposed 6 s threshold is a design choice for PM, not existing canon. Reset on input, displacement, leaving ground, combat, pause and cinematic. Interrupt within the same eligible physics tick; never wait for a flourish to finish. No reward, save flag or stamina effect.
- **Crouch:** scope must be settled explicitly. A cosmetic pose must not advertise traversal clearance the unchanged capsule cannot provide. Real crouching, sliding, speed changes, smaller collision or stand-up clearance checks are controller work requiring PM approval. Do not infer crouch support from an unused historical script. An isolated art preview is safe pending that decision.
- **Transitions:** separate approach, turn, entry, traverse, emerge and return-to-profile clips, with direction and ground-contact metadata. Keep rendering registration in an adapter; preserve source/destination facings and safe arrival placement. Fallback to approved art if a clip is absent or rejected.
- **Polish:** improve silhouettes, contact alternation, cloth follow-through, grounded shadows and foreground occlusion. Drive run presentation from measured movement only if its baseline cadence/feel remains accepted. Do not add camera shake, squash, mandatory anticipation or input delays to sell weight.

## 6. TR08 input/control restoration checklist

Treat each accepted cinematic as a transaction with a unique generation and source/target. Plain automatic passages retain the existing 0.65 s loader; they do not acquire a staged hold. PR57 opt-in R14→R17 is 0.85 enter +0.65 load +0.85 arrive =2.35 s; reduced =0.95 s. Reverse R17→R14 is not opted into that sequence. These are review baselines, not approval to make staging default.

- [ ] Validate route, gate, current transition and player viability before acquiring control. Rejected requests leave no proxy, camera override or lock.
- [ ] Snapshot only owned presentation/process state; identify loader versus cinematic ownership. Keep gameplay facing and display facing distinct.
- [ ] Gate keyboard, gamepad, touch and direct action dispatch consistently. Continue accepting pause/accessibility controls. Clearing touches at entry alone is insufficient.
- [ ] Define edge policy: recommended no attack/dash/jump queued by presses occurring solely during a meaningful cinematic; held directional input sampled on first unlocked tick. Do not globally release OS input or reinterpret an old E as a second request. PM must review changes to existing timer semantics.
- [ ] Keep gates, room swap, arrival support and cooldown/rearm under existing world/passage ownership; never derive arrival position from a proxy foot.
- [ ] On completion, dispose of proxies/overlay, restore camera zoom/position/offset/smoothing, and restore owned visibility/modulation. Exactly one live player visual remains.
- [ ] Restore eligible control by the next physics tick after release. No full animation loop is required. Correct run/air/attack state renders immediately; no forced idle frame over an active action.
- [ ] Test pause, map, loadout and focus loss in enter/load/arrive. Paused game must stay paused; resuming must not retain a cinematic lock. During load, preserve a coherent loader transaction rather than prematurely enabling movement.
- [ ] Death/respawn, fall recovery and external room rebuild invalidate the old transaction. Old callbacks must not reposition or re-hide the new player.
- [ ] F6 during each phase shortens remaining motion without extending/restarting the lock; plain/reduced avoid zoom, moving proxy and animated wipe as specified by their mode.
- [ ] Force stalled enter, load and arrive paths; bounded recovery must reconcile pending_room, transition, sprite, camera and process flags. PR57's >4 s non-load watchdog and >2 s load watchdog are not proof until exercised.
- [ ] Cleanup is idempotent under repeated cancel/rebuild/F6. Record reason, source, target and elapsed time for QA.

## 7. Regression scenarios and acceptance gates

Run on immutable control and candidate SHAs with identical engine, physics tick, initial position, progression, RNG where applicable and input events. Record per-tick position, velocity, facing, grounded/wall/tether status, action timers, strike/projectile events, room and lock state. For presentation-only changes, paired traces must match (within 0.01 world px only for floating point comparison); event ticks and eligibility must match exactly. Any intentional exception requires PM explanation, not wider tolerance. Cinematic elapsed time gets a separate approved budget; total clock duration is not a movement metric.

| ID | Scenario | Pass condition |
| --- | --- | --- |
| R01 | Walk, accelerate, brake, reverse, double-tap sprint; default/stride/momentum fixtures | Same displacement, speed and run transitions; idle/turn never delays control |
| R02 | Tap/hold jump, edge coyote, buffered landing jump; immediately attack or reverse on landing | Same apex, airtime and accepted input ticks; no landing lock |
| R03 | Wall slide/jump both sides, repeat climb and jump to legitimate upper routes | Same impulses and reachable routes; no animation cooldown/ceiling |
| R04 | Double jump before/after wall and tether; test locked ability too | Same air_used resets and gate behavior |
| R05 | Ground/air dash into wall and threshold, dash from tether | Same duration, collision, release, invulnerability and ghost cadence; no lingering dash visual |
| R06 | Slack/taut grapple, pump both ways, release, jump-release, wall collision | Same trajectory and release timing; attack/tether conflict documented without rebalancing |
| R07 | All three melee hits, early/late queue, airborne attack, parry, kunai, hitstop and hurt | Exact hit/projectile ticks, reach and damage; visual contact aligned with gameplay event |
| R08 | Canal-left and both R13↔R14 directions: walk/sprint/dash/jump, stop, reverse, hold direction/E | Automatic without E; no stall/loop; retain PR51 support recovery and momentum rules |
| R09 | All 39 automatic endpoints; wrong height, tethered, gated and repeated approach | No bypass or false trigger; specific hints; safe reciprocal landing and rearm |
| R10 | R14→R17 staged and R17→R14 baseline; plain/reduced/default flags | Correct branch-specific timing and facing; no accidental staged reverse/default adoption |
| R11 | Press/release jump, attack, dash, parry, kunai, tether during every locked phase on touch/keyboard/gamepad | No unauthorized dispatch; edge/held policy agrees across devices; no delayed ghost action |
| R12 | Pause/map/loadout/focus loss at enter/load/arrive; resume holding direction | Paused ownership intact; control/visual/camera recover; no lost touch release |
| R13 | Death, respawn, rebuild, rejected request, repeated cancel, F6 twice in every phase | One valid player, coherent room/pending state, no stale camera/proxy/input lock |
| R14 | Force each watchdog and missing/invalid clip | Recovery within declared budget plus one tick; fallback usable; loader stall explicitly tested |
| R15 | Gameplay→proxy→gameplay, both facings, idle/run/attack/traversal and damaged alpha | Fixed ground registration, no unexplained size/opacity/frame pop; no crop/duplicate sprite |
| R16 | Long-idle at proposed threshold then movement/jump/attack; slope/air/damage/menus | Never steals input or selects while ineligible; all exits immediate |
| R17 | Crouch preview versus production toggle; low ceiling only if PM authorizes physical crouch | No unapproved capsule/speed changes or false clearance; standing safety separately tested if implemented |
| R18 | Fresh and upgraded saves, room revisit, death reload; Windows and macOS exported builds | Progression/save behavior unchanged; accepted assets included; native control and visual review recorded |

Visual gate: compare at 1280×720, gameplay zoom 1 and actual cinematic zoom, normal speed and frame step. Proposed planted-contact tolerance ≤1 world px for registered contact poses; intended lift/step is excluded and must be labelled. Compare silhouette/body scale to approved reference, not a uniform sprite-scale value. Creator decides aesthetic acceptance. Record physical gamepad and touch separately. At target 60 FPS, measure frame pacing during transitions; no FPS claim from headless tests.

Existing suites: retain baseline and TR05 preservation checks, TR05 runner and PR51 doorway suite. PR60 reports 9 old timing assertions failing with staged mode enabled because they encode 0.65 s; retain default-mode checks and add explicit staged expectations instead of weakening them globally. Prior coordinator reports do not replace R11/R14 or human playthrough.

## 8. PM handoff and disposition

**Recommendation:** continue Claude's TR08/ART08 work behind explicit presentation boundaries. Preserve the approved controller and traversal freedom. This review does not certify integration ready to merge.

Claude/TR08: address input ingress and transaction/watchdog ownership in the integration design; reproduce GP07-01/02; execute R08–R14. Seek PM approval before any controller or combat/timer policy change.

Claude/ART08: supply complete accepted cycles and metadata, preserve clip-specific registration, demonstrate immediate idle/long-idle interruption and seam captures; do not bind rejected/WIP assets. Execute R15–R17 with gameplay QA.

PM: decide cosmetic versus physical crouch, long-idle threshold, cinematic action/timer/damage policy and any new default timing. Creator retains visual and movement acceptance. Existing residual wall escapes from PR60 are not authorization to weaken wall jumping.

QA/Build: pin integrated SHA and all source/art dependencies; run paired scenarios, native Windows/macOS playthrough, gamepad/touch and export verification. Attach evidence identifying automation versus human review and mark every unrun case pending.

Delivered here: gameplay preservation audit (§2–4), animation recommendations (§5), restoration checklist (§6), regression scenarios (§7), PM handoff (§8). No gameplay, art, collision, saves or implementation branches changed. No merge.
