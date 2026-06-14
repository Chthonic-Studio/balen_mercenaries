class_name SkinToneButton extends Button

var skin_tone : String

@onready var _color_rect: ColorRect = $MarginContainer/ColorRect

func _ready() -> void:
	_color_rect.color = Definitions.SKIN_TONES[skin_tone]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
