extends Node2D

var ApproachNote = preload("res://approach_note.tscn")
var time_begin


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_begin = Time.get_ticks_usec()
	$AudioStreamPlayer.play()


# [time, angle, coverage, speed, key]
const Keys = preload("res://globals.gd").Keys
var notes = [
	[2.0, 1.0, 0.2, 1.0, Keys.LEFT],
	[3.0, 0.5, 0.2, 1.2, Keys.LEFT],
	[4.0, 1.0, 0.2, 1.4, Keys.LEFT],
	[4.5, 1.5, 0.2, 1.0, Keys.LEFT],
	[5.0, 2.0, 0.2, 1.2, Keys.RIGHT],
	[6.0, -2.0, 0.2, 1.2, Keys.LEFT],
	[6.5, -1.0, 0.2, 1.2, Keys.RIGHT],
	[7.0, -2.0, 0.2, 1.2, Keys.RIGHT],
	[7.5, -3.0, 0.2, 1.2, Keys.LEFT],
	[8.0, -2.0, 0.2, 1.0, Keys.CRITICAL],
]
var next_index = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	#var time = $AudioStreamPlayer.get_playback_position()
	time -= AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	
	while next_index < notes.size() and notes[next_index][0] - 1.0/notes[next_index][3] < time:
		var note = notes[next_index]
		
		var approach_note = ApproachNote.instantiate()
		approach_note.rotation = note[1]
		approach_note.coverage = note[2]
		approach_note.speed = note[3]
		approach_note.key = note[4]
		add_child(approach_note)
		
		next_index += 1
		
	if time > 10.0:
		next_index = 0
		$AudioStreamPlayer.play()
		time_begin = Time.get_ticks_usec()
