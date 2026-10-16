"""Collect the completed LD03 evidence; never runs tests or rewrites game code."""
from pathlib import Path
import json, shutil, subprocess

r=Path(__file__).resolve().parents[1]
out=r/'docs/ld03/evidence';out.mkdir(parents=True,exist_ok=True)
for source,target in [('build/ld03/qa/results.json','QA_RESULTS.json'),('build/ld03/initial-results.json','QA_INITIAL_RESULTS.json'),('build/ld03/space_audit.json','SPACE_AUDIT.json'),('build/ld03/windows-manifest.json','WINDOWS_NATIVE_BUILD.json')]:
    shutil.copy2(r/source,out/target)
for source,target in [('build/ld03/native-route.log','WINDOWS_NATIVE_ROUTES.txt'),('build/ld03/packed-route.log','WINDOWS_PACKED_ROUTES.txt'),('build/ld03/native-transition.log','WINDOWS_TRANSITIONS.txt'),('build/ld03/qa/intentional_space.log','ROUTE_TEST.txt'),('build/ld03/qa/audit_intentional_space.log','SPACE_AUDIT_TEST.txt'),('build/ld03/qa/verify_ld03_preservation.log','PRESERVATION_TEST.txt'),('build/ld03/exe-smoke.log','WINDOWS_EXE_BOOT.txt')]:
    (out/target).write_bytes((r/source).read_bytes().replace(b'\r',b'').rstrip(b'\n')+b'\n')
rows=json.loads((out/'QA_RESULTS.json').read_text(encoding='utf-8'))
summary=dict(actions=len(rows),behavioral_suites=24,passing_assertions=sum(x['passes'] for x in rows),failed_assertions=sum(x['failures'] for x in rows),script_errors=sum(x['script_errors'] for x in rows),nonzero_exits=[x['name'] for x in rows if x['exit']],native_route_assertions=63,packed_route_assertions=63,native_transition_assertions=11,native_executable_exit=0)
assert summary['passing_assertions']==1292 and not summary['failed_assertions'] and not summary['script_errors'] and not summary['nonzero_exits']
(out/'QA_SUMMARY.json').write_bytes((json.dumps(summary,indent=2)+'\n').encode())
hosted=dict(workflow_source='3f03bb92f69b67bbf5f3505bd4b0112a82e729df',game_runtime_source='1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0',run_id=38847365650,run_url='https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650',artifact_id=12024315505,download_url='https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650/artifacts/12024315505',artifact_bytes=52969952,artifact_sha256='931fe310e8ae33b97f18f413555600562d60a039e389094d81cf8de7c126ae58',expires='2026-11-15',status='success')
(out/'WINDOWS_HOSTED_BUILD.json').write_bytes((json.dumps(hosted,indent=2)+'\n').encode())

qa='''# LD03 QA return — 2026-10-16 UTC

Baseline PR33: `1835fcca272fd6a925b3d8ad4834fb225a6caef6`. Runtime: `1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0` (local a77a40e489fe3733e0540f34753a57b3e9220aa2; identical tree9b432e0e56f4720079a9ce8b228d395b0ca48b38). Later packaging/checker commits do not change game scripts.

**Final batch: 31 actions, 24 behavioral suites, 1,292 passing assertions, zero failed assertions, zero script/parser errors and zero nonzero exits.** [Exact per-suite commands/results](evidence/QA_RESULTS.json), [summary](evidence/QA_SUMMARY.json).

Official Godot4.6.1.stable.official.14d19694e, native Windows, NVIDIA RTX4070 Laptop GPU, OpenGL3.3 compatibility / driver591.44. Disposable APPDATA/explicit test saves; normal creator save not loaded.

## Coverage

- 63 new intentional-space checks: six solid masses/six one-way steps match actual collision/layer policy; base400px/s jump segments with double-jump/dash/tether/Stride/momentum disabled; three roof returns; grounded foundations; existing log relocation; locked gates; six historical blocked-save positions with capsule-clear staging; unchanged free/other-room positions; real version8 save/reload/respawn preserves earned ability and lore.
- 21 room checks: all other20 ordered collision signatures match PR33 to0.001px JSON serialization tolerance; Bellroof retains every old rectangle and adds only12 authored shapes. [All-room data](evidence/SPACE_AUDIT.json).
- 46 preservation checks guard controller, momentum, mixed policy, art, map and save/gate construction. World differences are only builder/preload and two blocked-save staging calls; expansion changes only R14 optional lore coordinate/legacy decoration suppression; presentation changes only R14 backdrop.
- Existing combat/swing, boss/story, save migration/restart, movement/momentum, grapple, world traversal, gate/reward, character-art, mixed/embodied/ART04 and TR04 geometry suites pass.

Native rendered route fixtures:63 passes. Exported Windows resource pack on official native Windows engine:63 passes. Native actual-key transition fixture:11 passes. Actual exported EXE boot with120-frame quit: exit0. These are segment/input fixtures, not an uninterrupted human playthrough. Each leap fixture seeds its launch position; an overlapping higher roof landing is a valid recovery corridor, not a reason to disable mobility.

## Reproduce

From repository root, substitute your official engine path:

```powershell
python tools/run_ld03_qa.py --godot ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe
$env:APPDATA="$PWD/build/ld03/native-route-user"
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --fixed-fps 60 --script res://tests/intentional_space.gd -- --test
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --script res://tests/playtest_level_geometry.gd -- --test --tr03-art-preview
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --path . --script res://tests/capture_ld03.gd -- --test
& ../sprite-engine/Godot_v4.6.1-stable_win64_console.exe --headless --path . --export-release 'Windows Desktop' build/ld03/windows/Kaze-LD03-Intentional-Space-Windows.exe
python tools/package_ld03.py --source 1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0
```

Before captures used the same capture script with `--before` before edits. Four fixed1280x720 views, same ART04 mode; overview zoom0.46 and details zoom1. JPEG copies preserve framing; native PNGs remain in ignored build outputs.

The packed test combines the unchanged leap-helper prefix from tests/expansion_traversal.gd with intentional-space's run method, avoiding inheritance from excluded res://tests. It runs with `--main-pack build/ld03/windows/Kaze-LD03-Intentional-Space-Windows.exe --fixed-fps 60 --script <absolute packed_intentional_space.gd> -- --test`. Compiled world/controller come from the export. [Native routes](evidence/WINDOWS_NATIVE_ROUTES.txt), [packed routes](evidence/WINDOWS_PACKED_ROUTES.txt), [transition inputs](evidence/WINDOWS_TRANSITIONS.txt), [EXE boot](evidence/WINDOWS_EXE_BOOT.txt).

## Failure and build provenance

[Hosted run38847365650](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650) passed: approved art/controller, preservation, settled import, new routes, all-room audit, TR04 geometry, export, PCK/CRC and artifact uploads. Source3f03bb92f69b67bbf5f3505bd4b0112a82e729df. This hosted Windows rebuild is not byte-identical to the native-session build and does not acquire a new native rendering certificate merely because scripts match. Exact hosted download/hash are in [WINDOWS_HOSTED_BUILD.json](evidence/WINDOWS_HOSTED_BUILD.json).

Initial JSON equality rejected five unchanged rooms with generated float32 thirds. The checker now preserves count/order and compares components within0.001px; independent source guards prove construction code remains unchanged. Failed [initial results](evidence/QA_INITIAL_RESULTS.json) and hosted run38847262531 remain recorded. Corrected audit passed targeted rerun, then full final batch and hosted rebuild. No runtime change was made to conceal that checker failure.

Inherited import/editor/export RID/ObjectDB shutdown diagnostics remain in raw warnings. No behavioral/script/parser failures accompany the final run. Engine-generated import metadata/old endpoint-matrix output are excluded from the implementation diff. Transcripts normalize line endings only.

## Limits

No human full-campaign run, exhaustive reachable-volume proof, physical gamepad review, sustained60FPS measurement or macOS candidate. Native rendering worked on the listed GPU; fixed-fps fixtures do not measure rendering performance. ART04 missing cycles/fallbacks remain unchanged. New faces use existing materials/procedural context, not a finished original tileset.

Creator should start Lower-West, find the log, try all three returns, drop from roofs into each bay and compare Roof-Route. Old-Save-Staging demonstrates the same-x safe spawn. Other rooms were audited, not redesigned; named P2 recovery/readability issues remain in the world audit.
'''
qa=qa.replace('Godot4.6','Godot 4.6').replace('NVIDIA RTX4070','NVIDIA RTX 4070').replace('sustained60FPS','sustained 60 FPS')
(r/'docs/ld03/QA_RESULTS.md').write_bytes(qa.encode())

pm='''# LD03 — Intentional Playable Space: PM return

2026-10-16 UTC · Level Masta Masta · **Bellroof candidate ready for creator playtest. Wider-world refinement remains.**

## Repository

[Draft PR37](https://github.com/cappy2yappy/momentum-fractured/pull/37) · [Dedicated branch](https://github.com/cappy2yappy/momentum-fractured/tree/feature/alpha-0.6.1-ld03-intentional-space).

Base PR33 `1835fcca272fd6a925b3d8ad4834fb225a6caef6`; runtime `1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0`; hosted build source `3f03bb92f69b67bbf5f3505bd4b0112a82e729df`. Subsequent evidence commits change documentation only; fetch PR37's current head before continuing. No merge or destructive branch recreation.

Local implementation a77a40e489fe3733e0540f34753a57b3e9220aa2 has runtime tree9b432e0e56f4720079a9ce8b228d395b0ca48b38, matching published runtime. Existing CLI authentication limitation was handled through connected Git-data publication, with checked parent/non-force updates and tree comparison; different local/remote commit identities are not represented as the same SHA.

## Implemented

Bellroof's flat lower catch floor now supports a grounded service walk: six solid masonry masses, six one-way recovery ledges, a dedicated court for the existing optional bellkeeper log, and west/central/east returns to the retained upper route. Visible faces and actual collision use the same rectangles. Large decorative building blocks crossing the play area are removed, with recessed service-wall/sign/cabinet context instead.

All original Bellroof platforms, anchors, three exits, floor and gate prerequisites remain. Other20 rooms retain their PR33 construction/signatures. Movement/controller, combat, abilities, map29 links/58 directions, bosses, save schema8 and historical save identity remain protected. No optional bonus is required. Log text/`lore_14` identity are preserved; no new canon or progression item.

Old R14 checkpoint feet inside new masonry are staged upward at the same x with capsule head clearance, only at startup/respawn. Free Bellroof and other-room coordinates remain exact. Tests cover blocked/free positions and persisted ability/lore restoration.

## Deliverables

- [Bellroof design and eight before/after captures](../ld03/BELLROOF_DESIGN.md).
- [All21-room purpose audit and prioritized follow-ups](../ld03/WORLD_SPACE_AUDIT.md).
- [QA report, exact commands and raw results](../ld03/QA_RESULTS.md).
- [Art collision/placement contract](../ld03/ART_COORDINATION.md). Art Mane coordination posted on [PR30](https://github.com/cappy2yappy/momentum-fractured/pull/30#issuecomment-6207668648); no acknowledgment/new asset delivery claimed.

## Validation

Final31-action batch /24 behavioral suites / **1,292 passes**, zero failed assertions/script/parser errors/nonzero exits. Native Windows route fixtures63 passes; compiled exported-resource route fixtures63; existing native transition keys11. Actual EXE boots/renders/quits, exit0. Official Godot4.6.1, NVIDIA RTX4070 Laptop / OpenGL3.3 /591.44. No sustained FPS number or human campaign completion claimed.

The initial audit's five JSON float-equality failures were corrected with explicit0.001px serialization tolerance plus independent source guards; initial evidence and failed hosted attempt remain visible. Final rerun and hosted candidate succeed. Existing editor/export shutdown diagnostics are disclosed.

## Playable Windows candidate

[Download hosted Windows candidate](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650/artifacts/12024315505) · [Successful build/evidence](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38847365650).

Hosted artifact:52,969,952 bytes; SHA256 `931fe310e8ae33b97f18f413555600562d60a039e389094d81cf8de7c126ae58`; expires2026-11-15. GitHub sign-in may be required. Extract all, open **windows**, launch **Play-Lower-West.cmd**. Other isolated fixtures: Lower-Court, East-Recovery, Roof-Route, Old-Save-Staging and Fresh. Non-fresh fixtures deliberately seed progression; they are not earned playthroughs. Each keeps a separate explicit save. Direct EXE uses the existing normal save identity.

Native-session ZIP: `build/ld03/Kaze-LD03-Intentional-Space-Windows.zip`,52,084,198 bytes; SHA256 `479140cd1ca66631ec5e489d305d9a9a2349b5899037520bd553c84f7e8a5726`; executable SHA256 `faef3ed6578c3758866ea8af819f96ba96c5bd3f0744cf539b77f5dfdda55dfd`.571 packed resources, excluded test/doc/build resources absent, CRC passed. The hosted rebuild is a separate binary with the same reviewed game scripts; it is not claimed byte-identical to the native-session ZIP. No prior build overwritten; macOS not produced.

## Remaining work and next action

Creator should evaluate whether the lower detour feels rewarding, the three returns are readable, and support obstacles suit Kaze's speed. Existing materials and procedural signs are temporary architectural treatment; original authored environment modules remain an Art Mane follow-up. Missing character animation cycles remain outside this level change.

Other rooms have been audited rather than silently redesigned. Named P2 long/weakly signposted recovery walks in9/10/13/15/18/19/20 require later focused passes. No exhaustive reachable-volume/human campaign/gamepad/sustained-performance certification is claimed. This is a concrete Bellroof pilot and world audit, not a claim every room is finished.

Resume from fetched PR37 head, run tools/run_ld03_qa.py, preserve the original upper route and blocked-save guard, then review creator feedback before broadening geometry. Coordinate transition placement with its separate owner; this branch keeps PR33 activation/direction policy and does not import unreviewed transition or ART05 work. Do not merge.
'''
pm=pm.replace('Other20','Other 20').replace('All21','All 21').replace('Final31','Final 31').replace('Godot4.6','Godot 4.6').replace('NVIDIA RTX4070','NVIDIA RTX 4070')
(r/'docs/agent_handoffs/LD03_PM_REPORT.md').write_bytes(pm.encode())
(r/'docs/ld03/README.md').write_bytes(b'# LD03 - Bellroof playable service walk\n\n[PM return](../agent_handoffs/LD03_PM_REPORT.md) | [Design / before-after captures](BELLROOF_DESIGN.md) | [World purpose audit](WORLD_SPACE_AUDIT.md) | [QA](QA_RESULTS.md) | [Art coordination](ART_COORDINATION.md)\n\nDraft PR37. Ready for creator playtest; no merge or full-world completion claim.\n')

def prepend(path,content):
    p=r/path;old=p.read_bytes();prefix=content.encode()
    if not old.startswith(prefix.split(b'\n')[0]):
        old=subprocess.check_output(['git','-c','safe.directory=*','show','HEAD:'+path],cwd=r)
        p.write_bytes(prefix+old)
prepend('PROJECT_STATUS.md','''# Current LD03 status — 2026-10-16 UTC

Draft PR37: playable Bellroof lower service walk, log court and three returns; six solid masses/six steps share rendered/collision rectangles. PR33 base; game runtime1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0. Other20 rooms audited, not redesigned. Blocked historical R14 saves stage safely; schema/flags/controller/topology preserved.

Final31 actions /24 suites /1292 passes; native routes63, packed routes63, transition keys11, EXE exit0. Hosted Windows run38847365650 succeeds. See docs/agent_handoffs/LD03_PM_REPORT.md for download, audit, hashes and remaining work. No human campaign/gamepad/sustained FPS certification. Creator playtest and authored environment work remain open. Do not merge.

---
Historical status follows unchanged:

''')
prepend('docs/agent_continuity/level_masta_masta/CONTEXT.md','''# Current context — LD03 — 2026-10-16 UTC

Draft PR37, feature/alpha-0.6.1-ld03-intentional-space. PR33 base1835fcca; runtime1dc714e2249cf39ada9fdcc5cd2225bdda5c5cc0; hosted source3f03bb92f69b67bbf5f3505bd4b0112a82e729df. Fetch actual PR head before continuing.

Delivered Bellroof service walk/log court, six solid masses/six one-way steps, three returns and blocked-save staging. Original upper route and other20 room layouts preserved. Full31-action batch1292 passes, native63/packed63/transition11; Windows candidate hosted in run38847365650. No merge. Read docs/agent_handoffs/LD03_PM_REPORT.md and docs/ld03.

Initial checker JSON-precision failure fixed; do not remove source guards or assert full-world completion. Other-room P2 recovery/readability work, creator playtest, original art and human/performance review remain. Separate transition/ART05 agents own their changes; do not silently integrate their candidate work. Continue from GitHub head, not old local commit identities.

---
Previous continuity follows unchanged:

''')
p=r/'docs/agent_continuity/level_masta_masta/SESSION_LOG.md'
entry=b'\n\n## 2026-10-16 - LD03\n\nBellroof lower service walk and optional log court implemented from PR33;63 new route/save checks,21 all-room signatures, full1292-pass batch, native/packed Windows checks. Draft PR37; hosted run38847365650. PM return docs/agent_handoffs/LD03_PM_REPORT.md. No merge; creator and remaining world/art review pending.\n'
if entry not in p.read_bytes():p.write_bytes(p.read_bytes()+entry)
print(json.dumps(summary))
