# Kaze skill security and Godot 4.6.1 evaluation

Date: 2026-10-15 America/New_York (2026-10-16 UTC). Decision: **restricted, manual pilot only**. No global skill installation, gameplay changes, engine migration, editor bridge, or merge.

## Scope and decision

Evaluated against [TR-04 PR #33](https://github.com/cappy2yappy/momentum-fractured/pull/33), confirmed open and draft at source commit `1835fcca272fd6a925b3d8ad4834fb225a6caef6`. The existing local `kaze-tr04` checkout was dirty and its HEAD differed; it was preserved. A separate `kaze-skill-eval` documentation checkout and disposable `skill-audit-run-v2` execution copy were used. Synced `sources/` files were untouched.

Selected pilot:

- **haxqer:** only `scripts/docs/api_lookup.py` and `scripts/debug/lint_project.py` under `skill/godot`. API lookup dynamically imports that exact sibling linter for rename suggestions, so both belong to the allowlist. Run with an explicit official 4.6.1 binary and a workspace cache. Do not use `--project` or implicit cached-engine fallback in this pilot.
- **awesome-gamedev-agent-skills:** only `skills/godot/godot-physics/SKILL.md` and its `references/bodies-and-queries.md`, as a manually reviewed reference. Apply its body/layer/mask/query review questions to existing TR-04 code and tests. No code snippets, layer numbers, interpolation settings, collision sizes, or controllers are copied into Kaze.

The two tools were executed and the physics reference was applied as a source-review checklist. This is a non-destructive compatibility/diagnostic benchmark, not an autonomous code-editing trial. The measured benefit is exact-version API verification and discovery of diagnostic limitations; productivity improvement is unmeasured.

## Immutable sources

| Repository | Evaluated commit | Decision |
| --- | --- | --- |
| [thedivergentai/Game-Dev-Agentic-Skills](https://github.com/thedivergentai/Game-Dev-Agentic-Skills/tree/002d004c50b865406e58b3ec86508adab926d7f4) | `002d004c50b865406e58b3ec86508adab926d7f4` | Defer; no bulk installation |
| [gamedev-skills/awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/tree/0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd) | `0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd` | Physics reference only |
| [haxqer/godot-skill](https://github.com/haxqer/godot-skill/tree/037c03e9858ae748bf66c010aeb9942dbe9b93d6) | `037c03e9858ae748bf66c010aeb9942dbe9b93d6` | Two tools only; lint advisory |
| [vl4dt/godot-skills](https://github.com/vl4dt/godot-skills/tree/1ae280d35f2cc3931d4d8eb63f4bac82d6acf4a0) | `1ae280d35f2cc3931d4d8eb63f4bac82d6acf4a0` | Reject current physics/animation pilot; bridge deferred |

[upstream-lock.json](upstream-lock.json) records canonical Git archive SHA-256 and size for every tracked upstream file. Archive generation explicitly disables `core.autocrlf`. [pilot-lock.json](pilot-lock.json) adds hashes of the actual selected checkout files and the engine executable. Canonical Markdown and Windows checkout Markdown may differ by line endings; both hashes are recorded. These pins identify reviewed material, not publisher authentication or a promise of future safety. Updating a pin requires a new diff review and benchmark.

## Review depth and threat model

All tracked files were inventoried and text sources scanned for process execution, overwrite/deletion, network/install indicators, and a narrow instruction-boundary pattern. Inventory includes 181/75/1/23 `SKILL.md` files respectively (including router/template definitions) and 2504/7/168/28 executable-source files, including samples and tests. This is **not** a manual line-by-line audit of all those executable sources.

Manual review focused on actual skill instructions, selected physics references, haxqer lookup/linter entrypoints and their execution/write/import paths, divergent builder/process/editor-staging helpers and physics samples, and vl4dt physics/animation instructions, hooks, scaffolder, bridge connector and file tools. [static-indicators.json](static-indicators.json) retains file/line indicators and aggregate counts. The network category includes ordinary documentation links; it is not an exfiltration count. Individual URL hits are omitted from the compact retained indicator list. Zero narrow instruction-boundary matches is not proof that a repository contains no prompt injection.

Upstream instructions were treated as untrusted review material. Their mandatory routing, template-copying, cache-wiping and edit instructions did not override Kaze preservation requirements. No installer, package manager, upstream setup hook, remote script, or bridge server was run. Fetching the repositories used network access; the selected analysis tools have no reviewed network client calls. No packet-capture or dependency vulnerability scan was executed.

Isolation used a disposable project copy, separate APPDATA/LOCALAPPDATA/HOME/XDG/TMP directories per command, explicit engine path, subprocess argument arrays, and timeouts. It was not a VM or an OS-level no-network security boundary. Only reviewed tools were executed, with their normal filesystem/process authority still present. No personal saves were read.

## Findings by repository

### haxqer: useful exact-version lookup; broad automation requires restrictions

[SKILL.md](https://github.com/haxqer/godot-skill/blob/037c03e9858ae748bf66c010aeb9942dbe9b93d6/skill/godot/SKILL.md) says its scripts/templates are verified on 4.7 and recommends copying templates, scene mutation, resource moves, smoke fuzzing, and a dispatcher that can execute supplied GDScript. Those capabilities are outside this pilot. Its 4.x compatibility wording does not certify every operation on 4.6.1. In particular, the advertised `CollisionShape2D.one_way_collision_direction` is absent in the installed 4.6.1 API.

[api_lookup.py](https://github.com/haxqer/godot-skill/blob/037c03e9858ae748bf66c010aeb9942dbe9b93d6/skill/godot/scripts/docs/api_lookup.py) invokes the supplied engine with argument lists for `--version` and `--doctool`, reads XML, and writes a versioned cache. Its optional project documentation path can load project scripts; excluded here. It dynamically executes the sibling linter module for rename suggestions. Without an explicit binary it may answer from the most recently modified cache; require the explicit binary and inspect reported version/notes. Cache integrity is not authenticated by the tool; use a dedicated trusted cache and refresh after engine replacement. The first attempt generated 4.6.1 XML; the corrected benchmark reused that cache with the same hashed engine.

[lint_project.py](https://github.com/haxqer/godot-skill/blob/037c03e9858ae748bf66c010aeb9942dbe9b93d6/skill/godot/scripts/debug/lint_project.py) uses Python standard-library file reads and static heuristics. Its reviewed CLI has no fix/write option or child-process launch. It skips addons by default and honors `.gdignore`, so a clean result cannot certify all project code. On Kaze it emitted **54 error-level input-action findings and 2 warnings**, exit 1. `scripts/world.gd:119-131` creates actions through `for action in keys` and `InputMap.add_action(action)`; the linter only resolves simpler static forms. The input findings are false positives for the normal main-scene initialization path, not instructions to recreate or rebind inputs. The two warnings refer to optional generated capture directories in tests. No fixes or suppressions were applied. **Do not make this linter a blocking Kaze gate.**

Other reviewed surfaces: `project/move_resource.py` rewrites paths and removes backup directories; `project/scaffold_project.py` authors a project; `debug/validate_project.py` invokes the dispatcher; `debug/run_project.py` launches/kills child processes; `export/serve_web.py` exposes a server. They were not executed or approved by this evaluation. Root license metadata: MIT; no upstream source is vendored in this PR.

### awesome-gamedev-agent-skills: smallest targeted reference

[godot-physics/SKILL.md](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd/skills/godot/godot-physics/SKILL.md) and [bodies-and-queries.md](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/blob/0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd/skills/godot/godot-physics/references/bodies-and-queries.md) contain reference prose/examples, with no scripts in that subtree. They distinguish blockers from Areas, layer identity from mask detection, RID exclusions, physics-step queries and refreshed raycasts. Those are a close fit for TR-04 diagnosis. The catalog targets 4.7; its router/version-support policy explicitly preserves existing project versions. The pilot does not load the whole router/catalog or migrate Kaze.

Limitations: example layer bits are illustrative and must not replace Kaze's actual assignments; one-way direction must be checked against actual shape orientation and behavior; the reference includes 3D/Jolt advice irrelevant to this 2D project. It does not fully cover TR-04 safe arrivals or all one-way edge cases. Core selected APIs were checked against installed 4.6.1, while project behavior was checked by existing tests. This is bounded compatibility evidence, not certification of every example. Root license metadata: Apache-2.0; references are linked, not copied. Its repository-wide publishing/asset scripts were not executed.

### thedivergentai: broad library and mutable editor workflows

[godot-2d-physics](https://github.com/thedivergentai/Game-Dev-Agentic-Skills/blob/002d004c50b865406e58b3ec86508adab926d7f4/skills/godot-2d-physics/SKILL.md) routes into many `.gd` samples and related skills. Some statements are too absolute: it claims CharacterBody2D defaults to collision layer zero, whereas the installed 4.6.1 inherited property defaults to **1** (see `api-positive.txt`). Its canonical `scripts/physics_queries.gd` demonstrates RID exclusions and physics queries but is not a drop-in Kaze component.

[godot-builder](https://github.com/thedivergentai/Game-Dev-Agentic-Skills/blob/002d004c50b865406e58b3ec86508adab926d7f4/skills/godot-builder/SKILL.md) includes cache deletion and UID/import mutation workflows. `scripts/base.py` defaults to a machine-specific `D:\Godot\Godot_v4.7...` binary and writes worker scripts into the selected project. `scripts/stop_project.py` forcibly terminates an arbitrary supplied PID, without establishing process ownership. `godot-agent-vision/scripts/stage_editor_bridge.py` removes/recreates staging/addon directories and edits `project.godot`; it also imports Pillow. None is necessary for this audit or safe to auto-run against the active project. No malicious intent is inferred from those administrative capabilities.

Defer wholesale installation and any animation/controller template adoption. A future single-file use needs individual API/behavior review, explicit paths and bounded writes. Root license metadata is LGPLv3; no source/templates were copied into Kaze. Distribution review remains pending if vendoring or shipping any upstream code is later proposed.

### vl4dt: concrete compatibility errors and unneeded bridge authority

[godot-physics/SKILL.md](https://github.com/vl4dt/godot-skills/blob/1ae280d35f2cc3931d4d8eb63f4bac82d6acf4a0/skills/godot-physics/SKILL.md) uses `get_world_3d().direct_space` (lines 72/272) rather than `direct_space_state`, lists `move_and_snap` and `move_teleport` (302-303), and describes `move_and_slide` returning `SlideFlags` (300). The installed CharacterBody2D API returns bool and lacks both listed methods. [godot-animation/SKILL.md](https://github.com/vl4dt/godot-skills/blob/1ae280d35f2cc3931d4d8eb63f4bac82d6acf4a0/skills/godot-animation/SKILL.md) uses `anim_tree.get("state_machine")` and `has_state` on the playback object; these examples need correction and independent tests before adoption. Animation examples were source-reviewed, not runtime-certified.

`.claude/settings.json` runs `bd prime` on SessionStart/PreCompact. `scripts/new-godot-project.sh` overwrites configuration, places `.gdignore` in assets, and emits a literal `${PROJECT_NAME}` inside a quoted heredoc. Importing that scaffolding would conflict with the established project.

The optional MCP bridge adds Node/npm dependencies, WebSocket editor access, file write/delete, script edits and project-setting mutation. `mcp-bridge/README.md` illustrates a 4.7+ editor. `src/index.ts` defaults to loopback but allows a supplied WebSocket URL; `godot-connector.ts` sends a handshake with no authentication material. In `src/tools/file-tools.ts`, file-write confirmation is description text; the handler directly forwards writes, and the delete handler directly forwards deletion. No client-side path confinement or confirmation enforcement was observed in those handlers. Server-side enforcement is unverified; this is an authority/enforcement gap requiring further review, not a demonstrated remote exploit. No bridge or package installation was performed. Root license metadata: MIT.

## Physics-reference application to TR-04

| Reference question | Reviewed project evidence | Executed evidence |
| --- | --- | --- |
| Blocker versus trigger, correct layer/mask roles | `scripts/world.gd`, `scripts/level_geometry.gd`, actual player collision setup; no layer reassignment | `level_geometry`: 78 passes per phase |
| One-way rise/catch and perimeter support | Existing landing rectangles, one-way shape use, stop/reapproach coverage; no tuning | Same geometry suite, including existing 19 landing allowlist |
| Safe arrival and immediate overlap | Existing implicit Terrace arrival and capsule overlap checks | Same geometry suite |
| Momentum and approved movement preserved | Controller retained byte-for-byte | `movement_momentum`: 53 passes per phase; preservation checks |
| Animation presentation and fallback boundaries | Existing sprite integration and ART04 fallback behavior; no new cycles | `sprite_integration`: 43; `art04_transitions`: 111 per phase |
| Save boundaries | Separate profiles and existing save-compatibility fixture | 11 passes per phase |

The physics reference supplies review questions; the established Kaze tests supply project-specific acceptance criteria. No new gameplay implementation was required.

## Results and limits

See [RESULTS.md](RESULTS.md) for executed commands, raw outputs, timings, initial harness failures and pending work. The corrected paired benchmark passed **296 behavioral assertions per phase, 592 total**, plus TR-03/TR-04 preservation checks (32 + 46 per phase) and baseline verifier exit 0. Both imports exited 0; the expected API-negative control exited 1. The advisory linter exited 1 with the findings above. The entire evaluation is therefore not described as an all-green tool run.

All **996 tracked source files** hashed before/after execution remained unchanged, including import sidecars. Documentation is the only published change. No controller, gameplay setting, sprite, scene, save schema, geometry or dependency was modified.

No new 1,240-assertion full TR-04 batch, native input fixture, Windows export/resource test, sustained FPS test, human campaign playtest, gamepad review, all-upstream execution audit, malware certification, dependency CVE scan, animation-cycle authoring or environment-art pass is claimed. Prior TR-04 results remain prior evidence. Automatic skill discovery/installation and any expanded tool authority remain outside the selected pilot.

Official API cross-checks: [CharacterBody2D, Godot 4.6](https://docs.godotengine.org/en/4.6/classes/class_characterbody2d.html) and [AnimationPlayer, Godot 4.6](https://docs.godotengine.org/en/4.6/classes/class_animationplayer.html). The installed 4.6.1 engine's generated XML is the precise patch-version authority used in this benchmark.
