extends Node2D

const Keys = preload("res://globals.gd").Keys
const color_map = preload("res://globals.gd").color_map
const Judgements = preload("res://globals.gd").Judgements
const judgement_info = preload("res://globals.gd").judgement_info

var radius = 0
var coverage = 0.4
var width = 0
var note_width = 0
var process = 0.0
var frame_radius
@export var key = Keys.LEFT
@export var speed = 1.0
var processed = false

signal pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	note_width = frame.width
	
	if key == Keys.CRITICAL:
		coverage = TAU


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
	
	var dt = (process - 1.0) / speed
	if not processed:
		if abs(dt) <= judgement_info[Judgements.MISS][2] and (
			key == Keys.CRITICAL and Input.is_action_just_pressed("CriticalPress")
			or is_covered() and (
				key == Keys.LEFT and Input.is_action_just_pressed("LeftPress")
				or key == Keys.RIGHT and Input.is_action_just_pressed("RightPress")
			)
		):
			processed = true
			for i in range(judgement_info.size() - 1):
				if abs(dt) <= judgement_info[i][2]:
					pressed.emit(i)
					break
			queue_free()
			print(dt)
		elif dt > judgement_info[Judgements.MISS][2]:
			pressed.emit(Judgements.MISS)
			processed = true
	
	if dt > judgement_info[Judgements.MISS][2] and radius > (get_window().size/2).length() + width * 2:
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
