extends Node2D

signal scene_changed(scene_name)

@export var scene_name: String


func on_menu_game_pressed() -> void:
	scene_changed.emit(scene_name)


func on_menu_map_pressed() -> void:
	get_tree().change_scene_to_file("res://nodes/scenes/map_scene.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Centering/MenuGame.pressed.connect(on_menu_game_pressed)
	$Centering/MenuMap.pressed.connect(on_menu_map_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
