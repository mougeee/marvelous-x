extends Node2D

var scene_data = {}
signal scene_changed


func _on_back_menu_pressed() -> void:
	scene_changed.emit("offset", "option", {"cursor_direction": $Centering/NoteFrame.rotation})


func _ready() -> void:
	$Centering/NoteFrame.rotation = scene_data.get("cursor_direction", 0.0)

	var time = Time.get_ticks_usec() / 1_000_000.0
	$Metronome.set_anchor_position(time)
	$Centering/NoteFrame.metronome.set_anchor_position(time - 1.0)
	
	$Centering/OffsetLabel.modulate.a = 0.0


var offset_sum = 0
var count = 0


func _process(delta: float) -> void:
	if (
		Input.is_action_just_pressed("LeftPress") or Input.is_action_just_pressed("RightPress")
		or Input.is_action_just_pressed("CriticalPress")
	) and not $Centering/BackMenu.is_hover():
		var time = Time.get_ticks_usec() / 1_000_000.0
		var diff = fposmod(time - $Metronome.anchor_position, 0.5)
		if abs(diff - 0.5) < abs(diff):
			diff -= 0.5
		
		count += 1
		offset_sum += diff
		
		Globals.offset = offset_sum / count
		
		$Centering/OffsetLabel.text = "%.2fms\nOffset set to %.2fms" % [diff * 1000.0, Globals.offset * 1000.0]
		$Centering/OffsetLabel.modulate.a = 1.0
	$Centering/OffsetLabel.modulate.a = lerp($Centering/OffsetLabel.modulate.a, 0.0, 6.0 * delta)
