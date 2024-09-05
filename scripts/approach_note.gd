extends Node2D

const Keys = preload("res://scripts/globals.gd").Keys
const key_info = preload("res://scripts/globals.gd").key_info
const Judgements = preload("res://scripts/globals.gd").Judgements
const judgement_info = preload("res://scripts/globals.gd").judgement_info

var radius = 0
var coverage = 0.4
var width = 0
var note_width = 0
var process = 0.0
var frame_radius
@export var key = Keys.LEFT
@export var speed = 1.0
var processed = false
var begin_time
@export var manual = false

signal pressed


func resize() -> void:
	var frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	note_width = frame.width


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	
	resize()
	
	if key == Keys.CRITICAL:
		coverage = TAU
		
	begin_time = Time.get_ticks_usec()


func is_covered() -> bool:
	var frame = get_parent().get_node("NoteFrame")
	var dr = abs(angle_difference(frame.rotation, rotation))
	var dc = abs(angle_difference(frame.coverage, coverage)) / 2
	return dr <= dc


func render():
	width = pow(process, 3) * note_width
	radius = frame_radius * pow(process, 4)
	queue_redraw()


func _process(_delta: float) -> void:
	if not manual:
		process = (Time.get_ticks_usec() - begin_time) / 1_000_000.0 * speed
	
	render()
	
	var dt = (process - 1.0) / speed
	if not processed:
		if abs(dt) <= judgement_info[Judgements.MISS]["precision"] and (
			key == Keys.CRITICAL and Input.is_action_just_pressed("CriticalPress")
			or is_covered() and (
				key == Keys.LEFT and Input.is_action_just_pressed("LeftPress")
				or key == Keys.RIGHT and Input.is_action_just_pressed("RightPress")
			)
		):
			processed = true
			for i in range(judgement_info.size() - 1):
				if abs(dt) <= judgement_info[i]["precision"]:
					pressed.emit(i, rotation, key == Keys.CRITICAL, dt)
					break
			queue_free()
		elif dt > judgement_info[Judgements.MISS]["precision"]:
			pressed.emit(Judgements.MISS, rotation, key == Keys.CRITICAL, dt)
			processed = true
	
	if dt > judgement_info[Judgements.MISS]["precision"] and radius > (get_window().size/2).length() + width * 2:
		queue_free()



func _draw():
	var color = Color(key_info[key]["color"])
	
	if radius > 0 and process < 2.0:
		draw_arc(
			Vector2.ZERO, radius,
			-coverage/2, coverage/2, coverage * 50, color, width,
			true
		)
		draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width / 2, color, true, -1, true)
		draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width / 2, color, true, -1, true)
