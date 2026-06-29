class_name CharacterParts
extends Object

# Lists all available options per category and their restrictions
const PART_COUNTS = {
	"NakedBody": 3,
	"Bag": 8,
	"Belt": 2,
	"Chest": 19,
	"Effect": 5,
	"Hands": 4,
	"Head": 24,
	"Legs": 9,
	"Magic": 3,
	"Melee": 25,
	"Mount": 5,
	"Offhand": 2,
	"Ranged": 7,
	"Shadow": 1,
	"Shield": 7,
	"Shoes": 5,
	"Slash": 2,
	"Special": 2
}

# Tag system to categorize parts and prevent impossible combinations
const PART_TAGS = {
	"Melee_10": ["heavy", "two-handed", "no-shield"],
	"Ranged_2": ["ranged", "two-handed", "no-shield", "no-crouch"],
	"Mount_1": ["rideable", "no-crouch", "no-die"],
	"Magic_1": ["magic", "glowing"]
}

# Checks if a given item configuration is restricted by any tag rules
static func is_compatible(part_category: String, part_id: int, animation: String) -> bool:
	var key = part_category + "_" + str(part_id)
	if PART_TAGS.has(key):
		var tags = PART_TAGS[key]
		if animation.begins_with("Crouch") and tags.has("no-crouch"):
			return false
		if animation == "Die" and tags.has("no-die"):
			return false
	return true
