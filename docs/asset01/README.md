# ASSET-01: isolated third-party intake

Draft review only. Base `af184380fb690f2c19bac69960b7aacce50f9ff2` (PR78), branch `codex/asset01-intake`. No production source, game settings, approved artwork, physics, saves, enemies, hazards or rooms change. The nested gallery is excluded from the main Godot scan with `.gdignore`; existing export exclusions already omit tools/docs.

Start with [COMPATIBILITY.md](COMPATIBILITY.md), [license evidence](LICENSES.md), [license inventory](license-status.csv), and [pack/sequence metadata](inventory/packs.json). Per-file JSONL shards contain hashes, canvas sizes, exact alpha counts and bounds; static sheets also contain candidate component rectangles. Components are not guaranteed authored sprite identities. The one real tile grid is Mossy's 7×7, 512px grid; DarkCave sheets are decorations, not a tile set.

## Run existing local review on this Mac

From this branch checkout:

```sh
./tools/asset01/launch.command
```

Godot 4.6.1 defaults to `/Applications/Godot.app`. Pass a staging directory as the launcher's first argument if needed. Keys 1–6 select the six pack galleries; Up/Down selects assets/sequences; Space pauses; Left/Right steps frames; F chooses 6/12/24/30 review FPS; N compares nearest/linear filtering; V decodes original resolution; comma/period browses individual atlas regions; +/- adjusts the candidate comparison scale; R resets; Esc exits. Full animation canvases keep source registration; component slices have no authored pivots.

The left panel fits the asset; the right compares an adjustable candidate scale with Kaze's unchanged approved idle first frame at its actual controller scale. Candidate scale starts 0.25. Playback rates are review assumptions because source timing metadata is absent. V can allocate a 64 MiB source atlas separately from the bounded 48 MiB cache; default previews downsample to 768px maximum solely for inspection. This is not a shipping importer or production performance benchmark.

## Recreate staging from supplied ZIPs

Originals live outside the tracked checkout. Do not commit or redistribute them. On a Mac with Command Line Tools:

```sh
python3 tools/asset01/stage.py --source /path/to/Packs --stage /absolute/local/asset01-staging
xcrun clang -O2 -fobjc-arc -framework Foundation -framework ImageIO -framework CoreGraphics tools/asset01/scan_images.m -o /tmp/asset01-scan
/tmp/asset01-scan /absolute/local/asset01-staging/extracted /absolute/local/asset01-staging/inventory-initial.json
python3 tools/asset01/finalize_inventory.py /absolute/local/asset01-staging/inventory-initial.json --out /absolute/local/audit-inventory
cp /absolute/local/audit-inventory/packs.json /absolute/local/asset01-staging/gallery.json
./tools/asset01/launch.command /absolute/local/asset01-staging
```

The staging tool verifies all six audited ZIP hashes, rejects unsafe archive paths/links/duplicates, and refuses to overwrite changed staged content. ImageIO reads image pixels; PSD/AEP source files are retained but never executed. The PSD header is identified; layer/editing fidelity and AE render dependencies require the relevant editors and remain untested.

## Verify

Use explicit absolute log files. The gallery check opens every image through Godot and compares metadata bounds, tests sequence wrapping, preview availability, region bounds and cache limits. No production save access is needed.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path tools/asset01/gallery --log-file /absolute/local/check.log --script res://check.gd -- --stage=/absolute/local/asset01-staging
python3 tools/verify_baseline.py
```

Native captures use the same gallery with `--capture=/absolute/local/captures` after `--`. They visit every sequence/atlas and record actual frame durations, cache use and renderer identity. Runtime capture images remain local due to asset redistribution restrictions. Raw textual evidence and exact commands are committed. Windows, mobile, shipping exports, mixed gameplay load and creator art acceptance remain untested.

## Adoption handoff

- Art Mane: choose specific asset/sequence IDs; review palette, line style, alpha fringes, filters, pivots and scale beside approved Kaze. Add missing combat and hazard timing poses rather than stretching the current loops.
- Level Masta: place approved visuals against existing colliders; run room placement/door/checkpoint/recovery safety probes. DarkCave silhouettes do not define new floors or collision. No room layout changes belong in this PR.
- Claude: retain source/license evidence, approve selected usage and contract consumers, then commission a separate placement/integration draft. Creator-attested permission authorizes isolated pilots for all six packs; DarkCave's independent source verification remains open, and all production placements require creator approval. No canonical faction, character, species identity, location or story event is established by these packs.

## Controlled pilot follow-up (2026-10-22)

See [CONTROLLED_PILOTS.md](CONTROLLED_PILOTS.md). The creator attestation is recorded separately from publisher verification in the license register. Curated selections open in the existing isolated gallery. Optional companion pilots open the existing EN-01/HAZ-01 labs in a separate pinned compliance checkout. They add presentation children only; no campaign placement or damage adapter is installed. Art acceptance and production integration remain separately reviewed next steps.

```sh
python3 tools/asset01/review_pilot.py --stage /absolute/local/asset01-staging --check
python3 tools/asset01/review_pilot.py --stage /absolute/local/asset01-staging --pilot FOL-01
```
