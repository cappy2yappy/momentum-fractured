extends Node2D
## Isolated presentation study. No world, save, StoryDirector or player is loaded.
const ASSET='res://assets/art09_image4/'
var manifest:Dictionary
var textures={}
var mode=0
var elapsed=0.0
var paused=false
var catalog=false
var page=0
var auto_capture=false
var frames=[]
var capture_busy=false
var capture_done=false
var capture_started=0
var last_capture=-1.0
var shots={}
var run_total=0.0
var captures='res://build/art09_image4/capture'
var modes=['sprint','ascent','descent','braking']
var font=ThemeDB.fallback_font
var scale_art=3.0
func _ready():
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 manifest=JSON.parse_string(FileAccess.get_file_as_string(ASSET+'MANIFEST.json'))
 for row in manifest.frames:
  textures[int(row.id)]=ImageTexture.create_from_image(Image.load_from_file('res://'+row.path))
 auto_capture='--art09-capture' in OS.get_cmdline_user_args()
 if auto_capture:
  DirAccess.make_dir_recursive_absolute(captures)
  capture_started=Time.get_ticks_usec()
 queue_redraw()
func _unhandled_key_input(event):
 if not event is InputEventKey or not event.pressed or event.echo:return
 if event.keycode==KEY_SPACE:paused=not paused
 if event.keycode==KEY_R:elapsed=0.0
 if event.keycode==KEY_C:catalog=not catalog
 if event.keycode==KEY_RIGHT:
  if catalog:page=(page+1)%5
  else:mode=(mode+1)%4;elapsed=0.0
 if event.keycode==KEY_LEFT:
  if catalog:page=(page+4)%5
  else:mode=(mode+3)%4;elapsed=0.0
 if event.keycode>=KEY_1 and event.keycode<=KEY_4:mode=event.keycode-KEY_1;elapsed=0.0;catalog=false
func chosen()->int:
 var c=manifest.clips[modes[mode]]
 if mode==3:
  var t=fmod(elapsed,3.8)
  if t<1.5:return [138,139,140][int(t*10)%3]
  t-=1.5
  for i in c.durations.size():
   if t<float(c.durations[i]):return int(c.poses[i])
   t-=float(c.durations[i])
  return 143
 return int(c.poses[int(elapsed*float(c.fps))%c.poses.size()])
func root_position()->Vector2:
 var t=clampf(elapsed/3.8,0,1)
 if mode==0:return Vector2(180+t*850,565)
 if mode==1:return Vector2(230+t*760,565-t*264)
 if mode==2:return Vector2(230+t*760,301+t*264)
 return Vector2(180+760*(1-pow(1-t,3)),565)
func pose(id:int,root_at:Vector2,s:float):
 var texture=textures[id];var size=texture.get_size()
 var target=Rect2(root_at-Vector2(size.x/2,size.y-1)*s,size*s)
 draw_texture_rect(texture,target,false)
func text(at:Vector2,label:String,size=18,color=Color(.82,.86,.94)):
 draw_string(font,at,label,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func _draw():
 draw_rect(Rect2(0,0,1280,720),Color('#172333'))
 text(Vector2(30,36),'ART09 / ACTUAL IMAGE 4 / CANDIDATE POSE STUDIES',26)
 text(Vector2(30,64),'Source pixels extracted deterministically; PR30 remains the identity reference.',17)
 if catalog:
  text(Vector2(30,94),'CATALOG page %d / 5 | Row groups are mixed action poses, not assumed cycles.'%[page+1],18)
  for slot in 35:
   var id=page*35+slot
   if id>=manifest.frames.size():break
   var col=slot%7;var row=slot/7
   var at=Vector2(100+col*178,208+row*111)
   var texture=textures[id];var fit=minf(1.0,80.0/texture.get_height())
   draw_rect(Rect2(at-Vector2(75,90),Vector2(158,108)),Color('#24374b'))
   pose(id,at,fit)
   text(at+Vector2(-60,21),'pose_%03d'%id,14)
  return
 var clip=manifest.clips[modes[mode]]
 text(Vector2(30,105),modes[mode].to_upper()+'  |  '+str(clip.status),18,Color('#ffce79'))
 text(Vector2(30,131),'Sparse source keys; timing and movement are study parameters. Tread planting is unvalidated.',16)
 # Alternating dark/light backgrounds expose extraction fringes.
 for i in 16:
  draw_rect(Rect2(i*80,160,80,465),Color('#24374b') if i%2==0 else Color('#293d51'))
 draw_line(Vector2(50,567),Vector2(1210,567),Color('#d1b48b'),3)
 if mode in [1,2]:
  var previous=Vector2(195,565 if mode==1 else 301)
  for i in 9:
   var x=195+i*95.0
   var y=(565-i*33.0) if mode==1 else (301+i*33.0)
   draw_line(previous,Vector2(x,y),Color('#b7b0a2'),3)
   draw_line(Vector2(x,y),Vector2(x+95,y),Color('#b7b0a2'),3)
   previous=Vector2(x+95,y)
 var feet=root_position()
 pose(chosen(),feet,scale_art)
 draw_circle(feet,4,Color('#ffb75b'))
 text(Vector2(30,650),'Pose %03d   t %.2fs   |   1 sprint  2 ascent  3 descent  4 braking'%[chosen(),elapsed],18)
 text(Vector2(30,678),'Space pause / resume   R restart   Left / Right choose   C catalog (arrows change page)',17)
 text(Vector2(30,704),'PRESENTATION ONLY: no production scene, physics, save or story ownership.',15,Color('#a9b9c8'))
func _process(dt):
 if capture_done:return
 if not paused and not catalog:elapsed+=dt
 if auto_capture:
  run_total=(Time.get_ticks_usec()-capture_started)/1000000.0
  var target_mode=mini(3,int(run_total/4.2))
  if target_mode!=mode:mode=target_mode;elapsed=0.0
  if run_total>16.8:
   catalog=true;page=mini(4,int((run_total-16.8)/.4))
  queue_redraw()
  if run_total-last_capture>1.0/20.0 and not capture_busy:
   capture_busy=true
   last_capture=run_total
   await RenderingServer.frame_post_draw
   if not is_inside_tree():return
   var actual=(Time.get_ticks_usec()-capture_started)/1000000.0
   var path=captures+'/frame_%05d.jpg'%frames.size()
   get_viewport().get_texture().get_image().save_jpg(path,.92)
   frames.append({'path':ProjectSettings.globalize_path(path),'time':actual})
   var label=('catalog_%d'%page) if catalog else modes[mode]
   if not shots.has(label) and (catalog or elapsed>(2.4 if mode==3 else 1.1)):
    get_viewport().get_texture().get_image().save_png(captures+'/'+label+'.png');shots[label]=true
   capture_busy=false
  if run_total>19.0 and not capture_busy:
   capture_done=true
   set_process(false)
   var f=FileAccess.open(captures+'/timing.json',FileAccess.WRITE)
   f.store_string(JSON.stringify({'frames':frames,'clock':'Time.get_ticks_usec after frame_post_draw; no fixed FPS','elapsed':run_total,'engine':Engine.get_version_info().string,'renderer':RenderingServer.get_video_adapter_name(),'source_sha256':manifest.source_sha256,'status':'candidate pose timing studies; incomplete cycles, tread contacts unvalidated'},'  '));f.close()
   print('ART09_CAPTURE samples=',frames.size(),' elapsed=',run_total,' modes=',shots.keys())
   get_tree().quit()
 else:
  if elapsed>3.8:elapsed=0.0
  queue_redraw()
