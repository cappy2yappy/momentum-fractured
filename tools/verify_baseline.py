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
rollback_path = root / "tests/fixtures/player_alpha052.gd"
if "rollback_controller_sha256" in manifest:
    rollback = rollback_path.read_bytes()
    if hashlib.sha256(rollback).hexdigest() != manifest["rollback_controller_sha256"]:
        failures.append("Rollback controller reference changed.")
    rollback_text = rollback.decode("utf-8")
    for method, following in [("animate", "damage"), ("integrate_tether_swing", "_draw")]:
        def body(text):
            return text[text.index(f"func {method}"):text.index(f"func {following}")]
        if body(controller_text) != body(rollback_text):
            failures.append(f"Preserved {method} differs from restored-size Alpha 0.5.2.")
if "physics_sha256" in manifest:
    physics = controller_text[controller_text.index("func _physics_process"):controller_text.index("func animate")]
    if hashlib.sha256(physics.encode()).hexdigest() != manifest["physics_sha256"]:
        failures.append("Physics process differs from the documented movement contract.")
for item in manifest.get("previous_sprites", []):
    if hashlib.sha256((root / item["path"]).read_bytes()).hexdigest() != item["sha256"]:
        failures.append(f"Original artwork changed: {item['path']}")
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
