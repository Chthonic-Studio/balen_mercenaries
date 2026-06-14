## TestingGrounds
## Entry point for free-play / feature testing after character creation.
## Reads player_data from GameManager (set by CharacterCreator) and applies
## it to the Player node so the chosen appearance is preserved across the
## scene transition.

extends Node2D

@onready var _player: Player = $Player

func _ready() -> void:
	if GameManager.player_data != null:
		_player.get_appearance().character_data = GameManager.player_data
	_player.play_animation("idle", "down")
