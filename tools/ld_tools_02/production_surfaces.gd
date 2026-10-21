extends Node2D
## Same terrain renderer and room-local rectangles as world._draw, ordered between decoration layers.
const LevelGeometry = preload("res://scripts/level_geometry.gd")
var room = 18
var records: Array[Rect2] = []
func _draw():
	for rect in records:
		if rect.position.x < 0 or rect.position.x >= 2600: continue
		LevelGeometry.draw_surface(self,rect)
