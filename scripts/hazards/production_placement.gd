extends RefCounted
## Conservative gate for future creator-marked placements, never edits geometry.
## All exclusion volumes are room-local Rect2s. Caller supplies surveyed data.
static func validate(placement, platforms: Array, recovery_floors: Array, doors: Array, checkpoints: Array, interactables: Array, has_timing_window_or_bypass: bool) -> PackedStringArray:
	var errors = placement.validation_errors()
	if placement.kind == "collapse": errors.append("collapse adds collision: prototype only, forbidden in production")
	if not has_timing_window_or_bypass: errors.append("requires a surveyed timing window or bypass")
	var rect = Rect2(placement.at, placement.dimensions)
	var supported = false
	for surface in platforms:
		if surface.encloses(rect): supported = true
	if not supported: errors.append("damage volume must lie inside surveyed existing platform geometry")
	for floor_rect in recovery_floors:
		if rect.intersects(floor_rect, true): errors.append("overlaps recovery floor")
	for door in doors:
		if rect.intersects(door.grow(200), true): errors.append("inside 200px door approach")
	for checkpoint in checkpoints:
		if rect.intersects(checkpoint, true): errors.append("overlaps checkpoint exclusion")
	for interactable in interactables:
		if rect.intersects(interactable, true): errors.append("overlaps interactable exclusion")
	return errors
