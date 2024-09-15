extends Node2D

@export var selected_index = 0

var children = []
var menus = {}

signal selected


func change_selected_index_offset(offset: int, invoke: bool = true):
	if invoke and offset == 0:
		selected.emit(children[selected_index].get_name(), selected_index)
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
		
		elif 0 <= new_index and new_index < children.size():
			var menu = children[new_index]
			menu.target_rotation = get_target_rotation(new_key)
			menu.rotation = menu.target_rotation
			menu.target_coverage = get_target_coverage(new_key)
			menu.coverage = 0.0
			menu.pressed.connect(change_selected_index_offset.bind(new_key))
			new_menus[new_key] = menu
	
	menus = new_menus
	selected_index += offset



func update_children():
	children = get_children()
	change_selected_index_offset(0, false)



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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
