class_name HairPanel extends PanelContainer

signal changed(color: Color)

@onready var _color_picker : ColorPicker = $VBoxContainer/ColorPicker

func _ready() -> void:
	_color_picker.color_changed.connect(_on_color_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_color_changed(color : Color) -> void:
	changed.emit(color)
