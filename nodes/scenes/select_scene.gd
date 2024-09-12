extends Node2D

const Menu = preload("res://nodes/objects/menu.tscn")

var chart_names = []
var selected_index = 0
var menus = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir = DirAccess.open("res://charts")
	chart_names.clear()
	dir.list_dir_begin()
	while true:
		var filename = dir.get_next()
		
		if filename == "":
			break
		
		chart_names.append(filename)
	dir.list_dir_end()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not menus:
		for i in range(-5, 5+1):
			var index = selected_index + i
			if index < 0 or index >= chart_names.size():
				continue
			
			var chart_name = chart_names[index]
			var menu = Menu.instantiate()
			menu.angle = PI/2 + i / 2
			menu.coverage = 1.0
			menus[index] = menu
			$Centering.add_child(menu)
		
		print("update, ", menus)


func _on_back_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://nodes/scenes/title_scene.tscn")
