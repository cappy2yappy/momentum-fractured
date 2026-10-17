#!/usr/bin/env python3
"""Create a THROWAWAY patched copy of the runtime with the ART-06 R18 hooks applied,
so the proposal can be rendered natively without editing scripts/ in this branch.

Writes tools/art06/_patched/{world.gd, world_expansion.gd, main.tscn} (untracked).
Exits non-zero if any anchor line is not found exactly once (patch would be stale).
Usage: apply_proposed_hooks.py REPO_ROOT
"""
import sys
from pathlib import Path

root = Path(sys.argv[1]); out = root / "tools/art06/_patched"; out.mkdir(parents=True, exist_ok=True)
P = "res://tools/art06/_patched/"

def patch(src, edits):
    text = (root / src).read_text()
    for old, new in edits:
        n = text.count(old)
        if n != 1: sys.exit(f"anchor not unique in {src} ({n}): {old!r}")
        text = text.replace(old, new)
    return text

world = patch("scripts/world.gd", [
    ('const Expansion = preload("res://scripts/world_expansion.gd")',
     f'const Expansion = preload("{P}world_expansion.gd")\nconst R18Dressing = preload("res://tools/art06/proposed/r18_dressing.gd")'),
    ("\tRoomPresentation.draw_background(self)\n",
     "\tRoomPresentation.draw_background(self)\n\tR18Dressing.draw_back(self)\n"),
    ("\t\tLevelGeometry.draw_surface(self,rect)\n",
     "\t\tif not R18Dressing.draw_surface(self,rect): LevelGeometry.draw_surface(self,rect)\n"),
    ("\tcinematic_transitions.room_loaded(self)\n\tqueue_redraw()",
     "\tcinematic_transitions.room_loaded(self)\n\tR18Dressing.room_loaded(self)\n\tqueue_redraw()"),
])
expansion = patch("scripts/world_expansion.gd", [
    ("\t\t\tif w.room==14: continue # LD03 uses grounded service-walk architecture.\n",
     "\t\t\tif w.room==14: continue # LD03 uses grounded service-walk architecture.\n"
     "\t\t\tif w.room==18 and w.R18Dressing.enabled(w): continue # ART06 replaces placeholder drums.\n"),
])
(out / "world.gd").write_text(world)
(out / "world_expansion.gd").write_text(expansion)
(out / "main.tscn").write_text(
    '[gd_scene format=3]\n\n[ext_resource type="Script" path="%sworld.gd" id="1"]\n\n'
    '[node name="CanalRoute" type="Node2D"]\nscript = ExtResource("1")\n' % P)
print("patched copies written to", out)
