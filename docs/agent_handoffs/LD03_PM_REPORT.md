# LD03 — Intentional Playable Space: PM return

2026-10-16 UTC · Level Masta Masta · **Bellroof candidate ready for creator playtest. Wider-world refinement remains.**

## Repository

[Draft PR37](https://github.com/cappy2yappy/momentum-fractured/pull/37) · [Dedicated branch](https://github.com/cappy2yappy/momentum-fractured/tree/feature/alpha-0.6.1-ld03-intentional-space).

Base PR33 `1835fcca272fd6a925b3d8ad4834fb225a6caef6`; runtime `1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0`; hosted build source `3f03bb92f69b67bbf5f3505bd4b0112a82e729df`. Subsequent evidence commits change documentation only; fetch PR37's current head before continuing. No merge or destructive branch recreation.

Local implementation a77a40e489fe3733e0540f34753a57b3e9220aa2 has runtime tree9b432e0e56f4720079a9ce8b228d395b0ca48b38, matching published runtime. Existing CLI authentication limitation was handled through connected Git-data publication, with checked parent/non-force updates and tree comparison; different local/remote commit identities are not represented as the same SHA.

## Implemented

Bellroof's flat lower catch floor now supports a grounded service walk: six solid masonry masses, six one-way recovery ledges, a dedicated court for the existing optional bellkeeper log, and west/central/east returns to the retained upper route. Visible faces and actual collision use the same rectangles. Large decorative building blocks crossing the play area are removed, with recessed service-wall/sign/cabinet context instead.

All original Bellroof platforms, anchors, three exits, floor and gate prerequisites remain. Other 20 rooms retain their PR33 construction/signatures. Movement/controller, combat, abilities, map29 links/58 directions, bosses, save schema8 and historical save identity remain protected. No optional bonus is required. Log text/`lore_14` identity are preserved; no new canon or progression item.

Old R14 checkpoint feet inside new masonry are staged upward at the same x with capsule head clearance, only at startup/respawn. Free Bellroof and other-room coordinates remain exact. Tests cover blocked/free positions and persisted ability/lore restoration.

## Deliverables

- [Bellroof design and eight before/after captures](../ld03/BELLROOF_DESIGN.md).
- [All 21-room purpose audit and prioritized follow-ups](../ld03/WORLD_SPACE_AUDIT.md).
- [QA report, exact commands and raw results](../ld03/QA_RESULTS.md).
- [Art collision/placement contract](../ld03/ART_COORDINATION.md). Art Mane coordination posted on [PR30](https://github.com/cappy2yappy/momentum-fractured/pull/30#issuecomment-6207668648); no acknowledgment/new asset delivery claimed.

## Validation

Final 31-action batch /24 behavioral suites / **1,292 passes**, zero failed assertions/script/parser errors/nonzero exits. Native Windows route fixtures63 passes; compiled exported-resource route fixtures63; existing native transition keys11. Actual EXE boots/renders/quits, exit0. Official Godot 4.6.1, NVIDIA RTX 4070 Laptop / OpenGL3.3 /591.44. No sustained FPS number or human campaign completion claimed.

The initial audit's five JSON float-equality failures were corrected with explicit0.001px serialization tolerance plus independent source guards; initial evidence and failed hosted attempt remain visible. Final rerun and hosted candidate succeed. Existing editor/export shutdown diagnostics are disclosed.

## Playable Windows candidate

[Download hosted Windows candidate](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650/artifacts/12024315505) · [Successful build/evidence](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650).

Hosted artifact:52,969,952 bytes; SHA256 `931fe310e8ae33b97f18f413555600562d60a039e389094d81cf8de7c126ae58`; expires2026-11-15. GitHub sign-in may be required. Extract all, open **windows**, launch **Play-Lower-West.cmd**. Other isolated fixtures: Lower-Court, East-Recovery, Roof-Route, Old-Save-Staging and Fresh. Non-fresh fixtures deliberately seed progression; they are not earned playthroughs. Each keeps a separate explicit save. Direct EXE uses the existing normal save identity.

Native-session ZIP: `build/ld03/Kaze-LD03-Intentional-Space-Windows.zip`,52,084,198 bytes; SHA256 `479140cd1ca66631ec5e489d305d9a9a2349b5899037520bd553c84f7e8a5726`; executable SHA256 `faef3ed6578c3758866ea8af819f96ba96c5bd3f0744cf539b77f5dfdda55dfd`.571 packed resources, excluded test/doc/build resources absent, CRC passed. The hosted rebuild is a separate binary with the same reviewed game scripts; it is not claimed byte-identical to the native-session ZIP. No prior build overwritten; macOS not produced.

## Remaining work and next action

Creator should evaluate whether the lower detour feels rewarding, the three returns are readable, and support obstacles suit Kaze's speed. Existing materials and procedural signs are temporary architectural treatment; original authored environment modules remain an Art Mane follow-up. Missing character animation cycles remain outside this level change.

Other rooms have been audited rather than silently redesigned. Named P2 long/weakly signposted recovery walks in9/10/13/15/18/19/20 require later focused passes. No exhaustive reachable-volume/human campaign/gamepad/sustained-performance certification is claimed. This is a concrete Bellroof pilot and world audit, not a claim every room is finished.

Resume from fetched PR37 head, run tools/run_ld03_qa.py, preserve the original upper route and blocked-save guard, then review creator feedback before broadening geometry. Coordinate transition placement with its separate owner; this branch keeps PR33 activation/direction policy and does not import unreviewed transition or ART05 work. Do not merge.
