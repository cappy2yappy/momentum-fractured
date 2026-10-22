# KAZE ASSET-01 compatibility review

2026-10-22. Isolated branch `codex/asset01-intake`, base PR78 `af184380fb690f2c19bac69960b7aacce50f9ff2`. Review candidates only. No room placement, approved Kaze replacement, gameplay integration or merge.

## Findings

Six supplied archives contain 1,106 files: 1,102 PNGs, one JPG, two After Effects projects and one PSD. All 1,103 images decode in Godot 4.6.1. Every PNG has genuine transparent pixels and partial-alpha edges; none is an entirely opaque checkerboard image. The JPG is a static black square, not a transparent sprite. No embedded license, readme, animation-rate manifest, Godot resource, collision definition, audio, attack marker or pivot specification was supplied.

| Pack | Raster inventory | Preview entries | PNG canvas dimensions | Base-level RGBA estimate |
| --- | --- | --- | --- | --- |
| BlueWizard Animations.zip | 96 PNG | 6 sequences / 0 atlases | 512×512 | 96.00 MiB |
| CaveAssetsMaaot.zip | 5 PNG + 1 JPG | 0 sequences / 5 atlases | 1024×1024, 2048×1024, 2048×2048 | 61.00 MiB |
| Mossy Assets.zip | 6 PNG | 0 sequences / 6 atlases | 2048×2048, 2048×2948, 3584×3584, 4096×4096 | 232.03 MiB |
| Plant Animations.zip | 730 PNG | 13 sequences / 0 atlases | 512×512, 768×768 | 880.00 MiB |
| PlantsAnimated.zip | 205 PNG | 6 sequences / 0 atlases | 256×256, 256×512, 512×256, 1024×1024 | 227.50 MiB |
| Slimes.zip | 60 PNG | 2 sequences / 0 atlases | 376×256, 510×410 | 34.95 MiB |

Totals: 27 numbered animation sequences and 11 static PNG atlases (38 main views). Eleven atlas detail views bring the native capture set to 49. Alpha-region indexing yields 167 candidate connected components plus the 49 cells of Mossy's 7×7 tile grid. Components are not guaranteed separate authored sprites; disconnected pieces and merged silhouettes need Art Mane's slicing review. DarkCave is decoration art, not an authored tile map.

The PNG sequences have contiguous numbered files. Some contain byte-identical repeats: 1,103 raster files contain 1,030 unique file hashes. BlueWizard idle has 20 frames but 11 unique files; BlueFlower1 and Plant6 each have 60 frames but 31 unique files. Preserve sequence positions and holds when sharing identical textures. Removing duplicate timeline entries would change playback. Loop closure, source frame rates and intended transitions remain unverified; filename order is the sequence-order evidence.

### Editable sources

Only PlantsAnimated includes editable files: `Vegetation/Grass5/gr5.aep`, its separately hashed autosave under `Almacenamiento automático de Adobe After Effects`, and `Vegetation/Grass5/Plant4.psd`. The PSD has a valid version 1 RGB header, four channels, 8-bit depth and 1024×1024 canvas. No AE/Photoshop/Clip Studio editor project was opened or executed. Layer fidelity, AE version/plugins, external media dependencies and original composition FPS remain unverified. The other five archives provide raster output only.

## Suitability and recommended uses

| Pack | Art / scale judgment from native comparison | Candidate use | Adoption condition |
| --- | --- | --- | --- |
| BlueWizard Animations | Rounded, soft-painted, floating wizard silhouette differs strongly from Kaze's sharp character treatment; 512px canvases are much larger than gameplay display | Reference-only animation study; no Kaze substitution and no automatic new narrative character | Low priority. New identity/style approval and missing combat reactions would be needed |
| CaveAssetsMaaot | Dark organic rocks can support background depth; sheets need individual slicing and deliberate tint/contrast treatment | Selected background/foreground cave decoration in existing or future creator-approved rooms | Complete permission terms, Art Mane palette approval, Level Masta silhouette/collider alignment |
| Mossy Assets | Dark green/black forms complement organic areas, but painted edges and heavy silhouettes can overpower Kaze | Selected Root Conservatory/Root Shrine layers, roots, hanging plants and backdrop pieces; creator-approved future overgrowth | Preserve existing room collision; review occlusion/contrast and author runtime slices/gutters |
| Plant Animations | Broadest decorative motion set; small displayed silhouettes can fit organic rooms after scale review | Blue flowers and selected foliage for decorative environmental animation; poison/wind labels are only visual candidates for HAZ-01 | Establish loop rates, fixed pivots and readability. No damage semantics from filenames |
| PlantsAnimated | Useful grass/group movement, variable canvas aspect ratios; large Grass5 frames are memory-heavy | Secondary foliage/parallax and environmental motion | Complete permission terms; source-editor validation if modifying editable project; fixed registration |
| Slimes | Small ground silhouettes can fit below Kaze at about 0.25x source scale, but expressive soft faces create a tone/style mismatch | Conditional EN-01 visual prototype in an isolated arena | Art Mane approval plus explicit anticipation, attack, recovery, hurt/death treatment; no species/faction canon |

These are visual recommendations, not accepted placements or enemy implementations. No exact-byte duplicates match existing PNGs under the chosen base's `assets` directory. That comparison cannot establish that a transformed or repacked derivative is absent.

### EN-01 / HAZ-01 timing boundary

No pack supplies a complete combat-state contract. BlueWizard contains idle 20, walk 20, jump 8 and three 16-frame dash/effect directories. Slimes supplies two 30-frame blob sequences, without separate attack/hurt/death folders. Plant Animations supplies 13 sequences of 20–90 frames. PlantsAnimated supplies six sequences of 30–45 frames.

The gallery offers 6/12/24/30 FPS as explicit review assumptions. At 12 FPS, a 90-frame clip lasts 7.5 seconds; that is not an acceptable substitute for attack timing. Keep EN-01's at least 0.5s attack windup and safe activation rules, and HAZ-01's at least 0.6s warning plus active/recovery windows. Art Mane must identify or author suitable cues; gameplay code remains the timing owner. Static thorns or poison-looking foliage cannot silently become collision or damage volumes. Existing player damage, recovery floors, transitions and saves remain untouched.

## Performance and scale

Uncompressed RGBA8 base levels total **1,531.48  MiB**, excluding mipmaps, duplication, CPU images, scene overhead and driver allocations. Plant Animations alone is 880 MiB. Two 4096² Mossy sheets cost 64 MiB each; this is source authoring density, not an instruction to draw assets at 1:1 gameplay size.

Use only approved selections, trim transparent margins with fixed offsets, and build bounded runtime atlases/import settings after approval. Reuse identical textures while preserving frame timing; avoid preloading every clip. A uniform quarter-size derivative would reduce base pixel memory by 16× mathematically, but all-frame quarter-size output would still be roughly 95.72 MiB. That is an estimate, not a tested production optimization or permission to modify the source.

The local gallery uses a 48 MiB LRU cache and a 768px maximum preview dimension. V deliberately bypasses downsampling for original-resolution inspection; a 64 MiB atlas can then exist outside the cache. It does not imply a 48 MiB bound on all process/GPU/transient memory. Kaze's reference uses the unchanged first approved idle frame at controller scale 0.2649908807 and fixed baseline 591; candidate comparison starts at 0.25 and is adjustable. Sequence canvases remain registered; atlas component slices have no supplied pivot.

Native final run: Godot 4.6.1 official, Apple M4 OpenGL Compatibility. 49 captures; no missing files or GDScript errors. Cache peak **48.00 MiB**. Observed frame duration median **8.33 ms**, p95 **13.14 ms**. Texture memory reported at the end was **74.79 MiB**; this is not a GPU peak or process RSS measurement. 227 cold/path-cache decodes plus preview resizes consumed 2.398s cumulatively. These results cover one downsampled inspection view at a time, not full-resolution crowds, alpha-overdraw stress or the live game. Other hardware, shipping exports and room-level frame budgets remain untested.

## Rights and source provenance

See [LICENSES.md](LICENSES.md) and the per-pack [license-status inventory](license-status.csv). None of the six archives embeds terms. The [Mossy Cavern publisher page](https://maaot.itch.io/mossy-cavern) provides a custom V0.1 permission for its four named downloads, including an asset-redistribution restriction. The [DarkCave page](https://maaot.itch.io/2d-browncave-assets) lists the other two ZIPs; the [creator's commercial-use reply](https://itch.io/post/3597222) is useful evidence but incomplete terms. Do not infer a shared license solely from the same author or a free price.

Source association uses exact download names and matching rounded archive sizes, not publisher-provided byte hashes. SHA256 pins preserve the inspected local copies. For DarkCave/PlantsAnimated, obtain complete written terms before release adoption. Originals, editable projects, extracted rasters and preview PNGs remain local; the draft PR publishes metadata, tools and textual results only.

## Verification and handoff

- **2,533 headless assertions passed**: every image decoded, ImageIO/Godot bounds agreed, every main view resolved, sequence stepping wrapped, atlas coordinates stayed in bounds and cache limits held.
- **49 actual native captures** cover all 38 entries plus detail slices. Render logs contain zero GDScript/parse errors; source-path omissions are empty.
- Reproducible staging matched all six archive hashes and all 1,106 extracted-file hashes. The staging tool refuses changed files and rejects unsafe paths/links/duplicates.
- Approved baseline verifier passed with zero failures. The review adds files only under `tools/asset01` and `docs/asset01`; existing production files are byte-identical to the named base. Main project/export settings are unchanged; no third-party raster/source archive enters Git.
- Earlier metadata-coordinate and preview-render type errors were corrected before accepted runs. Superseded diagnostics remain in local work files and are not counted as passes.

Art Mane owns per-asset style, alpha, filtering, pivots and missing animation poses. Level Masta owns approved visual placement against existing collision, recovery/door/checkpoint safety and room-level performance probes. Claude owns adoption sequencing, source/license record acceptance and the separate integration draft. Creator markup and per-room/story approval remain required. This review establishes no new canonical identity, room or revelation. No merge is requested.
