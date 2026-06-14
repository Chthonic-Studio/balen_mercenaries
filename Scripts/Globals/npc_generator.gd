## NpcGenerator (Autoload)
## Background service that creates CharacterData instances for NPCs.
## Can be used from any script via:
##   var data := NpcGenerator.generate(archetype_resource)
##   appearance_component.character_data = data
##
## All randomisation is constrained by a CharacterArchetype resource,
## which lists which equipment folders are valid for each slot.

extends Node

# Prefix used when no archetype is supplied.
const _FALLBACK_TORSO_MALE:   Array[String] = ["torso/leather/male",   "torso/chainmail/male",  "torso/plate/male"]
const _FALLBACK_TORSO_FEMALE: Array[String] = ["torso/leather/female", "torso/chainmail/female", "torso/plate/female"]
const _FALLBACK_LEGS_MALE:    Array[String] = ["legs/pants/male", "legs/plate/male"]
const _FALLBACK_LEGS_THIN:    Array[String] = ["legs/pants/thin", "legs/plate/thin"]

# ---------- Public API ---------------------------------------------------

## Generate a CharacterData for an NPC.
## @param archetype  Optional CharacterArchetype resource.  When null a
##                   generic civilian appearance is produced.
## @param rng        Optional RandomNumberGenerator for reproducible results.
func generate(archetype: CharacterArchetype = null,
			  rng: RandomNumberGenerator = null) -> CharacterData:
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()

	var data := CharacterData.new()

	# --- Body & head ---
	var is_female: bool = rng.randi() % 2 == 0
	data.body_type = "female" if is_female else "male"
	data.head_type = "female" if is_female else "male"
	data.skin_tone = _pick(Definitions.SKIN_TONES.keys(), rng)

	# --- Hair ---
	var hair_options := _collect_hair_options()
	if not hair_options.is_empty():
		data.hair_style = _pick(hair_options, rng)
	data.hair_color = _random_hair_color(rng)

	# --- Beard (male only, ~50% chance) ---
	if not is_female and rng.randi_range(0, 1) == 1:
		var beard_options := _collect_beard_options()
		if not beard_options.is_empty():
			data.beard_style = _pick(beard_options, rng)

	# --- Eye colour ---
	data.eye_color = _random_eye_color(rng)

	# --- Equipment from archetype ---
	var use_thin: bool = (data.body_type == "female")

	if archetype != null:
		data.torso_layer     = _pick_or_empty(archetype.get_allowed_paths("chest",   is_female), rng)
		data.legs_layer      = _pick_or_empty(archetype.get_allowed_paths("legs",    is_female), rng)
		data.hat_layer       = _pick_or_empty(archetype.get_allowed_paths("head",    is_female), rng)
		data.weapon_layer    = _pick_or_empty(archetype.get_allowed_paths("melee",   is_female), rng)
		data.shield_layer    = _pick_or_empty(archetype.get_allowed_paths("shield",  is_female), rng)
		data.arms_layer      = _pick_or_empty(archetype.get_allowed_paths("arms",    is_female), rng)
		data.shoulders_layer = _pick_or_empty(archetype.get_allowed_paths("shoulders", is_female), rng)
	else:
		# Generic civilian – light clothing, no weapons.
		var torso_pool := _FALLBACK_TORSO_FEMALE if is_female else _FALLBACK_TORSO_MALE
		var legs_pool  := _FALLBACK_LEGS_THIN    if use_thin  else _FALLBACK_LEGS_MALE
		data.torso_layer = _pick(torso_pool, rng)
		data.legs_layer  = _pick(legs_pool,  rng)

	# Feet – pick a valid variant for the body type
	var feet_variant := "thin" if use_thin else "male"
	var feet_options := _collect_feet_options(feet_variant)
	if not feet_options.is_empty():
		data.feet_layer = _pick(feet_options, rng)

	return data

## Apply a CharacterData to a node that has a CharacterAppearanceComponent child.
## Returns true on success.
func apply_to_character(character_node: Node, data: CharacterData) -> bool:
	var comp := character_node.get_node_or_null("CharacterAppearanceComponent") as CharacterAppearanceComponent
	if comp == null:
		push_error("NpcGenerator.apply_to_character: node '%s' has no CharacterAppearanceComponent child." % character_node.name)
		return false
	comp.character_data = data
	return true

# ---------- Internal helpers ---------------------------------------------

func _pick(arr: Array, rng: RandomNumberGenerator) -> String:
	if arr.is_empty():
		return ""
	return arr[rng.randi() % arr.size()]

func _pick_or_empty(arr: Array[String], rng: RandomNumberGenerator) -> String:
	if arr.is_empty():
		return ""
	return arr[rng.randi() % arr.size()]

func _collect_hair_options() -> Array[String]:
	## Returns paths relative to Spritesheets/hair/ for styles that have idle.
	var results: Array[String] = []
	var hair_base := Definitions.SPRITES_BASE_PATH + "/hair"
	_scan_for_idle_dirs(hair_base, hair_base, results, 3)
	return results

func _collect_beard_options() -> Array[String]:
	var results: Array[String] = []
	var beard_base := Definitions.SPRITES_BASE_PATH + "/beard"
	_scan_for_idle_dirs(beard_base, beard_base, results, 3)
	return results

func _collect_feet_options(variant: String) -> Array[String]:
	var results: Array[String] = []
	var base := Definitions.SPRITES_BASE_PATH + "/feet"
	var variant_suffix := "/" + variant
	for category in ["boots", "sandals", "shoes", "plate"]:
		var path := base + "/" + category + variant_suffix
		if ResourceLoader.exists(path + "/idle.png"):
			results.append("feet/" + category + variant_suffix)
		elif ResourceLoader.exists(path + "/idle/"):
			results.append("feet/" + category + variant_suffix)
	return results

## Recursively scans *dir_path* up to *max_depth* levels, collecting
## sub-paths (relative to *base*) that contain an idle.png file.
func _scan_for_idle_dirs(base: String, dir_path: String,
						  results: Array[String], max_depth: int) -> void:
	if max_depth <= 0:
		return
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var full := dir_path + "/" + entry
		if dir.current_is_dir():
			if ResourceLoader.exists(full + "/idle.png"):
				results.append(full.trim_prefix(base + "/"))
			else:
				_scan_for_idle_dirs(base, full, results, max_depth - 1)
		entry = dir.get_next()
	dir.list_dir_end()

func _random_hair_color(rng: RandomNumberGenerator) -> Color:
	const HAIR_COLORS := [
		Color("1a0a00"), Color("3b1f0d"), Color("5c3317"),
		Color("8b4513"), Color("c68642"), Color("e8c07a"),
		Color("f5f5dc"), Color("8b0000"), Color("ff4500"),
		Color("4b0082"), Color("800080"), Color("00008b"),
		Color("696969"), Color("d3d3d3"), Color("ffffff"),
	]
	return HAIR_COLORS[rng.randi() % HAIR_COLORS.size()]

func _random_eye_color(rng: RandomNumberGenerator) -> Color:
	const EYE_COLORS := [
		Color("3b2002"), Color("2e5090"), Color("2d7d46"),
		Color("8b6914"), Color("808080"), Color("4b0082"),
	]
	return EYE_COLORS[rng.randi() % EYE_COLORS.size()]
