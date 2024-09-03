extends Node2D

var audio_playing = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if audio_playing:
		$Timeline.value = $AudioStreamPlayer.get_playback_position() * 1000.0


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
	audio_playing = not audio_playing


func _on_timeline_drag_started() -> void:
	if audio_playing:
		$AudioStreamPlayer.stop()
		audio_playing = false
