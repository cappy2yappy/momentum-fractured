# ST-04 — Opening and Checkpoint Copy for Creator Approval
Date: October 18, 2026. Status: **PROPOSED player-facing wording, NOT implemented**.
Source audit: [Issue #44](https://github.com/cappy2yappy/momentum-fractured/issues/44), [PR #39](https://github.com/cappy2yappy/momentum-fractured/pull/39). Source files currently use technical relay-first messaging. No code or quest changes in ST-04.

## Three-string approval package
| Moment | Proposed copy | Why |
|---|---|---|
| **First appearance / opening** (current world.gd initial announcement) | **The refuge was attacked. I have to find the others.** | Establishes Kaze's awareness, separation, search motive. Does not assert everyone died or locate survivors. The original clan refuge is elsewhere. |
| **Initial objective** (current world.gd current_objective first condition) | **Search for survivors. Defeat the Market sentinel for Windstep.** | Survivor search is the reason; existing required Market encounter and Windstep pickup remain the immediate player action. |
| **R11 checkpoint name** (current skyworks_region.gd display label) | **FOUNDRY REST STATION** | A functional rest point in Storm Foundry, unambiguously separate from original clan refuge and later forest sanctuary. Proposed only; R11 room name remains STORM FOUNDRY. |

### Current strings and proposed companion substitutions
| Code location | Existing / audited text | Proposal awaiting approval |
|---|---|---|
| scripts/world.gd initial message | The rooftop relay is dark. Follow the canal route east. | The refuge was attacked. I have to find the others. |
| scripts/world.gd first current_objective() branch | Defeat the Market sentinel and claim Windstep. | Search for survivors. Defeat the Market sentinel for Windstep. |
| scripts/world.gd R11 objective later in progression | Save at Foundry Refuge. Open the Electric relay. | Rest at Foundry Rest Station. Open the Electric relay. |
| scripts/skyworks_region.gd R11 checkpoint announce | Foundry Refuge restored. The Keeper waits east. | Foundry Rest Station active. The Keeper waits east. |
| scripts/skyworks_region.gd R11 on-world interaction label | FOUNDRY REFUGE • E | FOUNDRY REST STATION • E |

**Concise UI fallback if needed:** 'Find survivors. Claim Windstep in Lantern Market.' This loses the direct sentinel instruction, so prefer the main line if its width is safe.

## Explaining the relay without inventing functionality
**Confirmed objective:** Kaze searches for other survivors.
**Existing mechanic:** Restoring the Archive relay unlocks routes to the annexes and later infrastructure; the three relay sigils and SkyWorks attunement retain their original gates.
**Proposed player-understandable rationale:** The canal paths and service passages are broken or sealed. Repairing usable relay access reopens a way through the district so she can search areas beyond her immediate reach.

Optional *later* contextual line near the established R7 relay restoration (separate creator approval, no new trigger):
> These routes are opening again. I can search farther.

This is a rationale for traversal, **not** a survivor locator, rescue confirmation, communications system, or compulsory note. Leave all original gates/pickups and their existing instructional text unchanged unless Gameplay Masta receives a separately approved copy list.

## Creator read-through (spoiler-safe player experience)
Opening: 'The refuge was attacked. I have to find the others.'
Objective visible during first exploration: 'Search for survivors. Defeat the Market sentinel for Windstep.'
Existing room path continues: Canal Haven -> Lantern Market -> Flooded Cistern -> Echo Shrine -> Broken Span -> Ascent Tower -> Tide Warden -> Relay Archive.
At R7, restoring a relay is understood as a way to **search farther**. Later, R11 offers a rest station, never a second 'refuge' that sounds like a recovered clan village.

## Implementation handoff only after approval
Gameplay Masta to change **display strings only** in scripts/world.gd and scripts/skyworks_region.gd. Retain original objective branching, encounters, unlock conditions, room IDs, E interaction, checkpoints and save schema. Confirm the initial message appears sensibly on fresh save; existing save/resume may require an approved display policy but no new save flag is authorized. QA: 1280x720 plus smaller viewport, UI overflow, announcement duration, first 60 seconds, R11 label + announce + objective consistency, fresh/continued saves, and absence of Mizuki spoilers. No runtime test or screenshot has been executed by the Story Agent.
