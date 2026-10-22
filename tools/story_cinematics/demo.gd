extends Node
## Separate process fixture. No StoryDirector replacement and no shipping hooks.
const Presenter = preload("res://scripts/story/cutin_presenter.gd")
var world
var presenter
var banner: Label

func _ready():
 world = load("res://scenes/main.tscn").instantiate()
 world.save_path = "user://story_cinematics_fixture_only.json"
 add_child(world)
 world.message_time = 0
 presenter = Presenter.new()
 add_child(presenter)
 presenter.configure(world)
 var overlay = CanvasLayer.new()
 overlay.layer = 110
 add_child(overlay)
 banner = Label.new()
 banner.position = Vector2(15, 664)
 banner.add_theme_font_size_override("font_size", 16)
 overlay.add_child(banner)

func _process(dt):
 presenter.reduced = world.cinematic_transitions.reduced
 presenter.update(world, dt)
 banner.text = "STORY REVIEW ONLY | 1 opening  2 record  3 provisional timing | SPACE / pad B skip | F6 reduced\nMove with A/D or gamepad. ESC pause. %s" % presenter.last_outcome

func _unhandled_key_input(event):
 if not event.pressed or event.echo: return
 var ids = {KEY_1: "opening_review", KEY_2: "record_review", KEY_3: "fallen_clan_review"}
 if ids.has(event.physical_keycode): presenter.request_cutin(ids[event.physical_keycode])
