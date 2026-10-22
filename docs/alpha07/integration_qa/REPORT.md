# Alpha 0.7 independent integration readiness

2026-10-22 · Owner: Agent E · Status: **isolated review only; production acceptance pending**.

The original INT-01 publication gate is satisfied: the coordinator recovered original PR88 `feature/int01-story-director` at `2fa6cd6a03de599b7f9098e8bf61f8d770784091` before authoritative composition. The original branch was not overwritten. The separate follow-up is draft PR89 at `3dc433cd7b537391f218864abeb2398dc671ccb0`; its tree `0d07593f282dfd704d598b7bab1e12c7314e027f` matches locally tested C source. Earlier results and failures remain in the separate provisional artifact bundle; they are not the authoritative acceptance evidence.

This draft PR adds QA fixtures, logs and handoff documentation only. **Its tests require the separately composed local fixture.** It does not contain the specialist implementation source. The exact source pins, tested local tree and changed-file inventory are in `pins.json` and `changed-files.json`. No PR has been merged.

## Recovered components and ownership

| Component | Pinned source |
| --- | --- |
| PR78 Cut-In Maker foundation | `af184380fb690f2c19bac69960b7aacce50f9ff2` |
| B presenter / PR86 source-equivalent local tree | `835d01952bb523e552a762eac8d67c97ea868eef` |
| Original EN01 | `5265e6c6182d883432215f4e9beab50255e48b5e` |
| Original HAZ01 | `e7a94185a6e76b12516bfeb9f175d4b03b1ace1a` |
| D contract correction | `125c6db1598aacebf2f9f96055631e35cdd801ce` |
| D shared-lifecycle test correction | `6aa9e84ce6d80611b7210c47a4d8cbf2bd056433` |
| Original INT01 recovered implementation + publication evidence | `60bab32f73c1596608640113c30fbe0e46fbd33f`, `2fa6cd6a03de599b7f9098e8bf61f8d770784091` |
| C follow-up implementation + provenance, same tree as PR89 | `3d740849231bf6720328af51491817b3b1bb6d11`, `a8993c544feaafc56f11fe24d1e55c40d602bf20` |
| D final identifier validation | See `pins.json` |

C alone resolved `world.gd` and export context conflicts. PR78 source was retained, with only the six reviewed INT01 hooks and director declaration. No Candidate3 RoomBoundary or creator geometry was imported. The sixth hook routes only `story_managed_encounter` defeat persistence through StoryDirector; unmanaged legacy handling remains unchanged. The coordinator accepted this narrow technical contract delta; it grants no story approval. The owner-resolution patch is retained for independent reproduction.

The combined QA branch is local `codex/alpha07-integration-qa-authoritative`. The report/test-only branch is `codex/alpha07-integration-readiness`, based directly on PR78. Candidate3 and all published feature branches are preserved.

## Runtime evidence

Engine: **Godot 4.6.1.stable.official.14d19694e**. Native renderer: **OpenGL 4.1 Metal / Apple M4**.

- **41 combined checks, 0 failures headless; 41 combined checks, 0 failures native rendered.** Real director rules drive all three real presenters: `opening_review`, `record_review`, `fallen_clan_review`. State is written before requests, even with the request listed first. Transition/control deferral, repeated events, synthetic gamepad B skip, reduced presentation, disabled/missing cut-ins and same-room rebuilding preserve state and restore input.
- The real guard defeat path is exercised during a transition. The test proves the enemy Node has been freed before control resumes, then checks one encounter save, one completion event/flag save, no replay writes, and an actual version-8 disk reload. Test-only `counting_world.gd` counts calls and delegates to the unchanged real serializer; disk saves are not mocked.
- Actual `spawn_encounter` and `arm_hazard` callbacks are registered on the sole StoryDirector. Duplicate IDs and missing consumers fail closed. A real enemy uses `world.spawn_enemy`; a real hazard reads authoritative flags. Composition roots must register consumers before loading rules and tick hazard consumers. There is no production room placement.
- Final negative adapter identifier results are recorded in `logs/adapter_ids-final.log`: **4 real-director checks pass**, plus **31 D consumer contract checks pass**. Initial failing evidence is retained in `logs/adapter_ids.log`. Initial tests demonstrated two real failures: invalid completion event `evt/Invalid-Event` and invalid new hazard flag `trap/Invalid-Flag` were accepted. D's narrow follow-up `6f7c5129c8532effdc8b9e9eff6ff65454312c33` now validates before mutating registry/bindings; the actual director accepts explicit/existing boolean legacy reads and duplicate hazard registration leaves no hidden binding. Check the final log and pin, rather than inferring compatibility from Git.
- **23 independent preservation checks pass:** the entire world file equals PR78 after removing only the reviewed hooks/declaration; ten guarded world bodies are exact; player, guard, geometry, transitions, map and project identity are byte-exact; 47 approved/candidate artwork files are byte-exact; only two exact export include-filter extensions are present.

Native before/presentation/after captures were inspected for legible fixture labels and restored gameplay. The combined harness steps timelines deterministically; its stills are not a native-speed animation benchmark. The creator's wall-clock preview deliverables are separate.

## Existing suites on the authoritative composition

| Suite | Pass / fail |
| --- | --- |
| Approved baseline | 32 / 0 |
| Approved combat swing | 7 / 0 |
| Movement/momentum | 53 / 0 |
| Sprite integration | 43 / 0 |
| Save compatibility | 11 / 0 |
| TR08 canal hang interruption regression | 53 / 0 |
| Cinematic presenter | 25 / 0 |
| INT01 contracts | 36 / 0 |
| EN framework | 52 / 0 |
| EN disk persistence | 6 / 0 |
| HAZ toolkit | 56 / 0 |
| HAZ contract | 17 / 0 |
| **Total** | **491 / 0** |

These 491 checks ran on exact source `fd41c9dfc4247a37657d9836ce4bf538d7884ea7`, immediately before the narrow consumer identifier correction. The final source `892b1ea29ab459d6e6ece1edba0cb88d3ec24972` / tree `bbd3c06f77c8672d1823f1a6b157923706eda457` was then validated with 4 real-director identifier checks, 31 consumer checks and the full 41-check combined test in both headless and native rendered runs. Unrelated broad suites were not repeated.

Original suite source hashes and exact runner adaptations are in `logs/regressions.json`. Assertion thresholds are unchanged. Save tests use copied scripts with literal writable disposable paths. TR08 uses a copied probe that sets the explicit private `save_path` before adding the unchanged campaign scene to the tree, and normal startup rather than `--test` so its real disk fixture loads. Its original probe wrote the supplied fixture path but never assigned it to PR78's world. All 53 existing assertions remain unchanged.

D's test-only lifecycle correction drives the single director in the deliberately frozen isolated arena; otherwise deferred state could never flush. The shared persistence failure test now proves director dirty/retry ownership and a real successful retry, rather than expecting the standalone fallback signal. Earlier failed runs are preserved separately; they were not relabeled as passes.

The original PR37 preservation guard still reports the inherited `world_expansion.build_room` difference and explicit export filter delta. The independent PR78 proof does not waive either original guard threshold. Import/export can emit sandbox editor-settings and certificate-access diagnostics; distinguish these from runtime assertions.

## Creator and integration gates

- **Image 4:** the actual selected Higgsfield source remains required for new ninja animation production. No substitute reconstruction was made and approved live sprites are unchanged.
- **Physical controller and packaged platforms:** synthetic events are covered. No hardware-controller session, signed Mac app validation, Windows execution or full unseeded progression playthrough is claimed.
- **Creator-designed rooms and canon:** no room expansion, progression gates or canonical deaths/identities/revelations were added. All production story arrays remain empty. Fallen-clan presentation is visibly provisional and requires creator approval.
- **Production metadata:** register approved encounter/hazard consumers, run the strict identifier checks, supply surveyed door/checkpoint/recovery exclusions, and validate every creator placement before any room is connected. A clean merge or successful PCK export is not runtime compatibility proof.

## Reproduction / Mac launch

The review-only PR needs a composed fixture; running its tests directly on its PR78 base is expected to fail missing specialist dependencies. Recreate the composition from the pinned commits above in a new worktree, let INT01's designated owner apply the narrow shared-file resolution, then copy the QA fixtures from this PR. Keep all PRs draft and unmerged.

For the already composed local workspace:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path '/Users/tonysantiago/Documents/Codex/2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative/work/integration-qa-authoritative' --log-file '/Users/tonysantiago/Documents/Codex/2026-10-22/kaze-codex-alpha07-coordinated-gameplay-narrative/work/integration-qa-authoritative-evidence/recheck-native.log' --script res://tests/alpha07_qa/combined.gd -- --test
```

This opens an automated rendered assertion session and closes on completion. Its save files live under `build/alpha07_qa`, not the campaign profile. Run `python3 tests/alpha07_qa/preservation.py` and `python3 tests/alpha07_qa/run_regressions.py` in the composed checkout for independent preservation and existing suites. See the parent PM report for the interactive cinematic, interaction, staircase and encounter demonstrations.
