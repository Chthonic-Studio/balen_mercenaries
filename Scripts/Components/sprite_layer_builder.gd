## SpriteLayerBuilder
## Static utility that builds SpriteFrames resources at runtime from
## the split-per-animation LPC sprite sheets found under Spritesheets/.
##
## Each sheet PNG has the layout:
##   rows    = 4  (up=0, left=1, down=2, right=3)
##   columns = N  (number of frames for that animation)
##
## The resulting SpriteFrames has one named animation per direction, e.g.
##   "idle_down", "walk_left", "slash_up", …

class_name SpriteLayerBuilder
extends RefCounted

# ---------- Public API ---------------------------------------------------

## Build and return a SpriteFrames resource for all standard animations
## found inside *base_path* (a directory).  Missing PNGs are silently
## skipped so partial layers (e.g. shields that have only idle/walk)
## still work.
##
## @param base_path  Absolute res:// path to the animation folder,
##                   e.g. "res://Assets/Char_Creation/Spritesheets/body/male"
## @param fps        Playback speed (frames per second) for all animations.
static func build(base_path: String, fps: float = 8.0) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	for anim_name in Definitions.LPC_ANIMATION_FRAMES.keys():
		var png_path := base_path + "/" + anim_name + ".png"
		if not ResourceLoader.exists(png_path):
			continue

		var tex := ResourceLoader.load(png_path) as Texture2D
		if tex == null:
			continue

		var frame_count: int = Definitions.LPC_ANIMATION_FRAMES[anim_name]
		var frame_w: int = Definitions.LPC_FRAME_SIZE
		var frame_h: int = Definitions.LPC_FRAME_SIZE

		# Guard against sheets that were authored with a different resolution.
		var actual_cols: int = tex.get_width() / frame_w
		if actual_cols > 0 and actual_cols != frame_count:
			frame_count = actual_cols

		for dir_name in Definitions.LPC_DIRECTION_ROWS.keys():
			var row: int = Definitions.LPC_DIRECTION_ROWS[dir_name]
			var anim_key := anim_name + "_" + dir_name

			frames.add_animation(anim_key)
			frames.set_animation_loop(anim_key, true)
			frames.set_animation_speed(anim_key, fps)

			for col in frame_count:
				var region := Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
				var atlas := AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = region
				frames.add_frame(anim_key, atlas)

	return frames

## Convenience: build SpriteFrames for a *single* animation file.
## Useful for layers that only contain one animation (e.g. some shields).
static func build_single(png_path: String, anim_name: String, fps: float = 8.0) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	if not ResourceLoader.exists(png_path):
		return frames

	var tex := ResourceLoader.load(png_path) as Texture2D
	if tex == null:
		return frames

	var expected: int = Definitions.LPC_ANIMATION_FRAMES.get(anim_name, 1)
	var frame_w := Definitions.LPC_FRAME_SIZE
	var frame_h := Definitions.LPC_FRAME_SIZE
	var actual_cols := tex.get_width() / frame_w
	var frame_count := actual_cols if actual_cols > 0 else expected

	for dir_name in Definitions.LPC_DIRECTION_ROWS.keys():
		var row := Definitions.LPC_DIRECTION_ROWS[dir_name]
		var anim_key := anim_name + "_" + dir_name

		frames.add_animation(anim_key)
		frames.set_animation_loop(anim_key, true)
		frames.set_animation_speed(anim_key, fps)

		for col in frame_count:
			var region := Rect2(col * frame_w, row * frame_h, frame_w, frame_h)
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = region
			frames.add_frame(anim_key, atlas)

	return frames
