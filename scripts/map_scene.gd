extends Node2D

const globals = preload("res://scripts/globals.gd")
const Keys = globals.Keys
const NoteTypes = globals.NoteTypes
const note_type_info = globals.note_type_info
const ApproachNote = preload("res://nodes/approach_note.tscn")
const LongNote = preload("res://nodes/long_note.tscn")

var audio_playing = false
var stream_loaded = false

var offset = preload("res://scripts/globals.gd").offset

var notes = []
var note_nodes = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func process_key(key_code: int) -> Keys:
	if key_code == 0:
		return Keys.LEFT
	elif key_code == 1:
		return Keys.RIGHT
	else:
		return Keys.CRITICAL


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if audio_playing:
		$Timeline.value = $AudioStreamPlayer.get_playback_position() * 1000.0
		
	if Input.is_action_just_pressed("MapPlayPause"):
		_on_play_pause_pressed()
	if Input.is_action_just_pressed("MapTapBPM"):
		_on_tap_bpm_button_pressed()
	
	for note_node in note_nodes:
		note_node.queue_free()
	note_nodes.clear()
	
	var time = $Timeline.value / 1000.0
	var frame = $Centering/NoteFrame
	for note in notes:
		if note["y"] == note_type_info[NoteTypes.APPROACH]["code"] and note['t'] - 1.0 / note['s'] <= time:
			var process = (time - note['t']) * note['s'] + 1.0
			if process > 0.0 and process < 2.0:
				var note_node = ApproachNote.instantiate()
				note_nodes.append(note_node)
				note_node.manual = true
				note_node.process = process
				note_node.rotation = note['r']
				note_node.key = process_key(note['k'])
				note_node.frame_radius = frame.radius
				note_node.note_width = frame.width
				note_node.render()
				note_node.queue_redraw()
				$Centering.add_child(note_node)
		elif note["y"] == note_type_info[NoteTypes.LONG]["code"]:
			var begin_process = (time - note['t']) * note['s'] + 1.0
			if begin_process > 0.0:
				var note_node = LongNote.instantiate()
				note_nodes.append(note_node)
				note_node.speed = note['s']
				note_node.path = note['p']
				note_node.manual = true
				note_node.begin_process = begin_process
				note_node.key = process_key(note['k'])
				note_node.frame_radius = frame.radius
				note_node.process_notes()
				$Centering.add_child(note_node)


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
		$Metronome.anchor_position = Time.get_ticks_usec() / 1_000_000.0 - $Timeline.value / 1000.0 + int($Offset.text) / 1000.0
		$AudioStreamPlayer.play($Timeline.value / 1000.0)
		pressed_log.clear()
	audio_playing = not audio_playing
	$Metronome.running = audio_playing and $MetronomeOn.button_pressed


func _on_timeline_drag_started() -> void:
	if audio_playing:
		$AudioStreamPlayer.stop()
		audio_playing = false
		$Metronome.running = audio_playing


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
	$Metronome.running = audio_playing and $MetronomeOn.button_pressed


func _on_bpm_text_changed(new_text: String) -> void:
	$Metronome.set_bpm(float(new_text))


func _on_audio_stream_player_finished() -> void:
	_on_play_pause_pressed()


func _on_offset_text_changed(new_text: String) -> void:
	$Metronome.anchor_position = Time.get_ticks_usec() / 1_000_000.0 - $Timeline.value / 1000.0 + int(new_text) / 1000.0


func load_chart(info_path: String) -> Dictionary:
	var file = FileAccess.open(info_path, FileAccess.READ)
	var chart = JSON.parse_string(file.get_as_text())
	file.close()
	
	return chart


func _on_load_chart_pressed() -> void:
	if not ResourceLoader.exists($ChartSourcePath.text):
		return
	var chart = load_chart($ChartSourcePath.text)
	notes = chart["notes"]
	$LoadedChartPath.text = $ChartSourcePath.text
