extends RefCounted
## Review-only contract; never authorizes production activation.
const Raster = preload("res://tools/art10/raster_contact.gd")
const PHASES = ["approach", "sprint", "stairs", "brake", "settle"]
static func point(value) -> bool:
	return value is Array and value.size() == 2 and number(value[0]) and number(value[1])

static func number(value) -> bool:
	return (value is float or value is int) and is_finite(float(value))

static func validate_clip(clip: Dictionary, check_assets := true) -> Array:
	var errors: Array = []
	var frames = clip.get("frames", [])
	var treads = clip.get("treads", [])
	if not frames is Array or frames.size() < 12:
		return ["At least 12 authored frames required; sparse source keys are insufficient."]
	if not treads is Array or treads.is_empty():
		return ["Fixed staircase treads required."]
	for tread in treads:
		if not tread is Array or tread.size() != 3:
			return ["Treads must be [left, right, top]."]
		if not number(tread[0]) or not number(tread[1]) or not number(tread[2]) or tread[0] >= tread[1]:
			return ["Tread bounds must be finite and increase."]
	var phases: Array = []
	var regions: Dictionary = {}
	var pixels: Dictionary = {}
	var images: Dictionary = {}
	var expected_size = Vector2i.ZERO
	var last_phase := -1
	var planted: Dictionary = {}
	var stair_contacts: Array = []
	for frame in frames:
		if not frame is Dictionary:
			errors.append("Frame must be a dictionary.")
			continue
		var phase = frame.get("phase", "")
		var phase_index = PHASES.find(phase)
		if phase_index < 0 or phase_index < last_phase: errors.append("Invalid phase order.")
		last_phase = phase_index
		if phase not in phases: phases.append(phase)
		var duration = frame.get("duration", 0)
		if not number(duration) or float(duration) <= 0: errors.append("Duration must be finite and positive.")
		if not point(frame.get("root")) or not point(frame.get("pivot")):
			errors.append("Root and pivot must be finite points.")
			continue
		var region = frame.get("region", [])
		if not region is Array or region.size() != 4:
			errors.append("Atlas region required.")
			continue
		var valid_region := true
		for value in region:
			if not number(value) or float(value) != floorf(float(value)): valid_region = false
		if not valid_region:
			errors.append("Atlas region must contain integer pixels.")
			continue
		if region[0] < 0 or region[1] < 0 or region[2] <= 0 or region[3] <= 0:
			errors.append("Atlas region bounds invalid.")
			continue
		var asset = str(frame.get("asset", ""))
		if not asset.begins_with("res://assets/art10/") or ".." in asset:
			errors.append("Only isolated ART10 art may be bound.")
			continue
		regions[asset + str(region)] = true
		var raster: Image
		if check_assets:
			if not images.has(asset): images[asset] = Image.load_from_file(asset)
			var image = images[asset]
			if image == null or image.is_empty():
				errors.append("Missing artwork: " + asset)
				continue
			if region[0]+region[2] > image.get_width() or region[1]+region[3] > image.get_height():
				errors.append("Atlas region exceeds image.")
				continue
			raster = image.get_region(Rect2i(region[0],region[1],region[2],region[3]))
			errors.append_array(Raster.inspect(raster,Vector2(frame.pivot[0],frame.pivot[1])))
			if expected_size == Vector2i.ZERO: expected_size = raster.get_size()
			elif raster.get_size() != expected_size: errors.append("Inconsistent frame dimensions.")
			pixels[Raster.digest(raster)] = true
		var current_plants: Dictionary = {}
		var contacts = frame.get("contacts", [])
		if not contacts is Array:
			errors.append("Contacts must be an array.")
			continue
		for contact in contacts:
			if not contact is Dictionary or contact.get("foot", "") not in ["left", "right"] or not point(contact.get("sole")):
				errors.append("Contact needs foot and measured sole.")
				continue
			if current_plants.has(contact.foot): errors.append("Duplicate foot contact.")
			if check_assets and not Raster.supported(raster,Vector2(contact.sole[0],contact.sole[1])):
				errors.append("Contact marker lacks visible sole-edge support.")
			var ti = contact.get("tread", -1)
			if not number(ti) or float(ti) != floorf(float(ti)) or ti < 0 or ti >= treads.size():
				errors.append("Invalid contact tread.")
				continue
			var sole = Vector2(frame.root[0], frame.root[1]) + Vector2(contact.sole[0], contact.sole[1]) - Vector2(frame.pivot[0], frame.pivot[1])
			var tread = treads[int(ti)]
			if sole.x < tread[0] or sole.x > tread[1] or absf(sole.y-tread[2]) > 1.0:
				errors.append("Measured sole misses fixed tread.")
			var foot: String = contact.foot
			if planted.has(foot) and planted[foot].distance_to(sole) > 1.0:
				errors.append("Stance foot slides during consecutive contact.")
			current_plants[foot] = sole
			if phase == "stairs" and (stair_contacts.is_empty() or stair_contacts.back() != foot):
				stair_contacts.append(foot)
		planted = current_plants
	if phases != PHASES: errors.append("All five production phases required.")
	if check_assets and pixels.size() < 12: errors.append("Fewer than twelve distinct raster drawings.")
	if regions.size() < 12: errors.append("Repeated static keys are not a production cycle.")
	if stair_contacts.size() < 4: errors.append("At least four alternating stair contacts required.")
	var last = frames.back()
	if last is Dictionary and last.get("contacts", []) is Array:
		var final_feet: Array = []
		for contact in last.get("contacts", []):
			if contact is Dictionary: final_feet.append(contact.get("foot", ""))
		final_feet.sort()
		if final_feet != ["left", "right"]: errors.append("Final settle needs both feet grounded.")
	if frames[-1] is Dictionary and frames[-2] is Dictionary and frames[-1].get("root") != frames[-2].get("root"):
		errors.append("Settle must end without root drift.")
	return errors

static func frame_at(frames: Array, elapsed: float) -> int:
	var remaining = maxf(0.0, elapsed)
	for index in frames.size():
		remaining -= float(frames[index].duration)
		if remaining < 0: return index
	return frames.size()-1
