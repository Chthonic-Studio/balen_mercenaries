class_name CharacterCreationSystem
extends Control

signal character_completed(config: Dictionary)

@export_file("*.tscn") var gameplay_scene_path: String = "res://Main.tscn"

@onready var preview_visuals: CharacterVisuals = $HBoxContainer/PreviewContainer/SubViewportContainer/SubViewport/CharacterVisuals
@onready var category_list: ItemList = $HBoxContainer/EditorPanel/TabContainer/Equipment/CategoryList
@onready var option_list: ItemList = $HBoxContainer/EditorPanel/TabContainer/Equipment/OptionList
@onready var skin_picker: ColorPickerButton = $HBoxContainer/EditorPanel/TabContainer/Colors/SkinColor
@onready var hair_picker: ColorPickerButton = $HBoxContainer/EditorPanel/TabContainer/Colors/HairColor
@onready var chest_picker: ColorPickerButton = $HBoxContainer/EditorPanel/TabContainer/Colors/ChestColor

# Archetype Blending Selector Nodes
@onready var archetype_dropdown: OptionButton = $HBoxContainer/EditorPanel/TabContainer/Archetypes/ArchetypeOption
@onready var override_head_btn: CheckButton = $HBoxContainer/EditorPanel/TabContainer/Archetypes/OverrideHeadBtn
@onready var override_chest_btn: CheckButton = $HBoxContainer/EditorPanel/TabContainer/Archetypes/OverrideChestBtn

var active_category: String = "NakedBody"
var active_archetype_id: String = "none"

# Continuous preview animation loop properties
var current_frame: int = 0
var anim_timer: float = 0.0

# Tracks whether a part is manually custom-override or uses the archetype default rules
var custom_override_flags: Dictionary = {
	"Head": false,
	"Chest": false,
	"Legs": false,
	"Shoes": false,
	"Melee": false,
	"Shield": false,
	"Mount": false
}

var active_config: Dictionary = {
	"NakedBody": 1, "Head": 1, "Chest": 1, "Legs": 1, "Shoes": 1,
	"Melee": 0, "Shield": 0, "Mount": 0, "Shadow": true,
	"Bag": 0, "Belt": 0, "Effect": 0, "Hands": 0, "Magic": 0,
	"Offhand": 0, "Ranged": 0, "Slash": 0, "Special": 0,
	"skin_color": Color.WHITE, "hair_color": Color.WHITE, "chest_color": Color.WHITE
}

func _ready() -> void:
	# Populate visual category list from schema
	for cat in CharacterParts.PART_COUNTS.keys():
		category_list.add_item(cat)
	category_list.select(0)
	_on_category_selected(0)
	
	# Populate Archetype list
	archetype_dropdown.clear()
	archetype_dropdown.add_item("None (Pure Custom Character)")
	archetype_dropdown.set_item_metadata(0, "none")
	
	var idx = 1
	for arch_key in Definitions.archetypes.keys():
		var arch = Definitions.get_archetype(arch_key)
		archetype_dropdown.add_item("Blend with: " + arch.archetype_name)
		archetype_dropdown.set_item_metadata(idx, arch_key)
		idx += 1
		
	# Connect internal event handlers
	category_list.item_selected.connect(_on_category_selected)
	option_list.item_selected.connect(_on_option_selected)
	skin_picker.color_changed.connect(func(col): 
		active_config["skin_color"] = col
		apply_render()
	)
	hair_picker.color_changed.connect(func(col):
		active_config["hair_color"] = col
		apply_render()
	)
	chest_picker.color_changed.connect(func(col):
		active_config["chest_color"] = col
		apply_render()
	)
	
	# Connect archetype dropdown and checkboxes
	archetype_dropdown.item_selected.connect(_on_archetype_selected)
	override_head_btn.toggled.connect(func(toggled):
		custom_override_flags["Head"] = toggled
		apply_render()
	)
	override_chest_btn.toggled.connect(func(toggled):
		custom_override_flags["Chest"] = toggled
		apply_render()
	)
	
	$HBoxContainer/EditorPanel/Actions/RandomizeButton.pressed.connect(randomize_visuals)
	$HBoxContainer/EditorPanel/Actions/SaveButton.pressed.connect(export_json_config)
	if $HBoxContainer/EditorPanel/Actions.has_node("PlayButton"):
		$HBoxContainer/EditorPanel/Actions/PlayButton.pressed.connect(_on_play_pressed)
	
	apply_render()

func _process(delta: float) -> void:
	# Tick preview frame timer to animate the idle character in the viewport
	anim_timer += delta
	if anim_timer >= 0.08: # ~12 FPS
		anim_timer = 0.0
		current_frame = (current_frame + 1) % 15
		apply_render()

func _on_play_pressed() -> void:
	# Automatically export configured data to global singleton and files first
	export_json_config()
	
	# Navigate seamlessly to your game scene
	if gameplay_scene_path != "" and ResourceLoader.exists(gameplay_scene_path):
		get_tree().change_scene_to_file(gameplay_scene_path)
		print("Transitioning to gameplay scene: ", gameplay_scene_path)
	else:
		push_warning("Configured gameplay scene not found: " + gameplay_scene_path + ". Attempting fallback res://Main.tscn")
		if ResourceLoader.exists("res://Main.tscn"):
			get_tree().change_scene_to_file("res://Main.tscn")
		else:
			push_error("Could not find any gameplay scene to load!")

func _on_archetype_selected(item_idx: int) -> void:
	active_archetype_id = archetype_dropdown.get_item_metadata(item_idx)
	apply_render()

func _on_category_selected(idx: int) -> void:
	active_category = category_list.get_item_text(idx)
	option_list.clear()
	
	# Option zero (None) for everything except core body
	if active_category != "NakedBody":
		option_list.add_item("None")
		option_list.set_item_metadata(0, 0)
		
	var max_items = CharacterParts.PART_COUNTS.get(active_category, 0)
	for i in range(1, max_items + 1):
		var item_label = active_category + " Style " + str(i)
		option_list.add_item(item_label)
		var item_idx = option_list.get_item_count() - 1
		option_list.set_item_metadata(item_idx, i)
		
		# Validate system tags incompatibility
		if not CharacterParts.is_compatible(active_category, i, "Idle"):
			option_list.set_item_disabled(item_idx, true)
			option_list.set_item_text(item_idx, item_label + " (Restricted)")

func _on_option_selected(idx: int) -> void:
	var value = option_list.get_item_metadata(idx)
	active_config[active_category] = value
	
	# If we modify a category manually, auto-mark it as overridden
	if custom_override_flags.has(active_category):
		custom_override_flags[active_category] = true
		if active_category == "Head":
			override_head_btn.button_pressed = true
		elif active_category == "Chest":
			override_chest_btn.button_pressed = true
			
	apply_render()

func randomize_visuals() -> void:
	for cat in CharacterParts.PART_COUNTS.keys():
		var count = CharacterParts.PART_COUNTS[cat]
		var roll = randi() % (count + 1)
		if cat == "NakedBody" and roll == 0:
			roll = 1
		if CharacterParts.is_compatible(cat, roll, "Idle"):
			active_config[cat] = roll
			
	active_config["skin_color"] = Color(randf(), randf(), randf())
	active_config["hair_color"] = Color(randf(), randf(), randf())
	active_config["chest_color"] = Color(randf(), randf(), randf())
	
	# Apply and sync picker widgets
	skin_picker.color = active_config["skin_color"]
	hair_picker.color = active_config["hair_color"]
	chest_picker.color = active_config["chest_color"]
	apply_render()

func apply_render() -> void:
	var final_config = active_config.duplicate()
	
	# Blending engine integration:
	# If an archetype is selected, we query its resource to resolve overrides vs defaults
	if active_archetype_id != "none":
		var arch = Definitions.get_archetype(active_archetype_id)
		if arch:
			final_config = arch.resolve_character_config(active_config, custom_override_flags)
			
	preview_visuals.apply_configuration(final_config)
	
	# Continuously play Idle animation in character creator preview
	preview_visuals.play_animation("Idle", CharacterVisuals.Direction.DOWN, current_frame)
	
	# Apply custom modulates dynamically
	if preview_visuals.layers.has("Body"):
		preview_visuals.layers["Body"].self_modulate = active_config.get("skin_color", Color.WHITE)
	if preview_visuals.layers.has("Head"):
		preview_visuals.layers["Head"].self_modulate = active_config.get("hair_color", Color.WHITE)
	if preview_visuals.layers.has("Chest"):
		preview_visuals.layers["Chest"].self_modulate = active_config.get("chest_color", Color.WHITE)

func export_json_config() -> void:
	var out_path = "user://character_creation_preset.json"
	var file = FileAccess.open(out_path, FileAccess.WRITE)
	if file:
		var export_data = active_config.duplicate()
		export_data["skin_color"] = active_config["skin_color"].to_html()
		export_data["hair_color"] = active_config["hair_color"].to_html()
		export_data["chest_color"] = active_config["chest_color"].to_html()
		export_data["archetype_id"] = active_archetype_id
		export_data["overrides"] = custom_override_flags
		file.store_string(JSON.stringify(export_data, "  "))
		file.close()
		
		# Persist configured data inside the global GameManager for automatic instantiations
		if has_node("/root/GameManager"):
			var game_manager = get_node("/root/GameManager")
			if game_manager and "player_visuals" in game_manager:
				game_manager.player_visuals = export_data
				print("Successfully stored customized player visuals inside GameManager global.")
				
		character_completed.emit(active_config)
		print("Custom character template successfully written to: ", out_path)
