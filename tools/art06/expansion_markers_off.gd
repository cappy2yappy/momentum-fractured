extends "res://scripts/world_expansion.gd"
## Capture-only: same expansion behaviour, but can hide portal doors/labels so the
## capture script can isolate the runtime interactive markers as a separate pass.
var hide_portals := false
func portals(index: int) -> Array:
	if hide_portals: return []
	return super.portals(index)
