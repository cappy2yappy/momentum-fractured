extends SceneTree
func _init():
 var image=Image.load_from_file('res://source_art/art09-image4/image4-original.png')
 var alpha={};var colors={}
 for y in image.get_height():
  for x in image.get_width():
   var p=image.get_pixel(x,y);var a=int(round(p.a*255));alpha[a]=alpha.get(a,0)+1
   if x<16: colors[p.to_html()]=colors.get(p.to_html(),0)+1
 print('SIZE ',image.get_size(),' ALPHA ',alpha,' BORDER ',colors)
 quit()
