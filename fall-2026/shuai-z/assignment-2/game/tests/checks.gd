extends Node
## Headless checks for the greybox. Step 1a: the scenes have their nodes,
## Rudy's capsule matches the character sheet, his movement states, turning in
## place, the camera, and the jump sound's guard (one Sfx "jump" per takeoff,
## CHANGE-BRIEF.md).
## Run from the repository root:
##   Godot --headless --path game --fixed-fps 60 res://tests/checks.tscn
## Prints one line per check and exits with code 1 if any check fails.

const MAIN := preload("res://app/main.tscn")
const REQUIRED_NODES := {
	"res://app/main.tscn": ["Level1", "Rudy", "Camera", "Hud"],
	"res://content/rudy/rudy.tscn": ["Body", "Look"],
	"res://content/level_1/level_1.tscn": ["Ground/Segment1", "Bounds/Left", "Bounds/Right", "StartPoint"],
	"res://ui/hud.tscn": ["Debug"],
}

var _failures := 0
var _rudy: Rudy
var _camera: Camera2D
# What the checks see Rudy do, measured from his motion rather than from Sfx.
var _takeoffs := 0
var _was_on_floor := true
var _trail: Array[StringName] = [] # each pose, once per change


func _ready() -> void:
	_check_scenes()
	var main := MAIN.instantiate()
	add_child(main)
	_rudy = main.get_node("Rudy")
	_camera = main.get_node("Camera")
	await _run()
	print("all checks passed" if _failures == 0 else "%d check(s) FAILED" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


func _physics_process(_delta: float) -> void:
	if _rudy == null:
		return
	var on_floor := _rudy.is_on_floor()
	if _was_on_floor and not on_floor and _rudy.velocity.y < 0.0:
		_takeoffs += 1
	_was_on_floor = on_floor
	if _trail.is_empty() or _trail[-1] != _rudy.pose:
		_trail.append(_rudy.pose)


func _run() -> void:
	var body: CollisionShape2D = _rudy.get_node("Body")
	var capsule := body.shape as CapsuleShape2D
	_check("the capsule is 40 x 136 px with its bottom on the soles",
		capsule.radius == 20.0 and capsule.height == 136.0 and body.position == Vector2(0, -68))

	await _frames(10)
	_check("Rudy starts on the ground at the start point",
		_rudy.is_on_floor() and is_equal_approx(_rudy.global_position.x, 300.0),
		"x %.1f, y %.1f" % [_rudy.global_position.x, _rudy.global_position.y])
	_check("standing still shows CHAR-IDLE", _rudy.pose == &"CHAR-IDLE", _rudy.pose)

	# Run right for two seconds.
	var x0 := _rudy.global_position.x
	_trail.clear()
	Input.action_press(&"move_right")
	await _frames(60)
	var ran := _rudy.global_position.x - x0
	_check("he runs right at about run_speed", ran > 0.9 * _rudy.run_speed and ran <= _rudy.run_speed,
		"%.0f px in 1 s" % ran)
	_check("the run alternates CHAR-RUN-A and CHAR-RUN-B",
		_trail.count(&"CHAR-RUN-A") >= 3 and _trail.count(&"CHAR-RUN-B") >= 3, _trail_text())
	await _frames(60)
	var view := _camera.get_screen_center_position()
	_check("the camera follows him sideways, less than his height behind, and keeps its height",
		absf(view.x - _rudy.global_position.x) < 160.0 and is_equal_approx(view.y, 540.0),
		"view centre %.0f, %.0f; Rudy x %.0f" % [view.x, view.y, _rudy.global_position.x])
	Input.action_release(&"move_right")
	await _frames(15)
	_check("he stops and shows CHAR-IDLE again",
		_rudy.pose == &"CHAR-IDLE" and _rudy.velocity.x == 0.0, _rudy.pose)

	# One tap: one takeoff and one jump sound; RISE, then FALL, then IDLE on landing.
	_reset_counts()
	var floor_y := _rudy.global_position.y
	# His height after each tick. A key pressed from inside a physics tick, as
	# here, counts from the next tick, so the takeoff is the first tick above 0.
	var heights: Array[float] = []
	Input.action_press(&"jump")
	for i in 90:
		await _frames(1)
		if i == 2:
			Input.action_release(&"jump")
		heights.append(floor_y - _rudy.global_position.y)
	_check("a tap jumps once, with one jump sound", _takeoffs == 1 and Sfx.count(&"jump") == 1, _counts_text())
	_check("the jump shows CHAR-RISE, then CHAR-FALL, then CHAR-IDLE",
		_trail == [&"CHAR-IDLE", &"CHAR-RISE", &"CHAR-FALL", &"CHAR-IDLE"], _trail_text())
	var expected := _expected_jump()
	var takeoff := 0
	while takeoff < heights.size() - 1 and heights[takeoff] <= 0.0:
		takeoff += 1
	var apex: float = heights.max()
	var apex_at := heights.find(apex)
	var landed_at := apex_at
	while landed_at < heights.size() - 1 and heights[landed_at] > 0.01:
		landed_at += 1
	var rise_ticks := apex_at - takeoff + 1
	var fall_ticks := landed_at - apex_at
	_check("the apex matches jump_velocity and gravity", absf(apex - expected.x) < 2.0,
		"%.1f px, expected %.1f" % [apex, expected.x])
	_check("the fall is quicker than the rise, as fall_gravity sets",
		fall_ticks < rise_ticks and absi(rise_ticks - int(expected.y)) <= 1 and absi(fall_ticks - int(expected.z)) <= 1,
		"rise %d ticks, fall %d; expected %d and %d" % [rise_ticks, fall_ticks, int(expected.y), int(expected.z)])
	_check("he lands on the ground again", _rudy.is_on_floor() and is_equal_approx(_rudy.global_position.y, floor_y))

	# Holding the key: one jump, and no new jump on landing.
	_reset_counts()
	Input.action_press(&"jump")
	await _frames(100)
	Input.action_release(&"jump")
	await _frames(10)
	_check("holding jump jumps once, not again on landing",
		_takeoffs == 1 and Sfx.count(&"jump") == 1, _counts_text())

	# A second press in the air does nothing.
	_reset_counts()
	await _tap(&"jump")
	await _frames(12)
	await _tap(&"jump")
	await _frames(80)
	_check("a press in the air does not jump", _takeoffs == 1 and Sfx.count(&"jump") == 1, _counts_text())

	# Mashing: every takeoff has exactly one jump sound, and nothing else does.
	_reset_counts()
	for i in 160:
		if i % 2 == 0:
			Input.action_press(&"jump")
		else:
			Input.action_release(&"jump")
		await _frames(1)
	Input.action_release(&"jump")
	await _frames(80)
	_check("mashing jump: one jump sound per takeoff",
		_takeoffs >= 2 and Sfx.count(&"jump") == _takeoffs, _counts_text())

	# On the ground a tap of the other direction turns him in place: neither he
	# nor the camera moves.
	await _frames(90) # let the camera settle
	var look: Node2D = _rudy.get_node("Look")
	var x_still := _rudy.global_position.x
	var view_still := _camera.get_screen_center_position()
	var tick := 1.0 / Engine.physics_ticks_per_second
	Input.action_press(&"move_left")
	await _frames(floori(_rudy.turn_hold_time / tick) - 2)
	Input.action_release(&"move_left")
	await _frames(30)
	var view_moved := _camera.get_screen_center_position().distance_to(view_still)
	_check("a tap of the other direction turns him in place; he and the camera stay put",
		_rudy.facing == -1 and look.scale.x == -1.0
		and absf(_rudy.global_position.x - x_still) < 0.01 and view_moved < 0.5,
		"facing %d, he moved %.2f px, the view %.2f px" % [_rudy.facing, _rudy.global_position.x - x_still, view_moved])

	# Holding the other direction turns him, then moves him after turn_hold_time.
	var held_ticks := 0
	Input.action_press(&"move_right")
	while absf(_rudy.global_position.x - x_still) < 0.01 and held_ticks < 60:
		await _frames(1)
		held_ticks += 1
	_check("holding the other direction moves him after about turn_hold_time",
		_rudy.facing == 1 and absf(held_ticks * tick - _rudy.turn_hold_time) <= 2.0 * tick,
		"he moved after %.3f s; turn_hold_time %.3f s" % [held_ticks * tick, _rudy.turn_hold_time])

	# From a run, the other direction stops him at once, with no slide.
	await _frames(40)
	var x_run := _rudy.global_position.x
	Input.action_release(&"move_right")
	Input.action_press(&"move_left")
	var slid := 0.0
	for i in 5:
		await _frames(1)
		slid = maxf(slid, _rudy.global_position.x - x_run)
	_check("from a run, the other direction stops him at once, with no slide",
		_rudy.facing == -1 and slid < 0.01, "slid %.2f px" % slid)
	await _frames(30)
	_check("holding it then runs him the other way",
		_rudy.velocity.x < 0.0 and _rudy.global_position.x < x_run, "speed %.0f" % _rudy.velocity.x)
	Input.action_release(&"move_left")

	# In the air there is no turning delay: the facing and the speed change at once.
	Input.action_press(&"move_right")
	await _frames(30)
	await _tap(&"jump")
	await _frames(4)
	Input.action_release(&"move_right")
	Input.action_press(&"move_left")
	await _frames(10)
	_check("in the air, the other direction turns him and changes his speed at once",
		not _rudy.is_on_floor() and _rudy.facing == -1 and _rudy.velocity.x < 0.0,
		"speed %.0f" % _rudy.velocity.x)

	# The left bound stops him on the ground.
	await _frames(250)
	Input.action_release(&"move_left")
	await _frames(15)
	_check("the left bound stops him at the edge, on the ground",
		_rudy.global_position.x > 19.0 and _rudy.global_position.x < 21.0 and _rudy.is_on_floor(),
		"x %.1f" % _rudy.global_position.x)
	_check("the camera stops at the level's left edge",
		is_equal_approx(_camera.get_screen_center_position().x, 960.0),
		"view centre x %.1f" % _camera.get_screen_center_position().x)


func _check_scenes() -> void:
	for path: String in REQUIRED_NODES:
		var root := (load(path) as PackedScene).instantiate()
		var missing: PackedStringArray = []
		for node_path: String in REQUIRED_NODES[path]:
			if not root.has_node(node_path):
				missing.append(node_path)
		_check("%s has its nodes" % path.get_file(), missing.is_empty(),
			"" if missing.is_empty() else "missing " + ", ".join(missing))
		root.free()


## The jump the controller should make, stepped the way it moves: the takeoff
## tick moves at the full jump velocity; from the next tick, gravity is added
## before each move, fall_gravity once he is coming down. Returns the apex in px,
## then the ticks of the rise and of the fall.
func _expected_jump() -> Vector3:
	var dt := 1.0 / Engine.physics_ticks_per_second
	var speed := -_rudy.jump_velocity # negative is up
	var y := 0.0
	var apex := 0.0
	var rise_ticks := 0
	for tick in range(1, 600):
		if tick > 1:
			speed += (_rudy.fall_gravity if speed >= 0.0 else _rudy.gravity) * dt
		y += speed * dt
		if -y > apex:
			apex = -y
			rise_ticks = tick
		if y >= 0.0:
			return Vector3(apex, rise_ticks, tick - rise_ticks)
	return Vector3.ZERO


func _check(what: String, ok: bool, detail: String = "") -> void:
	print("%s  %s%s" % ["PASS" if ok else "FAIL", what, "" if detail.is_empty() else "  (%s)" % detail])
	if not ok:
		_failures += 1


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _tap(action: StringName) -> void:
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)


func _reset_counts() -> void:
	Sfx.reset_counts()
	_takeoffs = 0
	_trail.clear()
	_trail.append(_rudy.pose)


func _counts_text() -> String:
	return "takeoffs %d, Sfx jump %d" % [_takeoffs, Sfx.count(&"jump")]


func _trail_text() -> String:
	return " > ".join(PackedStringArray(_trail))
