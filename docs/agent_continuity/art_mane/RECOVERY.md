# ART-04 — resume without regenerating delivered work

1. Fetch `art/art04-production-pilots`, inspect [PR30](https://github.com/cappy2yappy/momentum-fractured/pull/30) actual HEAD. Verified production checkpoint `9f4e7151b1f8aa683123ee59aa549c3d8c2b4bb7`. Read current CONTEXT/next-task/state and ART04_PM_REPORT.md. Creator's ART-03 approval supersedes old pending-concept wording.
2. Local art checkout work/art03-recovery; separate PR27 reference snapshot work/art04-level-reference at c2c002267c58e991966c0eebf7e098c6e7fff769. The reference snapshot is not a managed worktree or published integration branch.
3. Inspect assets/art04, source_art/art04 and docs/art/art04 images before new authoring. No diagrams substituted for sprites. Master/source/transparency and ORA layers are recoverable; original ART03 paintings unchanged.
4. Re-export with tools/art04_export.py (Pillow/NumPy, macOS Arial path). Fixed authoring transforms are recorded, not playback auto-centering. Review capture scripts run only on pinned PR27 with assets/art04 copied in; ignored on older art-branch gameplay. Native Godot4.6.1 installed at /Applications/Godot.app. Explicit disposable --tr03-save path.
5. Rebuild capture sheets/QA with tools/art04_review/build_review.py. PNG integrity and baseline passed; native static fixture passed, not live transition/full-build tests. Keep strong texture references in custom drawing; first temporary-load white rectangles were fixed before delivered captures.
6. Actual colors/contacts/facing and layer-order limitations are in LEVEL_HANDOFF.md. Right-up and left-down are separately authored; no opposite-facing or full-cycle approval inferred.
7. Coordination posted to [PR27](https://github.com/cappy2yappy/momentum-fractured/pull/27#issuecomment-6201972556); no acknowledgment claimed. Next creator review → Level scoped integration/QA → Build Shogun pinned comparison packages. No merge, sprite replacement or global reskin.

Worktree-only inherited state: production_revision/QA_RESULTS.json reports CRLF normalization noise but bytes equal base; excluded from all commits. No unfinished production payload left outside publication.
