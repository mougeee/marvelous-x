extends Node2D

var radius = 600
var coverage = 1.0
var width = 20


func resize():
	radius = get_window().size.y / 3
	queue_redraw()
	
	position = get_window().size / 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize()
	
	get_tree().get_root().size_changed.connect(resize)
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_delta = get_global_mouse_position() - position
	rotation = lerp_angle(rotation, mouse_delta.angle(), 0.5)
	
	if mouse_delta.length() > radius:
		#Input.warp_mouse(position + mouse_delta.normalized() * radius)
		pass



func _draw():
	# note frame
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false, 2, true)
	
	# center
	draw_circle(Vector2.ZERO, 2, Color.WHITE, true, -1, true)
	
	# frame cursor
	draw_arc(
		Vector2.ZERO, radius,
		-coverage/2, coverage/2, coverage * 50, Color.WHITE, width*2,
		true
	)
	draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width, Color.WHITE, true, -1, true)
	draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width, Color.WHITE, true, -1, true)
