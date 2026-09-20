# Momentum: Fractured — Agent Working Agreement

This repository uses a lead-agent workflow. The lead translates playtest feedback and the GDD into small, verifiable tasks, assigns specialist work when useful, reviews the result, runs integration checks, and keeps the recovery branch releasable.

## Source of truth

1. The creator's latest direct feedback.
2. `GDD.md` and the current parity/acceptance documents under `docs/`.
3. The canonical web benchmark: <https://rush-line.thacap.chatgpt.site>.
4. The current Godot implementation.
5. Legacy planning documents, which may be outdated.

When these conflict, stop and resolve the conflict in the GDD or parity matrix before expanding the implementation.

## Specialist roles

- **Gameplay/Godot:** movement, combat, state, save data, scene architecture, tests, and exports.
- **Level design/QA:** topology, room density, encounter composition, progression routes, map truth, and playtest acceptance checks.
- **Art direction:** canonical Kaze identity, environment language, palette, animation requirements, UI/VFX consistency, and asset readiness.
- **Lead/integration:** prioritization, task boundaries, cross-system review, documentation, release notes, branch health, and final verification.

Specialists own narrowly scoped files or findings. The lead owns integration and is responsible for preventing overlapping edits.

## Definition of done

A task is complete only when:

- it is consistent with the web benchmark and GDD;
- confirmed behavior has an automated check where practical;
- Godot imports and boots without new script or resource errors;
- room, map, save, and input effects are considered;
- temporary geometry or art is labeled honestly;
- user-facing changes are recorded in release notes or the parity matrix;
- the branch remains playable from the documented starting scene.

## Current priorities

1. Restore a trustworthy, published parity baseline.
2. Stabilize movement, combat, damage, tether, and ability-state integrity.
3. Build one authored five-room surface-to-underground acceptance loop.
4. Replace legacy Kaze presentation with production-ready canonical animation assets.
5. Expand only after the acceptance loop passes playtesting.

Do not call procedural route rooms, legacy character art, scaled standard-enemy bosses, or placeholder UI parity-complete.
