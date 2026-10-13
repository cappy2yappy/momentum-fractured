# DEV-06 integration report — 2026-10-13 UTC

Candidate for creator playtest; Alpha 0.6 acceptance is pending.

Integration branch: `integration/alpha-0.6-world-momentum`.
Approved Alpha 0.5.2: `215e9bce3b234cb268e9426b52817f5ca844031e`.
Restored-size sprite base and MV/LD merge-base: `0bf37e19ef3498386b133ed5d41e32788c2609d6`.
MV-01 verified source: `c700ca9f6c4729f4a826c792c3b87b1ed938194c`.
LD-01 current head: `1f46ca78f3259c0d0d00eaec43da8012bd4b5ea2`; design publication `1ba5bdd4cd8bfb0e000a11492d9e6269ab480ab2` and original design `10d9efe` are included in its history.
Implementation/QA code checkpoint: `bac15f25065f0e6b7ffbfad7e2df366035b90fa7`. Final export metadata/documentation commits follow this checkpoint.

## Integration decisions

- Created a clean separate worktree from MV-01, preserving the earlier worktree's generated import changes. Verified approved gameplay and restored-size ancestry using `git merge-base --is-ancestor` (exit 0).
- Local merge `fdb4571` incorporates LD-01. Sole merge conflict: shared movement contract add/add. Kept MV-01's measured contract; retained LD-01 as `LD01_MOVEMENT_CONTRACT_PROPOSAL.md`. Design documents were incorporated, not older controller/asset files.
- Gate fixes `f5145fb`; initial eight-room implementation `03ad5e5`; traversal, save/projectile QA and atlas refinement `bac15f25065f0e6b7ffbfad7e2df366035b90fa7`.
- Player controller and active/original Kaze PNGs remain byte-identical to MV-01. Original eight-room collision arrays stay identical; old enemy lanes now clamp to supporting surfaces without changing attack timings/damage.
- New service ledges alone use one-way upward collision. Perimeter/recovery floors and original rooms stay solid. This repairs overlapping shelf undersides while keeping measured controller movement intact.
- Named sigils replace dictionary-size progression checks: `undercroft_sigil`, `terrace_west`, `terrace_fire_cache`. Optional lore cannot satisfy campaign locks.
- No main merge, force-push, branch deletion, candidate kunai-art import, swimming system, or new boss scope.

## Publication provenance

Normal CLI push failed: `cannot spawn sh` and credentials unavailable. Connected GitHub publication is used as a safe fallback. A branch-creation attempt was automatically rejected pending evidence that no remote branch would be overwritten. `git ls-remote --heads` and GitHub branch search both showed no matching branch; creation then succeeded from MV-01. Remote file commits preserve the tested tree, but their SHAs differ from the local merge history. Consult the final project-management report for the verified remote SHA and PR. Local commits remain preserved.
