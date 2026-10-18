# BUILD-06 pinned playtest controls

Build controls are based on PR #40. The separate game checkout is pinned to PR #39
`5dfc4c4f077c5408ecbe49f1cafafea1dcb1003c`. No branch merge, gameplay edit,
ART-07 activation, main update, signing bypass or production release is performed.

`sources.json` is an explicit allowlist. Currently only the prior-baseline control is
buildable. TR-07 and LD-04 comparisons need published, reviewed engineering commits
and a separately verified temporary integration source before adding an entry.
ART-06 art branches are not substitutes for that engineering integration.

The PR-triggered workflow exports on native Windows 2022 and Intel macOS 15 runners.
It downloads official checksum-pinned 4.6.1 editors/templates, checks all 25 TR-05
suites and preservation, repeats exports, requires identical named resource payloads,
audits every packed payload, and tests the final extracted package in a path with
spaces. Seven launchers, native release startup, 54 input-fixture checks and six
packaged suites run on each host. Hosted fixture runs are headless. They are not
hands-on campaign, GPU, gamepad, or sustained-FPS certification.

Artifacts retain the inner distribution ZIP, source/control/engine provenance,
SHA256SUMS, package member hashes, content labels and QA results for 30 days.
QA artifacts include failures even when no playable artifact is uploaded.
Actual GitHub artifact IDs/digests/expiration are reported after each run.

For local Windows testing, use a clean disposable full-history checkout at the
allowlisted source. Set BUILD06_SOURCE_ROOT to it and BUILD06_TEMPLATES to official
4.6.1 templates. Run `python tools/build06/candidate.py --godot <official-console-exe>`.
Use `--graphical` only on a host with a working desktop to capture the actual exported
input fixture. Never point the runner at an active developer checkout; it imports,
exports and writes ignored build/profile directories. Start from a new clean source
checkout for every run. No personal save or active project is used.

The export-only preset overlay uses Godot's text-script mode, then restores the
original preset bytes. Every shipped script is checked against its source bytes.
Reproducibility means pinned inputs and identical repeated resource payloads.
Outer platform archives or executable metadata may differ; both repeated export
hashes and their byte-equality result are retained without claiming cross-run
bit identity. No downloadable artifact is called a candidate-lane integration until
its manifest explicitly identifies those included components.
