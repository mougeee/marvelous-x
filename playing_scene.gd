extends Node2D

const Judgements = preload("res://globals.gd").Judgements
const judgement_info = preload("res://globals.gd").judgement_info

var ApproachNote = preload("res://approach_note.tscn")
var time_begin
var offset = 0.090


# [time, angle, coverage, speed, key]
const Keys = preload("res://globals.gd").Keys
var raw_notes = [
	[2.0, 1.0, 0.2, 1.0, Keys.LEFT],
	[3.0, 0.5, 0.2, 1.8, Keys.LEFT],
	[4.0, 1.0, 0.2, 1.6, Keys.LEFT],
	[4.5, 1.5, 0.2, 1.4, Keys.LEFT],
	[5.0, 2.0, 0.2, 1.2, Keys.RIGHT],
	[6.0, -2.0, 0.2, 1.0, Keys.LEFT],
	[6.5, -1.0, 0.2, 0.8, Keys.RIGHT],
	[7.0, -2.0, 0.2, 0.6, Keys.RIGHT],
	[7.5, -3.0, 0.2, 0.4, Keys.LEFT],
	[8.0, -2.0, 0.2, 0.2, Keys.CRITICAL],
]
var notes = []
var next_index = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_begin = Time.get_ticks_usec()
	$AudioStreamPlayer.play()
	
	position = get_viewport_rect().size / 2
	
	for raw_note in raw_notes:
		var time = raw_note[0] - 1 / raw_note[3]
		
		# get correct position (by binary search)
		var left = 0
		var right = notes.size()
		var anchor = 0
		
		while left < right:
			anchor = (left + right) / 2
			var mid_value = notes[anchor]
			
			if mid_value[0] <= time:
				left = anchor + 1
			else:
				right = anchor
				
		# insert
		notes.insert(left, [time] + raw_note)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	#var time = $AudioStreamPlayer.get_playback_position()
	time -= AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	time -= offset
	
	while next_index < notes.size() and notes[next_index][0] < time:
		var note = notes[next_index]
		
		var approach_note = ApproachNote.instantiate()
		approach_note.rotation = note[2]
		approach_note.coverage = note[3]
		approach_note.speed = note[4]
		approach_note.key = note[5]
		approach_note.pressed.connect(_on_approach_note_pressed)
		add_child(approach_note)
		
		next_index += 1
		
	if time > 10.0:
		next_index = 0
		$AudioStreamPlayer.play()
		time_begin = Time.get_ticks_usec()


var marvelous_count = 0
var splendid_count = 0
var great_count = 0
var ok_count = 0
var miss_count = 0


func _on_approach_note_pressed(judgement: Judgements):
	var j_info = judgement_info[judgement]
	
	if j_info[0] == Judgements.MARVELOUS:
		marvelous_count += 1
	if j_info[0] == Judgements.SPLENDID:
		splendid_count += 1
	if j_info[0] == Judgements.GREAT:
		great_count += 1
	if j_info[0] == Judgements.OK:
		ok_count += 1
	if j_info[0] == Judgements.MISS:
		miss_count += 1
		
	var accuracy = (float) (
		marvelous_count * judgement_info[Judgements.MARVELOUS][3]
		+ splendid_count * judgement_info[Judgements.SPLENDID][3]
		+ great_count * judgement_info[Judgements.GREAT][3]
		+ ok_count * judgement_info[Judgements.OK][3]
		+ miss_count * judgement_info[Judgements.MISS][3]
	) / (marvelous_count + splendid_count + great_count + ok_count + miss_count)
	
	$Judgement.text = "{}, {}%".format([j_info[1], accuracy], "{}")
