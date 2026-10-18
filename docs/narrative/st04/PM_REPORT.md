# KAZE ST-04 — PM Return / Documentation-Only Review
Date: October 18, 2026. Owner: Story Agent. Milestone: Alpha 0.6.1.
Repository: https://github.com/cappy2yappy/momentum-fractured
Story baseline: draft [PR #38](https://github.com/cappy2yappy/momentum-fractured/pull/38) @ 553285f1e8a3961c6b7c1c83ba861bbd4ee21438.
Gameplay reference: draft [PR #39](https://github.com/cappy2yappy/momentum-fractured/pull/39) @ 5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c.
Independent audit: [Issue #44](https://github.com/cappy2yappy/momentum-fractured/issues/44).
Branch: narrative/st04-post-attack-opening; **stacked on PR #38**, no merge authorized.

## Status
**Completed for review:** reconciled the creator-confirmed chronology and Mizuki name into existing ST-03 docs; separated resolved issues from open geography/mechanism questions; drafted three concise opening/checkpoint strings; proposed R11 **Foundry Rest Station**; prepared R0–R7/R18 art+level handoff. **Nothing player-visible or gameplay-affecting is implemented.**

## Documents
- ../st03/CANON_RECOVERY.md: creator-authoritative name/placement and source precedence.
- ../st03/SECTION_PLACEMENT_AND_BEATS.md: confirmed location in story, survivor-first objective and remaining approvals.
- ../st03/ROOM_PURPOSE_MATRIX.md: confirmed district context, explicitly provisional R11 checkpoint identity.
- ../st03/ENVIRONMENTAL_HANDOFF.md: updated art/level priority and latest-baseline caveat.
- ../st03/README.md and ../st03/PM_HANDOFF.md: review status and historical audit traceability.
- [CANON_DECISION_DELTA](CANON_DECISION_DELTA.md): approved chronology versus unapproved elaborations.
- [OPENING_TEXT_FOR_APPROVAL](OPENING_TEXT_FOR_APPROVAL.md): 3-string creator read-through and all related future runtime text sites.
- [ENVIRONMENTAL_BEAT_MAP](ENVIRONMENTAL_BEAT_MAP.md): concrete environmental direction for R0–R7 and R18.

## Main review findings
- PR #38 creator decision dated October 16 resolves **Mizuki** (Mikaze/Mizagi slips) and confirms **current 21-room district immediately after the attack**. Original clan refuge, R0, R11, and future sanctuary stay distinct.
- In PR #39, scripts/world.gd opens with a dark relay warning and current_objective() begins with a Market sentinel task. scripts/skyworks_region.gd labels the R11 checkpoint 'Foundry Refuge'. All miss or blur the approved narrative context.
- Proposed main opening: **'The refuge was attacked. I have to find the others.'**
- Proposed initial objective: **'Search for survivors. Defeat the Market sentinel for Windstep.'**
- Proposed R11 display name: **'FOUNDRY REST STATION'**.
- The underlying reason to restore the relay is **reach**: route access lets Kaze search beyond blocked areas. Existing relay flags and item progression remain wholly authoritative. No survivor-tracking power implied.

## Creator decisions still required
1. Approve/rewrite the three player-facing strings, plus consistency changes to the R11 objective/announce/interaction label. Gameplay Masta should not edit them prior to approval.
2. Decide whether R0 is the emergency shelter, nearby, or simply the first safe district foothold.
3. Decide which district damage is attack-related, if any, and what evidence is permissible at the main-route milestone.
4. Separate future review for age/function of affinity-reactive records, bosses' allegiances, and any sanctuary foreshadowing.

## Handoffs (recommendations, not assertions of agent receipt)
- **Gameplay Masta:** after approval, display-string-only patch to world.gd/skyworks_region.gd, plus UI and first-minute/fresh-save checks. No added quest flags or trigger branches.
- **Level Masta:** read ENVIRONMENTAL_BEAT_MAP, protect current physical route, checkpoint usability and recovery floors. Verify current PR #37 / #39 geometry rather than relying on old PR #33 screenshots.
- **Claude's Art:** submit stylized gameplay-scale architecture/prop treatments using approved visual language. Mood is separation/search; the original massacre and future sanctuary are not staged at R0 or R11.
- **PM:** track Issue #44 until approved text is separately implemented and shown on actual gameplay captures. Keep ST-03 and ST-04 draft/unmerged.

## Documentation QA and limitations
Validated against the existing ST-03 six-document package, creator's PR #38 comment, Issue #44 and inspected PR #39 source text. No new room IDs, map edges or gates proposed; narrative covers R0–R7 and R18 while preserving the entire 21-room ST-03 matrix.
Check GitHub diff: **only Markdown files under docs/narrative/st03 and docs/narrative/st04** should change relative to PR #38 head. No code, images, assets, controls, save data or test fixtures to be modified.
**Not executed:** Godot runtime, native/exported builds, screenshot proof, UI overflow, actual first-60-second playthrough and localization. They belong to the post-approval Gameplay/QA follow-up. A clean text review is **not** a passing gameplay regression run.
No branch merge, production release, new character, live relay locator, or spoiler reveal authorized.
