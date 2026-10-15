# gameplay_masta — RECOVERY

1. Read sibling `CONTEXT.md`, `SESSION_LOG.md` and linked work order/report.
2. Fetch the actual latest remote branch and PR state; do not assume a historical SHA is current.
3. Check PR #8 and integrated candidate #10. Do not restart stabilization. Only address bounded new gameplay issues requested by PM; retain controller invariants, retest, document source SHA.
4. Push completed increments to the dedicated branch and update these records with real source links. Clearly label absent evidence and local-only outputs. Never auto-merge.
