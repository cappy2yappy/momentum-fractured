#!/usr/bin/env python3
"""ART-07 Phase 1: package Godot validation and native capture evidence.

Usage: python3 -I tools/art07/package_evidence.py VALIDATE_LOG CAPTURE_LOG
  VALIDATE_LOG  stdout of validate_idle_godot.gd (RESULT / SUMMARY lines)
  CAPTURE_LOG   stdout of capture_idle_godot.gd (RENDERER / GODOT lines)
Writes GODOT_VALIDATION.json, godot_capture/NATIVE_RENDER.txt and a GIF assembled from the
real captured framebuffers (cropped to the 960x540 fixture area). The GIF is a derived
preview built from 16 timed samples, not a continuous screen recording.
"""
import json
import os
import re
import sys

from PIL import Image

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DOC = os.path.join(REPO, "docs/art/art07/idle_procedural")


def clean(path):
    return re.sub(r"\x1b\[[0-9;]*m", "", open(path, encoding="utf-8", errors="replace").read())


def main(val_log, cap_log):
    checks, summary = [], ""
    for line in clean(val_log).splitlines():
        if line.startswith("RESULT "):
            checks.append(json.loads(line[len("RESULT "):]))
        elif line.startswith("SUMMARY"):
            summary = line
    out = {
        "script": "tools/art07/validate_idle_godot.gd",
        "command": "godot --headless --path . --script res://tools/art07/validate_idle_godot.gd",
        "summary": summary, "checks": checks, "passed": bool(checks) and all(c["pass"] for c in checks),
        "scope": "Imported-texture contract and pixel checks plus player.gd-style Sprite2D stepping. Does not run the player scene, physics or the default binding.",
    }
    with open(os.path.join(DOC, "GODOT_VALIDATION.json"), "w") as fh:
        json.dump(out, fh, indent=2, sort_keys=True)

    cap = [ln for ln in clean(cap_log).splitlines() if ln.startswith(("RENDERER", "GODOT", "CAPTURE_DONE"))]
    os.makedirs(os.path.join(DOC, "godot_capture"), exist_ok=True)
    with open(os.path.join(DOC, "godot_capture/NATIVE_RENDER.txt"), "w") as fh:
        fh.write("command: xvfb-run -a -s \"-screen 0 1280x720x24\" godot --rendering-method gl_compatibility "
                 "--rendering-driver opengl3 --resolution 960x540 --path . --script res://tools/art07/capture_idle_godot.gd\n")
        fh.write("\n".join(cap) + "\n")
        fh.write("note: software GL (llvmpipe) under a virtual display in a cloud sandbox. Not a GPU, not Windows or macOS, "
                 "not a human play session. Samples are timed ticks of 80 ms, not a continuous recording.\n")
    frames = []
    for i in range(16):
        im = Image.open(os.path.join(DOC, f"godot_capture/tick_{i:02d}.png")).convert("RGB").crop((0, 0, 960, 540))
        frames.append(im)
    pal_src = Image.new("RGB", (960, 540 * 16))
    for i, f in enumerate(frames):
        pal_src.paste(f, (0, 540 * i))
    pal = pal_src.quantize(colors=200, method=Image.MEDIANCUT, dither=Image.NONE)
    q = [f.quantize(palette=pal, dither=Image.NONE) for f in frames]
    q[0].save(os.path.join(DOC, "godot_native_playback_16ticks.gif"), save_all=True, append_images=q[1:],
              duration=[80] * 16, loop=0, disposal=1, optimize=False)
    print("packaged; godot validation passed =", out["passed"])


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
