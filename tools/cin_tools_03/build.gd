extends SceneTree
## Rebuild seed resources only. Never run over creator-authored files.
const PARTS = "res://assets/cin_tools_03/rig_parts/"
const OUT = "res://presets/cutins/studio/"
func _init(): call_deferred("run")
func node(parent, name_, at = Vector2.ZERO):
 var n = Node2D.new(); n.name = name_; n.position = at; parent.add_child(n); return n
func piece(parent, part, at, size = Vector2.ZERO, region = Rect2()):
 var s = Sprite2D.new(); s.name = "Art"; s.texture = load(PARTS + part + ".png")
 s.centered = false; s.position = at
 if region.size != Vector2.ZERO: s.region_enabled = true; s.region_rect = region
 if size != Vector2.ZERO:
  s.scale = size / (region.size if region.size != Vector2.ZERO else s.texture.get_size())
 parent.add_child(s); return s
func own(n, root_):
 for child in n.get_children():
  child.owner = root_
  if child.scene_file_path.is_empty(): own(child, root_)
func save_scene(n, path):
 own(n, n)
 var packed = PackedScene.new(); assert(packed.pack(n) == OK)
 assert(ResourceSaver.save(packed, path) == OK)
func track(anim, path, times, values, discrete = false):
 var i = anim.add_track(Animation.TYPE_VALUE); anim.track_set_path(i, NodePath(path))
 anim.value_track_set_update_mode(i, Animation.UPDATE_DISCRETE if discrete else Animation.UPDATE_CONTINUOUS)
 for k in times.size(): anim.track_insert_key(i, times[k], values[k])
 return i
func run():
 var actor = Node2D.new(); actor.name = "Actor"; actor.set_script(load("res://tools/cin_tools_03/actor.gd"))
 var rig = node(actor, "Rig", Vector2(0, -185))
 for side in ["Far", "Near"]:
  var leg = node(rig, "Leg" + side, Vector2(-7 if side == "Far" else 7, 0))
  piece(leg, "leg_tube", Vector2(-14, -4), Vector2(28, 70), Rect2(0, 0, 49, 80))
  var shin = node(leg, "Shin", Vector2(0, 65))
  piece(shin, "leg_tube", Vector2(-12, -4), Vector2(24, 70), Rect2(0, 70, 49, 79))
  var boot = node(shin, "Boot", Vector2(0, 65)); piece(boot, "boot", Vector2(-28, -8))
 var torso = node(rig, "Torso")
 var hair = node(torso, "Hair", Vector2(11, -113)); piece(hair, "hair", Vector2(-146, -38))
 piece(torso, "torso", Vector2(-60, -99))
 var head = node(torso, "Head", Vector2(11, -113)); piece(head, "head", Vector2(-5, -38))
 var ribbon = node(torso, "Ribbon", Vector2(6, -143)); piece(ribbon, "ribbon", Vector2(-79, -13))
 for side in ["Far", "Near"]:
  var arm = node(torso, "Arm" + side, Vector2(-6 if side == "Far" else 4, -90))
  piece(arm, "arm_tube", Vector2(-15, -5), Vector2(30, 51), Rect2(0, 0, 53, 65))
  var lower = node(arm, "Forearm", Vector2(0, 46))
  piece(lower, "arm_tube", Vector2(-12, -3), Vector2(24, 50), Rect2(0, 65, 53, 58))
  piece(node(lower, "Hand", Vector2(0, 46)), "fist", Vector2(-14, -4))
 var sprite = Sprite2D.new(); sprite.name = "Sprite"
 sprite.texture = load("res://assets/kaze/cleaned/kaze_run_strip.png")
 sprite.hframes = 8; sprite.offset = Vector2(0, -238); sprite.scale = Vector2.ONE * .85
 actor.add_child(sprite)
 var player = AnimationPlayer.new(); player.name = "AnimationPlayer"; actor.add_child(player)
 var clip = Animation.new(); clip.resource_name = "Sprint to stop — candidate"; clip.length = 4.2
 track(clip, ".:position", [0, .25, 1.45, 1.8, 2.15, 2.55, 4.2], [Vector2(200,610),Vector2(245,610),Vector2(665,610),Vector2(745,610),Vector2(782,610),Vector2(790,610),Vector2(790,610)])
 track(clip, ".:mode", [0, 1.5], [1, 0], true)
 var times = []; var frames = []
 for i in 13: times.append(i / 8.0); frames.append(i % 8)
 track(clip, "Sprite:frame", times, frames, true)
 track(clip, "Rig/Torso:rotation", [0,1.5,1.8,2.15,2.55,3.0,4.2], [-.25,-.25,.1,.14,-.04,0.,0.])
 track(clip, "Rig/Torso/Head:rotation", [0,1.5,2.15,2.55,3.0,4.2], [.25,.25,-.14,.04,0.,0.])
 track(clip, "Rig/Torso/Hair:rotation", [0,1.5,1.9,2.3,2.7,3.2,4.2], [.28,.28,-.16,.13,-.06,0.,0.])
 track(clip, "Rig/Torso/Ribbon:rotation", [0,1.5,1.9,2.3,2.7,3.2,4.2], [.4,.4,-.25,.2,-.1,0.,0.])
 for side in ["Far", "Near"]:
  var sign_ = -1 if side == "Far" else 1
  track(clip,"Rig/Leg"+side+":rotation",[0,1.5,1.8,2.15,2.55,3.,4.2],[sign_*.6,sign_*.6,sign_*.3,-sign_*.1,sign_*.05,sign_*.04,sign_*.04])
  track(clip,"Rig/Leg"+side+"/Shin:rotation",[0,1.5,1.8,2.15,2.55,3.,4.2],[-.8,-.8,-.4,-.15,0.,0.,0.])
  track(clip,"Rig/Torso/Arm"+side+":rotation",[0,1.5,1.8,2.15,2.55,3.,4.2],[.95,.95,.5,-.2,.08,0.,0.])
  track(clip,"Rig/Torso/Arm"+side+"/Forearm:rotation",[0,1.5,1.8,2.15,2.55,3.,4.2],[-.25,-.25,-.5,-.8,-.4,-.2,-.2])
 assert(ResourceSaver.save(clip, OUT+"sprint_stop.tres") == OK)
 actor.clip = load(OUT+"sprint_stop.tres")
 save_scene(actor, OUT+"actor.tscn")
 actor.free()
 for kind in ["animator", "director"]:
  var stage = load("res://presets/cutins/special_transition.tscn").instantiate()
  stage.name = "CharacterAnimator" if kind == "animator" else "CinematicDirector"
  stage.set_script(load("res://tools/cin_tools_03/presentation.gd"))
  # Remove obsolete actor tracks; retain existing framing/environment/tint/audio nodes.
  var actor_ = load(OUT+"actor.tscn").instantiate()
  stage.get_node("Framing/Shake").add_child(actor_)
  stage.get_node("Framing/Shake/Character").visible = false
  stage.get_node("Status").text = "CANDIDATE RIG / APPROVED SPRITE — flat-art seams and pose switch visible"
  var title = stage.get_node_or_null("Title")
  if title:
   title.position = Vector2(40,90); title.add_theme_font_size_override("font_size",30)
   title.text = "Sprint → brake → settle" if kind == "animator" else "One reusable clip / two shots"
  stage.get_node("Destination").text = "PRESENTATION STUDY / NO CAMPAIGN PLACEMENT"
  stage.get_node("Fade").color.a = 0
  var library = AnimationLibrary.new()
  for variant in ["standard", "reduced"]:
   var a = stage.get_node("AnimationPlayer").get_animation(variant).duplicate(true)
   for i in range(a.get_track_count()-1,-1,-1):
    if str(a.track_get_path(i)) not in ["Framing/Shake/Background:position", "Framing/Shake/Foreground:position"]: a.remove_track(i)
   a.length = 4.2 if kind == "animator" else 8.4
   track(a,".:handoff",[0],[false],true)
   track(a,".:shake_strength",[0],[0.])
   if kind == "animator" or variant == "reduced":
    track(a,"Framing:position",[0],[Vector2.ZERO])
    track(a,"Framing:scale",[0],[Vector2.ONE])
   if variant == "reduced": track(a,".:clip_time",[0],[4.2])
   elif kind == "animator": track(a,".:clip_time",[0,4.2],[0.,4.2])
   else:
    # Two shots reference the same external clip, with an explicit cut/reset.
    track(a,".:clip_time",[0,4.199,4.2,8.4],[0.,4.199,0.,4.2])
    if variant == "standard":
     track(a,"Framing:scale",[0,4.199,4.2,8.4],[Vector2.ONE,Vector2.ONE,Vector2(1.08,1.08),Vector2(1.08,1.08)],true)
     track(a,"Framing:position",[0,4.199,4.2,8.4],[Vector2.ZERO,Vector2.ZERO,Vector2(-30,-38),Vector2(-30,-38)],true)
   library.add_animation(variant,a)
  var p = stage.get_node("AnimationPlayer"); p.remove_animation_library(""); p.add_animation_library("",library)
  stage.artwork_status = "Presentation-only prototype. ART-08 cutout candidate; approved sprite bytes unchanged."
  save_scene(stage,OUT+kind+".tscn"); stage.free()
 print("CIN-TOOLS-03 seed resources saved")
 quit()
