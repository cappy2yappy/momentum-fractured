#!/usr/bin/env python3
"""Serial, bounded native/headless suites; optional read-only state observation.

Test bodies/assertions stay intact. Profiles and generated scripts live under build/.
Can target either pinned checkout without modifying its tracked files.
"""
import argparse
import hashlib
import json
import re
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

DEFAULT_SUITES = [
    "cin_tools_01/authoring", "cin_tools_01/runtime", "tr08_embodied_cinematics",
    "tr08_canal_hang_regression", "tr08_stage_labels", "automatic_passage_reliability",
    "native_cinematic_transitions",
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", required=True)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--label", required=True)
    parser.add_argument("--headless", action="store_true")
    parser.add_argument("--observe", action="store_true")
    parser.add_argument("--timeout", type=float, default=120)
    parser.add_argument("--suites", nargs="+", default=DEFAULT_SUITES)
    args = parser.parse_args()
    root = args.root.resolve()
    out = root / "build/qa10_native" / args.label
    out.mkdir(parents=True, exist_ok=False)
    observer = Path(__file__).resolve().parents[2] / "tests/qa10_native/state_observer.gd"
    if args.observe:
        (out / "observer.gd").write_bytes(observer.read_bytes())
    rows = []
    for name in args.suites:
        label = name.replace("/", "_")
        profile = out / ("profile_" + label)
        profile.mkdir()
        source_path = root / "tests" / (name + ".gd")
        if name.startswith("qa10_native/"):
            source_path = Path(__file__).resolve().parents[2] / "tests" / (name + ".gd")
        original = source_path.read_bytes()
        source = original.decode().replace("user://", profile.as_posix() + "/")
        observe = args.observe and name not in ["cin_tools_03/workspace", "cin_tools_01/authoring"]
        if observe:
            source += ('\nfunc _initialize():\n'
                       '\tvar observer = load("res://' + (out / "observer.gd").relative_to(root).as_posix() + '").new()\n'
                       '\tobserver.harness = self\n\troot.add_child(observer)\n')
            if name == "automatic_passage_reliability":
                source += ('\nfunc shot(name):\n\tprint("QA10_SHOT begin ", name)\n'
                           '\tawait super.shot(name)\n\tprint("QA10_SHOT end ", name)\n')
        script = out / (label + ".gd")
        script.write_text(source, encoding="utf-8")
        flags = ["--test"]
        if name in ["automatic_passage_reliability", "tr08_canal_hang_regression", "qa10_native/focus_lifecycle", "qa10_native/automation_contract"]:
            flags = ["--tr05-save=" + (profile / "normal_save.json").as_posix()]
        cmd = [args.godot] + (["--headless"] if args.headless else []) + [
            "--path", str(root), "--log-file", str(out / (label + ".engine.log")),
            "--fixed-fps", "60", "--script", "res://" + script.relative_to(root).as_posix(), "--",
        ] + flags
        started = time.monotonic()
        started_at = datetime.now(timezone.utc).isoformat()
        try:
            proc = subprocess.run(cmd, cwd=root, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=args.timeout)
            output, code = proc.stdout.decode(errors="replace"), proc.returncode
        except subprocess.TimeoutExpired as exc:
            output, code = (exc.stdout or b"").decode(errors="replace"), 124
        (out / (label + ".log.txt")).write_text(output, encoding="utf-8")
        rows.append(dict(
            suite=name, exit=code, seconds=round(time.monotonic() - started, 2),
            passes=len(re.findall(r"^PASS:", output, re.M)), failures=len(re.findall(r"^FAIL:", output, re.M)),
            script_errors=len(re.findall(r"SCRIPT ERROR|Parse Error|Failed to load", output)),
            source_sha256=hashlib.sha256(original).hexdigest(), command=cmd,
            headless=args.headless, observe=observe,
            started_at=started_at,
        ))
        (out / "results.json").write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(rows[-1]), flush=True)
    return int(any(row["exit"] or row["failures"] or row["script_errors"] for row in rows))


if __name__ == "__main__":
    raise SystemExit(main())
