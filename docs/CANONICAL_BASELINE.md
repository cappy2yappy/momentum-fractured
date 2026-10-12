# Canonical Kaze development baseline

October 12 sprite update: the creator authorized Final Cleanup idle/run and Boundary QA combat/traversal integration. Active bindings now use `assets/kaze/cleaned`; original approved image bytes remain preserved in `assets/web`. See [sprite integration](SPRITE_INTEGRATION_2026-10-12.md) for the visual-only controller checksum change and verification limits.

Selected on 2026-10-12 by the creator following the Alpha 0.5.2 review and direct confirmation of the character sprite sheets.

| Item | Identity |
| --- | --- |
| Source foundation | `215e9bce3b234cb268e9426b52817f5ca844031e` |
| Working branch | `codex/kaze-approved-baseline-2026-10-12` |
| Engine | Godot 4.6.1 |
| Entry project | root `project.godot`; `scenes/main.tscn` |
| Scope | 13 rooms across 4 regions; Alpha 0.5.2 Development |
| Reviewed executable SHA-256 | `41b5b66ef56e0e93b7822c3297100ec85ba27b27b94a014a28468357d3a9db50` |
| Reviewed Windows ZIP SHA-256 | `a612be3156d8bf3e287707f5a6220824e583b33d65219ddf5f4742174c193b1a` |
| Approved controller SHA-256 | `58a1c319183a993bde9abc6f639b4adaefe245f89de24e6f0f9338bc9519339d` |
| Character assets | [Four approved sheets](../assets/web/KAZE_SPRITES.md) |

The original approved Alpha 0.5.0 was recovered in `47ba3d3`; Alpha 0.5.1 is `7ef5873`; Alpha 0.5.2 is `215e9bc`. See BASELINE_PROVENANCE.md for recovery evidence. This organization change adds documentation and asset verification without changing gameplay, room geometry or image bytes.

The executable keeps the Alpha 0.5.0 application/save identity intentionally, while its Windows metadata reports 0.5.2. Do not rename the application to tidy version labels without implementing save migration.

The creator approved these sprites as the active character art; that does not approve every encounter's balance. Seven source suites passed in the October 12 review, while a complete unseeded Windows playthrough remains pending. The reviewed executable hash matches the adjacent build report; embedded scripts were not independently compared with source. Do not overstate binary/source equivalence.

The canonical web reference is https://rush-line.thacap.chatgpt.site/. It was accessible in-browser on October 12 and advertises 21 areas, 5 regions and 5 keepers. The current Windows build is an incremental foundation, not that completed campaign.

## Changes from here

Start combat and world expansion from this branch. Keep the approved art and dry-ground movement. Work on bounded, tested increments; mark unintegrated assets separately. If a combat edit changes player.gd, explain the change and verify movement preservation before updating its recorded checksum. Do not replace the controller or import an older gameplay foundation just because its version label is higher.
