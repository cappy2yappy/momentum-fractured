# DEV-06 Windows candidate export

Exported from local source commit `91c719e614008e9cb883f4f34b12809a1dd9a272` using official Godot 4.6.1. Verified published runtime/source snapshot `2d827d47f0c6f84cfd327b0da887e7cf9bde474a` has no differences in scripts, tests, docs, world, project/export config and status at publication. Connected file-commit SHAs differ from the local merge history.

Draft PR: https://github.com/cappy2yappy/momentum-fractured/pull/7 (base feature/alpha-0.6-momentum). No main merge.

Windows x86_64 candidate: Kaze-Alpha-0.6-World-Momentum-Windows.zip (51145179 bytes). Executable SHA-256: `d0452a2fef1d7bd8b5ad3624b482bbbc95afffadd2dd19064629f8942c628581`. ZIP SHA-256: `9f13b8894afd2d9288e2909b52ad065915e6a2f5898a0bf03f68d4864f10dc69`.

Export command: `Godot_v4.6.1-stable_win64_console.exe --headless --path kaze-integration --export-release "Windows Desktop" build/windows/Kaze-Alpha-0.6-Candidate.exe` — exit0. Packaged executable `--headless --quit-after 180 -- --test` — exit0, no script errors. An attempted external source-suite invocation against the release executable produced no assertions and was stopped; no packaged full-suite pass is claimed. The twelve suites/556 assertions apply to source. Export/import has the known certificate and editor cleanup warnings; packaged boot has the certificate warning.

Extract ZIP, run Play-Fresh-Test.cmd to isolate a fresh profile beside the executable. Play-With-Momentum.cmd compares the opt-in meter on that same profile. Direct executable launches use the existing application/save identity; back up existing saves before comparing versions. Source key bindings and route-entry notes are in README.txt. Prior Alpha0.5.2 exports were not overwritten.

macOS: not exported; installed templates include Windows only, and no macOS signing/runtime validation environment is available. Candidate verdict: ready for creator playtest, not Alpha0.6 milestone complete. Remaining: fresh-save full campaign/softlock sweep, subjective movement review, real60FPS hardware measurement, environment art decisions. SHA-256 checks establish file identity, not subjective quality or full gameplay completion.
