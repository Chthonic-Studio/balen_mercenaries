## CharacterAppearanceComponent
## Composable component node that owns and drives all visual sprite layers
## for a character (player or NPC).  Attach it as a child of any
## CharacterBody2D / Node2D that needs layered LPC-style appearance.
##
## Usage:
##   1. Add as a child node.
##   2. Set character_data (CharacterData resource).
##   3. Call apply() to build all AnimatedSprite2D layers.
##   4. Call play_animation(name, direction) each frame / on state change.
##
## The component creates/destroys AnimatedSprite2D nodes as needed; it does
## NOT rely on any pre-placed sprite nodes in the scene.

class_name CharacterAppearanceComponent
extends Node

# ---------- Exports ------------------------------------------------------

@export var character_data: CharacterData:
	set(value):
		character_data = value
		if is_inside_tree():
			apply()

## Playback speed passed to SpriteLayerBuilder (fps).
@export var animation_fps: float = 8.0

## If true, (re)apply appearance as soon as the node enters the tree.
@export var apply_on_ready: bool = true

# ---------- Signals ------------------------------------------------------

## Emitted after all sprite layers have been (re)built.
signal appearance_applied

# ---------- Internal state -----------------------------------------------

## Dictionary[String, AnimatedSprite2D] — slot name → sprite node.
var _layers: Dictionary = {}

## Current animation base name (without direction suffix), e.g. "walk".
var _current_anim: String = "idle"

## Current direction suffix, e.g. "down".
var _current_dir: String = "down"

# ---------- Lifecycle ----------------------------------------------------

func _ready() -> void:
	if apply_on_ready and character_data != null:
		apply()

# ---------- Public API ---------------------------------------------------

## (Re)build all sprite layers from character_data.
## Safe to call multiple times; old layers are removed first.
func apply() -> void:
	if character_data == null:
		push_warning("CharacterAppearanceComponent: apply() called with null character_data.")
		return

	_clear_layers()

	for slot in Definitions.LAYER_ORDER:
		var base_path := character_data.get_layer_base_path(slot)
		if base_path.is_empty():
			continue

		var sprite_frames := SpriteLayerBuilder.build(base_path, animation_fps)

		# Only create the node if at least one animation was built.
		if sprite_frames.get_animation_names().is_empty():
			continue

		var sprite := AnimatedSprite2D.new()
		sprite.name = slot
		sprite.sprite_frames = sprite_frames
		_apply_modulate(sprite, slot)
		add_child(sprite)
		_layers[slot] = sprite

	# Play the current animation immediately so the character is not blank.
	_play_on_all(_current_anim + "_" + _current_dir)

	appearance_applied.emit()

## Play *anim_name* (e.g. "walk") in *direction* (e.g. "down") on every layer.
## Layers that don't have the requested animation fall back to the same
## animation in "down" direction, then to "idle_down" as a last resort.
func play_animation(anim_name: String, direction: String = "down") -> void:
	_current_anim = anim_name
	_current_dir  = direction
	_play_on_all(anim_name + "_" + direction)

## Update skin-tone modulate without rebuilding all layers.
func set_skin_tone(skin_tone: String) -> void:
	if character_data:
		character_data.skin_tone = skin_tone
	var color: Color = Definitions.SKIN_TONES.get(skin_tone, Color.WHITE)
	for slot in ["body", "head"]:
		if _layers.has(slot):
			_layers[slot].modulate = color

## Update hair colour modulate without rebuilding all layers.
func set_hair_color(color: Color) -> void:
	if character_data:
		character_data.hair_color = color
	for slot in ["hair_bg", "hair_fg"]:
		if _layers.has(slot):
			_layers[slot].modulate = color

## Update eye colour modulate without rebuilding all layers.
func set_eye_color(color: Color) -> void:
	if character_data:
		character_data.eye_color = color
	if _layers.has("eyes"):
		_layers["eyes"].modulate = color

## Returns the AnimatedSprite2D for a given slot, or null if it doesn't exist.
func get_layer(slot: String) -> AnimatedSprite2D:
	return _layers.get(slot, null)

# ---------- Internal helpers ---------------------------------------------

func _clear_layers() -> void:
	for slot in _layers.keys():
		var sprite: AnimatedSprite2D = _layers[slot]
		if is_instance_valid(sprite):
			sprite.queue_free()
	_layers.clear()

func _play_on_all(anim_key: String) -> void:
	for slot in _layers.keys():
		var sprite: AnimatedSprite2D = _layers[slot]
		if sprite.sprite_frames.has_animation(anim_key):
			sprite.play(anim_key)
		else:
			# Fallback: same anim facing down
			var fallback_down := _current_anim + "_down"
			if sprite.sprite_frames.has_animation(fallback_down):
				sprite.play(fallback_down)
			elif sprite.sprite_frames.has_animation("idle_down"):
				sprite.play("idle_down")

func _apply_modulate(sprite: AnimatedSprite2D, slot: String) -> void:
	match slot:
		"body", "head":
			sprite.modulate = Definitions.SKIN_TONES.get(
				character_data.skin_tone, Color.WHITE)
		"hair_bg", "hair_fg":
			sprite.modulate = character_data.hair_color
		"eyes":
			sprite.modulate = character_data.eye_color
