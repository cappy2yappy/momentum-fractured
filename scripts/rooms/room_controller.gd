extends Node2D
class_name RoomController

## Room Controller - Manages combat encounters and door unlocking
## Metroid-style: Clear all enemies to unlock exits

signal room_cleared
signal enemy_defeated(remaining: int)

@export var enemies_node: NodePath
@export var door_barriers: Array[NodePath] = []
@export var door_exits: Array[NodePath] = []
@export var enemy_counter_label: NodePath

var total_enemies: int = 0
var remaining_enemies: int = 0
var is_cleared: bool = false

func _ready():
	await get_tree().process_frame
	_setup_enemies()
	_lock_doors()
	_update_ui()

func _setup_enemies():
	var enemies_container = get_node_or_null(enemies_node) if not enemies_node.is_empty() else null
	
	if not enemies_container:
		push_warning("No enemies container found!")
		return
	
	for child in enemies_container.get_children():
		if child.has_node("Health"):
			var health = child.get_node("Health")
			health.died.connect(_on_enemy_died)
			total_enemies += 1
	
	remaining_enemies = total_enemies
	print("Room setup: %d enemies found" % total_enemies)

func _on_enemy_died():
	remaining_enemies -= 1
	print("Enemy defeated! Remaining: %d" % remaining_enemies)
	
	emit_signal("enemy_defeated", remaining_enemies)
	_update_ui()
	
	if remaining_enemies <= 0 and not is_cleared:
		_clear_room()

func _clear_room():
	is_cleared = true
	print("Room cleared!")
	
	emit_signal("room_cleared")
	_unlock_doors()
	_update_ui()

func _lock_doors():
	for barrier_path in door_barriers:
		var barrier = get_node_or_null(barrier_path)
		if barrier:
			barrier.show()
			barrier.set_collision_layer_value(1, true)
			barrier.set_collision_mask_value(1, true)

func _unlock_doors():
	for barrier_path in door_barriers:
		var barrier = get_node_or_null(barrier_path)
		if barrier:
			barrier.hide()
			barrier.set_collision_layer_value(1, false)
			barrier.set_collision_mask_value(1, false)
	
	# Connect exit triggers
	for exit_path in door_exits:
		var exit = get_node_or_null(exit_path)
		if exit and exit is Area2D:
			if not exit.body_entered.is_connected(_on_exit_triggered):
				exit.body_entered.connect(_on_exit_triggered)
			# Update label if exists
			if exit.has_node("Label"):
				var label = exit.get_node("Label")
				label.text = "← EXIT\n(unlocked)"

func _on_exit_triggered(body: Node2D):
	if body.name == "Kaze":
		print("Player reached exit!")
		# TODO: Load next room/scene
		get_tree().reload_current_scene()

func _update_ui():
	var counter = get_node_or_null(enemy_counter_label) if not enemy_counter_label.is_empty() else null
	
	if counter and counter is Label:
		if is_cleared:
			counter.text = "Room Cleared! Exit unlocked!"
			counter.modulate = Color.GREEN
		else:
			counter.text = "Enemies Remaining: %d" % remaining_enemies
			counter.modulate = Color.WHITE
