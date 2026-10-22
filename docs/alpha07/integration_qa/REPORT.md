# Alpha 0.7 independent integration QA — PROVISIONAL / HOLD

Date: 2026-10-22, America/New_York. Owner: Agent E. Branch: `codex/alpha07-integration-qa`. This local QA composition has not been published, merged, or approved as a shipping candidate.

**Hold:** The creator clarified that the original INT-01 specialist will publish `feature/int01-story-director`. Recover that authoritative remote commit before further dependent integration or acceptance. The local continuation tested here is not a substitute for that publication. All results below are provisional local-continuation evidence.

## Exact inputs and ownership

| Input | Exact source commit | Local composition commit |
| --- | --- | --- |
| PR78 foundation | `af184380fb690f2c19bac69960b7aacce50f9ff2` | foundation |
| B cinematic presenter | `835d01952bb523e552a762eac8d67c97ea868eef` | `be3a300` |
| Original EN01 | `5265e6c6182d883432215f4e9beab50255e48b5e` | `5041051` |
| Original HAZ01 | `e7a94185a6e76b12516bfeb9f175d4b03b1ace1a` | `d53ec96` |
| D contract correction | `125c6db1598aacebf2f9f96055631e35cdd801ce` | `69474b6` |
| C local continuation | `856a46d5628b1f91fdf3c960152d4b6966cded27` | `78a219647c82bed4e74381a10f6edd6e453fe1b7` |

Tested composition tree: `d8f2640a53393c1315b3f9741f54a755c01651c1`. B published PR86 uses a different commit with the same B source tree. A's inventory-only commit `615994d2b5db978af879429da1ac95df97966dd1` was reviewed and does not need runtime integration.

C alone resolved the two QA cherry-pick conflicts: retain exact PR78 `world.gd` with INT01 hooks, and add only the two JSON include-filter extensions in `export_presets.cfg`. No Candidate3 RoomBoundary or geometry changes were imported. The sixth world hook routes only `story_managed_encounter` defeat persistence through the single StoryDirector; legacy defeat handling stays unchanged. The coordinator accepted this narrow technical contract delta. It grants no story approval.

QA adds only assertion harnesses, a test-only subclass that counts calls to the unchanged real `save_progress`, and this report. No implementation work was done by Agent E. Implementation commits are composed only in this isolated local QA checkout. Candidate3 and all published branches remain unchanged.

## Supported integration and validation

Godot: **4.6.1.stable.official.14d19694e**. Native backend: **OpenGL 4.1 Metal / Apple M4**. All tests use `--test` and disposable save files. The combined test does call the real version-8 serializer and loader; it does not mock disk writes.

- Combined director/presenter/encounter/hazard test: **41 checks, 0 failures headless; 41 checks, 0 failures native rendered**. Native captures were visually inspected. The harness advances cinematic timelines deterministically; these stills are not a native-speed performance claim.
- Three IDs are shared correctly: `opening_review`, `record_review`, `fallen_clan_review`. Each real director rule commits and saves state before requesting its real presenter, even when request appears first in the rule. Transition deferral waits for player physics/control ownership. Synthetic gamepad B skip, repeated events, disabled/missing presentation, reduced motion, and production same-room rebuild preserve committed state and restore input.
- A real enemy is defeated during a transition, and the test explicitly proves its Node has been freed before control resumes. The existing encounter dictionary is then written exactly once, completion is reported once, and its story flag is written exactly once. Repeated flushes do not write again. Real disk reload restores both dictionaries.
- Explicit `spawn_encounter` / `arm_hazard` callback registration now connects the sole director to D's consumers. Duplicate consumer IDs and unregistered consumer IDs are rejected. A real registered hazard reads the director-owned flag. Composition roots must register consumers before loading rules and update their hazard adapter each tick. No automatic production placements were added.
- Independent preservation: **23 checks, 0 failures** against PR78, including 47 approved/candidate artwork files, exact player/guard/geometry/transition files, all ten guarded world function bodies, the entire world file normalized by only the reviewed six hooks plus director declaration, unchanged project identity, and exactly two export include-filter extensions. The original PR37 preservation script still fails on the inherited `world_expansion.build_room` difference. After composition it also sees the explicit export-filter delta; those failures are retained, not waived.
- Baseline asset verifier: **0 failures**. Actual review PCK export completed and export log lists `res://data/story/objects.json` and `res://data/story/rules.json`. There is no production encounter/hazard JSON yet. This is pack-content evidence, not a signed Mac app or packaged gameplay validation.

## Existing-suite results on the provisional composition

| Suite | Result |
| --- | --- |
| Approved baseline | 32 pass / 0 fail |
| Approved combat swing | 7 pass / 0 fail |
| Sprite integration | 43 pass / 0 fail |
| Save compatibility | 11 pass / 0 fail |
| Cinematic presenter | 25 pass / 0 fail |
| INT01 contracts | 29 pass / 0 fail |
| HAZ toolkit | 56 pass / 0 fail |
| HAZ contract | 17 pass / 0 fail |
| EN framework | **50 pass / 2 fail** |
| EN persistence | **4 pass / 1 fail** |
| Movement/momentum | **incomplete**: sandbox-denied `user://` save, failed assertions, subsequent nil parse; timeout |
| TR08 canal hang regression | **incomplete**: default fixture path cannot be written in sandbox; subsequent nil errors; timeout |

Save compatibility and INT01 contract tests run exact copies with only literal disposable-path substitutions; the runner records original hashes and substitutions. Assertions and tolerances are unchanged. Other suites above were not rewritten.

The two EN framework failures arise because its isolated arena deliberately disables world physics and therefore never ticks the newly present StoryDirector after deferred defeat. The EN persistence failure expects the standalone encounter's failure signal, whereas the shared director now owns persistence and retry. These are actual failed combined-suite runs, not green results. D prepared test-only correction `6aa9e84ce6d80611b7210c47a4d8cbf2bd056433` that drives the otherwise-frozen director and strengthens shared save retry assertions. **It has not been cherry-picked or rerun here because of the creator's hold.** Recover authoritative INT01 first, review the test-only correction, then rerun these failures. For movement/TR08, use explicit disposable paths while preserving every assertion; do not infer gameplay failure from the environment errors.

Import/export emitted sandbox editor-settings and certificate-access diagnostics. The combined native and headless runtime test completed without script errors or leaked resources after QA teardown correction. Export editor teardown also emitted resource-leak diagnostics; do not describe editor export as warning-free.

## Remaining integration gates

1. Recover original specialist's published INT01 exact remote SHA, compare it with this provisional continuation, and recompose on the approved foundation under the designated shared-file owner.
2. Resolve and rerun the failed/incomplete existing suites above. Then rerun combined native/disk/transition evidence against the new exact tree.
3. Creator supplies actual selected Higgsfield Image 4; do not reconstruct it. Native-speed new ninja animation candidates remain blocked on that asset.
4. Physical controller verification remains pending. Synthetic controller events are verified; no hardware controller session was observed.
5. Creator approval remains required for room markup, story object placement, and provisional fallen-clan content. Production story data arrays stay empty; no deaths, identities, or revelations were invented.
6. Signed/package-specific Mac validation and a complete unseeded progression playthrough remain pending. Do not classify a clean cherry-pick or PCK export as runtime compatibility proof.

## Mac reproduction of this local provisional QA

From this workspace, run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path '/Users/tonysantiago/Documents/Codex/2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative/work/integration-qa' --log-file '/Users/tonysantiago/Documents/Codex/2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative/work/integration-qa-evidence/combined-native-recheck.log' --script res://tests/alpha07_qa/combined.gd -- --test
```

This opens an automated native rendered assertion session and closes when finished. It uses disposable saves under `build/alpha07_qa`, not the campaign profile. The real-time cinematic preview, interaction demonstration, staircase demo and enemy/hazard arenas are separate creator deliverables in the parent coordination report. This QA checkout is intentionally local and provisional; it is not a replacement for the original specialist's upcoming branch.
