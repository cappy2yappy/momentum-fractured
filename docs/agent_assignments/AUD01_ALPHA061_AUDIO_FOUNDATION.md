# KAZE ALPHA 0.6.1 — AUD-01 AUDIO FOUNDATION & SOUND DESIGN

**Owner / chat:** THE SOUND SHOGUN | Audio, SFX & Godot Integration
**Assignment:** AUD-01-0061
**Issuer:** Kaze Project Management (PM-01)
**Date:** 2026-10-14
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Engine:** Godot 4.6.1
**Verified review starting candidate:** integration/candidate-alpha-0.6.1-gp-ld, observed SHA afecef1922231081807a332c511de85c7941fec8; re-verify remote HEAD before working.
**Dedicated feature branch:** feature/alpha-0.6.1-audio-foundation
**Draft PR target:** integration/candidate-alpha-0.6.1-gp-ld
**Related work:** Gameplay PR #8, level design PR #9, combined candidate PR #10, art concept PR #11, transition PR #12 (UNMERGED), automated builds PR #13 (UNMERGED). CI-02 default-branch promotion underway.
**This is an existing playable Metroidvania, not a new Godot project.**

## Authority, identity and ownership

The creator is **Music Director**, personally producing/selecting/approving the game's soundtrack through **Suno**. You are **Sound Shogun**, responsible for the technical audio pipeline, gameplay sound effects, original environmental ambiences, music-integration scaffolding, accessibility, mix and technical QA. **Do not commission, generate, publish or select a definitive soundtrack without the creator's express approval.** Do not imply the creator has to grant Suno credentials; request approved exported audio when needed and document formats, handoff path and music rights. If no music asset is supplied, use a clearly labeled silence/temporary test-tone path, never a counterfeit finished score.

Sound/music art direction established by the creator:
- Primary inspiration: **Samurai Champloo** as a reference for sophisticated rhythmic atmosphere and emotional contrasts, not literal copying.
- Stylistic palette: soulful/jazzy lo-fi hip-hop, city pop, Jersey club/house percussion for high-momentum traversals, Japanese math rock for tense encounters, occasional organic/traditional textural elements.
- Geography: warm hidden village, mysterious Overgrown Shrine and Canal Remains, nocturnal Silent District/city.
- Visual presentation: Persona 5-*influenced* graphic transitions made original to Kaze; audio can accent passage changes with short kinetic whooshes, not borrowed sounds.
- Preserve subtlety, dynamic range and sonic legibility. No unlicensed sampling, imitation of recognizable riffs, copied game cues or reproduction of copyrighted songs.

## Mission and success criteria

Deliver a **small real in-engine audio vertical slice** for the approved gameplay foundation. Demonstrate original, licensed, or internally synthesized SFX on meaningful mechanics without altering mechanics. Prototype ambient layers, music-ready buses and scene transitions. Publish evidence and a report; creator can hear/compare audio in an actual candidate.

Success means:
1. Audited Godot audio integration, with sound buses / playback organization and level-safe SFX hookups.
2. Working, appropriately mixed sounds for **at least**: movement footfalls (surface-aware if feasible), dash/wind, jump/landing, tether/grapple attach/release, melee swing/contact, kunai throw/impact, parry success, damage/death and checkpoint/room-transition cue. Prioritize mechanisms actually implemented on the approved candidate; if a listed event is absent, document and propose a non-invasive alternative rather than inventing gameplay.
3. At least two distinct **environment ambience** profiles for existing, verified rooms/biomes (e.g., roof/city night versus canal/underground). Avoid wholesale new rooms.
4. Clear, scalable Audio Bus architecture (Music / SFX / Ambience / UI, with logical SFX subgroups as needed), sensible priorities, polyphony limits, peak control and music ducking policy *documented* (implement only if useful to MVP).
5. A **music slot**/AudioStreamPlayer and basic transition policy able to accept future approved Suno stems/tracks without changing gameplay architecture. Silence is valid until creator supplies approved music.
6. Actual Godot import/test/build evidence, audio-listening notes, 60 FPS risk assessment and repeatable user playtest directions.
7. Feature branch pushed and draft PR opened. No merges or broad game-state changes.

## Preflight audit

Read repository documentation and scripts carefully, inspect scene tree and autoloads, existing AudioStreamPlayers and event/signal locations, `project.godot`, sound resources, licensing provenance, save/load, physics and movement input. Identify real safe hook points with minimum code changes. Record baseline exact SHA. Inspect existing `assets/`, `scripts/`, `scenes/`, `tests/` and all audio files before introducing more. Make no assumptions about third-party tool permissions or GitHub binary-upload ability.

**Read/reference but do not cherry-pick unmerged PRs**: #12 transitions and #13 CI. The audio hooks must remain compatible with current approved movement and future transition system; use loosely coupled event interfaces when possible.

## Approved tooling and source rules

- The creator has installed an ElevenLabs plugin, but **actual available operations must be verified**. You may use ElevenLabs *only if it exposes a suitable authorized audio-generation operation*, with original descriptive prompts, and must save generated sound files into the repo or provide an actionable provenance-preserving handoff. Do NOT claim an asset is integrated merely because a preview exists in a SaaS session.
- Acceptable alternatives: original synthesis/procedural recordings, clearly licensed CC0 game audio (e.g., applicable Kenney packs), Freesound material only after verifying precise license/attribution and suitability. Document artist/source URL, date, license, modification, and redistribution/commercial-use conditions. Do not include NC assets, unknown-rights audio or copied copyrighted recordings.
- If third-party audio production is blocked, implement silent-scaffold first and report blockers rather than fabricate tests. Only production-ready/original candidate assets should be shipped, not stock placeholder sounds mislabeled final.
- Audio formats: evaluate OGG Vorbis for long music/ambience, WAV or OGG for short effects, compression/loop points/latency; choose suitable files and describe Godot import settings. Keep repo binary growth small; discuss Git LFS/asset hosting threshold before adding very large tracks.
- Creator owns soundtrack approval and Suno commercial-rights verification; retain generation/date/account-plan/right-status in `docs/audio/AUDIO_ASSET_REGISTRY.md` when approved files arrive. Never assert that Suno automatically grants exclusivity.

## Implementation guardrails

**LOCKED:** approved movement speed/floatiness, dash/tether physics, player scale/animations, combat damage, ability gating, room graph, exit destinations, save schema/profile identity, UI hierarchy, original game logic and existing player input. Sound must observe gameplay, not drive/retime it. Do not change scene graph in ways that reset state.

Use centralized routing/signals only where justified. Handle event rate limiting: no machine-gun footfalls from continuous collision; velocity-/state-dependent stepping, avoid overlapping duplicated loops, silence during pause/respawn when appropriate. Sound when gates reject action must be informative but not punishing. Mix so combat and damage are legible over ambience/music, and transitions avoid clicks; fade or crossfade ambience on room changes, respecting reduced-motion option if relevant. Include user-accessible independent volume controls if implementation reasonably achievable without save schema changes; otherwise document a clear next phase.

Create **original descriptive generation briefs** for future SFX and ambience in `docs/audio/AUD01_SFX_PROMPTS.md`: compact prompts with event, intended sonic layers, length, tonal range, ambience context, prohibited signatures, dry/wet versions and preferred format. Do not use prompts instructing direct imitation of another game's protected audio.

## Proposed first-pass cue inventory

| Event | Sonic approach | Notes |
| --- | --- | --- |
| Footsteps | quiet tactile cloth/sole and contextual stone/wood splash where appropriate | sparse; speed-aware |
| Dash | fast compressed airy cut + cloth snap | brief, no repetitive piercing whistle |
| Jump / land | light exertion/soft wind impulse; grounded soft thump | no long cartoon boing |
| Tether fire / attach / release | airy line flick, clipped magnetic/clink, soft elastic release | timing must follow actual swing |
| Basic melee | sharp fabric/steel whoosh and independent hit confirmation | don't overuse generic blade clang |
| Kunai elements | common throw + subtle wind/fire/electric identity on impact | respect actual ability availability |
| Parry | musical/metallic transient with crisp positive timing | stand clear over mix |
| Damage / death | restrained, impactful, not excessively loud | feedback not fatigue |
| Room passage | quick directional whoosh; brief stylish panel/wind-fold sting | coordinate with TR-02 |
| Save/checkpoint | gentle resolved bell/paper/chime | emotional quiet |
| Night city | distant urban rumble, wind/air, occasional subtle environmental texture | loop-safe |
| Canal/shrine | water/stone resonance/occasional air drips or foliage | loop-safe |

## QA, delivery and platform evidence

- Run existing full regression suite and audio-specific tests appropriate to current candidate. Count actual assertions, not extrapolated numbers.
- Verify audio import, bus names/effects, resource load paths, missing files, loop lengths/clicks and transition lifetime via Godot headless tests where possible.
- Provide audible A/B export or actual gameplay capture with creator-facing directions. A silent headless smoke pass **does not prove sounds are listenable/mixed well**; document manual-listening scope and what remains.
- Capture audio levels/peak/clipping notes and rough CPU/polyphony stress in busiest test room. Avoid claiming sustained 60 FPS from short samples.
- Windows/macOS build packages if feasible. CI-01 exists in an unmerged branch (#13); do not depend on `Run workflow` availability until CI-02 is authorized/merged.
- Prevent unrelated asset, visual, combat, movement or transition edits. Keep short/efficient audio library with transparent manifests and hashes.
- Do not touch `main`, shared integration branches, PR #12, PR #13, or existing agent branches.

## Required publication

Push feature branch `feature/alpha-0.6.1-audio-foundation`, open draft PR targeting `integration/candidate-alpha-0.6.1-gp-ld`. Commit:

- Audio bus/stream resources, small approved original/licensed sound files and integration scripts/scenes where justified.
- `docs/audio/AUDIO_ASSET_REGISTRY.md`: each sound ID, rights/license, file, generator/source, intended use, attribution, format, hash, approval status.
- `docs/audio/AUD01_SFX_PROMPTS.md`: approved original prompt library, usable by the creator in ElevenLabs or other tools.
- `docs/audio/AUD01_AUDIO_ARCHITECTURE.md`: buses, control routing, events, cue priorities, future music integration, limitations.
- `docs/agent_handoffs/AUD01_ALPHA061_PM_REPORT.md`: PM return report, exact branch/SHA/PR, changed files, implemented vs scaffolded sounds, asset legality, test logs and counted assertions, native listening and build evidence, missing rights/assets, risks, next creator approval.
- `docs/agent_handoffs/AUD01_ALPHA061_TEST_RESULTS.json` or equivalent actual machine-readable results.

**Do not merge**. No audio creation subscription purchases without creator approval. If blocked, publish PARTIAL with precise cause, artifacts and next action.

## PM decision gates

1. **Creator audio taste test**: like/dislike cues, volumes, SFX intensity, environmental feel.
2. **Music selection**: creator provides approved Suno exports; separate legal-use checklist.
3. **Integration**: only after audio-specific tests and human listen pass.
4. **Later enhancements**: adaptive layer/beat sync, room-state changes and accessibility controls, if positively reviewed.

## Required handoff format

Return **KAZE PM RETURN REPORT — AUD-01-0061** with:
A. Executive verdict (READY FOR PM REVIEW / PARTIAL / BLOCKED)
B. Source/branch audit
C. Implemented audio architecture
D. Sound asset inventory & rights
E. Cue binding and preservation
F. Tests with PASS/FAIL and engine/build evidence
G. Playable/listening preview, paths and links
H. GitHub PR/SHAs
I. Creator decisions
J. Blockers and follow-up.

**Preserve the creator's music authority. The soundtrack is not part of your independent deliverable.**
