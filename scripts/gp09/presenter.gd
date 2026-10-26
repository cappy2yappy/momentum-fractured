extends "res://scripts/story/cutin_presenter.gd"
## Room-local copy only. The approved request/update/cancel interface is inherited.
func request_cutin(id: String) -> void:
	if id != "record_review" or world.story.has("evt/gp09_presented"): return
	if active_id == id or pending.has(id): return
	super.request_cutin(id)

func apply_labels(_id: String):
	cutin.get_node("Title").text = "AN ABANDONED TRACE\nSomeone passed through here."
	cutin.get_node("Title").add_theme_font_size_override("font_size", 30)
	cutin.get_node("Destination").text = "GP-09 / PROVISIONAL — no identity or fate is established."
