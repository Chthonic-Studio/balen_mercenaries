class_name Player extends CharacterBody2D

@onready var body: AnimatedSprite2D = $Skeleton/Body
@onready var torso: AnimatedSprite2D = $Skeleton/Torso
@onready var head: AnimatedSprite2D = $Skeleton/Head
@onready var hair: AnimatedSprite2D = $Skeleton/Hair
@onready var eyes: AnimatedSprite2D = $Skeleton/Eyes
@onready var weapon: AnimatedSprite2D = $Skeleton/Weapon

var _sprites : Array[AnimatedSprite2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_sprites = [ body, torso, head, hair, eyes, weapon ]
	_play_animation("idle_down")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _play_animation( animation : String ) -> void:
	for sprite in _sprites:
		sprite.play(animation)

func change_hair_color(hair_color : Color ) -> void:
	hair.modulate = hair_color

func change_skin_tone(skin_tone : String) -> void:
	body.modulate = Definitions.SKIN_TONES[skin_tone]
	head.modulate = Definitions.SKIN_TONES[skin_tone]
