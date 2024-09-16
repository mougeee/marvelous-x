extends Node2D

@export var target_coverage = PI / 2
@export var thumbnail: Texture2D
@export var target_rotation = 0.0
@export var label = ""

var background_color = Globals.CUSTOM_WHITE
var original_radius = 0.0
var radius = original_radius
var coverage = target_coverage
var pressing = false

signal pressed


func is_hover() -> bool:
	var mouse_position = get_local_mouse_position()
	var distance = mouse_position.length()
	var theta = atan2(mouse_position.y, mouse_position.x)
	
	return abs(theta) < coverage / 2 and distance <= radius
	
	
func resize() -> void:
	original_radius = get_viewport_rect().size.y / 3
	radius = original_radius


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background_color.a = 0.0
	
	resize()
	get_tree().get_root().size_changed.connect(resize)
	
	$Label.text = label


func _process(delta: float) -> void:
	if is_hover():
		background_color.a = lerp(background_color.a, 0.2, 6.0 * delta)
		radius = lerp(radius, original_radius * 1.1, 6.0 * delta)
	else:
		background_color.a = lerp(background_color.a, 0.0, 6.0 * delta)
		radius = lerp(radius, original_radius, 6.0 * delta)
	queue_redraw()
	
	if is_hover() and visible and (
		Input.is_action_just_pressed('Click')
	):
		pressing = true
	
	if is_hover() and visible and (
		pressing and Input.is_action_just_released('Click')
		or Input.is_action_just_pressed("LeftPress")
		or Input.is_action_just_pressed("RightPress")
	):
		pressed.emit()
	
	if not is_hover():
		pressing = false
	
	rotation = lerp_angle(rotation, target_rotation, 18.0 * delta)
	coverage = lerp(coverage, target_coverage, 18.0 * delta)


func _draw():
	$Label.position.x = radius - $Label.get_rect().size.x - 50.0
	$Label.position.y = -$Label.get_rect().size.y / 2
	draw_line(Vector2.ZERO, Vector2(radius, 0.0).rotated(-coverage/2), Globals.CUSTOM_WHITE, 2, true)
	draw_line(Vector2.ZERO, Vector2(radius, 0.0).rotated(coverage/2), Globals.CUSTOM_WHITE, 2, true)
	draw_arc(Vector2.ZERO, radius, -coverage/2, coverage/2, coverage*50.0, Globals.CUSTOM_WHITE, 2, true)
	
	#if thumbnail:
		#draw_texture(thumbnail, Vector2.ZERO)
