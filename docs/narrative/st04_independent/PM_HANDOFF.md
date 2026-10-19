# ST-04 PM handoff and creator decisions
2026-10-19. Status: review-ready documentation; implementation not authorized by this package.

## Findings and priority
1. **P0:** Source opening omits confirmed survivor-search motivation. Approve earlier ST04 copy rather than create another version.
2. **P0:** R11 “Foundry Refuge” creates avoidable ambiguity with the attacked clan refuge. Rename proposal remains pending.
3. **P1:** R14 lower space already has service/recovery context; improve recognition, do not duplicate Level work.
4. **P1:** Canal gallery, shared-feed Pump Gallery and worker stair can connect environments through existing civic functions without revealing story secrets.
5. **P1:** Undated convoy/evacuation text can imply a current deadline; do not build rescue promises around it until chronology is decided.

## Creator decisions
| ID | Decision needed | Recommendation | Safe default while pending |
|---|---|---|---|
| D1 | Earlier ST04 opening/objective copy | Approve the two exact strings in ENVIRONMENTAL_PROPOSALS | Keep current runtime unchanged |
| D2 | R11 checkpoint naming | Approve Foundry Rest Station in all three existing display locations | Document distinction; no rename |
| D3 | Canal and stair environmental identity | Covered mooring service gallery; bellkeeper/worker service stair | Use only existing geometry/presentation, no new historical claims |
| D4 | R18 shared-feed dressing | Approve direction subject to art/geometry review | Keep PR47 separate; no adoption |
| D5 | R0's relation to emergency shelter | Leave exact geography unresolved unless needed for a later opening scene | Neutral quay, no shelter interior |
| D6 | Damage and convoy chronology | Decide whether records predate the attack before adding urgency/date | Keep records undated; no timed rescue implication |
| D7 | Section-end information | For now, reopened access extends the search; no confirmed survivor location | Retain existing mechanical completion message |
| D8 | Optional text moments and sample descriptions | Select only useful candidates; retain existing optional lore | No new dialogue, triggers, flags or description UI |

Already resolved, do not ask again: canonical Mizuki spelling; post-attack placement; survival/search rather than revenge. “Mentals” is not authority to invent a faction. Major revelations remain protected.

## Owner handoff
| Owner | Reviewable next action after relevant approval | Boundary |
|---|---|---|
| PM/creator | Record D1–D8 outcomes against this package and prior ST04 | Draft status does not confer canon approval |
| Gameplay | Bind approved copy to existing fields; preserve all branching | No new quests/gates/save flags |
| Art | Fit Canal motifs to PR58; R18 motifs to latest Level geometry; paired stair identity | No independent collider or opening relocation |
| Level | Supply authoritative geometry if it changes | Story does not fix containment or intermediate slabs |
| Transition/Claude | Use approved architectural identity within owned presentation | No duplicated camera/timing/animation implementation |
| QA | After implementation: first-minute comprehension, gate clarity, consistent R11 names, two-way recognition, reduced motion | New tests/playtest are future work, not claimed here |
| Build | Include only explicitly approved integrations in named candidate | This report does not request packaging or merge |

## Verification performed / limits
- Retrieved metadata for all six requested PRs and verified the creator decision comment on PR38.
- Read actual canon sources, earlier ST04 copy, runtime room/objective/gate/lore definitions, Bellroof service-walk implementation, PR58 contract and PR60 coordinator report.
- Inspected PR47's native-after R18 overview; no fresh Godot run or full-world screenshot pass.
- Checked 21 unique room IDs against runtime names and documentation-only change scope before commit.
- Existing automated counts in older reports are not ST04 test results. No claims of new gameplay or visual acceptance.
- No scripts, scenes, assets, dialogue bindings, progression or saves changed. No specialist branches modified, no merge.

Publication verification: verify draft PR head and read the pushed report from GitHub before reporting delivery. Exact commit/PR are supplied in the delivery message; this avoids a self-referential commit hash inside its own contents.
