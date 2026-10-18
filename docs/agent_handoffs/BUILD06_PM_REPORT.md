# BUILD-06 PM return

Status: infrastructure prepared; current native/hosted execution pending. This
interim report will be updated with executed results before final handoff.

Game source: PR #39 `5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`.
Build pipeline reference: PR #40 `32e75a884b62d08f9e024eab5b01429e87ed12f7`.
Branch: `ci/build06-parallel-playtest`, stacked on PR #40. Tracking: issue #46.
Main remains unchanged; no production release or merge.

Current build allowlist contains only the PR39 baseline comparison. It contains
prior approved artwork and ART04 held-pose stair prototype. It excludes ART-06
lateral animation, R18 authored environment integration and ART-07 idle/wait/crouch
candidates. Doorway issue #42 remains present in this control source; PR #51 is a
separate engineering fix and has not been silently combined.

TR-07 and LD-04 engineering commits were not published in the inspected branch
snapshot. ART-06 lateral branch `5fc41d231ee7a030a5c273e5263f96be54b55a8e`
contains tools/references but its handoff says the generated assets are outside Git.
ART-07 `65e1e08d3650349ae1573985af3470b2bb6ac9e9` reports no produced animation
assets. PR #47 R18 art is `4b11bef0b3727f1647029cb04568b96a2e09c9fd`, based on
unmerged ART05 PR #41. Its layout needs export inclusion and LD integration review.

Pipeline: native Windows/macOS exports, source/preservation QA, repeated PCK
comparison, seven isolated launchers, actual exported-resource assertions, per-file
checksums and 30-day downloadable Actions artifacts. Until executed logs are linked,
none of these planned checks is a platform pass.

Remaining gates: component readiness and review; bounded temporary integration;
exact source pin; creator art acceptance as applicable; native platform evidence;
human campaign/gamepad/FPS acceptance. Explicit creator approval is required for
any later move of main. Do not merge as part of BUILD-06.
