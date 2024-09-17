extends Node2D

var scene_data = {}
signal scene_changed


func _ready() -> void:
	$Centering/NoteFrame.rotation = scene_data.get("cursor_direction", 0.0)


func _on_back_menu_pressed() -> void:
	scene_changed.emit("option", "title", {"cursor_direction": $Centering/NoteFrame.rotation})


func _on_menu_list_selected(child_name: String, selected_index: int) -> void:
	if child_name == "OffsetMenu":
		scene_changed.emit("option", "offset", {"cursor_direction": $Centering/NoteFrame.rotation})
