extends Node2D

const Menu = preload("res://nodes/objects/menu.tscn")

var chart_names = []
var chart_data = {}

var scene_data

signal scene_changed


func resize():
	Globals.resize_thumbnail($Centering/PreviewThumbnail, get_viewport_rect().size)


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
	
	if chart_names:
		for chart_name in chart_names:
			var menu = Menu.instantiate()
			menu.label = chart_name
			$Centering/MenuList.add_child(menu)
		$Centering/MenuList.selected_index = randi_range(0, chart_names.size() - 1)
		$Centering/MenuList.update_children()
	
	# resize hander connection
	get_tree().get_root().size_changed.connect(resize)


func _process(delta: float) -> void:
	if $PreviewAudio.get_playback_position() == 0:
		$PreviewAudio.play()


func _on_back_menu_pressed() -> void:
	scene_changed.emit("select", "title")


func _on_menu_list_changed(index: int) -> void:
	if not chart_names:
		return
	
	for i in range(-$Centering/MenuList.left_right_count, $Centering/MenuList.left_right_count + 1):
		if index + i < 0 or index + i >= chart_names.size():
			continue
			
		var chart_name = chart_names[index + i]
		if chart_name in chart_data:
			continue
			
		var chart = Globals.load_chart("user://charts/" + chart_name + "/chart.json")
		chart_data[chart_name] = chart
		chart_data[chart_name]["stream"] = load("user://charts/" + chart_name + "/" + chart.song.path)
		chart_data[chart_name]["thumbnail"] = load("user://charts/" + chart_name + "/" + chart.song.thumbnail)
		
	var chart_name = chart_names[index]
	$Centering/PreviewThumbnail.texture = chart_data[chart_name]["thumbnail"]
	Globals.resize_thumbnail($Centering/PreviewThumbnail, get_viewport_rect().size)
	$PreviewAudio.stream = chart_data[chart_name]["stream"]
	$PreviewAudio.play($PreviewAudio.stream.get_length() * randf() * 0.5)


func _on_menu_list_selected(child_name: String, selected_index: int) -> void:
	scene_changed.emit("select", "playing", {
		'chart': chart_names[$Centering/MenuList.selected_index]
	})
