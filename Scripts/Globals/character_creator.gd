extends CanvasLayer

const BASE_PATH = "res://Assets/Char_Creation/Spritesheets/"
const TEMPLATE_SCENE = preload("res://Scenes/Units/character_template.tscn") 

# Aligned with LPC rendering order (Back to Front)
const CATEGORIES: Array[String] = [
	"shadow", "body", "eyes", "legs", "shoes", 
	"chest", "belt", "hands", "head", "bag", 
	"shield", "melee", "offhand", "ranged", "magic", 
	"effect", "slash", "special"
]

# Defines rules for generation. Empty array means "any", null means "force none"
const ARCHETYPES: Dictionary = {
	"Civilian": {
		"chest": ["clothes/shirts"],
		"legs": ["clothes/pants"],
		"head": ["hair"],
		"shield": [null], "melee": [null], "magic": [null]
	},
	"Soldier": {
		"chest": ["armor/plate", "armor/chain"],
		"legs": ["armor/plate", "armor/chain"],
		"head": ["helmets"],
		"melee": ["weapons/sword", "weapons/spear"],
		"shield": ["shields"]
	},
	"Mercenary": {
		"chest": ["armor/leather", "clothes/shirts"],
		"legs": ["armor/leather", "clothes/pants"],
		"head": ["hoods", "hair"],
		"melee": ["weapons/dagger", "weapons/sword"],
		"ranged": ["weapons/bow"]
	}
}

var available_parts: Dictionary = {}
# Structure: { category_name: { "part": "folder_path", "color": Color } }
var current_config: Dictionary = {}
var current_animation_state: String = "Idle" 

@onready var ui_panel = $UI
@onready var categories_container = $UI/HBoxContainer/ControlsContainer/ScrollContainer/Categories
@onready var preview_container = $UI/HBoxContainer/MarginContainer/PreviewContainer

var preview_instance: Node2D

func _ready() -> void:
	ui_panel.hide()
	_initialize_data_structures()
	_setup_preview_instance()
	_load_directory_data_recursive(BASE_PATH, "")
	_build_dynamic_ui()
	generate_archetype("Civilian")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			toggle_ui(!ui_panel.visible)
			get_viewport().set_input_as_handled()

# ---------------------------------------------------------
# CORE SETUP & LOGIC
# ---------------------------------------------------------

func _initialize_data_structures() -> void:
	for category in CATEGORIES:
		available_parts[category] = []
		current_config[category] = {"part": "None", "color": Color.WHITE}

func _setup_preview_instance() -> void:
	for child in preview_container.get_children():
		child.queue_free()
		
	preview_instance = TEMPLATE_SCENE.instantiate()
	preview_instance.scale = Vector2(4, 4) 
	preview_container.add_child(preview_instance)

# Scans deeply into the LPC folders
func _load_directory_data_recursive(path: String, relative_path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		push_warning("Character Creator: Missing directory at " + path)
		return
		
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not file_name.begins_with("."):
			var full_path = path + "/" + file_name
			var current_rel_path = relative_path + "/" + file_name if relative_path != "" else file_name
			
			if dir.current_is_dir():
				_load_directory_data_recursive(full_path, current_rel_path)
			else:
				if file_name.ends_with(".png"):
					_categorize_asset(current_rel_path)
		file_name = dir.get_next()

func _categorize_asset(rel_path: String) -> void:
	# rel_path example: "body/male/light.png" or "clothes/shirts/longsleeve/male/brown.png"
	# We extract the base part name and assign it to the correct category
	var path_segments = rel_path.split("/")
	
	for category in CATEGORIES:
		# If the folder path contains the category name (e.g., matches "body" or "chest")
		if rel_path.to_lower().contains(category):
			var part_identifier = rel_path.replace(".png", "") # Store full relative path without extension
			if not available_parts[category].has(part_identifier):
				available_parts[category].append(part_identifier)
			break

func _update_preview() -> void:
	for category in CATEGORIES:
		var sprite = preview_instance.get_node_or_null(category) as Sprite2D
		if not sprite: continue
			
		var config = current_config[category]
		if config["part"] != "None":
			# Append the animation state to the path. LPC typically uses one large sheet,
			# so you might just load the base texture and let an AnimationPlayer handle coordinates.
			var tex_path = BASE_PATH + config["part"] + ".png" 
			
			if ResourceLoader.exists(tex_path):
				sprite.texture = load(tex_path)
				sprite.modulate = config["color"]
			else:
				sprite.texture = null 
		else:
			sprite.texture = null

# ---------------------------------------------------------
# UI GENERATION & INTERACTION
# ---------------------------------------------------------

func _build_dynamic_ui() -> void:
	# Clear existing
	for child in categories_container.get_children():
		child.queue_free()
		
	for category in CATEGORIES:
		if available_parts[category].is_empty():
			continue 
			
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = category.capitalize()
		label.custom_minimum_size = Vector2(80, 0)
		hbox.add_child(label)
		
		var option_btn = OptionButton.new()
		option_btn.name = category + "_Btn"
		option_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_btn.add_item("None")
		available_parts[category].sort()
		
		for part in available_parts[category]:
			# Clean up the string for the UI display
			var display_name = part.get_file().capitalize()
			option_btn.add_item(display_name)
			# Store the actual path in metadata for easy retrieval
			option_btn.set_item_metadata(option_btn.get_item_count() - 1, part)
			
		option_btn.item_selected.connect(_on_part_selected.bind(category, option_btn))
		hbox.add_child(option_btn)
		
		var color_picker = ColorPickerButton.new()
		color_picker.name = category + "_Color"
		color_picker.custom_minimum_size = Vector2(30, 30)
		color_picker.color = Color.WHITE
		color_picker.color_changed.connect(_on_color_changed.bind(category))
		hbox.add_child(color_picker)
		
		categories_container.add_child(hbox)
		
	var separator = HSeparator.new()
	categories_container.add_child(separator)
		
	# Archetype Buttons
	for archetype_name in ARCHETYPES.keys():
		var arch_btn = Button.new()
		arch_btn.text = "Generate: " + archetype_name
		arch_btn.pressed.connect(generate_archetype.bind(archetype_name))
		categories_container.add_child(arch_btn)

func _on_part_selected(index: int, category: String, btn: OptionButton) -> void:
	if index == 0: # "None" is always index 0
		current_config[category]["part"] = "None"
	else:
		current_config[category]["part"] = btn.get_item_metadata(index)
	_update_preview()

func _on_color_changed(color: Color, category: String) -> void:
	current_config[category]["color"] = color
	_update_preview()

# ---------------------------------------------------------
# PUBLIC API & GENERATION
# ---------------------------------------------------------

func toggle_ui(state: bool) -> void:
	ui_panel.visible = state

func generate_archetype(archetype_name: String) -> void:
	if not ARCHETYPES.has(archetype_name): return
	var rules = ARCHETYPES[archetype_name]
	
	for category in CATEGORIES:
		var part_to_assign = "None"
		
		if rules.has(category):
			var valid_paths = rules[category]
			if valid_paths[0] == null:
				part_to_assign = "None"
			else:
				# Filter available parts based on the allowed paths in the ruleset
				var filtered_parts = []
				for part in available_parts[category]:
					for valid_path in valid_paths:
						if part.contains(valid_path):
							filtered_parts.append(part)
				
				if filtered_parts.size() > 0:
					part_to_assign = filtered_parts.pick_random()
		else:
			# If no rule exists for this category, pick completely at random or leave blank
			# Defaulting to 50% chance to have a random part if not restricted
			if available_parts[category].size() > 0 and randf() > 0.5:
				part_to_assign = available_parts[category].pick_random()
				
		current_config[category]["part"] = part_to_assign
		current_config[category]["color"] = Color(randf_range(0.5, 1.0), randf_range(0.5, 1.0), randf_range(0.5, 1.0)) # Random slight tint
		
		_sync_ui_to_config(category)
		
	_update_preview()

func _sync_ui_to_config(category: String) -> void:
	var btn = categories_container.get_node_or_null(category + "_Btn") as OptionButton
	var color_picker = categories_container.get_node_or_null(category + "_Color") as ColorPickerButton
	
	if btn:
		var target_part = current_config[category]["part"]
		if target_part == "None":
			btn.select(0)
		else:
			for i in range(btn.get_item_count()):
				if btn.get_item_metadata(i) == target_part:
					btn.select(i)
					break
					
	if color_picker:
		color_picker.color = current_config[category]["color"]

func generate_character_instance(config: Dictionary = {}) -> Node2D:
	var final_config = config
	if final_config.is_empty():
		final_config = current_config.duplicate(true)
				
	var char_node = TEMPLATE_SCENE.instantiate()
	char_node.name = "CharacterInstance"
	char_node.set_meta("equipment_config", final_config)
	
	for category in CATEGORIES:
		var sprite = char_node.get_node_or_null(category) as Sprite2D
		if sprite:
			if final_config.has(category) and final_config[category]["part"] != "None":
				var tex_path = BASE_PATH + final_config[category]["part"] + ".png"
				if ResourceLoader.exists(tex_path):
					sprite.texture = load(tex_path)
					sprite.modulate = final_config[category]["color"]
				else:
					sprite.texture = null
			else:
				sprite.texture = null
				
	return char_node
