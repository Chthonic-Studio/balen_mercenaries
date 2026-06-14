class_name Player extends CharacterBody2D

@onready var _appearance: CharacterAppearanceComponent = $Appearance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func play_animation(anim_name: String, direction: String = "down") -> void:
	_appearance.play_animation(anim_name, direction)

func change_hair_color(hair_color: Color) -> void:
	_appearance.set_hair_color(hair_color)

func change_skin_tone(skin_tone: String) -> void:
	_appearance.set_skin_tone(skin_tone)

func change_eye_color(eye_color: Color) -> void:
	_appearance.set_eye_color(eye_color)

func get_appearance() -> CharacterAppearanceComponent:
	return _appearance
