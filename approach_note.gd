extends Node2D

const Keys = preload("res://globals.gd").Keys
const color_map = preload("res://globals.gd").color_map

var radius = 0
var coverage = 0.4
var width = 0
var note_width = 0
var process = 0.0
var frame_radius
@export var key = Keys.LEFT
@export var speed = 1.0
var processed = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	note_width = frame.width
	
	if key == Keys.CRITICAL:
		coverage = TAU
	
	position = get_window().size / 2


func is_covered() -> bool:
	var frame = get_parent().get_node("NoteFrame")
	var dr = abs(angle_difference(frame.rotation, rotation))
	var dc = abs(angle_difference(frame.coverage, coverage)) / 2
	return dr <= dc



func _process(delta: float) -> void:
	process += speed * delta
	
	width = pow(process, 3) * note_width
	radius = frame_radius * pow(process, 4)
	queue_redraw()
	
	var dt = (process - 1.0) * speed
	if not processed:
		if abs(dt) <= 0.100 and (
			key == Keys.CRITICAL and Input.is_action_just_pressed("CriticalPress")
			or is_covered() and (
				key == Keys.LEFT and Input.is_action_just_pressed("LeftPress")
				or key == Keys.RIGHT and Input.is_action_just_pressed("RightPress")
			)
		):
			processed = true
			if abs(dt) <= 0.020:
				print('Marvelous ', dt)
			elif abs(dt) <= 0.040:
				print('Splendid ', dt)
			elif abs(dt) <= 0.070:
				print('Great ', dt)
			else:
				print('OK ', dt)
			queue_free()
		elif dt > 0.100:
			print("Miss")
			processed = true
			
	if dt > 0.065 and radius > (get_window().size/2).length():
		queue_free()



func _draw():
	var color = color_map[key]
	
	draw_arc(
		Vector2.ZERO, radius,
		-coverage/2, coverage/2, coverage * 50, color, width*2,
		true
	)
	draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width, color, true, -1, true)
	draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width, color, true, -1, true)
