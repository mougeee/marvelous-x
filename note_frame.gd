extends Node2D

var radius = 600
var coverage = 1.0
var width = 20
var press_highlight = Color.TRANSPARENT


func resize():
	radius = get_window().size.y / 3
	width = radius / 20
	queue_redraw()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize()
	
	get_tree().get_root().size_changed.connect(resize)
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_delta = get_global_mouse_position() - get_parent().position
	rotation = lerp_angle(rotation, mouse_delta.angle(), 0.5)
	
	if mouse_delta.length() > radius:
		#Input.warp_mouse(get_parent().position + mouse_delta.normalized() * radius)
		pass
	
	if Input.is_action_just_pressed("LeftPress"):
		press_highlight = Color.RED
	elif Input.is_action_just_pressed("RightPress"):
		press_highlight = Color.BLUE
	elif Input.is_action_just_pressed("CriticalPress"):
		press_highlight = Color.YELLOW
		
	press_highlight.a = max(0.0, press_highlight.a - delta * 2)
	queue_redraw()


func _draw():
	# note frame
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false, 2, true)
	
	# center
	draw_circle(Vector2.ZERO, 20, Color.WHITE, false, 1, true)
	
	# frame cursor
	draw_arc(
		Vector2.ZERO, radius,
		-coverage/2, coverage/2, coverage * 50, Color.WHITE, width,
		true
	)
	draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width / 2, Color.WHITE, true, -1, true)
	draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width / 2, Color.WHITE, true, -1, true)
	
	# press highlight
	draw_arc(
		Vector2.ZERO, radius,
		-coverage/2, coverage/2, coverage * 50, press_highlight, width,
		true
	)
	draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width / 2, press_highlight, true, -1, true)
	draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width / 2, press_highlight, true, -1, true)
