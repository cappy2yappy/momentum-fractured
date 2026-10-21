@tool
extends Marker2D
@export_enum("Entrance", "Exit", "Pickup", "Checkpoint", "Hazard") var kind := "Entrance"
@export var design_note := "Metadata only; no gameplay behavior"
func _process(_delta):
	visible = Engine.is_editor_hint()
	if visible: queue_redraw()
func _draw():
	if not Engine.is_editor_hint(): return
	draw_circle(Vector2.ZERO,14,Color("e5a7d8"),false,2)
	draw_line(Vector2(-22,0),Vector2(22,0),Color("e5a7d8"),2)
	draw_line(Vector2(0,-22),Vector2(0,22),Color("e5a7d8"),2)
	draw_string(ThemeDB.fallback_font,Vector2(24,0),kind + " (metadata)",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
