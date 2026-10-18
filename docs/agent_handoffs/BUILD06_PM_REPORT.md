# BUILD-06 PM return — 2026-10-18

Delivered verified Windows x86_64 and Universal macOS **PR39 baseline controls** in
draft [PR52](https://github.com/cappy2yappy/momentum-fractured/pull/52).
TR07/LD04 combined engineering builds remain pending published integrations.
Tracking: [issue #46](https://github.com/cappy2yappy/momentum-fractured/issues/46).
No component merge, main update, tag or production release was performed.

## Source and controls

| Input | Exact commit |
| --- | --- |
| Gameplay PR39 | `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` |
| Gameplay tree | `89d6d6052e68fccaad0d0c696c12ba568d3bc124` |
| Pipeline reference PR40 | `32e75a884b62d08f9e024eab5b01429e87ed12f7` |
| Accepted hosted controls | `bbec1b0d4494a489711385f8c3dff5137d166773` |
| Local graphical Windows controls | `1200c0cd483bd797d435abe98a27ba3205c5bb35` |
| Main inspected and preserved | `c69efbb43aa49b71dc6c541820934487a170fa7b` |

Official engine `4.6.1.stable.official.14d19694e`; editors/templates are checksum
pinned. Infrastructure branch `ci/build06-parallel-playtest` is stacked on PR40,
with a separate exact-PR39 gameplay checkout. Final publication adds documentation,
verification helpers and README clarification; pipeline code remains the accepted
controls above. No untested publication head is substituted for that CI pin.

Accepted [Actions run 39098330966](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39098330966):
both jobs successful. [Run](../build06/evidence/HOSTED_RUN.json),
[jobs/steps](../build06/evidence/HOSTED_JOBS.json),
[artifact metadata](../build06/evidence/ARTIFACTS.json).

## Downloads and checksums

Extract the Actions ZIP, then its inner Kaze ZIP, into a writable folder. Use
Play-Fresh for an isolated persistent campaign or six resettable demos. Direct
EXE/app opening retains the historical ordinary save identity; prefer launchers.
Seeded unlocks are fixtures, not earned progression.

| Download | Expires UTC |
| --- | --- |
| [Windows x86_64 control](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39098330966/artifacts/12125915950) | 2026-11-17 04:51:18Z |
| [macOS Universal control](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39098330966/artifacts/12125533126) | 2026-11-17 04:53:07Z |
| [Windows QA](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39098330966/artifacts/12126075333) | 2026-11-17 04:51:21Z |
| [macOS QA](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39098330966/artifacts/12125846459) | 2026-11-17 04:53:13Z |

Thirty-day retention: these expire late **November 16 in New York**, 23:51/23:53 EST.
They are temporary artifacts, not release links. Rebuild pinned inputs if expired.

| SHA-256 | Windows | macOS |
| --- | --- | --- |
| Outer Actions ZIP | `f0cd1a453b4b8e75ec8a533d121d5d2266d210d54d5936444550d56c35c0dbbc` | `cb21b38d61d8c1f11bbd8d56a6411985f277b55390f2fb01a8fe5cfaa04e0642` |
| Inner playtest ZIP | `a96a4d457e79237ac72457b8bbf8fd5b2a60be5e6f6c0dad978e2bf20aba0163` | `5d2f78d12a57b93206340dfd6b567f74d1f4cc4e13d7390c667dbfdca02033dd` |

Independent download verification passed: both outer/inner hashes and CRCs; every
member (15 Windows / 20 Mac); all 514 resource payloads per platform; all 59 shipped
scripts against exact Git-source bytes. Both QA archives were downloaded and their
hashes, CRCs and QA statuses verified. [Verification](../build06/evidence/DOWNLOADED_VERIFICATION.json),
[reproduction helper](../build06/verify_delivery.py).

## Executed coverage

| Host | Executed result | Limits |
| --- | --- | --- |
| Hosted native Windows Server 2022 x86_64 | Cold/settled imports; baseline verifier; 59 preservation checks; 25 suites/1,607 source assertions; two exports; release boot; seven actual launchers; 252 exported-resource assertions | Headless automation, no hosted graphical/human campaign claim |
| Hosted native Intel macOS 15.7.9 | Same source/preservation/export/boot/launcher/252-resource checks; lipo verifies x86_64 + arm64 | Intel headless only; no new Apple Silicon execution or graphical/hands-on Mac pass |
| Local native Windows / NVIDIA RTX4070 Laptop / OpenGL 3.3 | Same 25 suites/1,607 assertions, preservation, two exports, release, seven launchers and 252-resource checks; graphical packaged-input fixture 54/54 with 36 captures | Automated graphical coverage, not human acceptance/FPS certification |
| Downloaded hosted Windows package, local Windows | Actual Play-Fresh headless boot for 120 frames from a spaced path, exit 0, after checksum verification | Downloaded binary smoke, not full campaign |

All accepted build actions passed; all 1,101 tracked source files remained unchanged across
accepted builds. Four historical transition suites explicitly use `--tr05-legacy`;
they are not fresh-input automatic-passage proof. Exported coverage includes 54
key/transition checks plus six room/movement/save/progression suites. Fixed 60-FPS
simulation is not measured sustained FPS. Local captures were inspected; hosted
Mac tests deliberately remain headless.

[Windows manifest](../build06/evidence/windows-MANIFEST.json),
[Windows QA](../build06/evidence/windows-QA_RESULTS.json),
[Mac manifest](../build06/evidence/macos-MANIFEST.json),
[Mac QA](../build06/evidence/macos-QA_RESULTS.json),
[local manifest](../build06/evidence/LOCAL_WINDOWS_MANIFEST.json),
[local logs](../build06/evidence/local-windows/).

## Reproducibility and failures

Initial default compressed-token Windows exports differed in two of 573 MetSys
resources: `MetSysPlugin.gdc` and `ScrollingRoomTransitions.gdc`. The gate stopped
playable-artifact publication. An isolated engine decompression experiment crashed
without results; no decoded-token equivalence is claimed. Initial hashes/differences
are retained in `evidence/INITIAL_WINDOWS_*`.

An export-only `script_export_mode=0` overlay now ships auditable text scripts;
`finally` restores original preset bytes. No gameplay script, physics, combat,
sprites, save logic or persistent export configuration changed. Local Windows
repeated text exports were wholly byte-identical. Hosted repeats on both platforms
still differed in raw pack/container bytes, but **all 514 named resource payloads
matched exactly**. The accepted gate checks each payload and all 59 source scripts.
It does not claim whole-archive, cross-machine or future-run bit identity. Both
raw hashes and canonical resource hashes/equality are recorded in manifests.

[Initial run 39097987451](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39097987451)
and [run 39098169448](https://github.com/cappy2yappy/momentum-fractured/actions/runs/39098169448)
have Windows failures at raw-pack equality, then were superseded/cancelled while
Mac work was pending. Neither is a Mac pass. Run 39098330966 is the accepted run.
Inherited RID/ObjectDB shutdown diagnostics remain in logs; the narrow inherited
filter does not ignore script/parser/missing-resource errors. Packages are
unsigned/unnotarized; no security/signing bypass is bundled.

**Known baseline gameplay defect independently reproduced:** PR51's pinned
test-only fresh-key fixture on unchanged PR39 gives **211 pass / 94 fail**, exit 1,
zero script errors. [Issue #42](https://github.com/cappy2yappy/momentum-fractured/issues/42)
remains in both control packages. [Record](../build06/evidence/ISSUE42_BASELINE.json)
and [log](../build06/evidence/ISSUE42_BASELINE.log). Green stock suites do not certify
doorway recovery or a defect-free campaign. No fix was silently combined.

## Build contents

| Component | Both control packages |
| --- | --- |
| PR39 gameplay, PR37 geometry, existing approved sheets | Included |
| Existing ART04 held stair keys / moving stair study | Included; unfinished gait remains prototype |
| New approved ART06 lateral art / TR07 integration | Not included |
| PR47 R18 authored art / LD04 integration | Not included |
| ART07R procedural idle / waiting / crouch candidates | Not included |
| PR51/TR06 doorway reliability fix | Not included |

New optional [ART07R PR53](https://github.com/cappy2yappy/momentum-fractured/pull/53)
arrived during verification at `18491105da5f8dd0b11b616c7da81803ced1fadc` with 21
`assets/art07` files. It is procedural single-drawing idle, not approved/default-bound;
waiting and crouch remain pending. The initial `65e1e08...` snapshot had no produced
art. Both packages retained the frozen PR39 source when PR53 arrived.

## Integration plan and approval gates

[Detailed strategy/rollback](../build06/INTEGRATION_PLAN.md),
[exact ancestry/dry-run output](../build06/evidence/ANCESTRY.json).
Main is 82 commits behind PR39 and one ahead, with 1,236 differing paths; it is not
a substitute build source. PR40 adds only build/docs relative to PR39. Eight
merge-tree probes found seven mechanically clean pairs and a `.gitignore` conflict
between ART06 lateral and R18 art. No checked-out merge or conflict resolution was
applied. Mechanical cleanliness is not functional compatibility or approval.

TR07 and LD04 runtime integration commits remain unpublished in the final snapshot.
ART06 lateral's generated image drop is absent from Git: creator approval in this
assignment does not supply missing bytes. PR47 needs final geometry fitting and
JSON export inclusion. PR49 is still a disconnected authoring pilot. ART07R stays
in its separate optional art review. These are readiness blockers for combined
comparisons, not reasons to modify approved gameplay from this build lane.

When reviewed engineering inputs arrive, pin transition-only, R18-only and combined
temporary sources alongside this baseline control; run candidate-specific art,
fresh-jump/doorway, route/gate/save and native package checks; verify downloaded
artifacts again. Never automatically default-bind ART07. Creator comparison, full
unseeded campaigns, physical gamepad, sustained FPS and new Apple Silicon/graphical
Mac coverage remain pending. Main requires separate explicit creator approval.
**Do not merge or publish a production release.**

## Turn State

State: BUILD06 baseline delivery complete; component integration pending published inputs.
Owner: Build Shogun/Codex. Next: PM/creator review, then engineering candidate handoff.
Checkout: `C:\Users\TonyS\.codex\.chatgpt-projects\g-p-6aa9b0443c20819186909618bb6be970\kaze-build06`.
Disposable source: sibling `build06-source-windows-v2`; downloads: `build06-downloads`.
Existing developer checkouts were preserved. No bridge/background game service
remains. Outputs/caches stay outside Git. Verify live PR/artifact state and exact
source/control pins before resuming.
