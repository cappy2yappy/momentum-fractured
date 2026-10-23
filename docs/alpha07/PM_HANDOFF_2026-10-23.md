# KAZE PM handoff, 2026-10-23 16:50 NY (Claude coordination checkpoint)

Purpose: let coordination continue safely if Claude's usage limit is reached. Everything here is read from GitHub (cappy2yappy/momentum-fractured). All specialist PRs are draft and unmerged. No implementation, generation, external transfer, merge or release is authorized by this note.

## 1. Baselines
- **Alpha 0.6.1:** NOT accepted. Reference tree is Candidate 3, `candidate/wave3-targeted-3` `c2170032` (PR #77). Creator verdict: needs work, 3 of 28 checklist items. Eleven automated failures and six skips tracked in `docs/alpha07/QA_0_6_1_TRACKING.md`, separate from everything below. Universal roof not approved. Last macOS playtest build: Actions run 39815022431, artifact id 12443670152 (expires 2026-11-21); bytes never verified by Claude.
- **Alpha 0.7:** development foundation is Candidate 3 per Gate A0 (2026-10-22), provisional, rebase if the accepted source changes. Isolated integration branch: PR #84 `candidate/alpha07-integration` `1f01e407` (base note only). No gameplay PR is merged anywhere. Contracts v1.1 and exceptions are in PR #80.

## 2. Active PR heads (verified 16:50) and ownership
Owners: Codex leads implementation and delegates to specialists; Claude is integration lead and reviewer; the creator is the creative authority; the PM approves gates.

| PR | Branch @ head | Stream |
|---|---|---|
| #101 | qa/qa10-cinematic-native-regression @ `2b727670` | QA-10, independent QA owner |
| #100 | tools/cin-tools-03-studio @ `7b162dd5` | Cinematic Studio, Studio owner |
| #99 | codex/art11-environmental-assets @ `250afde2` | ART-11 |
| #98 | codex/ld08-open-top-boundaries @ `2ceaf453` | LD-08 |
| #97 | codex/gp09-narrative-vertical-slice @ `02c69c31` | GP-09 |
| #96 | codex/cin04-story-cinematics @ `bf696dab` | CIN-04 |
| #95 | codex/art10-ninja-staircase @ `30ab48a1` | ART-10, Art/Animation owner |
| #94, #92 | codex/asset01-controlled-pilots `815bceb9`, codex/asset01-intake `2dd5c4f6` | ASSET-01 |
| #91, #90 | codex/alpha07-coordination `164daddd`, codex/alpha07-integration-readiness `95fe0a36` | Codex coordination and QA fixtures |
| #89, #88 | codex/alpha07-int01-remote-followup `3dc433cd`, feature/int01-story-director `2fa6cd6a` | INT-01 |
| #87, #83, #82 | codex/alpha07-compliance `5172db68`, feature/en01-alpha07-enemy-framework `5265e6c6`, feature/haz01-toolkit `33e70874` | EN-01 and HAZ-01 (#87 carries the HAZ-01 code; #82 and #87 must not both merge) |
| #86, #85 | codex/alpha07-story-cinematics `2d459743`, codex/alpha07-animation `378b86ca` | Cut-in presenter, animation |
| #81 | narrative/st05-discoveries `1d157f4b` | ST-05, creator-gated, proposals only |
| #80 | docs/alpha07-production-plan (this doc's branch; verify head on GitHub) | Claude docs |
| #79, #78 | tools/ld-tools-02-room-creator `7a17cb42`, tools/cin-tools-01-cutin-maker `af184380` | Tools |
| #77, #62 | candidate/wave3-targeted-3 `c2170032`, art/art08-embodied-cinematic-animation `98d639f3` | Candidate 3, ART-08 |

## 3. Cinematic Studio #100 at `7b162dd5`
Reports a usable Mac workflow: pose and key a joint, save a native Animation, reload in a fresh process, reuse the exact clip in two Director shots at 1.0x. 212 headless plus 212 native-rendered assertions, zero failures (author-reported; Claude has not rerun). Prototype only: flat-art seams, FK limb overlap, unvalidated foot contact. Windows, controllers, exports and creator acceptance pending. Note: this head is newer than the one QA-10 tested (`d227b038`); see section 4.

## 4. QA-10 #101 at `2b727670`
Diagnosis complete: the automation HUD still ran the production focus-pause handler, pause survived world replacement, and an unbounded native screenshot wait could stall. Same mechanisms on #78 and #100. A test-only overlay is reported to pass complete macOS native suites (#100: 855 native plus 16 contract; #78: 826 plus 16; headless 2,505; 609 production files unchanged). **Pending:** coordinator review of the #101 diff (Claude, not yet done), PM acceptance, and a rerun against #100's newer head `7b162dd5`, since #101 was validated against `d227b038`. The compositor-specific reason for suppressed draws is unresolved. macOS Godot startup crashes are a separate diagnostic, unresolved by #101. Windows native validation not done.

## 5. CIN-04 clip-reuse prerequisites (Claude's reading, confirm with the CIN-04 owner)
CIN-04 (#96) is stacked on #86 and #78 and uses Cut-In Maker timelines, not Studio clips. To reuse Studio clips it needs: (a) #100 persisted clips accepted by the creator and QA-10 accepted; (b) a shared interface that does not duplicate Studio code; (c) INT-01 state-before-presentation preserved (progression applied before `request_cutin`; cinematics never own flags, saves or spawns); (d) cancellation on room rebuild. CIN-04 copy for Resistance and Fallen Defenders is proposal only; no location, identity or casualty is canon.

## 6. ART-10 #95 and PR #62
#95 audits 15 local images and 40 key specifications; all four production staircase slots (grounded and expressive, ascent and descent) are empty. Original drawings and visually validated foot contacts are missing; Image4 keys are source studies only. The artist handoff is `ART_MANE_HANDOFF.md`; the direct Art Mane thread lookup failed, so no artist message was delivered. PR #62 (ART-08) is the verified repository destination: script-authored candidates, door_turn_to_rear stand-in, door_turn_to_side unfinished, creator acceptance reserved. Standalone rig parts and a Studio scene were absent from inspected source trees.

## 7. Active Codex work: direct mouse joint manipulation
Reported active by the PM. I found no published PR, branch or commit message for it as of 16:50, so ownership and status are unverified. It presumably extends Studio (#100). Do not start a parallel implementation; ask the Codex lead for the branch and base.

## 8. Open gates
- **Creator:** Alpha 0.6.1 acceptance, roof, Level questions (pit penalty, service routes, strips), ST-05 D1 to D14, casualty options, world-design sheets (pending, authoritative on arrival), Studio and CIN-04 visual review, ART-10 originals.
- **Platform:** Windows native validation, macOS startup crashes, controllers, exports, FPS, full campaign.
- **Licensing and provenance:** creator-attested provenance for ASSET-01 (#94), source-art restrictions, no external transfer, Image4 provenance.
- **Integration:** PM acceptance of #101; INT-01 managed defeat and save-retry seam (EN-01 has 3 failures without it, EX-05); exceptions EX-01 (collapse conflicts with #87 production check), EX-02, EX-03, EX-05, EX-08 decided one at a time; #82 versus #87 duplication; combined validation rerun on a fresh tree covering #88 through #101; Gate A1 not opened.

## 9. Safe next steps and resuming
1. Verify heads against section 2 with `gh api repos/cappy2yappy/momentum-fractured/pulls?state=open`.
2. Review #101's diff: test-only, original assertions retained, no production edits. Ask for a run on #100 `7b162dd5`.
3. Get the mouse-joint branch from the Codex lead.
4. Recheck the combined tree after INT-01 gets its seam; use `--import` first and clear stale test saves under the Godot user dir before movement and save suites (a stale profile caused false failures before).
5. Update PM with a readiness report only after the above.

Environment notes: shallow clone, so `git fetch --depth=300` each SHA before merging; GraphQL is blocked, use `gh api` REST, draft via `-F draft=true`; stop-hook "unpushed" warnings have been false alarms fixed by fetching the remote-tracking ref. Never write em dashes in docs (creator preference). Do not merge, release, upload, generate or spend without explicit PM and creator authorization.
