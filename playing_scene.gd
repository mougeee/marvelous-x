extends Node2D

var ApproachNote = preload("res://approach_note.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var approach_note = ApproachNote.instantiate()
	approach_note.rotation = randf() * TAU
	approach_note.color = Color.YELLOW_GREEN
	
	add_child(approach_note)
