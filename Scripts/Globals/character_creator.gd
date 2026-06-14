extends CanvasLayer

@onready var _player : Player = $UI/Control/MarginContainer/PreviewContainer/Player
@onready var _hair_color_panel : HairPanel = $UI/Control/ControlsContainer/LeftVbox/HairPanel
@onready var _skin_tone_panel: PanelContainer = $UI/Control/ControlsContainer/LeftVbox/SkinTonePanel

func _ready() -> void:
	_hair_color_panel.changed.connect(_on_hair_color_changed)
	_skin_tone_panel.changed.connect(_on_skin_color_changed)
	
func _on_hair_color_changed(color : Color) -> void:
	_player.change_hair_color(color)

func _on_skin_color_changed(skin_tone : String) -> void:
	_player.change_skin_tone(skin_tone)
