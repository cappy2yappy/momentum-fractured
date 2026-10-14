# AUD-01 actual audio asset registry

Generation date: **2026-10-14**. Author: **Sound Shogun / Codex for Kaze**.
Source: `tools/synthesize_aud01.py`, deterministic seed 61, Python standard
library, original mathematical noise/resonances/envelopes. Source URL:
[repository generator](../../tools/synthesize_aud01.py). No recordings, packs,
Suno tracks or ElevenLabs generations are included. ElevenLabs suitable tool
availability was positively verified (`sfx`, `eleven_text_to_sound_v2`, duration
0.5–30 seconds, prompt influence and loop controls); it was not commissioned.

**All rows below are integrated original candidate sounds, awaiting creator
sonic approval. None are claimed final/approved production audio.**
License for every WAV: **CC0-1.0**, [dedication](../../assets/audio/LICENSE.md),
[official deed](https://creativecommons.org/publicdomain/zero/1.0/).
Copy/modify/redistribute/commercial use allowed; attribution optional, suggested
“Kaze AUD-01 original synthesized sound design.” No external artist attribution
or subscriptions required. Modification: authored synthesis plus envelope/gain;
no third-party source modifications. Format for every file: PCM16 mono WAV,
22,050 Hz. Import: no normalize/trim; compression off. Hashes identify shipped
file bytes. Ambience is explicitly looped by AudioDirector over 176400 samples.

| ID | File under `assets/audio/` | Duration s | Intended use | SHA-256 |
|---|---|---:|---|---|
| `step_stone` | `step_stone.wav` | 0.100 | Grounded stone contact | `60316c8ea50f6ed9a1d32256dc951e30b4a0539bc18abdea976616d03d164d3f` |
| `step_wood` | `step_wood.wav` | 0.120 | R13/14 grounded roof contact | `6fdf36315f77401bdd5ec8a4a0a83f55243ba7b30d6fa0206d48a3d0f7cf94f7` |
| `jump` | `jump.wav` | 0.160 | Accepted ground/wall/double jump | `31d191bb9194fe0922f9709ddfa0648a99c8e9d4e0233f9b78df74a2b2289ca1` |
| `land` | `land.wav` | 0.180 | Airborne-to-floor transition | `6d517a56c75ca08a60de6c1b7cf207f4e2314f927826afedf4a49e4fc90e6c23` |
| `dash` | `dash.wav` | 0.240 | Accepted Gale Dash | `17064b4c11aaf9b44fc24428359e02d6816b70a03ffb8b0c5f9015d924fa2910` |
| `tether_fire` | `tether_fire.wav` | 0.120 | Successful anchor selection | `a0341b931ec206e7fab6b4d3fbe76d54bb6c42ad0c5fe82cb5b81a602c3d4d5e` |
| `tether_attach` | `tether_attach.wav` | 0.180 | Accepted tether attachment | `2acaaa21edd186469e56ccf6d7065a1ef9b666b8713a89e71d6778b422fbb347` |
| `tether_release` | `tether_release.wav` | 0.150 | Actual attached rope release | `6f4113ad2c88ec7ec831c4723d8b5eb2cff0e7f6cdd9c6d1f116bb98137f244e` |
| `swing` | `swing.wav` | 0.180 | Melee attack start | `4c53cbfdedd7f29ec0999a40ab0ad491d77748d0c2c73bedfd0409f4d3897547` |
| `contact` | `contact.wav` | 0.140 | Confirmed melee hit | `a7be2c0ec6db7c3922d89aaa1fe2d471f646ecbda11e8c0c938bb19cbe693612` |
| `kunai_throw` | `kunai_throw.wav` | 0.130 | Actual projectile spawn | `1f1b0923e3a3b84aa220e392ef8e097f277764ebb1ef28c48342cb0b09312bfc` |
| `impact_wind` | `impact_wind.wav` | 0.220 | Wind projectile contact | `df4854a75880ebe3359603a2f93c2813ead0f48754489a94e32cfb2fa42d0c9c` |
| `impact_fire` | `impact_fire.wav` | 0.250 | Fire projectile contact | `c52769d13d00335aa19c3f1e66258f0a7c2bfe8e61392075dc268c7329b035e1` |
| `impact_electric` | `impact_electric.wav` | 0.220 | Electric projectile contact | `3413db061c69ce8c312ac2627dc3d0c8f2f08db109a361d1ce7fd31344390970` |
| `parry` | `parry.wav` | 0.380 | Successful Guard/Keeper parry | `e5d4f0cf419e8e2b10c4039cabb912605e9ddaa8358ecadebe3b3d03c2c70f4c` |
| `damage` | `damage.wav` | 0.230 | Accepted hurt or nonlethal fall | `ee07d2050586a8b64b01847e99e362430298d815b46f77a8a6f3a39f7547e419` |
| `death` | `death.wav` | 0.550 | Lethal hurt/fall | `a6c0aafa27cd36e219be9c8faa6a0aedaa3e712aa9eb5d746848cac7896f9f48` |
| `checkpoint` | `checkpoint.wav` | 0.650 | Shrine/relay interaction | `7998c137472b8386865d6bfdad68f8d94fc981655b16c199a92b803d4d8b2b7b` |
| `room_passage` | `room_passage.wav` | 0.300 | Accepted room request | `725d1cc9b3bb7d15824d16408cfb392a88d57302e802b95e13a16f864089641c` |
| `reject` | `reject.wav` | 0.120 | No available tether anchor | `b77ef3874a7ad82737b7bb9930ed0417dc0fec9a04ae36a29e40362bc57e6b43` |
| `amb_city` | `amb_city.wav` | 8.000 | City/roof continuous wind | `23300b87b30ef352c345659e88da209805dad4d15084b2e4c3e94c81acbaf424` |
| `amb_canal` | `amb_canal.wav` | 8.000 | Canal/shrine continuous resonance | `afd1cc3db0cfe0d74349e7f043533ecc29018f3d51b8c8e415c33f1411ee5e90` |

**Actual runtime WAV footprint: 910,310 bytes across 22 files.**
Machine inventory: `assets/audio/AUD01_MANIFEST.json`; measured source
levels/seams: `docs/agent_handoffs/aud01_evidence/ASSET_ANALYSIS.json`.

## Audible review artifact

`docs/agent_handoffs/aud01_evidence/AUD01_ENGINE_MIX.wav` is a 33.30-second
native Godot CoreAudio mixer recording of seeded real actions, both ambient
seams, then deliberate cue stress. It is downmixed/resampled to mono 22,050 Hz
for compact review. The raw stereo 48k recording is in ignored `build/aud01/`.
This derivative uses only the original assets above and shares CC0-1.0.
Human listening approval is pending; it is not a finished soundtrack.
Timeline and actual cue counts are in `AUD01_PREVIEW_RESULTS.json`.
Preview SHA-256: `30526b074c5a4aaf94595305ec777418ef4c5e42311d7ed965fc4885f762fe7f`.

## Music inventory — intentionally empty

No soundtrack assets supplied or integrated. Music players/API are functional
and silent. Do not infer creator selection, Suno rights or exclusivity.
For each future track/stem record file/hash, source/export URL, creator identity,
generation and export dates, account/plan at generation, rights status and
verification date, modifications, commercial/redistribution conditions, loop
markers, mix notes and explicit Music Director approval before inclusion.
