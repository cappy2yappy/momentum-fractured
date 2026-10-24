extends SceneTree
## Frozen native comparison harness. Not a traversal or progression test.
class Keys extends Node:
	signal pressed(code)
	func _unhandled_key_input(event):
		if event is InputEventKey and event.pressed and not event.echo: pressed.emit(event.physical_keycode)
var room=0
var code=''
var art11=''
var cache=''
var output=''
var automate=false
var world
var overlay
var bank
var title: Label
var report: Dictionary={}
var failures: Array=[]
var frame_samples: Array=[]
var draw_samples: Array=[]
var measuring=false
var last_tick=0
var original_shapes: Array=[]
var initial_state: Dictionary={}
var shots: Array=[]
func _initialize():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with('--room='): room=int(arg.trim_prefix('--room='))
		if arg.begins_with('--code='): code=arg.trim_prefix('--code=')
		if arg.begins_with('--art11='): art11=arg.trim_prefix('--art11=')
		if arg.begins_with('--cache='): cache=arg.trim_prefix('--cache=')
		if arg.begins_with('--output='): output=arg.trim_prefix('--output=')
		if arg=='--capture': automate=true
	if room not in [0,4,14,16] or not '--test' in OS.get_cmdline_user_args(): quit(1);return
	start.call_deferred()
func rect_data(r: Rect2) -> Array:return [r.position.x,r.position.y,r.size.x,r.size.y]
func shapes(node: Node) -> Array:
	var rows: Array=[]
	if node is CollisionShape2D: rows.append([str(node.get_path()),str(node.transform),str(node.shape),str(node.shape.get_rect()),node.disabled])
	if node is CollisionObject2D: rows.append([str(node.get_path()),node.collision_layer,node.collision_mask])
	for child in node.get_children(): rows.append_array(shapes(child))
	return rows
func state() -> Dictionary:
	return {'edges':world.world_edges(),'rooms':world.ROOM_COUNT,'double_jump':world.player.double_jump,'tether':world.player.tether_unlocked,'dash':world.player.dash_unlocked,'kunai':world.player.kunai_unlocked.duplicate(true),'gates':world.opened_kunai_gates.duplicate(true),'flags':world.expansion_flags.duplicate(true),'completed':world.completed,'checkpoint_room':world.checkpoint_room,'checkpoint_position':str(world.checkpoint_position),'objective':world.current_objective(),'save_path':world.save_path}
func check(condition: bool,message: String):
	report.assertions=report.get('assertions',0)+1
	if not condition: failures.append(message);push_error(message)
func start():
	bank=load(art11.path_join('bank.gd')).new()
	if not bank.open(cache): quit(1);return
	world=load('res://scenes/main.tscn').instantiate()
	world.save_path='user://ENV12_disposable_only.json'
	root.add_child(world);current_scene=world
	await process_frame
	world.build_room(room)
	world.player.position={0:Vector2(400,1300),4:Vector2(380,1110),14:Vector2(420,1100),16:Vector2(420,1120)}[room]
	world.player.velocity=Vector2.ZERO
	world.set_physics_process(false);world.player.set_physics_process(false)
	for enemy in world.enemies: enemy.set_physics_process(false)
	world.hud.visible=false;world.message_time=0
	world.camera.reparent(world);world.camera.position_smoothing_enabled=false
	await process_frame
	original_shapes=shapes(world);initial_state=state()
	overlay=load(code.path_join('overlay.gd')).new();world.add_child(overlay)
	overlay.configure(world,bank,code,art11)
	var canvas=CanvasLayer.new();canvas.layer=100;root.add_child(canvas)
	var panel=ColorRect.new();panel.position=Vector2(12,12);panel.size=Vector2(1256,78);panel.color=Color(0.025,0.04,0.06,0.96);canvas.add_child(panel)
	title=Label.new();title.position=Vector2(26,20);title.add_theme_font_size_override('font_size',16);canvas.add_child(title)
	var keys=Keys.new();root.add_child(keys);keys.pressed.connect(key)
	report.merge({'room':room,'base':'250afde28517fcc05984038ac9e1487114729b78','engine':Engine.get_version_info().string,'gpu':RenderingServer.get_video_adapter_name(),'viewport':[1280,720],'frozen_review':true,'native_traversal_tested':false,'texture_bytes':bank.bytes,'decoded_frames':bank.decoded,'initial_state':initial_state,'geometry':[]},true)
	for rect in world.platforms:report.geometry.append(rect_data(rect))
	check(original_shapes==shapes(world),'Attach changed collision topology')
	check(state()==initial_state,'Attach changed progression')
	check(world.ROOM_COUNT==21 and world.world_edges().size()==29,'Graph differs from 21/29')
	check(world.test_mode,'Test mode must prevent saves')
	camera_view('overview');update_title('OVERVIEW')
	if automate: await sequence()
func update_title(view):
	title.text='ENV-12 | R%d %s | %s | ART %s | CREATOR REVIEW PENDING' % [room,world.ROOM_NAMES[room],view,'ON' if overlay.art_on else 'OFF']
	title.text+='\nF4 art  F7 guides  F8 reduced motion  F9 cosmetic response  1-4 layers  F5 view  Esc exit'
	title.text+='\nCyan = actual collision  Amber = protected read  Purple = cosmetic bounds | No route or story change'
func camera_view(view):
	if view=='overview':
		world.camera.zoom=Vector2(0.47,0.47) if room!=16 else Vector2(0.55,0.55)
		world.camera.position=world.room_size(room)*0.5
	elif view=='native':
		world.camera.zoom=Vector2.ONE
		world.camera.position={0:Vector2(640,1030),4:Vector2(640,1030),14:Vector2(640,1020),16:Vector2(640,970)}[room]
	elif view=='exit':
		world.camera.zoom=Vector2.ONE
		world.camera.position={0:Vector2(1960,1000),4:Vector2(1960,1000),14:Vector2(1960,820),16:Vector2(1360,720)}[room]
	world.camera.reset_smoothing();update_title(view.to_upper())
func capture(name):
	await process_frame
	await RenderingServer.frame_post_draw
	var path=output.path_join('R%d_%s.png'%[room,name])
	var img=root.get_texture().get_image()
	check(img.get_width()==1280 and img.get_height()==720,'Capture dimensions')
	check(img.save_png(path)==OK,'Capture write failed')
	shots.append({'file':path.get_file(),'sha256':FileAccess.get_sha256(path),'width':1280,'height':720,'art_on':overlay.art_on,'guides':overlay.guides,'zoom':world.camera.zoom.x,'camera':[world.camera.position.x,world.camera.position.y],'layers':overlay.layer_enabled.duplicate(),'reduced_motion':overlay.reduced_motion})
func sequence():
	await create_timer(0.6).timeout
	for view in ['overview','native','exit']:
		camera_view(view)
		for mode in ['baseline','art','guides']:
			overlay.set_state(mode!='baseline',mode=='guides');update_title(view.to_upper())
			await capture(view+'_'+mode)
	if room==16:
		camera_view('native');overlay.set_state(false,false)
		var reference=load(art11.path_join('presentation.gd')).new()
		reference.bank=bank;world.add_child(reference);reference.setup_room(world,'moss')
		title.text='ENV-12 | R16 | UNMODIFIED ART-11 REFERENCE | SOURCE READ ONLY\nLocal comparison includes DarkCave-associated grass: independent rights UNRESOLVED.'
		await capture('art11_reference')
		world.remove_child(reference);reference.free()
	camera_view('native');overlay.set_state(true,false)
	overlay.reduced_motion=true
	var clock=overlay.motion_time
	await create_timer(0.15).timeout
	check(overlay.motion_time==clock,'Reduced motion changed cosmetic clock')
	await capture('reduced_motion')
	overlay.reduced_motion=false
	for i in 4:
		overlay.layer_enabled=[false,false,false,false];overlay.layer_enabled[i]=true
		if is_instance_valid(overlay.art11_layer):overlay.art11_layer.art_enabled=false
		await capture('layer_'+str(i+1))
	overlay.layer_enabled=[true,true,true,true];overlay.set_state(true,false)
	overlay.preview_response();await create_timer(0.4).timeout;await capture('cosmetic_B')
	check(state()==initial_state,'B preview changed progression')
	paused=true;var paused_clock=overlay.motion_time
	await create_timer(0.1,true).timeout
	check(overlay.motion_time==paused_clock,'Pause did not freeze ambient clock');paused=false
	# Warmup and two comparable display-paced windows, excluding screenshots.
	camera_view('native')
	await create_timer(0.6).timeout
	report.performance={}
	for on in [false,true]:
		overlay.set_state(on,false);update_title('PERFORMANCE')
		await create_timer(0.3).timeout
		frame_samples.clear();draw_samples.clear();last_tick=Time.get_ticks_usec();measuring=true
		await create_timer(3.0).timeout;measuring=false
		frame_samples.sort();draw_samples.sort()
		report.performance['art' if on else 'baseline']={'samples':frame_samples.size(),'p50_ms':frame_samples[int(frame_samples.size()*0.5)],'p95_ms':frame_samples[mini(frame_samples.size()-1,int(frame_samples.size()*0.95))],'draw_calls_p95':draw_samples[mini(draw_samples.size()-1,int(draw_samples.size()*0.95))]}
	var audit=overlay.audit();report.audit=audit
	check(audit.violations.is_empty(),'Readability/exclusion audit failed')
	check(audit.four_layers==4,'Missing layer')
	check(audit.protected_counts.get('grapple',0)=={0:0,4:3,14:3,16:2}[room],'Locked anchors must also be protected')
	check(original_shapes==shapes(world),'Review changed collision topology')
	check(initial_state==state(),'Review changed state')
	check(bank.decoded==report.decoded_frames,'Texture decode count grew')
	check(not FileAccess.file_exists(world.save_path),'Unexpected test save')
	world.remove_child(overlay);overlay.free()
	check(original_shapes==shapes(world),'Detach changed topology')
	check(initial_state==state(),'Detach changed state')
	# Reattach tests that ambient state and B are disposable, not persistent story flags.
	overlay=load(code.path_join('overlay.gd')).new();world.add_child(overlay);overlay.configure(world,bank,code,art11)
	check(overlay.motion_time==0 and overlay.response_time==0,'Reattach retained transient state')
	check(overlay.audit().violations.is_empty(),'Reattach exclusion audit failed')
	report.captures=shots;report.failures=failures;report.pass=failures.is_empty()
	var file=FileAccess.open(output.path_join('report.json'),FileAccess.WRITE);file.store_string(JSON.stringify(report,'\t'));file.close()
	print('ENV12 R%d: %d checks, %d failures, %d native captures'%[room,report.assertions,failures.size(),shots.size()])
	quit(0 if failures.is_empty() else 1)
func key(k):
	if k==KEY_ESCAPE:quit()
	if k==KEY_F4:overlay.set_state(not overlay.art_on,overlay.guides)
	if k==KEY_F7:overlay.set_state(overlay.art_on,not overlay.guides)
	if k==KEY_F8:overlay.reduced_motion=not overlay.reduced_motion
	if k==KEY_F9:overlay.preview_response()
	if k==KEY_F5:camera_view('native' if world.camera.zoom.x<0.9 else 'overview')
	if k>=KEY_1 and k<=KEY_4:overlay.layer_enabled[k-KEY_1]=not overlay.layer_enabled[k-KEY_1]
	update_title('REVIEW')
func _process(_delta):
	if measuring:
		var now=Time.get_ticks_usec();frame_samples.append((now-last_tick)/1000.0);last_tick=now
		draw_samples.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	return false
