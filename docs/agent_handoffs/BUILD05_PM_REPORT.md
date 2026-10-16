# BUILD-05 — Alpha 0.6.1 integrated macOS candidate

2026-10-16 · Build Shogun · PM return for draft review, no merge.

## Identity and scope

- Gameplay source: PR39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`.
- TR05 runtime: `f168339a6fa6b02f16958ce250636dbe47d4a783`.
- PR37 geometry: `b950373efb5c4621d7da7e0be1506db048e3043a`.
- Dedicated branch: `ci/build05-integrated-macos`.
- Draft review: [PR40](https://github.com/cappy2yappy/momentum-fractured/pull/40),
  based on the PR39 branch so the build-only diff is reviewable independently.
- Tested controls: `416477542a0fd1cb0a44ca3631e97338e08d00dc`.
- Engine: official `4.6.1.stable.official.14d19694e`; official editor/templates
  SHA-512 pinned and checked. Universal `x86_64` plus `arm64` binary.

Only build controls and evidence/documentation are added. Exact source checkout,
unchanged export presets, baseline verification, PR37 preservation verifier and
PCK payload audit protect gameplay, artwork, controller, saves and geometry.
Main, PR37, PR39 and other specialist branches are not modified or merged.

## Delivered package

**Ready for creator/PM playtest.** [Download the Universal Mac artifact](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38951786047/artifacts/12067919040)
from [successful Actions run38951786047](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38951786047).
[Raw hosted QA evidence](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38951786047/artifacts/12068098774).
Build expires **2026-11-15 19:06:09 UTC**; evidence expires 19:06:16 UTC that day.
No build or access blocker remains. Signing and human acceptance limitations below remain.

- Artifact ID: `12067919040`; outer artifact size `76,614,524` bytes.
- Outer SHA-256: `d5a7e03039d9d56ff7cccf86c4d38f10c3cc34e5884058b17bb26e55f1ffe9ba`.
- Inner candidate ZIP: `76,894,543` bytes.
- Inner SHA-256: `7389b03b6e9106d899c27d4ef279cd930add4bea87a08ae542a9ef544e6ea4c4`.
- Source commit is included in the archive filename, README and manifest.
- Full member hashes, source identity, artifact digests/expiry, native host scopes
  and 36 rendered PNG capture hashes: [verification](../build05/evidence/VERIFICATION.json).
- [Hosted manifest](../build05/evidence/hosted-manifest.json) and
  [hosted native QA](../build05/evidence/hosted-intel-qa.json).

The downloaded outer and inner archives, every declared member hash, all 573 PCK
resource payload MD5s, required world bytes, absence of forbidden resources,
Universal architecture and all eight executable file modes were independently
verified. GitHub sign-in was sufficient through the authorized connection to
retrieve both accepted artifacts; the temporary signed download URLs are not
published.

Extract the GitHub artifact, then extract its inner
`Kaze-BUILD05-macOS-Universal-5dfc4c4f.zip` completely into a writable local folder.
GitHub sign-in may be required. Keep the app, launchers and fixtures together.

1. Open `Play-Fresh.command` for an isolated persistent new campaign.
2. `Play-Canal-Automatic.command`: hold A. Canal-left crosses without E.
3. `Play-Door-East.command`: hold D, stop, wait a second, then A to return.
   `Play-Door-West.command` starts the reciprocal Bellroof side.
4. `Play-Stair-Cinematic.command`: E. `Play-Stair-Descending.command` reverses
   direction. `Play-Stair-Reduced-Motion.command` uses the still treatment.
5. F6 toggles reduced motion for this session. A/D move; double-tap run; Space
   jump; Q tether; Shift dash; J attack; F parry; R kunai; T element; M map;
   I kit; Escape pause.

Six demos reset only their own supplied fixtures every launch. Fresh persists in
its own profile. Seeded unlocks deliberately allow focused review and do not prove
an earned campaign. Opening the app directly uses the historical ordinary save
identity; use the launchers for isolated review. Source application/save identity
and save schema are preserved. Distribution contains no test profiles or saves.

## Test evidence

**All required automated acceptance checks passed.**

- Source QA on the hosted Intel Mac: **25 suites /1,607 passing assertions**, zero
  failed assertions or script/parser errors; baseline and **59 PR37 preservation
  checks** passed. [Source results](../build05/evidence/source-results.json).
- Hosted macOS **15.7.9 /Intel x86_64**: actual Universal release startup and **7/7
  real launchers** passed from a spaced path. **252 exported-resource assertions**
  passed (54 input/transition +198 geometry/movement/save/progression). These are
  native **headless** checks; no complete hosted graphical acceptance is claimed.
- Downloaded exact accepted artifact on **macOS27.0.1 /Apple M4 arm64**: real
  release startup, **7/7 launchers** and the same **252 exported-resource assertions**
  passed; the 54-check input fixture ran graphically and produced **36 captures**.
  [Downloaded arm64 QA](../build05/evidence/downloaded-arm64-qa.json),
  [native raw log](../build05/evidence/downloaded-arm64-packaged-native.log).
- The actual downloaded release binary also completed **180 rendered frames**
  through `Play-Fresh.command`, OpenGL4.1/Metal compatibility on Apple M4, exit0
  and zero errors. This is a graphical startup check, not a campaign playthrough.
  [Release graphical result](../build05/evidence/downloaded-release-graphical.json).
- Captures inspected for approved character/background rendering, inward arrivals
  and the explicitly unfinished stair study. [Mac capture previews](../build05/README.md).

Counts are per host/scope; repeated assertions on two CPUs are not different test
cases. The hosted and downloaded candidate have the same inner archive SHA-256.

| Requested area | Evidence | Interpretation |
| --- | --- | --- |
| Automatic Canal / reciprocal R13 | Current source transition suite 368 assertions; native input fixture includes walking, double-tap sprint, held E, stopped reverse round trips | Scripted Godot key events, no E for ordinary side passage; correct target, inward landing/facing and no loop |
| Bellroof / PR37 | `intentional_space` 63 + geometry audit 21 assertions against exported resources | Grounded masses/one-way steps, physical traversal checks, old blocked-save staging, optional log, locks, 21-room geometry signatures |
| Cinematic stairs / reduced motion | Source transition suite plus native 54-check fixture | Both directions, safe landing, camera restore; source checks F6/abort/cleanup and stationary reduced pose/camera |
| Movement preservation | Exported-resource `movement_momentum` 53 plus source baseline/controller comparisons | Existing movement/tether behavior retained; no physics edits |
| Saves | Exported-resource `save_compatibility` 11 and `expansion_gates_save` 17; Bellroof save/reload cases | Old save migration, earned kit/flags/checkpoints, seal/reward persistence, blocked feet staging and honest failed-save feedback |
| Progression | Exported-resource `skyworks_progression` 33 plus full source suites | Locked routes, elemental gates, Keeper/attunement, backtracking and save/reload |
| Delivery | PCK MD5/world-data/forbidden-entry audit, inner/outer ZIP hash/CRC, Universal Mach-O architecture check | Downloaded distribution identified independently of a local export |

The native input harness mounts the final exported Mac PCK into the exact matching
Godot native editor. Tests remain outside the shipped PCK. This proves the exported
compiled gameplay resources under the matching engine. Separate real release
executable/launcher tests establish binary startup; they do not turn scripted
fixture coverage into a full release-binary campaign. Geometry audit output alone
is redirected to an absolute disposable directory because mounted `res://` is
read-only. No assertion or gameplay code is relaxed.

The first hosted rendered fixture [run38950190263](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38950190263)
passed import, preservation, source suites, export, startup and seven launchers,
then timed out after partial native captures. Its [retained evidence](https://github.com/cappy2yappy/momentum-fractured/actions/runs/38950190263/artifacts/12069042198)
is diagnostic and is not the accepted download. Hosted Intel acceptance now runs
the same key events and all assertions headlessly, omitting screenshot waits only.
Local Apple Silicon acceptance retains full graphical capture and a graphical
release launch. No hosted Intel graphical certification is claimed. The controls
now also retain partial output and a failed QA row for future timeouts.

All 25 source suites must have nonzero assertions and zero failures/errors. Four
historical presentation suites explicitly run with `--tr05-legacy`; the other 21,
including TR05 and PR37, run current default behavior. These legacy checks are not
presented as proof of the new default. Raw logs retain the inherited shutdown RID/
ObjectDB warnings and macOS headless certificate diagnostic; these are narrowly
classified and are not assertion/script/parser failures.

## Limits and PM disposition

**The stair animation is not finished.** The current treatment translates approved
ART04 held ascent/descent drawings through space with a brief camera close-up.
Full gait, distinct walking, outward and arrival cycles remain ART05 work. The game
labels the moving study. Discrete 0.65-second room loading remains; no streaming
claim. Reduced motion is session-only and preserves the save format.

The app is unsigned/unnotarized and downloaded software may encounter macOS trust
controls. No bypass or signing credential is bundled. Native scripted QA and
rendered capture inspection do not certify a human unseeded campaign, physical
gamepad, sustained 60 FPS, every hardware configuration or every macOS version.
PR37's conditional creator acceptance remains unchanged.

Creator review should cover Canal-left, both R13 directions with stop/reverse,
Bellroof lower route/log and historical save staging, both stairs, F6/pause and
Fresh save/restart. Return feel/readability findings to PM; do not merge PR40 or
its gameplay baseline through this build assignment.

## Reproduction and recovery

See [build controls](../../tools/build05/README.md) and
[BUILD05 evidence index](../build05/README.md). The workflow pins gameplay SHA
separately from its own controls and has read-only repository permissions. A new
candidate requires an explicit source pin/change and new acceptance evidence;
never relabel another build as this one. Artifacts expire: retain this report and
hashes and rebuild the documented source through reviewed controls when needed.
