extends "res://scripts/world.gd"
var save_attempts = 0
func save_progress():
	save_attempts += 1
	return super.save_progress()
func _ready():
	save_path = "user://int01_demo_only.json"
	super._ready()
	story.load_data("res://tests/story_demo/objects.json", "res://tests/story_demo/rules.json")
	player.position = Vector2(700,1298)
	message = "[TEST FIXTURE] INT-01 laboratory. E inspect; Esc close."
	message_time = 20
func request_room(_target, _arrival = Vector2.INF):
	pass # Laboratory never enters the campaign.
func build_room(_index):
	super.build_room(0)
	for child in geometry.get_children(): child.queue_free()
	platforms.clear()
	add_platform(Rect2(0,1300,2600,140))
func _draw():
	draw_rect(Rect2(0,0,2600,1440),Color("172532"))
	draw_rect(Rect2(0,1300,2600,140),Color("384e59"))
	if story.world != null: story.draw_room(self)
