extends SceneTree
## Real native-render evidence; deterministic samples plus measured timed playback.
var failures=0
var checks=0
func _init(): call_deferred("run")
func check(ok,label):
	checks+=1
	if not ok: failures+=1
	print("PASS: " if ok else "FAIL: ",label)
func shot(path):
	await process_frame;await RenderingServer.frame_post_draw
	var im=root.get_texture().get_image()
	check(im.get_size()==Vector2i(1280,720),"native capture1280x720")
	im.save_png(path)
func run():
	await process_frame
	var bed=load("res://tools/art05/testbed.tscn").instantiate();root.add_child(bed);current_scene=bed
	var out="res://build/art05/native";DirAccess.make_dir_recursive_absolute(out)
	print("ART05_NATIVE engine=",Engine.get_version_info().string," gpu=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name())
	bed.playing=false
	for mode in 3:
		bed.select(mode)
		var frames=bed.Frames
		var clip=bed.clip
		check(frames.get_frame_count(clip)==[4,8,6][mode],"real SpriteFrames count "+clip)
		check(frames.get_animation_speed(clip)==20.0,"authored20fps "+clip)
		for i in frames.get_frame_count(clip):
			bed.set_review_frame(i)
			check(bed.actor.frame==i and bed.detail.frame==i,"frame registered "+clip+str(i))
			check(bed.actor.offset==Vector2(0,-238) and bed.actor.scale==Vector2.ONE*0.303125,"fixed pivot/scale")
			await shot(out+"/%s_%02d.png"%[clip,i])
	# Real time playback through all four frames (not merely assigning stills).
	bed.select(0);bed.playing=true;bed.clock=0
	var visited={};var began=Time.get_ticks_msec()
	while Time.get_ticks_msec()-began<240:
		await process_frame;visited[bed.actor.frame]=true
	check(visited.size()==4,"native actual-speed playback visits all4 turn frames")
	bed.playing=false
	# Independently exercise Godot's AnimatedSprite2D playback, not just sampler.
	bed.actor.play("turn_depth");await create_timer(0.24).timeout
	check(bed.actor.frame==3 and not bed.actor.is_playing(),"Godot nonloop playback completes0.20s clip")
	bed.select(-1);await process_frame
	var signatures=JSON.stringify(bed.world.platforms);var children=bed.world.geometry.get_child_count()
	var before=bed.world.player.position
	bed.overlay.visible=false;await shot(out+"/bellroof_before.png")
	bed.overlay.visible=true;await shot(out+"/bellroof_after.png")
	check(signatures==JSON.stringify(bed.world.platforms) and children==bed.world.geometry.get_child_count(),"art overlay preserves exact colliders")
	check(bed.world.player.position==before,"art overlay leaves player simulation unchanged")
	check(bed.world.camera.zoom==Vector2.ONE,"Bellroof camera zoom1.0")
	check(bed.overlay.position==Vector2(520,1220) and bed.overlay.texture.get_size()==Vector2(180,80),"art exactly fits PR37 solid rectangle")
	var adapter=load("res://tools/art05/proxy_adapter.gd").new()
	var proxy=bed.world.embodied_transitions.proxy
	check(not adapter.apply(proxy,"turn_depth",0),"candidate requires explicit consumer opt-in")
	for clip in ["enter_depth","stair_up"]:
		check(not adapter.apply(proxy,clip,0,true),"WIP refused by proxy adapter: "+clip)
	for i in 4:
		check(adapter.apply(proxy,"turn_depth",float(i)/20,true),"TR39 real render proxy accepts turn frame"+str(i))
		check(proxy.texture==adapter.Frames.get_frame_texture("turn_depth",i),"TR39 real proxy texture frame parity")
	check(signatures==JSON.stringify(bed.world.platforms),"render adapter preserves world geometry")
	bed.queue_free();current_scene=null
	for i in 3: await process_frame
	print("ART05_NATIVE: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
