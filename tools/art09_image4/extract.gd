extends SceneTree
const OUT='res://assets/art09_image4'
func bg(c:Color)->bool:
 return maxf(c.r,maxf(c.g,c.b))-minf(c.r,minf(c.g,c.b))<.11 and c.v>.53
func _init():
 var image=Image.load_from_file('res://source_art/art09-image4/image4-original.png')
 var size=image.get_size();var w=size.x;var h=size.y
 var mask=PackedByteArray();mask.resize(w*h)
 var queue=PackedInt32Array()
 for y in h:
  for x in w:
   if x==0 or y==0 or x==w-1 or y==h-1:
    if bg(image.get_pixel(x,y)):
     var i=y*w+x;mask[i]=1;queue.append(i)
 var n=0
 while n<queue.size():
  var i=queue[n];n+=1;var x=i%w;var y=i/w
  for p in [Vector2i(x-1,y),Vector2i(x+1,y),Vector2i(x,y-1),Vector2i(x,y+1)]:
   if p.x<0 or p.y<0 or p.x>=w or p.y>=h:continue
   var j=p.y*w+p.x
   if mask[j]==0 and bg(image.get_pixelv(p)):mask[j]=1;queue.append(j)
 var green_before=0;var green_after=0;var removed=0
 for y in h:
  for x in w:
   var c=image.get_pixel(x,y)
   if c.g>c.r*1.4 and c.g>c.b*1.25 and c.g>.25:green_before+=1
   if mask[y*w+x]:image.set_pixel(x,y,Color(0,0,0,0));removed+=1
   elif c.g>c.r*1.4 and c.g>c.b*1.25 and c.g>.25:green_after+=1
 DirAccess.make_dir_recursive_absolute(OUT+'/frames')
 image.save_png(OUT+'/sheet_keyed.png')
 # Connected foreground catalog; 8-neighbour connectivity preserves pixel diagonals.
 var visited=PackedByteArray();visited.resize(w*h);var components=[]
 for y in h:
  for x in w:
   var first=y*w+x
   if mask[first] or visited[first]:continue
   var q=PackedInt32Array([first]);visited[first]=1;var k=0
   var lo=Vector2i(x,y);var hi=lo
   while k<q.size():
    var i=q[k];k+=1;var xx=i%w;var yy=i/w
    lo=lo.min(Vector2i(xx,yy));hi=hi.max(Vector2i(xx,yy))
    for dy in [-1,0,1]:
     for dx in [-1,0,1]:
      var nx=xx+dx;var ny=yy+dy
      if nx<0 or ny<0 or nx>=w or ny>=h:continue
      var j=ny*w+nx
      if not mask[j] and not visited[j]:visited[j]=1;q.append(j)
   if q.size()>=100:components.append({'bbox':[lo.x,lo.y,hi.x-lo.x+1,hi.y-lo.y+1],'pixels':q.size()})
 components.sort_custom(func(a,b):return a.bbox[1]<b.bbox[1])
 var f=FileAccess.open('res://docs/alpha07/art09-image4/components.json',FileAccess.WRITE)
 f.store_string(JSON.stringify({'source_alpha':'all 2340864 pixels opaque; checkerboard baked into RGB','key_method':'4-connected exterior flood, near neutral RGB range<0.11,value>0.53; alpha-only removal, enclosed whites preserved','source_size':[w,h],'background_removed':removed,'green_before':green_before,'green_after':green_after,'components':components},'  '));f.close()
 print('KEY removed=',removed,' green=',green_before,'/',green_after,' components=',components.size())
 quit()
