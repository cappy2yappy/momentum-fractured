extends RefCounted
## TR-08: manifest-driven clip table for Kaze's embodied room-transition cinematics.
## Contract: /home/claude/wave3_shared/ANIMATION_INTERFACE.md (see INTERFACE_VERSION).
## A clip binds to ART-08 by FILE PATH from assets/art08/MANIFEST.json only when its strip
## exists in this checkout, has at least two frames and a provenance that counts as
## animation. Every other clip falls back to a STAND-IN built from existing approved strips
## and is labelled STANDIN_LABEL on screen. A stand-in is never the intended action.
const INTERFACE_VERSION = "v2.1"
const MANIFEST_PATH = "res://assets/art08/MANIFEST.json"
const STANDIN_LABEL = "STAND-IN, ANIMATION PENDING"
## Provenance values that must never be presented as animation (interface hard rule).
const NOT_ANIMATION = ["", "held", "unfinished", "scaled", "bobbed", "wipe", "skeleton"]
const CLIPS = ["stair_ascend_enter","stair_ascend_loop","stair_ascend_exit",
	"stair_descend_enter","stair_descend_loop","stair_descend_exit","stair_arrive_idle_settle","stair_descend_arrive_settle",
	"door_approach_walk","door_turn_to_rear","door_cross","door_emerge","door_turn_to_side","door_walk_out"]
const ART08_WORLD_SCALE = 0.303125
const ART08_FIGURE_FALLBACK = 560.0

## Approved source strips reused by stand-ins (byte-identical files, never modified).
const RUN = "res://assets/kaze/cleaned/kaze_run_strip.png"
const IDLE = "res://assets/kaze/cleaned/kaze_idle_strip.png"
const TURN_KEY = "res://assets/art04/kaze/turn_depth_key.png"
const ENTER_KEY = "res://assets/art04/kaze/enter_depth_key.png"
const RUN_REG = {"strip":RUN,"hframes":8,"cell":[272,724],"pivot":[136,491],"figure":424.0,"world_scale":0.3825780535911868}
const IDLE_REG = {"strip":IDLE,"hframes":8,"cell":[272,724],"pivot":[136,591],"figure":516.0,"world_scale":0.2649908807267889}
const KEY_REG = {"hframes":1,"cell":[320,724],"pivot":[160,600],"figure":320.0,"world_scale":0.303125}

## Stand-in step on the stage, as a fraction of the figure height (rise:run 1:2).
## Real clips supply their own root motion; these numbers only drive stand-ins.
const STEP_RUN = 0.24
const STEP_RISE = 0.12

## Stand-in table. Frame counts and fps follow ART08_MANIFEST_SKELETON.json so the
## timing does not change when the real strips bind. Root motion is source px per frame.
static func standins() -> Dictionary:
	var f=RUN_REG.figure
	var run=STEP_RUN*f/4.0  # 4 frames per step, 2 steps per 8-frame loop
	var rise=STEP_RISE*f/4.0
	var up=[]; var down=[]
	for i in 8: up.append(Vector2(run,-rise)); down.append(Vector2(run,rise))
	var t={}
	t["stair_ascend_enter"]=row(RUN_REG,[0,1,2,3],16,false,[Vector2(run,0),Vector2(run,0),Vector2(run,-rise*0.5),Vector2(run,-rise)],"approved cleaned RUN strip frames 0-3 (a sprint, not a stair step)")
	t["stair_ascend_loop"]=row(RUN_REG,[0,1,2,3,4,5,6,7],14,true,up,"approved cleaned RUN cycle (a sprint, not a climbing stride)")
	t["stair_ascend_exit"]=row(RUN_REG,[4,5,6,7],16,false,[Vector2(run,-rise),Vector2(run,-rise*0.5),Vector2(run,0),Vector2(run,0)],"approved cleaned RUN strip frames 4-7 (not a top-step transition)")
	t["stair_descend_enter"]=row(RUN_REG,[0,1,2,3],16,false,[Vector2(run,0),Vector2(run,0),Vector2(run,rise*0.5),Vector2(run,rise)],"approved cleaned RUN strip frames 0-3 (not a heel-first descent)")
	t["stair_descend_loop"]=row(RUN_REG,[0,1,2,3,4,5,6,7],14,true,down,"approved cleaned RUN cycle (not a heel-first descending stride)")
	t["stair_descend_exit"]=row(RUN_REG,[4,5,6,7],16,false,[Vector2(run,rise),Vector2(run,rise*0.5),Vector2(run,0),Vector2(run,0)],"approved cleaned RUN strip frames 4-7 (not a bottom-step transition)")
	t["stair_arrive_idle_settle"]=row(IDLE_REG,[0,1,2,3],12,false,[],"approved cleaned IDLE strip frames 0-3 (breathing idle, not a settle)")
	t["stair_descend_arrive_settle"]=row(IDLE_REG,[0,1,2,3],12,false,[],"approved cleaned IDLE strip frames 0-3 (breathing idle, not a settle)")
	var walk=0.12*f/4.0
	var w=[];for i in 8: w.append(Vector2(walk,0))
	t["door_approach_walk"]=row(RUN_REG,[0,1,2,3,4,5,6,7],12,true,w,"approved cleaned RUN cycle slowed (a sprint, not a walk)")
	var turn=KEY_REG.duplicate();turn.strip=TURN_KEY
	t["door_turn_to_rear"]=row(turn,[0,0,0,0],16,false,[],"single HELD ART-04 turn_depth_key, mirrored for leftward use (a held pose, not a turn)")
	var enter=KEY_REG.duplicate();enter.strip=ENTER_KEY
	t["door_cross"]=row(enter,[0,0,0,0,0,0,0,0],12,false,[],"single HELD ART-04 enter_depth_key (a held pose, not a crossing)")
	t["door_emerge"]=row(IDLE_REG,[0,1,2,3,4,5],12,false,[],"approved cleaned IDLE strip frames 0-5, side profile (not an emergence toward camera)")
	t["door_turn_to_side"]=row(IDLE_REG,[6,7,0,1],16,false,[],"approved cleaned IDLE strip frames 6,7,0,1 (not a turn)")
	t["door_walk_out"]=row(RUN_REG,[0,1,2,3,4,5,6,7],12,true,w,"approved cleaned RUN cycle slowed (a sprint, not a walk)")
	return t

static func row(reg:Dictionary,frames:Array,fps:float,loop:bool,motion:Array,what:String) -> Dictionary:
	var r=reg.duplicate()
	r.frames=frames;r.fps=fps;r.durations=[];r.loop=loop;r.root_motion=motion;r.contacts=[]
	r.facing="right";r.flip=true;r.strip_left=""
	r.bound="stand-in";r.provenance="STAND-IN: "+what;r.label=STANDIN_LABEL
	r.sha256="";r.bytes=0
	return r

## Path normalisation: manifests store repo-relative paths.
static func res_path(path:String) -> String:
	if path.is_empty() or path.begins_with("res://"): return path
	return "res://"+path.trim_prefix("./")

static func read_manifest(path:=MANIFEST_PATH) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var parsed=JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

## Why an ART-08 manifest row cannot bind (empty string = it binds).
static func rejection(entry:Dictionary) -> String:
	var status=str(entry.get("status","")).strip_edges().to_lower()
	if status=="unfinished": return "status 'unfinished'"
	var provenance=str(entry.get("provenance","")).strip_edges().to_lower()
	if provenance in NOT_ANIMATION or provenance.begins_with("held") or provenance.begins_with("unfinished"):
		return "provenance '%s' is not animation"%provenance
	var strip=res_path(str(entry.get("strip","")))
	if strip.is_empty() or not ResourceLoader.exists(strip): return "strip not in this checkout: "+strip
	var frames=int(entry.get("hframes",0))
	if frames<2: return "fewer than 2 frames"
	var cell=entry.get("cell",[480,724])
	if not cell is Array or cell.size()!=2: return "bad cell"
	return ""

static func vec(value,fallback:=Vector2.ZERO) -> Vector2:
	if value is Array and value.size()>=2 and (value[0] is float or value[0] is int): return Vector2(float(value[0]),float(value[1]))
	return fallback

## ART-08 marks some shipped clips as stand-ins (usable, not final). They bind by path but
## keep the on-screen STAND-IN label.
static func is_standin_status(entry:Dictionary) -> bool:
	var status=str(entry.get("status","")).strip_edges().to_lower().replace("-","_").replace(" ","_")
	return status in ["stand_in","standin"]

## Builds the bound ART-08 clip from a manifest row (already validated).
static func from_manifest(entry:Dictionary,defaults:Dictionary) -> Dictionary:
	var cell=entry.get("cell",defaults.get("cell",[480,724]))
	var pivot=entry.get("pivot",defaults.get("pivot",[240,600]))
	var count=int(entry.hframes)
	var frames=[];for i in count: frames.append(i)
	var motion=[]
	var rm=entry.get("root_motion_px_per_frame",null)
	if rm is Array and rm.size()>0:
		if rm[0] is Array:
			for i in count: motion.append(vec(rm[mini(i,rm.size()-1)]))
		else:
			for i in count: motion.append(vec(rm))
	var durations=[]
	var given=entry.get("durations",entry.get("frame_durations",[]))
	if given is Array and given.size()==count:
		for d in given: durations.append(float(d))
	var facing=str(entry.get("facing","right"))
	var both=bool(entry.get("drawn_both_directions",false))
	return {"strip":res_path(str(entry.strip)),"hframes":count,"cell":cell,"pivot":pivot,
		"figure":float(entry.get("figure_height_px",0.0)),
		"world_scale":float(entry.get("engine_scale_world",defaults.get("engine_scale_world",ART08_WORLD_SCALE))),
		"frames":frames,"fps":float(entry.get("fps",12)),"durations":durations,"loop":bool(entry.get("loop",false)),
		"root_motion":motion,"contacts":entry.get("contact_frames",[]) if entry.get("contact_frames",[]) is Array else [],
		"facing":facing,"flip":not "no flip" in facing,
		"strip_left":res_path(str(entry.get("strip_left",""))) if both else "",
		"bound":"art08-standin" if is_standin_status(entry) else "art08",
		"status":str(entry.get("status","")),"alias_of":str(entry.get("alias_of","")) if entry.get("alias_of")!=null else "",
		"provenance":str(entry.provenance),"label":STANDIN_LABEL if is_standin_status(entry) else "",
		"sha256":str(entry.get("sha256","")),"bytes":int(entry.get("bytes",0) if entry.get("bytes",0)!=null else 0)}

## Resolved table: name -> clip dictionary with "texture" loaded. Keeps textures alive.
static func build(manifest_path:=MANIFEST_PATH) -> Dictionary:
	var table=standins()
	var manifest=read_manifest(manifest_path)
	var rows={}
	for entry in manifest.get("clips",[]):
		if entry is Dictionary and entry.has("name"): rows[str(entry.name)]=entry
	for name in CLIPS:
		var clip:Dictionary=table[name]
		clip.name=name
		clip.rejected=""
		if name in rows:
			var why=rejection(rows[name])
			if why.is_empty(): clip=from_manifest(rows[name],manifest);clip.name=name;clip.rejected=""
			else: clip.rejected=why
		clip.texture=load(clip.strip)
		clip.texture_left=load(clip.strip_left) if not str(clip.strip_left).is_empty() and ResourceLoader.exists(clip.strip_left) else null
		if float(clip.figure)<=0.0: clip.figure=measure_figure(clip)
		clip.soles=measure_soles(clip) if str(clip.bound).begins_with("art08") else []
		if clip.root_motion.is_empty() and name.begins_with("stair_") and not name.ends_with("arrive_settle") and name!="stair_arrive_idle_settle":
			# Real stair clip without root motion: drive it along the stand-in step so the
			# feet still travel the flight. Reported as a binding note, never silently.
			clip.root_motion=default_motion(name,clip)
			clip.motion_note="root motion missing in manifest; stand-in step applied"
		table[name]=clip
	return table

static func default_motion(name:String,clip:Dictionary) -> Array:
	var f=float(clip.figure);var run=STEP_RUN*f/4.0;var rise=STEP_RISE*f/4.0
	var sign=-1.0 if "ascend" in name else 1.0
	var motion=[]
	for i in clip.frames.size():
		var u=1.0
		if name.ends_with("_enter"): u=clampf(float(i-1)/2.0,0,1)
		elif name.ends_with("_exit"): u=clampf(1.0-float(i)/2.0,0,1)
		motion.append(Vector2(run,sign*rise*u))
	return motion

## Figure height in source px: pivot row minus the highest opaque row of any frame.
static func measure_figure(clip:Dictionary) -> float:
	var tex=clip.texture
	if tex==null: return ART08_FIGURE_FALLBACK
	var image:Image=tex.get_image()
	if image==null or image.is_empty(): return ART08_FIGURE_FALLBACK
	if image.is_compressed(): image.decompress()
	var w=int(clip.cell[0]);var top=int(clip.pivot[1])
	for frame in clip.frames:
		var x0=int(frame)*w
		for y in range(0,int(clip.pivot[1]),4):
			var hit=false
			for x in range(x0,mini(x0+w,image.get_width()),6):
				if image.get_pixel(x,y).a>0.5: hit=true;break
			if hit: top=mini(top,y);break
	return maxf(64.0,float(clip.pivot[1])-top)

## Lowest opaque point (sole) of each frame, relative to the pivot, source px. Used to
## seat stage treads under planted feet. Only measured for ART-08 strips, whose cells are
## clean registered alpha; the reused approved strips carry padding below the baseline.
static func measure_soles(clip:Dictionary) -> Array:
	var out=[]
	var tex=clip.texture
	if tex==null: return out
	var image:Image=tex.get_image()
	if image==null or image.is_empty(): return out
	if image.is_compressed(): image.decompress()
	var w=int(clip.cell[0]);var h=mini(int(clip.cell[1]),image.get_height())
	for frame in clip.frames:
		var x0=int(frame)*w;var found=Vector2.INF
		for y in range(h-1,-1,-1):
			var xs=[]
			for x in range(x0,mini(x0+w,image.get_width()),2):
				if image.get_pixel(x,y).a>0.5: xs.append(x-x0)
			if xs.size()>=3:
				found=Vector2(float(xs[0]+xs[-1])/2.0-float(clip.pivot[0]),float(y)-float(clip.pivot[1]));break
		out.append(found)
	return out

## Seconds for one pass of the clip at rate 1.
static func duration(clip:Dictionary) -> float:
	var total=0.0
	for i in clip.frames.size(): total+=frame_duration(clip,i)
	return total

static func frame_duration(clip:Dictionary,i:int) -> float:
	if clip.durations.size()==clip.frames.size(): return maxf(0.001,float(clip.durations[i]))
	return 1.0/maxf(1.0,float(clip.fps))

## Total root motion of one pass (source px, drawn facing right).
static func motion_total(clip:Dictionary) -> Vector2:
	var total=Vector2.ZERO
	for v in clip.root_motion: total+=v
	return total

## Per-clip binding summary used by tests, captures and the PM report.
static func summary(table:Dictionary) -> Array:
	var out=[]
	for name in CLIPS:
		var c=table[name]
		out.append({"clip":name,"bound":c.bound,"strip":c.strip,"frames":c.frames.size(),"fps":c.fps,"provenance":c.provenance,"rejected":c.get("rejected",""),"motion_note":c.get("motion_note","")})
	return out
