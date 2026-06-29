class_name Player
extends Character

func _ready() -> void:
	super._ready()
	
	# Load customized player character sprite values from the global GameManager Autoload
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if game_manager and "player_visuals" in game_manager and game_manager.player_visuals:
			var visuals_data = game_manager.player_visuals
			visuals.apply_configuration(visuals_data)
			
			# Apply individual self-modulate colors if saved
			if visuals_data.has("skin_color"):
				var skin_col_str = visuals_data["skin_color"]
				if typeof(skin_col_str) == TYPE_STRING:
					var sc = Color(skin_col_str) # Changed from Color.from_html() to Color() constructor!
					if visuals.layers.has("Body"):
						visuals.layers["Body"].self_modulate = sc
						
			if visuals_data.has("hair_color"):
				var hair_col_str = visuals_data["hair_color"]
				if typeof(hair_col_str) == TYPE_STRING:
					var hc = Color(hair_col_str) # Changed from Color.from_html() to Color() constructor!
					if visuals.layers.has("Head"):
						visuals.layers["Head"].self_modulate = hc
						
			if visuals_data.has("chest_color"):
				var chest_col_str = visuals_data["chest_color"]
				if typeof(chest_col_str) == TYPE_STRING:
					var cc = Color(chest_col_str) # Changed from Color.from_html() to Color() constructor!
					if visuals.layers.has("Chest"):
						visuals.layers["Chest"].self_modulate = cc
			
			print("PlayerController successfully loaded and instantiated character visuals from GameManager.")

func _physics_process(_delta: float) -> void:
	# 1. Update modifiers
	is_sprinting = Input.is_action_pressed("sprint")
	is_crouching = Input.is_action_pressed("crouch")
	
	update_movement_state()
	
	# 2. Get input vector
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	handle_velocity(input_direction)
	
	# 3. Handle Animation state
	var anim = "Idle"
	if velocity.length() > 5:
		if is_crouching:
			anim = "CrouchRun"
		elif is_sprinting:
			anim = "Run" # (Sprint plays fast Run)
		else:
			anim = "Walk"
	else:
		if is_crouching:
			anim = "CrouchIdle"
		else:
			anim = "Idle"
	
	# Compute facing direction
	var facing_dir = get_facing_direction(input_direction)
	var current_frame = Engine.get_physics_frames() / 5 % 15 # Anim tick rate
	
	visuals.play_animation(anim, facing_dir, current_frame)

func get_facing_direction(input_vec: Vector2) -> CharacterVisuals.Direction:
	if input_vec == Vector2.ZERO:
		return CharacterVisuals.Direction.DOWN # Default facing down
		
	var angle = input_vec.angle() # Range from -PI to PI
	var degrees = rad_to_deg(angle)
	if degrees < 0:
		degrees += 360
		
	var slice = round(degrees / 45.0)
	var slice_index = int(slice) % 8
	return slice_index as CharacterVisuals.Direction
