extends Node2D

const globals = preload("res://nodes/globals.gd")
const Keys = globals.Keys
const key_info = globals.key_info
const Judgements = globals.Judgements
const judgement_info = globals.judgement_info
const NoteTypes = globals.NoteTypes
const note_type_info = globals.note_type_info

var radius = 0
var coverage = 0.4
var width = 0
var note_width = 0
var process = 0.0
var frame_radius
@export var speed = 1.0
var processed = false
var begin_time
@export var manual = false

signal passed


func resize(frame = null) -> void:
	if frame == null:
		frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	note_width = frame.width


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	
	resize()
		
	begin_time = Time.get_ticks_usec()


func is_kinda_covered() -> bool:
	var frame = get_parent().get_node("NoteFrame")
	var dr = abs(angle_difference(frame.rotation, rotation))
	var dc = abs(frame.coverage + coverage) / 2
	return dr <= dc


func is_well_covered() -> bool:
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
	
	if process >= 1.0 and not processed:
		if is_well_covered():
			passed.emit(Judgements.MISS, rotation, false, 0.0)
		elif is_kinda_covered():
			passed.emit(Judgements.OK, rotation, false, 0.0)
		else:
			passed.emit(Judgements.MARVELOUS, rotation, false, 0.0)
		processed = true
	
	render()



func _draw():
	var color = note_type_info[NoteTypes.TRAP]['color']
	
	if radius > 0 and process < 2.0:
		draw_arc(
			Vector2.ZERO, radius,
			-coverage/2, coverage/2, coverage * 50, color, width,
			true
		)
		draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width / 2, color, true, -1, true)
		draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width / 2, color, true, -1, true)
