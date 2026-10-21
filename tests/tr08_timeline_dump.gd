extends "res://tests/native_cinematic_transitions.gd"
## TR-08 fixed-step timeline recorder. Real key events only; records every physics tick
## from the key press until control returns: room, TR-08 phase, clip, frame index, stage
## or doorway feet, live feet, loader time, physics state. Output JSON for diffing two
## SHAs. Run: -- --test "--tr08-dump=<abs path.json>"
var out = {}

func dump_path() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--tr08-dump="): return arg.trim_prefix("--tr08-dump=")
	return "user://tr08_timeline.json"

func record(name:String,index:int,feet:Vector2,code:int,hold:bool):
	for k in [KEY_A,KEY_D,KEY_SPACE,KEY_E]: key(k,false)
	reset(index);var c=w.cinematic_transitions;var t8=c.tr08
	w.player.position=feet;w.player.velocity=Vector2.ZERO;w.camera.reset_smoothing();live()
	await wait_ticks(8)
	var rows=[]
	key(code,true)
	if not hold: await wait_ticks(1);key(code,false)
	var seen=false
	for tick in 600:
		await wait_ticks(1)
		if t8.owns(): seen=true
		if hold and seen: key(code,false)
		var s=t8.stair;var d=t8.canal
		var clip="";var frame=-1;var at=Vector2.ZERO
		if s.phase!="": clip=s.current;frame=s.kaze.frame;at=s.feet
		elif d.phase!="": clip=str(d.kaze.clip.get("name",""));frame=d.kaze.frame;at=d.kaze.position
		rows.append([tick,w.room,t8.phase(),clip,frame,snappedf(at.x,0.01),snappedf(at.y,0.01),snappedf(w.player.position.x,0.01),snappedf(w.player.position.y,0.01),snappedf(w.transition,0.0001),w.player.is_physics_processing()])
		if seen and not t8.owns() and w.transition<=0: break
	out[name]={"ticks":rows.size(),"seconds":rows.size()/float(Engine.physics_ticks_per_second),"rows":rows,"bindings":t8.Library.summary(t8.table)}
	print("TIMELINE ",name," ticks=",rows.size())

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture()
	await record("canal_return_0-13",0,Vector2(650,778),KEY_E,false)
	await record("canal_out_13-0_grounded",13,Vector2(190,1198),KEY_A,true)
	await record("stair_14-17",14,Vector2(1420,478),KEY_E,false)
	await record("stair_17-14",17,Vector2(1650,1298),KEY_E,false)
	var f=FileAccess.open(dump_path(),FileAccess.WRITE);f.store_string(JSON.stringify(out));f.close()
	w.queue_free();current_scene=null
	for i in 3: await process_frame
	quit(0)
