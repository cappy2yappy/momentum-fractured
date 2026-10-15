# TR-03-0061 — Embodied Room Transitions & Environmental Cohesion

**Status:** Creator-approved design direction; implementation work order **for specialist review**, not a merge authorization  
**PM:** Kaze Project Management  
**Owners:** Level Masta Masta (transition/level implementation); The Art Mane (visual language, animation specifications, later production assets)  
**Game:** Momentum Fractured / Kaze, Godot 4.6.1  
**Milestone:** Alpha 0.6.1 comparison follow-up; longer-term visual polish may extend into Alpha 0.7  
**Repository:** https://github.com/cappy2yappy/momentum-fractured

## Authoritative context and references

- Creator's spoken TR-02 playtest feedback, transcribed/summarized by PM in project chat on 2026-10-15. It is **not** a verbatim GitHub archive.
- [TR-02 mixed transitions PR #16](https://github.com/cappy2yappy/momentum-fractured/pull/16), branch `feature/alpha-0.6.1-mixed-transitions`, last checked head `e9a2d1ab0537f3f903c543b080451b3556961179` (re-verify).
- [TR-02 PM report](https://github.com/cappy2yappy/momentum-fractured/blob/feature/alpha-0.6.1-mixed-transitions/docs/agent_handoffs/TR02_ALPHA061_PM_REPORT.md)
- [TR-02 original work order](https://github.com/cappy2yappy/momentum-fractured/blob/0b9470b71ebd32eaa0d4987cbd23bcde082242bf/docs/agent_assignments/TR02_ALPHA061_MIXED_TRANSITIONS.md)
- [Art Mane biome identity PR #11](https://github.com/cappy2yappy/momentum-fractured/pull/11)
- [Agent continuity protocol draft PR #18](https://github.com/cappy2yappy/momentum-fractured/pull/18). If still unmerged, read from branch `docs/pm02-agent-continuity`.

## Creator feedback: explicitly captured decisions

1. Creator **likes** TR-02's **special wind-fold graphic**. Keep its expressive quality as the model for exceptional/supernatural crossings.
2. Creator **likes** walk-through / running graphic ideas, especially when they acknowledge Kaze's actual approach motion.
3. Room travel must look like a character **performing a spatial action**, not a generic interchangeable wipe. Adapt presentation to actual entrance orientation, movement and architecture.
4. At a doorway opening inward/deeper into the scene rather than a horizontal left/right exit, Kaze should **turn toward and enter that doorway**, not slide sideways or disappear in place.
5. At stairs, Kaze should eventually **visibly ascend or descend**. Stairs should have believable dimensional continuity.
6. Floating platforms should eventually be grounded in environment: terrain, structural supports, ruins, roofwork, bridges, wall brackets or plausible supernatural justification. **Do not** globally remodel collision geometry in this task.
7. The creator explicitly allows **phasing**: new custom sprites / full animation sets can follow later. Do not block an otherwise testable transition pass on unfinished art.
8. Inspiration is conceptual: *Resident Evil* establishes intentional door-crossing presentation; *Metroid* and *Castlevania* establish connected-world traversal. Avoid reproducing trademarked artwork, transitions or asset designs. Persona 5-inspired graphic energy remains an original Kaze visual treatment.
9. Do not automatically reinterpret the creator's spoken example name as a canonical character change; **Kaze remains the player character** unless separately approved.

These are direction approvals, **not final per-frame animations or blanket acceptance of all TR-02 mechanics**. Existing TR-02 is a comparison baseline and stays intact.

## TR-03 implementation strategy and feature gates

### Lane A: Level Masta Masta — interaction taxonomy and safe prototype

**Recommended working branch:** `feature/alpha-0.6.1-tr03-embodied-transitions`, fork from current TR-02 feature head after verifying remote. Draft PR base: TR-02 branch, **not main/integration**.

- Audit all present transition endpoints and assign an explicit *presentation mode*: `horizontal_walk`, `horizontal_run` (when speed state provides a grounded distinction), `depth_door`, `stair_up`, `stair_down`, `wind_fold`, or existing plain/fallback. Do not invent connections or infer direction solely from sprite facing when door metadata is ambiguous.
- Preserve R15↔R16's approved directional passage as a scoped test pilot; carry horizontal velocity only under existing TR-02 safe rules. Preserve original 0.65s room-load semantics, cooldown/rearm and progression gating unless creator review requires a bounded change. Walk/run presentations should track actual traversal intent without speed manipulation.
- Keep R14↔R17 stairwell as the structural control; prototype art-independent **stair entry/exit staging** with anchored facing, optional reversible turn, clear fade, and deterministic arrival. The final staircase animation is a separate art-dependent gate.
- Keep R20↔R13 special wind-fold as an expressive exceptional treatment. Do not apply that intensity to every ordinary connection.
- For eligible **depth-facing door** locations, prepare a non-destructive prototype: Kaze visibly reorients/turns toward a doorway and moves into depth before fade. If current endpoint metadata cannot support this without topology changes, submit the metadata schema/design and ONE gated demonstration rather than changing graph, gates or collision globally.
- Maintain three original-comparison toggles where practical: current TR-02 graphic, refined context-sensitive staging, reduced motion/plain. Never make spinning, flashing or camera shake necessary to read travel.
- Room architecture pass: audit conspicuous unsupported floating platforms and deliver a **priority-ranked structural dressing plan** per room with screenshot/map references. Prototype only *visual backing pieces* at 1–2 pilot locations if appropriate and performance-neutral; no unapproved platform, collider, vertical port or navigation changes.
- Use temporary animation/staging placeholders only where art isn't available, visibly label them and preserve an immediate fallback.

### Lane B: The Art Mane — visual and animation asset specifications

**Recommended working branch:** `art/alpha-0.6.1-tr03-entry-poses`, fork from current vetted art branch or an agreed common base. Keep work isolated from Level branch.

- Audit approved Kaze character proportions, current sprite set and anchoring; do not redesign the character.
- Specify a minimal *action pose/strip pack*: depth-facing turn + entering, stair ascending, stair descending, and walk/run exit continuation (reuse existing run where technically suitable). Define frame size, anchor consistency, naming, timing, palette, transparency, directional variations and Godot import metadata.
- Produce original *entry architecture* reference kit: door threshold/frame, stairwell facing and landing, culvert support, rooftop braces, canal platform supports; show plausible sightlines and entry depth. Prioritize existing biome identity, no genre asset tracing.
- Deliver **storyboard/contact sheets and animation briefs first** so Level Masta Masta may prototype without waiting for polished art. Final animation production requires creator review of the storyboard and actual Kaze sprite compatibility.
- Keep transitional art assets and art source docs on the specialist art branch; no blind replacement of production sprites.

### Integration boundaries and protected invariants

- **Must preserve:** approved movement speed and floatiness, run/jump/dash/tether behavior, ability acquisition, gating, interactions, combat, map/minimap, save format and default save identity, room graph/endpoints, player scale and 60 FPS design target.
- **No new traversal links** and no multi-level same-wall exits without a separate explicit graph/topology approval.
- **No merge to main, candidate, or TR-02 branch without PM/creator approval.**
- Sound effects will be coordinated later with Sound Shogun; no license-unverified third-party media enters public builds.
- Keep TR-02 comparison playable while developing TR-03. Project benchmark remains the existing web demo for movement feel.
- Do not change 0.65s loading clock to disguise problems, or claim seamless streaming.

## Quality and creator acceptance tests

**Required Level QA:** unit/source transition policy checks, real in-engine directional runs, unchanged gate/save/profile/respawn tests, no accidental double transitions, on-arrival safety, locked passage denial, strong approach/turn readability, reduced motion, gamepad/keyboard mapping, Windows export and native launch where possible. Include before/after comparisons at 1280×720 and scale 1.0, clearly tag scripted fixture vs human-playtest evidence. Report draw timing and any regression honestly, but do not certify sustained 60 FPS without full-run data.

**Required Art QA:** animation frame boundaries/clipping, RGBA, consistent anchors, frame parity, visual readability at gameplay zoom, transparent edges and brief sprite sheet frame previews. Do not treat storyboard approvals as integrated animation approvals.

**Creator review criteria:**
- Horizontal walk looks like a walk; running approach reads as running.
- An inward-facing door produces a convincing turn/entry, not horizontal sliding.
- Stairs visibly lead somewhere rather than acting like a decorative teleport.
- Wind-fold retains its exceptional, energetic identity.
- Architecture feels supported and rooted, and old gameplay remains untouched.
- No surprises in save/progression or unintended movement speed.

## Required deliverables

**Level Masta Masta**: endpoint presentation matrix, prototype code on own branch, QA logs, screenshots or GIF comparisons, Windows test package or reproducible CI ref, list of art placeholders, draft PR and PM return report.

**Art Mane**: asset requirements and sprite/architecture audit, storyboard set, accepted-vs-new asset table, frame/pivot/import specification, original concept previews, future production schedule, dedicated draft PR and PM return report. If the creator approves the initial art pass, later final assets can be implemented on the branch without altering gameplay.

**Both agents:** link branch and exact HEAD, status of each requirement, risks, remaining creator decisions, and update continuity records. Do not report locally generated files as backed up without pushed commits.

## Dispatch sequencing

1. PM dispatches Lane A and Lane B separately with **this same authoritative brief**.
2. Each specialist verifies current GitHub source, reports any ambiguity without redoing prior TR-02 work, and pushes a first recoverable checkpoint.
3. Art first supplies minimal action/pose specs; Level implements safe placeholder staging and shared visual taxonomy in parallel.
4. PM reviews isolated PRs and coordination evidence; integration is a separate assignment after creator acceptance.

**Authority:** The creator approved this design direction and documentation/assignment. This does not authorize autonomous merges or final art redefinition.
