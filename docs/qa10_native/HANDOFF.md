# QA-10 PM handoff

Status: investigation complete; isolated draft change ready for review. No integration or merge authorized/performed.

**Decision supported by evidence:** classify the reproduced native stationary fixtures as an inherited test-harness pause-lifecycle problem. An inherited unbounded screenshot wait separately explains timeouts after successful gameplay. PR78 reproduces the mechanisms; the same test-only correction makes the complete relevant native sets pass on both game commits. No Studio gameplay regression was found.

- Candidate reference: PR100 `d227b038576fc5268acc4f94324fc5fbf64244a5`.
- Baseline reference: PR78 `af184380fb690f2c19bac69960b7aacce50f9ff2`.
- Branch: `qa/qa10-cinematic-native-regression`, stacked on PR100.
- Checkout: `work/qa10-native-regression` in the Kaze project workspace.
- Changed: four existing test harnesses, one test-only HUD factory, diagnostic controls/runner/verifier, and evidence. Production/resource bytes are preserved.
- Final native: candidate 855 assertions plus 16 contract checks; baseline 826 plus the same 16. Zero failures/script errors.
- Headless: 2,505 passing assertions across the 33 existing suites, Studio, and lifecycle/automation controls. Baseline asset/controller verifier passes.

Review [REPORT.md](REPORT.md), the final native result JSONs under `logs/pr100/final-native` and `logs/pr78/final-native`, preserved failures, and the preservation manifest. In particular, verify that explicit focus tests still execute the exact production handler and that incidental focus cannot clear a deliberate pause/map state. No assertion was relaxed or removed; native screenshots now have explicit success checks.

The first historical OS event is not recoverable from old logs, and the compositor-specific cause of suppressed regular drawing is not established. Windows native execution, controllers, exports, creator/editor visual acceptance and wider campaign acceptance remain outside this macOS investigation. Those existing PR100 acceptance limits stay open.

The older `capture_pm_transition.gd` workflow still uses the legacy HUD fixture retained for the positive control. It was not exercised here; review that caller separately before relying on its background-focus behavior.

Recommended next owner: PM/reviewer. Review the test-only correction, then arrange the Windows Godot 4.6.1 native pass and existing creator acceptance. Keep PR100 draft; preserve Alpha 0.6.1 Candidate 3. This handoff does not authorize a merge or replace broader production acceptance.
