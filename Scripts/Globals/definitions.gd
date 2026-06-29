extends Node

# ---------- Skin / Colour -----------------------------------------------
# Stores instantiated CharacterArchetype resources by their identifier
var archetypes: Dictionary = {}

const SKIN_TONES: Dictionary[String, Color] = {
	"porcelain": Color("ffe0bd"),
	"fair":      Color("ffcd94"),
	"light":     Color("eac086"),
	"medium":    Color("ffad60"),
	"tan":       Color("d87d00ff"),
	"brown":     Color("593123"),
	"dark":      Color("321414"),
}

func _ready() -> void:
	register_default_archetypes()

func register_default_archetypes() -> void:
	# Define a Villager archetype
	var villager = CharacterArchetype.new()
	villager.archetype_name = "Town Villager"
	villager.tag_identifiers = ["townsperson", "peaceful"]
	villager.allowed_bodies = [1, 2]
	villager.allowed_heads = [1, 2, 3, 4, 5]
	villager.allowed_chests = [1, 2, 3]
	villager.allowed_legs = [1, 2]
	villager.allowed_shoes = [1, 2]
	villager.movement_speed = 95.0
	archetypes["Villager"] = villager
	
	# Define a Bandit Outlaw archetype
	var bandit = CharacterArchetype.new()
	bandit.archetype_name = "Bandit Outlaw"
	bandit.tag_identifiers = ["hostile", "melee"]
	bandit.allowed_bodies = [2, 3]
	bandit.allowed_heads = [6, 8, 10, 11]
	bandit.allowed_chests = [4, 5, 8]
	bandit.allowed_legs = [3, 4]
	bandit.allowed_shoes = [3]
	bandit.allowed_melee = [2, 5, 8, 12]
	bandit.movement_speed = 135.0
	archetypes["Bandit"] = bandit

	# Define a Royal Guard archetype
	var guard = CharacterArchetype.new()
	guard.archetype_name = "Royal Castle Guard"
	guard.tag_identifiers = ["defender", "armored"]
	guard.allowed_bodies = [3]
	guard.allowed_heads = [12, 14, 15]
	guard.allowed_chests = [10, 12, 15]
	guard.allowed_legs = [5, 6]
	guard.allowed_shoes = [4]
	guard.allowed_melee = [15, 18, 20]
	guard.allowed_shields = [2, 3, 5]
	guard.movement_speed = 115.0
	archetypes["Guard"] = guard

func get_archetype(id: String) -> CharacterArchetype:
	if archetypes.has(id):
		return archetypes[id]
	return null
