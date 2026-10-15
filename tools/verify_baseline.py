"""Check the creator-approved artwork and controller without importing Godot."""
import hashlib
import json
from pathlib import Path
import struct
import sys

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / "assets/web/kaze_manifest.json").read_text())
controller = (root / "scripts/player.gd").read_bytes()
controller_text = controller.decode("utf-8")
failures = []
if hashlib.sha256(controller).hexdigest() != manifest["controller_sha256"]:
    failures.append("Controller differs from the approved baseline; review movement preservation before updating the contract.")
for item in manifest["sprites"]:
    path = root / item["path"]
    if not path.is_file():
        failures.append(f"Missing sprite: {item['path']}")
        continue
    data = path.read_bytes()
    if hashlib.sha256(data).hexdigest() != item["sha256"]:
        failures.append(f"Sprite checksum changed: {item['path']}")
    if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n":
        failures.append(f"Invalid PNG: {item['path']}")
        continue
    width, height = struct.unpack(">II", data[16:24])
    if (width, height) != (item["width"], item["height"]) or width % item["frames"]:
        failures.append(f"Sprite dimensions/frame layout changed: {item['path']}")
    binding = f'clips["{item["clip"]}"] = load("res://{item["path"]}")'
    if binding not in controller_text:
        failures.append(f"Runtime clip no longer uses approved sheet: {item['clip']}")
    print(f"Checked {item['clip']}: {item['path']} ({width} x {height}, {item['frames']} frames)")
for failure in failures:
    print("FAIL:", failure)
print(f"Approved baseline verification: {len(failures)} failure(s)")
sys.exit(bool(failures))
