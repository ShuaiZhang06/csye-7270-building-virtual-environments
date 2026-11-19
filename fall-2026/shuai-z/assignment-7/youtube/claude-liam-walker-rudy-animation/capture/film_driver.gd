extends Node
## Film-only autoload, added to an isolated copy of game/ (never to the project
## itself). The real main scene, res://app/main.tscn, boots as F5 runs it; this
## node presses the game's input actions with Input.action_press(), the way
## checks.gd does. It never calls Rudy's, RudyLook's or the AnimationPlayer's
## methods, never places anything, and assigns nothing in the game: it only
## presses keys and reads state.
##
## Each drawn frame it prints what that frame shows (after the frame's last
## physics tick): Rudy's place, mode and gear, the clip the AnimationPlayer
## plays and its position, the Sprite's cell, whether the rig shows, Grip's
## angle, whether the hitbox is live, the swing tick, goblin B and the hearts.
## Each physics tick it prints a "tick" line when something the film labels
## happens: a fresh slash or jump press that Rudy reads, a new swing, a hit.
##
## Takes (user argument take=1, 2 or 3, after "--"):
##  1: the title; Enter; the run (spikes, goblin A); the sword picked up while
##     running; a stop; one slash; a slash with the slash key pressed again on
##     swing ticks 1, 5 and 13 (startup, active, recovery: ignored); a jump on
##     swing tick 5 (the swing plays on in the air); run, slash, run (left);
##     then goblin B walks into his back on swing tick 1: a hit in STARTUP.
##  2: the same route to goblin B, then a hit on swing tick 5: ACTIVE.
##  3: the same, then a hit on swing tick 13: RECOVERY.
## Waits are in physics ticks (60 a second).
##
## The window. On macOS Godot skips drawing while its window is covered or off
## the visible desktop, and Movie Maker then writes the last image again while
## the game runs on. So under Movie Maker the driver prints a "draw" line when
## DisplayServer.window_can_draw() changes, and ends the take at once (exit 3)
## if it turns false: that take is void and is recorded again.

const HIT_TICK := {1: 1, 2: 5, 3: 13} ## the swing tick each take aims its hit at
const GOBLIN_STEP := 100.0 / 60.0 ## px goblin B walks per tick (goblin.gd: speed 100 px/s)

var take := 1
var contact_dx := 40.0 ## measured in the dry runs: the gap at which goblin B's box first touches him

var _main: Node
var _rudy: Node
var _look: Node2D
var _player: AnimationPlayer
var _sprite: Sprite2D
var _rig: Node2D
var _grip: Node2D
var _sword_box: CollisionShape2D
var _goblin_a: Node2D
var _goblin_b: Node2D
var _frame := 0
var _tick := 0
var _last_swing := -1
var _last_mode := -1
var _schedule: Array = [] ## [action, swing tick] presses still to make
var _start_swing := false ## press slash at the end of this tick, read on the next
var _hit_aim := -1 ## the swing tick goblin B should touch him on, or -1
var _held: Array[StringName] = [] ## actions the scheduler pressed last tick
var _movie := "--write-movie" in OS.get_cmdline_args()
var _can_draw := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 1000 # print after every other _process()
	process_physics_priority = 1000 # read each tick after Rudy's _physics_process()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("take="):
			take = int(arg.substr(5))
		if arg.begins_with("contact="):
			contact_dx = float(arg.substr(8))
	await get_tree().process_frame
	_main = get_tree().current_scene
	_rudy = _main.get_node("Rudy")
	_look = _rudy.get_node("Look")
	_player = _look.get_node("AnimationPlayer")
	_sprite = _look.get_node("Sprite")
	_rig = _look.get_node("SlashRig")
	_grip = _rig.get_node("Lean/Grip")
	_sword_box = _rudy.get_node("SwordHitbox/Shape")
	_goblin_a = _main.get_node("Level1/Enemies/GoblinA")
	_goblin_b = _main.get_node("Level1/Enemies/GoblinB")
	_rudy.hit.connect(_on_hit)
	print("take %d, aiming the hit at swing tick %d, contact gap %.1f px" % [take, HIT_TICK[take], contact_dx])
	_play()


func _swing_tick() -> int:
	var clock: float = _rudy._slash_clock # read only
	return roundi(clock * 60.0) if clock >= 0.0 else -1


func _physics_process(_delta: float) -> void:
	if _rudy == null:
		return
	# After Rudy's tick: his clock has advanced, so the tick just shown is one less.
	var shown := _swing_tick() - 1 if _swing_tick() > 0 else -1
	if _swing_tick() == -1 and _rudy.is_slashing() == false and _last_swing >= 0 and _rudy.mode == 1:
		print("tick %d: the swing ended after swing tick %d" % [_tick, _last_swing])
	if Input.is_action_just_pressed(&"slash"):
		print("tick %d: slash pressed, read on swing tick %s" % [_tick, str(shown) if shown >= 0 else "— (new swing or none)"])
	if Input.is_action_just_pressed(&"jump"):
		print("tick %d: jump pressed, read on swing tick %s, floor %s" % [_tick, str(shown) if shown >= 0 else "—", _rudy.is_on_floor()])
	if _rudy.mode != _last_mode:
		print("tick %d: mode %d -> %d" % [_tick, _last_mode, _rudy.mode])
		_last_mode = _rudy.mode
	_last_swing = shown
	_tick += 1
	# The scheduler. It runs after Rudy's tick, so a press made here is read on his next tick.
	for action in _held:
		Input.action_release(action)
	_held.clear()
	if _start_swing:
		_start_swing = false
		_press(&"slash")
	elif shown >= 0:
		for item in _schedule.duplicate():
			if shown + 1 == item[1]:
				_press(item[0])
				_schedule.erase(item)
	if _hit_aim >= 0 and _rudy.mode == 1 and not _rudy.is_slashing():
		# Goblin B moves before Rudy each tick; it touches him on the first tick its gap is at most contact_dx.
		var gap: float = _rudy.global_position.x - _goblin_b.global_position.x
		var ticks_to_contact := ceili((gap - contact_dx) / GOBLIN_STEP)
		if ticks_to_contact == _hit_aim + 1:
			print("tick %d: gap %.2f px, contact predicted in %d ticks: slash" % [_tick - 1, gap, ticks_to_contact])
			_press(&"slash")
			_hit_aim = -1


func _press(action: StringName) -> void:
	Input.action_release(action)
	Input.action_press(action)
	_held.append(action)


func _on_hit() -> void:
	# The goblin's tick runs before Rudy's, so the hit lands on the swing tick after the last one shown.
	var on_tick := _last_swing + 1 if _last_swing >= 0 else -1
	var phase := "none"
	if on_tick >= 0:
		phase = "STARTUP" if on_tick <= 1 else ("ACTIVE" if on_tick <= 10 else "RECOVERY")
	print("tick %d: HIT by goblin B, gap %.1f px, on swing tick %d (%s)" % [_tick, _goblin_b.global_position.x - _rudy.global_position.x, on_tick, phase])


func _process(_delta: float) -> void:
	if _rudy == null:
		return
	if _movie:
		var can := int(DisplayServer.window_can_draw())
		if can != _can_draw:
			print("draw %d %s" % [_frame, can == 1])
			_can_draw = can
			if can == 0:
				print("step: THE WINDOW CANNOT DRAW from frame %d: this take is void" % _frame)
				get_tree().quit(3)
	var rx: float = _rudy.global_position.x
	print("frame %d x %.1f y %.1f mode %d gear %d facing %d floor %s clip %s pos %.4f cell %d rig %s grip %.2f live %s swing %d gB %.1f gBf %d hearts %d paused %s" % [
		_frame, rx, _rudy.global_position.y, _rudy.mode, _rudy.gear, _rudy.facing, _rudy.is_on_floor(),
		_player.current_animation, _player.current_animation_position, _sprite.frame, _rig.visible,
		_grip.rotation_degrees, not _sword_box.disabled, _swing_tick() - 1 if _swing_tick() > 0 else -1,
		_goblin_b.global_position.x, _goblin_b.facing, _rudy.hearts, get_tree().paused])
	_frame += 1


func _play() -> void:
	await _ticks(60 if take == 1 else 30)
	print("step: Enter on the title")
	await _tap(&"restart")
	await _ticks(40 if take == 1 else 20)
	print("step: run right")
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.global_position.x >= 930.0, 300)
	print("step: jump the first spikes")
	await _tap(&"jump")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.global_position.x > 1150.0, 120)
	print("step: landed; on towards the first goblin")
	await _until(func() -> bool: return _goblin_a.global_position.x - _rudy.global_position.x < 190.0, 300)
	print("step: jump over the first goblin")
	await _tap(&"jump")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.global_position.x > _goblin_a.global_position.x + 60.0, 120)
	print("step: landed; on to the sword")
	await _until(func() -> bool: return _rudy.gear != 0, 400)
	print("step: the sword, picked up while running")
	await _until(func() -> bool: return _rudy.global_position.x >= 2620.0, 60)
	Input.action_release(&"move_right")
	print("step: stop")
	await _ticks(40)
	if take == 1:
		await _take_one_middle()
	await _goblin_from_behind()
	await _ticks(55) # quit before goblin B, still walking, touches him again

	print("step: quit")
	get_tree().quit()


## Take 1 only: the slash standing, re-pressed, with a jump, and on the run.
func _take_one_middle() -> void:
	print("step: one slash, standing")
	await _tap(&"slash")
	await _ticks(45)
	print("step: a slash, with the slash key pressed again on swing ticks 1, 5 and 13")
	await _press_on_swing_ticks(&"slash", [1, 5, 13])
	await _ticks(45)
	print("step: a slash, and a jump on swing tick 5")
	await _press_on_swing_ticks(&"jump", [5])
	await _until(func() -> bool: return _rudy.is_on_floor(), 120)
	await _ticks(40)
	print("step: run left, slash while running, run on")
	Input.action_press(&"move_left")
	await _ticks(34)
	await _tap(&"slash")
	await _ticks(40)
	Input.action_release(&"move_left")
	print("step: stop")
	await _ticks(40)


## Starts a swing and presses `action` so that Rudy reads it on each of
## `swing_ticks`, through the per-tick scheduler (_physics_process).
func _press_on_swing_ticks(action: StringName, swing_ticks: Array) -> void:
	_schedule.clear()
	for k: int in swing_ticks:
		_schedule.append([action, k])
	_start_swing = true
	await _until(func() -> bool: return _schedule.is_empty() and not _rudy.is_slashing(), 120)
	await _ticks(2)


## Goblin B, walking right, comes up behind him; the slash is timed so that its
## box touches him on swing tick HIT_TICK[take].
func _goblin_from_behind() -> void:
	print("step: wait until goblin B walks right, near the start of its patrol")
	await _until(func() -> bool: return _goblin_b.facing == 1 and _goblin_b.global_position.x < 3060.0, 700)
	print("step: run right towards goblin B")
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _goblin_b.global_position.x - _rudy.global_position.x < 190.0, 300)
	print("step: jump over goblin B")
	await _tap(&"jump")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.global_position.x > _goblin_b.global_position.x + 60.0, 120)
	Input.action_release(&"move_right")
	print("step: landed beyond goblin B; stop, facing away from it")
	await _until(func() -> bool: return absf(_rudy.velocity.x) <= 1.0, 30)
	print("step: goblin B walks up behind him; slash timed for a hit on swing tick %d" % HIT_TICK[take])
	_hit_aim = HIT_TICK[take]
	await _until(func() -> bool: return _rudy.mode != 1, 400)


func _ticks(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _until(condition: Callable, max_ticks: int) -> void:
	for i in max_ticks:
		if condition.call():
			return
		await get_tree().physics_frame
	print("step: TIMED OUT")


func _tap(action: StringName) -> void:
	Input.action_press(action)
	await _ticks(2)
	Input.action_release(action)
