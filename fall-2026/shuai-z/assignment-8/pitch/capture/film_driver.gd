extends Node
## Film-only autoload for the Assignment 8 pitch film. It is added to an isolated
## copy of game/ exported from tag a7 (`git archive a7`), never to the project
## itself. Adapted by Claude Code from Assignment 7's capture/film_driver.gd.
##
## The real main scene, res://app/main.tscn, boots as F5 runs it. This node
## presses the game's input actions with Input.action_press(), the way
## checks.gd does, and reads state. It never calls a game method, places
## nothing and assigns nothing in the game: it only presses keys and reads.
##
## Each drawn frame it prints one "frame N ..." line of what that frame shows
## (Rudy's place, mode, gear and hearts, the level's state, the pause, the
## title and end card, each goblin, the waystone). Each physics tick it prints
## an "event" line when something the film names happens: a jump or slash
## read, a stomp or slash defeat, a hit, the waystone lit, a fall, the
## respawn, the circle, the pause.
##
## Takes (user argument take=run, mech or pause, after "--"):
##  run:   the title; Enter; a clean run of Level 1 to the teleport circle: the
##         first spikes jumped, goblin A stomped, the sword picked up, goblin B
##         slashed, the waystone lit, the first cliff, the second spikes,
##         goblin C slashed, the second cliff, the circle, the end card.
##         The film cuts C1 (the opening), C2 (waystone to end card) and C4
##         (all of it) from this one take.
##  mech:  the same to the second spikes, without slashing goblin C; Rudy runs
##         into goblin C, and its touch knocks the sword away; a second touch,
##         once he can be hit again, costs a heart; he jumps over goblin C if
##         it is ahead of him (in the dry run the knockback left it behind
##         him), and runs off the second cliff without jumping; the fall costs
##         a heart; he gets up at the waystone. The film's C3.
##  pause: the title; Enter; a short run; Esc: "Paused"; Esc: resume; the first
##         spikes jumped; goblin A touches him three times without the sword;
##         the last heart is lost; the level starts over at the start with full
##         hearts. The film's C5.
## Waits are in physics ticks (60 a second).
##
## The window. On macOS Godot skips drawing while its window is covered or off
## the visible desktop, and Movie Maker then writes the last image again while
## the game runs on. Under Movie Maker (OS.has_feature("movie"); Assignment 7's
## CAPTURE.md found that the command-line test never fired) the driver prints
## a "draw" line when DisplayServer.window_can_draw() changes, and ends the
## take at once (exit 3) if it turns false: that take is void.

const SPIKES_A := 1065.0
const SPIKES_B := 5180.0
const CLIFF_1 := 4300.0 ## the first ground segment's right edge
const CLIFF_2 := 6400.0 ## the second ground segment's right edge
const JUMP_BEFORE_SPIKES := 165.0 ## px before a row's middle: clear of its box from 20 px after take-off to 360 px
const JUMP_BEFORE_CLIFF := 90.0 ## px before an edge: the jump lands about 290 px past it
const STOMP_TIME := 0.60 ## s from take-off until his soles come down to a goblin's top (118 px)
## px between Rudy and where the goblin will be in STOMP_TIME, when he jumps. Measured in the
## headless dry runs: 336 and below cleared goblin A without touching it; 350 to 400 stomped it
## (at 410 and above he jumps on landing from the spikes). 375 is the middle of that range.
const STOMP_REACH := 375.0
const SLASH_GAP := 115.0 ## px to a goblin ahead when the slash is pressed: its box is live from the second tick
const JUMP_OVER_GAP := 190.0 ## px to a goblin ahead when he jumps over it (Assignment 7's driver)
const STATES := ["TITLE", "PLAYING", "DYING", "COMPLETE"]

var take := "run"
var title_hold := 90 ## ticks on the title before Enter
var stomp_reach := STOMP_REACH

var _main: Node
var _rudy: Node
var _hud: Node
var _waystone: Node
var _goblins: Dictionary = {}
var _frame := 0
var _tick := 0
var _movie := OS.has_feature("movie")
var _can_draw := -1
var _last := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = 1000 # print after every other _process()
	process_physics_priority = 1000 # read each tick after Rudy's and the goblins' _physics_process()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("take="):
			take = arg.substr(5)
		elif arg.begins_with("hold="):
			title_hold = int(arg.substr(5))
		elif arg.begins_with("reach="):
			stomp_reach = float(arg.substr(6))
	await get_tree().process_frame
	_main = get_tree().current_scene
	_rudy = _main.get_node("Rudy")
	_hud = _main.get_node("Hud")
	_waystone = _main.get_node("Level1/Waystone")
	for g in ["A", "B", "C"]:
		_goblins[g] = _main.get_node("Level1/Enemies/Goblin" + g)
	_rudy.hit.connect(func() -> void: print("event tick %d: HIT, hearts %d, gear %d, x %.1f" % [_tick, _rudy.hearts, _rudy.gear, _rudy.global_position.x]))
	_rudy.defeated.connect(func() -> void: print("event tick %d: DEFEATED (last heart)" % _tick))
	_rudy.respawned.connect(func() -> void: print("event tick %d: respawned at x %.1f, hearts %d" % [_tick, _rudy.global_position.x, _rudy.hearts]))
	_waystone.activated.connect(func(_w: Node) -> void: print("event tick %d: waystone lit, x %.1f" % [_tick, _rudy.global_position.x]))
	_main.get_node("Level1/Portal").reached.connect(func() -> void: print("event tick %d: teleport circle reached, x %.1f" % [_tick, _rudy.global_position.x]))
	print("take %s, title hold %d ticks, stomp reach %.1f px, movie %s" % [take, title_hold, stomp_reach, _movie])
	match take:
		"run":
			await _take_run()
		"mech":
			await _take_mech()
		"pause":
			await _take_pause()
		_:
			print("step: UNKNOWN TAKE")
	print("step: quit")
	get_tree().quit()


func _physics_process(_delta: float) -> void:
	if _rudy == null:
		return
	var now := {"mode": _rudy.mode, "hearts": _rudy.hearts, "gear": _rudy.gear, "state": _main.state,
		"slashing": _rudy.is_slashing(), "paused": get_tree().paused, "floor": _rudy.is_on_floor()}
	for g in _goblins:
		now["dead" + g] = _goblins[g].dead
	for key in now:
		if _last.has(key) and _last[key] != now[key]:
			var value = now[key]
			if key == "state":
				value = STATES[value]
			print("event tick %d: %s -> %s (x %.1f)" % [_tick, key, str(value), _rudy.global_position.x])
	_last = now
	_tick += 1


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
	var gob := ""
	for g in _goblins:
		var n: Node2D = _goblins[g]
		gob += " g%s %.1f%s" % [g, n.global_position.x, " dead" if n.dead else ""]
	print("frame %d x %.1f y %.1f mode %d gear %d hearts %d facing %d state %s cp %s paused %s title %s end %s way %s%s" % [
		_frame, _rudy.global_position.x, _rudy.global_position.y, _rudy.mode, _rudy.gear, _rudy.hearts,
		_rudy.facing, STATES[_main.state], _main.checkpoint_name, get_tree().paused,
		_hud.is_showing_title(), _hud.is_showing_end_card(), _waystone.lit, gob])
	_frame += 1


# --- the takes ---------------------------------------------------------------

func _take_run() -> void:
	await _opening()
	await _goblin_b()
	await _to_waystone_and_cliff_1()
	await _spikes(SPIKES_B)
	await _slash_goblin(_goblins["C"], "C")
	print("step: the second cliff")
	await _until(func() -> bool: return _rudy.global_position.x >= CLIFF_2 - JUMP_BEFORE_CLIFF, 600)
	await _tap(&"jump")
	print("step: on to the teleport circle")
	await _until(func() -> bool: return _main.state == 3, 600)
	Input.action_release(&"move_right")
	print("step: the circle; wait for the end card")
	await _until(func() -> bool: return _hud.is_showing_end_card(), 400)
	await _ticks(90)


func _take_mech() -> void:
	await _opening()
	await _goblin_b()
	await _to_waystone_and_cliff_1()
	await _spikes(SPIKES_B)
	var c: Node2D = _goblins["C"]
	print("step: run into goblin C with the sword")
	await _chase(c)
	print("step: knocked back; wait until he can be hit again")
	Input.action_release(&"move_right")
	Input.action_release(&"move_left")
	await _until(func() -> bool: return _rudy.mode == 1 and not _rudy.is_invulnerable(), 200)
	print("step: run into goblin C again, without the sword")
	await _chase(c)
	Input.action_release(&"move_right")
	Input.action_release(&"move_left")
	print("step: knocked back; jump over goblin C while he cannot be hit")
	await _until(func() -> bool: return _rudy.mode == 1, 60)
	if c.global_position.x > _rudy.global_position.x:
		Input.action_press(&"move_right")
		await _until(func() -> bool: return c.global_position.x - _rudy.global_position.x < JUMP_OVER_GAP or c.global_position.x < _rudy.global_position.x, 200)
		await _tap(&"jump")
	else:
		Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.global_position.x > c.global_position.x + 60.0, 200)
	print("step: run off the second cliff without jumping")
	await _until(func() -> bool: return _rudy.global_position.x > CLIFF_2 + 10.0, 400)
	Input.action_release(&"move_right")
	await _until(func() -> bool: return _main.state == 2, 120)
	print("step: the fall; wait for him to get up at the waystone")
	await _until(func() -> bool: return _main.state == 1, 200)
	await _ticks(50)


func _take_pause() -> void:
	await _ticks(title_hold)
	print("step: Enter on the title")
	await _tap(&"restart")
	await _ticks(25)
	print("step: a short run")
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.global_position.x >= 640.0, 120)
	Input.action_release(&"move_right")
	await _until(func() -> bool: return absf(_rudy.velocity.x) <= 1.0, 30)
	await _ticks(10)
	print("step: Esc: pause")
	await _tap(&"pause")
	await _ticks(70)
	print("step: Esc: resume")
	await _tap(&"pause")
	await _ticks(20)
	Input.action_press(&"move_right")
	await _spikes(SPIKES_A)
	var a: Node2D = _goblins["A"]
	for n in 3:
		print("step: run into goblin A, touch %d" % (n + 1))
		await _chase(a)
		Input.action_release(&"move_right")
		Input.action_release(&"move_left")
		if _rudy.hearts <= 0:
			break
		await _until(func() -> bool: return _rudy.mode == 1 and not _rudy.is_invulnerable(), 200)
	print("step: the last heart; wait for the level to start over")
	await _until(func() -> bool: return _main.state == 2, 60)
	await _until(func() -> bool: return _main.state == 1, 240)
	await _ticks(50)


# --- the pieces --------------------------------------------------------------

## The title, Enter, the first spikes, goblin A stomped, the sword picked up.
func _opening() -> void:
	await _ticks(title_hold)
	print("step: Enter on the title")
	await _tap(&"restart")
	await _ticks(25)
	print("step: run right")
	Input.action_press(&"move_right")
	await _spikes(SPIKES_A)
	var a: Node2D = _goblins["A"]
	print("step: stomp goblin A")
	await _until(func() -> bool: return _rudy.is_on_floor() and _predicted_x(a, STOMP_TIME) - _rudy.global_position.x <= stomp_reach, 400)
	print("step: jump at x %.1f, goblin A at %.1f facing %d, predicted %.1f" % [_rudy.global_position.x, a.global_position.x, a.facing, _predicted_x(a, STOMP_TIME)])
	await _tap(&"jump")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.velocity.y >= 0.0 and _rudy.global_position.x > a.global_position.x + 30.0, 120)
	print("step: on to the sword")
	await _until(func() -> bool: return _rudy.gear != 0, 400)
	print("step: the sword, picked up while running, at x %.1f" % _rudy.global_position.x)


func _goblin_b() -> void:
	await _slash_goblin(_goblins["B"], "B")


func _to_waystone_and_cliff_1() -> void:
	print("step: on past the waystone to the first cliff")
	await _until(func() -> bool: return _rudy.global_position.x >= CLIFF_1 - JUMP_BEFORE_CLIFF, 400)
	await _tap(&"jump")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.global_position.x > CLIFF_1 + 220.0, 120)
	print("step: over the first cliff, at x %.1f" % _rudy.global_position.x)


## Runs on and jumps the row of spikes at `middle`.
func _spikes(middle: float) -> void:
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.global_position.x >= middle - JUMP_BEFORE_SPIKES, 400)
	print("step: jump the spikes at %.0f, from x %.1f" % [middle, _rudy.global_position.x])
	await _tap(&"jump")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.global_position.x > middle + 100.0, 120)


## Runs on and slashes the goblin when it is SLASH_GAP ahead.
func _slash_goblin(g: Node2D, name: String) -> void:
	print("step: slash goblin %s" % name)
	await _until(func() -> bool: return g.global_position.x - _rudy.global_position.x <= SLASH_GAP, 600)
	print("step: slash at x %.1f, goblin %s at %.1f facing %d" % [_rudy.global_position.x, name, g.global_position.x, g.facing])
	await _tap(&"slash")
	await _until(func() -> bool: return g.dead or _rudy.mode != 1, 30)
	print("step: goblin %s dead %s, Rudy mode %d" % [name, g.dead, _rudy.mode])


## Runs towards the goblin, whichever side it is on, until it touches him.
func _chase(g: Node2D) -> void:
	var hearts: int = _rudy.hearts
	var gear: int = _rudy.gear
	for i in 600:
		if _rudy.hearts != hearts or _rudy.gear != gear:
			return
		var right: bool = g.global_position.x > _rudy.global_position.x
		if right:
			Input.action_release(&"move_left")
			Input.action_press(&"move_right")
		else:
			Input.action_release(&"move_right")
			Input.action_press(&"move_left")
		await get_tree().physics_frame
	print("step: TIMED OUT chasing")


## Where the goblin will be in `t` seconds, if it does not turn.
func _predicted_x(g: Node2D, t: float) -> float:
	return g.global_position.x + g.facing * g.speed * t


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
