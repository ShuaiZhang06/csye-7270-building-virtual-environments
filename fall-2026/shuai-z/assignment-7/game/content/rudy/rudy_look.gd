class_name RudyLook
extends Node2D
## Rudy's generated frames (ASSET-LOG.md), one per pose asset ID in
## CHARACTER-SHEET.md, made by design/tools/matte_sprites.py into frames/.
## Every frame shares one canvas with the body origin (his soles, on the
## torso's centre line) at the same texture px, and is stored at 2 texture px
## per game px; the Sprite child draws it at half scale with that origin on
## this node's, as frames.json says. The controller flips this node to face
## left and fades it while he flashes. The Sprite's material adds the outer
## outline (systems/art/outline.gdshader), and it draws with mipmaps so the
## hair's fine lines do not shimmer at half scale.
## The sword form's frames show the sword and shield he holds, so nothing is
## drawn over them. CHAR-SWORD-BLOCK waits for blocking (build step 4).
##
## The Sprite draws the 16 frames from one sheet, sheet/rudy_sheet.png (4 x 4
## cells, in frames.json's order: CELLS). Its AnimationPlayer is the only
## writer of the Sprite's frame: this script plays the clip the controller
## picks and never sets the Sprite's texture or frame (CHANGE-BRIEF.md
## section 5). The pose on screen is read back from the cell the Sprite shows.

const FRAMES: Dictionary[StringName, Texture2D] = {
	&"CHAR-IDLE": preload("res://content/rudy/frames/CHAR-IDLE.png"),
	&"CHAR-RUN-A": preload("res://content/rudy/frames/CHAR-RUN-A.png"),
	&"CHAR-RUN-B": preload("res://content/rudy/frames/CHAR-RUN-B.png"),
	&"CHAR-RISE": preload("res://content/rudy/frames/CHAR-RISE.png"),
	&"CHAR-FALL": preload("res://content/rudy/frames/CHAR-FALL.png"),
	&"CHAR-HURT": preload("res://content/rudy/frames/CHAR-HURT.png"),
	&"CHAR-DEFEAT": preload("res://content/rudy/frames/CHAR-DEFEAT.png"),
	&"CHAR-RESPAWN": preload("res://content/rudy/frames/CHAR-RESPAWN.png"),
	&"CHAR-CELEBRATE": preload("res://content/rudy/frames/CHAR-CELEBRATE.png"),
	&"CHAR-SWORD-IDLE": preload("res://content/rudy/frames/CHAR-SWORD-IDLE.png"),
	&"CHAR-SWORD-RUN-A": preload("res://content/rudy/frames/CHAR-SWORD-RUN-A.png"),
	&"CHAR-SWORD-RUN-B": preload("res://content/rudy/frames/CHAR-SWORD-RUN-B.png"),
	&"CHAR-SWORD-RISE": preload("res://content/rudy/frames/CHAR-SWORD-RISE.png"),
	&"CHAR-SWORD-FALL": preload("res://content/rudy/frames/CHAR-SWORD-FALL.png"),
	&"CHAR-SWORD-SLASH": preload("res://content/rudy/frames/CHAR-SWORD-SLASH.png"),
	&"CHAR-SWORD-BLOCK": preload("res://content/rudy/frames/CHAR-SWORD-BLOCK.png"),
}

## The sheet's cells, row by row: cell N shows the frame of CELLS[N]. This is
## frames.json's order (CHANGE-BRIEF.md section 2.1).
const CELLS: Array[StringName] = [
	&"CHAR-IDLE", &"CHAR-RUN-A", &"CHAR-RUN-B", &"CHAR-RISE",
	&"CHAR-FALL", &"CHAR-HURT", &"CHAR-DEFEAT", &"CHAR-RESPAWN",
	&"CHAR-CELEBRATE", &"CHAR-SWORD-IDLE", &"CHAR-SWORD-SLASH", &"CHAR-SWORD-BLOCK",
	&"CHAR-SWORD-RUN-A", &"CHAR-SWORD-RUN-B", &"CHAR-SWORD-RISE", &"CHAR-SWORD-FALL",
]

## The asset ID of the pose on screen: the pose of the cell the Sprite shows.
var pose: StringName:
	get:
		return CELLS[_sprite.frame] if _sprite else CELLS[0]

@onready var _sprite: Sprite2D = $Sprite
@onready var _player: AnimationPlayer = $AnimationPlayer


## Plays `clip` if it is not the clip playing. `restart` starts it over from
## its first key even if it is playing: every new swing does (section 3).
## The seek comes before play(): play() marks the clip as just started, so
## the player's update later this tick adds no time and shows the first key
## on this tick. A seek(0.0, true) after play() would run that update at once,
## using the mark up, and the tick's own update would then add a tick: the
## slash would end, and the player stop, a tick early.
func play_clip(clip: StringName, restart := false) -> void:
	if not restart and StringName(_player.current_animation) == clip:
		return
	if restart:
		_player.seek(0.0, true)
	_player.play(clip)


## The frame on screen now: the original PNG of the pose the Sprite shows.
func frame() -> Texture2D:
	return FRAMES[pose]
