class_name CharacterVisuals
extends Node2D

# Configures the active vertical spritesheet mapping (8 directions)
const VFRAMES: int = 8

# Direction clockwise mapping matching coordinates
enum Direction {
	RIGHT = 0,
	RIGHT_DOWN = 1,
	DOWN = 2,
	DOWN_LEFT = 3,
	LEFT = 4,
	LEFT_UP = 5,
	UP = 6,
	UP_RIGHT = 7
}

# The active layers
@onready var layers = {
	"Shadow": $Shadow,
	"Mount": $Mount,
	"Body": $Body,
	"NakedBody": $Body,
	"Legs": $Legs,
	"Shoes": $Shoes,
	"Chest": $Chest,
	"Belt": $Belt,
	"Bag": $Bag,
	"Hands": $Hands,
	"Head": $Head,
	"Melee": $Melee,
	"Shield": $Shield,
	"Effect": $Effect
}

# Stores the active configuration values
var active_config: Dictionary = {}

# Applies a customization configuration to the active sprite visibility
func apply_configuration(config: Dictionary) -> void:
	active_config = config
	for part_name in layers.keys():
		if layers.has(part_name):
			var value = config.get(part_name, 0)
			if typeof(value) == TYPE_INT and value == 0:
				layers[part_name].visible = false
			elif typeof(value) == TYPE_BOOL and value == false:
				layers[part_name].visible = false
			else:
				layers[part_name].visible = true
	queue_redraw()

# Updates the sprite frame depending on direction, animation name, and current timer frame.
# This script loads separate animation sheets (e.g., Idle.png, Walk.png, Run.png)
# dynamically from each individual part's style folder!
func play_animation(anim_name: String, dir_enum: Direction, frame_idx: int) -> void:
	var row = int(dir_enum)
	
	for layer_name in layers.keys():
		var sprite = layers[layer_name]
		if sprite.visible and sprite is Sprite2D:
			# Get style index (e.g., Body=1, Head=2)
			var style_val = active_config.get(layer_name, 0)
			var style_idx: int = 0
			if typeof(style_val) == TYPE_INT:
				style_idx = style_val
			elif typeof(style_val) == TYPE_BOOL:
				style_idx = 1 if style_val else 0
			
			# Fallback if we use the dual key 'NakedBody' vs 'Body'
			if style_idx == 0 and layer_name == "Body":
				var fallback_val = active_config.get("NakedBody", 0)
				if typeof(fallback_val) == TYPE_INT:
					style_idx = fallback_val
				elif typeof(fallback_val) == TYPE_BOOL:
					style_idx = 1 if fallback_val else 0
			elif style_idx == 0 and layer_name == "NakedBody":
				var fallback_val = active_config.get("Body", 0)
				if typeof(fallback_val) == TYPE_INT:
					style_idx = fallback_val
				elif typeof(fallback_val) == TYPE_BOOL:
					style_idx = 1 if fallback_val else 0
				
			var style_str = ""
			if style_idx > 0:
				style_str = str(style_idx)
			
			# Map layer names to clean folder names
			var folder_name = layer_name
				
			# Folder structure pattern: "res://Assets/Characters/Spritesheets/[Part][Style]/[Animation].png"
			# e.g., "res://Assets/Characters/Spritesheets/Body1/Idle.png"
			var path = "res://Assets/Char_Creation/Spritesheets/" + folder_name + style_str + "/" + anim_name + ".png"
			
			# For static layers without style folders (e.g., Shadow or unique static effects)
			if not ResourceLoader.exists(path):
				path = "res://Assets/Char_Creation/Spritesheets/" + folder_name + "/" + anim_name + ".png"
				
			if ResourceLoader.exists(path):
				var loaded_tex = load(path)
				if sprite.texture != loaded_tex:
					sprite.texture = loaded_tex
				
				# Smart Dynamic Frame Count Detection:
				# If we divide the texture height by VFRAMES (8 rows), we get the square frame height.
				# Dividing the texture width by this square frame size automatically yields the correct 
				# column count (HFrames) for ANY animation file without hardcoding sheet lengths!
				if loaded_tex:
					var frame_height = loaded_tex.get_height() / VFRAMES
					if frame_height > 0:
						sprite.hframes = loaded_tex.get_width() / frame_height
					else:
						sprite.hframes = 15 # fallback
				else:
					sprite.hframes = 15
			else:
				# Fallback if spritesheets aren't fully populated inside folder yet
				sprite.hframes = 15
				
			sprite.vframes = VFRAMES
			var col = frame_idx % sprite.hframes
			sprite.frame = row * sprite.hframes + col
