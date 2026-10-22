# CODEX-ALPHA07 ownership and recovery

2026-10-22. Draft production work only. No merges or changes to Candidate 3.

| Area | Owner | Branch / base | Exclusive files |
| --- | --- | --- | --- |
| Animation inventory and isolated current stair review | Agent A | codex/alpha07-animation / PR78 af18438 | new animation tooling, candidate assets, own documentation |
| Story presentation and three isolated previews | Agent B | codex/alpha07-story-cinematics / PR78 af18438 | new presentation adapter and test scenes |
| Recovered interactables and shared narrative interface | Agent C | codex/alpha07-int01-remote-followup / published original 2fa6cd6a | scripts/story, world.gd hooks, data/story, export filter |
| Enemy/hazard contract corrections | Agent D | codex/alpha07-compliance / PR83 5265e6c plus additive PR82 toolkit | encounter and hazard modules, isolated QA |
| Independent compatibility QA | Agent E | codex/alpha07-integration-readiness / PR78 af18438 | QA only; no implementation edits |
| Contracts, GitHub handoff and consolidated readiness | Lead Codex | codex/alpha07-coordination / PR80 e561775 | docs/alpha07/codex_alpha07 |

Only Agent C can change world.gd, StoryDirector, save-related hooks or transition routing. Existing save_progress/load_progress, player movement, guard.gd, room geometry and live artwork remain protected. Story flags use existing expansion_flags; encounters use cleared_encounters; no save schema change. B consumes a presentation callback installed by the demo/composition owner. B never writes story or progression state.

Three child agents can execute concurrently. A and B completed their bounded deliveries, and D and E started as those slots freed. All five requested specialist roles were delegated.

## Recovered source

All requested PRs recovered and verified open draft through GitHub. Exact refs recorded in recovery.json. main is historical and is not a feature base. Candidate 3 is c2170032d08ea55268313e0020676c743251deab and remains untouched.

Unpublished INT01 was recovered through the earlier chat titled "Implement interactable object system", at the original local work/int01-interactables checkout. Original source is read-only; feature changes are copied into an isolated writable worktree. Earlier creator instructions require five object kinds and a multipage inspection UI; those requirements exceed the earlier announcement-only contract proposal and take precedence. No implementation was recreated to conceal missing work.

The creator supplied exact Image4 during this run. Its original is preserved unchanged and its baked checkerboard was verified. ART09 candidate pose studies are separate from existing ART08 clips and approved live sprites. Neither pilot is represented as creator-accepted replacement animation.

## Integration gate

No campaign placements before creator markup and per-row canon approval. No casualty or affiliation conclusion from ST05. No final Alpha07 integration branch promotion or merge is authorized by this work. A clean merge cannot satisfy runtime compatibility. Combined QA must pin component SHAs, run the engine, exercise interruption and restoration, and distinguish new checks from rerun existing checks.

## Narrow contract deltas accepted for this review

- The creator previously requested five object kinds and a multipage keyboard/gamepad inspection panel. Preserve that actual INT01 work rather than replacing it with the earlier announcement-only proposal.
- Contract section 6 requires export include filters for data/story, data/encounters and data/hazards. Record the original preservation verifier result unchanged, plus a strict separate proof that only these include patterns differ. Do not claim the original guard is clean if it reports this.
- C alone may add a sixth world hook for newly managed encounter defeats. Marked encounter enemies defer their world defeat handler through StoryDirector until transition completion and restored control. Existing unmarked enemies retain their existing handler. This closes the immediate save call connected by world.spawn_enemy without adding a second save manager. Exact final code and regression evidence must be reviewed before integration readiness is claimed.

These are coordinator implementation decisions within the authorized task, not approval of story content, room placements or animation assets. Existing save functions/schema, movement and original enemy behavior stay protected.

The original INT01 remote was subsequently published as PR88 at 2fa6cd6a03de599b7f9098e8bf61f8d770784091, independently fetched and verified. PR89 is an audited separate follow-up directly atop that source. Earlier local continuation/composition artifacts are provisional history; authoritative QA uses the recovered published source. Original branch and checkout remain untouched.
