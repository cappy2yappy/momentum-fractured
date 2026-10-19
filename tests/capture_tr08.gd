extends "res://tests/native_cinematic_transitions.gd"
## TR-08 capture: software-GL frame sequences of the full-screen staircase (both
## directions, cinematic and reduced) and the Canal doorway (both directions), driven by
## real InputEventKey presses. Writes PNGs + captures.json to build/tr08/captures.
## Run under xvfb with --rendering-method gl_compatibility; see docs/tr08/README.md.
var rows=[]
var t8

func setup(index:int,feet:Vector2,still:=false):
	for code in [KEY_A,KEY_D,KEY_SPACE,KEY_E]: key(code,false)
	reset(index);t8=w.cinematic_transitions.tr08
	w.cinematic_transitions.reduced=still;t8.reduced=still
	w.embodied_transitions.comparison="reduced" if still else "art-preview"
	w.player.position=feet;w.player.velocity=Vector2.ZERO;w.message_time=0
	w.camera.reset_smoothing();live()
	await wait_ticks(8)

func snap(prefix:String,index:int,t:float):
	var name="%s_%02d_t%.2f"%[prefix,index,t]
	await shot(name)
	var s=t8.stair;var d=t8.canal
	rows.append({"frame":name,"t":snappedf(t,0.01),"room":w.room,"phase":t8.phase(),"transition":snappedf(w.transition,0.001),
		"stair_clip":s.current if s.phase!="" else "","stair_feet":[s.feet.x,s.feet.y],
		"canal_clip":d.kaze.clip.get("name","") if d.phase!="" else "","canal_feet":[d.feet.x,d.feet.y],
		"live_feet":[w.player.position.x,w.player.position.y],"physics":w.player.is_physics_processing()})

## Presses E (or holds a direction) and snaps every `every` ticks until control returns.
func sequence(prefix:String,start_key:int,hold:bool,every:int,limit:=360):
	var t0=Engine.get_physics_frames()
	key(start_key,true)
	if not hold: await wait_ticks(1);key(start_key,false)
	var n=0;var seen=false
	for tick in limit:
		await wait_ticks(1)
		if t8.owns(): seen=true
		if hold and seen: key(start_key,false)
		if seen and tick%every==0:
			await snap(prefix,n,(Engine.get_physics_frames()-t0)/60.0);n+=1
		if seen and not t8.owns() and w.transition<=0: break
	key(start_key,false)
	await wait_ticks(8)
	await snap(prefix,99,(Engine.get_physics_frames()-t0)/60.0)
	print("CAPTURE ",prefix," frames=",n," seconds=",(Engine.get_physics_frames()-t0)/60.0," room=",w.room," stair=",t8.stair.last_result," canal=",t8.canal.last_result)

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	output="res://build/tr08/captures"
	DirAccess.make_dir_recursive_absolute(output)
	print("TR08_CAPTURE GPU=",RenderingServer.get_video_adapter_name()," driver=",RenderingServer.get_current_rendering_driver_name())
	var every=int(OS.get_environment("TR08_EVERY")) if OS.get_environment("TR08_EVERY")!="" else 9
	await setup(14,Vector2(1420,478));await snap("stair_14-17",-1,0)
	await sequence("stair_14-17",KEY_E,false,every)
	await setup(17,Vector2(1650,1298));await snap("stair_17-14",-1,0)
	await sequence("stair_17-14",KEY_E,false,every)
	await setup(14,Vector2(1420,478),true)
	await sequence("stair_14-17_reduced",KEY_E,false,every)
	await setup(13,Vector2(190,1198));await snap("canal_13-0",-1,0)
	await sequence("canal_13-0",KEY_A,true,max(3,every/2))
	await setup(0,Vector2(630,778));await snap("canal_0-13",-1,0)
	await sequence("canal_0-13",KEY_E,false,max(3,every/2))
	await setup(13,Vector2(190,1198),true)
	await sequence("canal_13-0_reduced",KEY_A,true,max(3,every/2))
	var f=FileAccess.open(output+"/captures.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"engine":Engine.get_version_info().string,"driver":RenderingServer.get_current_rendering_driver_name(),"adapter":RenderingServer.get_video_adapter_name(),"bindings":t8.Library.summary(t8.table),"frames":rows},"\t"))
	f.close()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit(0)
