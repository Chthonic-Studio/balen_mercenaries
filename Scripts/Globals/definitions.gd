extends Node

# ---------- Skin / Colour -----------------------------------------------

const SKIN_TONES: Dictionary[String, Color] = {
	"porcelain": Color("ffe0bd"),
	"fair":      Color("ffcd94"),
	"light":     Color("eac086"),
	"medium":    Color("ffad60"),
	"tan":       Color("d87d00ff"),
	"brown":     Color("593123"),
	"dark":      Color("321414"),
}

# ---------- LPC Spritesheet constants -----------------------------------

## Pixel size of a single frame in the standard LPC character sheets.
const LPC_FRAME_SIZE: int = 64

## Sprite sheet base path (relative to res://)
const SPRITES_BASE_PATH: String = "res://Assets/Char_Creation/Spritesheets"

## Animation names present in the split-per-animation LPC sheets.
## Each name maps to the expected number of frames per direction row.
## The sheet has 4 rows: up (0), left (1), down (2), right (3).
const LPC_ANIMATION_FRAMES: Dictionary[String, int] = {
	"spellcast":   7,
	"thrust":      8,
	"walk":        9,
	"slash":       6,
	"shoot":      13,
	"hurt":        6,
	"idle":        2,
	"run":         8,
	"climb":       6,
	"jump":        5,
	"sit":         3,
	"emote":       3,
	"combat_idle": 2,
	"backslash":   6,
	"halfslash":   6,
}

## Direction row indices inside each LPC animation sheet (top→bottom).
const LPC_DIRECTION_ROWS: Dictionary[String, int] = {
	"up":    0,
	"left":  1,
	"down":  2,
	"right": 3,
}

## Ordered list of layer names drawn back-to-front on a character.
## A layer name of "" means that slot is disabled for a given character.
const LAYER_ORDER: Array[String] = [
	"body",
	"head",
	"eyes",
	"torso",
	"legs",
	"feet",
	"arms",
	"shoulders",
	"beard",
	"hair_bg",   # background hair layer (long styles with bg/fg split)
	"hat",
	"hair_fg",   # foreground hair layer
	"shield",
	"weapon",
]

# ---------- Available body types ----------------------------------------

## Body types that have a complete animation set (have idle + walk at minimum).
const BODY_TYPES: Array[String] = [
	"male",
	"female",
	"teen",
	"child",
]

## Head type variants (must match folder names under head/).
const HEAD_TYPES: Array[String] = [
	"male",
	"female",
	"male_small",
	"female_small",
	"male_elderly",
	"female_elderly",
	"male_plump",
	"male_gaunt",
	"elderly_small",
	"child",
	"zombie",
	"skeleton",
]
