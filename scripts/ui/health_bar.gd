extends Control

@onready var _bar: ProgressBar = $Panel/VBox/HealthFill
@onready var _value: Label = $Panel/VBox/HealthValue


func set_health(current: float, max_health: float) -> void:
	var clamped_max := maxf(max_health, 1.0)
	_bar.max_value = clamped_max
	_bar.value = clampf(current, 0.0, clamped_max)
	_value.text = "%d / %d" % [roundi(current), roundi(clamped_max)]
