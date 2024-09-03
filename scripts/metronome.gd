extends Node

@export var bpm = 120.0
@export var anchor_position = 0.0

var beat_duration
var running = false


func set_bpm(b: float) -> void:
	bpm = b
	beat_duration = 60.0 / bpm


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beat_duration = 60.0 / bpm


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if running:
		var time = fposmod(Time.get_ticks_usec() / 1_000_000.0 - anchor_position, beat_duration)
		if time <= beat_duration and beat_duration < time + delta:
			$MainBeat.play()
