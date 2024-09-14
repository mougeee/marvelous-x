extends Node2D

const Menu = preload("res://nodes/objects/menu.tscn")

var chart_names = []
var selected_index = 0
var menus = {}

var scene_data

signal scene_changed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Centering/PreviewThumbnail.modulate.a = 0.1
	
	# load chart names
	var dir = DirAccess.open("user://charts")
	chart_names.clear()
	dir.list_dir_begin()
	while true:
		var filename = dir.get_next()
		
		if filename == "":
			break
		
		chart_names.append(filename)
	dir.list_dir_end()
	
	selected_index = randi_range(0, chart_names.size() - 1)
	
	# draw chart menus
	for i in range(-5, 5+1):
		var index = selected_index + i
		if index < 0 or index >= chart_names.size():
			continue
		
		var chart_name = chart_names[index]
		
		var menu = Menu.instantiate()
		menu.target_rotation = get_target_rotation(i)
		menu.rotation = menu.target_rotation
		menu.target_coverage = get_target_coverage(i)
		menu.pressed.connect(change_selected_index_offset.bind(i))
		#menu.thumbnail = load("user://charts/" + chart_name + "/thumbnail.svg")
		menu.label = chart_name
		menus[i] = menu
		$Centering.add_child(menu)
	
	if chart_names:
		var chart_name = chart_names[selected_index]
		var chart = Globals.load_chart("user://charts/" + chart_name + "/chart.json")
		$PreviewAudio.stream = load("user://charts/" + chart_name + "/" + chart.song.path)
		$PreviewAudio.play($PreviewAudio.stream.get_length() * randf() * 0.5)
		$Centering/PreviewThumbnail.texture = load("user://charts/" + chart_name + "/" + chart.song.thumbnail)


func _process(delta: float) -> void:
	if $PreviewAudio.get_playback_position() == 0:
		$PreviewAudio.play()


func change_selected_index_offset(offset: int):
	if offset == 0:
		scene_changed.emit("select", "playing", {
			'chart': chart_names[selected_index]
		})
		return
	
	var new_menus = {}
	
	for key in menus:
		var new_key = key - offset
		if abs(new_key) > 5:
			menus[key].queue_free()
			menus.erase(key)
			continue
	
	for i in range(-5, 6):
		var new_index = selected_index + offset + i
		var key = offset + i
		var new_key = key - offset
		
		if key in menus:
			menus[key].pressed.disconnect(change_selected_index_offset.bind(key))
			menus[key].pressed.connect(change_selected_index_offset.bind(new_key))
			menus[key].target_rotation = get_target_rotation(new_key)
			menus[key].target_coverage = get_target_coverage(new_key)
			new_menus[new_key] = menus[key]
		
		elif 0 <= new_index and new_index < chart_names.size():
			var chart_name = chart_names[new_index]
			var menu = Menu.instantiate()
			menu.target_rotation = get_target_rotation(new_key)
			menu.rotation = menu.target_rotation
			menu.target_coverage = get_target_coverage(new_key)
			menu.coverage = 0.0
			menu.label = chart_name
			menu.pressed.connect(change_selected_index_offset.bind(new_key))
			new_menus[new_key] = menu
			$Centering.add_child(menu)
	
	menus = new_menus
	selected_index += offset
	
	var chart_name = chart_names[selected_index]
	var chart = Globals.load_chart("user://charts/" + chart_name + "/chart.json")
	$PreviewAudio.stream = load("user://charts/" + chart_name + "/" + chart.song.path)
	$PreviewAudio.play($PreviewAudio.stream.get_length() * randf())
	$Centering/PreviewThumbnail.texture = load("user://charts/" + chart_name + "/" + chart.song.thumbnail)


func get_target_coverage(index: int) -> float:
	var result = pow(2.0, 1 - abs(index))
	return result


func get_target_rotation(index: int) -> float:
	if index == 0:
		return PI/2
	
	var offset = -1.0
	for i in range(abs(index)):
		offset += pow(0.5, abs(i) - 1)
	offset += pow(0.5, abs(index))
	
	var negative = 1 if index < 0 else -1
	return PI/2 + offset * negative


func _on_back_menu_pressed() -> void:
	scene_changed.emit("select", "title")
