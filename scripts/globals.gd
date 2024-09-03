const CUSTOM_WHITE = Color("#f7f7f9")


enum Keys {LEFT, RIGHT, CRITICAL}
const key_info = {
	Keys.LEFT: {
		"color": Color(60 / 255.0, 112 / 255.0, 186 / 255.0)
	},
	Keys.RIGHT: {
		"color": Color(188 / 255.0, 59 / 255.0, 59 / 255.0)
	},
	Keys.CRITICAL: {
		"color": Color(255 / 255.0, 206 / 255.0, 0 / 0.0)
	},
}

enum Judgements {MARVELOUS, SPLENDID, GREAT, OK, MISS}
const judgement_info = {
	Judgements.MARVELOUS: {
		"judgement": Judgements.MARVELOUS,
		"label": "Marvelous",
		"precision": 0.020,
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

enum NoteTypes {APPROACH, LONG}
