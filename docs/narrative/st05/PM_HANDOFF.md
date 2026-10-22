# Creator decisions and PM handoff

ST-05 • Alpha 0.7 • 2026-10-22 • **Draft, documentation only; do not merge.**

## Delivered
Eight Markdown documents: source/canon audit, twelve beat specifications, complete 21-room matrix, object writing, three mutually exclusive casualty/injury treatments, asset requests, INT-01/CIN-TOOLS contracts and this handoff. No runtime script, room, asset, save, objective, gate, named fate or cinematic was changed.

Working branch: `narrative/st05-discoveries`. Review base: `candidate/wave3-targeted-3` at `c2170032d08ea55268313e0020676c743251deab`. This base has the current graph and approved-copy implementation; selection for document review is not approval of the candidate's gameplay or a merge into main. Diff must remain limited to `docs/narrative/st05/*.md` when retargeted.

## Creator approval checklist
Record **approve / revise / decline** per row with exact variant and scope in the PR. Unchecked items remain pending. Existing approvals C1/C2 do not authorize any D item.

| Decision | Concrete choice | Current status |
|---|---|---|
| C1 | Immediate post-attack survival/search; Mizuki naming; preserve delayed reveals | Confirmed by PR38; preserved |
| C2 | Exact opening/first objective/Foundry Rest Station label | Approved by PR68 comments; present in inspected candidate |
| D1 | Twelve-beat framework, optional delivery and no lore gates | Pending |
| D2 | R1 wrap, shared mending recognition and exact B02 copy | Pending; no owner identified |
| D3 | R2 undated physical letter treatment and optional “which dawn” reaction | Pending; original reward/text retained |
| D4 | R4 parapet as damaged defensive structure, without cause/date | Pending |
| D5 | R7 access-for-search panel/reaction | Earlier proposal; still pending |
| D6a | F1 anonymous clan-associated death, F2 affiliation withheld death, F3 possible injury evidence, or omit | Pending; choose only one; no named victims |
| D6b | If F1/F2: death existence, affiliation and unidentifiable victim policy separately | Pending |
| D6c | R8 placement, covered visual, recognition motif, exact reaction | Pending; Level bounds also required |
| D6d | Optional cloth memorial and any reduced-intensity variant | Pending; no ritual/reward implied |
| D7 | R14 carrying frame/bundle as uncertain interrupted travel | Pending; not recent clan evacuation proof |
| D8 | R16 optional hope reaction and lamp treatment | Pending; existing note preserved |
| D9 | R18 guard observation variants, no allegiance/patrol changes | Pending |
| D10 | R11 optional rest reaction and bay framing | Pending; approved label unchanged |
| D11 | R12 unresolved-search reaction after real attunement | Pending |
| D12 | R20 state-aware return reaction and landmark | Pending |
| D13 | New examine UI and additive persistence contract | Pending Gameplay/INT-01 + creator scope approval |
| D14 | Any optional cinematic adaptation | Not needed for default plan; pending separate approval |

## PM routing and stop conditions
- **Story:** incorporate creator choices, lock exact approved strings/variant IDs, issue a delta. Do not treat approval of tone as approval of a new death.
- **Level:** publish safe prop/standing/trigger rectangles on accepted gameplay captures, especially R8 and R14; verify all 29 links and reciprocal arrivals unchanged.
- **Art/Audio:** concept only until corresponding D approval; A05 casualty work blocked by D6. Supply ordinary gameplay-scale proof and provenance. No inferred dates, affiliations or recognizable bodies.
- **Gameplay:** estimate interaction/announcement arbitration and additive save support; do not implement new flags from this document automatically.
- **INT-01:** reconcile accepted candidate, copy approval and new content approvals; schedule a separate bounded implementation PR and validation record. Do not import historical branch runtime as a shortcut.
- **CIN-TOOLS:** optional later presentation discussion; no production adapter or forced cutscene requested here.

This file is the PM handoff artifact. No separate PM chat, issue assignment or message delivery is claimed. The requested draft PR is the review channel; no merge is authorized.

## Validation record and limits
Static document checks **PASS**: exactly 21 unique room IDs/names matching runtime; symmetric 29-link / 58-endpoint adjacency matching ordinary chain, sealed returns and expansion EDGES; twelve B01–B12 specifications with required fields; referenced local Markdown files resolve; doc-only diff and whitespace check. Results are recorded with the published PR.

Source inspected: world.gd, world_expansion.gd, route_extension.gd, skyworks_region.gd; PR38/50/68/72/54 documents and relevant creator comments; CIN-TOOLS interface and PM handoff. Existing notes remain E evidence, never expanded into approved chronology. Old ST03 ambiguity about Mizuki and post-attack placement is resolved by explicit creator decisions, while R0 geography remains unresolved.

Not run: Godot, new screenshots, live placement, human playtest, UI fitting, cinematic execution, save migration, audio playback, Windows/macOS exported-build QA. No assets or runtime are added, so runtime regression results from other PRs are not claimed as ST05 testing.

## Ready for next stage when
Creator chooses D items; Level confirms safe bounds; INT-01 identifies accepted source and adapter ownership; Art/Audio deliver approved assets; Gameplay authors a separate implementation with the acceptance tests in PRODUCTION.md. Until then this is a concrete proposal bible, not playable integrated story content.
