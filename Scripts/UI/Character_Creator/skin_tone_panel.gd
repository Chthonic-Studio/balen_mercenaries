class_name SkinTonePanel extends PanelContainer

signal changed(skin_tone : String )

@onready var _grid_container: GridContainer = $VBoxContainer/GridContainer

var skin_tone_button_scene : PackedScene = preload("res://Scenes/Units/UI/skin_tone_button.tscn")
var skin_tone_buttons : Dictionary[String, SkinToneButton] = {}
var _current_skin_tone : String

func _ready() -> void:
	_create_buttons()

func _create_buttons() -> void:
	var skin_tones : Array = Definitions.SKIN_TONES.keys()
	
	for skin_tone in skin_tones:
		var skin_tone_button : SkinToneButton = skin_tone_button_scene.instantiate()
		
		skin_tone_button.skin_tone = skin_tone
		skin_tone_button.pressed.connect(_on_skin_tone_button_pressed.bind(skin_tone))
		
		_grid_container.add_child(skin_tone_button)
		skin_tone_buttons[skin_tone] = skin_tone_button

func _on_skin_tone_button_pressed(skin_tone : String) -> void:
	_current_skin_tone = skin_tone
	changed.emit(skin_tone)

func _process(delta: float) -> void:
	pass
