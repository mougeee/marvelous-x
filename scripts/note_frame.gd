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

@export var speed = 1.0
const Metronome = preload("res://nodes/metronome.tscn")
var beat_lines = []
@export var beat_line_manual = false
var metronome
@export var beat_line = true


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
	metronome.sound = false
	add_child(metronome)


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
		
	cursor_color.r = lerp(cursor_color.r, CUSTOM_WHITE.r, 0.05)
	cursor_color.g = lerp(cursor_color.g, CUSTOM_WHITE.g, 0.05)
	cursor_color.b = lerp(cursor_color.b, CUSTOM_WHITE.b, 0.05)
	critical_highlight_color.a = lerp(critical_highlight_color.a, 0.0, 0.05)
	
	queue_redraw()
	
	# beat line
	if beat_line:
		if metronome.need:
			beat_lines.append(0.0)
			metronome.need = false
		#
		increase_beat_lines(delta)
		# remove beat lines
		var index_offset = 0
		for i in range(beat_lines.size()):
			i -= index_offset
			if beat_lines[i] >= 2.0:
				beat_lines.pop_at(i)
				index_offset += 1


func increase_beat_lines(delta):
	for i in range(beat_lines.size()):
		beat_lines[i] += delta * speed


func _draw():
	# note frame
	draw_circle(Vector2.ZERO, radius, CUSTOM_WHITE, false, 2, true)
	
	# center
	draw_circle(Vector2.ZERO, 20, CUSTOM_WHITE, false, 1, true)
	
	# beat lines
	var beat_line_color = Color(CUSTOM_WHITE)
	beat_line_color.a = 0.1
	for b in beat_lines:
		var r = radius * pow(b, 4)
		draw_circle(Vector2.ZERO, r, beat_line_color, false, 1, true)
	
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
