# AUD-02-0061 — Creator-Supplied SFX Library Audit and Sound Selection

**Owner:** The Sound Shogun (Audio Designer / Godot Engineer)
**Requested by:** Creator, via PM-01
**Status:** Assigned for inventory and rights review; source ZIP not yet uploaded to GitHub
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Existing implementation:** https://github.com/cappy2yappy/momentum-fractured/pull/17
**Recovery record:** https://github.com/cappy2yappy/momentum-fractured/blob/docs/pm02-agent-continuity/docs/agent_continuity/sound_shogun/RECOVERY.md
**Source supplied to PM:** `S1PS3SFX.zip` (conversation attachment; must be made available to agent through authorized file transfer)
**SHA-256:** `46c15f62b9b6a8a4aded5a61ae0902570e7a43ff575313c63ef99f4622ce2e95`

## Creator feedback and mandate
Creator listened to AUD-01 synthesized sound preview and is **not satisfied with its sound design**. New ZIP is the creator's proposed alternative/reference library. Do not assume that the creator approved every sample, or that technical acceptance of AUD-01 constituted sound-design approval. Keep existing audio system intact during selection.

## Verified source inventory
Source ZIP **not committed to GitHub**. Observed 496 valid WAV files (uncompressed 159,476,266 bytes; ZIP ~130 MiB), all PCM 16-bit 48kHz: 459 mono and 37 stereo. Groups derived from filenames:

| Prefix | Count |
|---|---:|
| `commse0` | 177 |
| `battle` | 141 |
| `pupSe` | 75 |
| `missionSe` | 51 |
| `hugebtl` | 36 |
| `minigame` | 14 |
| `Dolby` | 1 |
| `logo_cc2` | 1 |

No license, attribution or provenance text appears inside the archive. The original filename categories are **not** verified semantic descriptions, e.g. `battle (20).wav` is not necessarily a Kaze combat sound.

## Work order
1. **Rights gate first.** Ask PM/creator for origin and distribution rights. Until cleared, treat samples as private listening/reference material. Do not upload raw WAVs/ZIP to public GitHub, produce public binaries using the files, or merge them into production.
2. Verify SHA-256, safety of the ZIP, complete asset inventory, technical parameters, filenames and duplicate/near-duplicate clusters. Never run source-pack scripts; no executable files are expected.
3. Audition each sample, tagging understandable sonic descriptors (blade, whoosh, impact, elemental, interface, environment, heavy boss, unusable/noisy) based on listening, NOT filenames alone. Note clips, loudness, attack, tail, obvious artifacting and suitability for 60 FPS play.
4. Draft a mapping for gameplay cues: steps stone/wood, jump, land, dash, grapple fire/attach/release, attack swing/hit, parry, hurt/death, kunai throw and wind/fire/electric impacts, checkpoints, doors/passages, blocked interactions, UI confirm/back, room ambience; list two or three candidates for contested assignments.
5. Prepare a **labeled review board** with cue ID, source filename, duration, proposed event, ratings, and timestamped A/B previews. Maintain creator approval column (Approve/Revise/Reject) blank until reviewed. A public GitHub report can reference samples by name, but audio previews must not be published until redistribution is authorized.
6. Preserve original AUD-01 synthesized SFX and audio director as non-destructive fallback. Once rights and creative review are cleared, integrate only approved choices in an isolated `feature/alpha-0.6.1-audio-curation` branch (or an updated PM-approved target); update audio cue mapping and source provenance, keep save/gameplay/transition behavior unchanged.
7. Run source regressions, export tests, audible in-engine and Windows/macOS smoke where available. Report exactly what's tested and what is not, including asset-license status. Prepare a draft PR and PM handoff, never merge into `main`/integration without approval.

## Delivery requirements
- Full sample inventory and rights/provenance verdict.
- Listening-based shortlist matched to individual Kaze actions.
- Creator-friendly labeled soundboard/previews, respecting licensing.
- Code and approved audio only after authorization; exact commit SHA and draft PR.
- Update `docs/agent_continuity/sound_shogun/` when PM-02 protocol is merged.

## Current blocker
The source ZIP is a conversation attachment, **not** yet an available GitHub asset. The available GitHub connector only creates UTF-8 files; it cannot upload the 130 MiB binary archive as-is. Its origin and redistribution license are also unknown. Report the blocker rather than claiming assets were deposited.
