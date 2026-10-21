@tool
extends Node2D
## PackedScene metadata remains the identity contract. These toggles are editor-only overlays.
@export var show_boundaries := true
@export var show_collision_overlay := true

func _process(_delta):
	if Engine.is_editor_hint():
		for surface in find_children("*", "CollisionShape2D", true, false):
			surface.visible = show_collision_overlay
		queue_redraw()

func _draw():
	if not Engine.is_editor_hint() or not show_boundaries: return
	var bounds = get_meta("room_size", Vector2(2600,1440))
	draw_rect(Rect2(Vector2.ZERO,bounds),Color("87cde5"),false,4)
	# The actual 1280x720 game viewport gives an editing scale reference.
	draw_rect(Rect2(Vector2.ZERO,Vector2(1280,720)),Color("87cde580"),false,2)
	draw_string(ThemeDB.fallback_font,Vector2(24,40),"ROOM %s | %s px | inner frame: 1280 x 720 viewport" % [get_meta("room_id",-1),bounds],HORIZONTAL_ALIGNMENT_LEFT,-1,24)
