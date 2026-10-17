# ART-06 PM report: R18 Pump Gallery environmental production pilot

Branch `art/art06-r18-environment`, stacked on PR41 `60859a8`. Draft PR only, no merge.

## Delivered
- 3 painted environment concepts (whole room, machine hall, east isolator).
- 16-piece transparent modular set at game scale: ledge cap tile, floor face tile, pipe tile, pier, relieving arch, timber beam, pump drum, pipe elbow, broken support, damaged building, back wall, isolator frame, lantern bracket, routing plate, steam column, foreground occluder.
- Layered ORA source with collider/keep-clear guide; lossless high-res masters.
- Native Godot 4.6.1 before captures and collider dump; native after captures with proposed hooks applied in a throwaway copy.
- Data-driven layer and collision contract, validator, compositor, packaging and capture tools.
- Codex/Level handoff and QC notes.

## Coordination state
- Level Masta: no R18 redesign exists yet for #43. Art registers to current colliders and tags the 10 generated slabs as interim. Re-fit procedure and geometry requests are in IMPLEMENTATION_HANDOFF.md section 4. Art did not wait on Level and did not change collision.
- Codex: four hook lines proposed, tested natively in a patched copy only. Export include filter for the layout JSON is an open item.
- Story: follows ST-03 R18 row and post-attack framing; no refuge imagery.

## Not done / needs decision
- Creator style acceptance.
- Exported-build, non-Linux GPU and performance verification.
- Hand paint cleanup of generated assets; tall-pier and second floor-tile variants.
- R13/R15/R16/R17/R19/R20 passes (out of scope per #43).

Tools: Higgsfield MCP (GPT Image 2.5) for generation; Pillow for deterministic processing; official Godot 4.6.1 Linux for captures. No Aseprite/Krita authoring claimed.
