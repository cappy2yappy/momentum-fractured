extends Node2D
## Capture-only annotation of the Canal contract rectangles (never shipped, never collides).
func _draw():
	draw_rect(Rect2(72,1068,96,132),Color(1,0.9,0.2,0.9),false,3)
	draw_line(Vector2(120,1040),Vector2(120,1215),Color(1,0.2,0.2,0.95),3)
	draw_line(Vector2(0,1020),Vector2(360,1020),Color(0.2,0.9,1,0.9),3)
	draw_line(Vector2(0,1200),Vector2(360,1200),Color(0.3,1,0.4,0.9),2)
	draw_rect(Rect2(0,1110,150,98),Color(1,0.5,0.1,0.15))
