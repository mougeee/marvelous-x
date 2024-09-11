extends Node2D

const global = preload("res://nodes/globals.gd")
const Judgements = global.Judgements
const judgement_info = global.judgement_info

var ApproachNote = preload("res://nodes/objects/approach_note.tscn")
var LongNote = preload("res://nodes/objects/long_note.tscn")
var TrapNote = preload("res://nodes/objects/trap_note.tscn")
var Judgement = preload("res://nodes/objects/judgement.tscn")
var time_begin
var offset = global.offset

const Keys = global.Keys
var notes = []
var next_index = 0
var last_time = -INF
var chart

const NoteTypes = global.NoteTypes
const note_type_info = global.note_type_info

var note_start_time = 0
var info_path = "res://res/demo1.json"
var audio_path = "res://res/demo1.wav"
	
	
func load_chart():
	var file = FileAccess.open(info_path, FileAccess.READ)
	chart = JSON.parse_string(file.get_as_text())
	file.close()
	

var note_count

func preprocess_notes(raw_notes: Array):
	note_count = 0
	for raw_note in raw_notes:
		last_time = max(last_time, raw_note['t'])
		
		var time = raw_note["t"] - 1 / chart['speed']
		note_start_time = min(note_start_time, time)
		
		# get correct position (by binary search)
		var left = 0
		var right = notes.size()
		var anchor = 0
		
		while left < right:
			anchor = (left + right) / 2.0
			var mid_value = notes[anchor]
			
			if mid_value["summon_time"] <= time:
				left = anchor + 1
			else:
				right = anchor
			
		# correct note type
		if raw_note["y"] == note_type_info[NoteTypes.APPROACH]['code']:
			raw_note['y'] = NoteTypes.APPROACH
			note_count += 1
		elif raw_note['y'] == note_type_info[NoteTypes.LONG]['code']:
			raw_note['y'] = NoteTypes.LONG
			note_count += 2
		elif raw_note['y'] == note_type_info[NoteTypes.TRAP]['code']:
			raw_note['y'] = NoteTypes.TRAP
			note_count += 1
		
		# correct key
		if raw_note.get('k', -1) != -1:
			if raw_note["k"] == 0:
				raw_note['k'] = Keys.LEFT
			elif raw_note['k'] == 1:
				raw_note['k'] = Keys.RIGHT
			elif raw_note['k'] == 2:
				raw_note['k'] = Keys.CRITICAL
			
		# insert
		raw_note["summon_time"] = time
		notes.insert(left, raw_note)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# preprocess notes
	load_chart()
	preprocess_notes(chart["notes"])
	
	# backgroung thumbnail
	$Centering/BackgroundThumbnail.texture = load(chart.thumbnail)
	$Centering/BackgroundThumbnail.modulate.a = 0.1
	
	# reset chart
	$AudioStreamPlayer.stream = load(audio_path)
	time_begin = Time.get_ticks_usec() - note_start_time * 1e6
	$Centering/NoteFrame.speed = chart['speed']


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# get audio play time
	var time = (Time.get_ticks_usec() - time_begin) / 1e6
	#var time = $AudioStreamPlayer.get_playback_position()
	time -= AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	time -= offset
	
	# beat lines timing
	for bpm in chart['bpm']:
		if bpm['t'] - 1.0 / chart['speed'] <= time and not bpm.get('processed', false):
			$Centering/NoteFrame.metronome.set_bpm(bpm['b'])
			$Centering/NoteFrame.metronome.set_anchor_position(
				time_begin / 1_000_000.0
				+ bpm['t']
				- 1.0 / chart['speed']
				+ AudioServer.get_time_since_last_mix()
				+ AudioServer.get_output_latency()
				+ offset
			)
	
	
	if not $AudioStreamPlayer.playing and time > -offset:
		$AudioStreamPlayer.play()
	
	# summon notes
	while next_index < notes.size() and time > notes[next_index]["summon_time"]:
		var note = notes[next_index]
		
		if note['y'] == NoteTypes.APPROACH:
			var approach_note = ApproachNote.instantiate()
			approach_note.rotation = note["r"]
			approach_note.coverage = note['c']
			approach_note.speed = chart['speed']
			approach_note.key = note['k']
			approach_note.pressed.connect(_on_note_pressed)
			$Centering.add_child(approach_note)
			
		elif note['y'] == NoteTypes.LONG:
			var long_note = LongNote.instantiate()
			long_note.path = note['p']
			long_note.speed = chart['speed']
			long_note.key = note['k']
			long_note.pressed.connect(_on_note_pressed)
			$Centering.add_child(long_note)
		
		elif note['y'] == NoteTypes.TRAP:
			var trap_note = TrapNote.instantiate()
			trap_note.rotation = note['r']
			trap_note.coverage = note['c']
			trap_note.speed = chart['speed']
			trap_note.passed.connect(_on_note_pressed)
			$Centering.add_child(trap_note)
		
		next_index += 1
	
	# cursor size change
	var last_cursor_info
	for cursor_info in chart['cursor']:
		if time > cursor_info['t']:
			last_cursor_info = cursor_info
	if last_cursor_info:
		$Centering/NoteFrame.coverage = lerp($Centering/NoteFrame.coverage, last_cursor_info['c'], 0.1)
	
	# escape from the game
	if time > last_time + 3.0 or Input.is_action_just_pressed("Escape"):
		get_tree().change_scene_to_file("res://nodes/scenes/title_scene.tscn")


var marvelous_count = 0
var splendid_count = 0
var great_count = 0
var ok_count = 0
var miss_count = 0


func _on_note_pressed(judgement: Judgements, angle: float, is_critical: bool, dt: float) -> void:
	var j_info = judgement_info[judgement]
	
	if j_info["judgement"] == Judgements.MARVELOUS:
		marvelous_count += 1
	if j_info["judgement"] == Judgements.SPLENDID:
		splendid_count += 1
	if j_info["judgement"] == Judgements.GREAT:
		great_count += 1
	if j_info["judgement"] == Judgements.OK:
		ok_count += 1
	if j_info["judgement"] == Judgements.MISS:
		miss_count += 1
	
	var judgement_node = Judgement.instantiate()
	judgement_node.set_judgement(j_info["judgement"])
	if not is_critical:
		judgement_node.position = Vector2.RIGHT.rotated(angle) * 100.0
	if j_info['judgement'] != Judgements.MISS and dt:
		judgement_node.get_node("Offset").text = "%.1fms" % [dt * 1000.0]
	$Centering.add_child(judgement_node)
		
	var accuracy = (float) (
		marvelous_count * judgement_info[Judgements.MARVELOUS]["accuracy"]
		+ splendid_count * judgement_info[Judgements.SPLENDID]["accuracy"]
		+ great_count * judgement_info[Judgements.GREAT]["accuracy"]
		+ ok_count * judgement_info[Judgements.OK]["accuracy"]
		+ miss_count * judgement_info[Judgements.MISS]["accuracy"]
	) / (marvelous_count + splendid_count + great_count + ok_count + miss_count)
	$Accuracy.number = accuracy
	
	#var score = (float) (
		#marvelous_count * judgement_info[Judgements.MARVELOUS]["accuracy"]
		#+ splendid_count * judgement_info[Judgements.SPLENDID]["accuracy"]
		#+ great_count * judgement_info[Judgements.GREAT]["accuracy"]
		#+ ok_count * judgement_info[Judgements.OK]["accuracy"]
		#+ miss_count * judgement_info[Judgements.MISS]["accuracy"]
	#) / note_count * 10000.0
	#$Accuracy.number = score