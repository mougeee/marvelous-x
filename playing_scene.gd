extends Node2D

var ApproachNote = preload("res://approach_note.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# [time, angle, coverage]
var notes = [
	[0.0, 1.0, 0.2],
	[1.0, 0.5, 0.2],
	[2.0, 1.0, 0.2],
	[2.5, 1.5, 0.2],
	[3.0, 2.0, 0.2]
]
var next_index = 0
var time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	if next_index < notes.size() and notes[next_index][0] < time:
		var note = notes[next_index]
		
		var approach_note = ApproachNote.instantiate()
		approach_note.rotation = note[1]
		approach_note.coverage = note[2]
		add_child(approach_note)
		
		next_index += 1
