extends Node
## Headless checks for the greybox. Run from the repository root:
##   Godot --headless --path game --fixed-fps 60 res://tests/checks.tscn
## Prints one line per check and exits with code 1 if any check fails.
## Step 1a: the scenes have their nodes, Rudy's capsule matches the character
## sheet, his movement states, turning on the spot, the camera, and the jump
## sound's guard (one Sfx "jump" per takeoff, CHANGE-BRIEF.md).
## Step 1b: the layout, a fall below a cliff, the respawn at the last
## checkpoint, the waystone, the teleport circle and the end card, and a timed
## route from the opening to the circle. Sounds counted: "fall", "checkpoint",
## "portal", each once per event.

const MAIN := preload("res://app/main.tscn")
const REQUIRED_NODES := {
	"res://app/main.tscn": ["Level1", "Rudy", "Camera", "Hud", "Level1/Waystone", "Level1/Portal"],
	"res://content/rudy/rudy.tscn": ["Body", "Look"],
	"res://content/level_1/level_1.tscn": [
		"Backdrop/Far/Art", "Backdrop/Mid/Art", "PitShade", "Ground/Segment1", "Ground/Segment2",
		"Ground/Segment3", "Waystone/SpawnPoint", "Portal", "Bounds/Left", "Bounds/Right", "StartPoint",
	],
	"res://ui/hud.tscn": ["Debug", "Fade", "EndCard/Lines/Title", "EndCard/Lines/Hint"],
}
const JUMP_LEAD := 60.0 ## the route presses jump this far before a cliff's edge

var _failures := 0
var _main: Main
var _rudy: Rudy
var _camera: Camera2D
var _restart_requests := 0
# What the checks see Rudy do, measured from his motion rather than from Sfx.
var _takeoffs := 0
var _was_on_floor := true
var _trail: Array[StringName] = [] # each pose, once per change


func _ready() -> void:
	_check_scenes()
	_start_level()
	await _run_1a()
	await _run_1b()
	print("all checks passed" if _failures == 0 else "%d check(s) FAILED" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_rudy):
		return
	var on_floor := _rudy.is_on_floor()
	if _was_on_floor and not on_floor and _rudy.velocity.y < 0.0:
		_takeoffs += 1
	_was_on_floor = on_floor
	if _trail.is_empty() or _trail[-1] != _rudy.pose:
		_trail.append(_rudy.pose)


func _start_level() -> void:
	_main = MAIN.instantiate()
	add_child(_main)
	_main.restart_requested.connect(_on_restart_requested)
	_rudy = _main.get_node("Rudy")
	_camera = _main.get_node("Camera")
	_was_on_floor = true


func _on_restart_requested() -> void:
	_restart_requests += 1


func _run_1a() -> void:
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
	# The body rests within the physics safe margin (0.08 px) of the ground, so
	# compare to within half a pixel.
	_check("he lands on the ground again", _rudy.is_on_floor() and absf(_rudy.global_position.y - floor_y) < 0.5,
		"on the floor %s, y %.3f, before the jump %.3f" % [_rudy.is_on_floor(), _rudy.global_position.y, floor_y])

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


func _run_1b() -> void:
	var level: Node2D = _main.get_node("Level1")
	var waystone: Waystone = level.get_node("Waystone")
	var portal: Portal = level.get_node("Portal")
	var start := (level.get_node("StartPoint") as Marker2D).global_position
	var spawn := waystone.spawn_point.global_position
	var gaps := _gaps(level)
	_check("Level 1 has two cliffs, after the waystone and before the teleport circle",
		gaps.size() == 2 and gaps[0].x > spawn.x and gaps[-1].y < portal.global_position.x, str(gaps))

	# A fall before the waystone: instant death, one fall sound, back at the start.
	_reset_counts()
	_teleport(Vector2(gaps[0].x - 120.0, start.y)) # past the waystone, without touching it
	Input.action_press(&"move_right")
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 240)
	Input.action_release(&"move_right")
	_check("falling below a cliff is instant death, with one fall sound",
		_main.state == Main.State.DYING and _rudy.mode == Rudy.Mode.FALLEN and Sfx.count(&"fall") == 1,
		"state %s, fall sounds %d" % [Main.State.keys()[_main.state], Sfx.count(&"fall")])
	var back_after: int = await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("after a fade he is back at the start, the last checkpoint, in control",
		_main.state == Main.State.PLAYING and _rudy.mode == Rudy.Mode.PLAY
		and _rudy.global_position.distance_to(start) < 1.0 and _rudy.is_on_floor(),
		"after %.2f s, at x %.0f" % [back_after / 60.0, _rudy.global_position.x])
	_check("the kill line counted the fall once, though he stayed below it",
		Sfx.count(&"fall") == 1, "fall sounds %d" % Sfx.count(&"fall"))
	_check("he gets back up in CHAR-RESPAWN, then stands in CHAR-IDLE",
		_trail.has(&"CHAR-RESPAWN") and _rudy.pose == &"CHAR-IDLE", _trail_text())
	_check("the camera comes back with him", absf(_camera.get_screen_center_position().x - 960.0) < 1.0,
		"view centre x %.0f" % _camera.get_screen_center_position().x)
	_check("the waystone is still dark", not waystone.lit)

	# The waystone lights once and becomes the checkpoint.
	_reset_counts()
	_teleport(Vector2(waystone.global_position.x - 300.0, start.y))
	await _hold_until(&"move_right", func() -> bool: return _rudy.global_position.x > spawn.x, 120)
	_check("the waystone lights the first time he touches it, and becomes the checkpoint",
		waystone.lit and Sfx.count(&"checkpoint") == 1 and _main.checkpoint_name == "waystone",
		"checkpoint sounds %d" % Sfx.count(&"checkpoint"))
	await _hold(&"move_left", 30)
	await _hold(&"move_right", 24)
	_check("crossing it again does not light it again", Sfx.count(&"checkpoint") == 1,
		"checkpoint sounds %d" % Sfx.count(&"checkpoint"))

	# A fall after the waystone brings him back at the waystone.
	_reset_counts()
	Input.action_press(&"move_right")
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 240)
	Input.action_release(&"move_right")
	await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("after a fall past the waystone he gets back up at the waystone",
		_rudy.global_position.distance_to(spawn) < 1.0 and Sfx.count(&"fall") == 1,
		"at x %.0f; spawn x %.0f" % [_rudy.global_position.x, spawn.x])

	# From the waystone, over both cliffs, onto the teleport circle.
	_reset_counts()
	var route_ticks: int = await _run_route(gaps, 900)
	_check("from the waystone he clears both cliffs and reaches the teleport circle",
		route_ticks > 0 and _main.state == Main.State.COMPLETE,
		"state %s, fall sounds %d" % [Main.State.keys()[_main.state], Sfx.count(&"fall")])
	await _frames(2) # his pose follows on his next tick
	_check("the circle completes the level once: one portal sound; he celebrates",
		Sfx.count(&"portal") == 1 and _rudy.mode == Rudy.Mode.CELEBRATING and _rudy.pose == &"CHAR-CELEBRATE",
		"portal sounds %d, pose %s" % [Sfx.count(&"portal"), _rudy.pose])
	await _frames(20) # let him come to a stop
	var x_done := _rudy.global_position.x
	await _hold(&"move_left", 30)
	await _tap(&"jump")
	await _frames(20)
	_check("input stops on the circle", absf(_rudy.global_position.x - x_done) < 0.01 and _rudy.is_on_floor(),
		"moved %.2f px" % (_rudy.global_position.x - x_done))
	var hud: Hud = _main.get_node("Hud")
	var card_after: int = await _wait_until(func() -> bool: return hud.is_showing_end_card(), 300)
	_check("the camera pulls back and the screen fades to the end card",
		hud.is_showing_end_card() and _camera.zoom.is_equal_approx(Main.END_ZOOM),
		"after %.2f s more; zoom %.2f" % [card_after / 60.0, _camera.zoom.x])
	portal.reached.emit() # as if he stepped onto the circle again
	await _frames(2)
	_check("stepping onto the circle again does not complete the level again", Sfx.count(&"portal") == 1,
		"portal sounds %d" % Sfx.count(&"portal"))
	await _tap(&"restart")
	await _frames(5)
	_check("Enter on the end card plays the level again", _restart_requests == 1,
		"restart requests %d" % _restart_requests)

	# A fresh level from the opening, the way Enter starts it: the whole route, timed.
	_main.queue_free()
	await _frames(1)
	_start_level()
	_reset_counts()
	await _frames(5)
	var fresh_waystone: Waystone = _main.get_node("Level1/Waystone")
	_check("the level starts again at the opening, with the waystone dark",
		_main.state == Main.State.PLAYING and not fresh_waystone.lit
		and _rudy.global_position.distance_to(start) < 1.0)
	route_ticks = await _run_route(gaps, 1800)
	_check("the route from the opening reaches the circle: the waystone lights once, no falls",
		route_ticks > 0 and Sfx.count(&"checkpoint") == 1 and Sfx.count(&"portal") == 1 and Sfx.count(&"fall") == 0,
		"%.1f s from the opening at full speed" % (route_ticks / 60.0))

	# How forgiving the widest cliff is, measured: full-speed takeoffs every 5 px
	# from 300 px before its edge to 40 px past it, on a fresh level.
	_main.queue_free()
	await _frames(1)
	_start_level()
	await _frames(5)
	var widest := gaps[0]
	for gap in gaps:
		if gap.y - gap.x > widest.y - widest.x:
			widest = gap
	var window := await _takeoff_window(widest)
	var window_s := (window.y - window.x) / _rudy.run_speed
	_check("the widest cliff can be cleared by full-speed takeoffs spread over at least 0.3 s",
		window_s >= 0.3,
		"takeoffs from %s to %s clear it: %.0f px, %.2f s of running" % [
			_from_edge(window.x), _from_edge(window.y), window.y - window.x, window_s])


## The cliffs: the gaps between ground segments, as (from x, to x).
func _gaps(level: Node2D) -> Array[Vector2]:
	var segments: Array[GroundSegment] = []
	for child in level.get_node("Ground").get_children():
		if child is GroundSegment:
			segments.append(child)
	segments.sort_custom(func(a: GroundSegment, b: GroundSegment) -> bool: return a.position.x < b.position.x)
	var gaps: Array[Vector2] = []
	for i in range(1, segments.size()):
		var end := segments[i - 1].global_position.x + segments[i - 1].size.x
		var begin := segments[i].global_position.x
		if begin > end:
			gaps.append(Vector2(end, begin))
	return gaps


## Runs at the cliff at full speed and jumps, once for each aim point every
## 5 px from 300 px before its edge to 40 px past it. Returns the earliest and
## the latest takeoff that cleared it, as x from the edge (before it is negative).
func _takeoff_window(gap: Vector2) -> Vector2:
	var earliest := INF
	var latest := -INF
	var aim := -300.0
	while aim <= 40.0:
		_teleport(Vector2(gap.x - 500.0, 840.0))
		await _frames(2) # let him settle: is_on_floor() is stale until his next move
		Input.action_press(&"move_right")
		# Past the edge he keeps moving right while he falls, so every aim is reached.
		await _wait_until(func() -> bool: return _rudy.global_position.x >= gap.x + aim, 240)
		Input.action_press(&"jump")
		var takeoff_x := NAN
		var floor_x := _rudy.global_position.x
		for t in 120:
			await _frames(1)
			if t == 2:
				Input.action_release(&"jump")
			if _rudy.is_on_floor():
				if is_nan(takeoff_x):
					floor_x = _rudy.global_position.x
				elif _rudy.global_position.x > gap.y:
					break # landed beyond the cliff
			elif is_nan(takeoff_x) and _rudy.velocity.y < 0.0:
				takeoff_x = floor_x # where he stood on the takeoff tick
			if _rudy.global_position.y > 880.0:
				break # in the pit
		Input.action_release(&"move_right")
		Input.action_release(&"jump")
		if not is_nan(takeoff_x) and _rudy.is_on_floor() and _rudy.global_position.x > gap.y:
			earliest = minf(earliest, takeoff_x - gap.x)
			latest = maxf(latest, takeoff_x - gap.x)
		aim += 5.0
	return Vector2(earliest, latest)


func _from_edge(x: float) -> String:
	if x < 0.0:
		return "%.0f px before the edge" % -x
	return "%.0f px past the edge" % x


## Holds right and jumps once before each cliff, until the level is complete.
## Returns the ticks it took, or -1 if he fell or ran out of time.
func _run_route(gaps: Array[Vector2], max_ticks: int) -> int:
	var next_gap := 0
	var release_jump_at := -1
	Input.action_press(&"move_right")
	for t in max_ticks:
		await _frames(1)
		if t == release_jump_at:
			Input.action_release(&"jump")
		if _main.state == Main.State.COMPLETE:
			Input.action_release(&"move_right")
			Input.action_release(&"jump")
			return t + 1
		if _main.state == Main.State.DYING:
			break
		while next_gap < gaps.size() and _rudy.global_position.x > gaps[next_gap].x:
			next_gap += 1
		if next_gap < gaps.size() and release_jump_at < t and _rudy.is_on_floor() \
				and _rudy.global_position.x >= gaps[next_gap].x - JUMP_LEAD:
			Input.action_press(&"jump")
			release_jump_at = t + 3
	Input.action_release(&"move_right")
	Input.action_release(&"jump")
	return -1


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


## Waits until `condition` is true, for at most `max_ticks`; returns the ticks waited.
func _wait_until(condition: Callable, max_ticks: int) -> int:
	for t in max_ticks:
		if condition.call():
			return t
		await get_tree().physics_frame
	return max_ticks


func _hold(action: StringName, ticks: int) -> void:
	Input.action_press(action)
	await _frames(ticks)
	Input.action_release(action)


func _hold_until(action: StringName, condition: Callable, max_ticks: int) -> void:
	Input.action_press(action)
	await _wait_until(condition, max_ticks)
	Input.action_release(action)


func _tap(action: StringName) -> void:
	Input.action_press(action)
	await _frames(2)
	Input.action_release(action)


func _teleport(spot: Vector2) -> void:
	_rudy.global_position = spot
	_rudy.velocity = Vector2.ZERO


func _reset_counts() -> void:
	Sfx.reset_counts()
	_takeoffs = 0
	_trail.clear()
	_trail.append(_rudy.pose)


func _counts_text() -> String:
	return "takeoffs %d, Sfx jump %d" % [_takeoffs, Sfx.count(&"jump")]


func _trail_text() -> String:
	return " > ".join(PackedStringArray(_trail))
