extends Node2D
## A fixture, not the game: Rudy's slash over Level 1 at in-game camera scale,
## for the slash frame strip (CHANGE-BRIEF.md, Revision 5, "The frame strip";
## section 4, "The rendered frame"; section 9, "Frame strips and watching").
## Every capture of it is a fixture capture.
##
## The real level is the background, with its Enemies, Hazards, Waystone and
## Portal frozen (PROCESS_MODE_DISABLED); its SwordPickup is left alone. The
## real Rudy (content/rudy/rudy.tscn) stands at (2500, 840), on the pickup, so
## he takes the sword by touch on the first ticks, facing right. He is driven
## only by Input.parse_input_event key events: this script never writes his
## state, velocity, position, gear or his AnimationPlayer, and only reads them.
## The camera has Main's limits, y 540 and no smoothing, and its x is set to
## Rudy's x every frame, so his origin stays at one screen point.
##
## The trigger frame is 30. The first J is sent at the end of frame 29's
## _process, so it is read on the first tick of frame 30. With the user
## argument second-tick it is read on frame 30's second tick instead (the
## brief's second offset, section 6), sent as the edge test sends a slot-b
## press (tests/test_rudy_edges.gd): from that frame boundary, one
## physics_frame, then the event and Input.flush_buffered_events(). Later J's
## are read every 120 ticks after the first J's read tick, on the same slot of
## their frame, so a 90-frame capture holds one swing and a windowed run
## without Movie Maker shows a swing every 2 s. Each J is released by ticks,
## after the tick it is read on, never by frames: a windowed run at
## --time-scale 0.25 has frames with no tick, and a press released before a
## tick runs is never read.
##
## Ticks are counted from 0, from this node's _physics_process, which runs
## before Rudy's on each tick; frames are counted from 0, one per _process(),
## which is one Movie Maker frame. At --fixed-fps 30, frame 0 runs one tick
## (tick 0) and frame N >= 1 runs ticks 2N-1 and 2N, so the first J is read on
## tick 59 (60 with second-tick). Each frame prints one line, "frame N", with
## the ticks run in it and the state after its last tick; a header before
## frame 0 names the frames to read, and a line "# J read on tick T, ..." is
## printed, from what happened, before the line of the frame it was read in.
##
## Run from the assignment folder. Windowed:
##   godot --path game res://previews/slash_preview.tscn
##   godot --path game res://previews/slash_preview.tscn -- second-tick
## Capture (the assignment text's command, with --debug-collisions; r<N> is the
## take; the second offset adds "-- second-tick" at the end):
##   godot --path game res://previews/slash_preview.tscn \
##     --write-movie "$PWD/captures/slash/r<N>/frame.png" \
##     --fixed-fps 30 --quit-after 90 --debug-collisions \
##     2>&1 | tee logs/slash_preview_r<N>.log

const TRIGGER_FRAME := 30 ## the first J is read in this frame
const REPEAT_TICKS := 120 ## later J's are read this many ticks after the one before
## Level 1's gameplay objects, held still so the background does not change.
const FROZEN: Array[NodePath] = [^"Level1/Enemies", ^"Level1/Hazards",
	^"Level1/Waystone", ^"Level1/Portal"]
const ARGUMENTS := ["second-tick"]

var _second_tick := false
var _tick := 0 ## the number of ticks started so far: the next tick's number
var _frame := 0
var _frame_first_tick := 0 ## the first tick of the frame now running
var _next_read := -1 ## the tick the next J is to be read on; -1 until the first is read
var _j_down := false
var _j_read := -1 ## the tick the last J was read on; -1 before the first
var _sent := false ## a J was sent and has not been read yet
var _was_slashing := false
var _swing_start := -1 ## the tick the current swing's J was read on

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
			print("# slash_preview: unknown argument %s; known: %s" % [arg, ", ".join(ARGUMENTS)])
			get_tree().quit(1)
			return
	_second_tick = "second-tick" in args
	for path in FROZEN:
		get_node(path).process_mode = Node.PROCESS_MODE_DISABLED
	_print_header()


func _physics_process(_delta: float) -> void:
	_observe(_tick - 1) # Rudy has not run this tick yet: the state after the last one
	# This node runs before Rudy on the tick, so this is the press he reads now.
	if Input.is_action_just_pressed(&"slash"):
		_j_read = _tick
		_sent = false
		_next_read = _tick + REPEAT_TICKS
		var slot := _tick - _frame_first_tick
		print("# J read on tick %d, the %s tick of frame %d" % [_tick, _slot_name(slot), _frame])
	_tick += 1


func _process(_delta: float) -> void:
	_observe(_tick - 1)
	_camera.position.x = _rudy.global_position.x
	_camera.force_update_scroll()
	_label.text = "FIXTURE slash_preview frame %d" % _frame
	print(_line())
	_frame += 1
	_frame_first_tick = _tick
	_drive()


## Sends this frame boundary's key events. A J sent here is read on the next
## tick (slot a), or, sent after one physics_frame and flushed, on the one
## after it (slot b, the second offset). A held J is released only once it
## has been read.
func _drive() -> void:
	if _j_down and _j_read >= 0 and _tick > _j_read:
		_key(KEY_J, false)
	if _j_down or _sent:
		return
	var due := false
	if _next_read < 0:
		due = _frame == TRIGGER_FRAME # the boundary at the end of frame TRIGGER_FRAME - 1
	else:
		due = _tick >= _next_read - (1 if _second_tick else 0)
	if not due:
		return
	_sent = true
	if _second_tick:
		await get_tree().physics_frame
		_key(KEY_J, true)
		Input.flush_buffered_events()
	else:
		_key(KEY_J, true)


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
	if code == KEY_J:
		_j_down = pressed


## Notes the tick a swing starts on, from Rudy's state after tick `done`.
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
	var f := TRIGGER_FRAME
	print("# FIXTURE slash_preview: a fixture, not the game; every capture of it is a fixture capture")
	print("# argument: %s" % ("second-tick (J read on the second tick of its frame)" if _second_tick
		else "none (J read on the first tick of its frame)"))
	print("# at --fixed-fps 30 frame 0 runs tick 0 alone, and frame N >= 1 runs ticks 2N-1 and 2N and shows the state after tick 2N")
	print("# the first J is sent at the end of frame %d and read on the %s tick of frame %d: tick %d at --fixed-fps 30;"
		% [f - 1, "second" if _second_tick else "first", f, 2 * f - (0 if _second_tick else 1)])
	print("# later J's every %d ticks after it, on the same slot; the \"# J read\" lines say where each was read" % REPEAT_TICKS)
	print("# trigger frame F = %d" % f)
	print("# frames to read:")
	if not _second_tick:
		print("#   (CHANGE-BRIEF.md, Revision 5, \"The frame strip\", as Revision 6 corrects it)")
		print("#   F-1 = %d  before the press: the sword-idle Sprite" % (f - 1))
		print("#   F   = %d  tick 1, startup: the rig: blade raised back over his shoulder, Grip -67.5, Lean -2; no arc; hitbox dead" % f)
		print("#   F+1 = %d  tick 3, active, the first frame shown: blade starting forward, Grip -53.3; arc half on (a 0.5); hitbox live" % (f + 1))
		print("#   F+2 = %d  tick 5, active: blade at its drawn angle (0); Lean +3, 6 px forward; arc a 0.86" % (f + 2))
		print("#   F+3 = %d  tick 7, active: Grip +25, the blade well past F+2, about level (Revision 6; Revision 5 had +5)" % (f + 3))
		print("#   F+5 = %d  tick 11, recovery, the first frame: Grip +45, forward and about 14 deg below horizontal; arc gone; hitbox dead" % (f + 5))
		print("#   F+8 = %d  tick 17, the swing is over: the sword-idle Sprite again" % (f + 8))
		print("#   tick 2, the startup-to-active boundary, falls on the first tick of frame F+1: no PNG shows it")
	else:
		print("#   (CHANGE-BRIEF.md, Revision 6, \"The second offset\"), derived from the phase table")
		print("#   (section 2.2: startup 0-1, active 2-10, recovery 11-16, end 17) and the slash clip's keys and")
		print("#   transitions (Grip ease-in 2 into tick 5, ease-out 0.5 from it and from tick 11; Lean ease 0.5 from tick 11; Arc linear).")
		print("#   Frame N shows swing tick 2N - 60.")
		print("#   F-1 = %d  before the press: the sword-idle Sprite" % (f - 1))
		print("#   F   = %d  tick 0, startup, the trigger: the rig; Grip -70, Lean -2, Lean (0, 0); arc a 0; hitbox dead" % f)
		print("#   F+1 = %d  tick 2, the startup-to-active boundary, the first active key: Grip -60, Lean -2, Lean (0, 0); arc a 0; hitbox live" % (f + 1))
		print("#   F+2 = %d  tick 4, active: Grip -33.33, Lean +1.33, Lean (4, 0); arc a 1.0; hitbox live" % (f + 2))
		print("#   F+3 = %d  tick 6, active: Grip +13.75" % (f + 3))
		print("#   F+4 = %d  tick 8, active: Grip +33.75, about level" % (f + 4))
		print("#   F+5 = %d  tick 10, the last live tick: Grip +43.75, Lean +3, Lean (6, 0); arc a 0.14; hitbox live" % (f + 5))
		print("#   F+6 = %d  tick 12, recovery, the first frame shown: Grip +35.83, Lean +2.08, Lean (4.17, 0); arc a 0; hitbox dead" % (f + 6))
		print("#   F+8 = %d  tick 16, the last slash frame: Grip +15.83, Lean +0.08, Lean (0.17, 0); arc a 0; hitbox dead" % (f + 8))
		print("#   F+9 = %d  tick 18, the first frame after the swing: the sword-idle Sprite again" % (f + 9))
		print("#   ticks 11 (active-to-recovery) and 17 (the end) fall on the first ticks of frames F+6 and F+9: no PNG shows them")
	print("# columns: the ticks run in the frame, then the state after its last tick; swing = ticks since the J was read")
