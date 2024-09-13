extends Node2D

const globals = preload("res://nodes/globals.gd")
var Keys = globals.Keys
var key_info = globals.key_info
const CUSTOM_WHITE = globals.CUSTOM_WHITE
const CUSTOM_YELLOW = globals.CUSTOM_YELLOW

var radius = 0
var coverage = 1.0
var width = 0
var cursor_color = CUSTOM_WHITE

var target_coverage = 1.0
@export var speed = 1.0
const Metronome = preload("res://nodes/utils/metronome.tscn")
var beat_lines = []
@export var beat_line_manual = false
var metronome
@export var beat_line = true

var cursor_path = []


func resize():
	radius = get_window().size.y / 3.0
	width = radius / 20.0
	queue_redraw()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resize()
	
	get_tree().get_root().size_changed.connect(resize)
	
	metronome = Metronome.instantiate()
	metronome.sound = false
	add_child(metronome)
	
	redraw_path()
	
	
var mouse_radius = 100.0
@export var mouse_lock = false
var cursor_highlight_color = Color(CUSTOM_WHITE.r, CUSTOM_WHITE.g, CUSTOM_WHITE.b, 0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_delta = get_global_mouse_position() - get_viewport_rect().size / 2
	rotation = lerp_angle(rotation, mouse_delta.angle(), 0.5)
	
	if mouse_lock and mouse_delta.length() > mouse_radius:
		Input.warp_mouse(get_parent().position + mouse_delta.normalized() * mouse_radius)
	
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
		queue_redraw()
	
	# change coverage
	if abs(coverage - target_coverage) >= 0.01:
		coverage = lerp(coverage, target_coverage, 0.1)
		redraw_path()
		
	# highlight cursor by pressing keys
	if Input.is_action_pressed("LeftPress") or Input.is_action_pressed("RightPress"):
		cursor_highlight_color = CUSTOM_WHITE
	elif Input.is_action_pressed("CriticalPress"):
		cursor_highlight_color = CUSTOM_YELLOW
	else:
		cursor_highlight_color.r = lerp(cursor_highlight_color.r, CUSTOM_WHITE.r, 0.1)
		cursor_highlight_color.g = lerp(cursor_highlight_color.g, CUSTOM_WHITE.g, 0.1)
		cursor_highlight_color.b = lerp(cursor_highlight_color.b, CUSTOM_WHITE.b, 0.1)
		cursor_highlight_color.a = lerp(cursor_highlight_color.a, 0.0, 0.1)
	queue_redraw()


func redraw_path():
	cursor_path.clear()
	
	var mid_count = int(coverage * 50)
	
	# outer arc
	for i in range(mid_count + 1):
		var angle = lerp(-coverage / 2, coverage / 2, float(i) / mid_count)
		var vector = Vector2(radius + width/2, 0).rotated(angle)
		cursor_path.append(vector)
	
	# right semicircle
	for i in range(11):
		var vector = Vector2(radius, 0).rotated(coverage / 2)
		vector += Vector2(width/2, 0).rotated(coverage/2 + lerp(0.0, PI, i / 10.0))
		cursor_path.append(vector)
			
	# inner arc
	for i in range(mid_count + 1):
		var angle = lerp(coverage / 2, -coverage / 2, float(i) / mid_count)
		var vector = Vector2(radius - width/2, 0).rotated(angle)
		cursor_path.append(vector)
		
	# left semicircle
	for i in range(11):
		var vector = Vector2(radius, 0).rotated(-coverage / 2)
		vector += Vector2(width/2, 0).rotated(-coverage/2 + lerp(PI, TAU, i / 10.0))
		cursor_path.append(vector)
	
	queue_redraw()


func increase_beat_lines(delta: float):
	for i in range(beat_lines.size()):
		beat_lines[i] += delta * speed


func set_coverage(c: float) -> void:
	target_coverage = c


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
	draw_colored_polygon(cursor_path, cursor_highlight_color, PackedVector2Array())
	var line_color = Color(cursor_highlight_color)
	line_color.a = 1.0
	draw_polyline(cursor_path, line_color, 1, true)
