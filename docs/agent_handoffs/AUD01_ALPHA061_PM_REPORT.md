# KAZE PM RETURN REPORT — AUD-01-0061

**Date:** October 14, 2026 (America/New_York)  
**Owner:** THE SOUND SHOGUN — Audio / Godot Integration / Technical Audio QA  
**Verdict:** **READY FOR PM REVIEW** — playable audio candidate, pending human
listening and creator acceptance. This is not production, integration or merge approval.

## A. Executive verdict

Implemented Kaze's first real audio slice on the approved combined Alpha 0.6.1
foundation: **20 original gameplay cues, two environment loops, four dedicated
bus routes, controlled polyphony, pause/respawn/transition cleanup and a functional
silent music API**. The WAV library is **910,310 bytes**. Actual gameplay actions
and confirmed contacts drive sound; no movement/combat/progression retiming.

Final source QA: **765 PASS / 0 FAIL** (691 existing + 74 audio assertions).
Exported macOS PCK: **74 PASS / 0 FAIL** using the same audio suite against
exported resources/code. Both release packages pass pack integrity, original
world-data, audio-inclusion and ZIP CRC audits. Native Apple M4 release app
starts successfully for 120 frames. A **33.30-second native CoreAudio internal
mixer recording** is published, measured peak **-10.82 dBFS**, zero
clipped PCM samples. It records generated game audio, not a microphone.

Creator listening/taste approval, approved music, platform endurance and
sustained 60 FPS remain gates. No soundtrack was generated, selected or commissioned.
Nothing was merged; all other branches remain untouched.

## B. Source and branch audit

Read the complete authoritative [AUD-01 work order](https://github.com/cappy2yappy/momentum-fractured/blob/e964cdc994c7e7f692a4bf8fc892dbb526d57a11/docs/agent_assignments/AUD01_ALPHA061_AUDIO_FOUNDATION.md)
before implementation. Read AGENTS.md, canonical baseline, repository guide,
controller/manifest, player/world/enemy/projectile/expansion/skyworks scripts,
HUD, scene/autoload/export configuration, existing QA and build references.
The audited candidate had **no pre-existing WAV/OGG/MP3 assets or audio players**.

Remote combined candidate was verified at
[`afecef1922231081807a332c511de85c7941fec8`](https://github.com/cappy2yappy/momentum-fractured/commit/afecef1922231081807a332c511de85c7941fec8).
This matched the assignment's observed head. A separate clone was created at:

`/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/aud01-alpha061`

Dedicated branch: `feature/alpha-0.6.1-audio-foundation`. Runtime implementation
commit: [`a24b500b92b94f53079ae197388146afbad47af2`](https://github.com/cappy2yappy/momentum-fractured/commit/a24b500b92b94f53079ae197388146afbad47af2). All recorded runtime hashes in the build
manifest match that committed source. Packaging-validator fixes, final evidence
and this PM report are a publication follow-up; gameplay/audio runtime is unchanged.
The final publication SHA/permalink is returned in the chat.

Read/reference only: [PR #12](https://github.com/cappy2yappy/momentum-fractured/pull/12), open/unmerged at
`c26cb7fa23131c2fd9c8deae288f7d0d468a6b52`; [PR #13](https://github.com/cappy2yappy/momentum-fractured/pull/13), open/unmerged
at `e0b70b6371342907fcaff1060e551ab3a6418860`. No cherry-picks, workflow installation,
transition-art integration or dependency on TR-02. Existing specialist checkouts
and read-only synced `sources/` material were not edited.

## C. Implemented audio architecture

- `default_bus_layout.tres`: Music (-8 dB), SFX (-4 dB), Ambience (-8 dB), UI
  (-6 dB) to Master; limiter ceiling -1 dB, threshold -3 dB.
- `scripts/audio/audio_director.gd`: one world-owned persistent node, 12 fixed
  single-voice effect players (eight ordinary, four reserved critical), two
  ambience slots, two silent Music slots. Maximum 16 players during both crossfades.
- Ordinary overflow drops; critical overflow replaces oldest critical voice;
  160ms step, 70ms ordinary, 40ms critical same-cue rate limits. No dynamic
  synthesis during gameplay. Asset loads occur once on startup.
- Actual movement distance and resolved floor state produce sparse steps and
  landings; room teleports reset tracking. R13/14 use wood, other rooms stone.
- City/roof wind versus canal/shrine water/stone profiles crossfade over 0.4s;
  repeated same-profile entry does not restart. No new rooms or biome canon.
- Pause/map/kit/focus-loss stops effects and suspends ambient/music streams;
  unpause resets walking distance. Room rebuild suppresses action-reset emissions.
  Damage/death tails survive recovery. Accepted passage gets one short cue.
- `set_music(stream)` accepts future approved exports, crossfades over 0.6s;
  repeated same stream preserves phase; `null` fades to silence. **No music asset**
  is assigned to gameplay. Tests use an ambience fixture only to exercise the API.
- Independent 0–1 launch controls: `--audio-music=…`, `--audio-sfx=…`,
  `--audio-ambience=…`, `--audio-ui=…`; zero mutes. Runtime setter supports future
  settings UI. Persistent sliders are deferred to preserve locked HUD/save structure.

Full event routing, limits, format choices, future Suno handoff and ducking policy:
[Audio architecture](../audio/AUD01_AUDIO_ARCHITECTURE.md). Adaptive music,
automated ducking, beat sync and stems remain proposed work, not implemented.

## D. Actual asset inventory and rights

All **22 files are integrated original synthesized candidate sounds**, not
externally generated previews or stock placeholders mislabeled final. They are
awaiting creator sonic acceptance. `tools/synthesize_aud01.py` authors noise,
resonance and envelopes deterministically (seed 61). No borrowed recordings,
recognizable riffs, sampled packs, voices or third-party music are included.

CC0-1.0 dedication: `assets/audio/LICENSE.md`; per-file paths, authorship,
source/generation date, intended use, license/attribution, hashes, approval state
and future music rights fields: [Asset registry](../audio/AUDIO_ASSET_REGISTRY.md).
Runtime format: PCM16 mono WAV at 22,050 Hz, normalization/trim off, compression
explicitly disabled. Two eight-second loops use exact sample ranges.

Integrated effect IDs: `step_stone`, `step_wood`, `jump`, `land`, `dash`,
`tether_fire`, `tether_attach`, `tether_release`, `swing`, `contact`, `kunai_throw`,
`impact_wind`, `impact_fire`, `impact_electric`, `parry`, `damage`, `death`,
`checkpoint`, `room_passage`, `reject`. Ambience IDs: `amb_city`, `amb_canal`.

The live ElevenLabs schema verified a suitable `sfx` / `eleven_text_to_sound_v2`
operation with duration, prompt influence and loop controls. Generation was
not commissioned. [Original external-production briefs](../audio/AUD01_SFX_PROMPTS.md)
cover all cues and both ambience profiles, lengths, layers, tonal range, prohibited
signatures, dry/wet variants and preferred formats. These briefs are authored
proposals; they do not imply creator approval or completed external production.

Music inventory is empty. Creator remains Music Director. Future approved Suno
exports need generation/export dates, account/plan at generation, rights
verification, intended loop/stems and explicit approval in the registry. No Suno
credentials or subscription purchases are required for this handoff.

## E. Cue binding and preservation

Jump emissions occur only in accepted ground/coyote, wall and double-jump
branches. Dash only after the approved impulse/gate checks. Swing follows
actual attack/combo starts; independent contact plays only after closest valid
melee target confirmation. Kunai throw occurs at spawn; elemental impact only
at actual seal/enemy contact, including a physically contacted mismatched seal.
Misses/expiration do not fake a hit. Successful facing/range parries in Guard
and Storm Keeper emit the same cue. Player hurt and fall decrements distinguish
nonlethal damage from death; invulnerability suppresses rejected hits. Accepted
anchor, guarded release and successful line-fire have distinct events; no anchor
gets a quiet reject tick. Checkpoint cues bind to actual shrine/relay interactions
(R0/3/7/8/11/12/16), not every automatic persistence write. Passage follows
accepted `request_room`; rejected/repeated transitions have no false success sound.

The preservation audit checks **69 pre-existing runtime/art/world/config files**.
Every audited gameplay script reproduces its pre-audio bytes after removing
explicitly tagged `# AUD01 audio-only` additions. Original/cleaned sprite bytes,
scene, geometry/map data, momentum/grapple calculations, scale/animation code,
ability gates, damage, input, arrivals, HUD hierarchy, project/save identity and
version-8 serialization are unchanged. The asset manifest updates controller/
physics hashes for the observation emissions, retains old hashes, and the
baseline verifier additionally proves stripped controller equality. This is
an explicit audio-only checksum change, not approval of altered physics.

Changed runtime files: bus layout, director, `player.gd`, `world.gd`, `guard.gd`,
`storm_keeper.gd`, `route_extension.gd`, `skyworks_region.gd`, `world_expansion.gd`,
new audio assets/import metadata and controller manifest. Added verification,
packaging, source review fixtures and documentation/evidence. Baseline verifier
is strengthened. No unrelated art, UI, story, progression or level edits.

## F. Actual QA and platform evidence

Engine: **4.6.1.stable.official.14d19694e**. Host: macOS / Apple M4,
OpenGL compatibility renderer, native CoreAudio for recordings/performance.
Existing persistence suites use the existing runner's disposable profiles;
audio/preview/release smoke uses `--test` and never loads/saves creator progress.
Final complete reproduction: `python3 tools/run_aud01_qa.py` (no regression reuse).

| Source suite | PASS | FAIL |
|---|---:|---:|
| approved_baseline | 32 | 0 |
| approved_combat_swing | 7 | 0 |
| annex_expansion | 34 | 0 |
| annex_traversal | 6 | 0 |
| save_compatibility | 11 | 0 |
| skyworks_progression | 33 | 0 |
| storm_keeper | 12 | 0 |
| movement_momentum | 53 | 0 |
| sprite_integration | 43 | 0 |
| world_expansion | 193 | 0 |
| expansion_gates_save | 17 | 0 |
| expansion_traversal | 125 | 0 |
| gameplay_stabilization | 16 | 0 |
| traversal_transitions | 8 | 0 |
| world_cohesion_traversal | 56 | 0 |
| integration_candidate | 12 | 0 |
| integration_descent | 26 | 0 |
| profile_prepare | 2 | 0 |
| profile_reload | 5 | 0 |
| audio_foundation | 74 | 0 |
| **Source total** | **765** | **0** |
| Exported macOS PCK audio suite (separate execution) | 74 | 0 |
| **Source + exported-resource assertions executed** | **839** | **0** |

Import and baseline verification separately exit 0. Audio assertions cover all
20 imported cues, two exact loops, routing/limiter, pool budgets, music silence
and handoff, action gates/contact, both parry implementations, damage/recovery,
checkpoint bindings, repeated/rapid room changes, pause/unpause, independent
mute, overload priorities and real walking/jump/landing. No script/parse/load
errors in final suites. Full counted results: [JSON](AUD01_ALPHA061_TEST_RESULTS.json).
Raw per-suite logs, preservation hashes, asset levels/seams and package audits:
[aud01_evidence](aud01_evidence/).

Source PCM analysis: zero clipped samples on all 22 files; the two loop wrap
sample deltas are no greater than their internal adjacent-sample maximum.
Native mixer recording: 33.301s, raw stereo 48k PCM16, peak
-10.82 dBFS, RMS -31.68 dBFS, **0 clipped samples**.
This is technical output evidence. It does not establish subjective balance,
noise/whistle fatigue, headphone/speaker translation or creator loop acceptance.

Final sequential native R1 three-guard samples at a 60 FPS cap, after tests/
exports completed, 1s warm-up then approximately 6s per mode:

| Mode | Frames | Mean ms | p95 ms | Max ms | Engine process CPU p95 ms | Physics CPU p95 ms |
|---|---:|---:|---:|---:|---:|---:|
| silent_control | 366 | 17.514 | 18.968 | 119.281 | 106.782 | 7.493 |
| audio_stress | 388 | 16.666 | 17.348 | 41.682 | 44.350 | 1.869 |

Five-cue dispatch p95: **157µs**. Native stress
high-water: **8 of 12 effect voices**, zero ordinary
voice drops in that sample; deterministic overload test separately confirms
bounded dropping and reserved critical voices. Native process monitors include
the scene/engine and are coarse; they do not measure total audio-thread cost.
Both modes miss the 16.67ms budget. Scene state evolves between samples, so this
is not a controlled causal benchmark of audio overhead. **Sustained 60 FPS is
not certified; hitches require follow-up profiling.** Earlier uncapped paired
samples and concurrently collected recording timings are retained separately;
they are not used to claim a target frame rate.

Both Windows x86_64 and macOS universal exports succeeded with supplied 4.6.1
release templates. Every PCK payload MD5 and original world file was checked;
all 22 imported audio samples and bus/director mappings exist; zero forbidden
docs/tests/tools/build entries. macOS universal header contains two architectures.
Each review ZIP passes CRC. Exported PCK audio behavior passes 74 assertions.
Actual macOS release native boot for 120 frames exits 0 with no script/load
errors. **Windows runtime and Intel Mac execution are untested.** Packages are
unsigned/unnotarized internal review artifacts, not remotely published releases.

Nonfatal diagnostics: headless macOS certificate-store retrieval, engine/MetSys
RID/ObjectDB teardown warnings, and sandbox-denied editor-settings writes during
exports; recorded in raw logs. Import/export exit codes and actual pack/boot
checks passed. Initial PCM import test caught default QOA compression and exact
loop-count mismatch; committed imports disable compression. A cached floor
state in the tether fixture was corrected by advancing real physics before
attachment. Packaging audit initially assumed text `.tres` remained unconverted;
it now accepts the Godot `.tres.remap` representation, with actual exported
runtime tested. A bare copied editor executable was killed; the installed editor
and explicit local templates exported successfully. No implementation blocker
or rejected approval remains. No headless run is presented as a human listen pass.

## G. Playable and listening preview

[Native engine mix WAV](aud01_evidence/AUD01_ENGINE_MIX.wav), also accessible at:

`/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/aud01-alpha061/docs/agent_handoffs/aud01_evidence/AUD01_ENGINE_MIX.wav`

The review derivative is mono 22,050 Hz for compact playback, generated from
the raw engine mixer recording. Approximately 0–9s: actual movement/combat/
tether/element/checkpoint cues; 9.8–18.1s: roof loop; 18.1–26.4s: canal loop;
26.4–33.3s: explicit audio stress. Exact events/counts and source level analysis
are adjacent JSON evidence. Seeded scripted gameplay, not a human campaign
capture and not a composed score. Listen on headphones and ordinary speakers;
compare legibility, intensity and loop repetition before approving.

Local review packages (large binaries stay out of source Git):

- `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/aud01-alpha061/build/aud01/exports/Kaze-AUD01-Alpha061-macOS-Review.zip` — 76,379,093 bytes; SHA-256 `04eef205805ce4bdf02ff9a4afb12e1bc59a08acd2829f275d3922720d4e19f6`; CRC PASS.
- `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/aud01-alpha061/build/aud01/exports/Kaze-AUD01-Alpha061-Windows-Review.zip` — 51,581,512 bytes; SHA-256 `a869150bfe26aa32f4dbe3c13c109a8f00747a96445f167a0babbd3787261582`; CRC PASS.

Unzip and use **Play Audio Review.command** (Mac) or **Play Audio Review.bat**
(Windows). They pass `--test`: no creator profile is loaded or written; all
progress is temporary. Opening the executable normally retains the original
application/save identity, so use the supplied review launcher for isolation.
The shipped wrappers begin in R0 without earned abilities. A/D move, double
tap runs, Space jump, J attack, F parry, E interact; Q tether, Shift dash and
R/T kunai after normal unlocks; M map, I kit, Escape pause.

1. Walk/jump/land in R0, stop and verify steps stop. E at Haven shrine checks
   checkpoint. E at east exit to R1 changes canal to city ambience; return and
   compare fade/phase. Holding/repeating E cannot retrigger passage.
2. R1 guard checks missed versus confirmed melee, facing parry and damage/death.
   Pause/map/kit/focus loss checks silence and resume without catch-up footsteps.
3. Source fixtures give immediate all-ability review, explicitly seeded and
   save-disabled. From this checkout:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --log-file /tmp/aud01-review.log --script res://tests/audio_playtest.gd -- --test
# Add --roof for R14 or --canal for R15 after --test.
```

Default seeded R4 gives actual tether anchors, enemies and kunai seals. Use
R14 for wood steps/city bed and R15 for canal bed; test existing doors and falls.
For external machines substitute the installed Godot 4.6.1 executable path.
No review fixture grants saved earned progression.
4. Compare independent launch levels, e.g. `--audio-sfx=0.8 --audio-ambience=0.6`.
   Report cue, room, action, device, loudness/fatigue and any missing/duplicate cue.
5. Reproduce recording with `tests/audio_preview.gd` under native Godot and
   `--test`; reproduce timing with `tests/audio_performance.gd --test` and a
   60 FPS cap. Files are written under ignored `build/aud01/`.

## H. GitHub references and publication

- [Draft PR #17](https://github.com/cappy2yappy/momentum-fractured/pull/17), target
  `integration/candidate-alpha-0.6.1-gp-ld` at `afecef1922231081807a332c511de85c7941fec8`.
- [Feature branch](https://github.com/cappy2yappy/momentum-fractured/tree/feature/alpha-0.6.1-audio-foundation).
- [Exact runtime commit](https://github.com/cappy2yappy/momentum-fractured/commit/a24b500b92b94f53079ae197388146afbad47af2).
- [Runtime source/audio evidence snapshot](https://github.com/cappy2yappy/momentum-fractured/tree/a24b500b92b94f53079ae197388146afbad47af2/docs/agent_handoffs/aud01_evidence).
- Final PM report, final QA/build/native evidence and packaging validator
  correction are published by a documentation/tooling follow-up. The exact final
  commit permalink is supplied in the originating chat; BUILD_MANIFEST pins
  runtime independently. No binary release/hosted build is claimed.

No merge, force push, history rewrite, shared candidate update, main update,
PR #12/#13 modification or soundtrack selection was performed.

## I. Creator and PM decisions

**Taste review:** accept/revise the original candidate cues, relative SFX/UI/
ambience levels, dash/parry brightness, death intensity, roof/canal atmosphere,
loop repetition and sparse footsteps. A human listen pass is required before
integration approval. Decide whether original synthesis is sufficient or to
commission external replacements from the documented briefs.

**Music:** creator produces/selects music through Suno and provides approved
exports with rights/account/date/loop information. Re-test the full mix with
those tracks. The current engine is ready to receive them and remains silent.

**Integration:** PM separately approves any merge. Performance/platform limits
above remain review risks. Neither the draft PR nor this verdict authorizes merge.

## J. Unfinished work, risks and next owner

No blocking implementation issue remains for this alpha review. Pending:
human listening and taste revisions, soundtrack/assets/rights review,
persistent volume/accessibility UI, deeper per-surface steps/wet contacts,
longer production ambience variations, stereo/world-positioned distant effects,
TR-02 emitter coordination, ducking/beat sync/adaptive music if approved,
long-session frame/audio reliability and Windows/Intel/hardware matrix testing.

The new voice pool has bounded cost, but short samples show existing/native
hitches. Profile scene/render/OS/audio separately before claiming 60 FPS.
Eight-second original loops can feel repetitive; creator must assess longer
listening. Small dry cues are deliberately candidate sound design; detailed
real-world material fidelity is not certified. Linux/web export is not covered.

**Next owner: Creator / PM-01**, for a concrete sound/playable review and
approval/revision decisions. Sound Shogun can revise this branch after feedback.
The feature branch remains isolated; final publication is a handoff, not a merge.
