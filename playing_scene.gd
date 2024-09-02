extends Node2D

var ApproachNote = preload("res://approach_note.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()


# [time, angle, coverage, speed]
var notes = [
	[2.0, 1.0, 0.2, 1.0],
	[3.0, 0.5, 0.2, 1.2],
	[4.0, 1.0, 0.2, 1.4],
	[4.5, 1.5, 0.2, 1.0],
	[5.0, 2.0, 0.2, 1.2],
	[6.0, -2.0, 0.2, 1.2],
	[6.5, -1.0, 0.2, 1.2],
	[7.0, -2.0, 0.2, 1.2],
	[7.5, -3.0, 0.2, 1.2],
	[8.0, -2.0, 0.2, 1.2],
]
var next_index = 0
var time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	while next_index < notes.size() and notes[next_index][0] - 1.0/notes[next_index][3] < time:
		var note = notes[next_index]
		
		var approach_note = ApproachNote.instantiate()
		approach_note.rotation = note[1]
		approach_note.coverage = note[2]
		approach_note.speed = note[3]
		add_child(approach_note)
		
		next_index += 1
		
	if time > 10.0:
		time = 0.0
		next_index = 0
		$AudioStreamPlayer.play()
