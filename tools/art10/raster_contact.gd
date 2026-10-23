extends RefCounted
## Raster checks are evidence, not anatomy or creator approval.
static func inspect(image: Image, pivot: Vector2) -> Array:
	var errors: Array = []
	if image == null or image.is_empty(): return ["Empty frame."]
	var size = image.get_size()
	if pivot.x < 0 or pivot.y < 0 or pivot.x >= size.x or pivot.y >= size.y:
		errors.append("Pivot outside frame.")
	var used = image.get_used_rect()
	if used.size == Vector2i.ZERO: errors.append("Fully transparent frame.")
	elif used.position.x == 0 or used.position.y == 0 or used.end.x == size.x or used.end.y == size.y:
		errors.append("Opaque artwork touches frame boundary.")
	return errors

static func supported(image: Image, at: Vector2) -> bool:
	# Coordinates identify the outer edge of the sole. Accept antialiased
	# visible pixels immediately above/at the marker, but not deep interior.
	if at.x < 0 or at.y < 0 or at.x >= image.get_width() or at.y >= image.get_height(): return false
	var x = int(round(at.x)); var y = int(round(at.y))
	var visible := false
	for dx in range(-1,2):
		for dy in range(-1,1):
			var p=Vector2i(x+dx,y+dy)
			if p.x>=0 and p.y>=0 and p.x<image.get_width() and p.y<image.get_height():
				if image.get_pixelv(p).a >= 0.2: visible=true
	if not visible: return false
	for dy in range(2,4):
		var p=Vector2i(x,y+dy)
		if p.x>=0 and p.x<image.get_width() and p.y<image.get_height() and image.get_pixelv(p).a >= 0.2: return false
	return true

static func digest(image: Image) -> String:
	var canonical=image.duplicate()
	canonical.convert(Image.FORMAT_RGBA8)
	# Transparent RGB must not disguise duplicate drawings.
	for y in canonical.get_height():
		for x in canonical.get_width():
			if canonical.get_pixel(x,y).a == 0: canonical.set_pixel(x,y,Color.TRANSPARENT)
	var h=HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(canonical.get_data())
	return h.finish().hex_encode()
