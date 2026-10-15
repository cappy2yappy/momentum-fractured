# TR-03 Lane A — recovery / baton

Goal: continue scoped embodied transitions on verified TR-02 while preserving gameplay, world and saves.

Done: policy/adapter, pilot structures,58-endpoint audit, full QA, native visual evidence and Windows package. Tasks: source/implementation/QA complete; acceptance, final poses, native Windows/controller and full-run performance pending. The current report/continuity are the final docs increment.

Branch: feature/alpha-0.6.1-tr03-embodied-transitions. PR27 base is TR-02, not main/candidate. Audited code/evidence checkpoint a7c1a1f7fe305c4c4844aa7fcbe4effed18f27f8; fetch actual current head. Local session worktree was /workspace/scratch/f29c75aa04b4/kaze (ephemeral; clone the branch to recover, not that path). Local CLI push lacked credentials; connected Git-data fast-forward publication has tree-equivalent, different commit IDs. Do not force-push the divergent local history.

1. Fetch PR27, verify head and working tree; read CONTEXT, latest SESSION_LOG and PM return. Do not recreate TR-01/TR-02/DEV-06 or regenerate art/evidence already committed.
2. Confirm official Godot4.6.1. Python3/Pillow for package evidence. Run tools/run_tr03_qa.py --godot /path/to/Godot_v4.6.1-stable_linux.x86_64. It creates isolated profiles. Inherited first editor import can need a registration warmup; log both attempts. Source suites must not have script errors.
3. Read docs/tr03/ENDPOINT_MATRIX.md and STRUCTURAL_DRESSING_PLAN.md. Only R15/R16 directional, R14/R17 stairs, exceptional R20/R13 and opt-in R14/R13 depth are staged. No new links/ports/colliders.
4. Compare original/refined/reduced/plain. --tr03-depth-demo enables exactly one existing link. --tr03-no-dressing removes only visual supports. --tr03-save=/absolute/path isolates files. Plain/default creator profile behavior is unchanged; package launchers provide separate fixtures.
5. Before accepted art integration, preserve old scales/baselines; future new320x724/pivot(160,600) clips belong to the render adapter, not player.gd. Keep per-direction anatomy and label placeholders until final creative approval.
6. For native captures on this Linux container, Xvfb local Unix sockets failed; TCP display worked with --display-driver x11 / llvmpipe. This is an environment detail, not a game requirement. No human playtest or hardware FPS result exists.
7. Next owner: PM/creator for pilot comparison; Art Mane for approved walk/rear/stair clips; Build Shogun for native Windows launch/performance. Resume small isolated fixes after feedback, not global rollout. No merge without explicit authorization.

Risks/deviations: quarter-width idle is a labelled turn placeholder, not final rear art; existing run is a stair contact placeholder, not final ascent/descent anatomy; inherited gamepad mapping absent. Export resource checks run on Linux, not native Windows. Full campaign/softlock/hardware acceptance open. No background execution promised.

