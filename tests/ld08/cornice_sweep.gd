extends "res://tests/ld08/traversal.gd"
## Adversarial timing sweep: wall-chain to the actual soffit, dash inward, try to round its end.
func attempt(index, side, jump_at, reverse_at):
	var start=Vector2(314.6,438) if index==13 and side<0 else Vector2(1785.4,558 if index==13 else 1298)
	if index==17 and side<0: start=Vector2(14.6,1898)
	await place(index,start)
	var toward=KEY_A if side<0 else KEY_D
	var away=KEY_D if side<0 else KEY_A
	key(toward,true)
	var phase=-1;var nextjump=0;var release=0;var escaped=false;var miny=9999.0;var apex=Vector2.ZERO
	for t in 2200:
		if phase<0:
			if (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t>=nextjump:
				key(KEY_SPACE,true);release=t+25;nextjump=t+30
			if held_keys.get(KEY_SPACE,false) and t>=release:key(KEY_SPACE,false)
			if w.player.is_on_ceiling():
				phase=t;key(toward,false);key(away,true);key(KEY_SPACE,false)
		else:
			var n=t-phase
			if n==2:key(KEY_SHIFT,true)
			if n==3:key(KEY_SHIFT,false)
			if n==jump_at:key(KEY_SPACE,true);release=t+25
			if n==reverse_at:key(away,false);key(toward,true)
			if t>=release:key(KEY_SPACE,false)
			if n>jump_at+26 and (w.player.is_on_wall() or w.player.is_on_floor()) and not held_keys.get(KEY_SPACE,false) and t>=nextjump:
				key(KEY_SPACE,true);release=t+25;nextjump=t+30
		await wait_ticks(1)
		if not still_here(index):break
		if w.player.position.y<miny:miny=w.player.position.y;apex=w.player.position
		if lateral(w.player.position):escaped=true;break
		if phase>=0 and t-phase>800:break
	release_all()
	var r={"room":index,"side":side,"jump_tick":jump_at,"reverse_tick":reverse_at,"apex":[apex.x,apex.y],"escape":escaped}
	samples.append(r)
	check(not escaped,"R%d side%d jump%d reverse%d escaped=%s apex=%s"%[index,side,jump_at,reverse_at,escaped,apex])

func run():
	await process_frame
	w=load("res://scenes/main.tscn").instantiate();root.add_child(w);current_scene=w;freeze();seed_fixture();automation_hud()
	for index in [13,17]:
		for side in [-1,1]:
			for jump_at in [12,20,28,36]:
				for reverse_at in [10,20,30,40]:await attempt(index,side,jump_at,reverse_at)
	var f=FileAccess.open("res://docs/ld08/evidence/cornice_sweep.json",FileAccess.WRITE);f.store_string(JSON.stringify({"checks":checks,"failures":failures,"samples":samples},"  "));f.close()
	w.queue_free();current_scene=null
	for i in 3:await process_frame
	print("LD08 SWEEP: %d checks, %d failure(s)"%[checks,failures]);quit(1 if failures else 0)
