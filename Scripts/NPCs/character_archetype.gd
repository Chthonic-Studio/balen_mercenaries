class_name CharacterArchetype
extends Resource

@export var archetype_name: String = "New Archetype"
# Use multiline strings or arrays of strings to define allowed folder paths relative to BASE_PATH
# Example: ["clothes/shirts/longsleeve", "clothes/shirts/basic"]
@export var allowed_chest_male: Array[String] = []
@export var allowed_chest_female: Array[String] = []
@export var allowed_legs_male: Array[String] = []
@export var allowed_legs_female: Array[String] = []
@export var allowed_head: Array[String] = [] # Usually gender-neutral (helmets/hats)
@export var allowed_hair_male: Array[String] = []
@export var allowed_hair_female: Array[String] = []
@export var allowed_melee: Array[String] = []
@export var allowed_ranged: Array[String] = []
@export var allowed_shields: Array[String] = []

func get_allowed_paths(category: String, is_female: bool) -> Array[String]:
	match category.to_lower():
		"chest": return allowed_chest_female if is_female else allowed_chest_male
		"legs": return allowed_legs_female if is_female else allowed_legs_male
		"head": return allowed_head
		"hair": return allowed_hair_female if is_female else allowed_hair_male
		"melee": return allowed_melee
		"ranged": return allowed_ranged
		"shield": return allowed_shields
		_: return [] # Empty means no restrictions for this archetype
