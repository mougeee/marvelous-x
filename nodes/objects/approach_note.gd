extends Node2D

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
@export var temporary = false

signal pressed


func to_json(time: float) -> Dictionary:
	#{"y": 0, "t": 8.0, "r": -2.0, "c": 0.0, "k": 2},
	return {
		"y": Globals.note_type_info[Globals.NoteTypes.APPROACH]['code'],
		't': time,
		'r': rotation,
		'c': coverage
	}


func resize() -> void:
	var frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	note_width = frame.width


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	
	resize()
		
	begin_time = Time.get_ticks_usec()


func is_entirely_covered() -> bool:
	var frame = get_parent().get_node("NoteFrame")
	var dr = abs(angle_difference(frame.rotation, rotation))
	var dc = abs(angle_difference(frame.coverage, coverage)) / 2
	return dr <= dc


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
		if abs(dt) <= Globals.judgement_info[Globals.Judgements.MISS]["precision"] and (
			(
				Input.is_action_just_pressed("LeftPress") or Input.is_action_just_pressed("RightPress") or Input.is_action_just_pressed("Click")
			)
		):
			processed = true
			if is_entirely_covered():
				for i in range(Globals.judgement_info.size() - 1):
					if abs(dt) <= Globals.judgement_info[i]["precision"]:
						pressed.emit(i, rotation, false, dt)
						break
			else:
				pressed.emit(Globals.Judgements.OK, rotation, false, dt)
			queue_free()
		elif dt > Globals.judgement_info[Globals.Judgements.MISS]["precision"]:
			pressed.emit(Globals.Judgements.MISS, rotation, false, dt)
			processed = true
	
	if dt > Globals.judgement_info[Globals.Judgements.MISS]["precision"] and radius > (get_window().size/2).length() + width * 2:
		queue_free()



func _draw():
	if radius > 0 and process < 2.0:
		var color = Globals.CUSTOM_WHITE
		
		if temporary:
			color.a = 0.5
		
		draw_arc(
			Vector2.ZERO, radius,
			-coverage/2, coverage/2, coverage * 50, color, width,
			true
		)
		draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width / 2, color, true, -1, true)
		draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width / 2, color, true, -1, true)
