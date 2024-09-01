extends Node2D

var radius = 0
var coverage = 0.4
var width = 0
var process = 0.0
var frame_radius
@export var color = Color.WHITE
@export var speed = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame_radius = get_parent().get_node("NoteFrame").radius
	
	position = get_window().size / 2



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process += speed * delta
	
	width = pow(process, 3) * 20
	radius = frame_radius * pow(process, 4)
	queue_redraw()
	
	if radius > (get_window().size/2).length():
		queue_free()



func _draw():
	draw_arc(
		Vector2.ZERO, radius,
		-coverage/2, coverage/2, coverage * 50, color, width*2,
		true
	)
	draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width, color, true, -1, true)
	draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width, color, true, -1, true)
