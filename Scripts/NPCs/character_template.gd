# character_template.gd
class_name CharacterTemplate
extends Node2D

enum AnimState { CAST, THRUST, WALK, SLASH, SHOOT, HURT }
enum Direction { UP, LEFT, DOWN, RIGHT }

# LPC Sheet structure: Action -> [Start Row, Frame Count]
const ANIM_MAP: Dictionary = {
	AnimState.CAST: [0, 7],
	AnimState.THRUST: [4, 8],
	AnimState.WALK: [8, 9],
	AnimState.SLASH: [12, 6],
	AnimState.SHOOT: [16, 13],
	AnimState.HURT: [20, 6]
}

var current_state: AnimState = AnimState.WALK
var current_dir: Direction = Direction.DOWN
var current_frame: int = 0
var anim_timer: float = 0.0
var anim_speed: float = 0.1

func _process(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= anim_speed:
		anim_timer = 0.0
		_advance_frame()

func set_animation(state: AnimState, dir: Direction) -> void:
	if current_state != state or current_dir != dir:
		current_state = state
		current_dir = dir
		current_frame = 0
		_sync_sprites()

func _advance_frame() -> void:
	var frame_count = ANIM_MAP[current_state][1]
	current_frame = (current_frame + 1) % frame_count
	_sync_sprites()

func _sync_sprites() -> void:
	var base_row = ANIM_MAP[current_state][0]
	
	# Hurt only has one row (directionless) in standard LPC
	var target_row = base_row if current_state == AnimState.HURT else base_row + current_dir
	
	for child in get_children():
		if child is Sprite2D and child.texture != null:
			child.frame_coords = Vector2i(current_frame, target_row)
