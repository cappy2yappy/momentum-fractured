extends SceneTree
var failures=[]
var checks=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures.append(label)
func _init():call_deferred('run')
func key(study,code):
 var e=InputEventKey.new();e.keycode=code;e.pressed=true
 study._unhandled_key_input(e)
func run():
 var study=load('res://tools/art09_image4/demo.tscn').instantiate();root.add_child(study)
 study.set_process(false)
 check(study.manifest.source_sha256=='0c9dc1eeab228a683d86cd156d02251400e7ebd7c1b1a46b1e56e8ae2d44bb09','actual source bound')
 for i in 4:
  key(study,KEY_1+i);check(study.mode==i and study.elapsed==0,'mode shortcut resets playhead')
  study.elapsed=1.9;var a=study.root_position();study.elapsed=3.8;var b=study.root_position()
  check(b.x>a.x,'root continues right in each study')
  if i==1:check(b.y<a.y,'ascent rises')
  if i==2:check(b.y>a.y,'descent lowers')
  check(study.chosen() in [138,139,140,141,142,143],'only reviewed pose ROIs used')
 study.elapsed=.4;key(study,KEY_SPACE);study._process(.1);check(study.elapsed==.4,'pause freezes timeline')
 key(study,KEY_SPACE);study._process(.1);check(is_equal_approx(study.elapsed,.5),'resume restores progression')
 key(study,KEY_R);check(study.elapsed==0,'restart restores start')
 key(study,KEY_C);check(study.catalog,'catalog keyboard reachable');key(study,KEY_RIGHT);check(study.page==1,'catalog advances')
 key(study,KEY_C);check(not study.catalog,'catalog returns control')
 check(study.get_child_count()==0,'presentation has no world/player/save children')
 study.queue_free();await process_frame
 print('ART09_STUDY checks=',checks,' failures=',failures.size())
 for f in failures:print('FAIL: ',f)
 quit(0 if failures.is_empty() else 1)
