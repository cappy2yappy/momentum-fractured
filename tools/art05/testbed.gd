extends Node2D
## Render-only ART05 review. No controller, collision or transition owner changes.
const Frames = preload("res://assets/art05/kaze/ART05_candidates.tres")
const Approved = preload("res://assets/art04/kaze/ART04_key_poses.tres")
const Masonry = preload("res://assets/art05/environment/bellroof_west_masonry.png")
const DoorBack = preload("res://assets/art04/environment/r14_door_back.png")
const DoorInside = preload("res://assets/art04/environment/r14_door_interior.png")
const DoorFront = preload("res://assets/art04/environment/r14_door_front.png")
const SCALE = 0.303125
var catalog = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art05/MANIFEST.json"))
var mode = 0
var clip: StringName = &"turn_depth"
var playing = true
var guides = true
var rate = 1.0
var clock = 0.0
var actor = AnimatedSprite2D.new()
var detail = AnimatedSprite2D.new()
var reference = Sprite2D.new()
var ui = CanvasLayer.new()
var panel = Control.new()
var info = Label.new()
var world
var overlay
var overlay_visible = true
var sample_frame = 0

func _ready():
	for sprite in [actor, detail]:
		sprite.sprite_frames=Frames;sprite.offset=Vector2(0,-238)
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(sprite)
	actor.scale=Vector2.ONE*SCALE;detail.scale=Vector2.ONE*SCALE*2.5
	actor.position=Vector2(600,460);detail.position=Vector2(1000,460)
	reference.texture=Approved.get_frame_texture("turn_depth_key",0)
	reference.offset=Vector2(0,-238);reference.scale=Vector2.ONE*SCALE;reference.position=Vector2(220,460)
	add_child(reference);ui.layer=20;add_child(ui);ui.add_child(panel);panel.add_child(info)
	info.position=Vector2(30,26);info.add_theme_font_size_override("font_size",20)
	select(0)
	if "--art05-environment" in OS.get_cmdline_user_args(): select(-1)
	print("ART05_TESTBED ready | viewport=",get_viewport_rect().size," zoom=1.0 | renderer=",RenderingServer.get_video_adapter_name())

func select(index:int):
	mode=index;clock=0;sample_frame=0
	if is_instance_valid(world):
		world.queue_free();world=null;overlay=null
	for item in [actor,detail,reference]: item.visible=index!=-1
	if index==-1:
		# --test suppresses normal progress loading; explicit path also protects writes.
		world=load("res://scenes/main.tscn").instantiate()
		world.save_path="user://art05-testbed-disposable.json"
		add_child(world)
		world.set_physics_process(false);world.player.set_physics_process(false)
		world.set_process_unhandled_input(false);world.set_process_unhandled_key_input(false)
		world.build_room(14)
		for enemy in world.enemies: enemy.set_physics_process(false)
		world.player.position=Vector2(610,1218);world.player.velocity=Vector2.ZERO
		# Freeze an approved idle for still comparison; no fabricated grounded physics.
		world.player.sprite.texture=world.player.clips.idle;world.player.sprite.hframes=8;world.player.sprite.frame=0
		world.player.sprite.scale=Vector2.ONE*0.2649908807267889
		world.player.sprite.offset=Vector2(0,724.0/2.0-591.0)
		world.hud.visible=false
		world.message_time=0;world.camera.zoom=Vector2.ONE
		world.camera.position_smoothing_enabled=false
		world.camera.global_position=Vector2(640,1080);world.camera.reset_smoothing()
		assert(Rect2(520,1220,180,80) in world.platforms)
		overlay=Sprite2D.new();overlay.texture=Masonry;overlay.centered=false
		overlay.position=Vector2(520,1220);overlay.z_index=1;world.add_child(overlay)
		overlay.visible=overlay_visible
		# Fixture remains a frozen real room with real imported textures/collision.
	else:
		clip=StringName(catalog.clips[index].id)
		actor.animation=clip;detail.animation=clip
		reference.texture=Approved.get_frame_texture("stair_up_key" if index==2 else ("enter_depth_key" if index==1 else "turn_depth_key"),0)
		actor.frame=0;detail.frame=0
	queue_redraw();update_info()

func seek(seconds:float):
	clock=maxf(0,seconds)
	if mode==-1:return
	var count=Frames.get_frame_count(clip)
	# 0.4s neutral pause between repeats makes nonloop endpoints reviewable.
	var fps=Frames.get_animation_speed(clip)
	var cycle=float(count)/fps+0.4
	var frame=mini(int(fmod(clock,cycle)*fps),count-1)
	set_review_frame(frame)

func set_review_frame(index:int):
	if mode==-1:return
	sample_frame=clampi(index,0,Frames.get_frame_count(clip)-1)
	actor.frame=sample_frame;detail.frame=sample_frame
	update_info();queue_redraw()

func _process(dt):
	if playing and mode!=-1: seek(clock+dt*rate)

func update_info():
	var status="BELLROOF: exact PR37 west block / art overlay candidate"
	if mode!=-1:
		var entry=catalog.clips[mode]
		status="%s: %s / %d frames at %.0f fps"%[clip,entry.status,Frames.get_frame_count(clip),Frames.get_animation_speed(clip)]
	info.text="KAZE / ART05 PRODUCTION REVIEW\n"+status+"\n1280 x 720 | gameplay zoom 1.0 | speed %.2fx | frame %d"%[rate,sample_frame]
	info.add_theme_color_override("font_color",Color("f4e5ce"))
	info.add_theme_color_override("font_shadow_color",Color.BLACK)
	info.add_theme_constant_override("shadow_offset_x",2);info.add_theme_constant_override("shadow_offset_y",2)

func _unhandled_key_input(event):
	if not event is InputEventKey or not event.pressed:return
	match event.physical_keycode:
		KEY_1: select(0)
		KEY_2: select(1)
		KEY_3: select(2)
		KEY_4: select(-1)
		KEY_TAB: select((mode+1)%catalog.clips.size())
		KEY_SPACE: playing=not playing
		KEY_LEFT: playing=false;set_review_frame(sample_frame-1)
		KEY_RIGHT: playing=false;set_review_frame(sample_frame+1)
		KEY_G: guides=not guides
		KEY_R: clock=0;set_review_frame(0)
		KEY_MINUS: rate=maxf(0.25,rate-0.25)
		KEY_EQUAL: rate=minf(2,rate+0.25)
		KEY_B:
			overlay_visible=not overlay_visible
			if is_instance_valid(overlay):overlay.visible=overlay_visible
	update_info();queue_redraw();get_viewport().set_input_as_handled()

func _draw():
	if mode==-1:return
	draw_rect(Rect2(0,0,1280,720),Color("171b2b"))
	draw_rect(Rect2(0,156,1280,395),Color("22283a"))
	var font=ThemeDB.fallback_font
	for item in [[100,"APPROVED PR30",1],[485,"CANDIDATE / WIP",1],[875,"2.5x INSPECTION",2.5]]:
		draw_string(font,Vector2(item[0],200),item[1],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e9d7b5"))
	if guides:
		draw_line(Vector2(90,460),Vector2(1190,460),Color("927858"),1)
		for x in [220,600,1000]:
			draw_line(Vector2(x,340),Vector2(x,490),Color("927858"),1)
			draw_circle(Vector2(x,460),3,Color("e5b76a"))
	for i in Frames.get_frame_count(clip):
		var at=Vector2(95+i*75,565)
		draw_rect(Rect2(at,Vector2(62,35)),Color("a58155") if i==sample_frame else Color("34394b"))
		draw_string(font,at+Vector2(12,24),str(i),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
	draw_string(font,Vector2(50,645),"1 TURN   2 ENTRY WIP   3 STAIR WIP   4 REAL BELLROOF ROOM   B BEFORE/AFTER",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e9d7b5"))
	draw_string(font,Vector2(50,679),"SPACE PAUSE   LEFT/RIGHT STEP   -/+ SPEED   G ROOT GUIDES   R RESTART",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("b3b9cd"))
