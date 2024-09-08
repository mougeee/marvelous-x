extends Node2D

const globals = preload("res://scripts/globals.gd")
const Keys = globals.Keys
const NoteTypes = globals.NoteTypes
const note_type_info = globals.note_type_info
const ApproachNote = preload("res://nodes/approach_note.tscn")
const LongNote = preload("res://nodes/long_note.tscn")
const TrapNote = preload("res://nodes/trap_note.tscn")

var audio_playing = false
var stream_loaded = false

var offset = preload("res://scripts/globals.gd").offset

var notes = []
var note_nodes = []
var chart = {
	"version": 1,
	"notes": [],
	"thumbnail": "res://res/thumbnail.svg",
	"speed": 1.0,
	"bpm": [{"t": 0.0, "b": 120.0}]
}

var bpm_processed_index = []


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
	var anchor_position = (
		Time.get_ticks_usec() / 1_000_000.0
		- $Timeline.value / 1000.0
		#+ int($Offset.text) / 1000.0
	)
	$Metronome.set_anchor_position(anchor_position)
	bpm_processed_index.append(index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# calculate time
	if audio_playing:
		$Timeline.value = $AudioStreamPlayer.get_playback_position() * 1000.0
		
	# key press event handles
	if Input.is_action_just_pressed("MapPlayPause"):
		_on_play_pause_pressed()
	if Input.is_action_just_pressed("MapTapBPM"):
		_on_tap_bpm_button_pressed()
	
	# redraw lines
	var time = $Timeline.value / 1000.0
	if chart:
		$Centering/NoteFrame.beat_lines.clear()
		for i in range(chart['bpm'].size()):
			var bpm = chart['bpm'][i]
			var timing = bpm['t']
			var end_time = $Timeline.max_value / 1000.0 if i == chart['bpm'].size() - 1 else chart['bpm'][i+1]['t']
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
		if note["y"] == note_type_info[NoteTypes.APPROACH]["code"] and note['t'] - 1.0 / chart['speed'] <= time:
			if process > 0.0 and process < 2.0:
				var note_node = ApproachNote.instantiate()
				note_nodes.append(note_node)
				note_node.manual = true
				note_node.process = process
				note_node.rotation = note['r']
				note_node.key = process_key(note['k'])
				note_node.coverage = note['c']
				note_node.frame_radius = frame.radius
				note_node.note_width = frame.width
				note_node.render()
				$Centering.add_child(note_node)
				
		elif note["y"] == note_type_info[NoteTypes.LONG]["code"]:
			if process > 0.0:
				var note_node = LongNote.instantiate()
				note_nodes.append(note_node)
				note_node.path = note['p']
				note_node.speed = chart['speed']
				note_node.manual = true
				note_node.begin_process = process
				note_node.key = process_key(note['k'])
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
				
	# create notes
	if $CreateNotes.button_pressed:
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
		note.rotation = mouse_theta
		note.process = process
		note.coverage = coverage
		note.temporary = true
		note.frame_radius = frame.radius
		note.note_width = frame.width
		note.render()
		note_nodes.append(note)
		$Centering.add_child(note)
		
		# insert note in correct position
		if (
			Input.is_action_just_pressed("LeftPress")
			or Input.is_action_just_pressed("RightPress")
			or Input.is_action_just_pressed("CriticalPress")
		):
			if Input.is_action_just_pressed("LeftPress"):
				note.key = Keys.LEFT
			if Input.is_action_just_pressed("RightPress"):
				note.key = Keys.RIGHT
			if Input.is_action_just_pressed("CriticalPress"):
				note.key = Keys.CRITICAL
			
			var t = time + 1.0 - note.process / chart['speed'] - offset
			var json = note.to_json(t)
			
			# insert in right position
			var left = 0
			var right = notes.size()
			while left < right:
				var mid_index = (left + right) / 2
				var mid = notes[mid_index]['t']
				
				if mid < t:
					left = mid_index + 1
				else:
					right = mid_index
			notes.insert(left, json)
	
	# metronome bpm
	if chart:
		for i in range(chart['bpm'].size()):
			if time > chart['bpm'][i]['t'] - delta and i not in bpm_processed_index:
				process_bpm_index(i)
				break


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://nodes/title_scene.tscn")


func _on_load_audio_pressed() -> void:
	if not ResourceLoader.exists($AudioSourcePath.text):
		return
	$AudioStreamPlayer.stream = load($AudioSourcePath.text)
	$Timeline.max_value = $AudioStreamPlayer.stream.get_length() * 1000.0
	$LoadedAudioStreamPath.text = $AudioSourcePath.text
	stream_loaded = true


func _on_play_pause_pressed() -> void:
	if not stream_loaded:
		return
		
	if audio_playing:
		$AudioStreamPlayer.stop()
	else:
		$AudioStreamPlayer.play($Timeline.value / 1000.0)
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
