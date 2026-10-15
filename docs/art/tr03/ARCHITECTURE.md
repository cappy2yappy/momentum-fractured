# Original entry and support kit

Design-only, side-view world plane; dimensions below are tunable art envelopes, not collision requests. Existing biome identity is concept direction, not new story canon. Muted support colors: village timber #8C6245/slate #44545C; canal stone #485E67/rust #94604B; district roof #202C3E/route edge #D9DCCF. Green stays available for Kaze/grapple cues. No neon requirement or new supernatural explanation.

| Module ID | Original construction and sightline | Reuse / attachment |
| --- | --- | --- |
| threshold_depth | Plaster/stone rear opening; 24px visible floor return; dark inner recess; separate near jamb hides depth steps. Opening must clear Kaze's measured silhouette, including hair | Back frame / sill / near jamb as separate layers; threshold and inner foot markers. Never imply an interactable door where endpoint metadata is absent |
| stair_landing | Three visible step contacts, side cheek beneath treads, structural slab and return wall. Upper landing visibly continues behind wall; lower landing has headroom and an unobscured exit | 32px horizontal /16px rise concept grid; tune to actual silhouette and geometry. One rise unit repeated, independent up/down character poses |
| culvert_ring | Segmental masonry arch with two spring piers into retaining wall; keystone shadow and wall thickness reveal passage depth | Crown / left spring / right spring / wall infill; preserve aperture and interaction sightline |
| roof_knee_brace | Timber or metal triangular knee brace fastened to wall rib beneath existing platform; roof fascia gives slab thickness | Left/right end caps +32px repeat beam + diagonal brace; do not draw an accessible-looking ladder |
| canal_corbel | Repeated masonry corbels seated in retaining wall, crossbeam under platform and softened wall backing | End pier +32px beam +32/64px corbel repeats; stop art at open jump/tether volume |
| terrain_root | Rock shelf attaches to contiguous retaining mass; roots wrap the underside and visibly terminate in soil | Low-contrast backing rock, separate roots, existing collision lip untouched; avoid bright fake footholds |

Foreground jamb/cheek may occlude only the controlled entry proxy inside its marked aperture. Supports behind live actors should be lower contrast than route lips and must not conceal enemies, grapple anchors or destination cues. Body-height clearance and headroom derive from measured sprite/collider bounds, not this board's schematic figure. Put supports at world scroll1.0; only distant skyline uses parallax. No collision nodes, navigation, hazard semantics or climbability implied. Every load path must visibly terminate in a wall, earth, column or roof frame; a diagonal hanging into empty space does not solve floating.

## Priority pilot plan (art evidence, not a complete room audit)

| Priority / room | Evidence reference | Proposed backing and constraint |
| --- | --- | --- |
| P0 R15 Lower Sluice | ../alpha061/previews/composition_R15.png,1280×720 art-study capture | Suspended central lip at screenshot x260–710,y290: seat corbels under its left/right ends into existing wall ribs. Lower right lip x860–1260,y510: two piers to canal retaining mass below. Screenshot coordinates are visual callouts, not world coordinates. Preserve all jump arcs and anchor at x1090,y230 |
| P0 R14 Bellroof Walk | ../alpha061/previews/composition_R14.png and TR-02 R14↔R17 control | Use roof knee braces/fascia and stair landing cheeks. Lane A must locate actual platform attachment points from its current scene; do not derive collisions from this older art study |
| P1 R15↔R16 culvert | TR-02 report at e9a2d1a, directional passage pilot | Arch ring and retaining-wall returns; no aperture narrowing, added gate, or endpoint relocation |
| P2 remaining rooms | Lane A current room screenshots/endpoint audit pending | Choose retaining mass, roof truss, bridge pier or wall bracket per biome. Do not stamp the same support everywhere; keep any currently ambiguous platform unchanged until its load path can be drawn credibly |

Maximum first implementation scope: one R15 corbel backing + one R14 brace backing. These are proposed pilots, not implemented art. Budget target: atlas/shared materials, no per-platform shader/light/particles, no new fullscreen pass. Count actual draw calls and measure draw times in Lane A; no performance certification here. Use far wall backing where a pier would falsely advertise collision.

Creator decisions: approve depth-turn silhouette/rear construction, stair dimensional language and support family choices. No decision on new traversal routes is requested or implied. Wind-fold remains exceptional and does not justify ordinary unsupported platforms automatically.
