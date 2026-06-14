## CharacterCreator
## Drives the player-facing visual character creation screen.
## Receives signals from the UI panels, updates CharacterData live, and
## transitions to the testing grounds when the player confirms.

extends CanvasLayer

@onready var _player:            Player          = $UI/Control/MarginContainer/PreviewContainer/Player
@onready var _hair_color_panel:  HairPanel       = $UI/Control/ControlsContainer/ScrollContainer/LeftVbox/HairPanel
@onready var _skin_tone_panel:   SkinTonePanel   = $UI/Control/ControlsContainer/ScrollContainer/LeftVbox/SkinTonePanel
@onready var _hair_style_panel:  HairStylePanel  = $UI/Control/ControlsContainer/ScrollContainer/LeftVbox/HairStylePanel
@onready var _body_type_panel:   BodyTypePanel   = $UI/Control/ControlsContainer/ScrollContainer/LeftVbox/BodyTypePanel
@onready var _name_input:        LineEdit        = $UI/Control/ControlsContainer/NameInput
@onready var _confirm_btn:       Button          = $UI/Control/ControlsContainer/ConfirmButton

## Holds all current player choices; updated live as the player adjusts sliders.
var player_data: CharacterData

func _ready() -> void:
	await get_tree().process_frame

	player_data = CharacterData.new()
	_player.get_appearance().character_data = player_data

	_hair_color_panel.changed.connect(_on_hair_color_changed)
	_skin_tone_panel.changed.connect(_on_skin_tone_changed)
	_hair_style_panel.changed.connect(_on_hair_style_changed)
	_body_type_panel.changed.connect(_on_body_type_changed)
	_confirm_btn.pressed.connect(_on_confirm_pressed)

# ---------- Panel callbacks ----------------------------------------------

func _on_hair_color_changed(color: Color) -> void:
	_player.change_hair_color(color)

func _on_skin_tone_changed(skin_tone: String) -> void:
	_player.change_skin_tone(skin_tone)

func _on_hair_style_changed(hair_style: String) -> void:
	player_data.hair_style = hair_style
	_player.get_appearance().apply()

func _on_body_type_changed(body_type: String, head_type: String) -> void:
	player_data.body_type = body_type
	player_data.head_type = head_type
	# Adjust equipment defaults when body type changes.
	var is_thin := body_type == "female"
	player_data.torso_layer = "torso/leather/female" if is_thin else "torso/leather/male"
	player_data.legs_layer  = "legs/pants/thin"      if is_thin else "legs/pants/male"
	player_data.feet_layer  = "feet/boots/thin"      if is_thin else "feet/boots/male"
	_player.get_appearance().apply()

func _on_confirm_pressed() -> void:
	player_data.character_name = _name_input.text.strip_edges()
	GameManager.player_data = player_data
	get_tree().change_scene_to_file("res://Scenes/Debug/testing_grounds.tscn")
