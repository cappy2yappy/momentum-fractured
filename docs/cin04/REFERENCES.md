# CIN-04 reference provenance

- PR #78: Cut-In Maker, `af184380fb690f2c19bac69960b7aacce50f9ff2`. Reuses its presentation script, preview controls and native AnimationPlayer format.
- PR #81: ST05, `1d157f4b7014ad1c05e231a8787594d57b5e33a3`. Reviewed canon audit, production boundary, optional discovery treatments and casualty proposals. CIN04's current creator instruction authorizes developing review sequences; it does not approve campaign placement or named casualties.
- PR #86: story presenter, `2d459743bce4a11a2d6bed1ae75d0c6d3adf3d5f`. Direct publication parent; legacy fixtures retained.
- PR #89: INT01 follow-up, `3dc433cd7b537391f218864abeb2398dc671ccb0`. Test-only copies of `story_director.gd`, `object_definition.gd`, and `inspection_panel.gd` live in `tests/cin04/int01_reference`. Only the director's two preload paths change to point into that test directory. No production director is installed or replaced.

Source recovery: shell Git networking was unavailable. The existing PR64 archive at `ed1875307e21f057add025ebebdec1e3f371e90f` plus connector-fetched #78/#86 additions reproduced the runtime. Every recovered file was checked against GitHub blob SHA-1s: no mismatches. Missing historical #78 screenshots, videos and log files were not needed for execution. Publication uses the complete remote #86 tree plus the reviewed CIN04 delta, retaining all historical files.

Local Git initialization records only a recovery snapshot, not upstream ancestry. The published commit uses the real #86 commit as its parent. No existing working checkout or synced project source was edited.
