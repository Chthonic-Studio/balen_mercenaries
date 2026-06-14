## CharacterData
## Pure data resource that describes the full visual appearance of a character.
## Passed between the character creator UI, the NPC generator, and the
## CharacterAppearanceComponent that actually builds the sprites.

class_name CharacterData
extends Resource

# ---------- Identity -----------------------------------------------------

## Display name chosen by the player or assigned to an NPC.
@export var character_name: String = ""

# ---------- Body & head --------------------------------------------------

## Body type folder name (see Definitions.BODY_TYPES).
@export var body_type: String = "male"

## Skin-tone key from Definitions.SKIN_TONES; applied as a colour modulate.
@export var skin_tone: String = "medium"

## Head variant folder name (see Definitions.HEAD_TYPES).
@export var head_type: String = "male"

# ---------- Face ---------------------------------------------------------

## Hair style path relative to Spritesheets/hair/. e.g. "plain/adult"
@export var hair_style: String = "plain/adult"

## Hair colour modulate applied to all hair layers.
@export var hair_color: Color = Color.WHITE

## Beard/mustache path relative to Spritesheets/beard/, or "" for none.
## e.g. "beard/basic"  or  "mustache/handlebar"
@export var beard_style: String = ""

## Eye colour modulate applied to the eyes layer.
@export var eye_color: Color = Color.WHITE

# ---------- Equipment layers  --------------------------------------------
## Each field is a path *relative to Spritesheets/*, or "" to hide the layer.
## e.g.  torso_layer = "torso/leather/male"
##       legs_layer  = "legs/pants/male"

@export var torso_layer:     String = "torso/leather/male"
@export var legs_layer:      String = "legs/pants/male"
@export var feet_layer:      String = "feet/boots/male"
@export var arms_layer:      String = ""
@export var shoulders_layer: String = ""
@export var hat_layer:       String = ""
@export var shield_layer:    String = ""
@export var weapon_layer:    String = ""

# ---------- Helpers ------------------------------------------------------

## Returns the full sprite-sheet folder path for a given layer slot and
## animation name, e.g. get_layer_path("torso") → "res://.../torso/leather/male"
func get_layer_base_path(slot: String) -> String:
	var base := Definitions.SPRITES_BASE_PATH
	match slot:
		"body":        return base + "/body/" + body_type
		"head":        return base + "/head/" + head_type
		"eyes":        return base + "/eyes"
		"torso":       return base + "/" + torso_layer    if torso_layer     else ""
		"legs":        return base + "/" + legs_layer     if legs_layer      else ""
		"feet":        return base + "/" + feet_layer     if feet_layer      else ""
		"arms":        return base + "/" + arms_layer     if arms_layer      else ""
		"shoulders":   return base + "/" + shoulders_layer if shoulders_layer else ""
		"hat":         return base + "/" + hat_layer      if hat_layer       else ""
		"shield":      return base + "/" + shield_layer   if shield_layer    else ""
		"weapon":      return base + "/" + weapon_layer   if weapon_layer    else ""
		"beard":       return base + "/beard/" + beard_style if beard_style  else ""
		"hair_bg":     return _hair_path("bg")
		"hair_fg":     return _hair_path("fg")
		_:             return ""

func _hair_path(layer_part: String) -> String:
	if hair_style.is_empty():
		return ""
	var base := Definitions.SPRITES_BASE_PATH + "/hair/" + hair_style
	# Some hair styles have bg/fg sub-folders (long hairstyles); others don't.
	var split_path := base + "/" + layer_part
	if ResourceLoader.exists(split_path + "/idle.png"):
		return split_path
	# Fall back to the single-layer path for the fg pass
	if layer_part == "fg" and ResourceLoader.exists(base + "/idle.png"):
		return base
	return ""
