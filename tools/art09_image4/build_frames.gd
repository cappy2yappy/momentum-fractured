extends SceneTree
const OUT='res://assets/art09_image4'
func _init():
 var source=Image.load_from_file('res://source_art/art09-image4/image4-original.png')
 var keyed=Image.load_from_file(OUT+'/sheet_keyed.png')
 var data=JSON.parse_string(FileAccess.get_file_as_string('res://docs/alpha07/art09-image4/components.json'))
 var frames=[];var n=0;var retained=0;var changed=0
 for y in keyed.get_height():
  for x in keyed.get_width():
   var c=keyed.get_pixel(x,y)
   if c.a>0:
    retained+=1
    if c!=source.get_pixel(x,y):changed+=1
 for row in data.components:
  var b=row.bbox;var rect=Rect2i(b[0],b[1],b[2],b[3])
  var img=keyed.get_region(rect);var name='pose_%03d'%n
  img.save_png(OUT+'/frames/'+name+'.png')
  var category='combat / locomotion mixed keys'
  var y=b[1]
  if y<220:category='standing, alternate run and punch keys'
  elif y<340:category='crouch, low attack and floor keys'
  elif y>800 and y<1040:category='kick / acrobatics / possible flip keys'
  elif y>1140 and y<1280:category='acrobatics / possible frontflip keys'
  elif y>1670 and y<1810:category='standing, guard and portrait'
  elif y>1800:category='front/back turnaround and combat variants'
  if n in [138,139,140]:category='arms-back sprint priority keys (incomplete cycle)'
  if n in [141,142,143]:category='guard keys selected for braking pose study'
  var review='catalog only; source anatomy and identity unapproved'
  if n in [138,139,140]:review='priority manually reviewed ROI: full running silhouette; sparse keys, face/ribbon identity needs creator acceptance'
  if n in [141,142,143]:review='manually reviewed guard ROI; not an authored braking sequence'
  if n in [161,162,163,164]:review='REJECT FROM PILOT: exposed tan torso / widened body variant diverges from PR30 jacket silhouette'
  if n==146:review='PORTRAIT ONLY: not a sprite pose or cycle frame'
  frames.append({'review':review,'id':n,'name':name,'path':'assets/art09_image4/frames/'+name+'.png','source_bbox':b,'pixels':row.pixels,'category':category,'pivot':[b[2]/2.0,b[3]-1],'status':'extracted candidate, creator acceptance pending'})
  n+=1
 var manifest={'source':'source_art/art09-image4/image4-original.png','source_sha256':'0c9dc1eeab228a683d86cd156d02251400e7ebd7c1b1a46b1e56e8ae2d44bb09','identity_reference_pr':30,'identity_reference_sha':'a6b76b9938825307bdcd4efb687c7198ea0d8681','retained_pixels':retained,'retained_rgb_changes':changed,'catalog_note':'170 connected foreground components >=100 px, including portrait; not 170 validated poses. Smaller detached fragments are not independently catalogued; chosen full ROIs reviewed manually.','frames':frames,'clips':{'sprint':{'poses':[138,139,140],'fps':10,'status':'three-key incomplete cycle study'},'ascent':{'poses':[138,139,140],'fps':10,'status':'same sprint keys on ascent root path; no authored stair contact'},'descent':{'poses':[138,139,140],'fps':8,'status':'same sprint keys on descent root path; no authored landing compression'},'braking':{'poses':[140,141,142,143],'durations':[0.12,0.16,0.18,0.28],'status':'sprint-to-guard pose study; guard keys not sequential braking drawings'}}}
 var f=FileAccess.open(OUT+'/MANIFEST.json',FileAccess.WRITE);f.store_string(JSON.stringify(manifest,'  '));f.close()
 print('ART09 frames=',frames.size(),' retained=',retained,' changed RGB=',changed)
 quit(0 if changed==0 else 1)
