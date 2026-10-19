# QA candidate-test runbook (PM pilot, ORDER 4)

One command runs everything against a worktree or a commit and writes one JSON file.

```bash
cd /home/claude/wt-qa        # any checkout of branch test/pm-pilot-regressions
# A candidate worktree already on disk:
python3 tools/pm_pilot_qa/run_qa.py --repo /home/claude/wt-transitions --label cand-transitions
# A pushed commit (fetched shallowly, checked out in a temporary detached worktree, removed afterwards):
python3 tools/pm_pilot_qa/run_qa.py --commit <sha> --label cand-x
# Add the software-GL graphical pass (several minutes, real time):
python3 tools/pm_pilot_qa/run_qa.py --repo <path> --label cand-x --rendered
```

Output: `docs/pm_pilot/qa/runs/<label>/result.json` plus every raw log in that folder. Exit code 0 means
`PASS` or `PASS_WITH_SKIPS`; 1 means `FAIL`. Engine defaults to
`/home/claude/godot_bin/Godot_v4.6.1-stable_linux.x86_64` (override with `--godot` or `$GODOT`).
Typical wall time headless: about 2.5 minutes (harness 20 s, stock 25 suites 75 s, preservation scripts, author test 35 s).
Do not run two runs at once on the 2-core box if timing matters; results are deterministic but slow down.

## What it runs (separate categories, never merged)

1. `automated_headless.harness`: `tests/pm_pilot_qa.gd` (this branch, passed by absolute path, so
   the target worktree is not modified apart from Godot import files). Real `InputEventKey` input and real
   physics, fresh disposable profile (HOME/XDG redirected, default save deleted before every scene).
   Sections: `start`, `issue42`, `matrix`, `controls`, `hints`, `endpoints`, `save`, `combat`, `graph`,
   `reduced`, plus the pending hooks.
2. `reduced_cli_default` and `reduced_cli_flag`: separate processes without and with
   `--tr05-reduced-motion`.
3. `automated_headless.stock`: the target's own `tools/run_tr05_qa.py` (25 suites), `verify_baseline.py` and
   `verify_tr05_preservation.py`, whichever the target has.
4. `author_tr06_test`: PR51's `tests/automatic_passage_reliability.gd` through `tools/run_tr06_qa.py`
   when the target contains them (or, with `--borrow-tr06` on a `--commit` worktree, copied in from this branch
   with hashes recorded). Use `--borrow-tr06` only to reproduce failing-before on PR39.
5. `graphical` (only with `--rendered`): the harness under `xvfb-run` with software GL (llvmpipe, OpenGL
   compatibility). By default only sections `start,issue42,reduced` (`--rendered-sections all` runs the
   whole suite, which is real time and takes over an hour).
6. `human`: always "none". `platform`: Linux cloud only. `untested`: list of known gaps.

## Reading the result

* `verdict`: `FAIL` if any harness check fails, any script/parser error appears, the harness exits non-zero,
  or a stock runner exits non-zero. `PASS_WITH_SKIPS` when everything ran and hooks are still pending.
* `pending_hooks_skipped` lists skips. A skip is not a pass. Do not accept a candidate as verified for
  cinematic completion or Canal containment while its hook is listed here.
* Per-section counts are in `automated_headless.harness.sections.<name>` with `failures` text.
* The harness prints `TRACE` lines (position, velocity, floor, wall state) per approach in `harness_headless.log`.
  Use them to explain any failure.
* The Godot line `ERROR: Parse JSON failed` in `save` is the deliberate corrupt-save case, not a defect.
  Inherited RID/ObjectDB leak lines at exit are also not failures.

## Activating the pending hooks (Phase B)

See `tools/pm_pilot_qa/hooks/README.md`. Drop `hook_cinematic_completion.gd` and/or `hook_canal_containment.gd`
into `tools/pm_pilot_qa/hooks/` (or pass `--hooks <dir>`), commit, rerun. Needs the Transition and Level candidate
head SHAs, `CANAL_CONTRACT.md`, and the exact field names / durations of the staged sequence.

## Failing-before reproduction (PR39)

```bash
python3 tools/pm_pilot_qa/run_qa.py --commit 5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c --label pr39 --borrow-tr06
```

## Single sections by hand

```bash
HOME=/tmp/qa-profile XDG_DATA_HOME=/tmp/qa-profile /home/claude/godot_bin/Godot_v4.6.1-stable_linux.x86_64 \
  --headless --path <worktree> --fixed-fps 60 --script /home/claude/wt-qa/tests/pm_pilot_qa.gd -- --qa-sections=matrix,hints
```

Run `--import` once per fresh worktree first (about 40 s). Never commit stray `.import` files the import creates.
