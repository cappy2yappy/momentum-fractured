# TR-06 automatic passage reliability

Issue [#42](https://github.com/cappy2yappy/momentum-fractured/issues/42). Based exactly on PR #39, `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`. Draft only; creator playtest remains required.

## Change

Jumping past a side doorway can miss its narrow height corridor, then stop at the wall beyond its 85px activation band. The controller now permits recovery after landing on the endpoint's actual support while holding outward direction. Recovery still requires inward arming, expired cooldown, an outward-side position, matching support height and no tether. A held reverse direction also rejects the ordinary crossing path. The support must contain the endpoint and the player's full 28px-wide footprint; feet must be within 2px of its top. The support height comes from the existing arrival resolver, including its reviewed R9 shelf correction.

`can_enter` retains ownership of authored prerequisite hints. The transition controller detects a fresh announcement even when it repeats the previous text and duration. Silent expansion checks use the existing need-id route-sealed wording; generic Atlas guidance is the last fallback. Successful checks restore the prior HUD message when no new hint was produced.

Only `scripts/cinematic_transitions.gd` changes runtime behavior. Controller physics, enemies, assets, saves, progression, room construction/topology, arrival placement and transition presentation are unchanged. Depth doors, stairs, shrines and exceptional interactions retain their existing E policies.

## Reproduction and validation

Godot `4.6.1.stable.official.14d19694e`, Windows. `InputEventKey` events enter the normal Godot input path; the actual controller, collision and world physics run throughout each approach. No approach is teleported across a threshold.

The fresh series uses a new disposable save location, normal loading, no `--test`, no seeded abilities and no position/velocity writes. Kaze walks from the normal R0 spawn through its automatic right exit into R1, then jumps left toward R0. Offset values 0..40 (5px steps) are additional inward pixels from a 40px jump reference, so tested jump distances are 40..80px before the threshold. Baseline offsets 15..40 reproduce the grounded wall stall at x about 14 with zero X velocity. The same test passes after the fix.

Broader cases stage initial rooms and ability fixtures explicitly: Canal-left, both R13/R14 directions, R1-right, walking, double-tap sprint, dash, jumping, stopping, reversing and holding direction through arrival. All 39 automatic endpoints also receive a live-physics jump approach. Adversarial fixtures check the wrong floor below an elevated exit and tether rejection. The suite checks 23 locked automatic endpoints, preserving authored base-game hints and expansion need ids. These staged cases are not an unseeded campaign playthrough.

| Check | Result |
| --- | --- |
| Identical final test on untouched PR39 runtime | 211 pass / 94 fail, exit 1; zero script errors |
| Fixed runtime, headless Windows engine | 305 pass / 0 fail, exit 0 |
| Fixed runtime, rendered Windows / OpenGL / RTX 4070 Laptop | 305 pass / 0 fail, exit 0 |
| Existing TR05 source suite runner | 25 suites / 1,607 assertions pass |
| Approved baseline preservation | 0 failures |
| TR05 preservation against PR37 | 0 failures |

Full logs and exact commands are in [evidence](evidence). The baseline comparison worktree contains only the added test, test HUD and runner on top of the pinned commit; its production files are untouched. Test source SHA-256 on both sides: `1280d39148c27f059cc120da60e3d659894987bbd7c2a19caccfa94f8d47cd9f`.

Rendered [R1-to-R0 landing](evidence/tr06_jump_1-0_landed.png) and [R13-to-R14 landing](evidence/tr06_jump_13-14_landed.png) captures are staged endpoint cases from the passing native run. They show existing approved art, not new cinematic integration.

The rendered harness substitutes a test HUD that suppresses the production HUD's focus-loss pause, because automation runs beside Codex. It reissues a held key only if Windows cleared that key state on focus loss, using another real `InputEventKey`. This is test-only; the shipped HUD and controller are not modified. Earlier focus-paused rendered attempts are diagnostic failures, not passing evidence.

## Repeat

```powershell
python tools/run_tr06_qa.py --godot C:/path/to/Godot_v4.6.1-stable_win64_console.exe
python tools/run_tr06_qa.py --godot C:/path/to/Godot_v4.6.1-stable_win64_console.exe --rendered --label native-final
python tools/run_tr05_qa.py --godot C:/path/to/Godot_v4.6.1-stable_win64_console.exe
python tools/verify_baseline.py
python tools/verify_tr05_preservation.py
```

For failing-before proof, create a detached worktree at the pinned baseline, copy `tests/automatic_passage_reliability.gd`, `tests/fixtures/transition_test_hud.gd` and `tools/run_tr06_qa.py` into it, import with Godot 4.6.1, then run the same command with `--label before`. The runner creates and removes its own disposable profile. It preserves logs and reports timeout as exit 124.

## Limits

Human Windows/Mac acceptance, physical gamepad, sustained performance and full fresh-save campaign traversal remain unverified. This change does not supply the separate multi-frame cinematic art/integration assignment. No exported candidate or remote CI result is claimed. The import produced inherited renderer/text-resource shutdown leak diagnostics; the recorded behavioral test runs have zero script/parse errors.
