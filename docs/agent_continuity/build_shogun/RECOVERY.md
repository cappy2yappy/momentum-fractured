# build_shogun — RECOVERY

1. Read sibling `CONTEXT.md`, `SESSION_LOG.md` and linked work order/report.
2. Fetch the actual latest remote branch and PR state; do not assume a historical SHA is current.
3. Inspect current main workflow, Actions permissions and live artifacts. Avoid rerunning completed infrastructure assignment. Extend only for explicitly approved new source refs/builds; report test scope and native limitations.
4. Push completed increments to the dedicated branch and update these records with real source links. Clearly label absent evidence and local-only outputs. Never auto-merge.
