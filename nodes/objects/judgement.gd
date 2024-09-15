extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, -0.05, 3.0 * delta)
	
	if modulate.a < 0.0:
		queue_free()


func set_judgement(judgement: Globals.Judgements) -> void:
	modulate.a = 1.0
	
	texture = load(Globals.judgement_info[judgement]['texture'])
