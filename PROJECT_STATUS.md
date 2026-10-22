# Momentum Fractured / Kaze — Project Status

Updated: 2026-10-12 (America/New_York). Active branch: `codex/alpha-recovery-2026-10-12`.
Active checkout: `~/Documents/Playground/momentum-fractured-recovery`.

## Milestone assessment

Recovery baseline published; Alpha 0.5 and Alpha 0.8 acceptance are **not complete**.
The September 30 parity baseline is the newest development line (2ec0a1d).
Godot 4.6.1 import and all four existing automated suites actually ran: zero assertion failures across 12 rooms. See TEST_RESULTS.md and validation/2026-10-12 logs. Headless checks do not establish visual quality, full player reachability, or 60 FPS performance.

## Recovery and synchronization

Both original checkouts remain intact. The newer outer checkout ends at 1d062bb; the nested clone ends at e4b0a86. All five requested commits were located. Local history and an unreachable stash are archived and published on separate preservation branches; current progression is retained. See RECOVERY_REPORT.md for hashes and compatibility decisions.

## Work under validation

- Recover viewport-correct combat damage numbers, defensive Hurtbox/Checkpoint lookups, and audio shutdown cleanup.
- Exercise real physics collisions, movement, transitions, and checkpoints beyond the existing method-level smoke checks.
- Persistent elemental seals and authored Fire return path implemented and regression-tested.

## Remaining acceptance work

P0: live collision stability; direct movement/tether feel acceptance; HUD/map interactions; web unlock/control parity reconciliation.
P1: Fire return loop; canonical Kaze animation sheets (current red-scarf art remains legacy); underwater presentation and recovery; genuine authored boss encounters and tutorial integration.
Release: Windows and macOS exports and platform verification; 60 FPS measurement on target hardware. Package creation does not equal accepted Alpha completion.

The canonical web game was directly inspected on October 12: Lantern Haven, Alpha 0.3.2, three-heart HUD, area map, F parry, Q tether after unlock, Shift/right-click dash after unlock. Current Godot baseline starts with Dash/Tether/Wind Kunai and uses F for kunai. Record this conflict before changing progression or remapping existing actions.

No background development process or schedule is implied by this status.

## Stability increment evidence

All five runtime suites passed in `validation/2026-10-12/stability/results.json`. The new recovery suite passed 43 checks including physical melee damage/immunity, per-window target tracking, camera transform, checkpoint save/load and actual scene respawn, detached helper guards, and audio teardown. Initial regressions demonstrated repeated per-window damage, an Echo death physics mutation error, and default-spawn checkpoint restoration; fixed and rerun.

The sandboxed re-import exited 0 but failed the strict runner due to denied writes to normal Godot editor settings/ObjectDB snapshot paths. It is recorded as **failed**, not passed; the engine import is being rerun with filesystem access. Baseline asset import had succeeded in an isolated application directory. Certificate and ObjectDB teardown warnings remain documented.

Godot re-import with normal filesystem access succeeded (exit 0), with no script/resource/editor-setting errors: `validation/2026-10-12/stability/import-unsandboxed.log`. The initial sandbox failure remains retained in the strict results file.

## October 12 continuation increment

All seven runtime suites passed after integration: `validation/2026-10-12/continuation-final/results.json`. Fresh Godot import also passed with no errors (`continuation-import.log`). The new suites contribute 43 recovery + 37 live-input + 37 Fire-return checks, in addition to the four existing suites.

Authored Room 9 now completes the five-room structural loop (Rooms 5–9): matching Fire impact opens a persistent seal and one-way shortcut to Surface entry_shortcut. Continuous partitions prevent the tested jump/dash/tether bypass routes; the Room 8 retreat and Room 10 campaign remain available. Gate saves are backward compatible; older saves begin with unopened gates. The map displays sealed links in orange and one-way arrows.

Pause, map, loadout and combat hit-pause now preserve each other's pause ownership. Actual movement, short/held jump, dash, swinging and selected transitions were tested. Room-wide player reachability and subjective feel approval remain pending.

Rendered probe: Apple M4 / Mac16,1, Godot Metal Forward+, 1280×720, 180 measured frames per room after 40 warmup frames. Average 116.8–120.1 FPS; p95 frame time 8.6–9.9 ms; worst observed frame 53.5 ms. Short sampling is not a sustained-frame-time guarantee. See rendered-performance.json/log.

Remaining: direct five-room playthrough/feel acceptance; canonical Kaze art and animations; parry/run/unlock reconciliation; underwater presentation/recovery; bespoke bosses/tutorial recovery; target-device soak tests. Export validation is the next step.
