enum Keys {LEFT, RIGHT, CRITICAL}
# [Color]
const key_info = {
	Keys.LEFT: [Color(188/255.0, 59/255.0, 59/255.0)],
	Keys.RIGHT: [Color(60/255.0, 112/255.0, 186/255.0)],
	Keys.CRITICAL: [Color(255/255.0, 206/255.0, 0.0)],
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
