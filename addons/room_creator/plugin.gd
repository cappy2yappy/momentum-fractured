@tool
extends EditorPlugin
const Factory = preload("res://tools/ld_tools_02/layout_factory.gd")
const Contract = preload("res://tools/ld_tools_02/layout_contract.gd")
var dock: VBoxContainer
var template: OptionButton
var identity: SpinBox
var marker_kind: OptionButton
var status: Label
var save_dialog: EditorFileDialog
var editor_qa: RefCounted

func _enter_tree():
	dock = VBoxContainer.new();dock.name = "Room Creator"
	var title = Label.new();title.text = "KAZE / Room Creator 2.0";dock.add_child(title)
	button("Open editable R18",func(): EditorInterface.open_scene_from_path("res://tools/ld_tools_02/r18_editable.tscn"))
	template = OptionButton.new()
	for label in Factory.TEMPLATES: template.add_item(label)
	dock.add_child(template)
	var id_label = Label.new();id_label.text = "New room ID (unregistered IDs start at 21)";dock.add_child(id_label)
	identity = SpinBox.new();identity.min_value = 0;identity.max_value = 99999;identity.value = 21;dock.add_child(identity)
	button("Create template…",create_template)
	button("Add rectangle",add_rectangle)
	button("Duplicate selected (unique shapes)",duplicate_selected)
	button("Add background decoration",func(): add_decoration("Background"))
	button("Add foreground decoration",func(): add_decoration("Foreground"))
	marker_kind = OptionButton.new()
	for kind in ["Entrance","Exit","Pickup","Checkpoint","Hazard"]: marker_kind.add_item(kind)
	dock.add_child(marker_kind)
	button("Add metadata marker",add_marker)
	button("Save + validate",save_validate)
	button("Save + play with Kaze",play_preview)
	var help = Label.new();help.text = "Use native 2D handles, Inspector, snap,\nUndo/Redo, Delete and Scene > Save As.\nMarkers have no gameplay behavior.\nClose preview window to return to editing.";dock.add_child(help)
	status = Label.new();status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;dock.add_child(status)
	save_dialog = EditorFileDialog.new();save_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	save_dialog.access = EditorFileDialog.ACCESS_RESOURCES;save_dialog.add_filter("*.tscn", "Room layout")
	save_dialog.file_selected.connect(save_template);dock.add_child(save_dialog)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL,dock)
	if "--room-creator-editor-qa" in OS.get_cmdline_user_args():
		editor_qa = load("res://tools/ld_tools_02/editor_qa.gd").new()
		editor_qa.call_deferred("run",self)

func _exit_tree():
	remove_control_from_docks(dock);dock.queue_free()

func button(label: String, action: Callable):
	var control = Button.new();control.text = label;control.pressed.connect(action);dock.add_child(control)

func layout_root() -> Node2D:
	var node = EditorInterface.get_edited_scene_root()
	if not node is Node2D or not node.has_meta("format_version"):
		status.text = "Open a room layout scene first.";return null
	return node

func create_template():
	save_dialog.current_path = "res://tools/ld_tools_02/room_%d.tscn" % int(identity.value)
	save_dialog.popup_centered_ratio(0.6)

func save_template(path: String):
	if FileAccess.file_exists(path):
		status.text = "Choose a new filename. Templates never overwrite an existing layout.";return
	var node = Factory.create(int(identity.value),Factory.TEMPLATES[template.get_item_text(template.selected)])
	var packed = PackedScene.new();var result = packed.pack(node)
	if result == OK: result = ResourceSaver.save(packed,path)
	node.free()
	if result != OK: status.text = "Could not save template: %s" % error_string(result);return
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.open_scene_from_path(path)
	status.text = "Created %s. This room is not registered in the game." % path

func insert(parent: Node, child: Node, root: Node, label: String):
	var undo = get_undo_redo()
	undo.create_action(label,UndoRedo.MERGE_DISABLE,root)
	undo.add_do_method(parent,"add_child",child,true)
	undo.add_do_method(Factory,"own",child,root)
	undo.add_undo_method(parent,"remove_child",child)
	undo.add_do_reference(child)
	undo.commit_action()
	EditorInterface.get_selection().clear();EditorInterface.get_selection().add_node(child)

func add_rectangle():
	var root = layout_root()
	if root == null: return
	var body = Factory.rectangle("Platform",Rect2(400,800,320,40))
	insert(root.get_node("Geometry"),body,root,"Add room rectangle")
	status.text = "Select Surface to move/resize; set Shape > Size and One Way Collision in Inspector."

func duplicate_selected():
	var root = layout_root()
	if root == null: return
	var selected = EditorInterface.get_selection().get_selected_nodes()
	if selected.size() != 1 or selected[0] == root or not root.is_ancestor_of(selected[0]):
		status.text = "Select one geometry body, decoration or marker.";return
	var source = selected[0]
	if source is CollisionShape2D: source = source.get_parent()
	if source.get_parent() == root:
		status.text = "Select a body or element inside a branch, not the whole branch.";return
	var copy = source.duplicate()
	for surface in copy.find_children("*","CollisionShape2D",true,false):
		if surface.shape: surface.shape = surface.shape.duplicate();surface.shape.resource_local_to_scene = true
	if copy is Node2D: copy.position += Vector2(40,-40)
	insert(source.get_parent(),copy,root,"Duplicate room element with unique shapes")

func add_decoration(branch: String):
	var root = layout_root()
	if root == null: return
	var prop = Polygon2D.new();prop.name = "Decoration";prop.position = Vector2(600,900)
	prop.polygon = PackedVector2Array([Vector2(-80,-120),Vector2(80,-120),Vector2(80,120),Vector2(-80,120)])
	prop.color = Color("42585f80")
	insert(root.get_node(branch),prop,root,"Add non-solid decoration")

func add_marker():
	var root = layout_root()
	if root == null: return
	var node = Factory.marker(marker_kind.get_item_text(marker_kind.selected));node.position = Vector2(400,800)
	insert(root.get_node("Markers"),node,root,"Add metadata marker")

func save_validate() -> bool:
	var node = layout_root()
	if node == null: return false
	var result = Contract.read(node)
	if not result.errors.is_empty(): status.text = "Validation failed: " + "; ".join(result.errors);return false
	if node.scene_file_path.is_empty(): status.text = "Save the scene with Scene > Save As first.";return false
	var error = EditorInterface.save_scene()
	if error != OK: status.text = "Save failed: " + error_string(error);return false
	status.text = "Saved room %s: %d validated rectangles. Markers remain metadata." % [result.room_id,result.records.size()]
	return true

func play_preview():
	if not save_validate(): return
	var path = EditorInterface.get_edited_scene_root().scene_file_path
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build"))
	var arguments = PackedStringArray(["--path",ProjectSettings.globalize_path("res://"),"--log-file",ProjectSettings.globalize_path("res://build/room-creator-preview.log"),"--script","res://tools/ld_tools_02/play_preview.gd","--","--test","--room-layout="+path])
	var pid = OS.create_instance(arguments)
	status.text = "Playable preview launched. Close its window to return here." if pid > 0 else "Preview launch failed."
