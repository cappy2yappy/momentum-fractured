extends SceneTree
var checks=0
var failures=[]
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures.append(label)
func _init():
 var path='res://source_art/art09-image4/image4-original.png'
 var source=Image.load_from_file(path)
 var sha=FileAccess.get_sha256(path)
 check(sha=='0c9dc1eeab228a683d86cd156d02251400e7ebd7c1b1a46b1e56e8ae2d44bb09','exact creator source SHA')
 var keyed=Image.load_from_file('res://assets/art09_image4/sheet_keyed.png')
 var manifest=JSON.parse_string(FileAccess.get_file_as_string('res://assets/art09_image4/MANIFEST.json'))
 var alpha=0;var modified=0;var green_in=0;var green_out=0;var bad_transparent=0
 for y in source.get_height():
  for x in source.get_width():
   var a=source.get_pixel(x,y);var b=keyed.get_pixel(x,y)
   if a.a<1:alpha+=1
   if b.a>0 and a!=b:modified+=1
   if a.g>a.r*1.4 and a.g>a.b*1.25 and a.g>.25:green_in+=1
   if b.a>0 and b.g>b.r*1.4 and b.g>b.b*1.25 and b.g>.25:green_out+=1
   if b.a==0 and (b.r!=0 or b.g!=0 or b.b!=0):bad_transparent+=1
 check(alpha==0,'source alpha all opaque (baked checkerboard)')
 check(modified==0,'retained RGBA bytes unchanged')
 check(green_in==13345 and green_out==green_in,'all neon green pixels retained')
 check(bad_transparent==0,'removed transparent pixels have zero RGB')
 check(manifest.frames.size()==170,'170 component catalog rows')
 for row in manifest.frames:
  var img=Image.load_from_file('res://'+row.path);var b=row.source_bbox
  check(img.get_size()==Vector2i(b[2],b[3]),'%s bbox dimensions'%row.name)
  var mismatch=0;var nonempty=0
  for y in img.get_height():
   for x in img.get_width():
    var p=img.get_pixel(x,y)
    if p.a>0:nonempty+=1
    if p!=keyed.get_pixel(b[0]+x,b[1]+y):mismatch+=1
  check(nonempty>0 and mismatch==0,'%s exact keyed source crop'%row.name)
 var scene=load('res://tools/art09_image4/demo.tscn')
 check(scene is PackedScene,'isolated study scene loads')
 print('ART09_INTEGRITY checks=',checks,' failures=',failures.size(),' green=',green_out,' retained_RGB_changes=',modified)
 for failure in failures:print('FAIL: ',failure)
 quit(0 if failures.is_empty() else 1)
