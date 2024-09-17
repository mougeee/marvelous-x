extends Node

const CUSTOM_WHITE = Color("#f7f7f9")
const CUSTOM_RED = Color("#bc3b3b")
const CUSTOM_BLUE = Color("#3c70ba")
const CUSTOM_YELLOW = Color("#ffce00")


enum Keys {LEFT, RIGHT, CRITICAL}
const key_info = {
	Keys.LEFT: {"code": 0},
	Keys.RIGHT: {"code": 1},
	Keys.CRITICAL: {"code": 2},
}

enum Judgements {MARVELOUS, SPLENDID, GREAT, OK, MISS}
const judgement_info = {
	Judgements.MARVELOUS: {
		"judgement": Judgements.MARVELOUS,
		"label": "Marvelous",
		"precision": 0.015,
		"accuracy": 100,
		"texture": "res://res/judgements_marvelous.svg"
	},
	Judgements.SPLENDID: {
		"judgement": Judgements.SPLENDID,
		"label": "Splendid",
		"precision": 0.040,
		"accuracy": 100,
		"texture": "res://res/judgements_splendid.svg"
	},
	Judgements.GREAT: {
		"judgement": Judgements.GREAT,
		"label": "Great",
		"precision": 0.065,
		"accuracy": 70,
		"texture": "res://res/judgements_great.svg"
	},
	Judgements.OK: {
		"judgement": Judgements.OK,
		"label": "OK",
		"precision": 0.100,
		"accuracy": 20,
		"texture": "res://res/judgements_ok.svg"
	},
	Judgements.MISS: {
		"judgement": Judgements.MISS,
		"label": "Miss",
		"precision": 0.100,
		"accuracy": 0,
		"texture": "res://res/judgements_miss.svg"
	},
}

enum NoteTypes {APPROACH, LONG, TRAP, CRITICAL}
const note_type_info = {
	NoteTypes.APPROACH: {
		"code": 0,
		'color': CUSTOM_WHITE
	},
	NoteTypes.LONG: {
		"code": 1,
		'color': CUSTOM_WHITE
	},
	NoteTypes.TRAP: {
		"code": 2,
		'color': CUSTOM_RED
	},
	NoteTypes.CRITICAL: {
		'code': 3,
		'color': CUSTOM_YELLOW
	},
}


func load_chart(filename: String) -> Dictionary:
	var file = FileAccess.open(filename, FileAccess.READ)
	var chart = JSON.parse_string(file.get_as_text())
	file.close()
	return chart


func resize_thumbnail(sprite: Sprite2D, viewport_size: Vector2):
	var thumbnail_size = sprite.texture.get_size()
	var scale_factor = max(viewport_size.x / thumbnail_size.x, viewport_size.y / thumbnail_size.y) + 0.1
	sprite.scale = Vector2(scale_factor, scale_factor)


var settings = {
	"offset": 0.0
}
