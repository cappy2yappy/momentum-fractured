extends "res://scripts/art04_presentation.gd"
## Test-harness only: answers the existing suppresses_legacy() hook for R18 so the
## placeholder pump-drum circles are not drawn under ART-06 dressing. Mirrors the
## one-line runtime change proposed in docs/art/art06/IMPLEMENTATION_HANDOFF.md.
func suppresses_legacy(e, index: int, bounds: Rect2) -> bool:
	if index == 18: return true
	return super.suppresses_legacy(e, index, bounds)
