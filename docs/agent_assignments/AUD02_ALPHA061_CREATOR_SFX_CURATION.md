# AUD-02-0061 — Creator-Supplied SFX Library Audit and Sound Selection

**Owner:** The Sound Shogun (Audio Designer / Godot Engineer)
**Requested by:** Creator, via PM-01
**Status:** AUD02 technical candidate submitted; creative audition remains partial. Source ZIP intentionally excluded from public Git because rights remain unverified.
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Existing implementation:** https://github.com/cappy2yappy/momentum-fractured/pull/17
**Recovery record:** https://github.com/cappy2yappy/momentum-fractured/blob/docs/pm02-agent-continuity/docs/agent_continuity/sound_shogun/RECOVERY.md
**Source supplied to PM:** `S1PS3SFX.zip` (conversation attachment; must be made available to agent through authorized file transfer)
**SHA-256:** `46c15f62b9b6a8a4aded5a61ae0902570e7a43ff575313c63ef99f4622ce2e95`

## Creator feedback and mandate
Creator listened to AUD-01 synthesized sound preview and is **not satisfied with its sound design**. New ZIP is the creator's proposed alternative/reference library. **Creator explicitly authorizes auditioning, shortlisting, mapping effects to gameplay, creating original replacement candidates, and integrating selected suitably licensed effects in a development branch after creator selection.** Do not infer approval of individual clips. Preserve existing audio system intact and synth SFX as fallbacks, and do not change gameplay feel or saves.

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
1. **Rights and provenance classification in parallel, not a blocker for auditing.** Creator says the pack came from an audio engineer friend who described it as public domain, but no original license document or source is available. Record this as **unverified public-domain claim**. Immediately proceed with inventory, internal audition and candidate identification. Do not upload raw WAVs/ZIP to public GitHub or public downloadable builds until appropriate redistribution rights can be verified. Contact PM only if additional proof is needed for public release.
2. Verify SHA-256, safety of the ZIP, complete asset inventory, technical parameters, filenames and duplicate/near-duplicate clusters. Never run source-pack scripts; no executable files are expected.
3. Audition each sample, tagging understandable sonic descriptors (blade, whoosh, impact, elemental, interface, environment, heavy boss, unusable/noisy) based on listening, NOT filenames alone. Note clips, loudness, attack, tail, obvious artifacting and suitability for 60 FPS play.
4. Draft a mapping for gameplay cues: steps stone/wood, jump, land, dash, grapple fire/attach/release, attack swing/hit, parry, hurt/death, kunai throw and wind/fire/electric impacts, checkpoints, doors/passages, blocked interactions, UI confirm/back, room ambience; list two or three candidates for contested assignments.
5. Prepare a **labeled review board** with cue ID, source filename, duration, proposed event, sonic notes, preference rating and creator choice (Approve/Revise/Reject), initially blank. Supply comparisons in a private review environment when reference redistribution is not established. A public GitHub report may reference names/metadata but must not publish source audio previews until authorized.
6. **Two-track implementation:** (A) For creator-liked recordings with verified adequate rights, import selected WAVs, normalize/mix and assign to the Godot cue registry on isolated `feature/alpha-0.6.1-audio-curation`; (B) for recordings with unverified rights, create **original Kaze sounds** inspired by broad sonic attributes (transient, weight, pacing, ambience, impact), not sampled/copied/recreated recognizable protected content, and assign those originals instead. Private local audition prototypes may use the source files if their terms permit, but must not be uploaded as public artifacts. Preserve original AUD-01 synth SFX and audio director as non-destructive fallback. No unrelated gameplay, saves, gates, or transition code changes.
7. **Do not wait for all 496 to be creatively approved before prototyping originals.** Submit a top-ranked 20–30 candidate slate by gameplay event, creator-friendly labeled A/B soundboard, and staged audio branch with original/verified rights-cleared candidate sounds in engine. Run source regressions, exports, audible in-engine Windows/macOS smoke where available. Report precisely what's tested and which sounds are placeholder/approved/original/right-cleared. Prepare a draft PR and PM handoff. Never merge into `main`/integration without PM approval.

## Delivery requirements
- Full sample inventory and rights/provenance verdict.
- Listening-based shortlist matched to individual Kaze actions.
- Creator-friendly labeled soundboard/previews, respecting licensing.
- A first playable audio integration candidate using **original or verified rights-cleared** effects, event-to-file registry, and a clear list of still-pending creator approvals; exact commit SHA and draft PR.
- Update `docs/agent_continuity/sound_shogun/` when PM-02 protocol is merged.

## Immediate next action / source transfer
The source ZIP is a conversation attachment, **not** yet an available GitHub asset. The available GitHub connector only creates UTF-8 files; it cannot upload the ~130 MiB binary archive as-is. The creator may need to provide the same ZIP to the Sound Shogun's execution session or approved private file location. **Do not say the sounds are in GitHub until their files are actually verified.** Start source-independent mapping and project preparation while waiting for the archive. If private reference clips are accessible, audition and catalog them without publishing the originals.

## Rights policy
The creator's engineer friend reportedly characterized the pack as public domain, but documentation is absent. Use the sounds as creative direction and for permissible internal evaluation; rights clearance remains required before uploading or distributing recordings themselves. This does **not** prohibit proceeding with original sound generation and gameplay integration.

## Execution checkpoint — 2026-10-14

Recovered AUD01, verified attachment hash, decoded496 pack +16 supplementary WAVs. Created28 provisional signal-based comparisons and12 opt-in original alternatives. No perceptual audition was possible for the agent: confirmed suitable0; creator choices pending. Fresh source951 assertions and exported Windows130 passed. See `docs/agent_handoffs/AUD02_ALPHA061_PM_REPORT.md` and `docs/agent_continuity/sound_shogun/`. No supplied recordings published, no music selected, no shared merge.
