@tool
extends RefCounted
## Programmatic tests of the actual editor plugin and native scene undo history.
var passes = 0
var failures = 0
func check(ok,label):
	print("PASS: " if ok else "FAIL: ",label)
	if ok: passes += 1
	else: failures += 1
func run(plugin):
	var tree = plugin.get_tree()
	for tick in 60: await tree.process_frame
	var path = "res://build/room-creator-editor-qa.tscn"
	if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	plugin.save_template(path)
	for tick in 30: await tree.process_frame
	var root = EditorInterface.get_edited_scene_root()
	check(root != null and root.get_meta("room_id",-1) == 21,"Editor creates and opens reusable template")
	if root == null: tree.quit(2);return
	var geometry = root.get_node("Geometry")
	var count = geometry.get_child_count()
	plugin.add_rectangle()
	check(geometry.get_child_count() == count+1,"Plugin inserts rectangle in edited scene")
	var surface = geometry.get_child(count).get_node("Surface")
	check(surface.owner == root,"Editor insertion persists node ownership")
	var manager = plugin.get_undo_redo()
	var history = manager.get_history_undo_redo(manager.get_object_history_id(root))
	history.undo()
	check(geometry.get_child_count() == count,"Native scene undo removes inserted rectangle")
	history.redo()
	check(geometry.get_child_count() == count+1 and surface.owner == root,"Native redo restores rectangle and ownership")
	EditorInterface.get_selection().clear();EditorInterface.get_selection().add_node(surface.get_parent())
	plugin.duplicate_selected()
	var duplicate = geometry.get_child(count+1).get_node("Surface")
	check(duplicate.shape != surface.shape,"Plugin duplication makes shape resources unique")
	manager.create_action("Test native platform edit",UndoRedo.MERGE_DISABLE,root)
	manager.add_do_property(surface,"position",Vector2(630,780));manager.add_undo_property(surface,"position",surface.position)
	manager.add_do_property(surface.shape,"size",Vector2(420,48));manager.add_undo_property(surface.shape,"size",surface.shape.size)
	manager.commit_action()
	check(surface.position == Vector2(630,780) and surface.shape.size == Vector2(420,48),"Native editor move/resize edits shape")
	history.undo();check(surface.position != Vector2(630,780),"Native editor move undo")
	history.redo();check(surface.position == Vector2(630,780),"Native editor move redo")
	plugin.add_decoration("Background");plugin.add_decoration("Foreground");plugin.add_marker()
	check(root.get_node("Background").get_child_count() == 1 and root.get_node("Foreground").get_child_count() == 1,"Plugin inserts non-solid decoration layers")
	check(root.get_node("Markers").get_child_count() == 1,"Plugin inserts metadata marker")
	check(plugin.save_validate(),"Actual EditorInterface saves validated edited scene")
	var saved = ResourceLoader.load(path,"PackedScene",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
	check(saved.get_node("Geometry").get_child(count).get_node("Surface").position == Vector2(630,780),"Editor-saved platform edit survives cache-bypass reload")
	check(saved.get_node("Markers").get_child_count() == 1,"Editor-saved marker survives reload")
	saved.free()
	print("ROOM CREATOR EDITOR: %d passes / %d failures" % [passes,failures])
	tree.quit(1 if failures else 0)
