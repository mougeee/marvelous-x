extends Node2D

const Menu = preload("res://nodes/objects/menu.tscn")

var chart_names = []
var selected_index = 0
var menus = {}

var scene_data

signal scene_changed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dir = DirAccess.open("charts")
	chart_names.clear()
	dir.list_dir_begin()
	while true:
		var filename = dir.get_next()
		
		if filename == "":
			break
		
		chart_names.append(filename)
	dir.list_dir_end()
	
	for i in range(-5, 5+1):
		var index = selected_index + i
		if index < 0 or index >= chart_names.size():
			continue
		
		var chart_name = chart_names[index]
		var menu = Menu.instantiate()
		menu.rotation = PI / 2.0 - i / 2.0
		menu.coverage = 1.0 / 2.0
		menu.pressed.connect(change_selected_index_offset.bind(i))
		menus[i] = menu
		$Centering.add_child(menu)


func change_selected_index_offset(offset: int):
	if offset == 0:
		scene_changed.emit("select", "playing", {
			'chart': 'charts/' + chart_names[selected_index] + '/chart.json'
		})
		return
	
	var new_menus = {}
	for key in menus:
		var new_key = key - offset
		if abs(new_key) > 5:
			menus[key].queue_free()
			continue
		menus[key].pressed.disconnect(change_selected_index_offset.bind(key))
		menus[key].pressed.connect(change_selected_index_offset.bind(new_key))
		menus[key].rotation = PI / 2.0 - new_key / 2.0
		new_menus[new_key] = menus[key]
	menus = new_menus
	selected_index += offset


func _on_back_menu_pressed() -> void:
	scene_changed.emit("select", "title")
