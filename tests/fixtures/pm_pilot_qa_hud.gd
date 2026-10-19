extends "res://scripts/hud.gd"
## QA-only HUD stand-in. Only the focus-loss pause is suppressed so a rendered or
## xvfb run can keep receiving real key events. Production HUD is untouched.
func _notification(what):
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("HARNESS: focus lost; continuing automated key/physics run")
