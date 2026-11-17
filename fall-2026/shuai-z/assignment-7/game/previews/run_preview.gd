extends Node2D
## A fixture, not the game: Rudy's run over Level 1 at in-game camera scale,
## for the run frame strip and its registration (CHANGE-BRIEF.md, Revision 5,
## "The frame strip"; section 4, "The rendered frame"; section 9, "Frame strips
## and watching"). Every capture of it is a fixture capture.
##
## The real level is the background, with its Enemies, Hazards, Waystone and
## Portal frozen (PROCESS_MODE_DISABLED). The real Rudy (content/rudy/rudy.tscn)
## stands at (2500, 840), facing right. He is driven only by
## Input.parse_input_event key events: this script never writes his state,
## velocity, position, gear or his AnimationPlayer, and only reads them. The
## camera has Main's limits, y 540 and no smoothing, and its x is set to Rudy's
## x every frame, so his origin stays at one screen point.
##
## With no argument he runs without the sword: before the first tick this
## script freezes and hides Level1's SwordPickup, so he runs past it (run).
## With the user argument sword the pickup is left alone, he takes it by touch
## on the first ticks, and he runs as sword_run.
##
## The trigger frame is 30. D is sent at the end of frame 29's _process, so it
## is read on the first tick of frame 30, and held for 24 ticks (12 frames at
## 30 fps): its release is sent once 24 ticks have run from the tick D was
## read on, counted by ticks, never by frames (a windowed run at
## --time-scale 0.25 has frames with no tick). Once; no repeat.
##
## Ticks are counted from 0, from this node's _physics_process, which runs
## before Rudy's on each tick; frames are counted from 0, one per _process(),
## which is one Movie Maker frame. At --fixed-fps 30, frame 0 runs one tick
## (tick 0) and frame N >= 1 runs ticks 2N-1 and 2N, so D is read on tick 59
## and released on tick 83. Each frame prints one line, "frame N", with the
## ticks run in it and the state after its last tick; a header before frame 0
## names the frames to read, and lines "# D read on tick T, ..." and "# D
## release read on tick T, ..." are printed, from what happened, before the
## line of the frame they were read in.
##
## Run from the assignment folder. Windowed:
##   godot --path game res://previews/run_preview.tscn
##   godot --path game res://previews/run_preview.tscn -- sword
## Capture (the assignment text's command, with --debug-collisions; r<N> is the
## take; the sword form adds "-- sword" at the end):
##   godot --path game res://previews/run_preview.tscn \
##     --write-movie "$PWD/captures/run/r<N>/frame.png" \
##     --fixed-fps 30 --quit-after 90 --debug-collisions \
##     2>&1 | tee logs/run_preview_r<N>.log

const TRIGGER_FRAME := 30 ## D is read on the first tick of this frame
const HOLD_TICKS := 24 ## ...and its release this many ticks later
const LAST_READ_FRAME := 41
## Level 1's gameplay objects, held still so the background does not change.
const FROZEN: Array[NodePath] = [^"Level1/Enemies", ^"Level1/Hazards",
	^"Level1/Waystone", ^"Level1/Portal"]
const ARGUMENTS := ["sword"]

var _sword := false
var _tick := 0 ## the number of ticks started so far: the next tick's number
var _frame := 0
var _frame_first_tick := 0 ## the first tick of the frame now running
var _pressed := false
var _released := false
var _d_read := -1 ## the tick D was read on; -1 before it is
var _was_slashing := false
var _swing_start := -1

@onready var _rudy: Rudy = $Rudy
@onready var _player: AnimationPlayer = $Rudy/Look/AnimationPlayer
@onready var _sprite: Sprite2D = $Rudy/Look/Sprite
@onready var _rig: Node2D = $Rudy/Look/SlashRig
@onready var _lean: Node2D = $Rudy/Look/SlashRig/Lean
@onready var _grip: Node2D = $Rudy/Look/SlashRig/Lean/Grip
@onready var _arc: Sprite2D = $Rudy/Look/SlashRig/Lean/Arc
@onready var _hitbox: CollisionShape2D = $Rudy/SwordHitbox/Shape
@onready var _camera: Camera2D = $Camera
@onready var _label: Label = $Overlay/Label


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	for arg in args:
		if not arg in ARGUMENTS:
			print("# run_preview: unknown argument %s; known: %s" % [arg, ", ".join(ARGUMENTS)])
			get_tree().quit(1)
			return
	_sword = "sword" in args
	for path in FROZEN:
		get_node(path).process_mode = Node.PROCESS_MODE_DISABLED
	if not _sword:
		var pickup: Node2D = $Level1/SwordPickup
		pickup.process_mode = Node.PROCESS_MODE_DISABLED
		pickup.visible = false
	_print_header()


func _physics_process(_delta: float) -> void:
	_observe(_tick - 1) # Rudy has not run this tick yet: the state after the last one
	# This node runs before Rudy on the tick, so these are the key states he reads now.
	var slot := _slot_name(_tick - _frame_first_tick)
	if Input.is_action_just_pressed(&"move_right"):
		_d_read = _tick
		print("# D read on tick %d, the %s tick of frame %d" % [_tick, slot, _frame])
	if Input.is_action_just_released(&"move_right"):
		print("# D release read on tick %d, the %s tick of frame %d, %d ticks after D was read"
			% [_tick, slot, _frame, _tick - _d_read])
	_tick += 1


func _process(_delta: float) -> void:
	_observe(_tick - 1)
	_camera.position.x = _rudy.global_position.x
	_camera.force_update_scroll()
	_label.text = "FIXTURE run_preview frame %d" % _frame
	print(_line())
	_frame += 1
	_frame_first_tick = _tick
	_drive()


## Sends this frame boundary's key events, read on the next tick: D at the end
## of frame TRIGGER_FRAME - 1, and its release once D was read and the next
## tick is HOLD_TICKS after that read.
func _drive() -> void:
	if not _pressed and _frame == TRIGGER_FRAME:
		_pressed = true
		_key(KEY_D, true)
	elif _pressed and not _released and _d_read >= 0 and _tick >= _d_read + HOLD_TICKS:
		_released = true
		_key(KEY_D, false)


func _slot_name(slot: int) -> String:
	match slot:
		0:
			return "first"
		1:
			return "second"
	return "tick %d" % (slot + 1)


func _key(code: Key, pressed: bool) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.pressed = pressed
	Input.parse_input_event(e)


func _observe(done: int) -> void:
	var slashing := _rudy.is_slashing()
	if slashing and not _was_slashing:
		_swing_start = done
	_was_slashing = slashing


func _line() -> String:
	var ticks := "%3d-%3d" % [_frame_first_tick, _tick - 1] if _tick > _frame_first_tick else "   none"
	var swing := "%2d" % (_tick - 1 - _swing_start) if _rudy.is_slashing() else " -"
	var v := _rudy.velocity
	var lp := _lean.position
	var o := _rudy.get_global_transform_with_canvas().origin
	return ("frame %3d ticks %s mode %-11s pose %-16s gear %-5s facing %+d x %8.2f y %7.2f"
		+ " vel (%8.2f, %8.2f) floor %-5s clip %-10s pos %.4f cell %2d sprite %-5s rig %-5s"
		+ " grip %7.2f lean %6.2f lean_pos (%5.2f, %5.2f) arc %.3f live %-5s swing %s"
		+ " screen (%7.2f, %7.2f)") % [
		_frame, ticks, Rudy.Mode.keys()[_rudy.mode], _rudy.pose, Rudy.Gear.keys()[_rudy.gear],
		_rudy.facing, _z(_rudy.global_position.x, 2), _z(_rudy.global_position.y, 2), _z(v.x, 2), _z(v.y, 2),
		_rudy.is_on_floor(), _player.current_animation, _z(_player.current_animation_position, 4),
		_sprite.frame, _sprite.visible, _rig.visible, _z(_grip.rotation_degrees, 2),
		_z(_lean.rotation_degrees, 2), _z(lp.x, 2), _z(lp.y, 2), _z(_arc.modulate.a, 3),
		not _hitbox.disabled, swing, _z(o.x, 2), _z(o.y, 2)]


## `x` for printing with `decimals` places: 0.0 if it rounds to zero there, so
## no "-0.00" (an exact -0.0, or a tiny negative from interpolation).
func _z(x: float, decimals: int) -> float:
	return 0.0 if absf(x) < 0.5 * pow(10.0, -decimals) else x


func _print_header() -> void:
	var a := "SWORD-RUN-A (cell 12)" if _sword else "RUN-A (cell 1)"
	var b := "SWORD-RUN-B (cell 13)" if _sword else "RUN-B (cell 2)"
	print("# FIXTURE run_preview: a fixture, not the game; every capture of it is a fixture capture")
	print("# argument: %s" % ("sword (the pickup is left alone; he runs as sword_run)" if _sword
		else "none (the pickup is frozen and hidden; he runs as run)"))
	var read := 2 * TRIGGER_FRAME - 1
	print("# at --fixed-fps 30 frame 0 runs tick 0 alone, and frame N >= 1 runs ticks 2N-1 and 2N and shows the state after tick 2N")
	print("# D is sent at the end of frame %d and read on the first tick of frame %d: tick %d at --fixed-fps 30;"
		% [TRIGGER_FRAME - 1, TRIGGER_FRAME, read])
	print("# its release is read %d ticks later (%d frames at 30 fps): tick %d, the first tick of frame %d; the \"# D\" lines say where each was read"
		% [HOLD_TICKS, HOLD_TICKS / 2, read + HOLD_TICKS, TRIGGER_FRAME + HOLD_TICKS / 2])
	print("# trigger frame F = %d" % TRIGGER_FRAME)
	print("# frames to read: %d to %d" % [TRIGGER_FRAME, LAST_READ_FRAME])
	print("#   (CHANGE-BRIEF.md, Revision 5): every frame shows his soles on the walk line, and RUN-A and RUN-B")
	print("#   alternating about every 3.75 frames")
	print("#   DERIVED, not the brief's, from the run clip (section 2.1: A at 0, B at 0.125 s, length 0.25 s,")
	print("#   restart from A on entry), section 7 (first B 8 ticks after the run starts) and the pin's T1 cells")
	print("#   (8, 8, 7, 8; B still shows at position 0.25, the clip's length, and wraps to A after it): the run")
	print("#   starts on tick %d, the tick D is read, so frame N shows run tick k = 2N - %d; A for k 0-7, B 8-15,"
		% [read, read])
	print("#   A 16-22, B 23-30")
	print("#   frames 30-33 %s (k 1-7); 34-37 %s (k 9-15); 38-40 %s (k 17-21); 41 %s (k 23)" % [a, b, a, b])
	print("# columns: the ticks run in the frame, then the state after its last tick; swing = ticks since a J was read")
