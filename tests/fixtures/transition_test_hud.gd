extends "res://scripts/hud.gd"
## Rendered automation runs beside Codex. Only suppress the focus-loss pause;
## normal HUD interactions and the production HUD remain unchanged.
func _notification(what):
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("HARNESS: focus lost; continuing automated key/physics run")
