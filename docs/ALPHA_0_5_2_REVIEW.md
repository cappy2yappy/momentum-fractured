# Kaze Alpha 0.5.2 review — October 12, 2026

Verdict: the thirteen-room development increment has strong regression evidence. The broader campaign/parity milestone is not complete. Combat is functional but still needs variety, feedback and balance work. A full unseeded Windows playthrough remains unverified.

## Artifact and method

Inspected the requested ZIP at C:/Users/TonyS/Documents/Codex/2026-10-11/resume-development-of-momentum-fractured-kaze/outputs/skyworks/Kaze-Alpha-0.5.2-Windows.zip. It contains one 117,654,584-byte executable and PLAYME.md, README.md and PROJECT_STATUS.md; no source or regression tests are inside the ZIP. Extraction succeeded and a full ZIP CRC integrity check found no corrupt entries.

ZIP SHA-256: A612BE3156D8BF3E287707F5A6220824E583B33D65219DDF5F4742174C193B1A.

Executable SHA-256: 41B5B66EF56E0E93B7822C3297100EC85BA27B27B94A014A28468357D3A9DB50. This exactly matches the adjacent BUILD_REPORT.md. Windows product/file version is 0.5.2.0; product name identifies the Development build. It is unsigned. The window/save identity remains Alpha 0.5.0 intentionally for compatibility.

Found adjacent kaze-alpha05 source, copied it into this review directory and ran tests with disposable APPDATA. Original source and personal save files were not edited intentionally. Native game launch did load an existing completed save. The adjacent report identifies source commit 215e9bce3b234cb268e9426b52817f5ca844031e, but embedded scripts were not independently compared byte-for-byte with adjacent source; source results are not equivalent to testing every packaged behavior.

## Goal assessment

| Requirement | Status | Evidence and limits |
|---|---|---|
| Standalone Windows launch and rendering | PASS | Launched the exact extracted executable through Windows; Keeper Relay, character, health and minimap rendered. |
| Fresh packaged boot | PASS, limited | Exact executable ran headless for 180 frames with fresh isolated APPDATA and exited 0; packaged-fresh.log records only the certificate-store diagnostic. This is a boot test, not a rendered fresh-game playthrough. |
| Existing-save loading | PASS, limited | Existing save loaded with all abilities. Kit displayed three sigils, Electric equipped and Keeper relay attuned. This checks one save, not every migration. |
| Travel kit UI | PASS, limited | Mouse opened the actual packaged kit; portrait, ability descriptions and progression labels were legible. Keyboard/atlas verification was interrupted by focus-loss pausing, so those packaged interactions remain UNKNOWN. |
| Preserve approved movement | PASS in source | Controller SHA-256 equals the documented approved checksum 58a1c319183a993bde9abc6f639b4adaefe245f89de24e6f0f9338bc9519339d. Baseline tests cover original eight-room geometry, walk speed and jump height. |
| Tether, release momentum, combo and parry | PASS in source | approved_combat_swing suite passed; not a full live Windows combat session. |
| Thirteen-room expansion and four regions | PASS in source | world.gd declares 13 rooms and Canal Ward, Echo Works, Storm Keep and SkyWorks. Progression suites passed. |
| Sigils, elemental gates and return shortcuts | PASS in source | Real projectile collision, blocked/wrong elements, reciprocal arrivals and persistence checked by expansion/progression suites. |
| Critical platform jumps | PASS in source | Six live-input/collision traversal assertions passed; does not demonstrate every route or player skill level. |
| Keeper mechanics | PASS in source | Sweep/parry, jumpable pulse, second phase, pursuit and independent victory progression passed. Difficulty, feel and exploits across a whole fight remain UNKNOWN. |
| Checkpoint, save migration and death recovery | PASS in source | Save compatibility and transition/death tests passed using disposable save data. |
| Twenty-one areas, five regions, five keepers | FAIL / incomplete | Windows source has 13 rooms and 4 regions. Canonical web atlas explicitly describes 21 areas across 5 regions; HUD tracks 5 keepers. Full five-keeper campaign is not present in this candidate. |
| Real swimming | FAIL / absent | Candidate notes defer swimming; player.gd has no swimming system. This is a future scope item, not an independently recovered formal Alpha acceptance requirement. |
| Exact web-demo mechanics and campaign parity | FAIL for campaign; UNKNOWN for full mechanics | Browser benchmark opened successfully; no complete side-by-side playthrough. Controls differ: web right-click dashes, Windows right-click parries. |
| End-to-end fresh Windows completion | UNKNOWN | No unseeded full route/boss playthrough was completed during this review. |
| Clean diagnostics | FAIL | Source import exited 0 but produced certificate-store, editor-settings write and RID/ObjectDB cleanup diagnostics. No script parse/resource-load failure observed in tested suites. |
| GitHub synchronization | UNKNOWN | Release notes say local, not pushed. Remote synchronization was not audited in this review. |

The referenced conversation provides recovery context rather than a complete signed-off Alpha 0.5 acceptance checklist. The wider benchmark and candidate's explicit commitments are assessed separately here; a new acceptance contract should make their relationship clear.

## Independently rerun tests

All seven source suites exited 0, with 135 PASS assertions and zero reported assertion failures:

| Suite | PASS assertions |
|---|---:|
| approved_baseline | 32 |
| approved_combat_swing | 7 |
| annex_expansion | 34 |
| annex_traversal | 6 |
| save_compatibility | 11 |
| skyworks_progression | 33 |
| storm_keeper | 12 |

Logs are beside this report. Each suite emitted the environment certificate-store diagnostic. Source import also could not save portable engine editor settings outside the writable workspace and emitted cleanup diagnostics. These are not assertion failures, but this review does not call the runs warning-free.

An attempt to run an external regression script directly against the exported release did not produce suite output and was stopped. It is not a passed packaged combat test. Export presets exclude tests and docs. Prior bundled reports of rendered seeded rooms and packaged boots are historical evidence, not new tests performed by this review.

## Canonical web comparison

Direct browser inspection of https://rush-line.thacap.chatgpt.site succeeded without an authentication prompt. Started the demo and opened its atlas. Its UI labels the build Alpha 0.3.2 and shows 1/21 areas, 0/5 keepers, 0/4 secret fragments and 0/8 notes. Atlas regions are Silent District, Old Conservatory, Ember Works, Royal Observatory and Storm Crown. Its controls describe wall-jumping, held tether, double-tap running, parry and dash. This establishes the visible benchmark scope, not successful completion of that campaign. Release documentation claiming benchmark authentication is unavailable should be updated.

## Combat findings and priorities

1. Ordinary guards use one chase/windup/strike/recover pattern. receive_hit always forces a 0.24-second stun, including during attack warnings. This creates an interruption incentive and warrants an attack-spam playtest; it is a code-supported risk, not a demonstrated infinite lock.
2. Player has a three-hit combo with 1/1/2 damage, a 0.23-second parry window and cooldown, dash protection and short hitstop. These are a usable foundation, not proof of satisfying combat feel.
3. Keeper has 18 HP, a facing-locked sweep and a grounded pulse. At half health its warning/recovery timings shorten; it largely accelerates the same two moves. Boss variety is limited.
4. Enemy damage from Wind, Fire and Electric projectiles is identically 1. Elements differentiate locks, but this code does not give them distinct enemy-combat effects.
5. Melee chooses one nearest target within horizontal/vertical thresholds. Multiple-enemy pressure and crowd-cleaving expectations need an explicit design choice.
6. Three-health survivability, repeated hits, enemy interruption and parry reward need live balancing. Automated success does not measure readability, enjoyment or pacing.

## Blocking issues and next increment

Full campaign acceptance is blocked by missing world/keeper scope and lack of end-to-end Windows acceptance evidence. Combat expansion should precede multiplying similar rooms.

Recommended next deliverable: a separate combat prototype copied from this source, preserving dry-ground movement. Add three genuinely different enemy roles (duelist, ranged pressure, armored guard), clearer attack/impact feedback, deliberate interruption rules and distinct elemental combat reactions. Validate facing, active hit windows, single-hit damage, parry success/failure, death cleanup and save compatibility. Then playtest a complete encounter route with no seeded victory state.

Expand toward 21 areas/5 regions/5 keepers through one distinct region at a time. An aquatic route can introduce swimming and traversal-led fights, with a unique keeper and reciprocal shortcut. New rooms should provide a new decision or ability use rather than merely increasing the room count. Treat these as proposed development targets, not features delivered by this review.

No production gameplay changes, commits, pushes or new release were made during this review.
