# Recovery Report — 2026-10-12

## Evidence and preservation

| Checkout | Initial HEAD | Working tree | Conclusion |
|---|---|---|---|
| `~/Documents/Playground/momentum-fractured` | 1d062bb7791c0400611d19b1c299071b7336fe4b | No tracked edits; seven old headless logs, .tmphome, nested clone untracked | Newest local development, March 23 |
| nested `momentum-fractured/momentum-fractured` | e4b0a86 | Clean independent Git clone | Older March 14 history |

Before edits, archived both checkouts including Git objects, reflogs, ignored/imported files and untracked logs:
`../recovery-archives/2026-10-12/local-checkouts-before-recovery.tar.gz`.
SHA-256: `6ac677922266a470844a4bc1fcc038207fe5fedd456e1da0400b7378fe8b0d9d`.
`git bundle verify ../recovery-archives/2026-10-12/all-local-history.bundle` succeeded and reported complete history.
`git fsck --full --no-reflogs` found stash commit d73650fc00f16abf3866560059edd25b0be6bcf7 and two dangling trees (b62297cf…, dab76197…). These objects remain in the full filesystem archive. The stash's two documentation files are already content-identical to local main; it is retained rather than reapplied.

Preservation refs: `recovery/preserved-local-2026-10-12` (1d062bb), `recovery/preserved-stash-2026-10-12` (d73650f), and published `codex/recovery-alpha-2026-10-12` (1d062bb).
Original main and existing GitHub development branches were not overwritten or merged.

## Requested commits

All five were verified with `git cat-file -t` and inspected using `git show`:

| Commit | Actual subject | Recovery decision |
|---|---|---|
| 8f5d34b | Add room 2 platforming challenge | Already ancestral to the latest parity branch; subsequent changes retained |
| 261b0a8 | Add room 3 mixed combat platforming room | Preserved in history; no duplicate cherry-pick |
| f5d4e9d | Add room 4 checkpoint safe room | Preserved; current reciprocal Room 3/5 topology preferred |
| f4f4b9d | Fix singleton access for headless script compilation | Preserved; defensive checks selectively recovered |
| d53b997 | Add playable room JSON import workflow | Latest importer is evolved; original remains recoverable |

## GitHub comparison

Fetched all branch heads over HTTPS:

| Branch | SHA | Evidence / role |
|---|---|---|
| main | 1a33d283a3781ba7068f86b43d4197f28f063939 | March status baseline |
| codex/alpha-0.5-baseline | fc6acea51e67ec23ec6bf0a748e247ab528549e7 | Separate isolated rebuild; universal macOS export and texture import work |
| codex/web-parity-restoration | 398c772c3f82a96b2650878ea1af651bfa3a1294 | Authored Threshold/Fire Reliquary; descendant of main |
| codex/parity-validation-2026-09-30 | 2ec0a1dbf59adb854e87afbe76c84fb8cbfc1c6b | Newest: authored canal and controlled swimming; descendant of web parity |
| codex/phase-sweep-2026-03-23 | 1d062bb7791c0400611d19b1c299071b7336fe4b | Already contains the newer outer local history |

The three nominated branches were compared with `git diff --stat`, logs and individual script diffs. September 30 incorporates the web branch and already has universal macOS/Windows presets and Apple Silicon texture import. Alpha 0.5's separate rebuild is retained in its original branch, not pasted over the newer game.

## Improvements absent from September baseline

Compatible: bb10664 damage-number world-to-viewport transform and defensive Hurtbox/Checkpoint singleton access; 9436dc3 audio stop/stream cleanup on exit. Port selectively, preserving Guard Veil and current topology, with new regression checks.

Preserved but deferred: legacy Guardian shield/anger behavior, three-phase Echo Amalgam, tutorial popup/persistence, victory stats and older Rooms 5–12. Their scenes target removed legacy rooms and use superseded AbilityManager/progression. Echo Amalgam needs deferred physics mutations and cleanup/registration of summoned adds. Tutorial timing needs serialized dismissal and GameState schema support. Wholesale integration would regress current movement, map, water, gates and reciprocal spawns.

Active development uses a separate Git worktree based on 2ec0a1d at `../momentum-fractured-recovery`, on `codex/alpha-recovery-2026-10-12`. The desktop managed-worktree tool could not create it because the chat root is not a Git repository; the Git CLI created the worktree successfully. Original folders are retained.

## Authentication and publication evidence

Configured origin is `git@github.com:cappy2yappy/momentum-fractured.git`; nested clone uses the equivalent HTTPS URL. GitHub connector authenticated as cappy2yappy. SSH check with BatchMode/10-second connection timeout failed on port 22. Existing supported HTTPS/keychain authentication succeeded without requesting credentials.

Published local history and stash with normal `git push https://github.com/cappy2yappy/momentum-fractured.git …` (no force). Independent `git ls-remote` confirmed 1d062bb on codex/recovery-alpha-2026-10-12 and d73650f on recovery/preserved-stash-2026-10-12. Active build publication is recorded after tested increments below.

## Web benchmark

Direct browser inspection of https://rush-line.thacap.chatgpt.site succeeded after the session loaded. Observed Lantern Haven, Alpha 0.3.2, green/purple Kaze, three hearts, area map, E lantern/save interaction, double-tap run, F parry, Q tether after unlock and Shift/right-click dash after unlock. Godot's current base-kit and F-kunai choices differ. This is documented as unresolved parity work; the canonical web game remains the reference. No subjective feel or all-room web acceptance is claimed.

## Stability increment evidence

All five runtime suites passed in `validation/2026-10-12/stability/results.json`. The new recovery suite passed 43 checks including physical melee damage/immunity, per-window target tracking, camera transform, checkpoint save/load and actual scene respawn, detached helper guards, and audio teardown. Initial regressions demonstrated repeated per-window damage, an Echo death physics mutation error, and default-spawn checkpoint restoration; fixed and rerun.

The sandboxed re-import exited 0 but failed the strict runner due to denied writes to normal Godot editor settings/ObjectDB snapshot paths. It is recorded as **failed**, not passed; the engine import is being rerun with filesystem access. Baseline asset import had succeeded in an isolated application directory. Certificate and ObjectDB teardown warnings remain documented.

Godot re-import with normal filesystem access succeeded (exit 0), with no script/resource/editor-setting errors: `validation/2026-10-12/stability/import-unsandboxed.log`. The initial sandbox failure remains retained in the strict results file.

Published stability increment: `84060d213ecf01d697b73c46c0aafc59484cc007` on `codex/alpha-recovery-2026-10-12`; normal HTTPS push succeeded and independent git ls-remote returned the same full SHA.

## Verified development continuation

Implemented the roadmap's authored Fire-Sealed Return in Room 9 without replacing current campaign progression. Added persisted opened_gates state, projectile detection shapes (the old generated seal lacked one), matching-element impact, gate-aware door lock and map rendering. Added real collision/input/persistence/death/transition regressions. Fixed overlapping UI pause ownership, including combat hit-pause expiry. All seven runtime suites and fresh import passed; logs are versioned. Export settings and native platform CI are being prepared for verified playtest builds, not an accepted Alpha release.

GitHub refused continuation84f82ee because the OAuth credential lacks workflow scope. Existing key authentication on supported SSH443 also failed. Full local development branch is preserved; source publication uses a new branch from84060d2, with the workflow proposal saved in docs/ci/parity-playtest-build.proposed.yml. No existing branch history is rewritten and no broad authentication permission is silently added. Windows runtime CI is genuinely blocked until a maintainer installs that workflow or authenticates with appropriate scope.
