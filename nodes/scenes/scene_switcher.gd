extends Node2D


@onready var current_scene = $TitleScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_scene.scene_changed.connect(handle_scene_changed)
	
	DirAccess.make_dir_absolute("user://charts")


func handle_scene_changed(current_scene_name: String, next_scene_name: String, data: Dictionary = {}):
	var next_scene = load("res://nodes/scenes/" + next_scene_name + "_scene.tscn").instantiate()
	next_scene.scene_changed.connect(handle_scene_changed)
	next_scene.scene_data = data
	add_child(next_scene)
	current_scene.queue_free()
	current_scene = next_scene
