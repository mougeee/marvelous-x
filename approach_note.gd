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



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process += speed * delta
	
	width = pow(process, 3) * note_width
	radius = frame_radius * pow(process, 4)
	queue_redraw()
	
	var dt = (process - 1.0) * speed
	if not processed:
		if dt > 0.0:
			coverage = PI
		if abs(dt) < 0.2 and (
			key == Keys.LEFT and Input.is_action_just_pressed("LeftPress")
			or key == Keys.RIGHT and Input.is_action_just_pressed("RightPress")
			or key == Keys.CRITICAL and Input.is_action_just_pressed("CriticalPress")
		):
			processed = true
			print(dt)
		elif dt > 0.2:
			print("MISS")
			processed = true
			
	if dt > 0.2 and radius > (get_window().size/2).length():
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
