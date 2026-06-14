## BodyTypePanel
## Allows the player to pick body type and head variant.
## Emits `changed` with the new body_type and head_type strings.
##
## Set `allowed_body_types` before the node is ready (e.g. as a scene
## property override) to restrict which body type buttons are shown.
## An empty array falls back to all entries in Definitions.BODY_TYPES.

class_name BodyTypePanel extends PanelContainer

signal changed(body_type: String, head_type: String)

@onready var _body_grid: GridContainer     = $VBoxContainer/BodyGrid
@onready var _head_grid: GridContainer     = $VBoxContainer/HeadGrid

## Optional allowlist of body types to display. Empty = show all.
@export var allowed_body_types: PackedStringArray = []

var _selected_body: String = "male"
var _selected_head: String = "male"

const _HEAD_FOR_BODY: Dictionary = {
	"male":   "male",
	"female": "female",
	"teen":   "male",
	"child":  "child",
}

func _ready() -> void:
	_build_body_buttons()
	_build_head_buttons()

func _build_body_buttons() -> void:
	for child in _body_grid.get_children():
		child.queue_free()
	var types: Array = allowed_body_types if not allowed_body_types.is_empty() \
			else Definitions.BODY_TYPES
	# Keep _selected_body valid within the allowed set.
	if not types.has(_selected_body):
		_selected_body = types[0] if not types.is_empty() else "male"
	for body_type in types:
		var btn := Button.new()
		btn.text = body_type.capitalize()
		btn.toggle_mode = true
		btn.button_pressed = (body_type == _selected_body)
		btn.pressed.connect(_on_body_selected.bind(body_type))
		_body_grid.add_child(btn)

func _build_head_buttons() -> void:
	for head_type in Definitions.HEAD_TYPES:
		var btn := Button.new()
		btn.text = head_type.replace("_", " ").capitalize()
		btn.toggle_mode = true
		btn.button_pressed = (head_type == _selected_head)
		btn.pressed.connect(_on_head_selected.bind(head_type))
		_head_grid.add_child(btn)

func _on_body_selected(body_type: String) -> void:
	_selected_body = body_type
	# Auto-match head to body type as a sensible default.
	_selected_head = _HEAD_FOR_BODY.get(body_type, "male")
	changed.emit(_selected_body, _selected_head)

func _on_head_selected(head_type: String) -> void:
	_selected_head = head_type
	changed.emit(_selected_body, _selected_head)
