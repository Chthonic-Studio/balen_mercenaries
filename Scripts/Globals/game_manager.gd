extends Node

func _unhandled_input(event: InputEvent) -> void:
	# Press the "C" key on your keyboard to toggle the Character Creator UI
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		# Access your Autoload globally to toggle visibility
		var current_state = CharacterCreator.ui_panel.visible
		CharacterCreator.toggle_ui(!current_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
