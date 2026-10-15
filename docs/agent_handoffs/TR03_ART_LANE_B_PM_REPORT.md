# KAZE — PROJECT MANAGEMENT RETURN REPORT

**Assignment:** TR-03-0061, Lane B — Character Animation and Environmental Architecture

**Specialist:** The Art Mane

**Date:** October 15, 2026, America/New_York

**Verdict: READY FOR PM / STORYBOARD REVIEW.** Lane B's implementation-first specification package is complete. Final painted character frames and Lane A's runtime prototype remain separate review gates. No merge performed.

## A. Executive Summary

Delivered an actionable art package for turning into depth-facing doorways, separate stair ascent/descent, low-speed walk versus running continuation, and structurally supported room architecture. Level Masta Masta can implement labeled placeholder staging from this package without waiting for finished art. Existing Kaze identity, completed ART-01 artwork, gameplay, room geometry and TR-02 comparison code remain unchanged.

Published a first recoverable specifications checkpoint before expanding the previews. The final preview package includes five original technical boards, six PNG review images, editable SVG/label sources, an actual32-frame source contact, per-frame audit data and a proposed30-frame new action pack. This is a storyboard/specification delivery, not a finished new animation pack.

## B. Authority and References Actually Reviewed

- [Complete authoritative TR-03 work order](https://github.com/cappy2yappy/momentum-fractured/blob/880718f51b761ffbe40fb028741135b58b00e5f1/docs/agent_assignments/TR03_ALPHA061_EMBODIED_TRANSITIONS.md), read in full and acknowledged before development.
- TR-02 branch independently verified at `e9a2d1ab0537f3f903c543b080451b3556961179`; read its complete PM report and relevant mixed transition/presentation source. Original0.65s loader, around0.33s swap, directional pilot, safe x carry, cooldown/rearm and exceptional wind-fold remain Lane A's reference.
- Vetted art branch independently verified at `2b1ccec9e293a50ada9c11d3dc9751281db31cb1`, including biome visual bible, preserved prototypes, current Kaze manifest and approved source strips. Existing ART-01 references/art were reused, not regenerated.
- PM-02 continuity protocol and Art Mane context/session/recovery records at `4c7794ae2ae6c354d204b04647f26f9c108526e4` on `docs/pm02-agent-continuity`; its bootstrap describes biome placeholders as accepted for now, not final production art.
- Official Aseprite CLI documentation consulted for batch/crop/export options. Local Aseprite probes were actually attempted; failures are reported below.

No unavailable chat transcript or unviewed source image is asserted as evidence.

## C. Accepted-vs-New Sprite and Architecture Audit

Existing clips are idle/run/combat/traversal, eight frames each. Idle/run cells272×724; combat/traversal320×724. Current per-clip scales and pivots remain unchanged, preserving roughly97px average upright presentation at camera zoom1.

The controller currently selects the run sheet even at low movement speed: **there is no accepted separate walk cycle**. The accepted set also lacks rear turn, depth entry/exit and stair-specific cycles. Existing run can support a running passage; it cannot honestly be presented as a finished walk or stair animation.

All four source strips are RGBA/equal-cell. At alpha>0.1, no strong pixels touch cell borders; minimum margins measured across all frames are idle25px,run13px,combat24px,traversal24px. This establishes containment at that threshold, not complete limb/art reconstruction or perfect halos. The actual contact reveals some detached combat/traversal fragments; they are documented and preserved rather than silently changing accepted art.

TR-02 pilots remain R15↔R16 horizontal passage, R14↔R17 stairwell control and R20↔R13 special wind-fold. No depth-facing endpoint is selected by Lane B. Existing endpoint coordinates and prerequisites are recorded in the handoff. Stair direction requires explicit Lane A metadata, not comparison of y coordinates between different rooms.

## D. Animation Concepts and Minimal Action Pack

| Motion | Concept / new requirement | Safe reuse or implementation fallback |
| --- | --- | --- |
| Depth door | Profile approach → authored quarter-back/rear turn → inward step behind jamb/reveal → opaque room swap → front-quarter emergence → prescribed arrival heading | Existing identity reference only; use labeled skeletal proxy or original plain/graphic fallback until new keys approved |
| Stair ascent | Planted support foot, lifted knee, visible tread contact and pelvic rise; local flight joins a landing and recessed continuation | Short entry/arrival step fragment, not an entire staircase compressed into loader time |
| Stair descent | Forward reach and knee compression on landing; distinct contacts from ascent | New downward keys, not reversed ascent playback |
| Walking | Low-amplitude upright6-frame cycle | New art required; no physics speed adjustment to disguise current run art |
| Running | Preserve existing stride phase, facing and current run registration where adapter permits | Existing8-frame run at current0.08s cadence |
| Exceptional travel | Keep the liked original wind-cloth/rose-indigo wind-fold expressive | No new generic wipe substituted for every ordinary connection |

Proposed new master pack: walk6,turn-depth4,enter-depth3,leave-depth3,return-profile2,stair-up6,stair-down6 = **30 new source frames**, plus existing run reuse. No final new painted frame was produced or approved in this task. The30-cell requirements sheet is explicitly schematic.

## E. Frame, Pivot, Timing and Import Contract

New authoring proposal:320×724 RGBA cells, ground pivot(160,600), upright occupied height320 source px, visual scale0.303125 to preserve97 world px. Centered Sprite2D offset(0,−238) maps that source pivot to local foot origin. This contract applies to future new clips only; current clips retain their individual approved scale/pivots. No per-frame auto-centering, trimming, deduplication or scale correction is permitted as a substitute for consistent drawing registration.

Define directional variants, contact events, frame count, nominal preview duration, source regions and alpha margins in JSON. New clips use their actual frame counts through a separate render adapter: do not reuse player.gd's hard-coded8-frame assumption blindly. Mirroring requires accessory/silhouette review; rear entry is an authored facing change, not negative-x scale or squeeze.

Storyboard cues occupy the retained0.65-second/39-tick window: turn/approach0–11, inward step12–18, cover/swap18–21, emergence21–29, profile/stride recovery30–38, ordinary resume at39. They must follow actual loader events rather than rescheduling room loading. These overlapping cue windows are a proposal, not implemented timing. Proxy art may be staged while existing physics is frozen; world root, capsule, velocity, save state and safe arrival stay owned by Lane A.

Reduced motion retains architecture plus a static facing key/fade. No mandatory spin, shake, burst or moving graphic is required to comprehend travel. Cancellation/failed request/death must restore the real sprite through the adapter's eventual cleanup path.

## F. Environmental Architecture and Support Treatments

Original concept kit provides depth doorway/jamb/threshold, stair flight/landing/stringer, culvert arch/piers, roof wall bracket, canal crossbeam/piers and ruin buttress. Proposed dimensions and local origins are specified relative to current character size; none is a collider instruction.

Priorities: R14 roof rests and stair casing; R17 shaft-wall brackets/rails; R15 dry service/culvert retaining supports; R19 wall-supported maintenance catwalks. Every support must visibly connect to a real wall, roof beam, terrain or floor. If no plausible receiving structure exists, request Level-approved scenic backing instead of attaching a dangling brace. Supernatural support needs explicit story/PM justification. Avoid covering anchors, elemental seals, hazards, pickups or HUD.

## G. Deliverables and File Inventory

All new task files are under `docs/art/tr03`, the scoped `docs/agent_continuity/art_mane` records, and this report.

| File / group | Purpose |
| --- | --- |
| LANE_B_IMPLEMENTATION_HANDOFF.md | Immediate Level staging/metadata guidance and exact existing pilots |
| SPRITE_PACK_SPEC.md / transition_art_contract.json |30-frame pack, naming, dimensions, pivots, transparency, timing and adapter proposal |
| ACCEPTED_VS_NEW_ASSETS.md / AUDIT_FINDINGS.md | Source audit and accepted art versus missing new production clips |
| ARCHITECTURE_KIT.md | Reusable architecture dimensions, attachments and per-room requests |
| PRODUCTION_PLAN.md | Phased artist effort estimates and review gates; not date promises |
| previews/STORYBOARD_depth_door.png | Six doorway action beats |
| previews/STORYBOARD_stairs.png | Separate ascent/descent key contacts |
| previews/STORYBOARD_walk_run.png | Low-speed versus running approach/crossing/continuation |
| previews/ARCHITECTURE_entry_support_kit.png | Six original architectural treatments |
| previews/CONTACT_new_frame_requirements.png |30 schematic frame slots, not production sprites |
| previews/CONTACT_existing_kaze.png |32 actual source frames at current scales over four backgrounds |
| Matching SVGs, *_shapes.svg and *_labels.json | Editable/reproducible technical sources |
| render_review.gd / QA_RESULTS.json / ASSET_MANIFEST.json | Standalone renderer, measured source audit and file hashes |
| PROVENANCE_AND_REPRODUCTION.md | Actual tool use, original work provenance and limitations |

## H. Actual QA, Tool Use and Limitations

Standalone Godot4.6.1 GL Compatibility render completed five labeled technical boards plus the existing32-frame contact at1600×1000. The contact renders source art at manifest gameplay-pixel scale; schematic diagrams use0.8× display scale for panel layout. These are technical art renders, **not gameplay transition screenshots or a playable prototype**.

Manually inspected door turn visibility, different stair contact mechanics, structural attachment examples, captions and actual-source contacts. First-draft occlusion/label overlap and a renderer parse error were corrected before the final successful run. Source RGBA/cell parity/border checks and `python tools/verify_baseline.py` passed (zero baseline failures). Final renderer log has no script error; the known Windows certificate-store diagnostic remains.

Aseprite executable is installed, but batch help/crop probes returned exit1, empty diagnostics and no file. No successful Aseprite authoring or .aseprite deliverable is claimed. Higgsfield preferences were read; no paid/free generation was submitted. Exact technical diagrams were authored as original SVGs instead of using generative media for frame-count/pivot information.

Final new-frame clipping/alpha/contact acceptance is **not run — new painted frames do not yet exist**. Runtime directional/gate/save/arrival/gamepad tests and Windows export are **not run — Lane B does not implement gameplay**. Sustained60FPS, final rendered transition readability and broad color-accessibility testing are not certified by static boards. No new build was requested or produced.

## I. Publication and Preservation

Branch: `art/alpha-0.6.1-tr03-entry-poses`. Draft [PR#25](https://github.com/cappy2yappy/momentum-fractured/pull/25) targets the vetted `art/alpha-0.6.1-biome-identity` branch, not gameplay/integration/main.

Verified published checkpoints:

- `0d96f939641c0815b16813c2382b607a5eb34f28`: specs-first minimal pack/architecture and initial continuity.
- `45ed20bdd6af68b89edc4b15fec64cfd891e0700`: storyboards, original architecture, source audit, review renders and provenance.

The complete return report and final continuity pointers are published as a following documentation-only commit on the same branch; retrieve its exact live HEAD from the PR/branch. No merge or force push. GitHub-connected object publication was used because this sandbox's CLI authentication is unavailable; local checkouts were fast-forwarded to the verified remote commits.

Compared with the art base, protected runtime scripts/scenes/project/world and existing assets have no task changes. Previously present untracked script/test UID metadata was left outside task commits; see scoped RECOVERY.md for the exact inherited list. Completed ART-01 art and source hashes remain intact.

## J. Cross-Agent Decisions, Schedule and Next Actions

1. Level Masta Masta can consume the handoff/JSON now, select one eligible depth-door demonstration and bind approach/heading/depth/cover/swap/arrival metadata without changing the graph.
2. Confirm explicit up/down semantics and art origins for the existing R14↔R17 stairwell. Keep R15↔R16 and R20↔R13 comparison pilots intact.
3. Creator reviews the door turn, stair contact/weight, new walk-vs-run distinction and support kit. This review does not approve final Kaze frames or a merge.
4. After approval, produce identity-matched rough turns/depth keys, then ascent/descent, then walk, then paint/export/edge/pivot QA. Proposed focused artist ranges are recorded in PRODUCTION_PLAN.md; engineering estimates remain Lane A's responsibility.
5. Integration/playtest/performance and Sound Shogun audio coordination follow on separately authorized branches. No unverified third-party audio/media enters builds.

## K. Final Verdict

**READY FOR PM / STORYBOARD REVIEW.** Lane B's audit, asset requirements, storyboards/contact sheets, pivot/import contract, original architecture references, production plan and recoverable publications are complete. Level is unblocked for explicit placeholder staging. Final painted sprites, actual embodiment acceptance and merge approval remain pending, as required by TR-03's phasing policy.
