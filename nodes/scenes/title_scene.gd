extends Node2D

signal scene_changed


func on_menu_game_pressed() -> void:
	scene_changed.emit("title", "select")


func on_menu_map_pressed() -> void:
	scene_changed.emit("title", "map")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Centering/MenuGame.pressed.connect(on_menu_game_pressed)
	$Centering/MenuMap.pressed.connect(on_menu_map_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
