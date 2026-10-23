# Inspected dependencies and ownership

| PR | Pinned head | Finding / action |
| --- | --- | --- |
| #78 Cut-In Maker | af184380fb690f2c19bac69960b7aacce50f9ff2 | Sole code foundation; extend its preview subclass, AnimationPlayer stage, slider/transport and native resource conventions. |
| #96 CIN-04 | bf696dab16a8c10528e6e1d4ea1846dde43febe3 | Inspected story build/preview source and authored sequence documentation. Its preview subclasses #78. Leave `tools/cin04`, story presets, narrative copy and StoryDirector ownership untouched. |
| #85 ART09 | 378b86ca47130ede1663674d82f3cfe6bd00511f | Inspected Image4 manifest documentation and native viewer implementation. Three sprint keys plus guard poses are incomplete; do not relabel them as new production gait. No ART09 files copied. |
| #95 ART-10 | 466e87f9f42ca272698687ff7a9f911e9e27ee4c | Inspected checkpoint/schema and empty candidate slots. Preserve ART-10 review/tooling ownership and missing-drawings status. |
| #30 ART-04 | a6b76b9938825307bdcd4efb687c7198ea0d8681 | Inspected production key/flat ORA documentation and identity constraints; preserve original bytes and proportions as reference. |
| #62 ART-08 | 98d639f32c34d862bbe6ecf1fb4a8c70e1736414 | Inspected original offline rig code/landmarks. Reuse only the explicit profile-part allowlist with exact-byte provenance in a new namespace. Native FK is a simpler prototype, not equivalent to offline deformation. |
| #64 TR-08 | ed1875307e21f057add025ebebdec1e3f371e90f | Already inherited by #78. Inspected its handoff/restoration contract and doorway/stair regression source. No changes to its runtime, manifests, clips, labels or fixtures. |

No branch from this table was merged into the draft. Source inspection fetched the requested repository refs; all art reuse stays within the same repository. Only the explicit #62 part files were copied.

## Coordination — 2026-10-23

The existing **Build cinematic Cut-In Maker** chat confirmed #78 is complete/idle, its worktree clean, with no active edits or reservations. It approved no new behavior; it supplied constraints: native timelines, separate reduced preview, harmless scrubbing and exactly-once TR-08 ownership must remain intact.

The existing **Audit Kaze worktrees and sync** chat checked the local inventory and reported no active local conflict in the reserved paths; only this worktree has source edits there. Cut-In Maker and Alpha 0.7 coordination chats were idle at that check. Other overlaps were untracked generated UID metadata, not source edits.

The Alpha 0.7 coordination chat was notified but returned an unrelated asset-intake recap, so no cinematic specialist acknowledgment is inferred. Direct notification attempts to the remote story and animation chats failed with `AbsolutePathBuf deserialized without a base path`. Remote specialist activity is therefore **unverified**, not confirmed clear. The new paths and one explicit preview seam keep file overlap bounded; the draft remains unmerged.

Reserved paths: `tools/cin_tools_03/`, `assets/cin_tools_03/`, `presets/cutins/studio/`, `tests/cin_tools_03/`, `docs/cin_tools_03/`. Sole shared edit: `tools/cin_tools_01/preview.gd`'s additive preset resolver. No new agents were spawned.

## Runtime boundary

Studio loads no World/Player scene and has no world reference. Parent property tracks drive presentation-local clip time, canvas framing and existing presentation nodes. Saved clip/shot validation rejects executable track types and unknown property paths. The draft neither invokes nor changes the room loader, player controller, Canal Doorway, save schema, approved sprites, story copy or campaign placement. The original isolated Cut-In Maker/TR-08 fixture remains available unchanged and is tested as a regression.

## Minimum usable continuation — 2026-10-23

Continues PR #100 / original Studio head `d227b038576fc5268acc4f94324fc5fbf64244a5` on its existing branch. Tonight's delta touches only the five reserved Studio namespaces; `tools/cin_tools_01/preview.gd` and its resolver are byte-identical to that checkpoint. The subclass reparents the inherited widgets into resizable containers and retains their callbacks/transport. No new shared preview contract, CIN-04 or ART-10 change requires coordination. No messages to other owners or new agents were dispatched this turn.

QA-10 PR #101 was inspected at `2b7276701f2aa7cdd85137237d06f57490bdacdc`. Its focus/pause/capture harness diagnosis compares the previous Studio head to #78. Treat it as a separate diagnosed test-only correction awaiting PM acceptance. It is not merged, cherry-picked, automatically certified or treated as validation of this updated head. Its branch and files remain untouched. The current Studio authoring checks run on the existing harness; broader gameplay certification is outside this milestone.
