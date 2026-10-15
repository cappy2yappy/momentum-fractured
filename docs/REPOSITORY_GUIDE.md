# Repository and branch guide

Inventory verified against GitHub on 2026-10-12. Branches preserve several different gameplay foundations; a recent date or larger version label does not establish the approved build.

## Active project

`codex/kaze-approved-baseline-2026-10-12` publishes the creator-approved 13-room Alpha 0.5.2 source, including its actual Kaze art. `main` remains the historical implementation pending review of the baseline PR. The local branch `codex/alpha05-approved-continuation` held commits `47ba3d3`, `7ef5873`, `215e9bc` but was absent from GitHub's branch list before this publication.

## Preserve as reference

| GitHub branch | Observed tip | Role |
| --- | --- | --- |
| main | 1a33d28 | Older project/default branch; contains historical design and task documents |
| codex/alpha-0.5-baseline | fc6acea | Earlier Godot foundation, not selected Alpha 0.5.2 |
| godot-recovery | fc6acea | Same tip as the older baseline |
| codex/web-parity-restoration | 398c772 | Alternative parity development; compare features before porting |
| codex/parity-validation-2026-09-30 | 2ec0a1d | Alternative foundation with aquatic work; not the selected controller |
| codex/alpha-recovery-2026-10-12 | 84060d2 | Recovery/collision/checkpoint work on the alternative foundation |
| codex/alpha-recovery-source-2026-10-12 | 4a07684 | Continuation of that recovery, including Fire-return work and export records |
| codex/phase-sweep-2026-03-23 | 1d062bb | Historical phase-sweep report |
| codex/recovery-alpha-2026-10-12 | 1d062bb | Same tip as historical phase-sweep branch |
| recovery/preserved-stash-2026-10-12 | d73650f | Preserved recovery work; retain for audit |
| art/kunai-sprite-pass-01 | 2f2a4af | Separate elemental kunai art pass; gameplay integration pending |

The art branch's new files live under assets/kunai. They have not been integrated into this approved baseline. Keep that work preserved and review it independently rather than merging its older project foundation wholesale.

The screenshots supplied by the creator showed assets/sprites/kaze on a recovery branch. That is the older red-scarf art. The active controller loads assets/web/kaze_idle_strip.png, kaze_run_strip.png, kaze_combat_strip.png and kaze_traversal_strip.png. See the preview manifest before choosing character art.

Historical root design/task documents remain available at main commit `1a33d283a3781ba7068f86b43d4197f28f063939`. Treat them as references, not current execution instructions. Existing branches and history are retained; this organization does not delete or rewrite them.

## Folder responsibilities

| Folder | Purpose |
| --- | --- |
| assets/web | Runtime approved character art, environment art and enemy sheets recovered with the selected build |
| assets/*.png | Older retained recovered sheets; not the character clips used by player.gd |
| scripts | Active player, world, UI, encounters and projectiles |
| scenes | Main entry scene |
| world | MetSys map data |
| addons/MetroidvaniaSystem | Recovered/pinned MetSys runtime and editor support |
| tests | Behavioral regression suites and seeded capture helpers |
| tools | Baseline verification |
| docs | Baseline contract, review, branch guide and recovery provenance |
| .github/workflows | Automated import, verification and Windows export |

Builds are produced into ignored build/windows. Versioned binaries belong in release/download artifacts; generated engine caches and personal saves do not belong in source commits. Do not rename runtime asset paths merely for aesthetics: recovery import metadata and runtime references already use these locations.
