# BUILD-06 integration and rollback plan

## Current source graph

The inspected main is `c69efbb43aa49b71dc6c541820934487a170fa7b`.
PR39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c` is 82 commits ahead and one
behind main, with 1,236 differing paths. Its merge base is `1a33d283...`, so
main is not a drop-in packaging source and a fast-forward is not currently possible.
No main branch, tag or historical branch was updated by BUILD-06.

PR40 `32e75a884b62d08f9e024eab5b01429e87ed12f7` descends from PR39 by five
build/documentation commits. Its difference contains no gameplay or art source.
BUILD-06 controls are stacked on PR40 and check game source out separately at PR39.
See `evidence/ANCESTRY.json` for exact tips, merge bases, file lists and dry-run output.

## Engineering readiness

| Lane | Published input | Integration status |
| --- | --- | --- |
| Doorway issue #42 | TR06 PR51 `baedd6786ad4bee2123ea872b437bbb98e6d2721` | Separate fix; creator/native acceptance gate remains; not in controls |
| TR07 approved ART06 lateral art | Raw handoff branch `5fc41d231ee7a030a5c273e5263f96be54b55a8e` | Creator approval is supplied by the assignment, but published branch has no `assets/art06` images and no TR07 runtime adapter |
| LD04 R18 authored integration | PR47 art `4b11bef0b3727f1647029cb04568b96a2e09c9fd` | 33 `assets/art06` files present; no published LD04 engineering integration; layout JSON not included by baseline export filters |
| ART07 idle/wait/crouch | New PR53 `18491105da5f8dd0b11b616c7da81803ced1fadc` | Arrived during BUILD06: optional procedural idle candidate, not approved or bound; waiting/crouch pending. Initial `65e1e08...` snapshot had no art. No candidate assets included in these builds |
| LD authoring tool | PR49 `00d74c36212e0493c242c25e15d4200ef094a49c` | Disconnected editor pilot, not LD04 gameplay adoption |
| ST03 canon | PR38 `553285f1e8a3961c6b7c1c83ba861bbd4ee21438` | Documentation lane; keep distinct from playable build source |

Some source handoffs are stale about publication/approval. File-tree inspection and
the current creator assignment take precedence; a documentation status alone does
not prove images or a working runtime adapter are present.

## Dry-run conflicts

Eight `git merge-tree --write-tree` probes were executed without a checkout merge or
branch update. Seven are mechanically clean: PR40 with TR06, lateral art, R18 art,
ART07 and ST03; TR06 with R18 art; R18 art with LD tools. Mechanical cleanliness is
not component review, functional compatibility or creator approval.

The lateral ART06 and R18 art branches conflict in `.gitignore`: the former adds
`__pycache__/`, the latter adds `tools/art06/_patched/` and its cache ignore.
A future reviewed union should retain both protections. No conflict resolution was
applied to either branch. Wholesale art merges also pull inherited ART05 candidate
assets; use an explicitly reviewed file/commit allowlist rather than assuming those
parents are approved for normal gameplay.

Potential future semantic collisions are not yet testable: TR06 and TR07 both own
passage timing/intent near `cinematic_transitions.gd`; LD04 may change R18 support
rectangles that PR47's interim-catwalk layout exactly matches. Refit art to final
approved geometry, preserve exit/anchor/door clearance and add JSON export inclusion
only in the engineering candidate. Do not turn the disconnected LD49 scene into a
second runtime world system accidentally.

## Temporary comparison strategy after readiness

1. Freeze each reviewed engineering head SHA, approved asset hashes and its parent
   baseline. Require the actual asset files and runtime adapters to be published.
2. Start a disposable integration branch from PR39, retaining full Git ancestry.
   Add only approved transition/reliability and R18 integration changes in separately
   attributable commits. Do not update main, retarget specialist branches, or import
   ART07 candidates into the normal animation bindings.
3. Prepare separate source pins for baseline, transitions-only, R18-only and combined
   comparisons. Add allowlisted entries to the build controls only after scope and
   preservation review. Candidate-specific tests replace the baseline-only art
   exclusion check as appropriate; baseline gates stay unchanged.
4. Run cold/settled imports, missing-resource checks, preservation, navigation,
   progression/saves, fresh real-input doorway regression and candidate-specific art
   checks. Repeat exports and compare exact resource payload hashes; record archive
   byte equality separately. Verify downloaded artifacts and test actual native
   packages on Windows and macOS, with architecture coverage stated precisely.
5. Supply seeded demonstrations and an isolated Fresh campaign per candidate.
   Require creator comparison before acceptance; authored animation, full campaign,
   gamepad and sustained FPS remain separate gates.

Rollback during evaluation means stop using the candidate source pin and rebuild
PR39 using the recorded control commit. Downloaded inner ZIP hashes identify the
exact fallback package. Demo profiles are separate and resettable; Fresh profiles
persist within each extracted build folder. No production saves are migrated or
rewritten. If a later main modernization is authorized, first preserve its exact
current tip with an explicitly approved backup/tag and define a separate reviewed
update/rollback operation. BUILD-06 does not create that tag or move main.
