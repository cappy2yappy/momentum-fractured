# FRACTURED Room Editor

Web-based level design tool for creating rooms.

## Usage

**Online:** https://laibyrinth.com/fractured-room-editor.html

**Or run locally:**
```bash
open tools/room-editor.html
```

## Controls

- **Platform tool:** Click & drag to create floor/wall platforms
- **Enemy tool:** Click to place enemy spawn points
- **Grapple tool:** Click to place grapple hooks
- **Hazard tool:** Click to place saws/lasers/traps
- **Right-click:** Delete object
- **Export JSON:** Copy room data to clipboard

## Workflow

1. Design room in editor
2. Click "Export JSON"
3. Paste into `rooms/[biome]/room_XX.json`
4. Godot will load it automatically

## Tips

- Grid snaps to 10px for clean alignment
- Keep platform count under 30 per room (performance)
- Place enemies away from spawn point
- Grapple points should be reachable (upward-only rule)
