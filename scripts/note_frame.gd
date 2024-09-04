extends Node2D

const globals = preload("res://scripts/globals.gd")
var Keys = globals.Keys
var key_info = globals.key_info
const CUSTOM_WHITE = globals.CUSTOM_WHITE

var radius = 0
var coverage = 1.0
var width = 0
var cursor_color = CUSTOM_WHITE
var critical_highlight_color = key_info[Keys.CRITICAL]["color"]

const Metronome = preload("res://nodes/metronome.tscn")
var beat_lines = []
@export var beat_line = true
@export var speed = 1.0
var metronome


func resize():
	radius = get_window().size.y / 3.0
	width = radius / 20.0
	queue_redraw()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize()
	
	get_tree().get_root().size_changed.connect(resize)
		
	critical_highlight_color.a = 0.0
	
	metronome = Metronome.instantiate()
	add_child(metronome)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
		
	cursor_color.r = lerp(cursor_color.r, CUSTOM_WHITE.r, 0.05)
	cursor_color.g = lerp(cursor_color.g, CUSTOM_WHITE.g, 0.05)
	cursor_color.b = lerp(cursor_color.b, CUSTOM_WHITE.b, 0.05)
	critical_highlight_color.a = lerp(critical_highlight_color.a, 0.0, 0.05)
	
	# beat lines
	if beat_line:
		var now = Time.get_ticks_usec() / 1_000_000.0
		if metronome.need:
			beat_lines.append(now + 1.0 / speed)
			metronome.need = false

		var index_offset = 0
		for i in range(beat_lines.size()):
			i -= index_offset
			var beat_line = beat_lines[i]
			if beat_line + 1.0 < now:
				beat_lines.pop_at(i)
				index_offset += 1
	
	queue_redraw()


func _draw():
	# note frame
	draw_circle(Vector2.ZERO, radius, CUSTOM_WHITE, false, 2, true)
	
	# center
	draw_circle(Vector2.ZERO, 20, CUSTOM_WHITE, false, 1, true)
	
	# beat lines
	var now = Time.get_ticks_usec() / 1_000_000.0
	for beat_line in beat_lines:
		var process = 1.0 - (beat_line - now) / speed
		var r = pow(process, 4) * radius
		draw_circle(Vector2.ZERO, r, Color(1.0, 1.0, 1.0, 0.1), false, 1, true)
		
	# cursor
	draw_arc(
		Vector2.ZERO, radius,
		-coverage/2, coverage/2, coverage * 50, cursor_color, width,
		true
	)
	draw_circle(radius * Vector2(cos(-coverage/2.0), sin(-coverage/2.0)), width / 2.0, cursor_color, true, -1, true)
	draw_circle(radius * Vector2(cos(coverage/2.0), sin(coverage/2.0)), width / 2.0, cursor_color, true, -1, true)
	
	# critical highlight
	draw_circle(Vector2.ZERO, radius, critical_highlight_color, false, width, true)
