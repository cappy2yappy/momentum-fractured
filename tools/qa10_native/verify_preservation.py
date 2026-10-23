#!/usr/bin/env python3
"""Verify QA-10's test-only boundary, preserved assertion lines, and production bytes."""
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CANDIDATE = "d227b038576fc5268acc4f94324fc5fbf64244a5"
BASELINE = "af184380fb690f2c19bac69960b7aacce50f9ff2"
EDITED_TESTS = [
    "tests/automatic_passage_reliability.gd", "tests/native_cinematic_transitions.gd",
    "tests/tr08_canal_hang_probe.gd", "tests/tr08_canal_hang_regression.gd",
]


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def main():
    protected = []
    for name in git("ls-tree", "-r", "--name-only", CANDIDATE).decode().splitlines():
        if name.startswith(("scripts/", "scenes/", "assets/", "world/", "addons/")) or name in ["project.godot", "export_presets.cfg"]:
            data = git("show", CANDIDATE + ":" + name)
            assert (ROOT / name).read_bytes() == data, name
            protected.append({"path": name, "sha256": hashlib.sha256(data).hexdigest()})
    shared = git("diff", "--name-only", BASELINE, CANDIDATE, "--", "scripts", "scenes", "world", "addons", "project.godot").decode().splitlines()
    assert not shared, shared
    changed = git("diff", "--name-only", CANDIDATE).decode().splitlines()
    assert all(name in EDITED_TESTS or name.startswith(("docs/qa10_native/", "tools/qa10_native/", "tests/qa10_native/", "tests/fixtures/native_automation_hud.gd")) for name in changed), changed
    assertions = 0
    for name in EDITED_TESTS:
        original = git("show", CANDIDATE + ":" + name).decode()
        current = (ROOT / name).read_text(encoding="utf-8")
        for line in original.splitlines():
            if "check(" in line or "expect(" in line:
                assert line in current.splitlines(), (name, line)
                assertions += 1
    print(f"PASS: {len(protected)} production/resource files match exact PR100 bytes")
    print("PASS: PR78 and PR100 gameplay, routing, project settings and addons are byte-identical")
    print(f"PASS: All {assertions} original assertion lines in edited tests remain intact")
    print("PASS: QA10 tracked changes are confined to tests, diagnostics and evidence")
    output = ROOT / "build/qa10_native/preservation_manifest.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({"candidate": CANDIDATE, "baseline": BASELINE, "files": protected}, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
