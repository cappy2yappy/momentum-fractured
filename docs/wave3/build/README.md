# BUILD-07 Wave 3 comparison packages (tester and coverage notes)

Variants (pins.json): `w3-control` (candidate 49ae3efe, the build the creator rejected), `w3-transition` (PR64), `w3-level` (PR63), `w3-art` (PR62), `w3-combined` (coordinator SHA, not yet supplied).

Launchers (demos.json, list `w3`; arguments PROVISIONAL until Transition's DEMO_ARGS confirms): Play-Fresh, Play-Stair-Fullscreen (R14), Play-Stair-Return (R17), Play-Canal-Doorway (R13), Play-Canal-Return (R0), Play-Geometry-Test, Play-Geometry-OpenTop, Play-Reduced-Stair, Play-Reduced-Canal. Each has its own profile file and user-data folder inside the package.

Do not pass `--pm-staged-stair` to TR-08 builds: it turns TR-08 off. Builds without TR-08 get it so the control shows the old staged stair.

Coverage: hosted runs are headless. Export success is not native graphical validation. No ART-08 clip is creator-approved; labels are candidate, stand-in, unfinished (INVENTORY.md in every package). ART-07 is excluded and the build fails if it appears.

Local dry run: `python tools/pmpilot/w3_prep_check.py --repo <clone>` (detached worktrees at the pinned SHAs, allowlist diff, inventory, fixture and launcher checks).
