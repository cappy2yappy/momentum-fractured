# AUD-01 audio foundation

Godot **4.6.1.stable.official.14d19694e**, base `afecef1922231081807a332c511de85c7941fec8`.
The main scene and project identity are unchanged. `world.gd` owns one
`AudioDirector` child, shared across room rebuilds; it is not recreated per room.

## Routing and mix

`default_bus_layout.tres` is the engine's default bus layout. Music (-8 dB),
SFX (-4 dB), Ambience (-8 dB) and UI (-6 dB) send to Master. Master has a
limiter, ceiling -1 dB and threshold -3 dB. Footfalls receive an additional
-4 dB per voice. Sources are deliberately quiet; the limiter is a safety ceiling,
not a loudness target. No runtime DSP allocation or synthesis is performed.
[Godot 4.6 audio bus reference](https://docs.godotengine.org/en/4.6/tutorials/audio/audio_buses.html).

All sources use PCM16 mono 22,050 Hz, no normalization/trim, WAV compression
disabled (`compress/mode=0`). Short attacks need predictable latency and a small
decoded footprint. Before adding an individual track above 10MB or a new batch
above 25MB, agree on Git LFS or asset hosting with the creator; no such music
files are included here. Two eight-second ambience streams are duplicated once at
startup and assigned explicit forward loop sample ranges 0–176400. Their
periodic synthesis has a continuous seam; quantitative seam checks are in
`aud01_evidence/ASSET_ANALYSIS.json`. Auditory loop/click acceptance is pending.
Future long ambience/music should use looped OGG Vorbis after creator listening
and loop-boundary verification; do not copy PCM megatracks into this library.

## Lifetime, priorities and limits

Twelve fixed single-polyphony effect players: eight ordinary and four reserved
for parry, damage, death, checkpoint and passage. Ordinary overflow is dropped.
Critical overflow steals the oldest critical voice. Same-cue gaps: footfall
160 ms, ordinary 70 ms, critical 40 ms. Invalid cues fail quietly. No random
pitch changes hide event identity. Maximum possible active players is 16 during
simultaneous ambience/music crossfades, normally 13 with silent music.

Two ambience players crossfade over 0.4 seconds. A repeated same-biome entry
keeps phase; interrupted fades kill the prior tween and stop the departing
voice when the new fade completes. R0/2/3/8/15/16/18/19/20 use canal/stone-water;
R1/4/5/6/7/9/10/11/12/13/14/17 use city/roof wind. These are soundscape profiles,
not new geography or canon. R13/14 footsteps are wood; other rooms are stone.
Per-platform surface materials and wet contact are deferred.

Pause/map/kit/focus-loss stops action voices and pauses both ambient/music
streams. Unpause resets footfall distance, preventing catch-up bursts.
Room rebuild suspends emissions from gameplay cleanup and clears ordinary
voices. Death/damage tails survive respawn; teleports do not produce landing
sounds. Passage clears stale actions and plays once after the existing gate
accepts; traversal timing and arrival calculations remain unchanged.

## Event bindings

| Cue | Actual hook |
|---|---|
| jump | Accepted ground/coyote, wall and double-jump branches emit player `audio_cue` |
| dash | Successful gated dash impulse emits once; rejected cooldown/gate stays silent |
| swing | `start_attack`, including actual combo starts |
| contact | `world.on_strike` only after a closest valid target is confirmed |
| tether_attach/release | Successful `apply_tether` and guarded `release_tether` |
| tether_fire/reject | World anchor selection succeeds / no available anchor |
| kunai_throw | Actual projectile spawn |
| impact_wind/fire/electric | Actual seal or live enemy contact in `resolve_kunai`; expired/missed projectile is silent |
| parry | Successful facing/range parry branch in Guard and Storm Keeper |
| damage/death | Accepted player hurt signal or fall recovery decrement; invulnerability rejects repeats |
| checkpoint | Actual R0/3/7/8/11/12/16 shrine/relay interaction; auto-save is silent |
| room_passage | Accepted `request_room`, before existing 0.65s transition |
| land/step | Post-controller resolved floor transition / grounded horizontal distance threshold 125px |

The director has physics priority 100, after the default-priority controller.
It reads state and does not write player position, velocity, input, damage,
abilities, timers or progression. Tagged audio-only additions can be removed
to reproduce every prior gameplay script byte for byte. The manifest records
new controller/physics checksums and retains pre-audio checksums; the baseline
verifier also proves the stripped controller equals its prior checksum.

## Music Director handoff — implemented silent infrastructure

Two Music `AudioStreamPlayer` slots are implemented. `world.audio.set_music(stream)`
crossfades approved streams over 0.6 seconds; the identical resource does not
restart. `set_music(null)` fades to silence. No track is selected, generated,
bundled or automatically mapped to a room. Tests use an ambience fixture only
to verify this API, then return to silence. No demo tone ships as a score.

Creator supplies approved exported OGG Vorbis (preferred for runtime), or WAV
master/stems, with BPM if relevant, loop/start/end intent, loudness notes,
Suno generation/export date, account/plan-at-generation, rights verification,
source URL and explicit creator approval. Place accepted files under a future
`assets/audio/music/` and add individual hashes/rights to the registry first.
Check the full combined mix again when tracks arrive. Beat sync, stem adaptation
and automated combat ducking are deferred: the slice has no music to duck.
Proposed later duck is a short -3 dB Music dip for damage/death, not for every
footfall, subject to Music Director approval.

## Controls and future transitions

Independent launch controls (0 mute to 1 full authored mix):
`--audio-music=0.7 --audio-sfx=0.8 --audio-ambience=0.6 --audio-ui=0.8` after
Godot's `--` separator. `set_volume(bus, value)` is available for a future menu.
Values clamp to 0–1 and invalid numeric arguments are ignored. A persisted
slider menu is deferred to preserve the locked HUD hierarchy and save schema.

TR-02 can call `audio.play("room_passage")` through the existing accepted
transition event or subscribe to the same boundaries. Remove the current call
when installing a second emitter; same-tick rate limiting is only a backup.
No dependence on PR #12, #13 or TR-02 scripts/geometry. The fade policy is
audio-based and remains the same for future reduced-motion rendering.

## Verification and limits

See `AUD01_ALPHA061_TEST_RESULTS.json`, raw per-suite evidence, mixer analysis,
short paired native performance samples and the PM report. Headless tests
establish logic/resource reliability; native CoreAudio recording establishes
actual mixer output. Neither proves a human likes the mix. Human listening,
full campaign endurance, Intel Mac/Windows execution and persistent volume UI
remain pending. Reproduce with `python3 tools/run_aud01_qa.py`.
