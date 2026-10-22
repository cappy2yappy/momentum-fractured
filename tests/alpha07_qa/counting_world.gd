extends "res://scripts/world.gd"
var qa_save_calls = 0
func save_progress() -> bool:
 qa_save_calls += 1
 return super.save_progress()
