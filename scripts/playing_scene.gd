extends Node2D

const Judgements = preload("res://scripts/globals.gd").Judgements
const judgement_info = preload("res://scripts/globals.gd").judgement_info

var ApproachNote = preload("res://nodes/approach_note.tscn")
var LongNote = preload("res://nodes/long_note.tscn")
var Judgement = preload("res://nodes/judgement.tscn")
var time_begin
var offset = 0.090

const Keys = preload("res://scripts/globals.gd").Keys
var notes = []
var next_index = 0

const NoteTypes = preload("res://scripts/globals.gd").NoteTypes

var note_start_time = 0
var info_path = "res://res/20240902001.json"
var audio_path = "res://res/20240902001.mp3"


func reset_times() -> void:
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	time_begin = Time.get_ticks_usec() - note_start_time * 1e6
	

func resize() -> void:
	position = get_viewport_rect().size / 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize)
	
	position = get_viewport_rect().size / 2
	
	# load notes from file
	var file = FileAccess.open(info_path, FileAccess.READ)
	var raw_notes = JSON.parse_string(file.get_as_text())["notes"]
	file.close()
	
	# preprocess notes
	for raw_note in raw_notes:
		var time = raw_note["t"] - 1 / raw_note["s"]
		note_start_time = min(note_start_time, time)
		
		# get correct position (by binary search)
		var left = 0
		var right = notes.size()
		var anchor = 0
		
		while left < right:
			anchor = (left + right) / 2
			var mid_value = notes[anchor]
			
			if mid_value["summon_time"] <= time:
				left = anchor + 1
			else:
				right = anchor
		
		# correct key
		if raw_note["k"] == 0:
			raw_note['k'] = Keys.LEFT
		elif raw_note['k'] == 1:
			raw_note['k'] = Keys.RIGHT
		elif raw_note['k'] == 2:
			raw_note['k'] = Keys.CRITICAL
			
		# correct note type
		if raw_note["y"] == 0:
			raw_note['y'] = NoteTypes.APPROACH
		elif raw_note['y'] == 1:
			raw_note['y'] = NoteTypes.LONG
			
		# insert
		raw_note["summon_time"] = time
		notes.insert(left, raw_note)
		
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
	
	while next_index < notes.size() and notes[next_index]["summon_time"] < time:
		var note = notes[next_index]
		
		if note['y'] == NoteTypes.APPROACH:
			var approach_note = ApproachNote.instantiate()
			approach_note.rotation = note["r"]
			approach_note.coverage = note['c']
			approach_note.speed = note['s']
			approach_note.key = note['k']
			approach_note.pressed.connect(_on_approach_note_pressed)
			add_child(approach_note)
		elif note['y'] == NoteTypes.LONG:
			var long_note = LongNote.instantiate()
			long_note.path = note['p']
			long_note.speed = note['s']
			long_note.key = note['k']
			add_child(long_note)
		
		next_index += 1
		
	if time > 10.0:
		next_index = 0
		reset_times()


var marvelous_count = 0
var splendid_count = 0
var great_count = 0
var ok_count = 0
var miss_count = 0


func _on_approach_note_pressed(judgement: Judgements, angle: float, is_critical: bool) -> void:
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
	
	var judgement_node = Judgement.instantiate()
	judgement_node.set_judgement(j_info[0])
	if not is_critical:
		judgement_node.position = Vector2.RIGHT.rotated(angle) * 100.0
	add_child(judgement_node)
		
	var accuracy = (float) (
		marvelous_count * judgement_info[Judgements.MARVELOUS][3]
		+ splendid_count * judgement_info[Judgements.SPLENDID][3]
		+ great_count * judgement_info[Judgements.GREAT][3]
		+ ok_count * judgement_info[Judgements.OK][3]
		+ miss_count * judgement_info[Judgements.MISS][3]
	) / (marvelous_count + splendid_count + great_count + ok_count + miss_count)
	
	$Accuracy.text = str(accuracy)
