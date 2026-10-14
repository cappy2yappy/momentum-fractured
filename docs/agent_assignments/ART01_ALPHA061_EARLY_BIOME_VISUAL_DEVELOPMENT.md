# KAZE ALPHA 0.6.1 — THE ART MANE: EARLY BIOME VISUAL DEVELOPMENT

**Assignment ID:** ART-01-0061  
**Agent:** The Art Mane  
**Issued by:** Project Management (PM-01)  
**Repository:** https://github.com/cappy2yappy/momentum-fractured  
**Engine:** Godot 4.6.1  
**Work-order publication branch:** `docs/pm-art01-alpha-0.6.1-biome-order`  
**Source reference:** `integration/alpha-0.6-world-momentum` (historical baseline `34be304`; verify current remote)  
**Agent work branch:** `art/alpha-0.6.1-biome-visual-development` (create if absent, check before modifying)  
**Reviews required:** PM, creator, Level Masta Masta, Story Agent  
**Milestone:** Alpha 0.6.1 visual direction and asset-ready specifications. **NOT** authorization to replace in-game environments wholesale or merge to integration.

## 1. Mission

Develop cohesive and actionable visual identities for Kaze's earliest world environments. The creator supplied **two primary aesthetic references** in the PM conversation:

- **Reference 1 / city:** an anime-inspired moody, neon nighttime city image, deep blue and violet urban skyline, glowing windows and reflective waterways, layered rooftops and mystery. Use for the **City / Silent District** design language.
- **Reference 2 / village:** a warm daylight Japanese mountain village/country-town image with green hills and fields, intimate houses, natural pathways and inhabited tranquility. Use for **Hidden Village**, the playable **prologue** location before the attack.

**Reference images are not stored in this work-order file. Do not claim to have seen them merely from the descriptions.** Search the current project attachments for exact creator-uploaded reference images first. If inaccessible, acknowledge it, use these textual descriptions for provisional exploration, and request the two images directly from the creator before final aesthetic approval. Do not substitute unrelated web images as creator references.

The creator has floated an additional connective idea: after the village's destruction, Kaze awakens in **Ruins / edge-of-city** which transitions toward the established Silent District. This is a **working design hypothesis**, not locked story or geography. The Story Agent and creator own final canon.

## 2. Approved visual pillars and narrative framing

### A. Hidden Village — playable prologue
- Tonal role: lived-in warmth, safety, human scale, greenery, sunlight, family and daily life before tragedy.
- Layer concepts: distant mountain/forest horizon; middle-distance village roofline, terraced fields and lanes; close playable homes, paths, low stone walls, vegetation; foreground foliage.
- Provide a **peaceful state** and **destroyed/aftermath direction** using the same recognizable landmarks, so destruction means something to the player. Do not assume precise attack staging or dialogue.
- The ninja refuge should feel plausibly concealed yet part of a modern fictional Japan, not purely feudal fantasy.

### B. Ruins / Awakening — provisional transition
- Tonal role: disorientation, loss, abandoned architecture, moss/stone/shrine traces and gradual hints of industrial/urban infrastructure.
- Design a visual **bridge language** connecting warm village motifs to the colder city rather than inventing an unrelated aesthetic.
- Could be old sanctuary remnants, collapsed transit approach, or a border zone, but keep alternative interpretations open. Do not cement location, timeline, mechanism of escape, or amnesia.

### C. City / Silent District — existing early main-game biome
- Tonal role: dark metropolitan mystery; nighttime blue/violet shadows, restrained neon and signage, rooftops, drainage channels, industrial edges, reflections and ArcuTech presence.
- Preserve strong gameplay silhouette contrast; avoid overwhelming visual effects that obscure platforms, enemies, gates, grapple anchors, or exits.
- Urban art should fit the *existing* 21-room game's topology rather than requiring a whole map replacement.

### Existing world continuity
- Check the real repo's current background assets, tile usage, room dimensions, camera zoom, player sprite scale, visual effects and room presentation, including new Level Masta Masta work in PR #9.
- Room references to address: R14 Bellroof Walk (roof skyline), R15 Lower Sluice (retaining walls, pipes, wet/dry layers), R17 Counterweight Spire (shaft/cable layers), R19 Coil Service Hall (coil banks, conduits).
- Integration candidate INT-01-0061 is being built separately. **Do not edit shared scripts/world.gd, scripts/world_expansion.gd, player controllers, navigation topology, hitboxes, gates, or gameplay systems.**

## 3. Phase 1 — Source & references audit

1. Retrieve this exact work order from GitHub, and acknowledge assignment ID, goals and reference-image availability.
2. Fetch and review current integration refs, existing approved Kaze sprite/size, world backgrounds, visual documentation, PR #9 (level presentation), PR #8 (gameplay), and Story Agent's canon documents where relevant.
3. Create your own work branch. No merges into shared integration branch.
4. Inventory what existing art can be reused, what must be redrawn, what needs Level Design dimensions or Story clarification.
5. Extract visual requirements from the repo rather than guessing final tile dimensions or native render scale.

## 4. Phase 2 — Required outputs

**Deliverable A: Early biome visual bible** at `docs/art/alpha061/EARLY_BIOME_VISUAL_BIBLE.md`. It must contain, for each of the three environments:
- Narrative/atmospheric intent, palette suggestions (with HEX values), lighting logic and chromatic contrast.
- Distinguishable skyline/architecture/material shapes and motifs; landmarks and environmental storytelling cues.
- Background/midground/gameplay/foreground layer rules; parallax movement guidance and platform legibility.
- Safe effects guidelines (fog, reflections, haze, signage), no UI/hazard/exit visibility regression.
- Asset priority and reuse plan, with placeholders clearly marked.
- Differences between **prologue village intact and attacked/aftermath states**.

**Deliverable B: Concept boards/mockups**, at least one annotated composition per biome, plus optional village destruction variant. Prefer usable PNG previews. Concept images are review assets, not final tilemaps. State explicitly if creation tools are unavailable instead of inventing produced files.

**Deliverable C: Concrete production specification** at `docs/art/alpha061/BIOME_ASSET_SPEC.md`:
- Exact canvas, logical resolution, scales, sprite anchoring and tiling/parallax needs **derived from repository inspection**, not assumed;
- Named source formats (editable working sources, ideally compatible with Aseprite; PhotoCraft/VectorCraft if available), export PNG specifications, transparency, layer ordering and naming;
- Alpha-safe pixel boundaries, repeat/tile seam checks, zoom/readability tests, simple runtime texture budget/performance considerations.
- A clear handoff list for Level Masta Masta, organized by specific existing rooms before new prologue layouts.

**Deliverable D: implementation-ready first slice**, if within tool capability: a restrained reusable urban skyline layer or roof silhouette, a ruins backdrop motif, and a village background composition, WITHOUT modifying gameplay scene code. Commit preview and source artifacts where possible. If tool limitations prevent image editing, documentation plus annotated spec and honest limitations count as a **partial handoff**, not a finished art production pass.

## 5. Creative constraints

- Kaze is an anime-directed 2D Metroidvania. Do not force an 8-bit/pixelated aesthetic if existing sprite assets demand illustrated detail.
- Art should complement creator-provided references, not duplicate them without usage rights or extrapolate specific copyrighted elements.
- No redesign of Kaze or other approved characters under this assignment.
- Preserve current gameplay readability, approved character scale/pivots, attack visibility, grapple anchor clarity, gates, exit interactions and intended 60 FPS budget.
- Do not treat "prologue → ruins → city" as a verified contiguous room connection. PM + Story Agent must approve geographic and chronological sequence.
- All new final assets and licenses/provenance must be explicitly documented; no uncredited ripped commercial game graphics.
- Aseprite and ArtCraft are tools available on the creator's **Windows PC**, not automatically on an agent's Mac/cloud environment. Verify actual executable access before using or claiming it.

## 6. QA and design checkpoints

- Verify image file sizes, alpha formats, consistent artwork dimensions and source files.
- Check at actual in-game zoom, using screenshot/mockups and contrasting active entities against backgrounds where supported.
- Verify seamless repeated panels or explicitly label non-tileable compositions.
- Seek cross-agent feedback: Story for canon, LD for room scale/anchor/exits and PM for aesthetic approval.
- Provide comparison examples or placement mockups for R14/R15/R17/R19 where possible.
- Do not claim FPS measurements without actual in-engine timing.

## 7. GitHub publication

Commit and push only to `art/alpha-0.6.1-biome-visual-development`. Publish documents, images if generated, a manifest with asset paths and source/licensing details, and `docs/agent_handoffs/ART01_ALPHA061_PM_RETURN.md`.

If possible, open a **draft** review PR against `integration/alpha-0.6-world-momentum`. Do not merge or alter PR #8/#9. If files cannot be published, say exactly why, list what is available locally and do not claim a push.

Keep creator-provided aesthetic image references separate from new licensed game-ready assets unless explicit redistribution permission is given.

## 8. Required final Project Management report

Conclude with **KAZE — PROJECT MANAGEMENT RETURN REPORT**, ID `ART-01-0061`, and:
A. Executive summary and aesthetic proposal  
B. Source and creator-reference audit (clearly identify inaccessible images)  
C. Per-biome visual identities and palette/layering  
D. Created artifacts with exact filenames, sizes, formats, licenses/provenance  
E. Room-specific needs for R14/R15/R17/R19  
F. Art QA and Godot-readability evidence (actual tests vs untested)  
G. GitHub branch, commit, draft PR and published links  
H. Risks, dependencies and questions for Level Masta Masta / Story  
I. Creator approvals and PM decisions required  
J. Next production iteration  
K. Final verdict: **READY FOR PM REVIEW**, **PARTIAL HANDOFF — CONTINUATION REQUIRED**, or **BLOCKED — PM DECISION REQUIRED**.

The user will send the published handoff report back to **Project Management**. Do not mark artwork as approved or merged before PM and creator review.
