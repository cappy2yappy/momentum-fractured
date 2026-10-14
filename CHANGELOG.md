# Kaze changelog

This log records reviewed development changes and creator feedback. Entries distinguish delivered work from proposals and acceptance still required.

## 2026-10-14 — Alpha 0.6.1 creator playtest follow-up

- Creator played the candidate and positively evaluated gameplay, dynamics, current feel and floatiness. Preserve those qualities in subsequent development.
- Recorded tentative excessive-speed feedback and apparent existing-save/powerful-character context. A fresh baseline, Stride-only and optional-meter comparison is needed before numerical tuning; save reuse is not yet a reproduced defect.
- Recorded a request for more life and more unique visual expression in Kaze's actions. Animation/liveliness is a working interpretation; an HP rebalance was not specified.
- Prioritized Level Design as the next major focus because current layouts make gameplay difficult to evaluate.
- Added the complete [GP-01 creator-playtest PM return](docs/agent_handoffs/GP01_CREATOR_PLAYTEST_PM_RETURN_2026-10-14.md) and linked it from the earlier technical handoff.
- This entry is documentation only: no speed, physics, health, animation, artwork or room changes; no new build or runtime test result. PM review remains required.

## 2026-10-14 — Alpha 0.6.1 GP-01 stabilization candidate

- Fixed long-step kunai collision sampling so traveled shots resolve crossed seals/enemies; use current room width for cleanup.
- Hardened schema-8 save loading against malformed field shapes, invalid flags, stale discovery and locked selected elements; preserved save identity and existing migration behavior.
- Released tether before dash and rejected attachment during active dash without changing movement equations, swing integrator, dash impulse/timing or restored character sizing.
- Added 24 targeted assertions. Final current validation: 14 suites / 580 assertions passed; historical audit: eight suites / 470 assertions passed. Windows export, 180-frame packaged headless startup and ZIP CRC passed.
- Source implementation: `7a2b7737168caedcf40a51914c7d345f2e9684dc`; technical handoff: `b801742b1c8a20c92770a31b5cda3bd6996473c0`; [PR #8](https://github.com/cappy2yappy/momentum-fractured/pull/8) targets the integration branch and awaits PM acceptance.
- Swimming, crouch/slide, full continuous campaign acceptance and measured 60 FPS rendering remain outstanding. See [technical handoff](docs/agent_handoffs/GP01_ALPHA_0_6_1_HANDOFF.md) and [historical audit](docs/agent_handoffs/GP01_HISTORICAL_GAMEPLAY_AUDIT.md).
