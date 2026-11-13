extends Node
## The edge test (CHANGE-BRIEF.md sections 6 and 9; step 5b). Run from the
## assignment folder:
##   scripts/run-test.sh test_rudy_edges.tscn 60
##   scripts/run-test.sh test_rudy_edges.tscn 30
##
## It works out how many physics ticks a rendered frame holds. With one (60
## fps) it runs E1-E7; with two (30 fps) it runs E1 and E2, once at each tick
## offset. Every edge is checked tick by tick, in physics ticks from the press.
##
## Rules this test keeps (the state test's, test_rudy_states.gd):
## - Each scenario starts a fresh real Main with the title skipped, as
##   checks.gd's _start_level() does (Main.title_shown = true before it is
##   instanced). E3's goblins and E6's pause need it.
## - Setup comes before a scenario's first key, and only then: it may place
##   Rudy at a spot on the level and lets him settle. From the first key on,
##   nothing writes his state, velocity, position, gear, hearts or mode. He
##   takes the sword by walking into the pickup.
## - Input is only InputEventKey events for the project's physical keys D, A,
##   Space, J and Esc, sent with Input.parse_input_event. A fresh press of a
##   key that is still held sends its key-up and key-down together, as the pin
##   does (test_rudy_pin.gd, step 5b).
## - It reads properties (Rudy's _slash_clock among them, read only), and
##   calls only read-only queries: is_on_floor(), get_children(), the
##   AnimationPlayer's current_animation and current_animation_position, and
##   Input's is_action_just_pressed()/is_action_just_released(). It never calls
##   play(), seek(), advance() or a state method.
## - This node is the recorder. Its process_physics_priority is 100, so on
##   every tick it samples after Rudy, his AnimationPlayer and the effects
##   driver: sample N is what tick N left.
##
## Pausing. Esc pauses the tree (Main.toggle_pause, from SystemKeys). So that
## this test and its recorder keep running while the game is paused:
## - this node's process_mode is ALWAYS (set in the scene). Its
##   _physics_process samples every physics tick, paused or not, and marks the
##   ticks on which the tree was paused, when nothing in the game ran;
## - it drives the scenarios with awaits on SceneTree's process_frame and
##   physics_frame signals, which the tree emits while paused;
## - Main is added under the tree's root, not under this node, so it inherits
##   the root's PAUSABLE mode as it does in the game. Under this node it would
##   inherit ALWAYS and never pause.
##
## Ticks. "st" counts from the tick a scenario's first key is read (st 0);
## setup ticks are negative. A swing tick counts the game ticks (ticks the tree
## was not paused) from the tick the press that starts the swing is read.
## At 30 fps a frame holds two ticks: slot a is the first, slot b the second. A
## key sent after a process_frame is read on the next frame's slot a. To have
## it read on slot b, the test awaits one physics_frame from a frame boundary,
## then sends the event and calls Input.flush_buffered_events() (the brief's
## second offset: one process_frame, then one physics_frame, then the event).
## Each swing's own press is read on slot a, so the edge presses read on slot
## a fall on its even swing ticks, and those on slot b on its odd ones.
##
## Prints a per-tick log, the scenarios, then the group EDGES, the ANOMALIES
## (the log lines around each failed check), and a RESULT line; quits 1 on any
## failure.

const MAIN_SCENE := preload("res://app/main.tscn")

const SETTLE_TICKS := 20 ## setup ticks after placing him, before the first key
## The slash (section 2.2, Revision 4): 17 ticks on screen, hitbox live on
## swing ticks 2-10, the swing over on tick 17.
const SWING_TICKS := 17
const LIVE_FIRST := 2
const LIVE_LAST := 10
const TOL := 1e-5
const GRIP_TOL := 0.01
const GRIP_START := -70.0 ## the slash clip's Grip key at 0
const GRIP_ACTIVE_END := 45.0 ## its key at 11/60 s
const GRIP_TRAVEL := 100.0 ## E1: the blade travels at least this far in a new swing
const RUN_FIRST_CELL_TICKS := 8 ## section 7
const RUN_LENGTH := 0.25
const HITBOX_REACH := 50.0 ## rudy.gd slash_reach: the hitbox centre from his
const JUMP_VY := -1500.0

const SWORD_SPOT := Vector2(2400, 840) ## 100 px before the pickup, as the state test's S5
const E3_STOP_X := 2945.0 ## E3: short of goblin B's patrol (x 3000-3400), as S6
const E3_HIT_TICKS: Array[int] = [1, 2, 6, 10, 11, 16] ## startup; active; recovery
const E4_SLASH_ST := 20 ## E4: sword_run has played 12 ticks (cell B) when J is read
const E5_TURN_TICK := 5
const E6_PAUSE_TICK := 5
const E6_PAUSE_FRAMES := 30
const E7_TAPS: Array[int] = [20, 31] ## E7: D released on these st, pressed again on the next
const E7_RELEASE_ST := 45

const KEY_NAME: Dictionary[Key, String] = {KEY_D: "D", KEY_A: "A", KEY_SPACE: "Space", KEY_J: "J", KEY_ESCAPE: "Esc"}
const KEY_ACTION: Dictionary[Key, StringName] = {
	KEY_D: &"move_right", KEY_A: &"move_left", KEY_SPACE: &"jump", KEY_J: &"slash", KEY_ESCAPE: &"pause",
}

var _tick := 0 ## the index the next physics tick will have
var _frame := -1
var _slot := 0
var _tpf := 0 ## physics ticks per rendered frame, measured
var _samples: Array[Dictionary] = []
var _by_t: Dictionary[int, int] = {}
var _sc := "" ## the scenario under way
var _t0: Dictionary[String, int] = {} ## each scenario's first key tick
var _scenarios: Array[Dictionary] = []
var _keys: Array[Dictionary] = []
var _held: Dictionary[Key, bool] = {}
var _waits_failed: Array[String] = []
var _anomalies: Array[Dictionary] = []
var _measured: Array[Dictionary] = [] ## kept as measured, classified, not failures
var _failures := 0
var _checks := 0
var _burst_seen: Dictionary[int, bool] = {}

var _main: Main
var _rudy: Rudy
var _player: AnimationPlayer
var _sprite: Sprite2D
var _rig: Node2D
var _grip: Node2D
var _look: Node2D
var _box: CollisionShape2D
var _bursts: Node2D


func _ready() -> void:
	_run.call_deferred()


func _physics_process(_delta: float) -> void:
	var t := _tick
	_tick += 1
	var f := Engine.get_process_frames()
	if f != _frame:
		_frame = f
		_slot = 0
	else:
		_slot += 1
	if _rudy == null or not is_instance_valid(_rudy):
		return
	var ins := ""
	for code: Key in KEY_ACTION:
		if Input.is_action_just_pressed(KEY_ACTION[code]):
			ins += KEY_NAME[code] + "+"
		if Input.is_action_just_released(KEY_ACTION[code]):
			ins += KEY_NAME[code] + "-"
	var new_bursts := 0
	for b in _bursts.get_children():
		if not _burst_seen.has(b.get_instance_id()):
			_burst_seen[b.get_instance_id()] = true
			new_bursts += 1
	var clip := StringName(_player.current_animation)
	_by_t[t] = _samples.size()
	_samples.append({
		"t": t,
		"sc": _sc,
		"f": f,
		"slot": _slot,
		"paused": get_tree().paused,
		"mode": Rudy.Mode.keys()[_rudy.mode],
		"clip": clip,
		"pos": _player.current_animation_position if clip != &"" else -1.0,
		"clock": _rudy._slash_clock,
		"pose": _rudy.pose,
		"spr": _sprite.visible,
		"rig": _rig.visible,
		"grip": _grip.rotation_degrees,
		"facing": _rudy.facing,
		"look_sx": _look.scale.x,
		"rig_sx": signf(_rig.get_global_transform().x.x),
		"hb_dx": _box.global_position.x - _rudy.global_position.x,
		"dis": _box.disabled,
		"vx": _rudy.velocity.x,
		"vy": _rudy.velocity.y,
		"floor": _rudy.is_on_floor(),
		"gear": _rudy.gear,
		"hearts": _rudy.hearts,
		"x": _rudy.global_position.x,
		"n_slash": Sfx.count(&"slash"),
		"n_jump": Sfx.count(&"jump"),
		"nb": new_bursts,
		"in": ins,
	})


# --- Driving ---

func _event(code: Key, pressed: bool) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.pressed = pressed
	Input.parse_input_event(e)
	if pressed:
		_held[code] = true
	else:
		_held.erase(code)


func _log_key(label: String, read: String, want: int) -> void:
	if not _t0.has(_sc):
		_t0[_sc] = want
	_keys.append({"sc": _sc, "label": label, "read": read, "want": want})


## A key down, to be read on tick `want`. A held key is released in the same
## batch first, so the press is fresh.
func _fresh(code: Key, want: int) -> void:
	var label := KEY_NAME[code] + "+"
	if _held.has(code):
		_event(code, false)
		label = KEY_NAME[code] + "-+"
	_event(code, true)
	_log_key(label, KEY_NAME[code] + "+", want)


## Key events sent now, at a frame boundary, are read on the next tick.
func _down(code: Key) -> void:
	_fresh(code, _tick)


func _up(code: Key) -> void:
	_event(code, false)
	_log_key(KEY_NAME[code] + "-", KEY_NAME[code] + "-", _tick)


## A fresh press of `code` read on tick t: in slot a (the first tick of its
## frame, sent at the frame boundary) or, at two ticks a frame, in slot b
## (sent between the frame's two ticks and flushed). At one tick a frame the
## slot is ignored.
func _press(code: Key, t: int, slot: int) -> void:
	if _tpf == 1 or slot == 0:
		await _until(t)
		if _tick != t:
			_waits_failed.append("%s: a press for tick %d could only be sent for tick %d" % [_sc, t, _tick])
		_fresh(code, _tick)
		return
	await _until(t - 1)
	if _tick != t - 1:
		_waits_failed.append("%s: a slot-b press for tick %d: the frame boundary was at tick %d" % [_sc, t, _tick])
	await get_tree().physics_frame
	_fresh(code, t)
	Input.flush_buffered_events()


func _step(ticks: int) -> void:
	await _until(_tick + ticks)


## Steps whole frames until events sent next are read on tick t or later.
func _until(t: int) -> void:
	while _tick < t:
		await get_tree().process_frame


func _last() -> Dictionary:
	return _samples[-1]


## Steps until cond(last sample) holds, at most max_ticks; a timeout is noted.
func _wait_for(label: String, max_ticks: int, cond: Callable) -> bool:
	var limit := _tick + max_ticks
	while _tick < limit:
		await get_tree().process_frame
		if cond.call(_last()):
			return true
	_waits_failed.append("%s: %s (not within %d ticks)" % [_sc, label, max_ticks])
	return false


func _standing(s: Dictionary) -> bool:
	return s.floor and s.vx == 0.0 and s.mode == "PLAY" and s.clock < 0.0


func _rate() -> String:
	return "%d fps" % (Engine.physics_ticks_per_second / maxi(_tpf, 1))


## A fresh level in play; `spot` places him there in setup, else he stays at
## the level's StartPoint.
func _start(id: String, edge: String, offset: String, what: String, spot: Variant) -> Dictionary:
	_sc = id
	Main.title_shown = true
	_main = MAIN_SCENE.instantiate()
	get_tree().root.add_child(_main) # under the root, so it pauses (see above)
	var rudy: Rudy = _main.get_node("Rudy")
	if spot != null:
		rudy.global_position = spot
	var where := "x %.0f, y %.0f (%s), facing right, no sword, %d hearts" % [
		rudy.global_position.x, rudy.global_position.y,
		"placed in setup" if spot != null else "the level's StartPoint", rudy.hearts]
	_player = rudy.get_node("Look/AnimationPlayer")
	_sprite = rudy.get_node("Look/Sprite")
	_look = rudy.get_node("Look")
	_rig = rudy.get_node("Look/SlashRig")
	_grip = rudy.get_node("Look/SlashRig/Lean/Grip")
	_box = rudy.get_node("SwordHitbox/Shape")
	_bursts = _main.get_node("Effects/SlashBursts")
	_rudy = rudy
	var rec := {"id": id, "edge": edge, "rate": _rate(), "offset": offset, "what": what, "where": where}
	_scenarios.append(rec)
	await _step(SETTLE_TICKS)
	var s := _last()
	if not (s.floor and s.vx == 0.0 and s.mode == "PLAY"):
		_waits_failed.append("%s: settled in setup (floor %s, vx %.1f, mode %s)" % [id, s.floor, s.vx, s.mode])
	return rec


## Takes the sword by walking into the pickup, stops, and stands.
func _take_sword(rec: Dictionary) -> void:
	_down(KEY_D)
	await _wait_for("walks into the pickup", 40, func(s): return s.gear == Rudy.Gear.SWORD)
	_up(KEY_D)
	await _wait_for("stands with the sword", 40, _standing)
	await _step(10)
	rec.edge_at = _at_text(_last())


func _end() -> void:
	for code: Key in _held.keys():
		_event(code, false)
	_rudy = null
	_main.queue_free()
	_main = null
	await get_tree().process_frame
	await get_tree().process_frame


func _at_text(s: Dictionary) -> String:
	return "x %.1f, %s, facing %s, %s" % [s.x, s.clip, "right" if s.facing > 0 else "left",
		"sword" if s.gear == Rudy.Gear.SWORD else "no sword"]


# --- Scenarios ---

func _run() -> void:
	await get_tree().process_frame # from a frame boundary
	var t := _tick
	for i in 10:
		await get_tree().process_frame
	_tpf = (_tick - t) / 10 if (_tick - t) % 10 == 0 else 0
	print("== FRAME ==")
	print("%d physics ticks in 10 rendered frames: %d tick(s) a frame, %s" % [_tick - t, _tpf, _rate()])
	if _tpf == 1:
		await _e1("")
		await _e2("")
		await _e3()
		await _e4()
		await _e5()
		await _e6()
		await _e7()
	elif _tpf == 2:
		for offset in ["first", "second"]:
			await _e1(offset)
			await _e2(offset)
	_report()


func _suffix(offset: String) -> String:
	return "" if offset == "" else "-" + offset


func _slot_of(offset: String) -> int:
	return 1 if offset == "second" else 0


## E1: J pressed during a swing. Swing A takes presses, then a press on the
## earliest tick after it starts swing B, which takes the rest.
## At 30 fps swing tick 1 needs its own swing. A slot-b J for tick 1, sent
## after the swing's own J was sent for slot a of the same frame, is flushed
## after tick 0's physics_frame and re-stamps that J: the two merge into one
## press read on tick 1 (measured; swing M of the second offset keeps it). So
## the first offset adds swing C, whose own J is read on slot b, and reads a
## J on its tick 1 in slot a of the next frame.
func _e1(offset: String) -> void:
	var a: Array[int] = [1, 10, 16]
	var next := 18
	var b: Array[int] = [2, 11, 17]
	if offset == "first":
		a = [2, 10, 16]
		b = []
	elif offset == "second":
		a = [11, 17]
		next = 19 # tick 18 is a slot-a tick: 19 is the earliest slot-b tick after the swing
		b = []
	var sl := _slot_of(offset)
	var rec := await _start("E1" + _suffix(offset), "E1", offset, "slash pressed during a slash", SWORD_SPOT)
	await _take_sword(rec)
	var s_m := -1
	if offset == "second":
		s_m = _tick
		_down(KEY_J)
		_keys[-1].merged = true
		await _press(KEY_J, s_m + 1, 1)
		await get_tree().process_frame
		_up(KEY_J)
		await _until(s_m + 30)
	var s_a := _tick
	_down(KEY_J)
	for k in a:
		await _press(KEY_J, s_a + k, sl)
	await _press(KEY_J, s_a + next, sl)
	var s_b := s_a + next
	for k in b:
		await _press(KEY_J, s_b + k, sl)
	await get_tree().process_frame
	_up(KEY_J)
	await _until(s_b + 30)
	var s_c := -1
	if offset == "first":
		s_c = _tick + 1
		await _press(KEY_J, s_c, 1)
		await _press(KEY_J, s_c + 1, 0)
		await get_tree().process_frame
		_up(KEY_J)
		await _until(s_c + 30)
	rec.check = _check_e1.bind(rec, s_a, a, next, s_b, b, s_c, s_m)
	await _end()


## E2: a jump during a swing on the floor, each in its own swing; then a
## landing during a swing begun in the air.
func _e2(offset: String) -> void:
	var ticks: Array[int] = [1, 5, 12]
	var land_k := 33
	if offset == "first":
		ticks = [12]
		land_k = 32
	elif offset == "second":
		ticks = [1, 5]
	var sl := _slot_of(offset)
	var rec := await _start("E2" + _suffix(offset), "E2", offset, "jump during a slash; a landing during a slash", SWORD_SPOT)
	await _take_sword(rec)
	var swings: Array[Dictionary] = []
	for k in ticks:
		var s := _tick
		_down(KEY_J)
		await _press(KEY_SPACE, s + k, sl)
		await get_tree().process_frame
		_up(KEY_J)
		_up(KEY_SPACE)
		swings.append({"start": s, "jump": k})
		await _wait_for("lands from the jump on swing tick %d" % k, 120, _standing)
		await _step(10)
	var jump := _tick
	_down(KEY_SPACE)
	await _press(KEY_J, jump + land_k, sl)
	await get_tree().process_frame
	_up(KEY_SPACE)
	_up(KEY_J)
	await _wait_for("stands after the slash in the air", 120, _standing)
	await _step(10)
	rec.check = _check_e2.bind(rec, swings, jump, land_k)
	await _end()


## E3's way to the goblin, the same in every run: D from st 0 until he is
## past x 2945 (taking the sword on the way), a tap of A to face away from
## goblin B. Returns the st of D's release and of A's press, measured in the
## rehearsal and replayed in the runs.
func _e3_approach(keys: Dictionary) -> void:
	_down(KEY_D)
	if keys.is_empty():
		await _wait_for("walks into the pickup", 40, func(s): return s.gear == Rudy.Gear.SWORD)
		await _wait_for("reaches x %.0f" % E3_STOP_X, 80, func(s): return s.x >= E3_STOP_X)
		keys.d_up = _tick - _t0[_sc]
		_up(KEY_D)
		await _step(15)
		keys.a_down = _tick - _t0[_sc]
	else:
		await _until(_t0[_sc] + keys.d_up)
		_up(KEY_D)
		await _until(_t0[_sc] + keys.a_down)
	_down(KEY_A)
	await get_tree().process_frame
	_up(KEY_A)


## E3: goblin B walks into his back. A rehearsal finds the tick of its hit on
## a Rudy who only stands; each run replays the same keys and starts a swing
## so that the hit lands on a chosen swing tick.
func _e3() -> void:
	var keys := {}
	var rec := await _start("E3-rehearsal", "E3", "", "goblin B's hit on a standing Rudy: finds its st", SWORD_SPOT)
	await _e3_approach(keys)
	await _wait_for("goblin B's hit", 700, func(s): return s.mode == "HURT")
	keys.hit = _tick - 1 - _t0[_sc]
	rec.edge_at = _at_text(_samples[_by_t[_t0[_sc] + keys.a_down + 1]])
	await _step(10)
	rec.check = _check_e3_rehearsal.bind(rec, keys)
	await _end()
	for k in E3_HIT_TICKS:
		var run := await _start("E3-k%d" % k, "E3", "", "goblin B hits him from behind on swing tick %d" % k, SWORD_SPOT)
		await _e3_approach(keys)
		run.edge_at = "as E3-rehearsal"
		var s: int = _t0[_sc] + int(keys.hit) - k
		await _press(KEY_J, s, 0)
		await get_tree().process_frame
		_up(KEY_J)
		await _wait_for("goblin B's hit", 40, func(x): return x.mode == "HURT")
		await _wait_for("the hurt ends", 40, func(x): return x.mode == "PLAY")
		await _step(30) # any late spark burst would start by now
		run.check = _check_e3.bind(run, s, k, _t0[_sc] + keys.hit)
		await _end()


## E4: run, slash, run, with D held throughout.
func _e4() -> void:
	var rec := await _start("E4", "E4", "", "run, slash, run, D held throughout", SWORD_SPOT)
	_down(KEY_D)
	await _wait_for("walks into the pickup", 40, func(s): return s.gear == Rudy.Gear.SWORD)
	var s := _t0[_sc] + E4_SLASH_ST
	await _until(s - 1)
	rec.edge_at = _at_text(_last())
	await _press(KEY_J, s, 0)
	await get_tree().process_frame
	_up(KEY_J)
	await _until(s + SWING_TICKS + 20)
	_up(KEY_D)
	await _wait_for("stands", 60, _standing)
	await _step(10)
	rec.check = _check_e4.bind(rec, s)
	await _end()


## E5: a turn (a tap of A) on swing tick 5, in the active phase.
func _e5() -> void:
	var rec := await _start("E5", "E5", "", "turn during the active phase", SWORD_SPOT)
	await _take_sword(rec)
	var s := _tick
	_down(KEY_J)
	await get_tree().process_frame
	_up(KEY_J)
	await _press(KEY_A, s + E5_TURN_TICK, 0)
	await get_tree().process_frame
	_up(KEY_A)
	await _until(s + 30)
	rec.check = _check_e5.bind(rec, s)
	await _end()


## E6: Esc read on swing tick 5 (the tree pauses after that tick), 30 frames
## paused, Esc again.
func _e6() -> void:
	var rec := await _start("E6", "E6", "", "pause during the active phase, then resume", SWORD_SPOT)
	await _take_sword(rec)
	var s := _tick
	_down(KEY_J)
	await get_tree().process_frame
	_up(KEY_J)
	await _press(KEY_ESCAPE, s + E6_PAUSE_TICK, 0)
	await get_tree().process_frame
	_up(KEY_ESCAPE)
	for i in E6_PAUSE_FRAMES:
		await get_tree().process_frame
	_down(KEY_ESCAPE)
	await get_tree().process_frame
	_up(KEY_ESCAPE)
	await _step(40)
	rec.check = _check_e6.bind(rec, s)
	await _end()


## E7: a run without the sword from the StartPoint; D released for one tick
## and pressed again, twice, while he stays in run.
func _e7() -> void:
	var rec := await _start("E7", "E7", "", "a tap of the held direction during the run", null)
	rec.edge_at = "the StartPoint, standing"
	_down(KEY_D)
	var t0 := _t0[_sc]
	for st in E7_TAPS:
		await _until(t0 + st)
		_up(KEY_D)
		await _until(t0 + st + 1)
		_down(KEY_D)
	await _until(t0 + E7_RELEASE_ST)
	_up(KEY_D)
	await _wait_for("stands", 60, _standing)
	await _step(10)
	rec.check = _check_e7.bind(rec, t0)
	await _end()


# --- Analysis ---

func _st(s: Dictionary) -> int:
	return s.t - _t0.get(s.sc, s.t + 1)


func _s(t: int) -> Dictionary:
	return _samples[_by_t[t]] if _by_t.has(t) else {}


func _tag(rec: Dictionary) -> String:
	return "%s @%s%s" % [rec.edge, rec.rate, "" if rec.offset == "" else ", offset " + rec.offset]


func _check(rec: Dictionary, what: String, ok: bool, detail: String, from_t: int, to_t: int) -> void:
	_checks += 1
	var line := "%s  %s [%s]: %s%s" % ["PASS" if ok else "FAIL", _tag(rec), rec.id, what,
		"" if detail.is_empty() else "  (%s)" % detail]
	print(line)
	if not ok:
		_failures += 1
		_anomalies.append({"line": line, "from": from_t, "to": to_t})


## The sample indices of game ticks 0..n from start_t: ticks the tree was
## paused are skipped, since nothing in the game ran on them.
func _gticks(start_t: int, n: int) -> Array[int]:
	var out: Array[int] = []
	if not _by_t.has(start_t):
		return out
	var sc: String = _s(start_t).sc
	var t := start_t
	while out.size() <= n and _by_t.has(t) and _s(t).sc == sc:
		if not _s(t).paused:
			out.append(_by_t[t])
		t += 1
	return out


func _slot_name(s: Dictionary) -> String:
	return "ab"[s.slot] if s.slot < 2 else str(s.slot)


## Where each press was read: "swing tick k (slot)" for every sample from
## start_t on (to start_t + span) whose input shows `label`.
func _reads(start_t: int, span: int, label: String) -> PackedStringArray:
	var out: PackedStringArray = []
	for t in range(start_t, start_t + span + 1):
		var s := _s(t)
		if not s.is_empty() and s["in"].contains(label):
			out.append("%d%s" % [t - start_t, "" if _tpf == 1 else " (" + _slot_name(s) + ")"])
	return out


## The checks every whole swing gets: the clip and the swing clock count on
## every game tick 0-16, the rig shows, the hitbox is live on 2-10 only, one
## sound, and on tick 17 the swing is over and `after` shows.
func _swing_checks(rec: Dictionary, name: String, start_t: int, after: Array) -> void:
	var g := _gticks(start_t, SWING_TICKS)
	var span_to := start_t + 24
	if g.size() < SWING_TICKS + 1:
		_check(rec, "%s: the log holds the swing" % name, false, "%d game ticks" % g.size(), start_t - 2, span_to)
		return
	var bad: PackedStringArray = []
	var live: Array[int] = []
	var sound_bad: PackedStringArray = []
	var s0 := _samples[g[0]]
	var before := _samples[g[0] - 1]
	for k in SWING_TICKS:
		var s := _samples[g[k]]
		if s.clip != &"slash" or absf(s.pos - k / 60.0) > TOL or absf(s.clock - (k + 1) / 60.0) > TOL or s.spr or not s.rig:
			bad.append("k%d %s pos %.4f clock %.4f spr %d rig %d" % [k, s.clip, s.pos, s.clock, int(s.spr), int(s.rig)])
		if not s.dis:
			live.append(k)
		if k > 0 and s.n_slash != s0.n_slash:
			sound_bad.append("k%d" % k)
	var e := _samples[g[SWING_TICKS]]
	if not e.dis:
		live.append(SWING_TICKS)
	if e.n_slash != s0.n_slash:
		sound_bad.append("k%d" % SWING_TICKS)
	_check(rec, "%s: on swing ticks 0-16 the clip is slash at (tick)/60 s and the swing clock at (tick+1)/60 s; SlashRig shown, Sprite hidden" % name,
		bad.is_empty(), "wrong: [%s]" % ", ".join(bad), start_t - 2, span_to)
	var want_live: Array[int] = []
	for k in range(LIVE_FIRST, LIVE_LAST + 1):
		want_live.append(k)
	_check(rec, "%s: hitbox live on swing ticks %d-%d only" % [name, LIVE_FIRST, LIVE_LAST],
		live == want_live, "live on %s" % str(live), start_t - 2, span_to)
	_check(rec, "%s: one slash sound, on tick 0; no new swing on ticks 1-17" % name,
		s0.n_slash == before.n_slash + 1 and sound_bad.is_empty() and s0["in"].contains("J+"),
		"sounds %d>%d on tick 0, J read on tick 0: %s; a sound on: [%s]" % [
			before.n_slash, s0.n_slash, s0["in"].contains("J+"), ", ".join(sound_bad)], start_t - 2, span_to)
	_check(rec, "%s: on swing tick 17 the swing is over and %s shows, the Sprite back" % [name, " or ".join(after)],
		String(e.clip) in after and e.clock < 0.0 and e.spr and not e.rig,
		"tick 17: %s, %s, clock %.4f, spr %d rig %d" % [e.clip, e.pose, e.clock, int(e.spr), int(e.rig)], start_t - 2, span_to)


func _keys_read_check(rec: Dictionary) -> void:
	var bad: PackedStringArray = []
	var n := 0
	for k in _keys:
		if k.sc != rec.id or k.get("merged", false):
			continue
		n += 1
		var s := _s(k.want)
		if s.is_empty() or s.sc != rec.id or not s["in"].contains(k.read):
			bad.append("%s for st %d: %s" % [k.label, k.want - _t0[rec.id],
				"no sample" if s.is_empty() else "read [%s]" % s["in"]])
	_check(rec, "every key event was read on the tick it was sent for", bad.is_empty(),
		"%d events; wrong: [%s]" % [n, ", ".join(bad)], _t0.get(rec.id, 0), _t0.get(rec.id, 0))


func _check_e1(rec: Dictionary, s_a: int, a: Array[int], next: int, s_b: int, b: Array[int], s_c: int, s_m: int) -> void:
	_keys_read_check(rec)
	if s_m >= 0:
		var m0 := _s(s_m)
		var m1 := _s(s_m + 1)
		var merged: bool = not m0["in"].contains("J+") and m0.clip != &"slash" and m0.n_slash == _s(s_m - 1).n_slash \
			and m1["in"].contains("J+") and m1.slot == 1 and m1.clip == &"slash" and absf(m1.pos) <= TOL and m1.n_slash == m0.n_slash + 1
		_check(rec, "swing M (method limit, measured): J sent for slot a of tick 0 and a slot-b J for tick 1 merge into one press, read on tick 1, which starts the swing",
			merged, "tick 0: in [%s] %s; tick 1 (slot %s): in [%s] %s pos %.4f, sounds %d>%d" % [
				m0["in"], m0.clip, _slot_name(m1), m1["in"], m1.clip, m1.pos, m0.n_slash, m1.n_slash], s_m - 1, s_m + 3)
		_measured.append({"line": "E1 @%s, offset second [%s], swing M: a J press on swing tick 1 in slot b cannot follow the swing's own J in slot a of the same frame; the two merge into one press read on tick 1. Error in the test's method, not the game: tick 1 is reached in the first offset (swing C)" % [rec.rate, rec.id],
			"from": s_m - 1, "to": s_m + 3})
		_swing_checks(rec, "swing M (one swing from tick 1)", s_m + 1, ["sword_idle"])
	if s_c >= 0:
		var c0 := _s(s_c)
		var c1 := _s(s_c + 1)
		_check(rec, "swing C: its own press read in slot b, a press read on its swing tick 1 in slot a",
			c0["in"].contains("J+") and c0.slot == 1 and c1["in"].contains("J+") and c1.slot == 0,
			"read on swing ticks %s" % ", ".join(_reads(s_c, SWING_TICKS + 2, "J+")), s_c - 1, s_c + 2)
		_swing_checks(rec, "swing C, the press on tick 1 ignored", s_c, ["sword_idle"])
	var got_a: Array[int] = []
	for r in _reads(s_a + 1, SWING_TICKS - 1, "J+"):
		got_a.append(int(r.get_slice(" ", 0)) + 1)
	_check(rec, "swing A: presses read on swing ticks %s, the swing's own on 0" % str(a), str(got_a) == str(a),
		"read on swing ticks %s" % ", ".join(_reads(s_a, SWING_TICKS + 2, "J+")), s_a, s_a + next)
	_swing_checks(rec, "swing A, presses ignored", s_a, ["sword_idle"])
	_check(rec, "the press read on swing tick %d starts swing B" % next,
		_s(s_b)["in"].contains("J+") and _s(s_b).n_slash == _s(s_b - 1).n_slash + 1,
		"tick %d: in [%s], sounds %d>%d" % [next, _s(s_b)["in"], _s(s_b - 1).n_slash, _s(s_b).n_slash], s_b - 2, s_b + 2)
	if not b.is_empty():
		var got_b: Array[int] = []
		for r in _reads(s_b + 1, SWING_TICKS - 1, "J+"):
			got_b.append(int(r.get_slice(" ", 0)) + 1)
		_check(rec, "swing B: presses read on swing ticks %s" % str(b), str(got_b) == str(b),
			"read on swing ticks %s" % ", ".join(_reads(s_b, SWING_TICKS + 2, "J+")), s_b, s_b + 20)
	_swing_checks(rec, "swing B (the new swing%s)" % ("" if b.is_empty() else ", presses ignored"), s_b, ["sword_idle"])
	var g := _gticks(s_b, SWING_TICKS)
	if g.size() > 11:
		var lo := INF
		var hi := -INF
		for k in SWING_TICKS:
			lo = minf(lo, _samples[g[k]].grip)
			hi = maxf(hi, _samples[g[k]].grip)
		var g0: float = _samples[g[0]].grip
		var g11: float = _samples[g[11]].grip
		_check(rec, "swing B starts from clip time 0: Grip %.0f deg on tick 0, %.0f deg on tick 11, travel at least %.0f deg" % [
			GRIP_START, GRIP_ACTIVE_END, GRIP_TRAVEL],
			absf(g0 - GRIP_START) <= GRIP_TOL and absf(g11 - GRIP_ACTIVE_END) <= GRIP_TOL and hi - lo >= GRIP_TRAVEL,
			"Grip %.2f on tick 0, %.2f on tick 11, %.2f to %.2f: %.2f deg; Grip on swing A's last tick %.2f" % [
				g0, g11, lo, hi, hi - lo, _s(s_b - 2).grip], s_b - 2, s_b + 18)


func _check_e2(rec: Dictionary, swings: Array[Dictionary], jump: int, land_k: int) -> void:
	_keys_read_check(rec)
	for sw in swings:
		var s: int = sw.start
		var k: int = sw.jump
		var name := "jump on swing tick %d" % k
		var j := _s(s + k)
		var jb := _s(s + k - 1)
		_check(rec, "%s: read on that tick, and he takes off on it" % name,
			j["in"].contains("Space+") and j.vy == JUMP_VY and not j.floor and jb.floor and j.n_jump == jb.n_jump + 1,
			"Space read on swing tick(s) %s; tick %d: vy %.1f, floor %d (tick %d floor %d), jump sounds %d>%d" % [
				", ".join(_reads(s, SWING_TICKS, "Space+")), k, j.vy, int(j.floor), k - 1, int(jb.floor), jb.n_jump, j.n_jump],
			s - 1, s + k + 2)
		_swing_checks(rec, name, s, ["sword_rise", "sword_fall"])
		var air: PackedStringArray = []
		for kk in range(k, SWING_TICKS):
			if _s(s + kk).floor:
				air.append("k%d" % kk)
		_check(rec, "%s: the swing plays on in the air from tick %d to its end" % [name, k],
			air.is_empty(), "on the floor on: [%s]" % ", ".join(air), s, s + SWING_TICKS)
	# The landing swing.
	var s := -1
	for t in range(jump, jump + land_k + 2):
		if _s(t)["in"].contains("J+"):
			s = t
	var name := "slash in the air, read %d ticks after the jump" % land_k
	if s < 0:
		_check(rec, name + ": the press was read", false, "", jump, jump + land_k + 2)
		return
	var land := -1
	for kk in range(1, SWING_TICKS + 1):
		if _s(s + kk).floor and not _s(s + kk - 1).floor:
			land = kk
			break
	_check(rec, "%s: he lands during the swing (swing ticks 1-16)" % name, land >= 1 and land < SWING_TICKS,
		"press read %d ticks after the jump%s; lands on swing tick %d" % [s - jump,
			"" if _tpf == 1 else " (slot %s)" % _slot_name(_s(s)), land], s - 2, s + SWING_TICKS + 1)
	_swing_checks(rec, name + ", landing does not cut it", s, ["sword_idle"])


func _check_e3_rehearsal(rec: Dictionary, keys: Dictionary) -> void:
	_keys_read_check(rec)
	var t := _t0[rec.id] + int(keys.hit)
	var h := _s(t)
	var b := _s(t - 1)
	_check(rec, "goblin B's hit on the standing Rudy, from behind: its st, replayed in E3's runs",
		h.mode == "HURT" and b.mode == "PLAY" and b.facing < 0 and h.facing > 0,
		"hit on st %d; facing %d > %d (he turns toward the hit, which came from his back)" % [keys.hit, b.facing, h.facing],
		t - 2, t + 2)


func _check_e3(rec: Dictionary, s: int, k: int, hit_t: int) -> void:
	_keys_read_check(rec)
	var first_hurt := -1
	for t in range(s, s + 60):
		if _s(t).get("mode", "") == "HURT":
			first_hurt = t
			break
	var h := _s(first_hurt) if first_hurt >= 0 else {}
	var p := _s(first_hurt - 1) if first_hurt >= 0 else {}
	var name := "hit on swing tick %d (%s)" % [k, "startup" if k < LIVE_FIRST else ("active" if k <= LIVE_LAST else "recovery")]
	_check(rec, "%s: the hit lands on that swing tick, from behind" % name,
		first_hurt == hit_t and _s(s).n_slash == _s(s - 1).n_slash + 1 and not p.is_empty() and p.facing < 0,
		"swing starts on st %d, hit on swing tick %d; facing before the hit %d" % [
			s - _t0[rec.id], first_hurt - s, p.get("facing", 0)], s - 2, s + k + 2)
	if h.is_empty():
		return
	_check(rec, "%s: on the tick before it the swing is under way at clip time %d/60" % [name, k - 1],
		p.clip == &"slash" and absf(p.pos - (k - 1) / 60.0) <= TOL and p.rig and not p.spr,
		"tick %d: %s pos %.4f rig %d spr %d" % [k - 1, p.clip, p.pos, int(p.rig), int(p.spr)], s - 2, first_hurt + 2)
	_check(rec, "%s: on the hit's tick the swing ends, he shows hurt, the rig hides, the Sprite shows, the hitbox is dead" % name,
		h.mode == "HURT" and h.clip == &"hurt" and absf(h.pos) <= TOL and h.pose == &"CHAR-HURT" and h.spr and not h.rig
			and h.dis and h.clock < 0.0 and h.gear == Rudy.Gear.NONE,
		"tick %d: mode %s, %s pos %.4f, %s, spr %d rig %d, hitbox disabled %d, clock %.4f, gear %d" % [
			k, h.mode, h.clip, h.pos, h.pose, int(h.spr), int(h.rig), int(h.dis), h.clock, h.gear], s - 2, first_hurt + 2)
	var live: Array[int] = []
	var bursts_before := 0
	var bursts_after: PackedStringArray = []
	var sounds_after := 0
	for t in range(s, first_hurt):
		if not _s(t).dis:
			live.append(t - s)
		bursts_before += _s(t).nb
	var t := first_hurt
	while _by_t.has(t) and _s(t).sc == rec.id:
		if _s(t).nb > 0:
			bursts_after.append("swing tick %d" % (t - s))
		if not _s(t).dis:
			live.append(t - s)
		sounds_after = _s(t).n_slash - _s(s).n_slash
		t += 1
	var want_live: Array[int] = []
	for kk in range(LIVE_FIRST, mini(LIVE_LAST, k - 1) + 1):
		want_live.append(kk)
	var want_bursts := 1 if k > LIVE_FIRST else 0
	var live_text := "never live" if want_live.is_empty() else "live only on swing ticks %d-%d before the hit, never after" % [LIVE_FIRST, want_live[-1]]
	_check(rec, "%s: hitbox %s; %d spark burst(s) before the hit, none from the hit on" % [name, live_text, want_bursts],
		live == want_live and bursts_before == want_bursts and bursts_after.is_empty() and sounds_after == 0,
		"live on %s; bursts started before the hit %d, on or after it [%s] over %d ticks; slash sounds after %d" % [
			str(live), bursts_before, ", ".join(bursts_after), t - first_hurt, sounds_after], s - 2, first_hurt + 4)


func _check_e4(rec: Dictionary, s: int) -> void:
	_keys_read_check(rec)
	var p := _s(s - 1)
	var z := _s(s)
	_check(rec, "the slash shows at once over the run: swing tick 0 is slash at 0, SlashRig shown",
		p.clip == &"sword_run" and z.clip == &"slash" and absf(z.pos) <= TOL and z.rig and not z.spr
			and z.pose == &"CHAR-SWORD-SLASH" and z["in"].contains("J+"),
		"tick -1: %s pos %.4f %s; tick 0: %s pos %.4f %s rig %d spr %d" % [
			p.clip, p.pos, p.pose, z.clip, z.pos, z.pose, int(z.rig), int(z.spr)], s - 3, s + 2)
	_swing_checks(rec, "the swing over the run", s, ["sword_run"])
	var bad: PackedStringArray = []
	for k in range(SWING_TICKS, SWING_TICKS + RUN_FIRST_CELL_TICKS + 1):
		var x := _s(s + k)
		var want_pose := &"CHAR-SWORD-RUN-A" if k < SWING_TICKS + RUN_FIRST_CELL_TICKS else &"CHAR-SWORD-RUN-B"
		if x.clip != &"sword_run" or absf(x.pos - (k - SWING_TICKS) / 60.0) > TOL or x.pose != want_pose:
			bad.append("k%d %s pos %.4f %s" % [k, x.clip, x.pos, x.pose])
	_check(rec, "after the swing sword_run restarts: SWORD-RUN-A on swing ticks 17-24 at 0..7/60 s, SWORD-RUN-B on 25",
		bad.is_empty(), "wrong: [%s]; before the press it stood at %.4f s (%s)" % [", ".join(bad), p.pos, p.pose],
		s + SWING_TICKS - 2, s + SWING_TICKS + 10)
	var slow: PackedStringArray = []
	for k in range(-1, SWING_TICKS + RUN_FIRST_CELL_TICKS + 1):
		if absf(_s(s + k).vx - 560.0) > 0.001 or not _s(s + k).floor:
			slow.append("k%d vx %.1f floor %d" % [k, _s(s + k).vx, int(_s(s + k).floor)])
	_check(rec, "D held throughout: he runs at full speed on the floor from tick -1 to 25",
		slow.is_empty(), "wrong: [%s]" % ", ".join(slow), s - 1, s + 26)


func _check_e5(rec: Dictionary, s: int) -> void:
	_keys_read_check(rec)
	var k := E5_TURN_TICK
	var b := _s(s + k - 1)
	var a := _s(s + k)
	_check(rec, "the turn is read on swing tick %d, in the active phase" % k,
		a["in"].contains("A+") and not a.dis and not b.dis,
		"A read on swing tick(s) %s; hitbox live on %d and %d: %s" % [
			", ".join(_reads(s, SWING_TICKS, "A+")), k - 1, k, not a.dis and not b.dis], s + k - 2, s + k + 2)
	_check(rec, "on the turn's tick Look and the rig flip, and the hitbox moves to his other side",
		b.facing == 1 and b.look_sx == 1.0 and b.rig_sx > 0.0 and absf(b.hb_dx - HITBOX_REACH) <= TOL
			and a.facing == -1 and a.look_sx == -1.0 and a.rig_sx < 0.0 and absf(a.hb_dx + HITBOX_REACH) <= TOL,
		"tick %d: facing %d, Look scale.x %.0f, rig x axis %.0f, hitbox %+.1f px; tick %d: facing %d, Look %.0f, rig %.0f, hitbox %+.1f px" % [
			k - 1, b.facing, b.look_sx, b.rig_sx, b.hb_dx, k, a.facing, a.look_sx, a.rig_sx, a.hb_dx], s + k - 2, s + k + 2)
	var flipped: PackedStringArray = []
	for kk in range(k, SWING_TICKS):
		var x := _s(s + kk)
		if x.facing != -1 or x.look_sx != -1.0 or x.rig_sx >= 0.0 or absf(x.hb_dx + HITBOX_REACH) > TOL:
			flipped.append("k%d" % kk)
	_check(rec, "it stays turned to the swing's end", flipped.is_empty(), "wrong on: [%s]" % ", ".join(flipped), s + k, s + SWING_TICKS)
	_swing_checks(rec, "the swing through the turn, neither clip nor hitbox window restarted", s, ["sword_idle"])


func _check_e6(rec: Dictionary, s: int) -> void:
	_keys_read_check(rec)
	var first_p := -1
	var last_p := -1
	var t := s
	while _by_t.has(t) and _s(t).sc == rec.id:
		if _s(t).paused:
			if first_p < 0:
				first_p = t
			last_p = t
		t += 1
	if first_p < 0:
		_check(rec, "the game pauses", false, "no paused tick", s, s + 40)
		return
	var gap: PackedStringArray = []
	for tt in range(first_p, last_p + 1):
		if not _s(tt).paused:
			gap.append(str(tt - s))
	var before := _s(first_p - 1)
	var g := _gticks(s, SWING_TICKS)
	var paused_at := g.find(_by_t[first_p - 1])
	_check(rec, "Esc read on swing tick %d pauses the tree after that tick; one pause, %d ticks long" % [E6_PAUSE_TICK, last_p - first_p + 1],
		_s(s + E6_PAUSE_TICK)["in"].contains("Esc+") and paused_at == E6_PAUSE_TICK and gap.is_empty()
			and last_p - first_p + 1 >= E6_PAUSE_FRAMES,
		"Esc read on swing tick(s) %s; the last game tick before the pause is swing tick %d; paused from st %d to %d; unpaused inside: [%s]" % [
			", ".join(_reads(s, SWING_TICKS, "Esc+")), paused_at, first_p - _t0[rec.id], last_p - _t0[rec.id], ", ".join(gap)],
		first_p - 3, first_p + 3)
	var moved: PackedStringArray = []
	for tt in range(first_p, last_p + 1):
		var x := _s(tt)
		if x.clip != before.clip or x.pos != before.pos or x.clock != before.clock or x.x != before.x or not x.rig or x.dis != before.dis:
			moved.append("st %d: %s pos %.4f clock %.4f" % [tt - _t0[rec.id], x.clip, x.pos, x.clock])
	_check(rec, "while paused the clip position and the swing clock stay put (%.4f s, %.4f s)" % [before.pos, before.clock],
		moved.is_empty(), "%d paused ticks; changed on: [%s]" % [last_p - first_p + 1, ", ".join(moved)], first_p - 2, last_p + 2)
	var after := _s(last_p + 1)
	_check(rec, "on resume both go on from where they stopped: the first game tick after the pause is swing tick %d" % (E6_PAUSE_TICK + 1),
		absf(after.pos - (E6_PAUSE_TICK + 1) / 60.0) <= TOL and absf(after.clock - (E6_PAUSE_TICK + 2) / 60.0) <= TOL,
		"st %d: pos %.4f, clock %.4f" % [last_p + 1 - _t0[rec.id], after.pos, after.clock], last_p - 1, last_p + 3)
	_swing_checks(rec, "the swing counted in game ticks across the pause, no tick lost or repeated", s, ["sword_idle"])


func _check_e7(rec: Dictionary, t0: int) -> void:
	_keys_read_check(rec)
	var e := t0
	var bad: PackedStringArray = []
	var slow: PackedStringArray = []
	for t in range(e, t0 + E7_RELEASE_ST):
		var x := _s(t)
		var want := fmod((t - e) / 60.0, RUN_LENGTH)
		var d := absf(x.pos - want)
		d = minf(d, RUN_LENGTH - d)
		if x.clip != &"run" or d > TOL:
			bad.append("st %d %s pos %.4f (want %.4f)" % [t - t0, x.clip, x.pos, want])
		if absf(x.vx) <= 1.0 or not x.floor:
			slow.append("st %d" % (t - t0))
	var taps: PackedStringArray = []
	for st in E7_TAPS:
		taps.append("D- read on st %d: %s, D+ on st %d: %s, vx there %.1f" % [st, _s(t0 + st)["in"].contains("D-"), st + 1,
			_s(t0 + st + 1)["in"].contains("D+"), _s(t0 + st).vx])
	_check(rec, "he stays in run through both taps: on the floor, moving, every tick st 0-%d" % (E7_RELEASE_ST - 1),
		slow.is_empty(), "not running on: [%s]; %s" % [", ".join(slow), "; ".join(taps)], t0, t0 + E7_RELEASE_ST)
	_check(rec, "the run clip is never restarted: from st 0 its position is (ticks since st 0)/60 mod 0.25 on every tick",
		bad.is_empty(), "wrong: [%s]" % ", ".join(bad), t0, t0 + E7_RELEASE_ST)


func _line(s: Dictionary) -> String:
	return "tick %5d %-13s st %4d %s%s %-11s %-10s pos %.4f clk %7.4f %-16s spr %d rig %d grip %7.2f face %2d look %2.0f rigx %2.0f hb %+5.1f dis %d v(%7.1f,%7.1f) floor %d gear %d hp %d x %7.1f burst+%d in %s" % [
		s.t, s.sc, _st(s), _slot_name(s), " P" if s.paused else "  ", s.mode, s.clip, s.pos, s.clock, s.pose,
		int(s.spr), int(s.rig), s.grip, s.facing, s.look_sx, s.rig_sx, s.hb_dx, int(s.dis), s.vx, s.vy,
		int(s.floor), s.gear, s.hearts, s.x, s.nb, s["in"] if s["in"] != "" else "-"]


func _report() -> void:
	var last_sc := ""
	for s in _samples:
		if s.sc != last_sc:
			last_sc = s.sc
			print("== SCENARIO %s ==" % s.sc)
		print(_line(s))

	print("== SCENARIOS ==")
	for rec in _scenarios:
		var keys: PackedStringArray = []
		for k in _keys:
			if k.sc == rec.id:
				keys.append("%s@%d" % [k.label, k.want - _t0[rec.id]])
		print("%s (%s) %s | starts at %s | edge at %s" % [rec.id, _tag(rec), rec.what, rec.where, rec.get("edge_at", "-")])
		print("%s keys: %s" % [rec.id, " ".join(keys)])

	print("== EDGES ==")
	var none := {"id": "-", "edge": "ALL", "rate": _rate(), "offset": ""}
	_check(none, "ticks per frame measured: %d, so %s" % [_tpf, "E1-E7 run" if _tpf == 1 else "E1 and E2 run at both offsets"],
		_tpf == 1 or _tpf == 2, "", 0, 0)
	_check(none, "every scripted wait was met", _waits_failed.is_empty(), "; ".join(PackedStringArray(_waits_failed)), 0, 0)
	for rec in _scenarios:
		if rec.has("check"):
			(rec.check as Callable).call()

	print("== ANOMALIES ==")
	if _anomalies.is_empty() and _measured.is_empty():
		print("none")
	for a in _measured:
		print("ANOMALY (measured, kept) " + a.line)
		for t in range(a.from, a.to + 1):
			if _by_t.has(t):
				print("  " + _line(_s(t)))
	for a in _anomalies:
		print("ANOMALY " + a.line)
		for t in range(a.from, a.to + 1):
			if _by_t.has(t):
				print("  " + _line(_s(t)))

	print("RESULT %s: %d checks, %d failed, %d ticks, %s" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures, _samples.size(), _rate()])
	get_tree().quit(1 if _failures > 0 else 0)
