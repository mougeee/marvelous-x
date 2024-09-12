extends Node2D

const globals = preload("res://nodes/globals.gd")
const CUSTOM_WHITE = globals.CUSTOM_WHITE

@export var coverage = PI / 2
@export var thumbnail: Texture2D

var background_color = CUSTOM_WHITE
var original_radius = 0.0
var radius = original_radius

signal pressed


func is_hover() -> bool:
	var mouse_position = get_local_mouse_position()
	var distance = mouse_position.length()
	var theta = atan2(mouse_position.y, mouse_position.x)
	
	return abs(theta) < coverage / 2 and distance <= radius
	
	
func resize() -> void:
	original_radius = get_parent().get_node("NoteFrame").radius
	radius = original_radius


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background_color.a = 0.0
	
	resize()
	get_tree().get_root().size_changed.connect(resize)


func _process(_delta: float) -> void:
	if is_hover():
		background_color.a = lerp(background_color.a, 0.2, 0.1)
		radius = lerp(radius, original_radius * 1.1, 0.1)
	else:
		background_color.a = lerp(background_color.a, 0.0, 0.1)
		radius = lerp(radius, original_radius, 0.1)
	queue_redraw()
	
	if is_hover() and Input.is_action_just_released('Click'):
		pressed.emit()


func _draw():
	draw_line(Vector2.ZERO, Vector2(radius, 0.0).rotated(-coverage/2), CUSTOM_WHITE, 2, true)
	draw_line(Vector2.ZERO, Vector2(radius, 0.0).rotated(coverage/2), CUSTOM_WHITE, 2, true)
	draw_arc(Vector2.ZERO, radius, -coverage/2, coverage/2, coverage*50.0, CUSTOM_WHITE, 2, true)
	
	#draw_texture(thumbnail, Vector2.ZERO)
