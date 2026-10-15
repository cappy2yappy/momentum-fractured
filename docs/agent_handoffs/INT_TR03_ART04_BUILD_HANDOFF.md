# INT-TR03 / ART-04 — Build Shogun packaging handoff

Integration passed local source/native fixture QA on macOS. Package this review comparison without merging into PR27, shared integration or main.

- Branch: `integration/int-tr03-art04-production`.
- Runtime/art checkpoint: **`e91e49caeada21baad5ab25e5080e67ab16a4094`**. Later evidence/report commits are documentation only. Base PR27 `c2c002267c58e991966c0eebf7e098c6e7fff769`; selective ART04 PR30 assets `a6b76b9938825307bdcd4efb687c7198ea0d8681`.
- Godot4.6.1 official. Existing Windows Desktop x86_64/embedded-PCK and macOS universal presets remain byte-identical to PR27. Reuse BUILD03/CI02 infrastructure; do not restart the build pipeline or copy older gameplay.
- Local full29-action batch:1,158 PASS checks;21 behavioral suites; zero assertion failures/script/parser errors. Five CLI profiles21 passes; native20/20 transition fixtures. Exact evidence: `docs/int_tr03_art04/evidence/REGRESSION_RESULTS.json` and README.
- Required modes: original, refined, art-preview, reduced, plain. Original/refined remain original comparison code; art-preview is opt-in. Four ART04 held keys are explicitly not complete cycles. Unsupported outward/arrival facings fall back to labelled approved idle. No movement/save changes.
- Native1280×720/zoom1 screenshots and unpaced Apple M4 render samples committed under `docs/int_tr03_art04/evidence`.

## Package commands

Export Windows with existing `Windows Desktop` preset to an ignored output path. Export macOS with existing `macOS` preset to an ignored ZIP. Then:

```sh
python3 tools/package_int_tr03_art04.py --platform windows --input build/int-tr03/windows/Kaze-INT-TR03-ART04.exe --source-sha e91e49caeada21baad5ab25e5080e67ab16a4094
python3 tools/package_int_tr03_art04.py --platform macos --input build/int-tr03/macos/export.zip --source-sha e91e49caeada21baad5ab25e5080e67ab16a4094
```

The macOS packaging path uses `ditto` and must run on macOS. The package tool uses Python stdlib only. It writes nine fixture/fresh pilots ×five comparison launchers, explicit absolute isolated save paths, README/source and per-platform manifests. It rejects a staging directory containing profiles; do not include saves in upload artifacts. Windows PowerShell launchers quote the entire path-bearing argument. Validate actual Windows launcher execution with package directories containing spaces. macOS .command files forward engine args before `--` so bounded boot testing can append `--headless --quit-after 180`.

Audit ZIP CRC, SHA-256/size, actual ART04 resources inside PCK, excluded build/test/doc/tool/source_art entries, packaged native startup and cleanup. Distinguish Windows cross-export or pack boot on another OS from native Windows execution. Include exact source/workflow/artifact IDs and expiration/download links. No public production release, no merges, and no claims of human feel/full-cycle art or sustained60FPS acceptance.

Creator should start `Play-stair-up-art-preview`, compare refined/original, then stair-down/depth/reverse-depth/reduced/plain. Targeted launchers seed abilities only once as QA fixtures; `Play-fresh-*` starts unseeded Haven. Direct EXE/.app launch uses historical normal saves and requires a deliberate backup/existing-save test.
