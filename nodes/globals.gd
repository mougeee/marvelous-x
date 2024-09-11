const offset = 0.090

const CUSTOM_WHITE = Color("#f7f7f9")

enum Keys {LEFT, RIGHT, CRITICAL}
const key_info = {
	Keys.LEFT: {
		"color": Color(60 / 255.0, 112 / 255.0, 186 / 255.0),
		"code": 0
	},
	Keys.RIGHT: {
		"color": Color(188 / 255.0, 59 / 255.0, 59 / 255.0),
		"code": 1
	},
	Keys.CRITICAL: {
		"color": Color(255 / 255.0, 206 / 255.0, 0 / 0.0),
		"code": 2
	},
}

enum Judgements {MARVELOUS, SPLENDID, GREAT, OK, MISS}
const judgement_info = {
	Judgements.MARVELOUS: {
		"judgement": Judgements.MARVELOUS,
		"label": "Marvelous",
		"precision": 0.015,
		"accuracy": 100
	},
	Judgements.SPLENDID: {
		"judgement": Judgements.SPLENDID,
		"label": "Splendid",
		"precision": 0.040,
		"accuracy": 100
	},
	Judgements.GREAT: {
		"judgement": Judgements.GREAT,
		"label": "Great",
		"precision": 0.065,
		"accuracy": 70
	},
	Judgements.OK: {
		"judgement": Judgements.OK,
		"label": "OK",
		"precision": 0.100,
		"accuracy": 20
	},
	Judgements.MISS: {
		"judgement": Judgements.MISS,
		"label": "Miss",
		"precision": 0.100,
		"accuracy": 0
	},
}

enum NoteTypes {APPROACH, LONG, TRAP}
const note_type_info = {
	NoteTypes.APPROACH: {"code": 0},
	NoteTypes.LONG: {"code": 1},
	NoteTypes.TRAP: {"code": 2},
}
