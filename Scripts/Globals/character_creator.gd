## CharacterCreator (Autoload CanvasLayer)
## Drives the player-facing visual character creation screen.
## Receives signals from the UI panels, updates CharacterData, then tells
## the CharacterAppearanceComponent on the preview player to rebuild.

extends CanvasLayer

@onready var _player:            Player          = $UI/Control/MarginContainer/PreviewContainer/Player
@onready var _hair_color_panel:  HairPanel       = $UI/Control/ControlsContainer/LeftVbox/HairPanel
@onready var _skin_tone_panel:   SkinTonePanel   = $UI/Control/ControlsContainer/LeftVbox/SkinTonePanel
@onready var _hair_style_panel:  HairStylePanel  = $UI/Control/ControlsContainer/LeftVbox/HairStylePanel
@onready var _body_type_panel:   BodyTypePanel   = $UI/Control/ControlsContainer/LeftVbox/BodyTypePanel

## Holds all current player choices; updated live as the player adjusts sliders.
var player_data: CharacterData

func _ready() -> void:
	player_data = CharacterData.new()
	_player.get_appearance().character_data = player_data

	_hair_color_panel.changed.connect(_on_hair_color_changed)
	_skin_tone_panel.changed.connect(_on_skin_tone_changed)
	_hair_style_panel.changed.connect(_on_hair_style_changed)
	_body_type_panel.changed.connect(_on_body_type_changed)

## Call to toggle the creator UI.
func toggle_ui(show: bool) -> void:
	visible = show

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_creator"):
		toggle_ui(not visible)

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

