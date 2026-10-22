# Production requests and integration dependencies

All new assets below are **requested concepts, not approved production work**. Story supplies intent/copy; Level approves exact safe bounds; Art supplies matching scale and pivots; Audio supplies optional ambience; Gameplay owns interaction/state; INT-01 selects the accepted integration base. Do not assign narrative causality through an artist's undocumented flourish.

## Asset queue
| ID / beat | Deliverable | Required variant / audio | Acceptance and dependency |
|---|---|---|---|
| A00 / B01 | Existing safe-quay composition review | No new audio or Kaze sprite | Exact opening legible; Market route visible; R0 not a destroyed clan settlement |
| A01 / B02 | Small wrap prop and readable seam detail | Neutral/seam detail; optional soft cloth Foley | No crest, named owner, item glow or overlap with sentinel/Windstep |
| A02 / B03 | Damp letter at existing cache | No date/name; UI handles readable text | No countdown or new reward; preserve Wind gate |
| A03 / B04 | Broken parapet/backing plates | Static; wind ambience only | Existing crossing collision/swing envelope unchanged; damage undated |
| A04 / B05 | Archive routing graphic | Closed/open keyed to existing restoration; existing relay sound | Shows actual access, no dots implying people or live signals |
| A05 / B06 | Distant covered anonymous figure + cloth | Initial/memorial cloth states; room tone only | Blocked by D6; no named silhouette, anatomical detail or loot look |
| A06 / B07 | Carrying frame and loose bundle | Static, no identifying fabric | Outside Bellroof service/recovery lanes; no contemporary attack insignia |
| A07 / B08 | Lamp-care detail | Steady/reduced-effects presentation; no new speech | Does not imply a recent departure or a particular caretaker |
| A08 / B09 | Shared-feed pipe shapes / overlook framing | Existing guard state drives copy, not new enemy art | Preserve R18 guard shelf, Electric isolator, three anchors, vent warning and routes |
| A09 / B10 | Modest rest-bay framing | Existing checkpoint lighting/audio only | Preserve all three Foundry Rest Station displays and Storm Foundry name |
| A10 / B11 | Keeper-to-Undercroft route graphic | Existing closed/open states; no distress sound | Only shows return after attunement; no new region on map |
| A11 / B12 | Mooring landmark repeat and return lamp | Actual switch-state variant | No early-open appearance; no survivor trail |
| A12 / support | Paired Canal masonry/cleats and stair worker marks | Matching both ends; reduced-motion-compatible still frames | Fit published aperture/landing geometry; no additional prompt or camera cue |

Art handoff for each approved item: layered transparent source, export, native dimensions, pivot, intended world scale, bounding rectangle and foreground/background order; normal gameplay-zoom composite with collision/trigger overlays supplied by Level. Reuse approved biome identity and Kaze sheets. Do not bake text into artwork. Sound is optional and never the sole evidence; provide file format, duration, license/provenance and gain recommendation before binding. No new VO casting is needed.

## INT-01 dependency contract
1. Pin accepted candidate and compare source to the reviewed `c2170032…`; document graph/gate differences before reusing coordinates. This bible does not authorize adopting the entire Wave 3 candidate.
2. Import only approved decisions/copy/assets. Keep PR72 exact strings; do not reapply its old branch wholesale. Documentation approval and runtime approval are separate.
3. Decide interaction UI, input priority and safe-area eligibility. Existing notes trigger on proximity (65 px for expansion lore) and persist in `expansion_flags`; they are not already an Examine system. R2 letter uses `secret`. Do not silently convert existing collectibles or duplicate their rewards.
4. If approved, design additive narrative storage with explicit old-save defaults, atomic read/memorial persistence and no changes to existing gameplay flags/checkpoint identity. `st05.*` is a proposed namespace, not an existing API. Reserve it only through a reviewed implementation.
5. Implement queue arbitration so boss/gate/pickup announcements win. Optional text cannot consume jumps, attacks, transition input, save activation or automatic passage behavior. No schema migration is authorized by this docs PR.
6. Review route coverage and save behavior before content integration. Keep all new clues disabled if creator decisions or the adapter are missing; approved opening still works without them.

## CIN-TOOLS dependency contract
Inspected `tools/cin-tools-01-cutin-maker` at `af18438` and its `docs/cin_tools_01/INTERFACES.md` / PM report. This is an isolated prototype based on PR64, not an adopted production story player. It offers AnimationPlayer templates, preview/scrub and a staircase demo; normal gameplay adoption remains pending.

**Default ST05 delivery needs no cutscene.** B06 is a player-chosen quiet inspection, never a boss-reveal template. No mandatory scene is requested for R0, the Canal return or R14↔R17. A later optional B05/B11 panel emphasis can be proposed only after creator approval of timing and adapter integration.

If CIN-TOOLS is adopted later:
- World owns route eligibility, state, checkpoint and room requests. Timeline tracks may present approved text/art only; they cannot write progression or call a second transition.
- Ordinary automatic passages remain ordinary. Do not attach a story pause to R0↔R13 or R14↔R17 merely because templates exist.
- One input/camera owner at a time. Review skip, focus loss, pause and reduced motion; accepted transition ownership must complete at most once under the existing adapter rules. Death/rebuild supersedes a stale request; a story scene must never revive it.
- Preview/scrub has no world reference or save writes. New story scenes need their own reviewed binding; the stair demo is not proof they work.
- Missing art/audio falls back to a plain optional text panel. Reduced motion/skip preserves information without an animation requirement. No runtime promise is made until Gameplay/INT-01 validate the adapter on the accepted base.

## Acceptance tests after approved implementation (not executed here)
- Fresh unseeded run: exact opening, useful first objective; route fully completable with every new interaction skipped.
- Branch-order runs: early rooftops; Root Shrine before casualty; R20 before Keeper; R18 guard already dead; all rooms visited before B12.
- Saves: old save missing all ST05 keys, existing `secret`/`lore_*` true, Archive/Keeper already restored; read/memorial saved once, no duplicate heal or respawn. Reload does not replay the body or alter checkpoint.
- Interruptions: leave, damage, die or dismiss before text displays; no premature read flag. Re-examine later. Milestone queue cannot replace a gate instruction.
- Placement: normal and fast traversal, both passage directions, fall recovery, combat telegraphs, sigils, seals and checkpoint prompts remain readable and usable. No new collider.
- UI: 1280×720 and compact viewport, keyboard/gamepad remapping, full text without audio, reduced motion, explicit cancel.
- Canon: compare shipped strings/art against approved decision IDs; no named casualty, dated evacuation, hidden-helper clue, survivor radar or new enemy allegiance.
- Run established preservation and relevant Godot regression suites with disposable saves once runtime changes exist. Record OS/build/candidate and distinguish source checks from human playtest.
