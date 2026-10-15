"""Rebuild original technical boards; stdlib only, no production art edits."""
from pathlib import Path
import json, hashlib, struct, html

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/art/tr03'
OUT.mkdir(parents=True, exist_ok=True)

def write(name, text):
    (OUT / name).write_text(text, encoding='utf-8')

assets = []
for p in sorted((ROOT / 'assets/kaze/cleaned').glob('*.png')):
    data = p.read_bytes()
    w,h,depth,color = struct.unpack('>IIBB', data[16:26])
    assets.append(dict(path=p.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(data).hexdigest(), width=w,height=h, cells=8,cell_width=w//8,bit_depth=depth,color_type=color))
write('SOURCE_AUDIT.json',json.dumps({'base':'2b1ccec9e293a50ada9c11d3dc9751281db31cb1','assets':assets,'note':'PNG header/hash audit only; alpha-boundary pixel QA is a later production gate.'},indent=2)+'\n')

clips = [
    dict(id='depth_turn_enter',frames=8,fps=16,loop=False,keys=['side plant','head leads','shoulders rotate','hips follow','rear three-quarter','first depth step','second depth step','occluded hold']),
    dict(id='stair_up',frames=8,fps=12,loop=True,keys=['lower foot plant','lead knee lift','upper foot contact','weight transfer','trailing toe off','other knee lift','next contact','recover']),
    dict(id='stair_down',frames=8,fps=12,loop=True,keys=['upper plant','lower toe reach','lower contact','knee absorbs','weight settles','other toe reach','next contact','recover']),
    dict(id='walk_continue',frames=8,fps=10,loop=True,keys=['left contact','down','left passing','up','right contact','down','right passing','up']),
]
write('ANIMATION_CONTRACT.json',json.dumps(dict(status='PROPOSED_NOT_RUNTIME',cell=[320,724],pivot=[160,510],scale=0.33919279345239656,alpha='straight RGBA8',clips=clips,run_reuse=dict(path='assets/kaze/cleaned/kaze_run_strip.png',fps=12.5,pivot=[136,491],scale=0.3825780535911868),loading_seconds=0.65),indent=2)+'\n')

write('README.md', '''# TR-03 Lane B — review kit

Status: original storyboard/specification proposal, **not approved final animation**. No runtime files change.

- [Animation and integration contract](ANIMATION_BRIEF.md)
- [Architecture kit and pilot dressing plan](ARCHITECTURE.md)
- [Storyboard](STORYBOARDS.svg) and [architecture concepts](ARCHITECTURE.svg)
- [Actual existing sprite frame previews](CONTACT_SHEETS.html): open locally in a browser, preserves source pixels.
- [Machine-readable proposed clips](ANIMATION_CONTRACT.json) and [source hash audit](SOURCE_AUDIT.json)
- [PM handoff](../../agent_handoffs/TR03_LANE_B_PM_REPORT.md)

Authority: TR03_ALPHA061_EMBODIED_TRANSITIONS.md at 880718f51b761ffbe40fb028741135b58b00e5f1. Art base: 2b1ccec9e293a50ada9c11d3dc9751281db31cb1. TR-02 read-only comparison: e9a2d1ab0537f3f903c543b080451b3556961179. Biome proposals remain provisional. Rebuild boards with `python tools/tr03_art_specs.py`.
''')

write('ANIMATION_BRIEF.md', '''# Character audit and minimal production brief

## Observed and protected

All four active cleaned sheets were visually inspected at source resolution. Kaze has brown skin, long dark purple hair, a bright green hair ribbon/chest bow, purple jacket, dark pleated skirt and purple boots. Preserve apparent age, face, outfit, proportions and silhouette; no new weapon, emblem, costume or character identity. Rear views need creator review because they reveal previously unseen construction. Existing artwork is retained byte for byte.

| Asset | Existing status / use | New work |
| --- | --- | --- |
| cleaned idle | Active, eight 272×724 cells; fixed baseline 591; scale 0.2649908807267889 | Reference for face and upright proportion; do not animate walking by sliding idle |
| cleaned run | Active, eight 272×724 cells; baseline 491; scale 0.3825780535911868; 0.08 s/frame | Reuse for horizontal_run, preserve phase and ninja lean |
| cleaned combat | Active, eight 320×724 cells; baseline 498; scale 0.37875157200639 | Reference only; not a turning animation |
| cleaned traversal | Active, eight 320×724 cells; baseline 510; scale 0.33919279345239656 | Reference only; jump/crouch frames do not prove stair poses |
| depth_turn_enter | Absent | Eight new frames: side plant → head turn → shoulders → hips → rear 3/4 → two depth steps → occluded hold |
| stair_up / stair_down | Absent | Eight frames each, independently authored; descending is not reversed ascending |
| walk_continue | Absent | Eight new upright heel-to-toe walk frames; a slowed ninja run is not a walk |
| wind_fold | TR-02 expressive prototype | Preserve; no replacement sheet in this assignment |

Accepted here means previously active source, not a new quality acceptance. Combat/traversal visibly retain boundary fragments/cut source detail; do not silently repair them or copy detached fragments into new work. Prior integration documentation already flags incomplete source reconstruction.

## Proposed export and pivot contract

New strips: 2560×724 RGBA8 PNG, eight 320×724 cells, straight alpha, transparent background, no baked shadow, frame numbers, scenery or labels. Source coordinates have top-left origin. Ground reference **(160,510)** in every cell; preserve 12 transparent pixels around every visible limb/hair tip. Fixed scale 0.33919279345239656 is the traversal compatibility starting point, not an accepted size result. Fit the upright design to the existing idle's measured world height; do not normalize each frame independently. Compare idle→turn→stairs at camera zoom 1.0 before approving scale.

With centered Sprite2D use offset=(0,724/2−510)=(0,−148), position=(0,0), hframes=8. This maps the authored anchor to the parent origin. Do not apply this pivot/scale to existing strips. New naming: `kaze_tr03_<clip>_right_strip.png`; source `kaze_tr03_<clip>.aseprite`, layers guide/line/flat/shade/hair/accent. Keep guides hidden at export. Tags match contract IDs, frames numbered 0–7. Include per-tag durations and slices `ground`, `lead_foot`, `rear_foot`; export metadata with each final source. No .aseprite file is claimed in this spec delivery.

Right is the reference lateral direction. Left may mirror only after checking face, hair ribbon and costume asymmetry against approved art. Depth turn must be delivered for both approach sides when mirroring fails identity review; depth does not mean flip_v. Ascending and descending each need both lateral directions. Stair facing comes from endpoint metadata, never inferred from current sprite facing alone.

Godot 4.6.1 proposal: lossless compress/mode=0; mipmaps/generate=false; process/fix_alpha_border=true; process/premult_alpha=false; size_limit=0. Match the existing project texture filter initially and compare edges at zoom 1.0 before changing it. New resources must receive fresh Godot UIDs; do not copy existing .import files. AnimatedSprite2D/SpriteFrames or a dedicated presentation Sprite2D may consume metadata later; the current controller is Sprite2D with eight hframes. Nothing is installed by this document.

## Staging and timing for Level Masta Masta

All times are proposed **presentation** windows, not physics edits. The existing discrete 0.65 s loading clock remains intact; preparation begins before room-load request, only after the existing authorized interaction. Hidden room swap does not become streaming. Failed eligibility must not strand a staged pose. No user movement speed changes.

| Mode | Pre-load performance | 0.65 s load / arrival | Placeholder contract |
| --- | --- | --- | --- |
| depth_door | Eight frames ×62.5 ms =500 ms: planted side (0), look (1), shoulder turn (2), hip turn (3), rear 3/4 (4), depth step (5–6), hold (7). Visual path from threshold to authored inner marker; occlude behind near jamb | Start load only after occlusion; reveal reciprocal doorway arrival, then restore live sprite at authoritative spawn | Two side poses plus three-quarter silhouette diagram may stage a clearly labeled demo; do not claim genuine rear art or shrink a side sprite to fake a turn |
| stair_up | Two step contacts in one 8-frame loop at12 FPS, ~667 ms; visual feet track authored ascending treads | Fade while next landing is occluded; show destination settling contact on existing landing | Anchored entry/exit pose + clear fade; no fake complete staircase animation |
| stair_down | Same cadence, lower toe reaches then knee absorbs; independent drawing | Fade behind landing cheek/return wall; reveal lower landing contact | Same limited staging fallback |
| horizontal_walk | New10 FPS walk, preserve gait phase across edge; feet travel at actual approach displacement | Existing TR-02 safe carry only; match reciprocal ground line and direction | Label missing walk strip; retain current comparison rather than relabeling run as walk |
| horizontal_run | Reuse12.5 FPS run and current phase; no forced braking or speedup | Existing TR-02 safe carry and deterministic arrival | Existing run is available now |
| wind_fold | Keep approved exceptional energy | Existing special behavior and plain/reduced alternatives | No ordinary door/stair reuse |

For depth/stairs, only a presentation proxy follows art markers; collision body, save and authoritative destination remain Level-owned. Suppress duplicate visible player render while proxy is active, restore on cancellation/failure, and use existing transition guards. Do not add root motion to the controller. Arrival must never render inside a wall or beyond a collision lip.

Proposed metadata (design only): `presentation_mode`, `approach_side`, `threshold_anchor`, `inner_anchor`, `arrival_anchor`, `occlusion_polygon`, `step_contacts`, `asset_id`, `fallback_mode`. Coordinates are room-local world pixels; links/gates are existing endpoint IDs. Lane A must validate and map this schema to its real endpoint structure; no new door location is asserted.

Reduced motion: same readable plant/turn/contact, plain fade, no forced camera movement, spin, flash, shake or perspective pulse. Preserve original graphic/refined/plain comparisons. Stair staging may be longer than its final load, so PM should review added interaction latency before production.

## Production gates and schedule

1. This session: audit, technical storyboards, original architecture kit and machine-readable brief ready for Lane A placeholders.
2. After creator storyboard review: first produce depth turn key poses and one up/down contact pair; verify actual Kaze identity, scale and foot registration before inbetweens. One art iteration, not a promised date.
3. Next production pass: complete32 minimum new frames (8 turn +8 up +8 down +8 walk); up to64 if separately drawn left variants are required. Run reuses8 existing frames. Export editable Aseprite sources and PNG/JSON only after creator compatibility review.
4. Integration gate: Lane A implements isolated pilots and in-engine capture. Review 1280×720/zoom1.0, both directions and reduced motion. Final frame acceptance precedes any sprite replacement or merge.

Final art QA still required: decode all RGBA pixels; check every cell alpha bounds and 12px padding; no detached fragments; anchor overlay and floor-contact parity; no hair/boot clipping; frame count/duration parity; black/white/checker edges; idle-to-turn scale; gameplay-size readability, left/right and rear identity. This delivery has no finished new PNG animation and makes no final frame-boundary, in-engine or60 FPS claim.
''')

write('ARCHITECTURE.md', '''# Original entry and support kit

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
''')

def svg_head(title,h):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="1280" height="{h}" viewBox="0 0 1280 {h}"><rect width="1280" height="{h}" fill="#17232e"/><style>text{{font-family:Arial;fill:#edf0df}} .n{{font-size:16px}} .s{{font-size:13px;fill:#b9c9cc}} .line{{fill:none;stroke:#d9dccf;stroke-width:3}}</style><text x="28" y="38" font-size="25">{title}</text><text x="28" y="63" class="s">ORIGINAL TECHNICAL STORYBOARD — pose diagrams, not finished Kaze sprites — creator review pending</text>'

s=svg_head('KAZE / TR-03 / Embodied crossings',1020)
rows=[('DEPTH DOOR / 500ms preparation', ['Plant /0ms','Head + shoulders /125ms','Rear 3/4 /250ms','Depth step /375ms','Occlude /500ms']),('STAIR UP / contact-led', ['Plant','Knee rises','Upper contact','Push from toe','Landing behind wall']),('STAIR DOWN / independent poses',['Plant','Toe reaches','Lower contact','Knee absorbs','Landing reveal']),('HORIZONTAL / continuous intent',['Walk: upright','Walk: passing','Run: reuse phase','Occluded room swap','Resume same direction'])]
for r,(title,labels) in enumerate(rows):
    y=100+r*220
    s+=f'<text x="28" y="{y}" class="n">{title}</text>'
    for i,label in enumerate(labels):
        x=28+i*246; by=y+145
        s+=f'<rect x="{x}" y="{y+12}" width="230" height="170" rx="6" fill="#243643"/><text x="{x+10}" y="{y+170}" class="s">{html.escape(label)}</text>'
        if r==0:
            s+=f'<path d="M{x+138},{by} v-98 h63 v98 M{x+145},{by-8} l39,-15" class="line"/><rect x="{x+190}" y="{by-98}" width="11" height="98" fill="#61747a"/>'
        elif r in (1,2):
            pts=f'M{x+15},{by} h45 v-16 h40 v-16 h40 v-16 h55' if r==1 else f'M{x+15},{by-48} h45 v16 h40 v16 h40 v16 h55'
            s+=f'<path d="{pts}" class="line"/><path d="M{x+16},{by+7} L{x+195},{by+7} L{x+195},{by-40}" fill="#425862"/>'
        else:
            s+=f'<path d="M{x+12},{by} h205" class="line"/>'
        # Joint diagrams deliberately separate from final identity art.
        cx=x+75+(i*12 if r==0 else 0); fy=by-(i*7 if r==1 else 28-i*6 if r==2 else 0)
        tilt=14 if r==3 and i>=2 else 0
        s+=f'<circle cx="{cx+tilt}" cy="{fy-76}" r="10" fill="#a88667"/><path d="M{cx-9+tilt},{fy-65} L{cx+13},{fy-30} L{cx-10},{fy-30} Z" fill="#78589b"/><path d="M{cx-9+tilt},{fy-70} q-30,12 -24,45" fill="none" stroke="#473955" stroke-width="12"/><path d="M{cx-14+tilt},{fy-72} l-15,-6 7,14" fill="#7bbb62"/><path d="M{cx},{fy-32} l-16,28 m20,-28 l20,18 -8,12 M{cx+tilt},{fy-57} l25,17" fill="none" stroke="#ab94c3" stroke-width="6"/><path d="M{cx-5},{fy+5} h10 m-5,-5 v10" stroke="#e1b768" stroke-width="2"/>'
s+='<text x="28" y="1000" class="s">Gold cross: fixed foot anchor. Read order left to right. Load remains 0.65s after staging; silhouettes are schematic.</text></svg>'
write('STORYBOARDS.svg',s)

s=svg_head('KAZE / TR-03 / Architecture that carries weight',720)
names=['Depth threshold','Stairwell + landing','Culvert + retaining wall','Roof knee braces','Canal corbels','Terrain + roots']
for i,name in enumerate(names):
    x=28+(i%3)*416; y=100+(i//3)*300
    s+=f'<rect x="{x}" y="{y}" width="394" height="275" rx="8" fill="#243643"/><text x="{x+14}" y="{y+28}" class="n">{name}</text>'
    if i==0:
        s+=f'<path d="M{x+80},{y+230} v-160 h190 v160" fill="#111b24" stroke="#8c9185" stroke-width="18"/><path d="M{x+80},{y+230} l30,-26 h145 l15,26" fill="#61727a"/><rect x="{x+258}" y="{y+68}" width="22" height="163" fill="#a4a28c"/><text x="{x+15}" y="{y+258}" class="s">Near jamb / inner recess / foot markers</text>'
    elif i==1:
        s+=f'<path d="M{x+30},{y+230} h65 v-30 h65 v-30 h65 v-30 h120 v65 H{x+30} Z" fill="#5a7078" stroke="#c8d8d6" stroke-width="3"/><rect x="{x+305}" y="{y+65}" width="32" height="150" fill="#84908a"/><text x="{x+15}" y="{y+258}" class="s">Treads sit on cheek / return wall hides landing</text>'
    elif i==2:
        s+=f'<path d="M{x+55},{y+235} V{y+150} a140,100 0 0 1 280,0 v85 h-40 v-85 a100,65 0 0 0 -200,0 v85 Z" fill="#61747a" stroke="#a6b5ad" stroke-width="3"/><text x="{x+15}" y="{y+258}" class="s">Spring piers terminate in continuous wall</text>'
    elif i in (3,4):
        s+=f'<rect x="{x+30}" y="{y+95}" width="333" height="23" fill="#8b8b7e"/><rect x="{x+40}" y="{y+120}" width="30" height="118" fill="#42545d"/><rect x="{x+325}" y="{y+120}" width="30" height="118" fill="#42545d"/>'
        if i==3:
            s+=f'<path d="M{x+68},{y+211} L{x+165},{y+120} M{x+325},{y+211} L{x+230},{y+120}" stroke="#8c6245" stroke-width="16"/>'
        else:
            for q in (70,170,270):
                s+=f'<path d="M{x+q},{y+120} h55 l-15,28 h-40 Z" fill="#687e83"/>'
        s+=f'<text x="{x+15}" y="{y+258}" class="s">Existing top unchanged / support enters wall ribs</text>'
    else:
        s+=f'<path d="M{x+30},{y+105} h320 l-20,35 -50,5 -35,50 -70,20 -25,25 H{x+30} Z" fill="#60736c"/><path d="M{x+65},{y+125} q80,15 100,60 m-50,-35 q-15,45 -40,60 m90,-25 q60,20 80,-20" stroke="#806b54" stroke-width="9" fill="none"/><text x="{x+15}" y="{y+258}" class="s">Rock mass and roots meet earth; no false foothold</text>'
s+='<text x="28" y="705" class="s">Concept geometry only. Low-contrast backing at world scroll1.0; preserve all collider lips, jump space and anchor visibility.</text></svg>'
write('ARCHITECTURE.svg',s)

page='<!doctype html><meta charset="utf-8"><title>Kaze TR03 existing frame audit</title><style>body{background:#202834;color:#eee;font:16px Arial;margin:25px}.grid{display:flex;flex-wrap:wrap;gap:8px}.cell{width:160px;background:repeating-conic-gradient(#46505d 0 25%,#343c48 0 50%) 0/16px 16px}.frame{height:362px;background-repeat:no-repeat}h2{margin-top:30px}</style><h1>Existing Kaze frame previews</h1><p>Source references only. Original pixels unchanged. Half source size; not gameplay scale. Cells expose clipping and registration differences.</p>'
for a in assets:
    page+=f'<h2>{html.escape(Path(a["path"]).name)}</h2><div class="grid">'
    for i in range(8):
        cw=a['cell_width']/2
        page+=f'<div class="cell"><div class="frame" style="width:{cw}px;background-image:url(../../../{a["path"]});background-size:{a["width"]/2}px 362px;background-position:-{i*cw}px 0"></div>Frame {i}</div>'
    page+='</div>'
write('CONTACT_SHEETS.html',page)
print('Rebuilt TR03 review kit; production PNGs unchanged.')
