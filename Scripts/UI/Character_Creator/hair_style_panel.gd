## HairStylePanel
## Lets the player scroll through available hair styles.
## Scans the Spritesheets/hair directory at runtime for all styles that
## contain an idle animation.  Emits `changed(style_path)` where
## style_path is relative to Spritesheets/hair/.

class_name HairStylePanel extends PanelContainer

signal changed(hair_style: String)

@onready var _list: ItemList = $VBoxContainer/ItemList

var _styles: Array[String] = []

func _ready() -> void:
	_styles = _collect_styles()
	for style in _styles:
		_list.add_item(style.replace("/", "  /  "))
	if not _styles.is_empty():
		_list.select(0)
	_list.item_selected.connect(_on_item_selected)

func _collect_styles() -> Array[String]:
	var results: Array[String] = []
	var base := Definitions.SPRITES_BASE_PATH + "/hair"
	_scan(base, base, results, 3)
	results.sort()
	return results

func _scan(base: String, dir_path: String,
		   results: Array[String], depth: int) -> void:
	if depth <= 0:
		return
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not entry.begins_with("."):
			var full := dir_path + "/" + entry
			if dir.current_is_dir():
				if ResourceLoader.exists(full + "/idle.png"):
					results.append(full.trim_prefix(base + "/"))
				else:
					_scan(base, full, results, depth - 1)
		entry = dir.get_next()
	dir.list_dir_end()

func _on_item_selected(index: int) -> void:
	if index >= 0 and index < _styles.size():
		changed.emit(_styles[index])
