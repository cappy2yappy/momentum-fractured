extends Sprite2D
## TR-08: plays one clip from the TR-08 clip table (tr08_clip_library.gd).
## play(clip, heading, start_frame) per ANIMATION_INTERFACE.md. Registration puts the
## clip pivot (feet contact centre) on this node's origin. Drawn facing right; heading<0
## mirrors (flip_h) unless the clip ships a drawn left strip. Root motion is returned by
## advance() in source px, already signed for heading, spread evenly over each frame.
const Library = preload("res://scripts/tr08_clip_library.gd")
var clip: Dictionary = {}
var heading = 1
var index = 0
var into = 0.0          # seconds into the current frame
var rate = 1.0
var finished = false
var base_scale = 1.0
var depth = 1.0         # extra staging scale (depth cue only, documented as staging)
var travelled = Vector2.ZERO  # root motion since play(), source px, heading applied

func play(c:Dictionary,h:int,start_frame:=0,playback_rate:=1.0):
	clip=c;heading=1 if h>=0 else -1;index=clampi(start_frame,0,c.frames.size()-1)
	into=0.0;rate=maxf(0.05,playback_rate);finished=false;travelled=Vector2.ZERO
	var left=heading<0 and c.get("texture_left")!=null
	texture=c.texture_left if left else c.texture
	hframes=int(c.hframes);vframes=1
	flip_h=heading<0 and not left and bool(c.flip)
	centered=true
	apply()

func apply():
	if clip.is_empty(): return
	frame=clampi(int(clip.frames[index]),0,hframes-1)
	var cw=float(clip.cell[0]);var ch=float(clip.cell[1])
	var px=float(clip.pivot[0]);var py=float(clip.pivot[1])
	offset=Vector2((cw/2.0-px)*(-1.0 if flip_h else 1.0),ch/2.0-py)
	scale=Vector2.ONE*base_scale*depth

func frame_time() -> float:
	return Library.frame_duration(clip,index)/rate

## Advances by dt. Returns the root motion travelled (source px, heading applied).
func advance(dt:float) -> Vector2:
	var moved=Vector2.ZERO
	if clip.is_empty() or finished: return moved
	var left=dt
	while left>0.0 and not finished:
		var span=frame_time()
		var take=minf(left,span-into)
		if clip.root_motion.size()>index:
			var rm:Vector2=clip.root_motion[index]
			moved+=Vector2(rm.x*heading,rm.y)*(take/span)
		into+=take;left-=take
		if into>=span-0.000001:
			into=0.0
			if index+1<clip.frames.size(): index+=1
			else: finished=true
	apply()
	travelled+=moved
	return moved

func has_depth_motion() -> bool:
	for v in clip.get("root_motion",[]):
		if absf(v.y)>0.01: return true
	return false

func pass_time() -> float:
	return Library.duration(clip)/rate

func is_standin() -> bool:
	return clip.get("bound","")!="art08"

func is_art08() -> bool:
	return str(clip.get("bound","")).begins_with("art08")

func status() -> String:
	if clip.is_empty(): return ""
	if not is_standin(): return "ART-08 · "+clip.name
	return "%s · %s%s"%[Library.STANDIN_LABEL,clip.name," (ART-08 stand-in)" if is_art08() else ""]
