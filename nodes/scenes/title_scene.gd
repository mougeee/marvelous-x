extends Node2D

var scene_data

signal scene_changed


func _on_menu_list_selected(menu_name: String, _index: int) -> void:
	if menu_name == "MapMenu":
		scene_changed.emit("title", "map")
		return
	
	if menu_name == "PlayMenu":
		scene_changed.emit("title", "select")
		return
	
	if menu_name == "QuitMenu":
		get_tree().quit()
		return
