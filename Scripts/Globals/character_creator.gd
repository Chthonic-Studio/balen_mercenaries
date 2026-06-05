extends CanvasLayer

const BASE_PATH = "res://Assets/Char_Creation/spritesheets/"
# Preload the template scene you just aligned
const TEMPLATE_SCENE = preload("res://Scenes/Units/character_template.tscn") 

const CATEGORIES: Array[String] = [
	"Shadow", "Mount", "NakedBody", "Legs", "Shoes", 
	"Chest", "Belt", "Hands", "Head", "Bag", 
	"Shield", "Melee", "Offhand", "Ranged", "Magic", 
	"Effect", "Slash", "Special"
] 

var available_parts: Dictionary = {}
var current_config: Dictionary = {}
var current_animation_state: String = "Idle" 

@onready var ui_panel = $UI
@onready var categories_container = $UI/HBoxContainer/ControlsContainer/ScrollContainer/Categories
@onready var preview_container = $UI/HBoxContainer/MarginContainer/PreviewContainer

var preview_instance: Node2D

func _ready() -> void:
	ui_panel.hide()
	_setup_preview_instance()
	_load_directory_data()
	_build_dynamic_ui()
	randomize_character()

# ---------------------------------------------------------
# CORE SETUP & LOGIC
# ---------------------------------------------------------

func _setup_preview_instance() -> void:
	# Clear any placeholder children
	for child in preview_container.get_children():
		child.queue_free()
		
	# Instantiate your hand-aligned template for the UI
	preview_instance = TEMPLATE_SCENE.instantiate()
	preview_instance.scale = Vector2(4, 4) 
	preview_container.add_child(preview_instance)

func _load_directory_data() -> void:
	for category in CATEGORIES:
		available_parts[category] = []
		
	if DirAccess.dir_exists_absolute(BASE_PATH):
		var dir = DirAccess.open(BASE_PATH)
		dir.list_dir_begin()
		var folder_name = dir.get_next()
		
		while folder_name != "":
			if dir.current_is_dir() and not folder_name.begins_with("."):
				for category in CATEGORIES:
					if folder_name.begins_with(category):
						available_parts[category].append(folder_name)
						break
			folder_name = dir.get_next()
	else:
		push_warning("Character Creator: Missing base directory at " + BASE_PATH)

func _update_preview() -> void:
	for category in CATEGORIES:
		var sprite = preview_instance.get_node_or_null(category) as Sprite2D
		if not sprite: continue
			
		if current_config.has(category):
			var folder_name = current_config[category] 
			var tex_path = BASE_PATH + folder_name + "/" + current_animation_state + ".png"
			
			if ResourceLoader.exists(tex_path):
				sprite.texture = load(tex_path)
			else:
				sprite.texture = null 
		else:
			sprite.texture = null

# ---------------------------------------------------------
# UI GENERATION & INTERACTION
# ---------------------------------------------------------

func _build_dynamic_ui() -> void:
	for category in CATEGORIES:
		if available_parts[category].is_empty():
			continue 
			
		var vbox = VBoxContainer.new()
		
		var label = Label.new()
		label.text = category
		vbox.add_child(label)
		
		var option_btn = OptionButton.new()
		option_btn.name = category + "_Btn"
		
		option_btn.add_item("None")
		available_parts[category].sort()
		
		for part in available_parts[category]:
			option_btn.add_item(part)
			
		option_btn.item_selected.connect(_on_part_selected.bind(category, option_btn))
		vbox.add_child(option_btn)
		categories_container.add_child(vbox)
		
	var rand_btn = Button.new()
	rand_btn.text = "Randomize Character"
	rand_btn.custom_minimum_size.y = 40
	rand_btn.pressed.connect(randomize_character)
	categories_container.add_child(rand_btn)

func _on_part_selected(index: int, category: String, btn: OptionButton) -> void:
	var part_name = btn.get_item_text(index)
	if part_name == "None":
		current_config.erase(category)
	else:
		current_config[category] = part_name
	_update_preview()

# ---------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------

func toggle_ui(state: bool) -> void:
	ui_panel.visible = state

func set_preview_animation(anim_name: String) -> void:
	current_animation_state = anim_name
	_update_preview()

func randomize_character() -> void:
	for category in CATEGORIES:
		if available_parts[category].size() > 0:
			var random_part = available_parts[category].pick_random()
			current_config[category] = random_part
			
			var btn = categories_container.get_node_or_null(category + "_Btn") as OptionButton
			if btn:
				for i in range(btn.get_item_count()):
					if btn.get_item_text(i) == random_part:
						btn.select(i)
						break
	_update_preview()

## Now spawns your beautifully aligned template instead of raw nodes!
func generate_character_instance(config: Dictionary = {}) -> Node2D:
	var final_config = config
	if final_config.is_empty():
		for category in CATEGORIES:
			if available_parts[category].size() > 0:
				final_config[category] = available_parts[category].pick_random()
				
	var char_node = TEMPLATE_SCENE.instantiate()
	char_node.name = "CharacterInstance"
	char_node.set_meta("equipment_config", final_config)
	
	for category in CATEGORIES:
		var sprite = char_node.get_node_or_null(category) as Sprite2D
		if sprite:
			if final_config.has(category):
				var tex_path = BASE_PATH + final_config[category] + "/" + current_animation_state + ".png"
				if ResourceLoader.exists(tex_path):
					sprite.texture = load(tex_path)
				else:
					sprite.texture = null
			else:
				sprite.texture = null
				
	return char_node
