# LD-07 PM handoff - 2026-10-21

Owner: Level Masta / Codex. Status: **ground repair evidence delivered; conditional coordinator review**. Keep PR #63 draft. Do not merge or treat unresolved issues as approved.

## Identity and recovery

- Branch: `feature/ld05-intentional-world-boundaries`.
- Worktree: `/Users/tonysantiago/.codex/.chatgpt-projects/g-p-6aa9b0443c20819186909618bb6be970/work/ld07-recovery`.
- Recovered PR head/runtime: `fa299cff0afe5172d5e37fad7d8378209425db56`.
- Verified implementation/evidence commit: `28efc6ab29ada5ca6fc1a86c159354d4ccce3edb`. A subsequent documentation-only commit adds this handoff and delivery inventory; its exact final head is published in PR #63. A report cannot embed its own commit hash.
- PR integration base: `49ae3efe21dea6a9eba556ce2fbc8299b00412b9`.
- Latest combined reference, read-only: PR #74 `c2c3d958abe8c1eb77e2851d29c00544bef63e80`.
- Reviewed PR #37 (`b950373e`), #39 (`5dfc4c4f`), #58 (`0656766d`) and existing LD05 handoffs/commits. No existing local #63 worktree was found; the existing remote branch and all six prior commits were recovered into the writable project workspace. No competing PR was created.

## Delivered

[All-21-room coordinate audit](../ld07/ROOM_AUDIT.md), [QA report](../ld07/QA_REPORT.md), [before/after and 21 native room captures](../ld07/captures/README.md), [exact scoped and whole-PR changed-file lists](../ld07/CHANGED_FILES.txt), and [machine-readable delivery metadata](../ld07/DELIVERY.json).

Retained and independently verified existing repairs: R6 walking-door sill, R8 depth-door landing extension, R13 Canal under-pad plinth, and R2/R4/R5 water alignment. Reproduced the first three physical defects against pinned pre-repair runtime; captured water before/after. Added real-input ground coverage with both roof modes, including an uninterrupted Stride pickup-to-exit route and serialized landing-save restoration. No new runtime edit was needed. All scripts/assets/scenes/map/settings, including movement, gatehouse and roof comparison, are byte-identical to recovered `fa299cff`.

Repaired two stale checks: an overfitted exact stopped-x assertion now tests the actual safe reciprocal shelf; the preservation guard permits only the exact earlier PR58 gatehouse hook while independently locking its implementation. Missing/duplicate hook, unrelated route mutation and moved threshold all fail mutation checks. Initial failures remain in evidence.

## Verification and limits

Official Godot 4.6.1 on macOS / Apple M4. Native rendered OpenGL/Metal and headless runs, isolated save profiles. Final green matrix: 30 headless suites, **2,466 pass / 0 fail**, including all 25 stock suites (**1,607 / 0**). Rendered LD07/automatic/Canal: **632 / 0**. Approved artwork/controller manifest and corrected preservation pass; four guard mutation tests pass.

Two roof-off 21-room sweeps: **22,432 total movement samples**, including 72 buried/nonstandable fixture samples per sweep (not evidence of reachable traps). No fall sample outside seven intentional pit intervals. Ordinary walking-door inventory improves **38/39 before -> 39/39 after**; all 54 observed arrivals supported. Four story-gated interact endpoints were not unlocked in the live-input fixture. No human campaign, physical gamepad, export/build or creative acceptance claimed. This branch does not certify the later combined candidate.

## Required PM actions (not waived)

1. **GN-06 remains red.** `tests/ld07_dash_regression.gd`, pinned to recovered `fa299cff`, returns exit1: dash from R6 feet(2300,1108), Shift at tick8, crosses the sill without arming R7. It stops at(2585.997,1089.998), requests0. Walking inward and reapproaching recovers. Send the reproducer to Transition through PM, agree ownership and test the next combination. Do not assume #64's Canal fix resolves this R6 case. No Transition implementation was edited.
2. **Roof remains unapproved.** Roof-off sweep records12 above-top lateral exits with gates open (R13:8,R17:4),10 with gates closed. No roof choice, switch, collision or comparison artifact was changed. Creator decision is required before any enclosure implementation; current roof-on test success is not approval.
3. Bare catch-floor purpose, pit pacing, past-door strips, duplicate R14 top, latent out-of-bounds recovery poses and flat-water polish retain explicit dispositions in the audit. No new routes/mechanics or silent redesign.
4. Re-run combination QA after PM integration. PR #64/#62/#72/#73 and the Wave3 combined candidate were not modified. No merge and no release build.

Next owner: PM coordinates GN-06 with Transition and obtains the creator's roof decision; Level evidence is ready for review. Everything in this handoff is committed; final push and draft/head identity are verified in the PR delivery.
