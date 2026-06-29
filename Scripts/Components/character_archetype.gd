class_name CharacterArchetype
extends Resource

@export var archetype_name: String = "Generic NPC"
@export var tag_identifiers: Array = []

# Allowed option indices for random modular generation
@export var allowed_bodies: Array = [1, 2, 3]
@export var allowed_heads: Array = [0, 1, 2, 3, 4]
@export var allowed_chests: Array = [1, 2, 3]
@export var allowed_legs: Array = [1, 2]
@export var allowed_shoes: Array = [1, 2]
@export var allowed_melee: Array = [0] 
@export var allowed_shields: Array = [0]
@export var allowed_mounts: Array = [0]

# Speed modifiers for this specific archetype
@export var movement_speed: float = 120.0

# Archetype Blending Engine:
# Resolves final character appearance by honoring specific manual overrides
# and defaulting unspecified / non-overridden parts to the archetype's ruleset!
func resolve_character_config(customized_parts: Dictionary, custom_override_flags: Dictionary) -> Dictionary:
	randomize()
	var final_config = customized_parts.duplicate()
	
	# Check each visual category. If NOT custom overridden (flag is false),
	# we pull randomly from the archetype's allowed ruleset.
	if not custom_override_flags.get("Head", false) and allowed_heads.size() > 0:
		final_config["Head"] = allowed_heads[randi() % allowed_heads.size()]
		
	if not custom_override_flags.get("Chest", false) and allowed_chests.size() > 0:
		final_config["Chest"] = allowed_chests[randi() % allowed_chests.size()]
		
	if not custom_override_flags.get("Legs", false) and allowed_legs.size() > 0:
		final_config["Legs"] = allowed_legs[randi() % allowed_legs.size()]
		
	if not custom_override_flags.get("Shoes", false) and allowed_shoes.size() > 0:
		final_config["Shoes"] = allowed_shoes[randi() % allowed_shoes.size()]
		
	if not custom_override_flags.get("Melee", false) and allowed_melee.size() > 0:
		final_config["Melee"] = allowed_melee[randi() % allowed_melee.size()]
		
	if not custom_override_flags.get("Shield", false) and allowed_shields.size() > 0:
		final_config["Shield"] = allowed_shields[randi() % allowed_shields.size()]
		
	if not custom_override_flags.get("Mount", false) and allowed_mounts.size() > 0:
		final_config["Mount"] = allowed_mounts[randi() % allowed_mounts.size()]
		
	return final_config

# Generates a fully randomized configuration matching archetype constraints
func roll_character_config() -> Dictionary:
	var mock_flags = {
		"Head": false, "Chest": false, "Legs": false, "Shoes": false,
		"Melee": false, "Shield": false, "Mount": false
	}
	var empty_parts = {
		"NakedBody": allowed_bodies[randi() % allowed_bodies.size()] if allowed_bodies.size() > 0 else 1,
		"Head": 0, "Chest": 0, "Legs": 0, "Shoes": 0, "Melee": 0, "Shield": 0, "Mount": 0,
		"Shadow": true, "Bag": 0, "Belt": 0, "Effect": 0, "Hands": 0, "Magic": 0,
		"Offhand": 0, "Ranged": 0, "Slash": 0, "Special": 0
	}
	return resolve_character_config(empty_parts, mock_flags)
