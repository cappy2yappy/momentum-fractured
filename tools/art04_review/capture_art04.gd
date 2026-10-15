extends SceneTree
## Native 1280x720 / zoom1 scripted art fixture; no runtime integration claim.
var w
var adapter
var extra = []
var output = "res://build/art04/capture"

func _init(): call_deferred("run")

func freeze():
	w.set_physics_process(false)
	w.player.set_physics_process(false)
	for enemy in w.enemies: enemy.set_physics_process(false)

func clear_extra():
	for node in extra: node.queue_free()
	extra.clear()

func texture_node(path: String, at: Vector2, z: int):
	var node = Sprite2D.new()
	node.texture = load(path)
	node.position = at
	node.z_index = z
	node.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	w.add_child(node)
	extra.append(node)
	return node

func key_pose(key: String, anchor: Vector2):
	var node = texture_node("res://assets/art04/kaze/"+key+".png",anchor,4)
	node.scale = Vector2.ONE * 0.303125
	node.offset = Vector2(0,-238)
	w.player.sprite.visible = false
	return node

func shot(name: String):
	w.queue_redraw()
	for i in 4: await process_frame
	await RenderingServer.frame_post_draw
	var im = root.get_texture().get_image()
	assert(im.get_size() == Vector2i(1280,720))
	assert(im.save_png(output.path_join(name+".png")) == OK)
	print("ART04_CAPTURE ",name," room=",w.room," zoom=",w.camera.zoom," colliders=",w.geometry.get_child_count())

func room(index: int, position: Vector2):
	clear_extra()
	w.transition=0
	w.pending_room=-1
	w.build_room(index)
	freeze()
	w.player.sprite.visible=true
	w.player.position=position
	w.player.velocity=Vector2.ZERO
	w.player.animate(0)
	w.camera.reset_smoothing()
	w.message_time=0

func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--art04-output="): output=arg.trim_prefix("--art04-output=")
	DirAccess.make_dir_recursive_absolute(output)
	await process_frame
	w=load("res://scenes/main.tscn").instantiate()
	root.add_child(w)
	current_scene=w
	freeze()
	w.camera.zoom=Vector2.ONE
	w.camera.position_smoothing_enabled=false
	var old=w.embodied_transitions
	adapter=load("res://tools/art04_review/review_adapter.gd").new()
	w.embodied_transitions=adapter
	w.add_child(adapter)
	adapter.configure(w)
	old.queue_free()
	adapter.depth_demo=true
	print("ART04_NATIVE device=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name())
	for index in [14,15]:
		for refined in [false,true]:
			adapter.art04=refined
			adapter.show_stairs=false
			room(index,Vector2(950 if index==14 else 1600,1298))
			await shot("R%d_"%index+("art04" if refined else "tr03"))
	adapter.art04=true
	for key in ["turn_depth_key","enter_depth_key"]:
		room(14,Vector2(120,1098))
		key_pose(key,Vector2(120,1098))
		var front=texture_node("res://assets/art04/environment/r14_door_front.png",Vector2(120,1100)-Vector2(120,208),5)
		front.centered=false
		await shot(key)
	# This flight is a noninteractive proxy local to the existing portal; no collider.
	for key in ["stair_up_key","stair_down_key"]:
		adapter.show_stairs=true
		room(14,Vector2(1450,478))
		adapter.stairs_at=Vector2(1330,431.8)
		key_pose(key,Vector2(1450,478))
		var lip=texture_node("res://assets/art04/environment/stair_front_lip.png",adapter.stairs_at,5)
		lip.centered=false
		lip.scale.y=0.8
		# Only treads above the unchanged flat collision shelf may occlude feet.
		lip.region_enabled=true
		lip.region_rect=Rect2(0,0,384,60)
		await shot(key)
	var clips=load("res://assets/art04/kaze/ART04_key_poses.tres")
	assert(clips.get_animation_names().size()==4)
	for clip in clips.get_animation_names(): assert(clips.get_frame_count(clip)==1)
	print("ART04_RESOURCE_CHECK four one-key clips loaded, no cycles claimed")
	for path in ["res://assets/art04/prefabs/doorway.tscn","res://assets/art04/prefabs/kaze_key_preview.tscn"]:
		var prefab=load(path).instantiate()
		assert(not prefab is CollisionObject2D)
		prefab.free()
	print("ART04_PREFAB_CHECK door layers and key preview instantiate")
	clear_extra()
	w.queue_free()
	current_scene=null
	await process_frame
	quit()
