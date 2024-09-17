extends Node2D

var scene_data

signal scene_changed


func _on_back_menu_pressed() -> void:
	scene_changed.emit("option", "title")


func _on_menu_list_selected(child_name: String, selected_index: int) -> void:
	if child_name == "OffsetMenu":
		scene_changed.emit("option", "offset")
