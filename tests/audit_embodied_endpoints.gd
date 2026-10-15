extends SceneTree
var w
func _init(): call_deferred("run")
func chain_at(index:int,left:bool) -> Vector2:
	return Vector2(120 if left else 2440,([1300,1300,1300,850,1300,1080,1300,1090,1090,830,830,760,1300] if left else [1300,1300,850,1300,1080,1300,1090,1300,830,830,760,1300,1300])[index])
func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w
	w.set_physics_process(false);w.player.set_physics_process(false)
	var endpoints=[];var rooms=[]
	for index in 21:
		w.build_room(index)
		for enemy in w.enemies: enemy.set_physics_process(false)
		var exposed=[];var floor_y=w.room_size(index).y-140
		for rect in w.platforms:
			if rect.position.x>=0 and rect.size.y==40 and rect.position.y<floor_y: exposed.append([rect.position.x,rect.position.y,rect.size.x,rect.size.y])
		var cell=w.ROOM_MAP_COORDS[index]
		rooms.append({"id":index,"name":w.ROOM_NAMES[index],"map_cell":[cell.x,cell.y,cell.z],"unsupported_candidates":exposed})
		var present=[]
		if index>0 and index<13: present.append({"target":index-1,"at":chain_at(index,true),"arrival":chain_at(index-1,false)+Vector2(-140,-2),"need":"original forward/reverse chain policy"})
		if index<12: present.append({"target":index+1,"at":chain_at(index,false),"arrival":chain_at(index+1,true)+Vector2(110,-2),"need":"original forward/reverse chain policy"})
		present.append_array(w.expansion.portals(index))
		var returns={3:{"target":9,"at":Vector2(2250,790),"arrival":Vector2(480,618),"need":"terrace_return_relay"},9:{"target":3,"at":Vector2(160,620),"arrival":Vector2(2100,788),"need":"terrace_return_relay"},8:{"target":12,"at":Vector2(1470,740),"arrival":Vector2(430,828),"need":"skyworks_restored"},12:{"target":8,"at":Vector2(220,830),"arrival":Vector2(1590,738),"need":"skyworks_restored"}}
		if index in returns: present.append(returns[index])
		for p in present:
			var policy=w.embodied_transitions.policy(w,index,p.target)
			endpoints.append({"source":index,"target":p.target,"at":[p.at.x,p.at.y],"arrival":[p.arrival.x,p.arrival.y],"requirement":p.need,"presentation":policy,"depth_demo":("%d:%d"%[index,p.target]) in w.embodied_transitions.DEPTH_DEMO})
	var output="res://docs/tr03/ENDPOINT_MATRIX.json"
	var file=FileAccess.open(output,FileAccess.WRITE);file.store_string(JSON.stringify({"rooms":rooms,"endpoints":endpoints,"source":"TR-02 e9a2d1a + TR-03 explicit presentation metadata"},"  "));file.close()
	print("ENDPOINT AUDIT: ",endpoints.size()," directed endpoints / ",rooms.size()," rooms")
	w.queue_free();current_scene=null;await process_frame;quit(0 if endpoints.size()==58 else 1)
