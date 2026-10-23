#!/usr/bin/env python3
"""Verified ART-11 local review. Asset bytes never enter tracked source or CI artifacts."""
import argparse, hashlib, json, os, subprocess, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
CODE = ROOT / "tools/art11"
sys.path.insert(0, str(ROOT / "tools/asset01"))
from review_pilot import verify

def contract(root, name):
    entries = json.loads((CODE / (name + "-contract.json")).read_text())
    for entry in entries:
        file = root / entry["path"]
        data = file.read_bytes()
        sha = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        if sha != entry["sha"]:
            raise ValueError("Pinned host changed: " + entry["path"])
    return len(entries)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", type=Path, required=True)
    parser.add_argument("--godot", required=True)
    parser.add_argument("--mode", choices=["prepare", "gallery", "moss", "cave", "enemy", "hazard", "validate"], default="gallery")
    parser.add_argument("--host", type=Path)
    parser.add_argument("--cache", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--baseline", action="store_true")
    args = parser.parse_args()
    stage = args.stage.resolve()
    verify(stage)
    cache = (args.cache or ROOT / "build/art11/cache").resolve()
    output = (args.output or ROOT / "build/art11/review").resolve()
    output.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    profile = ROOT / "build/art11/profile" / args.mode
    profile.mkdir(parents=True, exist_ok=True)
    if os.name == "nt":
        env["APPDATA"] = str(profile.resolve())
        env["LOCALAPPDATA"] = str(profile.resolve())
    else:
        env["XDG_DATA_HOME"] = str(profile.resolve())
        env["XDG_CONFIG_HOME"] = str(profile.resolve())
    base = [args.godot, "--rendering-method", "gl_compatibility"]
    if args.mode == "prepare":
        command = base + ["--headless", "--path", str(CODE / "gallery"), "--script", str(CODE / "prepare.gd"),
                          "--", str(stage), str(CODE / "selections.json"), str(cache)]
    elif args.mode == "validate":
        if not args.host: parser.error("--mode validate requires the pinned --host")
        contract(args.host.resolve(), "host")
        command = base + ["--headless", "--path", str(args.host.resolve()), "--script", str(CODE / "validate.gd"),
                          "--", str(CODE), str(cache), str(output / "validation.json")]
    elif args.mode == "gallery":
        contract(ROOT, "world")
        command = base + ["--path", str(CODE / "gallery"), "--", "--code=" + str(CODE), "--cache=" + str(cache)]
        if args.check:
            command += ["--capture=" + str(output / "candidate_gallery.png")]
    else:
        host = args.host.resolve() if args.mode in ["enemy", "hazard"] and args.host else ROOT
        contract(host, "host" if args.mode in ["enemy", "hazard"] else "world")
        command = base + ["--path", str(host), "--script", str(CODE / "pilot.gd"), "--",
                          "--test", "--code=" + str(CODE), "--cache=" + str(cache), "--mode=" + args.mode,
                          "--output=" + str(output)]
        if args.check: command += ["--check"]
        if args.baseline: command += ["--baseline"]
    print("ART-11 verified local " + args.mode + " review", flush=True)
    try:
        with (output / (args.mode + ("_baseline" if args.baseline else "") + ".log")).open("w", encoding="utf8") as log:
            result = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT,
                                    timeout=120 if args.check or args.mode in ["prepare", "validate"] else None)
        print("Exit:", result.returncode, "Log:", log.name)
        return result.returncode
    except subprocess.TimeoutExpired:
        print("Engine did not complete; inspect " + log.name, file=sys.stderr)
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
