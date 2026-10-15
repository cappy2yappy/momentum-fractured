extends SceneTree
class ReviewCanvas extends Node2D:
	var texture: Texture2D
	var labels: Array = []
	var contact_manifest: Dictionary = {}
	var sources: Array = []
	func _draw():
		if texture: draw_texture(texture,Vector2.ZERO)
		for item in labels:
			draw_string(ThemeDB.fallback_font,Vector2(item.x,item.y),item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,int(item.size),Color(item.color))
		if contact_manifest.is_empty(): return
		draw_rect(Rect2(0,0,1600,1000),Color("101824"))
		draw_string(ThemeDB.fallback_font,Vector2(35,45),"KAZE / EXISTING APPROVED SPRITE AUDIT",HORIZONTAL_ALIGNMENT_LEFT,-1,30,Color("eee9da"))
		draw_string(ThemeDB.fallback_font,Vector2(35,80),"Actual source art at current gameplay scale; root guides show registration. No new turn/stair frames are implied.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("a5b7b6"))
		for row in sources.size():
			var item=contact_manifest.sprites[row]
			var tex=sources[row]
			var cell=Vector2(tex.get_width()/8.0,tex.get_height())
			for frame in 8:
				var x=40+frame*190;var y=120+row*211
				var bg=[Color("101010"),Color.WHITE,Color("777777"),Color("252b55")][frame%4]
				var ink=Color("101824") if frame%4==1 else Color("eee9da")
				draw_rect(Rect2(x,y,180,200),bg)
				draw_string(ThemeDB.fallback_font,Vector2(x+8,y+22),"%s / %02d"%[item.clip,frame],HORIZONTAL_ALIGNMENT_LEFT,-1,16,ink)
				var pivot=Vector2(x+90,y+170)
				var size=cell*item.visual_scale
				var origin=pivot-Vector2(size.x/2.0,item.ground_baseline*item.visual_scale)
				draw_texture_rect_region(tex,Rect2(origin,size),Rect2(Vector2(frame*cell.x,0),cell))
				draw_line(pivot-Vector2(72,0),pivot+Vector2(72,0),Color("e4b562"),1)
				draw_circle(pivot,3,Color("e4b562"))
		draw_string(ThemeDB.fallback_font,Vector2(35,990),"Reference contact only. Mixed traversal poses have intentional airborne registration; no per-frame recentering.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("a5b7b6"))

func _init(): call_deferred("run")
func run():
	root.content_scale_size=Vector2i(1600,1000)
	root.size=Vector2i(1600,1000)
	await process_frame
	var folder="res://docs/art/tr03/previews"
	var manifest=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("diagram_manifest.json")))
	for board in manifest.boards:
		var image=Image.new()
		if image.load_svg_from_string(FileAccess.get_file_as_string(folder.path_join(board+"_shapes.svg")))!=OK: quit(1);return
		var canvas=ReviewCanvas.new();canvas.texture=ImageTexture.create_from_image(image)
		canvas.labels=JSON.parse_string(FileAccess.get_file_as_string(folder.path_join(board+"_labels.json")))
		root.add_child(canvas)
		await process_frame;await process_frame;RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png(folder.path_join(board+".png"))
		canvas.queue_free();await process_frame
	var art=JSON.parse_string(FileAccess.get_file_as_string("res://assets/web/kaze_manifest.json"))
	var canvas=ReviewCanvas.new();canvas.contact_manifest=art
	var audit=[]
	for item in art.sprites:
		var tex=load("res://"+item.path);canvas.sources.append(tex)
		var image=tex.get_image();var cell_width=image.get_width()/8
		var data=FileAccess.get_file_as_bytes("res://"+item.path)
		var frames=[]
		for frame in 8:
			var low=Vector2i(cell_width,image.get_height());var high=Vector2i.ZERO
			var border=0
			for y in image.get_height():
				for x in cell_width:
					if image.get_pixel(frame*cell_width+x,y).a<=0.1: continue
					low=Vector2i(mini(low.x,x),mini(low.y,y));high=Vector2i(maxi(high.x,x+1),maxi(high.y,y+1))
					if x==0 or x==cell_width-1 or y==0 or y==image.get_height()-1: border+=1
			frames.append({"frame":frame,"alpha_bounds_01":[low.x,low.y,high.x,high.y],"strong_alpha_on_cell_border":border,"minimum_margin_px":mini(mini(low.x,low.y),mini(cell_width-high.x,image.get_height()-high.y))})
		audit.append({"clip":item.clip,"path":item.path,"dimensions":[image.get_width(),image.get_height()],"rgba_png":data[25]==6,"frame_count":8,"equal_cells":image.get_width()%8==0,"visual_scale":item.visual_scale,"source_pivot":[cell_width/2.0,item.ground_baseline],"frames":frames})
	root.add_child(canvas);await process_frame;await process_frame;RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(folder.path_join("CONTACT_existing_kaze.png"))
	canvas.queue_free();await process_frame
	var contract=JSON.parse_string(FileAccess.get_file_as_string("res://docs/art/tr03/transition_art_contract.json"))
	var proposed_count=0
	for clip in contract.clips: proposed_count+=clip.frames
	var qa={"source_audit":audit,"diagram_size":[1600,1000],"boards_rendered":manifest.boards.size(),"current_frame_previews":32,"new_frame_slots":proposed_count,"final_new_frames_produced":0,"loader_seconds_unchanged_in_spec":contract.loader.seconds==0.65,"current_gameplay_not_executed_by_this_fixture":true,"measured_fps":null}
	var file=FileAccess.open("res://docs/art/tr03/QA_RESULTS.json",FileAccess.WRITE);file.store_string(JSON.stringify(qa,"  "));file.close()
	print("TR03 ART REVIEW: rendered5 storyboard/architecture boards and32 source frame previews; proposed30-frame pack; zero final new painted frames.")
	quit()
