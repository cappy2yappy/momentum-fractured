extends Node2D
## Isolated viewer. Studio sources, seed files and user:// are never written.
const ACTOR=preload("res://presets/cutins/studio/actor.tscn")
const G=preload("res://tools/anim_stop_01/generate.gd")
var actors=[]
var timeline=0.
var playing=true
var mirrored=false
var capture=false
var samples=[]
var start_us=0
var last_capture=-1.
var warmup=4
var out="res://docs/anim_stop_01/private-evidence"
var clock_label: Label
func label(text_, at, size=18):
	var l=Label.new();l.text=text_;l.position=at;l.add_theme_font_size_override("font_size",size);add_child(l);return l
func _ready():
	get_window().size=Vector2i(1440,720)
	get_window().content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	RenderingServer.set_default_clear_color(Color("171923"))
	label("ANIM-STOP-01 / THREE DISTINCT EVIDENCE LANES",Vector2(25,20),25)
	label("Space pause · R replay · M mirror (geometry comparison only) · Esc close",Vector2(25,57),16)
	clock_label=label("",Vector2(25,650),19)
	var names=["STUDIO SEED / unchanged", "PORTABLE KEYS / original rig scale", "CALIBRATED STUDY / Rig.scale 0.68"]
	for i in 3:
		label(names[i],Vector2(15+i*480,100),17)
		var box=Node2D.new();box.position=Vector2(i*480-20,90);box.scale=Vector2.ONE*.7;add_child(box)
		var a=ACTOR.instantiate();box.add_child(a);actors.append(a)
		if i>0:a.bind_clip(load("res://tools/anim_stop_01/"+("portable" if i==1 else "calibrated")+"_stop.tres"))
		if i==2:a.get_node("Rig").scale=Vector2.ONE*.68
	label("Motion-only candidate. Oversized source parts remain.",Vector2(490,600),15)
	label("Candidate cutouts, not original art or a drop-in Studio fix.",Vector2(970,600),15)
	capture="--stop-capture" in OS.get_cmdline_user_args()
	if capture:DirAccess.make_dir_recursive_absolute(out)
	start_us=Time.get_ticks_usec()
func _process(delta):
	if warmup>0:
		warmup-=1;start_us=Time.get_ticks_usec();return
	if capture:timeline=minf((Time.get_ticks_usec()-start_us)/1000000.,4.2)
	elif playing:timeline=minf(timeline+delta,4.2)
	for a in actors:
		a.sample(timeline)
		# Local viewport follows root horizontally, while preserving clip travel in readout.
		a.get_parent().position.x=actors.find(a)*480+240-a.position.x*.7
		a.get_parent().scale.x=-.7 if mirrored else .7
		if mirrored:a.get_parent().position.x=actors.find(a)*480+240+a.position.x*.7
	clock_label.text="%.3fs / 4.2s · native 1.0x · six-pose blocking only · original art and actor source untouched" % timeline
	queue_redraw()
	if capture:
		var elapsed=(Time.get_ticks_usec()-start_us)/1000000.
		if elapsed-last_capture>=1./30. and elapsed<4.5:
			RenderingServer.force_draw(false)
			var path=out+"/frame_%05d.jpg" % samples.size()
			get_viewport().get_texture().get_image().save_jpg(path,.9)
			samples.append({"file":path.get_file(),"wall":elapsed,"timeline":timeline});last_capture=elapsed
		if elapsed>=4.5:
			FileAccess.open(out+"/timing.json",FileAccess.WRITE).store_string(JSON.stringify({"samples":samples,"wall_seconds":elapsed,"speed":Engine.time_scale,"engine":Engine.get_version_info().string,"gpu":RenderingServer.get_video_adapter_name(),"note":"Real native draw samples; no fixed FPS/movie flags. Root-tracking review cameras do not alter actor clip coordinates."},"  "))
			get_tree().quit()
func _draw():
	for i in 3:
		var y=90+G.GROUND*.7
		draw_line(Vector2(i*480+15,y),Vector2(i*480+465,y),Color("8d9fb8"),1.)
		if actors.size()==3:
			for side in ["Near","Far"]:
				var b=actors[i].get_node("Rig/Leg"+side+"/Shin/Boot")
				var sole=to_local(b.to_global(G.SOLE))
				draw_circle(sole,3.,Color("ffd369"))
				draw_circle(to_local(b.to_global(G.FOREFOOT)),2.,Color("9be7d8"))
func _unhandled_key_input(event):
	if not event.pressed or event.echo:return
	if event.keycode==KEY_SPACE:playing=not playing
	if event.keycode==KEY_R:timeline=0.;playing=true
	if event.keycode==KEY_M:mirrored=not mirrored
	if event.keycode==KEY_ESCAPE:get_tree().quit()
