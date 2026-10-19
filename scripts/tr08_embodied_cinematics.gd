extends Node
## TR-08 controller: the default embodied room-transition presentations.
##  - R14 <-> R17 staircase: dedicated full-screen cinematic (tr08_stair_stage.gd), E.
##  - Canal doorway R13 left exit <-> R0: embodied passage (tr08_canal_doorway.gd),
##    automatic from R13 (trigger unchanged), E from the R0 door.
## Hooked from CinematicTransitions (intercept / present / arrived / room_loaded / cancel
## / F6). Clip frames come from the manifest-driven table (tr08_clip_library.gd).
## Off with --tr08-off (exact PR61 candidate behaviour), with --pm-staged-stair (the
## previous opt-in pilot), with --tr05-plain (plain fade) and with --tr05-legacy.
const Data = preload("res://scripts/transition_pilot_data.gd")
const Library = preload("res://scripts/tr08_clip_library.gd")
const StairStage = preload("res://scripts/tr08_stair_stage.gd")
const CanalDoorway = preload("res://scripts/tr08_canal_doorway.gd")
var enabled = false
var reduced = false
var table: Dictionary = {}
var world
var cinematic
var stair = StairStage.new()
var canal = CanalDoorway.new()
var releasing = false

func configure(w,c,args:PackedStringArray):
	world=w;cinematic=c
	name="Tr08EmbodiedCinematics"
	process_mode=Node.PROCESS_MODE_ALWAYS
	enabled=c.enabled and not c.plain
	for flag in Data.TR08.off_flags:
		if flag in args: enabled=false
	reduced=c.reduced
	table=Library.build()
	add_child(stair);stair.configure(w,self)
	add_child(canal);canal.configure(w,self)

func phase() -> String:
	if stair.phase!="": return "stair:"+stair.phase
	if canal.phase!="": return "canal:"+canal.phase
	return ""

func owns() -> bool:
	return stair.phase!="" or canal.phase!=""

## From world.request_room after can_enter accepted. True = this request is owned.
func intercept(w,t:int,at:Vector2) -> bool:
	if not enabled or stair.releasing or canal.releasing: return false
	if owns(): return true # no double trigger while a sequence runs
	if cinematic.plain: return false
	if stair.applies(w,t):
		stair.begin(w,t,at);return true
	if canal.applies(w,t):
		canal.begin(w,t,at);return true
	return false

func tick(w):
	if stair.phase!="": stair.tick(w)
	if canal.phase!="": canal.tick(w)

func room_loaded(w):
	stair.room_loaded(w);canal.room_loaded(w)

func cancel(w):
	stair.cancel(w);canal.cancel(w)

func reduced_changed(w):
	reduced=cinematic.reduced
	stair.reduced_changed(w);canal.reduced_changed(w)

func standin_clips() -> Array:
	var out=[]
	for name in Library.CLIPS:
		if table[name].bound!="art08": out.append(name)
	return out
