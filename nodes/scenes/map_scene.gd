extends Node2D

const globals = preload("res://nodes/globals.gd")
const Keys = globals.Keys
const key_info = globals.key_info
const NoteTypes = globals.NoteTypes
const note_type_info = globals.note_type_info
const ApproachNote = preload("res://nodes/objects/approach_note.tscn")
const LongNote = preload("res://nodes/objects/long_note.tscn")
const TrapNote = preload("res://nodes/objects/trap_note.tscn")
const CriticalNote = preload("res://nodes/objects/critical_note.tscn")

var audio_playing = false
var stream_loaded = false

var offset = globals.offset

var notes = []
var note_nodes = []
var chart = {
	"version": 1,
	"notes": [],
	"thumbnail": "res://res/thumbnail.svg",
	"speed": 0.5,
	"bpm": [{"t": 0.0, "b": 120.0}],
	"cursor": [{"t": 0.0, "c": 1.0}]
}

var bpm_processed_index = []

var scene_data

signal scene_changed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var chart_duplicate = JSON.parse_string(JSON.stringify(chart))
	chart_duplicate.erase("notes")
	$ChartRawEdit.text = JSON.stringify(chart_duplicate, ' ')

func process_key(key_code: int) -> Keys:
	if key_code == 0:
		return Keys.LEFT
	elif key_code == 1:
		return Keys.RIGHT
	else:
		return Keys.CRITICAL
	
	
func process_bpm_index(index: int) -> void:
	var bpm = chart['bpm'][index]
	$Metronome.set_bpm(bpm['b'])
	var anchor_position = Time.get_ticks_usec() / 1_000_000.0 - $Timeline.value
	$Metronome.set_anchor_position(anchor_position)
	bpm_processed_index.append(index)


func draw_temporary_note(frame):
	var mouse_delta = get_global_mouse_position() - $Centering.position
	var mouse_theta = atan2(mouse_delta.y, mouse_delta.x)
	var mouse_distance = mouse_delta.length()
	var coverage = pow($CreateNoteCoverage.value / 21.0, 2) * TAU
	var process = pow(mouse_distance / frame.radius, 0.25)
	
	# process snap
	for i in range($Centering/NoteFrame.beat_lines.size() - 1):
		var p = $Centering/NoteFrame.beat_lines[i + 1]
		var np = $Centering/NoteFrame.beat_lines[i]
		if p <= process and process <= np:
			process = p + round((process - p) / (np - p) * 4.0) / 4.0 * (np - p)
			break
	
	# draw note
	var note = ApproachNote.instantiate()
	note.manual = true
	note.rotation = round(mouse_theta * 100.0) / 100.0
	note.process = process
	note.coverage = round(coverage * 100.0) / 100.0
	note.temporary = true
	note.frame_radius = frame.radius
	note.note_width = frame.width
	note.render()
	note_nodes.append(note)
	$Centering.add_child(note)
	
	return note


var creating_long_note = []
var selected_note
var selected_note_distance
var selected_note_radius


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# calculate time
	if audio_playing:
		$Timeline.value = $AudioStreamPlayer.get_playback_position()
		
	# key press event handles
	if Input.is_action_just_pressed("MapPlayPause"):
		_on_play_pause_pressed()
	if Input.is_action_just_pressed("MapTapBPM"):
		_on_tap_bpm_button_pressed()
	
	# redraw lines
	var time = $Timeline.value
	if chart:
		$Centering/NoteFrame.beat_lines.clear()
		for i in range(chart['bpm'].size()):
			var bpm = chart['bpm'][i]
			var timing = bpm['t']
			var end_time = $Timeline.max_value if i == chart['bpm'].size() - 1 else chart['bpm'][i+1]['t']
			while timing - 1.0 / chart['speed'] < min(end_time, time):
				var summon_time = timing - 1.0 / chart['speed'] + offset
				var dt = time - summon_time
				var process = dt / (1.0 / chart['speed'])
				if 0.0 < process and process < 2.0:
					$Centering/NoteFrame.beat_lines.append(process)
				timing += 60.0 / bpm['b']
	
	# -- draw notes
	for note_node in note_nodes:
		note_node.queue_free()
	note_nodes.clear()
	
	var frame = $Centering/NoteFrame
	for note in notes:
		var process = (time - note['t'] - offset) * chart['speed'] + 1.0
		if not (note['t'] - 1.0 / chart['speed'] <= time):
			continue
			
		if note["y"] == note_type_info[NoteTypes.APPROACH]["code"]:
			if process > 0.0 and process < 2.0:
				var note_node = ApproachNote.instantiate()
				note_nodes.append(note_node)
				note_node.manual = true
				note_node.process = process
				note_node.rotation = note['r']
				note_node.coverage = note['c']
				note_node.frame_radius = frame.radius
				note_node.note_width = frame.width
				note_node.render()
				$Centering.add_child(note_node)
				
		elif note["y"] == note_type_info[NoteTypes.LONG]["code"]:
			if process > 0.0:
				var note_node = LongNote.instantiate()
				note_nodes.append(note_node)
				note_node.path = JSON.parse_string(JSON.stringify(note['p']))
				note_node.speed = chart['speed']
				note_node.manual = true
				note_node.begin_process = process
				note_node.frame_radius = frame.radius
				note_node.process_notes()
				$Centering.add_child(note_node)
				
		elif note['y'] == note_type_info[NoteTypes.TRAP]['code']:
			if process > 0.0 and process < 2.0:
				var note_node = TrapNote.instantiate()
				note_nodes.append(note_node)
				note_node.manual = true
				note_node.process = process
				note_node.rotation = note['r']
				note_node.coverage = note['c']
				note_node.frame_radius = frame.radius
				note_node.note_width = frame.width
				note_node.render()
				$Centering.add_child(note_node)
				
		elif note['y'] == note_type_info[NoteTypes.CRITICAL]['code']:
			if process > 0.0 and process < 2.0:
				var note_node = CriticalNote.instantiate()
				note_nodes.append(note_node)
				note_node.manual = true
				note_node.process = process
				note_node.frame_radius = frame.radius
				note_node.note_width = frame.width
				note_node.render()
				$Centering.add_child(note_node)
				
	# create notes
	if $CreateNotes.button_pressed or $CreateTrapNotes.button_pressed:
		var note = draw_temporary_note(frame)
		
		# insert note in correct position
		if (
			Input.is_action_just_pressed("LeftPress")
			or Input.is_action_just_pressed("RightPress")
			or Input.is_action_just_pressed("CriticalPress")
		):
			var t = time + (1.0 - note.process) / chart['speed'] - offset
			var json = note.to_json(t)
			if $CreateTrapNotes.button_pressed:
				json.erase("k")
				json['y'] = note_type_info[NoteTypes.TRAP]['code']
			elif Input.is_action_just_pressed("CriticalPress"):
				json.erase("c")
				json.erase("r")
				json['y'] = note_type_info[NoteTypes.CRITICAL]['code']
			
			# insert in right position
			var left = 0
			var right = notes.size()
			while left < right:
				var mid_index = (left + right) / 2.0
				var mid = notes[mid_index]['t']
				
				if mid < t:
					left = mid_index + 1
				else:
					right = mid_index
			notes.insert(left, json)
	
	# create long notes
	if $CreateLongNotes.button_pressed:
		var note = draw_temporary_note(frame)
		var t = time + (1.0 - note.process) / chart['speed'] - offset
		
		# start long note
		if Input.is_action_just_pressed("LeftPress") or Input.is_action_just_pressed("RightPress"):
			creating_long_note.append({'t': t, 'r': note.rotation, 'c': note.coverage})
		
		# create middle long note
		if (
			Input.is_action_pressed("LeftPress") and Input.is_action_just_released("RightPress")
			or Input.is_action_pressed("RightPress") and Input.is_action_just_released("LeftPress")
		):
			creating_long_note.append({'t': t, 'r': note.rotation, 'c': note.coverage})
		
		# end long note
		if (
			not Input.is_action_pressed("RightPress") and Input.is_action_just_released("LeftPress")
			or not Input.is_action_pressed("LeftPress") and Input.is_action_just_released("RightPress")
		):
			creating_long_note.append({'t': t, 'r': note.rotation, 'c': note.coverage})
			
			# preprocess creating_long_note
			var start_time = creating_long_note[0]['t']
			for i in range(creating_long_note.size()):
				creating_long_note[i]['t'] -= start_time
			
			# insert long note to the position
			var key_code
			if Input.is_action_just_released("LeftPress"):
				key_code = key_info[Keys.LEFT]['code']
			elif Input.is_action_just_released("RightPress"):
				key_code = key_info[Keys.RIGHT]['code']
				
				
			# insert in right position
			var left = 0
			var right = notes.size()
			while left < right:
				var mid_index = (left + right) / 2.0
				var mid = notes[mid_index]['t']
				
				if mid < t:
					left = mid_index + 1
				else:
					right = mid_index
			notes.insert(left, {
				'y': note_type_info[NoteTypes.LONG]['code'],
				't': start_time,
				'p': JSON.parse_string(JSON.stringify(creating_long_note))
			})
			
			#
			creating_long_note.clear()
	
	# metronome bpm
	if chart:
		for i in range(chart['bpm'].size()):
			if time > chart['bpm'][i]['t'] - delta and i not in bpm_processed_index:
				process_bpm_index(i)
				break
	
	# cursor coverage
	var last_cursor_info
	for cursor_info in chart['cursor']:
		if time - offset >= cursor_info['t']:
			last_cursor_info = cursor_info
	if last_cursor_info:
		$Centering/NoteFrame.set_coverage(last_cursor_info['c'])
	
	# remove/edit notes
	if $RemoveNotes.button_pressed or $EditNotes.button_pressed:
		# -- select note
		selected_note_distance = INF
		var mouse_pos = get_global_mouse_position() - get_viewport_rect().size / 2
		var selected_note_index
		for i in range(notes.size()):
			var note = notes[i]
			if (
				note['y'] == note_type_info[NoteTypes.APPROACH]['code']
				or note['y'] == note_type_info[NoteTypes.TRAP]['code']
			):
				var process = (time - (note['t'] - 1.0 / chart['speed'] + offset)) * chart['speed']
				var distance = pow(process, 4) * frame.radius
				var pos = Vector2(distance, 0).rotated(note['r'])
				var distance_between_mouse = (pos - mouse_pos).length()
				
				if not selected_note_distance or distance_between_mouse < selected_note_distance:
					selected_note = note
					selected_note_distance = distance_between_mouse
					selected_note_radius = distance
					selected_note_index = i
		
		# -- remove note
		if (
			$RemoveNotes.button_pressed and selected_note_index != null and (
				Input.is_action_just_pressed('LeftPress') or Input.is_action_just_pressed('RightPress')
			)
		):
			notes.pop_at(selected_note_index)
			queue_redraw()
		
		# -- edit note
		if $EditNotes.button_pressed and selected_note_index != null:
			var note = notes[selected_note_index]
			if Input.is_action_pressed('LeftPress'):
				var mouse_direction = atan2(mouse_pos.y, mouse_pos.x)
				note['r'] = mouse_direction
			if Input.is_action_pressed("RightPress"):
				var mouse_process = pow(mouse_pos.length() / frame.radius, 0.25)
				
				# snap mouse_process
				for i in range($Centering/NoteFrame.beat_lines.size() - 1):
					var p = $Centering/NoteFrame.beat_lines[i + 1]
					var np = $Centering/NoteFrame.beat_lines[i]
					if p <= mouse_process and mouse_process <= np:
						mouse_process = p + round((mouse_process - p) / (np - p) * 4.0) / 4.0 * (np - p)
						break
				
				var new_t = time - (mouse_process - 1.0) / chart['speed'] - offset
				var previous_t = note['t']
				note['t'] = new_t
				
				# sort notes by time
				if previous_t != new_t:
					notes.sort_custom(func(a, b): return a['t'] < b['t'])
		
		queue_redraw()
	
	# control coverage by shortcut
	if Input.is_action_just_pressed("MapDecreaseCoverage"):
		$CreateNoteCoverage.value -= 1
	if Input.is_action_just_pressed("MapIncreaseCoverage"):
		$CreateNoteCoverage.value += 1


func _draw():
	if ($RemoveNotes.button_pressed or $EditNotes.button_pressed) and selected_note and notes:
		var pos = get_viewport_rect().size / 2 + Vector2(selected_note_radius, 0.0).rotated(selected_note['r'])
		draw_circle(pos, 100.0, Color.WHITE, false, 1, true)


func _on_back_pressed() -> void:
	scene_changed.emit("map", "title")


func _on_load_audio_pressed() -> void:
	if not ResourceLoader.exists($AudioSourcePath.text):
		return
	$AudioStreamPlayer.stream = load($AudioSourcePath.text)
	$Timeline.max_value = $AudioStreamPlayer.stream.get_length() 
	$LoadedAudioStreamPath.text = $AudioSourcePath.text
	stream_loaded = true


func _on_play_pause_pressed() -> void:
	if not stream_loaded:
		return
		
	if audio_playing:
		$AudioStreamPlayer.stop()
	else:
		$AudioStreamPlayer.play($Timeline.value)
		bpm_processed_index.clear()
		pressed_log.clear()
		
	audio_playing = not audio_playing
	$Metronome.sound = audio_playing and $MetronomeOn.button_pressed


func _on_timeline_drag_started() -> void:
	if audio_playing:
		$AudioStreamPlayer.stop()
		audio_playing = false
		$Metronome.sound = audio_playing
		$Centering/NoteFrame.beat_lines.clear()


var pressed_log = []

func _on_tap_bpm_button_pressed() -> void:
	pressed_log.append(Time.get_ticks_usec() / 1_000_000.0)
	
	if pressed_log.size() < 2:
		return
	
	var total_delta = pressed_log[pressed_log.size() - 1] - pressed_log[0]
	var interval_count = pressed_log.size() - 1
	var predicted_bpm = 60.0 * 4 * total_delta / interval_count
	
	var offset_sum = 0.0
	for time in pressed_log:
		var o = fposmod(time - offset - (Time.get_ticks_usec() / 1_000_000.0 - $AudioStreamPlayer.get_playback_position()), $Metronome.beat_duration)
		var o2 = o - $Metronome.beat_duration
		if abs(o2) < abs(o):
			o = o2
		offset_sum += o
	var predicted_offset = offset_sum / pressed_log.size()
	
	$TapBPMInfo.text = "%d BPM, %.1fms" % [predicted_bpm, predicted_offset * 1000.0]


func _on_metronome_on_pressed() -> void:
	$Metronome.sound = audio_playing and $MetronomeOn.button_pressed
	process_bpm_index(bpm_processed_index[bpm_processed_index.size() - 1])



func _on_audio_stream_player_finished() -> void:
	_on_play_pause_pressed()


func load_chart(info_path: String):
	var file = FileAccess.open(info_path, FileAccess.READ)
	chart = JSON.parse_string(file.get_as_text())
	file.close()
	
	var chart_duplicate = JSON.parse_string(JSON.stringify(chart))
	chart_duplicate.erase("notes")
	$ChartRawEdit.text = JSON.stringify(chart_duplicate, ' ')


func _on_load_chart_pressed() -> void:
	if not ResourceLoader.exists($ChartSourcePath.text):
		return
	load_chart($ChartSourcePath.text)
	notes = chart["notes"]
	$LoadedChartPath.text = $ChartSourcePath.text
	$Centering/NoteFrame.speed = chart['speed']


func _on_create_note_coverage_value_changed(value: float) -> void:
	$CreateNoteCoverageLabel.text = str(value)


func _on_save_chart_pressed() -> void:
	chart['notes'] = notes
	var file = FileAccess.open($ChartSourcePath.text, FileAccess.WRITE)
	file.store_string(JSON.stringify(chart))
	file.close()


func _on_chart_raw_edit_focus_exited() -> void:
	chart = JSON.parse_string($ChartRawEdit.text)
	chart['notes'] = notes


func _on_remove_notes_button_up() -> void:
	queue_redraw()


func _on_edit_notes_button_up() -> void:
	queue_redraw()
