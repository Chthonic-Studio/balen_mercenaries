class_name Character
extends CharacterBody2D

# Export variables for easy tweaking in Inspector
@export var base_speed: float = 150.0
@export var sprint_multiplier: float = 1.6
@export var crouch_multiplier: float = 0.5

var current_speed: float = 0.0
var is_sprinting: bool = false
var is_crouching: bool = false

@onready var visuals: CharacterVisuals = $CharacterVisuals

func _ready() -> void:
	current_speed = base_speed

# Custom speed calculation based on state modifiers
func update_movement_state() -> void:
	if is_crouching:
		current_speed = base_speed * crouch_multiplier
	elif is_sprinting:
		current_speed = base_speed * sprint_multiplier
	else:
		current_speed = base_speed

func handle_velocity(input_dir: Vector2) -> void:
	if input_dir != Vector2.ZERO:
		velocity = input_dir.normalized() * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed * 0.2)
	
	move_and_slide()
