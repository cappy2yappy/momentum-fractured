extends RefCounted
## Optional consumer for TR39's existing Sprite2D proxy. Owns presentation only.
## WIP is always refused; a candidate requires the caller's explicit opt-in.
const Frames = preload("res://assets/art05/kaze/ART05_candidates.tres")
var manifest = JSON.parse_string(FileAccess.get_file_as_string("res://assets/art05/MANIFEST.json"))

func apply(sprite:Sprite2D, id:StringName, elapsed:float, allow_candidate=false) -> bool:
	var spec={}
	for entry in manifest.clips:
		if entry.id==str(id):spec=entry;break
	if spec.is_empty() or spec.status!="candidate" or not allow_candidate:return false
	var count=Frames.get_frame_count(id)
	var index=clampi(int(maxf(elapsed,0)*Frames.get_animation_speed(id)),0,count-1)
	sprite.texture=Frames.get_frame_texture(id,index)
	sprite.hframes=1;sprite.vframes=1;sprite.frame=0
	sprite.offset=Vector2(0,-238);sprite.scale=Vector2.ONE*0.303125
	sprite.flip_h=false;sprite.modulate=Color.WHITE
	return true
