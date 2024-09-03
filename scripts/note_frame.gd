extends Node2D

var Keys = preload("res://scripts/globals.gd").Keys
var key_info = preload("res://scripts/globals.gd").key_info

var radius = 0
var coverage = 1.0
var width = 0
var cursor_color = Color.WHITE
var critical_highlight_color = key_info[Keys.CRITICAL]["color"]


func resize():
	radius = get_window().size.y / 3
	width = radius / 20
	queue_redraw()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize()
	
	get_tree().get_root().size_changed.connect(resize)
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	critical_highlight_color.a = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_delta = get_global_mouse_position() - get_viewport_rect().size / 2
	rotation = lerp_angle(rotation, mouse_delta.angle(), 0.5)
	
	if mouse_delta.length() > radius:
		#Input.warp_mouse(get_parent().position + mouse_delta.normalized() * radius)
		pass
	
	if Input.is_action_just_pressed("LeftPress"):
		cursor_color = key_info[Keys.LEFT]['color']
	elif Input.is_action_just_pressed("RightPress"):
		cursor_color = key_info[Keys.RIGHT]['color']
	elif Input.is_action_just_pressed("CriticalPress"):
		critical_highlight_color.a = 1.0
		
	cursor_color.r = lerp(cursor_color.r, Color.WHITE.r, 0.05)
	cursor_color.g = lerp(cursor_color.g, Color.WHITE.g, 0.05)
	cursor_color.b = lerp(cursor_color.b, Color.WHITE.b, 0.05)
	critical_highlight_color.a = lerp(critical_highlight_color.a, 0.0, 0.05)
	queue_redraw()


func _draw():
	# note frame
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false, 2, true)
	
	# center
	draw_circle(Vector2.ZERO, 20, Color.WHITE, false, 1, true)
		
	# cursor
	draw_arc(
		Vector2.ZERO, radius,
		-coverage/2, coverage/2, coverage * 50, cursor_color, width,
		true
	)
	draw_circle(radius * Vector2(cos(-coverage/2), sin(-coverage/2)), width / 2, cursor_color, true, -1, true)
	draw_circle(radius * Vector2(cos(coverage/2), sin(coverage/2)), width / 2, cursor_color, true, -1, true)
	
	# critical highlight
	draw_circle(Vector2.ZERO, radius, critical_highlight_color, false, width, true)
