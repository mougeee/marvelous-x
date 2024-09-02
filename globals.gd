enum Keys {LEFT, RIGHT, CRITICAL}
const color_map = {
	Keys.LEFT: Color.RED,
	Keys.RIGHT: Color.BLUE,
	Keys.CRITICAL: Color.YELLOW
}

enum Judgements {MARVELOUS, SPLENDID, GREAT, OK, MISS}
# [Judgement, Label, Precision, Accuracy]
const judgement_info = {
	Judgements.MARVELOUS: [Judgements.MARVELOUS, "Marvelous", 0.020, 100],
	Judgements.SPLENDID: [Judgements.SPLENDID, "Splendid", 0.040, 100],
	Judgements.GREAT: [Judgements.GREAT, "Great", 0.065, 70],
	Judgements.OK: [Judgements.OK, "OK", 0.100, 20],
	Judgements.MISS: [Judgements.MISS, "Miss", 0.100, 0],
}
