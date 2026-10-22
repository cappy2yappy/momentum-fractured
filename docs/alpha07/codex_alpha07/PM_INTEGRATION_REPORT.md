# KAZE CODEX-ALPHA07 production handoff

2026-10-22. All work is draft and unmerged. The 21-room campaign, approved movement, live Kaze sprite bindings and Candidate 3 remain unchanged. This delivery is for isolated creator review; it does not authorize room placements or new canon.

## Source recovery and ownership

All requested source PRs were inspected before changes. Exact source heads are in recovery.json. main was identified as historical and not used as the feature foundation. PR77 Candidate 3 remains c2170032d08ea55268313e0020676c743251deab.

The original INT01 implementation was initially unpublished. Its local source was recovered read-only, and exploratory continuation work was isolated. When the creator clarified the publication gate, continuation publication and integration acceptance were held. The original agent then published draft PR88 at 2fa6cd6a03de599b7f9098e8bf61f8d770784091. That exact remote ref was independently verified, fetched, and inspected before authoritative integration resumed. PR89 is a separate audited follow-up directly atop that published commit; the original branch and original handoff remain intact. Earlier local QA evidence is labelled provisional and is not the acceptance source.

| Agent | Branch | Delivered | Blocker / next action |
| --- | --- | --- | --- |
| A, animation | codex/alpha07-animation | PR85, exact Image4 extraction, pose/component inventory, native sprint/stair/braking studies | Creator visual acceptance; artist cleanup and complete gait remain pending |
| B, narrative | codex/alpha07-story-cinematics | PR86, presentation-only adapter, three isolated playable previews | Creator approves provisional story treatment and placements separately |
| C, interactions | codex/alpha07-int01-remote-followup | PR89 atop original PR88, inspection/controller/save/consumer completion | Physical controller test and future approved room placement |
| D, compliance | codex/alpha07-compliance | PR87, encounter/hazard safety corrections and native before/after captures | Creator room-safety survey; prototype collapse excluded from production path |
| E, independent QA | codex/alpha07-integration-readiness | PR90 report/test-only draft; pinned local combined-runtime proof | Human playtest, Windows, physical controller and per-room acceptance |

The machine-readable component inventory records local test commits, corresponding published commits/trees, bases and every changed file. Different local/REST commit SHAs are disclosed when their complete trees are identical.

## Actual Image4 and animation limits

The exact attachment is preserved unchanged, SHA256 0c9dc1eeab228a683d86cd156d02251400e7ebd7c1b1a46b1e56e8ae2d44bb09. It is 1143×2048 RGBA8, but every one of its 2,340,864 pixels is opaque: the checkerboard is baked into RGB. The deterministic engine-native mask removes exterior-connected neutral background, retains 586,205 original-color pixels and all 13,345 green-dominant pixels. Approved PR30 artwork is the identity reference. No generative imitation was used.

The catalog contains 170 foreground components, including a portrait and unsuitable variants; this is not a claim of 170 validated animation poses. Source rectangles, classifications and candidate limitations are recorded. Three genuine arms-back pose keys support the pilot. Sprint, ascent, descent and braking are native-speed pose/timing/root-path studies. Foot planting, complete gait continuity and artist-perfect masking are not accepted. Exposed-torso/off-model variants are excluded from the pilot. Alternate runs, combat, acrobatics and flip candidates remain catalog material.

All candidate assets live separately. No approved gameplay sheet or production transition binding is replaced. Existing baseline staircase footage is labelled separately from the new Image4 study.

## Narrative, interactions and shared contracts

The three previews cover the approved opening, an existing R14 record, and a provisional fallen-clan timing study. The last depicts no new death, body, identity or revelation. All review content remains outside normal campaign launch.

One StoryDirector owns events and persistent narrative flags in the existing expansion_flags dictionary. Encounter defeats use cleared_encounters; existing opened-gate storage is retained. Save version remains 8; serializer/loader functions are unchanged. Optional cinematic presentation never writes progression or saves. State effects precede presentation; transitions and input ownership defer work until safe restoration.

INT01 retains the original shared object core and multipage panel. Follow-up fixes cover E priority, numeric JSON room IDs in overlap checks, keyboard/gamepad X/A/B/D-pad, opening-release suppression, missing text, same-room rebuild, death/focus interruption, bounded retry work, declared encounter/hazard consumers and empty production data. Synthetic button events are tested; this is not physical-controller acceptance.

Two review deltas are explicit: JSON data export includes required by contract section 6, and one narrow managed-encounter defeat hook owned only by C. Existing ordinary enemies keep the legacy handling path. The original preservation verifier remains unchanged. Its inherited PR78 world_expansion.build_room difference and the intentional export-filter difference are reported, while a strict independent proof verifies exact allowed filter changes and unchanged guarded functions. No failing threshold was lowered.

Encounters enforce HP 4–8, at least 0.5s attack windup, grounded/distant/control-safe story activation, existing damage and common spawn handling. Managed completion and persistence wait for control restoration, including when the defeated node has already been freed. Hazard warnings are at least 0.6s. Flag changes wait until volumes are unoccupied. Production placement probes reject recovery/door/checkpoint/interactable conflicts and collider-producing collapse. The pre-existing isolated collapse prototype remains a prototype; it is not approved for campaign placement.

## Validation and evidence

Godot 4.6.1 official was used, with actual Apple M4 native OpenGL rendering. Exact commands and raw logs are retained. Old test suites that hardcode user:// were copied to disposable test scripts with path literals changed only; assertions stayed intact. Normal-boot transition tests used explicit disposable fixture setup. Initial missing-import, sandbox-path and incorrect-runner failures are retained as superseded setup attempts, not silently counted as passes.

| Scope | Executed result | Meaning |
| --- | --- | --- |
| A Image4 pipeline / viewer | 347 integrity + 22 viewer checks, zero failures | Exact source/pixel integrity and isolated study controls |
| A existing regressions | TR08 226/0; sprites 43/0; approved baseline zero failures | Existing transition/asset behavior retained |
| B presentation | 25 headless + 25 native, zero failures; existing maker 103/0 | Lifecycle, interruption and state-free presentation |
| C follow-up | 512 headless + 36 native assertions, zero final failures | Includes automatic passage 305/0 and TR08 hang 53/0, disk saves and raw synthetic controller events |
| D source | 210 independent assertions, zero failures; new consumer boundary 31/0 | Encounter/hazard behavior, disk persistence and atomic ID rejection |
| E broad authoritative composition | 491 existing checks, zero failures | Ran immediately before the final consumer-only validation fix |
| E final targeted composition | 41 headless + 41 native, zero failures; 4 real-director ID/legacy/duplicate checks; consumer suite 31/0 | Reran on the exact final consumer fix; broad suites were not redundantly rerun |
| E preservation | 23 independent assertions, zero failures | Protected bodies, approved art and selected-base geometry verified |

Counts overlap across owners and include reruns of existing suites; they must not be summed into a unique-test total. The two malformed-ID QA failures were real and retained before the narrow fix. Final targeted results supersede those failures, with exact source trees disclosed.

A clean Git merge was never used as runtime proof. The combined fixture pins actual recovered components, exercises disk reload and exactly-once persistence, checks transition interruption and control restoration, and hashes approved assets/guarded bodies against the chosen base. Native captures were visually inspected. A targeted QA failure for malformed consumer event/flag IDs was recorded before correction and rerun after the exact fix.

## Creator review and Mac launch

Double-click outputs/Launch-Kaze-Demos.command on this machine with Godot 4.6.1 installed at /Applications/Godot.app. The menu launches six separate source fixtures with explicit workspace logs and --test. No standalone exported Mac app is claimed. Source projects and their imported caches must remain beside outputs. Each specialist README also documents direct engine commands.

The outputs folder contains native-speed MP4 previews, stills, frame timing, pose catalogs, QA logs, exact inventories and the per-agent launch instructions. The baseline staircase MP4 is 6.755s; the three-story-preview MP4 is 11.432s. Both encode actual post-draw timestamps with no fixed-FPS retiming. The Image4 pilot is a separate 18.970-second candidate MP4 (323 actual timestamped samples; capture wall clock about 19 seconds). Interactable screenshots compare interaction states; enemy/hazard captures include actual earlier/later code fixtures.

Before future room integration: review the Image4 pilot and cleanup limits, choose approved ST05 content, supply creator room markup/placements, then rerun placement and progression tests for each approved room. Physical controller hardware, Windows, performance/balance feel and complete human playthrough remain untested. No merge or canon approval is inferred.

## Published source pins

| PR | Branch | Exact head | State |
| --- | --- | --- | --- |
| [#77](https://github.com/cappy2yappy/momentum-fractured/pull/77) | candidate/wave3-targeted-3 | `c2170032d08ea55268313e0020676c743251deab` | draft, unmerged |
| [#85](https://github.com/cappy2yappy/momentum-fractured/pull/85) | codex/alpha07-animation | `378b86ca47130ede1663674d82f3cfe6bd00511f` | draft, unmerged |
| [#86](https://github.com/cappy2yappy/momentum-fractured/pull/86) | codex/alpha07-story-cinematics | `2d459743bce4a11a2d6bed1ae75d0c6d3adf3d5f` | draft, unmerged |
| [#87](https://github.com/cappy2yappy/momentum-fractured/pull/87) | codex/alpha07-compliance | `5172db6898f3efc35b74f3c134293049165b9bf7` | draft, unmerged |
| [#88](https://github.com/cappy2yappy/momentum-fractured/pull/88) | feature/int01-story-director | `2fa6cd6a03de599b7f9098e8bf61f8d770784091` | draft, unmerged |
| [#89](https://github.com/cappy2yappy/momentum-fractured/pull/89) | codex/alpha07-int01-remote-followup | `3dc433cd7b537391f218864abeb2398dc671ccb0` | draft, unmerged |

Final D runtime/consumer fix: `6f7c5129c8532effdc8b9e9eff6ff65454312c33`; later D head changes documentation only. Final targeted local QA source: `892b1ea29ab459d6e6ece1edba0cb88d3ec24972`, tree `bbd3c06f77c8672d1823f1a6b157923706eda457`. The preceding broad QA source was `fd41c9dfc4247a37657d9836ce4bf538d7884ea7`; the QA report supplies its full SHA and final artifact pin. Combined source remains local; the QA draft publishes only reports, tests, evidence and composition instructions.


QA report/test-only [draft PR90](https://github.com/cappy2yappy/momentum-fractured/pull/90), head `95fe0a3694dfa6fda01806c269f7ee9d7de0903c`, tree `e7b739b5f9c93f6230fd8eb103030e1170b5b1fe`, base PR78 `af184380fb690f2c19bac69960b7aacce50f9ff2`. The authoritative local bundle is `outputs/integration-qa-authoritative`; `outputs/integration-qa` is provisional history only.
