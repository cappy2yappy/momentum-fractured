# AUD02 listening and integration candidate

**PARTIAL CREATIVE REVIEW; TECHNICAL CANDIDATE. No merge authorization.**

AUD01 recovered from `da121f19f85b49c3bb5e1c7910472c448c673935` / draft PR17.
Existing architecture, buses, voices, triggers, gameplay and 22 WAVs are retained.
The creator rejected the previous sound-design direction; that feedback does
not imply approval of a specific supplied recording or these new prototypes.

## What is ready

- [Full inventory](AUD02_INVENTORY.csv): 496 pack recordings + 16 supplementary
  recordings, all decoded and measured. The ZIP hash matches the assignment.
- [Audit summary](AUD02_AUDIT_SUMMARY.json): safety, formats, duplicates, flags.
- [Provisional slate](AUD02_SHORTLIST.json): 28 event comparisons, each with two
  alternate references, exact filenames/hashes, intended use and pending approval.
- [Public-safe listening board](REVIEW.html): download and open locally; only
  original candidate/fallback audio is embedded. Original-reference playback is
  in the separately delivered PRIVATE `Kaze-AUD02-Listening-Review.html`.
- [Cue matrix](CUE_MATRIX.md), [provenance](PROVENANCE.md), and 12 new original
  candidates under `assets/audio/aud02/` with a deterministic generator/license.

## Listening limitation

The agent inspected decoded waveforms and measured duration, attack delay,
spectral energy, levels, boundaries and exact PCM duplicates. **It did not hear
the recordings.** The 28 candidates are automatically selected starting points,
not an artistic ranking. Zero recordings have confirmed subjective suitability.
Words such as `resonant/tonal` and `noise-rich` are measurement-derived heuristics,
not verified perceptual descriptions. Harmonic voices, dialogue, recognizable
effects, music, ambience suitability and recording defects need listening.
No claim is made that mathematical filtering solves the creator's taste concern.

Open the private HTML in Chrome/Edge after downloading. Each card presents
A reference, B original alternative where available, C AUD01 fallback, and two
alternate references. Additional files have individually labeled excerpt players.
Previews are mono22k PCM16 and attenuated only to a peak ceiling of -18dBFS;
no source onset is removed. They are not LUFS or perceived-loudness matched.
Record one preference and notes per cue, then download the decisions JSON.
There is no network submission. Do not publicly post the private HTML.

## Isolated in-engine review

Normal launch keeps AUD01. Add `--audio-bank=aud02` after Godot's `--` separator
to replace only the 12 authored cues. Missing candidates keep the existing sound.
The supplied review launcher includes `--test`, so personal progression is never
loaded or saved. Music remains silent. No extra movement, slide, enemy-death,
UI, collectible or tether-loop hooks were invented for this task.

From source: `Godot --path . --script res://tests/audio_playtest.gd -- --test --audio-bank=aud02`
uses the existing seeded R4 fixture for dash/tether/element review. Normal exported
review starts at R0; advanced abilities still require normal campaign unlocks.
Compare without `--audio-bank=aud02` for the existing bank.

## Reproduction

Python audit/review/synthesis tools require numpy, scipy and soundfile. Reference
paths must stay outside this repository. `audit_aud02.py` validates all ZIP paths,
collisions, symlinks, encryption, size limits and CRC before safe extraction.
Keep originals unchanged; CSV/JSON preserve exact filenames and SHA256 identities.

Run `python tools/run_aud02_qa.py --godot <Godot4.6.1>` for fresh source QA.
The Windows runner redirects APPDATA/LOCALAPPDATA and verifies `user://` points
inside disposable build profiles before save fixtures. Do not use the historic
Mac-specific runner on Windows without equivalent isolation.
`package_aud02.py` takes `--godot`, `--templates`, `--deliver` and restores export
presets byte-for-byte after exporting. Large builds remain outside source Git.

## Known limits

No perceptual audition, taste approval, full human campaign playthrough,
end-to-end latency, long-session reliability or sustained60FPS certification.
macOS exports are cross-builds, not current macOS execution. No sources are
rights-cleared for redistribution; only original AUD01/AUD02 sounds ship.
