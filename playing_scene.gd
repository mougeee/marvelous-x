extends Node2D

const Judgements = preload("res://globals.gd").Judgements
const judgement_info = preload("res://globals.gd").judgement_info

var ApproachNote = preload("res://approach_note.tscn")
var time_begin
var offset = 0.08


const Keys = preload("res://globals.gd").Keys
var notes = []
var next_index = 0

var note_start_time = INF
var info_path = "res://20240902001.json"
var audio_path = "res://20240902001.mp3"


func reset_times() -> void:
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	time_begin = Time.get_ticks_usec() - note_start_time * 1e6


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_viewport_rect().size / 2
	
	# load notes from file
	var file = FileAccess.open(info_path, FileAccess.READ)
	var raw_notes = JSON.parse_string(file.get_as_text())["notes"]
	file.close()
	
	# preprocess notes
	for raw_note in raw_notes:
		var time = raw_note[0] - 1 / raw_note[3]
		note_start_time = min(note_start_time, time)
		
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
		
		# correct key
		if raw_note[4] == 0:
			raw_note[4] = Keys.LEFT
		elif raw_note[4] == 1:
			raw_note[4] = Keys.RIGHT
		else:
			raw_note[4] = Keys.CRITICAL
			
		# insert
		raw_note.insert(0, time)
		notes.insert(left, raw_note)
		
		# [summon_time, time, angle, coverage, speed, key]
		
	$AudioStreamPlayer.stream = load(audio_path)
	reset_times()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time = (Time.get_ticks_usec() - time_begin) / 1e6
	#var time = $AudioStreamPlayer.get_playback_position()
	time -= AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	time -= offset
	
	if not $AudioStreamPlayer.playing and time > -offset:
		$AudioStreamPlayer.play()
	
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
		reset_times()


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
