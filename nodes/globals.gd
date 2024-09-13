const offset = 0.090

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
		"texture": ""
	},
	Judgements.SPLENDID: {
		"judgement": Judgements.SPLENDID,
		"label": "Splendid",
		"precision": 0.040,
		"accuracy": 100,
		"texture": ""
	},
	Judgements.GREAT: {
		"judgement": Judgements.GREAT,
		"label": "Great",
		"precision": 0.065,
		"accuracy": 70,
		"texture": ""
	},
	Judgements.OK: {
		"judgement": Judgements.OK,
		"label": "OK",
		"precision": 0.100,
		"accuracy": 20,
		"texture": ""
	},
	Judgements.MISS: {
		"judgement": Judgements.MISS,
		"label": "Miss",
		"precision": 0.100,
		"accuracy": 0,
		"texture": ""
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
