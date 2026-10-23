extends "res://tools/cin_tools_01/preview.gd"
## Reuses Cut-In Maker controls; native scenes remain the source of truth.
func _ready():
 choices = ["aftermath", "resistance", "fallen_defenders"]
 preset = load("res://presets/cutins/story/aftermath.tscn")
 super._ready()
 var controls = get_child(1).get_child(1).get_child(0).get_child(0)
 for connection in controls.item_selected.get_connections():
  controls.item_selected.disconnect(connection.callable)
 controls.item_selected.connect(func(i):
  preset = load("res://presets/cutins/story/" + choices[i] + ".tscn")
  open_preset())

func _process(dt):
 super._process(dt)
 status.text = "%.2f / %.2f s | CIN-04 review | Edit props and AnimationPlayer tracks in the saved scene." % [slider.value, slider.max_value]
