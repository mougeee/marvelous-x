extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
