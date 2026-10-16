# BUILD-05 Mac candidate controls

This workflow checks out gameplay at PR39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`
separately from its reviewed build controls. The source includes PR37 geometry and
TR05 runtime `f168339a6fa6b02f16958ce250636dbe47d4a783`; it is not main or an
unreviewed merge. The controls branch and draft PR are only for build/review.

`build05-macos.yml` runs on changes to these controls in the draft PR targeting
`feature/alpha-0.6.1-tr05-pr37`. Its manual entry is available only once that workflow
exists on the repository default branch; this delivery uses a real PR execution.
The native Intel runner uses official Godot 4.6.1 Universal with SHA-512 checked
editor/templates, disposable saves, bounded subprocesses and read-only GitHub
permissions. No secrets or publishing/merge permissions are needed.

`candidate.py` runs all 25 inherited source suites (the four historical presentation
suites explicitly use `--tr05-legacy`), baseline and PR37 preservation checks. It
exports unchanged Universal presets, recovers the six reviewed TR05 seeded fixture
definitions, adds six resettable Mac demo launchers and one persistent Fresh
launcher, then packages with `ditto` to preserve executable bits. No profiles ship.

Acceptance re-extracts the final ZIP into a directory containing spaces, audits
PCK entry MD5s/world data/forbidden files and both Mach-O architectures, boots the
release binary and all seven real launchers, then mounts the exact exported PCK
into the matching native editor for scripted gameplay QA. Source test harnesses
remain outside the distribution. The native 54-check input fixture
covers Canal, reciprocal R13, stop/reverse, held-E safety and both stair directions.
Hosted Intel runs headlessly and skips screenshot waits only: a prior rendered
fixture timed out on that runner. Local Apple Silicon validation uses graphical
captures and a real graphical release launch. Six additional mounted-pack suites cover Bellroof paths/geometry, momentum, save
compatibility and progression. The geometry audit's output path alone is adapted
to an absolute disposable directory because mounted `res://` is read-only.
This proves exported resources under the matching engine; graphical input checks
use the editor harness, while release executable checks prove startup/launchers.
It does not certify a human campaign or sustained FPS.

Recheck a downloaded inner ZIP on a Mac with Godot 4.6.1 and a settled source
checkout at the pinned SHA:

```
BUILD05_SOURCE_ROOT=/absolute/source python3 /absolute/controls/tools/build05/candidate.py --godot /Applications/Godot.app/Contents/MacOS/Godot --verify-only
```

Place the inner ZIP at `source/build/build05/Kaze-BUILD05-macOS-Universal-5dfc4c4f.zip`.
Read `MANIFEST.json`, `QA_RESULTS.json`, and the separate evidence artifact for
exact hashes and raw results. Never substitute an earlier package using the same
candidate label. Stair gait remains unfinished; approved held poses move through
space and the game labels the study accordingly. The app is unsigned/unnotarized.
