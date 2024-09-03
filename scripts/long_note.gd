extends Node2D

const key_info = preload("res://scripts/globals.gd").key_info

var path
var speed
var key

var frame_radius
var begin_time

signal pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_time = Time.get_ticks_usec()
	
	var frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	#note_width = frame.width


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var begin_process = (Time.get_ticks_usec() - begin_time) / 1_000_000.0 * speed
	
	# process notes
	var last_process = INF
	for p in path:
		p['process'] = begin_process - p['t'] * speed
		p['radius'] = frame_radius * pow(p['process'], 4)
		p['width'] = p['radius'] / 20
		
		p['dt'] = (p['process'] - 1.0) / speed
		
		last_process = min(last_process, p['process'])
	queue_redraw()
	
	# DEBUG
	if last_process > 2.0:
		queue_free()
	

func _draw():
	var color = key_info[key][0]

	for i in range(path.size() - 1):
		var p = path[i]
		var np = path[i+1]
		
		if p.get('process', 0.0) <= 0.0 or np.get('process', 0.0) <= 0.0:
			continue
		
		var points = []
		var divides = 10.0
		for j in range(divides+1):
			var process = lerp(p.get('process', 0), np.get('process', 0), j/divides)
			var radius = frame_radius * pow(process, 4)
			var angle = lerp_angle(p['r'], np['r'], j/divides)
			var coverage = lerp(p['c'], np['c'], j/divides)
			points.append(Vector2(radius, 0.0).rotated(angle))
		draw_polyline(points, color, 2, true)

	for p in path:
		if p.get('process', 0.0) <= 0.0:
			continue
			
		draw_arc(
			Vector2.ZERO, p.get('radius', 0.0),
			-p['c']/2 + p['r'], p['c']/2 + p['r'], p['c'] * 50, color, p.get('width', 2),
			true
		)
		draw_circle(Vector2(p.get('radius', 0.0), 0.0).rotated(p['r'] - p['c']/2), p.get('width', 2) / 2, color, true, -1, true)
		draw_circle(Vector2(p.get('radius', 0.0), 0.0).rotated(p['r'] + p['c']/2), p.get('width', 2) / 2, color, true, -1, true)
