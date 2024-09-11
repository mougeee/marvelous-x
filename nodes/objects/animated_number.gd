extends Label


@export var number = 0.0
@export var format = "%.2f"
@export var lerp_ratio = 0.5
var display_number = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_number = number


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	display_number = lerp(display_number, number, lerp_ratio)
	
	text = format % [display_number]
