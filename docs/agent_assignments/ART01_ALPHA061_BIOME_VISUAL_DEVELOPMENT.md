# KAZE — ART-01-0061 EARLY BIOME VISUAL DEVELOPMENT WORK ORDER

**Status:** PM APPROVED FOR DISPATCH — concept-development assignment only; production art requires creator review.
**Assigned specialist:** The Art Mane (retain existing chat name)
**Assignment ID:** ART-01-0061
**Game:** Momentum Fractured / Kaze
**Repository:** https://github.com/cappy2yappy/momentum-fractured
**Engine:** Godot 4.6.1
**Document source branch:** `docs/pm-art01-alpha-0.6.1-biome-brief`
**Proposed art feature branch:** `art/alpha-0.6.1-biome-identity`
**Relevant current integration baseline:** `integration/alpha-0.6-world-momentum`; fetch and verify current head before edits.
**Existing reviews:** Gameplay PR #8; Level Design PR #9; INT-01-0061 combined integration is running separately. Do not modify or merge their branches.

## Mission

Develop creator-reviewable **biome visual identities, composition concepts, and implementable asset specifications** for three distinct early-game environments, while the gameplay and level design teams build a playable integrated candidate. Art should reinforce story mood, navigation, readability and environmental continuity. **Do not** make speculative major world-topology decisions or replace stable character/gameplay assets.

## Creator-provided visual references and intended contrast

The creator shared **two screenshots/images in the Project Management conversation** (2026-10-14). They are not included in this GitHub Markdown file and should **not** be assumed automatically accessible to your chat. Ask for them to be attached to your conversation or retrieve an explicitly published project reference if available before asserting exact visual characteristics. The PM's written interpretation is:

1. **City / Silent District:** night-time Japanese city, urban skyline and rooftops, deep blue/indigo atmospheric range, dramatic luminous city details, reflective waterways, modern elements with a mysterious and slightly lonely mood. Character navigation and platforms must remain legible; do not flood every asset with neon.
2. **Hidden Village (prologue):** peaceful inhabited Japanese mountain/forest village, warm daylight, small-scale vernacular architecture, vegetation, paths, fields, water and ordinary lived-in details. Familiar, safe and emotionally grounded rather than futuristic or abandoned.
3. **Ruins / transitional awakening area:** concept hypothesis bridging the loss of the village to the cold city/early main gameplay. Overgrown shrine/stone remains, earth/root motifs, broken infrastructure/urban edge where appropriate. **Narrative and exact geographic connection are not yet canon.** Provide 2–3 alternatives rather than assuming the transition, time gap or memory loss.

The village is the **prologue** visual target and the city is the early core explorable world; ruins are a proposed transitional introduction. The established playable rooms need not be renumbered or geographically reassigned in this art task.

## Story and canon guardrails

Consult existing published narrative docs (including `docs/narrative/ST01_NARRATIVE_CANON_UPDATE.md`, `docs/narrative/ARIA_MNEMOSYNE_BOSS_ENCOUNTER_BRIEF.md` on their source branch if applicable, and narrative recovery history). Do not silently elevate earlier conflicting lore to canon. Kaze's hidden village is home before Darkness's attack; it should look lived in, socially active and worth protecting. The prologue may show ordinary daily life/school routines and eventual danger, but this is an **environmental identity brief**, not a scripted attack sequence. The player's precise arrival in ruins is pending Story/creator decision.

Coordinate with Level Masta Masta's actual room priorities (PR #9): Bellroof Walk R14, Lower Sluice R15, Counterweight Spire R17 and Coil Service Hall R19. These are **existing** rooms, not automatically the prologue. For current production needs, also provide motifs/assets suitable for underground retaining walls/pipes, roof skyline, shaft backgrounds and coil machinery.

## Phase 1 — Evidence and technical audit

1. Retrieve and read this GitHub document in full; acknowledge ART-01-0061 and scope.
2. Fetch repository and inspect current **real** render resolution, viewport/camera zoom, character on-screen height, room sizes, background system, tile scale/grid, parallax/layering structure and available asset formats; never invent exact pixel targets.
3. Review LD-01 room comparison views and level audit under `docs/level_design/alpha061/` from PR #9. Note where scenery must not obscure exits, platforms, grapple anchors, map/HUD, pickups, or hazards.
4. Review the approved Kaze sprite presentation and size anchor where available. Character-scale consistency is a hard constraint.
5. If the creator's two images are not accessible, use the descriptions above as provisional; request the exact two originals for visual sign-off. Do not pretend you viewed them.

## Phase 2 — Creative exploration

Produce **three biome visual identity sheets**, separately labeled:
- B0 Hidden Village / Prologue — warm safe inhabited daylight, with optional pre-disaster tension motif.
- B1 Ruins / Transition — at least 2–3 visual/story-compatible variants, no chosen geography or time gap without PM/Story approval.
- B2 City / Silent District — night city rooftops, distant skyline, industrial/water features, urban mystery.

For each identity sheet include: emotional goal; distinctive palette/color relationships (swatches and accessible contrast guidance); architecture, vegetation, weather/time-of-day; iconic landmarks; background depth composition; foreground/midground/background separation; traversable surface language; hazard/interactive contrast; parallax strategy; environmental story props; reusable asset inventory and proposed animation/VFX (where warranted). State clearly what is approved vs concept-only.

Bring original coherent designs aligned to the user images, not copied frames, scraped copyrighted designs, or generic prompt-art. The style should complement Kaze's 2D anime-inspired presentation and remain practical for Godot and 60 FPS.

## Phase 3 — Production-ready specification, not premature wholesale replacement

Propose:
- Layer naming and safe parallax rates relative to camera movement, if feasible.
- Sprite/tileset source formats, RGBA transparency, export PNG sizes and resolution/scale policy based on **inspected Godot source**, not guessed requirements.
- Seamlessly repeating skyline/field/architecture strips or chunking where needed; avoid visible seams.
- Color/readability rules for traversal edges, portals, hazards, kunai seals, enemies, and interactibles.
- An implementation matrix tying specific backdrop modules to **actual** known rooms R14/R15/R17/R19 while noting biome classification assumptions.
- Art performance budget and packaging expectations, texture import filtering/pixel alignment appropriate to actual existing asset style.
- Two priority prototype backdrops (prefer one city rooftop and one underground/ruin approach) as PNG layers or layered editable sources **only if supported in the execution environment**. The village concept remains priority even if implementation prototypes focus on currently playable rooms.

Aseprite exists on the creator's home Windows computer, alongside ArtCraft applications, but your cloud Work session does not automatically have access. You may use authorized image creation/editing tools or produce a detailed asset spec. **Do not claim to have used Aseprite, ArtCraft or Photoshop unless you actually did.**

Do not replace Godot room sprites/backgrounds in the integration candidate and do not change gameplay physics, transitions, topology, character proportions or canonical narrative. Any art integration must occur on your dedicated branch and be clearly demarcated for review.

## Phase 4 — QA and collaboration

Check concept readability at intended gameplay scale and at least one normal camera screenshot if tooling allows. Capture comparison previews, distinguish art stills vs in-engine captures. Assess paths, interactable legibility, panel seams, contrast and 60 FPS impact only if measured. Be clear whether assets are drafts, approved prototypes, or integrated/reproducibly tested.

Flag decisions for:
- PM + Story: prologue-to-ruins event timing, Kaze awakening details, city geographic relation and canon.
- Level Masta Masta: which backgrounds map onto each approved room and which geometry is finalized.
- Gameplay Masta / Integration: shader/layer/render ordering and stable player/hazard visibility.

## Deliverables

On `art/alpha-0.6.1-biome-identity`, commit and push where access permits:
1. `docs/art/alpha061/BIOME_VISUAL_BIBLE.md` — three biome sheets and identity/contrast rationale.
2. `docs/art/alpha061/ENVIRONMENT_ASSET_MATRIX.md` — room-to-background requests with priority and status.
3. `docs/art/alpha061/IMPLEMENTATION_SPEC.md` — inspect-derived technical specs, formats, layer/viewport compatibility, performance/readability checklist.
4. Creator-reviewable previews/assets under `docs/art/alpha061/previews/` and/or `assets/environment/alpha061/`, with actual files and licenses/provenance clearly recorded, if tools support generation. No invented screenshots.
5. `docs/agent_handoffs/ART01_ALPHA061_PM_REPORT.md` — complete handoff.
6. A draft review PR targeting `integration/alpha-0.6-world-momentum` **only if sensible**; do not merge and do not claim the visual bible alone completes production art.

If an environment lacks direct art authoring, produce a high-quality, inspected, actionable plan and report the generation limitation without falsely asserting completed images.

## Mandatory closed-loop PM return report

Finish the session with a self-contained **KAZE — PROJECT MANAGEMENT RETURN REPORT** including:
A. Executive Summary
B. References Actually Reviewed (explicitly whether creator screenshots were available)
C. Biome Identity Concepts (village, ruins variants, city)
D. Deliverables and File Inventory
E. Technical Asset Specification and Readability QA
F. Actual Previews / In-Engine Tests / Limitations
G. GitHub Branch, Commits, PR and Verified Push
H. Cross-Agent Dependencies and Canon Decisions
I. PM/Creator Approvals Needed
J. Recommended Production Order and Next Actions
K. Final Verdict: **READY FOR PM REVIEW**, **PARTIAL HANDOFF — CONTINUATION REQUIRED**, or **BLOCKED — PM DECISION REQUIRED**.

Preserve intermediate work near session usage limits and issue a partial report. The creator copies the final report back to PM. No visual direction or source assets become approved without creator/PM review.


## PM-01 reference availability update (2026-10-14)

The canonical proposed reference manifest is [ART_ASSET_REGISTRY.md](../art/ART_ASSET_REGISTRY.md), on this documentation branch. **REF-CITY-001 and REF-VILLAGE-001 remain unavailable as source binaries in the GitHub repo.** The original creator-shared chat images must be retrieved intact, permissions for publication in a public repository confirmed, then binary contents uploaded and independently verified before the agent can claim to have matched the creator's visual references. Current visual description is sufficient for technical audit and provisional planning, not source-image-based concept approval. Do not pretend planned registry image paths exist. This addendum does not supersede original scope or alter gameplay.
