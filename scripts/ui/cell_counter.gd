extends Control

@onready var _value_label: Label = $Panel/HBox/Value

var _current_cells: int = 0


func set_cells(total_cells: int) -> void:
	var delta := total_cells - _current_cells
	_current_cells = total_cells
	_value_label.text = "%d" % _current_cells

	if delta > 0:
		_animate_gain(delta)


func _animate_gain(gain: int) -> void:
	modulate = Color(1.0, 1.0, 0.75, 1.0)
	var flash_tween := create_tween()
	flash_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)

	var popup := Label.new()
	popup.text = "+%d" % gain
	popup.modulate = Color(1.0, 0.95, 0.4, 1.0)
	popup.position = Vector2(64, -8)
	add_child(popup)

	var popup_tween := create_tween()
	popup_tween.tween_property(popup, "position:y", popup.position.y - 22.0, 0.45)
	popup_tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.45)
	popup_tween.finished.connect(popup.queue_free)
