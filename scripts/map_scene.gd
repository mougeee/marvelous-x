extends Node2D

var audio_playing = false

var offset = preload("res://scripts/globals.gd").offset


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if audio_playing:
		$Timeline.value = $AudioStreamPlayer.get_playback_position() * 1000.0
		
	if Input.is_action_just_pressed("MapPlayPause"):
		_on_play_pause_pressed()
	if Input.is_action_just_pressed("MapTapBPM"):
		_on_tap_bpm_button_pressed()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://nodes/title_scene.tscn")


func _on_load_audio_pressed() -> void:
	$AudioStreamPlayer.stream = load($AudioSourcePath.text)
	$Timeline.max_value = $AudioStreamPlayer.stream.get_length() * 1000.0
	$LoadedAudioStreamPath.text = $AudioSourcePath.text


func _on_play_pause_pressed() -> void:
	if audio_playing:
		$AudioStreamPlayer.stop()
	else:
		$AudioStreamPlayer.play($Timeline.value / 1000.0)
		$Metronome.anchor_position = Time.get_ticks_usec() / 1_000_000.0 - $Timeline.value / 1000.0 + int($Offset.text) / 1000.0
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
