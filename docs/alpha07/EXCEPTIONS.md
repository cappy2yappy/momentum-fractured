# Alpha 0.7 compatibility exceptions register

Status: Gate A0 decision received 2026-10-22 16:03 (provisional). Each row needs explicit PM approval (and creator approval where marked) before any code relies on it. Provisional Gate A0 direction of 2026-10-22 allowed only EX-01 in principle.

| ID | Exception | Why needed | Limits | Approval needed | State |
|---|---|---|---|---|---|
| EX-01 | Collapsing platform adds one layer-1 StaticBody2D (HAZ-01 `collapse`) | A collapse that cannot be stood on is not a collapse | Contract v1.1 section 8: kind `collapse` only, rect-sized, never on door approach, checkpoint, arrival or recovery floor, never the only route, rebuild only when clear, tested at 30/60/144 fps, LD-05 reach probe shows no new escape | PM allowed in principle; per-instance creator placement approval | APPROVED PROVISIONALLY (A0). Compliance branch #87 forbids collapse in production placement; reconcile before any production use |
| EX-02 | EN-01 behaviors not configurable after `world.spawn_enemy` returns | EN-01 projectile and ranged enemies are not Guard subclasses | Adapter passes an `enemy_script` to `spawn_enemy`; any enemy that cannot be built this way is listed here with the reason | PM | UNDER INDIVIDUAL REVIEW. Evidence: #87 `encounter.gd` calls `world.spawn_enemy(..., Enemy)`; no unconfigurable behavior found. Likely closes as not needed once ranged enemies are checked |
| EX-03 | Persisted `en01/<id>` keys in `cleared_encounters` | EN-01 PR #83 already writes this namespace | Registered as alias of `enc/`; permanent once any build saves it; INT-01 must read both | PM | UNDER INDIVIDUAL REVIEW. Needs PM ruling that `en01/` is a permanent registered namespace |
| EX-04 | ST-05 dotted ids (`st05.bNN.*`) | Written before the namespace decision | Read-only alias table; nothing registered or saved until creator approves the row | Creator (D1 to D14) | PROPOSED |
| EX-05 | HAZ-01 `snapshot()` dictionary and EN-01 direct `world.save_progress()` | Both predate the "existing flags, deferred saves" rule | Adapters replace both before integration; neither PR is merged as is | PM | UNDER INDIVIDUAL REVIEW. #87 added the hazard flag adapter; #87 `encounter.gd` line 73 still calls `world.save_progress()` directly because INT-01 #88 has no managed defeat or save-retry seam. Open until INT-01 provides it |
| EX-06 | Hazard recovery minimum 0.3 s (telegraph is 0.6 s) | Direction fixed telegraph and windup only | Recovery stays 0.3 s unless PM raises it | PM to confirm | APPROVED for isolated prototypes only (A0). Telegraph stays at least 0.6 s, existing player damage immunity retained. Production placements need room-specific safety tests and creator review |
| EX-07 | EN-01 windup 0.48 s in shipped config | Direction requires 0.5 s | Not an exception: validator and demo configs change to 0.5 s | none | REQUIRED CHANGE |
| EX-08 | Boss-class hp 14 stays for existing bosses | Standard rule is hp 4 to 8 | Existing bosses untouched; no new boss | PM | UNDER INDIVIDUAL REVIEW. No new boss is planned, so likely a no-op note |

No exception touches `player.gd`, `momentum_profile.gd`, `project.godot` or the byte-locked world.gd functions. Any row that would is rejected, not queued.

No blanket approval exists. EX-02, EX-03, EX-05 and EX-08 are decided one at a time.
