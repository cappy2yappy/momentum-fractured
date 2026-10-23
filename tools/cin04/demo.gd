extends Node
## Separate review process. The live world remains unchanged; no campaign bindings.
const Presenter = preload("res://scripts/story/cutin_presenter.gd")
var world
var presenter
var banner: Label
var choice = "cin04_aftermath"

func _ready():
 world = load("res://scenes/main.tscn").instantiate()
 # Assigned BEFORE _ready/load_progress: never read a real save, even with F6 launch.
 world.save_path = "user://cin04_review_disposable.json"
 add_child(world)
 world.test_mode = true
 world.message_time = 0
 presenter = Presenter.new()
 add_child(presenter)
 presenter.configure(world)
 var layer = CanvasLayer.new()
 layer.layer = 110
 add_child(layer)
 banner = Label.new()
 banner.position = Vector2(18, 704)
 banner.add_theme_font_size_override("font_size", 12)
 layer.add_child(banner)

func _process(dt):
 presenter.reduced = world.cinematic_transitions.reduced
 presenter.update(world, dt)
 banner.text = "REVIEW ONLY | 1 Aftermath   2 Resistance   3 Fallen defenders | SPACE / B skip | F6 reduced: %s | R replay | %s" % [presenter.reduced, presenter.last_outcome]

func _unhandled_key_input(event):
 if not event.pressed or event.echo: return
 var ids = {KEY_1: "cin04_aftermath", KEY_2: "cin04_resistance", KEY_3: "cin04_fallen_defenders"}
 if ids.has(event.physical_keycode):
  presenter.cancel("review_selection")
  choice = ids[event.physical_keycode]
  presenter.request_cutin(choice)
 elif event.physical_keycode == KEY_R:
  presenter.cancel("replay")
  presenter.request_cutin(choice)
