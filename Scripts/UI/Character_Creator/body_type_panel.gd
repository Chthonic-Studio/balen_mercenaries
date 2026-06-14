## BodyTypePanel
## Allows the player to pick body type (male / female / teen / child)
## and head variant.  Emits `changed` with the updated CharacterData.

class_name BodyTypePanel extends PanelContainer

signal changed(body_type: String, head_type: String)

@onready var _body_grid: GridContainer     = $VBoxContainer/BodyGrid
@onready var _head_grid: GridContainer     = $VBoxContainer/HeadGrid

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
	for body_type in Definitions.BODY_TYPES:
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
