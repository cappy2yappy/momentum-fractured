#!/usr/bin/env python3
"""ART-07 Phase 1: write assets/art07/MANIFEST.json (hashes, contract, status). Run LAST.

Usage: python3 -I tools/art07/write_manifest.py
Hashes every file under assets/art07 (except the manifest), source_art/art07, docs/art/art07
and tools/art07. Verify a checkout with: python3 -I tools/art07/write_manifest.py --verify
"""
import hashlib
import json
import os
import sys

from PIL import Image

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ROOTS = ["assets/art07", "source_art/art07", "docs/art/art07", "tools/art07"]
MANIFEST = "assets/art07/MANIFEST.json"
ENGINE_SCALE = 0.2649908807267889
SOURCE = {"strip": "assets/kaze/cleaned/kaze_idle_strip.png",
          "sha256": "03db06f8670a4247bf98100b2a40e936bc3fff7ee27f90a02c7a3d47aea95697", "frame_index": 1}


def sha(p):
    with open(p, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


def inventory():
    inv = []
    for root in ROOTS:
        for d, dirs, files in os.walk(os.path.join(REPO, root)):
            dirs[:] = sorted(x for x in dirs if x != "__pycache__")
            for fn in sorted(files):
                full = os.path.join(d, fn)
                rel = os.path.relpath(full, REPO).replace(os.sep, "/")
                if rel == MANIFEST or fn.endswith(".pyc"):
                    continue
                e = {"path": rel, "sha256": sha(full), "bytes": os.path.getsize(full)}
                if fn.endswith((".png", ".gif")):
                    with Image.open(full) as im:
                        e["size"] = list(im.size)
                inv.append(e)
    return sorted(inv, key=lambda e: e["path"])


def main():
    if "--verify" in sys.argv:
        m = json.load(open(os.path.join(REPO, MANIFEST)))
        bad = 0
        for e in m["assets"]:
            p = os.path.join(REPO, e["path"])
            ok = os.path.exists(p) and sha(p) == e["sha256"]
            bad += 0 if ok else 1
            if not ok:
                print("MISMATCH", e["path"])
        print(f"verified {len(m['assets'])} files, {bad} mismatch(es)")
        sys.exit(1 if bad else 0)
    qa = json.load(open(os.path.join(REPO, "docs/art/art07/idle_procedural/QA_REPORT.json")))
    gv = json.load(open(os.path.join(REPO, "docs/art/art07/idle_procedural/GODOT_VALIDATION.json")))
    manifest = {
        "schema_version": 1,
        "task": "ART-07R Phase 1",
        "status": "candidate_optional_not_approved",
        "method": "procedural_displacement_of_one_approved_frame",
        "honesty": "Deterministic pixel displacement of approved artwork. It is not redrawn animation, adds no new pose, expression or silhouette, and is not equivalent to a hand-animated idle. The approved idle strip is untouched and remains the default.",
        "source": SOURCE,
        "contract": {
            "cell_px": [272, 724], "baseline_row": 591, "engine_scale": ENGINE_SCALE,
            "sprite_offset": "(0, texture_height/2 - baseline) = (0, -229)", "flip": "flip_h = facing < 0",
            "registration": "no per-frame trim, resize or recentre; rows 548 and below are byte-identical to the approved frame",
            "sets": {
                "8f": {"strip": "assets/art07/idle_procedural/kaze_idle_procedural_8f_strip.png", "hframes": 8,
                       "frame_duration_s": 0.16, "loop_s": 1.28, "engine_change_required": False,
                       "note": "Same dimensions and timing as the live idle strip. Binding it is a texture-path swap that was NOT made."},
                "16f": {"strip": "assets/art07/idle_procedural/kaze_idle_procedural_16f_strip.png", "hframes": 16,
                        "frame_duration_s": 0.08, "loop_s": 1.28, "engine_change_required": True,
                        "note": "player.gd hardcodes sprite.hframes = 8 and a 0.16 s divisor for idle; this set needs engine edits that were NOT made."},
            },
        },
        "qa": {"pixel_qa_passed_all": qa["passed_all"], "godot_validation_passed": gv["passed"],
               "godot_validation_summary": gv["summary"]},
        "assets": inventory(),
    }
    with open(os.path.join(REPO, MANIFEST), "w") as fh:
        json.dump(manifest, fh, indent=2, sort_keys=True)
    print("manifest files:", len(manifest["assets"]))


if __name__ == "__main__":
    main()
