class_name Player extends CharacterBody2D

@onready var _appearance: CharacterAppearanceComponent = $Appearance
@onready var _movement: TopDownMovementComponent = $Movement

var _is_moving: bool = false
var _current_direction: String = "down" # Default matching your idle_down

func _ready() -> void:
	# 1. Connect to the movement component signals
	if _movement:
		_movement.facing_direction_changed.connect(_on_facing_direction_changed)
		_movement.movement_state_changed.connect(_on_movement_state_changed)
	
	# Initial animation state update
	_update_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func play_animation(anim_name: String, direction: String = "down") -> void:
	_appearance.play_animation(anim_name, direction)

func change_hair_color(hair_color: Color) -> void:
	_appearance.set_hair_color(hair_color)

func change_skin_tone(skin_tone: String) -> void:
	_appearance.set_skin_tone(skin_tone)

func change_eye_color(eye_color: Color) -> void:
	_appearance.set_eye_color(eye_color)

func get_appearance() -> CharacterAppearanceComponent:
	return _appearance

func _on_movement_state_changed(is_moving: bool) -> void:
	_is_moving = is_moving
	_update_animation()

func _on_facing_direction_changed(new_direction: Vector2) -> void:
	_current_direction = _vector_to_direction_string(new_direction)
	_update_animation()

func _vector_to_direction_string(dir: Vector2) -> String:
	# Prioritize X or Y depending on the vector's largest magnitude
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	elif abs(dir.y) > abs(dir.x):
		return "down" if dir.y > 0 else "up"
	
	# If the vector is Vector2.ZERO, retain the current facing direction
	return _current_direction

func _update_animation() -> void:
	# Determine the base action
	var action_prefix: String = "walk" if _is_moving else "idle"
	
	# Pass the action and direction separately to match the component's API
	if _appearance.has_method("play_animation"):
		_appearance.play_animation(action_prefix, _current_direction)
