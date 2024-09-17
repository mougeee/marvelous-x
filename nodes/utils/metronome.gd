extends Node

@export var _bpm = 120.0

var beat_duration
@export var sound = false
var need = false
var time = 0.0
var anchor_position


func set_bpm(b: float) -> void:
	_bpm = b
	beat_duration = 60.0 / _bpm
	
	
func set_anchor_position(ap: float):
	anchor_position = ap
	time = fposmod(Time.get_ticks_usec() / 1_000_000.0 - ap, beat_duration)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	beat_duration = 60.0 / _bpm


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not need:
		time += delta
		if time >= beat_duration:
			need = true
			time -= beat_duration
	
	if sound and need:
		$MainBeat.play()
		need = false
