# TR-04 / LD-02 — Project Management return

2026-10-16 · Level Masta Masta · **Ready for creator playtest; further art refinement pending.**
Draft only. No merge or milestone-complete claim.

## Repository and recovery

- [Dedicated branch](https://github.com/cappy2yappy/momentum-fractured/tree/feature/alpha-0.6.1-tr04-geometry)
- [Draft PR33](https://github.com/cappy2yappy/momentum-fractured/pull/33), stacked on PR31 branch `integration/int-tr03-art04-production`.
- Exact integration base: `c2c6b08bfb3b85ad174dcc7ef60bddf1a3a48c15`.
- ART04 source: PR30 `a6b76b9938825307bdcd4efb687c7198ea0d8681`; already selectively integrated by PR31. Asset bytes preserved.
- Published runtime repair commit: `e7c308abd93de6f2191fbf000961d6fa1bb80721`. Local implementation commit `548bdd13ba3c9111b90cc3302f778a1ac827b9d2`; both trees `6c9a100f5ef1f8ce6f003142c9bce02248b19f47`.
- No previous remote TR04 branch was found. Recovered PR31 directly; did not restart DEV06/TR03 or merge historical branches.
- CLI push failed because Git's shell/credential prompt could not start (`NtCreateDirectoryObject ...0xC0000022`, then could not read Username). Connected GitHub Git-data publication succeeded with a checked parent and non-force update. Different commit identities are recorded honestly; tree equivalence is verified by fetch/diff. Evidence/documentation follow in a separate commit; PR head is the current full handoff identity.

## Implemented

Audited all 21 rooms. Repaired 19 near-boundary landings across 11 rooms (R2/R4/R9/R13-20), including both likely Canal Ward left-exit interpretations. Extend existing collision rectangles rather than add strips; preserve their top, thickness, collision layer and one-way behavior. R14 no longer generates a redundant overlapping doorway pad once the widened shelf supports its endpoint. Interior shelves, deliberate R2/R4/R5 water gaps and vertical routes remain intact.

Corrected only the R10→R9 implicit loader arrival from2300,828 to2300,808, removing solid-shelf overlap. Explicit arrivals and saved checkpoints remain untouched. Input radius, E behavior, automatic passage rules and loader timing are unchanged.

Platform/floor faces now sample existing biome material panels with clear top/side caps inside actual collider bounds. R17 gets a recessed wall return behind the cropped ART04 stair. Approved character sheets, ART04 key assets/contact/crop/front lip and their comparison switches remain preserved. Four held keys are still not completed animation cycles; missing outward/arrival/walk/cycle art remains explicitly labelled.

Movement physics,400/600px/s feel, abilities, combat, grapple, optional momentum default, progression gates/rewards, named sigils, map graph29 links/58 directions, save schema and save identity remain protected. No optional speed tier became a route requirement.

## Deliverables and coordination

- [Room-by-room audit and prioritized defects](../tr04/ROOM_GEOMETRY_AUDIT.md), with before/after Canal captures and21-room overview.
- [QA results, exact commands and limits](../tr04/QA_RESULTS.md), machine-readable/raw evidence alongside it.
- [Independent Godot-focused specialist review](../tr04/SPECIALIST_REVIEW.md): actual layer/one-way/edge/trigger inspection, then runtime checks.
- [Art Mane requests and ruins-escape evaluation](../tr04/ART_REQUESTS_AND_NARRATIVE.md). Coordination posted on [PR30](https://github.com/cappy2yappy/momentum-fractured/pull/30#issuecomment-6206967601); no Art Mane acknowledgment or new delivery is claimed.
- Ruins escape remains a proposal requiring Story Agent/creator confirmation. No story/progression changes were made.

## QA return

Final 30-action batch:22 behavioral suites, **1,240 passing assertions**, zero assertion/script/parser failures and zero nonzero exits. Includes78 new geometry assertions, unchanged controller/art protections, all-room connectivity/traversal, gates, save migration/restart, boss/story, movement/momentum, mixed transitions and ART04 behavior.

Native Windows actual key-event fixture:11 passes. Same fixture against exported Windows resources on native official engine:11 passes. Actual Windows EXE starts/renders and quits after 120 frames, exit0. GPU: NVIDIA RTX 4070 Laptop, OpenGL3.3  / 591.44. No sustained FPS number is claimed.

Initial validation failures and their fixes remain documented, including CRLF checkout bytes, explicit R2/R4 geometry exceptions and verifier UTF8 decoding. Inherited editor/export RID/ObjectDB cleanup diagnostics remain disclosed. No personal save was loaded or migrated in place; fixture save compatibility/restart passes.

## Windows candidate

`build/tr04/Kaze-TR04-Geometry-Windows.zip` —52,080,656 bytes, ZIP CRC passed.

SHA256: `186bc376cd188a2cef343d426d6833b96384b0f8a0d5898c88dbbb29ae778bbb`

Executable SHA256: `3382080ef316b4d434593d9ab5341477c76c92949c3b6e268b803f5001cb4975`

Runtime source `e7c308abd93de6f2191fbf000961d6fa1bb80721`; official Godot 4.6.1 Windows x86_64.569 packed resources, forbidden test/doc/build/source-art resources absent. The ZIP is also delivered with the session return. No older build was overwritten; no macOS candidate produced (Windows templates only).

Extract all files. Start `Play-Canal-Left.cmd` for the isolated seeded repair fixture; walk/run left, stop/wait, reapproach right and press E. `Play-Fresh.cmd` uses an isolated ordinary-campaign profile. Stair/door launchers enable ART04 preview; depth remains opt-in. Fixtures seed progression deliberately and are not earned playthroughs. Direct EXE launch retains the historical normal save identity. Launcher files are supplied; their individual shell paths were not separately exercised. Native engine/PCK input and EXE boot evidence is distinct.

## Acceptance limits and next action

Creator should repeat the reported item-stop/reapproach case in their actual room/save and provide the room label if it differs from the repaired Canal Ward fixtures. Human full-campaign and exhaustive ability/bypass sweeps, physical gamepad, other hardware and sustained60 FPS certification remain unverified. Authored biome supports/backgrounds and missing animation cycles remain outstanding. The global CANAL ROUTE HUD title is ambiguous; room-specific labels are recorded in evidence.

Next: creator Windows playtest, Art Mane terrain/pose delivery, Story Agent narrative decision; then targeted visual/collision review of incoming assets. Resume from the fetched PR33 head, read this report and current continuity notes, run `tools/run_tr04_qa.py`, and preserve the 19-landing allowlist and exact arrival exception. Do not merge, redesign movement, close intended drops or fabricate missing frames.
