# ST-05 — Story beats, discoveries and environmental narrative

Narrative production bible • Alpha 0.7 • Godot 4.6.1 • 2026-10-22

**DRAFT FOR CREATOR REVIEW. Documentation only. Do not merge.**
The current district remains immediately after the refuge attack. Kaze survived, wakes alone, and searches for others. This package proposes playable discoveries; it does not authorize their implementation or turn them into canon.

## Production index
- [Canon preservation audit and evidence](CANON_AUDIT.md)
- [Twelve beat specifications and interaction contract](BEATS.md)
- [Complete 21-room placement matrix and graph](ROOM_MATRIX.md)
- [Player-facing writing samples](WRITING.md)
- [Fallen clan member alternatives](FALLEN_CLAN.md)
- [Art/audio requests and INT-01 / CIN-TOOLS dependencies](PRODUCTION.md)
- [Creator decisions, validation and PM handoff](PM_HANDOFF.md)

## Reading rule
**C** = creator-confirmed canon or exact approved copy. **E** = evidence implemented in the inspected source, not automatically approved lore. **P** = earlier proposal, still pending. **N** = new ST-05 proposal, still pending. These labels are independent of priority. “Critical path” means an existing route/milestone, never permission to require a lore interaction.

Only B01's exact opening and B10's existing checkpoint name have explicit text approval. All new reactions, props, casualty concepts, flags, UI, audio and cinematic use require their stated decisions. Player-facing text is isolated in WRITING.md; internal spoiler context in CANON_AUDIT.md must never be imported into dialogue or art briefs.

## Source scope
Runtime review: `candidate/wave3-targeted-3` at `c2170032d08ea55268313e0020676c743251deab`, fetched 2026-10-22. This is an integration candidate, not a claim of creator acceptance or a released Alpha 0.7 build. The draft branch is based on it so the PR diff contains only this package. Historical `main` is not the current 21-room source. Retarget only after checking the resulting diff.

Static inspection covered world, expansion, route-extension and SkyWorks source plus the five requested PRs. No new game run, visual fit test or exported-build verification was performed. Source coordinates anchor review; Level must approve final prop/interaction bounds against the accepted integration revision.
