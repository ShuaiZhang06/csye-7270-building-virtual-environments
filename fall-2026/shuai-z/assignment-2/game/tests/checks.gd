extends Node
## Headless checks for the greybox. Run from the repository root:
##   Godot --headless --path game --fixed-fps 60 res://tests/checks.tscn
## Prints one line per check and exits with code 1 if any check fails.
## Step 1a: the scenes have their nodes, Rudy's capsule matches the character
## sheet, his movement states, turning on the spot, the camera, and the jump
## sound's guard (one Sfx "jump" per takeoff, CHANGE-BRIEF.md).
## Step 1b: the layout, a fall below a cliff, the respawn at the last
## checkpoint, the waystone, the teleport circle and the end card, a clean
## route from the opening to the circle, and how forgiving the widest cliff is.
## Sounds counted: "fall", "checkpoint", "portal", each once per event.
## Step 1c: hearts, spikes, goblins, the stomp, invulnerability, knockback, the
## camera shake, defeat at zero hearts, and every monster back after a death.
## Sounds counted: "hurt" once per heart lost, "stomp" once per goblin stomped.
## Step 1d: the sword-and-shield pickup, the sword form, the slash and its
## reach, the gear knocked away by a hit, and the pickup back after a death.
## Sounds counted: "pickup" once per pickup, "slash" once per swing.
## Step 2a: Rudy's generated frames: every frame in frames.json is in his look
## at the canvas size, drawn with its body origin on his and at 1/density, with
## mipmaps and the outline material; and every pose he took in the checks above
## showed its own frame.

const MAIN := preload("res://app/main.tscn")
const REQUIRED_NODES := {
	"res://app/main.tscn": ["Level1", "Rudy", "Camera", "Hud", "Level1/Waystone", "Level1/Portal"],
	"res://content/rudy/rudy.tscn": ["Body", "Look", "SwordHitbox/Shape"],
	"res://content/level_1/level_1.tscn": [
		"Backdrop/Far/Art", "Backdrop/Mid/Art", "PitShade", "Ground/Segment1", "Ground/Segment2",
		"Ground/Segment3", "Hazards/SpikesA", "Hazards/SpikesB", "Enemies/GoblinA", "Enemies/GoblinB",
		"Enemies/GoblinC", "SwordPickup", "Waystone/SpawnPoint", "Portal", "Bounds/Left", "Bounds/Right", "StartPoint",
	],
	"res://content/goblin/goblin.tscn": ["Shape"],
	"res://content/level_1/spikes.tscn": ["Shape"],
	"res://content/sword_pickup/sword_pickup.tscn": ["Shape"],
	"res://ui/hud.tscn": ["Hearts", "Debug", "Fade", "EndCard/Lines/Title", "EndCard/Lines/Hint"],
}
const CLIFF_LEAD := 100.0 ## the route jumps this far before a cliff's edge
const SPIKES_LEAD := 100.0 ## ...before a row of spikes
const GOBLIN_LEAD := 220.0 ## ...before a live goblin, which may be walking toward him

var _failures := 0
var _main: Main
var _rudy: Rudy
var _camera: Camera2D
var _restart_requests := 0
# What the checks see Rudy do, measured from his motion rather than from Sfx.
var _takeoffs := 0
var _was_on_floor := true
var _trail: Array[StringName] = [] # each pose, once per change
# Every pose Rudy took in all the checks, and any tick his look showed another pose's frame.
var _poses_taken: Dictionary[StringName, bool] = {}
var _frame_mismatches: PackedStringArray = []


func _ready() -> void:
	_check_scenes()
	_start_level()
	await _run_1a()
	await _run_1b()
	await _run_1c()
	await _run_1d()
	_run_2a()
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
	_poses_taken[_rudy.pose] = true
	var shown := (_rudy.get_node("Look") as RudyLook).frame()
	if shown != RudyLook.FRAMES.get(_rudy.pose) and _frame_mismatches.size() < 5:
		_frame_mismatches.append("%s showed %s" % [_rudy.pose, shown.resource_path.get_file() if shown else "nothing"])


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
	# The movement checks run over the spikes and the first goblin; switch them off.
	_set_threats(false)
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

	# One tap in place: one takeoff and one jump sound; RISE all the way down, then IDLE on landing.
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
	_check("a jump in place shows CHAR-RISE all the way down, then CHAR-IDLE",
		_trail == [&"CHAR-IDLE", &"CHAR-RISE", &"CHAR-IDLE"], _trail_text())
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

	# A running jump comes down in CHAR-FALL. Let go before the top and he drops
	# straight down in CHAR-RISE; either way the pose changes at most once in the air.
	_reset_counts()
	await _tap(&"jump")
	await _wait_until(func() -> bool: return _rudy.is_on_floor(), 90)
	var air := _trail.filter(func(id: StringName) -> bool: return not String(id).begins_with("CHAR-RUN-"))
	_check("a running jump shows CHAR-RISE, then CHAR-FALL", air == [&"CHAR-RISE", &"CHAR-FALL"], _trail_text())
	await _frames(5)
	_reset_counts()
	await _tap(&"jump")
	await _frames(4)
	Input.action_release(&"move_left")
	await _wait_until(func() -> bool: return _rudy.is_on_floor(), 90)
	await _frames(2)
	air = _trail.filter(func(id: StringName) -> bool: return not String(id).begins_with("CHAR-RUN-"))
	_check("letting go before the top: he drops in CHAR-RISE all the way down",
		air == [&"CHAR-RISE", &"CHAR-IDLE"], _trail_text())
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
	_set_threats(true)


func _run_1b() -> void:
	var level: Node2D = _main.get_node("Level1")
	var waystone: Waystone = level.get_node("Waystone")
	var portal: Portal = level.get_node("Portal")
	var start := (level.get_node("StartPoint") as Marker2D).global_position
	var spawn := waystone.spawn_point.global_position
	var gaps := _gaps(level)
	_check("Level 1 has two cliffs, after the waystone and before the teleport circle",
		gaps.size() == 2 and gaps[0].x > spawn.x and gaps[-1].y < portal.global_position.x, str(gaps))

	# A fall before the waystone: one heart, one fall sound, back at the start.
	_reset_counts()
	var hearts_before := _rudy.hearts
	_teleport(Vector2(gaps[0].x - 120.0, start.y)) # past the waystone, without touching it
	Input.action_press(&"move_right")
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 240)
	Input.action_release(&"move_right")
	var hud: Hud = _main.get_node("Hud")
	_check("a fall below a cliff costs one heart, with one fall sound and no hurt sound",
		_main.state == Main.State.DYING and _rudy.mode == Rudy.Mode.FALLEN and Sfx.count(&"fall") == 1
		and Sfx.count(&"hurt") == 0 and _rudy.hearts == hearts_before - 1 and hud.hearts_shown() == _rudy.hearts,
		"state %s, fall sounds %d, hearts %d -> %d" % [
			Main.State.keys()[_main.state], Sfx.count(&"fall"), hearts_before, _rudy.hearts])
	var back_after: int = await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("after a fade he is back at the start, the last checkpoint, in control, with the hearts he had left",
		_main.state == Main.State.PLAYING and _rudy.mode == Rudy.Mode.PLAY
		and _rudy.global_position.distance_to(start) < 1.0 and _rudy.is_on_floor()
		and _rudy.hearts == hearts_before - 1,
		"after %.2f s, at x %.0f, hearts %d" % [back_after / 60.0, _rudy.global_position.x, _rudy.hearts])
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

	# A fall after the waystone brings him back at the waystone, one heart fewer.
	_reset_counts()
	hearts_before = _rudy.hearts
	Input.action_press(&"move_right")
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 240)
	Input.action_release(&"move_right")
	await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("after a fall past the waystone he gets back up at the waystone, one heart fewer",
		_rudy.global_position.distance_to(spawn) < 1.0 and Sfx.count(&"fall") == 1
		and _rudy.hearts == hearts_before - 1,
		"at x %.0f, spawn x %.0f; hearts %d -> %d" % [_rudy.global_position.x, spawn.x, hearts_before, _rudy.hearts])

	# From the waystone, over both cliffs, onto the teleport circle.
	_reset_counts()
	var route_ticks: int = await _run_route(gaps, 900)
	_check("from the waystone he clears both cliffs and reaches the teleport circle, unhurt",
		route_ticks > 0 and _main.state == Main.State.COMPLETE and Sfx.count(&"hurt") == 0,
		"state %s, fall sounds %d, hurt sounds %d" % [Main.State.keys()[_main.state], Sfx.count(&"fall"), Sfx.count(&"hurt")])
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
	_check("a clean route from the opening reaches the circle: the waystone lights once; no falls, no hits",
		route_ticks > 0 and Sfx.count(&"checkpoint") == 1 and Sfx.count(&"portal") == 1
		and Sfx.count(&"fall") == 0 and Sfx.count(&"hurt") == 0,
		"%.1f s from the opening at full speed, jumping the cliffs, spikes and goblins; hurt sounds %d" % [
			route_ticks / 60.0, Sfx.count(&"hurt")])

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


func _run_1c() -> void:
	_main.queue_free()
	await _frames(1)
	_start_level()
	await _frames(5)
	var level: Node2D = _main.get_node("Level1")
	var hud: Hud = _main.get_node("Hud")
	var look: Node2D = _rudy.get_node("Look")
	var spikes: Spikes = level.get_node("Hazards/SpikesA")
	var goblin_a: Goblin = level.get_node("Enemies/GoblinA")
	var goblin_b: Goblin = level.get_node("Enemies/GoblinB")
	var goblin_c: Goblin = level.get_node("Enemies/GoblinC")
	var goblins: Array[Goblin] = [goblin_a, goblin_b, goblin_c]
	var start := (level.get_node("StartPoint") as Marker2D).global_position
	var ground_y := start.y
	_check("Rudy starts with three hearts, and the HUD shows three",
		_rudy.hearts == 3 and hud.hearts_shown() == 3, "hearts %d, shown %d" % [_rudy.hearts, hud.hearts_shown()])

	# Spikes: one heart, one hurt sound, a knockback, a shake and a flash.
	_reset_counts()
	_teleport(Vector2(spikes.global_position.x - 220.0, ground_y))
	await _frames(2)
	Input.action_press(&"move_right")
	await _wait_until(func() -> bool: return _rudy.hearts < 3, 120)
	Input.action_release(&"move_right")
	var hit_x := _rudy.global_position.x
	_check("touching the spikes costs one heart, with one hurt sound; the HUD shows two",
		_rudy.hearts == 2 and Sfx.count(&"hurt") == 1 and hud.hearts_shown() == 2,
		"hearts %d, hurt sounds %d, shown %d" % [_rudy.hearts, Sfx.count(&"hurt"), hud.hearts_shown()])
	_check("the hit knocks him back, away from the spikes, and turns him toward them",
		_rudy.mode == Rudy.Mode.HURT and _rudy.velocity.x < 0.0 and _rudy.facing == 1,
		"mode %s, speed %.0f, facing %d" % [Rudy.Mode.keys()[_rudy.mode], _rudy.velocity.x, _rudy.facing])
	await _frames(2)
	_check("he shows CHAR-HURT, and the camera shakes",
		_rudy.pose == &"CHAR-HURT" and _camera.offset != Vector2.ZERO,
		"pose %s, camera offset %s" % [_rudy.pose, _camera.offset])
	var alphas := {}
	for i in 24:
		await _frames(1)
		alphas[snappedf(look.modulate.a, 0.01)] = true
	_check("he flashes while he is invulnerable", alphas.size() == 2 and _rudy.is_invulnerable(),
		"alphas seen %s" % str(alphas.keys()))
	_check("the camera shake is over after 0.2 s", _camera.offset == Vector2.ZERO, str(_camera.offset))
	await _wait_until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY, 60)
	_check("control returns after the knockback", _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor(),
		"knocked back %.0f px" % (hit_x - _rudy.global_position.x))

	# The spikes and a goblin at once: one heart, one hurt sound.
	await _wait_until(func() -> bool: return not _rudy.is_invulnerable(), 120)
	goblin_a.speed = 0.0
	goblin_a.position.x = spikes.global_position.x + 50.0 # outside its patrol, until a reset
	_reset_counts()
	_teleport(Vector2(spikes.global_position.x + 40.0, ground_y))
	await _frames(3)
	_check("touching the spikes and a goblin at once costs one heart, with one hurt sound",
		_rudy.hearts == 1 and Sfx.count(&"hurt") == 1, "hearts %d, hurt sounds %d" % [_rudy.hearts, Sfx.count(&"hurt")])

	# Standing on the spikes: nothing while he is invulnerable, then his last heart goes.
	await _wait_until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor(), 60)
	_teleport(Vector2(spikes.global_position.x - 30.0, ground_y))
	var hit_while_invulnerable := false
	while _rudy.is_invulnerable():
		await _frames(1)
		if Sfx.count(&"hurt") != 1:
			hit_while_invulnerable = true
			break
	await _frames(3)
	_check("standing on the spikes hurts again only once his invulnerability is over",
		not hit_while_invulnerable and Sfx.count(&"hurt") == 2, "hurt sounds %d" % Sfx.count(&"hurt"))
	_check("with his last heart gone he is defeated (CHAR-DEFEAT), and the level is dying; no fall",
		_rudy.hearts == 0 and _rudy.mode == Rudy.Mode.DEFEATED and _rudy.pose == &"CHAR-DEFEAT"
		and _main.state == Main.State.DYING and Sfx.count(&"fall") == 0,
		"hearts %d, pose %s, state %s" % [_rudy.hearts, _rudy.pose, Main.State.keys()[_main.state]])
	var back_after: int = await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("after the fade the level starts over: he is at the start with three hearts, flashing",
		_rudy.global_position.distance_to(start) < 1.0 and _rudy.hearts == 3 and hud.hearts_shown() == 3
		and _rudy.is_invulnerable(),
		"after %.2f s; hearts %d" % [back_after / 60.0, _rudy.hearts])
	_check("the goblin that was moved is back in its patrol",
		not goblin_a.dead and goblin_a.position.x >= 1500.0 and goblin_a.position.x <= 1500.0 + goblin_a.patrol_distance,
		"x %.0f" % goblin_a.position.x)
	goblin_a.speed = 100.0

	# Landing on a goblin from above: one stomp sound, no hit, and a bounce.
	await _wait_until(func() -> bool: return not _rudy.is_invulnerable(), 120)
	_reset_counts()
	_teleport(Vector2(goblin_a.global_position.x, ground_y - Goblin.HEIGHT - 60.0))
	_rudy.velocity = Vector2(0, 200)
	await _frames(1) # is_on_floor() is stale until his next move
	await _wait_until(func() -> bool: return goblin_a.dead or _rudy.is_on_floor(), 60)
	await _frames(2)
	_check("landing on a goblin from above defeats it, with one stomp sound and no hit",
		goblin_a.dead and Sfx.count(&"stomp") == 1 and Sfx.count(&"hurt") == 0 and _rudy.hearts == 3,
		"stomp sounds %d, hurt sounds %d" % [Sfx.count(&"stomp"), Sfx.count(&"hurt")])
	_check("the stomp bounces him up", _rudy.velocity.y < 0.0 and not _rudy.is_on_floor(),
		"speed y %.0f" % _rudy.velocity.y)
	await _frames(60)
	_check("a defeated goblin ignores him when he comes down on it again, then disappears",
		Sfx.count(&"hurt") == 0 and Sfx.count(&"stomp") == 1 and not goblin_a.visible)

	# Walking into a goblin: a heart, a knockback away from it, and it stays.
	await _wait_until(func() -> bool:
		return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor() and not _rudy.is_invulnerable(), 120)
	_reset_counts()
	_teleport(Vector2(goblin_b.global_position.x - 250.0, ground_y))
	await _frames(2)
	Input.action_press(&"move_right")
	await _wait_until(func() -> bool: return _rudy.hearts < 3, 120)
	Input.action_release(&"move_right")
	_check("walking into a goblin costs a heart and knocks him back from it; the goblin stays",
		_rudy.hearts == 2 and Sfx.count(&"hurt") == 1 and Sfx.count(&"stomp") == 0
		and _rudy.velocity.x < 0.0 and not goblin_b.dead,
		"hearts %d, speed %.0f" % [_rudy.hearts, _rudy.velocity.x])

	# Landing on two goblins in the same tick: two stomp sounds, no hit.
	await _wait_until(func() -> bool:
		return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor() and not _rudy.is_invulnerable(), 120)
	for goblin: Goblin in [goblin_b, goblin_c]:
		goblin.speed = 0.0
	goblin_b.position.x = 2200.0 # clear of the spikes, the first patrol and the pickup
	goblin_c.position.x = 2240.0
	_reset_counts()
	_teleport(Vector2(2220.0, ground_y - Goblin.HEIGHT - 60.0))
	_rudy.velocity = Vector2(0, 200)
	await _frames(1) # is_on_floor() is stale until his next move
	await _wait_until(func() -> bool: return goblin_b.dead or goblin_c.dead or _rudy.is_on_floor(), 60)
	await _frames(2)
	_check("landing on two goblins in the same tick: two stomp sounds, no hit",
		goblin_b.dead and goblin_c.dead and Sfx.count(&"stomp") == 2 and Sfx.count(&"hurt") == 0,
		"stomp sounds %d, hurt sounds %d" % [Sfx.count(&"stomp"), Sfx.count(&"hurt")])
	for goblin: Goblin in [goblin_b, goblin_c]:
		goblin.speed = 100.0

	# A fall: every goblin comes back, and it costs a heart.
	await _frames(30)
	var hearts_before := _rudy.hearts
	_teleport(Vector2(4400.0, 700.0)) # over the first cliff, past the waystone without touching it
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 120)
	await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	var back := PackedStringArray()
	for goblin in goblins:
		if not goblin.dead and goblin.visible:
			back.append(goblin.name)
	_check("after a death every goblin is back, the defeated ones too", back.size() == goblins.size(),
		"back: %s" % ", ".join(back))
	var homes: Array[float] = [1500.0, 3000.0, 5600.0] # where level_1.tscn starts them
	var in_patrol := true
	for i in goblins.size():
		var x := goblins[i].position.x
		if x < homes[i] or x > homes[i] + goblins[i].patrol_distance:
			in_patrol = false
	_check("each goblin is back in its own patrol", in_patrol,
		"x %.0f, %.0f, %.0f" % [goblin_a.position.x, goblin_b.position.x, goblin_c.position.x])
	_check("a fall costs a heart and does not refill the others",
		hearts_before == 2 and _rudy.hearts == 1 and hud.hearts_shown() == 1,
		"hearts before %d, after %d" % [hearts_before, _rudy.hearts])

	# A stomp at full falling speed: from the top of a jump onto a goblin.
	await _wait_until(func() -> bool:
		return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor() and not _rudy.is_invulnerable(), 120)
	goblin_a.speed = 0.0
	_reset_counts()
	var apex := _expected_jump().x
	_teleport(Vector2(goblin_a.global_position.x, ground_y - apex))
	await _frames(1)
	var landing_speed := 0.0
	for i in 60:
		landing_speed = _rudy.velocity.y
		await _frames(1)
		if goblin_a.dead or _rudy.is_on_floor():
			break
	_check("falling from the top of a jump onto a goblin still counts as a stomp, not a hit",
		goblin_a.dead and Sfx.count(&"stomp") == 1 and Sfx.count(&"hurt") == 0,
		"falling at %.0f px/s; stomp sounds %d, hurt sounds %d" % [landing_speed, Sfx.count(&"stomp"), Sfx.count(&"hurt")])
	goblin_a.speed = 100.0

	# A fall that takes his last heart starts the level over from the opening,
	# even after the waystone was lit.
	var waystone: Waystone = level.get_node("Waystone")
	await _wait_until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor(), 120)
	_teleport(Vector2(waystone.global_position.x - 200.0, ground_y))
	await _frames(2)
	await _hold_until(&"move_right", func() -> bool:
		return _rudy.global_position.x > waystone.spawn_point.global_position.x, 120)
	var lit_before := waystone.lit and _main.checkpoint_name == "waystone"
	_reset_counts()
	hearts_before = _rudy.hearts
	_teleport(Vector2(4400.0, 700.0))
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 120)
	var hearts_at_fall := _rudy.hearts
	await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("a fall that takes his last heart starts the level over: at the start, three hearts, the waystone dark",
		lit_before and hearts_before == 1 and hearts_at_fall == 0
		and _rudy.global_position.distance_to(start) < 1.0 and _rudy.hearts == 3 and hud.hearts_shown() == 3
		and not waystone.lit and _main.checkpoint_name == "start"
		and Sfx.count(&"fall") == 1 and Sfx.count(&"hurt") == 0,
		"waystone lit before %s; hearts %d -> %d at the fall -> %d; at x %.0f; waystone lit now %s" % [
			lit_before, hearts_before, hearts_at_fall, _rudy.hearts, _rudy.global_position.x, waystone.lit])
	var all_alive := true
	for goblin in goblins:
		all_alive = all_alive and not goblin.dead and goblin.visible
	_check("starting over brings every goblin back", all_alive)
	await _wait_until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor(), 120)
	_teleport(Vector2(waystone.global_position.x - 200.0, ground_y))
	await _frames(2)
	await _hold_until(&"move_right", func() -> bool:
		return _rudy.global_position.x > waystone.spawn_point.global_position.x, 120)
	_check("after starting over, the waystone lights again", waystone.lit and Sfx.count(&"checkpoint") == 1,
		"checkpoint sounds %d" % Sfx.count(&"checkpoint"))

	# Hits that take his last heart start the level over too, even after the waystone.
	var spikes_b: Spikes = level.get_node("Hazards/SpikesB")
	_reset_counts()
	for i in 3:
		await _wait_until(func() -> bool:
			return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor() and not _rudy.is_invulnerable(), 120)
		var hearts_now := _rudy.hearts
		_teleport(Vector2(spikes_b.global_position.x, ground_y))
		await _wait_until(func() -> bool: return _rudy.hearts < hearts_now, 30)
	var defeated := _main.state == Main.State.DYING and _rudy.mode == Rudy.Mode.DEFEATED and Sfx.count(&"hurt") == 3
	await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("hits that take his last heart start the level over too: at the start, three hearts, the waystone dark",
		defeated and _rudy.global_position.distance_to(start) < 1.0 and _rudy.hearts == 3
		and not waystone.lit and _main.checkpoint_name == "start",
		"defeated %s; at x %.0f; hearts %d; waystone lit %s" % [defeated, _rudy.global_position.x, _rudy.hearts, waystone.lit])


func _run_1d() -> void:
	_main.queue_free()
	await _frames(1)
	_start_level()
	await _frames(5)
	var level: Node2D = _main.get_node("Level1")
	var pickup: SwordPickup = level.get_node("SwordPickup")
	var spikes: Spikes = level.get_node("Hazards/SpikesA")
	var goblin_b: Goblin = level.get_node("Enemies/GoblinB")
	var goblin_c: Goblin = level.get_node("Enemies/GoblinC")
	var start := (level.get_node("StartPoint") as Marker2D).global_position
	var ground_y := start.y
	_check("Rudy starts without gear, in the default form",
		_rudy.gear == Rudy.Gear.NONE and _rudy.pose == &"CHAR-IDLE", _rudy.pose)

	# Without the sword, slash does nothing.
	_reset_counts()
	await _tap(&"slash")
	await _frames(20)
	_check("without the sword, slash does nothing", Sfx.count(&"slash") == 0 and not _rudy.is_slashing())

	# The pickup: the sword form, one pickup sound, and it is gone.
	_reset_counts()
	_teleport(Vector2(pickup.global_position.x - 200.0, ground_y))
	await _frames(2)
	await _hold_until(&"move_right", func() -> bool: return _rudy.gear == Rudy.Gear.SWORD, 120)
	await _frames(2)
	_check("touching the pickup gives him the sword and shield, with one pickup sound; it disappears",
		_rudy.gear == Rudy.Gear.SWORD and Sfx.count(&"pickup") == 1 and pickup.taken and not pickup.visible,
		"pickup sounds %d" % Sfx.count(&"pickup"))
	_check("with the sword he shows the sword form's poses", String(_rudy.pose).begins_with("CHAR-SWORD-"), _rudy.pose)
	await _hold(&"move_left", 40)
	await _hold(&"move_right", 40)
	_check("crossing the pickup's place again gives nothing more", Sfx.count(&"pickup") == 1)

	# One tap: one swing and one slash sound; the swing ends after slash_time.
	await _wait_until(func() -> bool: return _rudy.is_on_floor() and _rudy.velocity.x == 0.0, 60)
	_reset_counts()
	await _tap(&"slash")
	_check("a tap swings the sword once (CHAR-SWORD-SLASH), with one slash sound",
		Sfx.count(&"slash") == 1 and _rudy.pose == &"CHAR-SWORD-SLASH", "pose %s" % _rudy.pose)
	var swing_ticks: int = await _wait_until(func() -> bool: return not _rudy.is_slashing(), 60)
	await _frames(1)
	_check("the swing ends after about slash_time, back in CHAR-SWORD-IDLE",
		_rudy.pose == &"CHAR-SWORD-IDLE" and absf((swing_ticks + 2) / 60.0 - _rudy.slash_time) <= 2.0 / 60.0,
		"%.2f s; pose %s" % [(swing_ticks + 2) / 60.0, _rudy.pose])

	# Holding the key: one swing. Mashing it: one sound per swing.
	_reset_counts()
	await _hold(&"slash", 60)
	await _frames(30)
	_check("holding slash swings once", Sfx.count(&"slash") == 1, "slash sounds %d" % Sfx.count(&"slash"))
	_reset_counts()
	var swings := 0
	var was_slashing := false
	for i in 120:
		if i % 2 == 0:
			Input.action_press(&"slash")
		else:
			Input.action_release(&"slash")
		await _frames(1)
		if _rudy.is_slashing() and not was_slashing:
			swings += 1
		was_slashing = _rudy.is_slashing()
	Input.action_release(&"slash")
	await _frames(30)
	_check("mashing slash: one slash sound per swing, and no swing starts during another",
		swings >= 3 and Sfx.count(&"slash") == swings and swings <= ceili(2.0 / _rudy.slash_time),
		"%d swings in 2 s, slash sounds %d" % [swings, Sfx.count(&"slash")])

	# A cut in reach defeats a goblin in one hit: no stomp sound, no hit.
	goblin_b.speed = 0.0
	goblin_c.speed = 0.0
	await _wait_until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY and not _rudy.is_slashing(), 60)
	_reset_counts()
	_teleport(Vector2(goblin_b.global_position.x - 70.0, ground_y))
	await _frames(2)
	await _tap(&"slash")
	await _wait_until(func() -> bool: return not _rudy.is_slashing(), 60)
	_check("a cut in reach defeats a goblin in one hit, with no stomp sound and no hit",
		goblin_b.dead and Sfx.count(&"stomp") == 0 and Sfx.count(&"hurt") == 0 and Sfx.count(&"slash") == 1,
		"dead %s; stomp %d, hurt %d" % [goblin_b.dead, Sfx.count(&"stomp"), Sfx.count(&"hurt")])

	# The cut reaches only in front of him, and only so far.
	_teleport(Vector2(goblin_c.global_position.x + 70.0, ground_y)) # the goblin behind him
	await _frames(2)
	await _tap(&"slash")
	await _wait_until(func() -> bool: return not _rudy.is_slashing(), 60)
	var behind_alive := not goblin_c.dead
	_teleport(Vector2(goblin_c.global_position.x - 150.0, ground_y)) # in front, out of reach
	await _frames(2)
	await _tap(&"slash")
	await _wait_until(func() -> bool: return not _rudy.is_slashing(), 60)
	_check("a cut misses a goblin behind him, and one 150 px ahead", behind_alive and not goblin_c.dead)
	_teleport(Vector2(goblin_c.global_position.x + 70.0, ground_y))
	await _frames(2)
	await _tap(&"move_left") # a tap turns him on the spot
	await _frames(2)
	await _tap(&"slash")
	await _wait_until(func() -> bool: return not _rudy.is_slashing(), 60)
	_check("turned around, the cut reaches the goblin that was behind him", _rudy.facing == -1 and goblin_c.dead,
		"facing %d, dead %s" % [_rudy.facing, goblin_c.dead])
	goblin_b.speed = 100.0
	goblin_c.speed = 100.0

	# A hit while he carries the gear: it flies off instead of a heart.
	await _wait_until(func() -> bool:
		return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor() and not _rudy.is_invulnerable(), 120)
	var hearts_before := _rudy.hearts
	_reset_counts()
	_teleport(Vector2(spikes.global_position.x - 220.0, ground_y))
	await _frames(2)
	Input.action_press(&"move_right")
	await _wait_until(func() -> bool: return _rudy.gear == Rudy.Gear.NONE, 120)
	Input.action_release(&"move_right")
	var flying := 0
	for child in _main.get_children():
		if child is FlyingGear:
			flying += 1
	_check("a hit while he carries the gear knocks it away instead of a heart, with one hurt sound",
		_rudy.gear == Rudy.Gear.NONE and _rudy.hearts == hearts_before and Sfx.count(&"hurt") == 1
		and _rudy.mode == Rudy.Mode.HURT,
		"hearts %d -> %d, hurt sounds %d" % [hearts_before, _rudy.hearts, Sfx.count(&"hurt")])
	_check("the sword and shield fly off", flying == 1, "%d flying" % flying)
	await _wait_until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY, 60)
	await _frames(40)
	flying = 0
	for child in _main.get_children():
		if child is FlyingGear:
			flying += 1
	_check("they fade and are gone; he is back in the default form; the pickup stays away",
		flying == 0 and not String(_rudy.pose).begins_with("CHAR-SWORD-") and not pickup.visible,
		"%d flying, pose %s" % [flying, _rudy.pose])

	# Without the gear, the next hit costs a heart.
	await _wait_until(func() -> bool: return not _rudy.is_invulnerable(), 120)
	_teleport(Vector2(spikes.global_position.x, ground_y))
	await _wait_until(func() -> bool: return _rudy.hearts < hearts_before, 30)
	_check("without the gear, the next hit costs a heart", _rudy.hearts == hearts_before - 1 and Sfx.count(&"hurt") == 2)

	# A death brings the pickup back, and he gets back up without gear.
	await _wait_until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor(), 120)
	_teleport(Vector2(4400.0, 700.0)) # a fall over the first cliff, past the waystone
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 120)
	await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("after a death the pickup is back where it was", pickup.visible and not pickup.taken)
	_reset_counts()
	_teleport(Vector2(pickup.global_position.x - 200.0, ground_y))
	await _frames(2)
	await _hold_until(&"move_right", func() -> bool: return _rudy.gear == Rudy.Gear.SWORD, 120)
	var had_sword := _rudy.gear == Rudy.Gear.SWORD and Sfx.count(&"pickup") == 1
	await _wait_until(func() -> bool: return _rudy.is_on_floor(), 60)
	_teleport(Vector2(4400.0, 700.0)) # his last heart: the level starts over
	await _wait_until(func() -> bool: return _main.state == Main.State.DYING, 120)
	await _wait_until(func() -> bool: return _main.state == Main.State.PLAYING, 300)
	_check("he gets back up without gear, even when he fell with it, and the pickup is back",
		had_sword and _rudy.gear == Rudy.Gear.NONE and pickup.visible and _rudy.pose == &"CHAR-IDLE",
		"had the sword %s; gear %s; pose %s" % [had_sword, Rudy.Gear.keys()[_rudy.gear], _rudy.pose])


func _run_2a() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/rudy/frames/frames.json"))
	var canvas := Vector2(manifest.canvas[0], manifest.canvas[1])
	var origin := Vector2(manifest.origin[0], manifest.origin[1])
	var density: float = manifest.density
	var problems: PackedStringArray = []
	for id: String in manifest.frames:
		var frame: Texture2D = RudyLook.FRAMES.get(StringName(id))
		if frame == null:
			problems.append("%s missing" % id)
		elif Vector2(frame.get_size()) != canvas:
			problems.append("%s is %s" % [id, frame.get_size()])
		elif not FileAccess.get_file_as_string(frame.resource_path + ".import").contains("mipmaps/generate=true"):
			problems.append("%s has no mipmaps" % id)
	_check("every frame in frames.json is in Rudy's look, at the canvas size, with mipmaps",
		problems.is_empty() and RudyLook.FRAMES.size() == manifest.frames.size(), ", ".join(problems))

	var look: RudyLook = _rudy.get_node("Look")
	var sprite: Sprite2D = look.get_node("Sprite")
	_check("each frame is drawn at 1/density with its body origin on Rudy's origin (his soles)",
		not sprite.centered and sprite.position == Vector2.ZERO and sprite.offset == -origin
		and sprite.scale == Vector2.ONE / density,
		"offset %s, scale %s; frames.json origin %s, density %s" % [sprite.offset, sprite.scale, origin, density])
	var material := sprite.material as ShaderMaterial
	_check("the frames draw with linear mipmap filtering and the 4 px outline",
		look.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		and sprite.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE
		and material != null and material.shader.resource_path == "res://systems/art/outline.gdshader"
		and is_equal_approx(material.get_shader_parameter(&"width"), 4.0 * density),
		"filter %d, width %s" % [look.texture_filter, material.get_shader_parameter(&"width") if material else null])

	# Every pose the controller can pick: every frame but the block, which waits for step 4.
	var not_taken: PackedStringArray = []
	for id: StringName in RudyLook.FRAMES:
		if id != &"CHAR-SWORD-BLOCK" and not _poses_taken.has(id):
			not_taken.append(id)
	_check("every pose he took in the checks showed its own frame, and he took all fifteen",
		_frame_mismatches.is_empty() and not_taken.is_empty(),
		"; ".join(_frame_mismatches) + ("" if not_taken.is_empty() else " not taken: " + ", ".join(not_taken)))


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


## Holds right and jumps over each cliff, row of spikes and live goblin ahead,
## until the level is complete. Returns the ticks it took, or -1 if he died or
## ran out of time.
func _run_route(gaps: Array[Vector2], max_ticks: int) -> int:
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
		if release_jump_at < t and _rudy.is_on_floor() and _obstacle_ahead(gaps):
			Input.action_press(&"jump")
			release_jump_at = t + 3
	Input.action_release(&"move_right")
	Input.action_release(&"jump")
	return -1


## True when a cliff, a row of spikes or a live goblin starts close enough ahead
## that the route should jump now.
func _obstacle_ahead(gaps: Array[Vector2]) -> bool:
	var x := _rudy.global_position.x
	for gap in gaps:
		if x >= gap.x - CLIFF_LEAD and x < gap.x:
			return true
	for spikes in _main.get_node("Level1/Hazards").get_children():
		var left := (spikes as Node2D).global_position.x - Spikes.WIDTH / 2.0
		if x >= left - SPIKES_LEAD and x < left:
			return true
	for goblin in _main.get_node("Level1/Enemies").get_children():
		if not (goblin as Goblin).dead:
			var left := (goblin as Node2D).global_position.x - 28.0
			if x >= left - GOBLIN_LEAD and x < left:
				return true
	return false


## Switches the spikes and the goblins on or off, for checks of movement alone.
func _set_threats(enabled: bool) -> void:
	for path: String in ["Level1/Hazards", "Level1/Enemies"]:
		_main.get_node(path).process_mode = Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED


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
