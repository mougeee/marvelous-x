extends Sprite2D


const Judgements = preload("res://nodes/globals.gd").Judgements


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	modulate.a = lerp(modulate.a, -0.05, 0.05)
	
	if modulate.a < 0.0:
		queue_free()


func set_judgement(judgement: Judgements) -> void:
	modulate.a = 1.0
	
	if judgement == Judgements.MARVELOUS:
		texture = load("res://res/judgements_marvelous.svg")
	elif judgement == Judgements.SPLENDID:
		texture = load("res://res/judgements_splendid.svg")
	elif judgement == Judgements.GREAT:
		texture = load("res://res/judgements_great.svg")
	elif judgement == Judgements.OK:
		texture = load("res://res/judgements_ok.svg")
	elif judgement == Judgements.MISS:
		texture = load("res://res/judgements_miss.svg")
