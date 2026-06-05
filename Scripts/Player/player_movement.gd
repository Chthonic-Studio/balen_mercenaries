extends Node
class_name TopDownMovementComponent

# --- SIGNALS ---
signal facing_direction_changed(new_direction: Vector2)
signal movement_state_changed(is_moving: bool)
signal sprint_state_changed(is_sprinting: bool)
signal dash_started()
signal dash_ended()

# --- EXPORTS ---
@export_category("Movement Settings")
@export var base_speed: float = 150.0
@export var sprint_speed: float = 250.0
@export var acceleration: float = 800.0
@export var friction: float = 1000.0

@export_category("Dash Settings")
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.2
## Max time in milliseconds between presses to trigger a dash
@export var double_tap_window_msec: int = 250 

# --- VARIABLES ---
var body: CharacterBody2D
var current_facing_direction: Vector2 = Vector2.DOWN

# State tracking
var is_moving: bool = false
var is_sprinting: bool = false
var is_dashing: bool = false

# Dash tracking
var last_dash_press_time: int = 0
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	body = get_parent() as CharacterBody2D

func _unhandled_input(event: InputEvent) -> void:
	# Check for double tap to dash using the sprint action
	if event.is_action_pressed("sprint"):
		var current_time = Time.get_ticks_msec()
		if current_time - last_dash_press_time <= double_tap_window_msec:
			_start_dash()
		last_dash_press_time = current_time

func _physics_process(delta: float) -> void:
	# 1. Handle Dash State Override
	if is_dashing:
		_process_dash(delta)
		return # Skip normal movement while dashing
		
	# 2. Get input
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 3. Determine target speed (Sprint logic)
	var current_target_speed = base_speed
	var wants_to_sprint = Input.is_action_pressed("sprint") and input_direction != Vector2.ZERO
	
	if wants_to_sprint:
		current_target_speed = sprint_speed
		
	if wants_to_sprint != is_sprinting:
		is_sprinting = wants_to_sprint
		sprint_state_changed.emit(is_sprinting)

	# 4. Apply movement or friction
	if input_direction != Vector2.ZERO:
		body.velocity = body.velocity.move_toward(input_direction * current_target_speed, acceleration * delta)
		
		if not is_moving:
			is_moving = true
			movement_state_changed.emit(is_moving)
			
		_update_facing_direction(input_direction)
	else:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
		
		if is_moving:
			is_moving = false
			movement_state_changed.emit(is_moving)
	
	# 5. Apply velocity
	body.move_and_slide()

# --- HELPER FUNCTIONS ---

func _start_dash() -> void:
	if is_dashing:
		return
		
	is_dashing = true
	dash_timer = dash_duration
	dash_started.emit()
	
	# Determine dash direction: Use current input, or fallback to facing direction if standing still
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		dash_direction = input_dir
		_update_facing_direction(input_dir)
	else:
		dash_direction = current_facing_direction

func _process_dash(delta: float) -> void:
	dash_timer -= delta
	
	if dash_timer <= 0:
		is_dashing = false
		dash_ended.emit()
		# Cut velocity slightly at the end of a dash for better game feel
		body.velocity = body.velocity.limit_length(base_speed) 
	else:
		# Apply dash velocity
		body.velocity = dash_direction * dash_speed
		
	body.move_and_slide()

func _update_facing_direction(input_dir: Vector2) -> void:
	var new_direction := current_facing_direction
	
	# Determine dominant axis. This perfectly handles analog inputs where
	# one axis is pressed slightly more than the other.
	if abs(input_dir.x) > abs(input_dir.y):
		# Moving horizontally faster
		new_direction = Vector2.RIGHT if input_dir.x > 0 else Vector2.LEFT
	elif abs(input_dir.y) > abs(input_dir.x):
		# Moving vertically faster
		new_direction = Vector2.DOWN if input_dir.y > 0 else Vector2.UP
	else:
		# Exactly diagonal (usually happens with digital keyboard inputs).
		# We default to a horizontal preference here as a tie-breaker.
		if input_dir.x != 0:
			new_direction = Vector2.RIGHT if input_dir.x > 0 else Vector2.LEFT
			
	# Only emit if it changed
	if new_direction != current_facing_direction:
		current_facing_direction = new_direction
		facing_direction_changed.emit(current_facing_direction)
