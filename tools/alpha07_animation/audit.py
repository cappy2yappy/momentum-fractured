"""Read-only animation recovery audit; does not modify artwork or bindings."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import subprocess

ROOT = Path(__file__).resolve().parents[2]

def inspect(path, frames):
    data = (ROOT / path).read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", path
    width, height = struct.unpack(">II", data[16:24])
    assert width % frames == 0, path
    return {"path": path, "sha256": hashlib.sha256(data).hexdigest(),
            "bytes": len(data), "dimensions": [width, height],
            "frames": frames, "cell": [width // frames, height]}

def audit():
    approved = json.loads((ROOT / "assets/web/kaze_manifest.json").read_text())
    art = json.loads((ROOT / "assets/art08/MANIFEST.json").read_text())
    result = {"base_sha": subprocess.check_output(["git", "rev-parse", "origin/tools/cin-tools-01-cutin-maker"], cwd=ROOT, text=True).strip(),
              "image4": {"status": "blocked_missing_creator_source", "supplied_path": None,
                         "replacement_generated": False}, "approved": [], "clips": [], "failures": []}
    supplied = ROOT / "source_art/art09-image4/image4-original.png"
    if supplied.is_file():
        result["image4"] = {"status": "supplied_extracted_candidate_only", "supplied_path": str(supplied.relative_to(ROOT)), "sha256": hashlib.sha256(supplied.read_bytes()).hexdigest(), "replacement_generated": False}
    for item in approved["sprites"] + approved.get("previous_sprites", []):
        row = inspect(item["path"], item["frames"])
        row["matches_manifest"] = row["sha256"] == item["sha256"]
        if not row["matches_manifest"]: result["failures"].append(item["path"])
        result["approved"].append(row)
    for item in art["clips"]:
        row = {key: item.get(key) for key in ("name", "status", "provenance", "fps", "durations", "loop", "pivot", "facing", "contact_frames", "root_motion_px_per_frame", "alias_of")}
        if item["status"] != "unfinished":
            row.update(inspect(item["strip"], item["hframes"]))
            row["matches_manifest"] = row["sha256"] == item["sha256"]
            row["matches_cell"] = row["cell"] == item["cell"]
            if not row["matches_manifest"] or not row["matches_cell"]: result["failures"].append(item["name"])
        result["clips"].append(row)
    return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = audit()
    encoded = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded)
    print(f"Approved sheets: {len(result['approved'])}; ART08 entries: {len(result['clips'])}; integrity failures: {len(result['failures'])}")
    print("Image4:", result["image4"]["status"])
    raise SystemExit(bool(result["failures"]))
