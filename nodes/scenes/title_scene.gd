extends Node2D

var scene_data = {}
signal scene_changed


func _ready() -> void:
	$Centering/NoteFrame.rotation = scene_data.get("cursor_direction", 0.0)


func close_scene():
	for child in $Centering/MenuList.children:
		child.close()


func _on_menu_list_selected(menu_name: String, _index: int) -> void:
	if menu_name == "MapMenu":
		scene_changed.emit("title", "map", {"cursor_direction": $Centering/NoteFrame.rotation})
		return
	
	if menu_name == "PlayMenu":
		scene_changed.emit("title", "select", {"cursor_direction": $Centering/NoteFrame.rotation})
		return
	
	if menu_name == "OptionMenu":
		scene_changed.emit("title", "option", {"cursor_direction": $Centering/NoteFrame.rotation})
		return
	
	if menu_name == "QuitMenu":
		get_tree().quit()
		return
