extends Node2D

const Keys = preload("res://scripts/globals.gd").Keys
const key_info = preload("res://scripts/globals.gd").key_info
const Judgements = preload("res://scripts/globals.gd").Judgements
const judgement_info = preload("res://scripts/globals.gd").judgement_info

var path
var speed
var key

var frame_radius
var begin_time
var last_missed = false

signal pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_time = Time.get_ticks_usec()
	
	var frame = get_parent().get_node("NoteFrame")
	frame_radius = frame.radius
	#note_width = frame.width
	
	
func is_covered(index: int) -> bool:
	var frame = get_parent().get_node("NoteFrame")
	var dr = abs(angle_difference(frame.rotation, path[index]['r']))
	var dc = abs(angle_difference(frame.coverage, path[index]['c'])) / 2
	return dr <= dc



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var begin_process = (Time.get_ticks_usec() - begin_time) / 1_000_000.0 * speed
	
	# process notes
	var last_process = INF
	for i in range(path.size()):
		var p = path[i]
		
		p['process'] = begin_process - p['t'] * speed
		p['radius'] = frame_radius * pow(p['process'], 4)
		p['width'] = p['radius'] / 20
		
		p['dt'] = (p['process'] - 1.0) / speed
		p['processed'] = p.get('processed', false)
		p['visible'] = p.get('visible', true)
		
		if not p['processed'] and (i == 0 or i == path.size() - 1):
			var is_first_keypressed = (
				key == Keys.LEFT and Input.is_action_just_pressed("LeftPress")
				or key == Keys.RIGHT and Input.is_action_just_pressed("RightPress")
			)
			var is_last_keyreleased = (
				key == Keys.LEFT and Input.is_action_just_released("LeftPress")
				or key == Keys.RIGHT and Input.is_action_just_released("RightPress")
			)
			
			if (
				abs(p['dt']) <= judgement_info[Judgements.MISS]["precision"]
				and is_covered(i)
				and (i == 0 and is_first_keypressed or i == path.size() - 1 and is_last_keyreleased)
				and not last_missed
			):
				p['processed'] = true
				for j in range(judgement_info.size() - 1):
					if abs(p['dt']) <= judgement_info[j]["precision"]:
						pressed.emit(j, p['r'], false, p['dt'])
						p['visible'] = false
						break
			if p['dt'] > judgement_info[Judgements.MISS]["precision"] and (i == 0 or i == path.size() - 1 and not last_missed):
				p['processed'] = true
				p['visible'] = false
				pressed.emit(Judgements.MISS, p['r'], false, p['dt'])
		
		elif not p['processed'] and not (i == 0 or i == path.size() - 1):
			var is_keypressing = (
				key == Keys.LEFT and Input.is_action_pressed("LeftPress")
				or key == Keys.RIGHT and Input.is_action_pressed("RightPress")
			)
			
			if p['dt'] > 0.0:
				p['processed'] = true
				p['visible'] = false
				if (not is_covered(i) or not is_keypressing):
					last_missed = true
					pressed.emit(Judgements.MISS, p['r'], false, p['dt'])
		
		last_process = min(last_process, p['process'])
	queue_redraw()
	
	# DEBUG
	if last_process > 2.0:
		queue_free()
	

func _draw():
	var color = key_info[key]['color']

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
		if not p.get('visible', true):
			continue
		if p.get('process', 0.0) <= 0.0:
			continue
			
		draw_arc(
			Vector2.ZERO, p.get('radius', 0.0),
			-p['c']/2 + p['r'], p['c']/2 + p['r'], p['c'] * 50, color, p.get('width', 2),
			true
		)
		draw_circle(Vector2(p.get('radius', 0.0), 0.0).rotated(p['r'] - p['c']/2), p.get('width', 2) / 2, color, true, -1, true)
		draw_circle(Vector2(p.get('radius', 0.0), 0.0).rotated(p['r'] + p['c']/2), p.get('width', 2) / 2, color, true, -1, true)
