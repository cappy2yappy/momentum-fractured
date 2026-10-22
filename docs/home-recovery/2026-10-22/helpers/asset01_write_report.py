from pathlib import Path
import json,shutil,html
root=Path(__file__).resolve().parent.parent;repo=root/'work/asset01';out=root/'outputs/asset01';inv=json.loads((repo/'docs/asset01/inventory/packs.json').read_text());perf=json.loads((out/'captures-final/performance.json').read_text())
rows=[]
for p in inv['packs']:
 dims=sorted(set((d[0],d[1]) for s in p['sequences'] for d in s['dimensions']))
 dimensions=', '.join(f'{w}×{h}' for w,h in dims)
 animated=sum(s['frame_count']>1 for s in p['sequences']);static=len(p['sequences'])-animated
 rows.append(f"| {p['name']} | {p['png_count']} PNG{' + 1 JPG' if p['image_count']>p['png_count'] else ''} | {animated} sequences / {static} atlases | {dimensions} | {p['decoded_rgba_bytes']/1048576:.2f} MiB |")
report='''# KAZE ASSET-01 compatibility review

2026-10-22. Isolated branch `codex/asset01-intake`, base PR78 `af184380fb690f2c19bac69960b7aacce50f9ff2`. Review candidates only. No room placement, approved Kaze replacement, gameplay integration or merge.

## Findings

Six supplied archives contain 1,106 files: 1,102 PNGs, one JPG, two After Effects projects and one PSD. All 1,103 images decode in Godot 4.6.1. Every PNG has genuine transparent pixels and partial-alpha edges; none is an entirely opaque checkerboard image. The JPG is a static black square, not a transparent sprite. No embedded license, readme, animation-rate manifest, Godot resource, collision definition, audio, attack marker or pivot specification was supplied.

| Pack | Raster inventory | Preview entries | PNG canvas dimensions | Base-level RGBA estimate |
| --- | --- | --- | --- | --- |
'''+ '\n'.join(rows)+'''

Totals: 27 numbered animation sequences and 11 static PNG atlases (38 main views). Eleven atlas detail views bring the native capture set to 49. Alpha-region indexing yields 167 candidate connected components plus the 49 cells of Mossy's 7×7 tile grid. Components are not guaranteed separate authored sprites; disconnected pieces and merged silhouettes need Art Mane's slicing review. DarkCave is decoration art, not an authored tile map.

The PNG sequences have contiguous numbered files. Some contain byte-identical repeats: 1,103 raster files contain 1,030 unique file hashes. BlueWizard idle has 20 frames but 11 unique files; BlueFlower1 and Plant6 each have 60 frames but 31 unique files. Preserve sequence positions and holds when sharing identical textures. Removing duplicate timeline entries would change playback. Loop closure, source frame rates and intended transitions remain unverified; filename order is the sequence-order evidence.

### Editable sources

Only PlantsAnimated includes editable files: `Vegetation/Grass5/gr5.aep`, its separately hashed autosave under `Almacenamiento automático de Adobe After Effects`, and `Vegetation/Grass5/Plant4.psd`. The PSD has a valid version1 RGB header, four channels, 8-bit depth and 1024×1024 canvas. No AE/Photoshop/Clip Studio editor project was opened or executed. Layer fidelity, AE version/plugins, external media dependencies and original composition FPS remain unverified. The other five archives provide raster output only.

## Suitability and recommended uses

| Pack | Art / scale judgment from native comparison | Candidate use | Adoption condition |
| --- | --- | --- | --- |
| BlueWizard Animations | Rounded, soft-painted, floating wizard silhouette differs strongly from Kaze's sharp character treatment; 512px canvases are much larger than gameplay display | Reference-only animation study; no Kaze substitution and no automatic new narrative character | Low priority. New identity/style approval and missing combat reactions would be needed |
| CaveAssetsMaaot | Dark organic rocks can support background depth; sheets need individual slicing and deliberate tint/contrast treatment | Selected background/foreground cave decoration in existing or future creator-approved rooms | Complete permission terms, Art Mane palette approval, Level Masta silhouette/collider alignment |
| Mossy Assets | Dark green/black forms complement organic areas, but painted edges and heavy silhouettes can overpower Kaze | Selected Root Conservatory/Root Shrine layers, roots, hanging plants and backdrop pieces; creator-approved future overgrowth | Preserve existing room collision; review occlusion/contrast and author runtime slices/gutters |
| Plant Animations | Broadest decorative motion set; small displayed silhouettes can fit organic rooms after scale review | Blue flowers and selected foliage for decorative environmental animation; poison/wind labels are only visual candidates for HAZ-01 | Establish loop rates, fixed pivots and readability. No damage semantics from filenames |
| PlantsAnimated | Useful grass/group movement, variable canvas aspect ratios; large Grass5 frames are memory-heavy | Secondary foliage/parallax and environmental motion | Complete permission terms; source-editor validation if modifying editable project; fixed registration |
| Slimes | Small ground silhouettes can fit below Kaze at about0.25x source scale, but expressive soft faces create a tone/style mismatch | Conditional EN-01 visual prototype in an isolated arena | Art Mane approval plus explicit anticipation, attack, recovery, hurt/death treatment; no species/faction canon |

These are visual recommendations, not accepted placements or enemy implementations. No exact-byte duplicates match existing PNGs under the chosen base's `assets` directory. That comparison cannot establish that a transformed or repacked derivative is absent.

### EN-01 / HAZ-01 timing boundary

No pack supplies a complete combat-state contract. BlueWizard contains idle20, walk20, jump8 and three16-frame dash/effect directories. Slimes supplies two30-frame blob sequences, without separate attack/hurt/death folders. Plant Animations supplies13 sequences of20–90 frames. PlantsAnimated supplies six sequences of30–45 frames.

The gallery offers6/12/24/30 FPS as explicit review assumptions. At12 FPS, a90-frame clip lasts7.5 seconds; that is not an acceptable substitute for attack timing. Keep EN-01's at-least0.5s attack windup and safe activation rules, and HAZ-01's at-least0.6s warning plus active/recovery windows. Art Mane must identify or author suitable cues; gameplay code remains the timing owner. Static thorns or poison-looking foliage cannot silently become collision or damage volumes. Existing player damage, recovery floors, transitions and saves remain untouched.

## Performance and scale

Uncompressed RGBA8 base levels total **1,531.48 MiB**, excluding mipmaps, duplication, CPU images, scene overhead and driver allocations. Plant Animations alone is880MiB. Two4096² Mossy sheets cost64MiB each; this is source authoring density, not an instruction to draw assets at1:1 gameplay size.

Use only approved selections, trim transparent margins with fixed offsets, and build bounded runtime atlases/import settings after approval. Reuse identical textures while preserving frame timing; avoid preloading every clip. A uniform quarter-size derivative would reduce base pixel memory by16× mathematically, but all-frame quarter-size output would still be roughly95.72MiB. That is an estimate, not a tested production optimization or permission to modify the source.

The local gallery uses a48MiB LRU cache and a768px maximum preview dimension. V deliberately bypasses downsampling for original-resolution inspection; a64MiB atlas can then exist outside the cache. It does not imply a48MiB bound on all process/GPU/transient memory. Kaze's reference uses the unchanged first approved idle frame at controller scale0.2649908807 and fixed baseline591; candidate comparison starts at0.25 and is adjustable. Sequence canvases remain registered; atlas component slices have no supplied pivot.

'''
report+=f'''Native final run: Godot4.6.1 official, AppleM4 OpenGL Compatibility.49 captures; no missing files or GDScript errors. Cache peak **{perf['cache_peak_bytes']/1048576:.2f}MiB**. Observed frame duration median **{perf['frame_dt_p50_ms']:.2f}ms**, p95 **{perf['frame_dt_p95_ms']:.2f}ms**. Texture memory reported at the end was **{perf['texture_memory_bytes']/1048576:.2f}MiB**; this is not a GPU peak or process RSS measurement.227 cold/path-cache decodes plus preview resizes consumed{perf['decode_usec']/1000000:.3f}s cumulatively. These results cover one downsampled inspection view at a time, not full-resolution crowds, alpha-overdraw stress or the live game. Other hardware, shipping exports and room-level frame budgets remain untested.

'''
report+='''## Rights and source provenance

See [LICENSES.md](LICENSES.md) and the per-pack [license-status inventory](license-status.csv). None of the six archives embeds terms. The [Mossy Cavern publisher page](https://maaot.itch.io/mossy-cavern) provides a custom V0.1 permission for its four named downloads, including an asset-redistribution restriction. The [DarkCave page](https://maaot.itch.io/2d-browncave-assets) lists the other two ZIPs; the [creator's commercial-use reply](https://itch.io/post/3597222) is useful evidence but incomplete terms. Do not infer a shared license solely from the same author or a free price.

Source association uses exact download names and matching rounded archive sizes, not publisher-provided byte hashes. SHA256 pins preserve the inspected local copies. For DarkCave/PlantsAnimated, obtain complete written terms before release adoption. Originals, editable projects, extracted rasters and preview PNGs remain local; the draft PR publishes metadata, tools and textual results only.

## Verification and handoff

- **2,533 headless assertions passed**: every image decoded, ImageIO/Godot bounds agreed, every main view resolved, sequence stepping wrapped, atlas coordinates stayed in bounds and cache limits held.
- **49 actual native captures** cover all38 entries plus detail slices. Render logs contain zero GDScript/parse errors; source-path omissions are empty.
- Reproducible staging matched all six archive hashes and all1,106 extracted-file hashes. The staging tool refuses changed files and rejects unsafe paths/links/duplicates.
- Approved baseline verifier passed with zero failures. The review adds files only under `tools/asset01` and `docs/asset01`; existing production files are byte-identical to the named base. Main project/export settings are unchanged; no third-party raster/source archive enters Git.
- Earlier metadata-coordinate and preview-render type errors were corrected before accepted runs. Superseded diagnostics remain in local work files and are not counted as passes.

Art Mane owns per-asset style, alpha, filtering, pivots and missing animation poses. Level Masta owns approved visual placement against existing collision, recovery/door/checkpoint safety and room-level performance probes. Claude owns adoption sequencing, source/license record acceptance and the separate integration draft. Creator markup and per-room/story approval remain required. This review establishes no new canonical identity, room or revelation. No merge is requested.
'''
for a,b in [('version1','version 1'),('about0.25x','about 0.25x'),('idle20','idle 20'),('walk20','walk 20'),('jump8','jump 8'),('three16','three 16'),('two30','two 30'),('supplies13','supplies 13'),('of20','of 20'),('of30','of 30'),('offers6','offers 6'),('At12','At 12'),('a90','a 90'),('lasts7.5','lasts 7.5'),('at-least0.5s','at least 0.5s'),('at-least0.6s','at least 0.6s'),('is880MiB','is 880 MiB'),('Two4096','Two 4096'),('cost64MiB','cost 64 MiB'),('at1:1','at 1:1'),('by16','by 16'),('roughly95.72MiB','roughly 95.72 MiB'),('a48MiB','a 48 MiB'),('a768px','a 768px'),('a64MiB','a 64 MiB'),('scale0.264','scale 0.264'),('baseline591','baseline 591'),('at0.25','at 0.25'),('Godot4.6.1','Godot 4.6.1'),('AppleM4','Apple M4'),('.49 ','. 49 '),('MiB**',' MiB**'),('ms**',' ms**'),('RSS measurement.227','RSS measurement. 227'),('consumed2','consumed 2'),('all38','all 38'),('all1,106','all 1,106')]:report=report.replace(a,b)
(repo/'docs/asset01/COMPATIBILITY.md').write_text(report)
(out/'COMPATIBILITY.md').write_text(report)
for n in ['LICENSES.md','license-status.json','license-status.csv','README.md']:
 shutil.copy(repo/'docs/asset01'/n,out/n)
shutil.copytree(repo/'docs/asset01/inventory',out/'inventory',dirs_exist_ok=True)
shutil.copytree(repo/'docs/asset01/evidence',out/'evidence',dirs_exist_ok=True)
# Capture browser stays local; no external services or fonts.
body=''.join(f'<figure><img loading="lazy" src="captures-final/{html.escape(Path(s["path"]).name)}"><figcaption>{html.escape(s["pack"]+" / "+s["asset"])} / region {s.get("region_index",-1)+1}</figcaption></figure>' for s in perf['samples'])
(out/'PREVIEWS.html').write_text('<!doctype html><meta charset="utf-8"><title>Kaze ASSET-01 local native captures</title><style>body{background:#111a24;color:#e2e8f0;font:16px system-ui;margin:30px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(520px,1fr));gap:24px}figure{margin:0}img{width:100%;border:1px solid #405269}figcaption{padding:10px}a{color:#92c5ff}</style><h1>ASSET-01 native review captures</h1><p>49 actual Godot 4.6.1 native views. Local review only; assets are not approved for production adoption.</p><p><a href="COMPATIBILITY.md">Compatibility report</a> · <a href="license-status.csv">License inventory</a></p><main>'+body+'</main>')
print('Compatibility report, license inventory and local preview index written.')
