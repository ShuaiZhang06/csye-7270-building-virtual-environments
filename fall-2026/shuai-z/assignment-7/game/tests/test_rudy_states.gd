extends Node
## The state test (CHANGE-BRIEF.md section 9; step 5a). Run from the
## assignment folder:
##   scripts/run-test.sh test_rudy_states.tscn 60
##
## It enters every state of section 3's table from its real action, in the
## real Main (the level, its goblins, spikes, pickup, pits and teleport
## circle), and pins the wired behaviour as it is now.
##
## Rules this test keeps:
## - Each scenario starts a fresh Main with the title skipped, as checks.gd's
##   _start_level() does (Main.title_shown = true before it is instanced).
## - Setup comes before a scenario's first input, and only then: it may place
##   Rudy at a spot on the level (his global_position, on the walk line) and
##   lets him settle. From the first input on, nothing writes his state,
##   velocity, position, gear, hearts or mode. He takes the sword by walking
##   into the pickup and loses hearts to real hits and falls.
## - Input is only InputEventKey events for the project's physical keys D, A,
##   Space and J, sent with Input.parse_input_event.
## - It reads properties, and calls only read-only queries: is_on_floor() and
##   the AnimationPlayer's current_animation and current_animation_position.
##   It never calls play(), seek(), advance() or a state method.
## - It steps one rendered frame at a time with process_frame: under
##   --fixed-fps 60, one frame is one physics tick, and an event sent after an
##   await is read on the next tick.
## - This node is the recorder. Its process_physics_priority is 100 (set in
##   the scene), so on every tick it samples after Rudy and after his
##   AnimationPlayer: sample N is what tick N left.
##
## Scenario ticks ("st") count from the tick the scenario's first input is
## read (st 0); setup ticks are negative. Swing ticks count from the tick the
## slash press that starts the swing is read (swing tick 0).
## Prints a per-tick log, the scenarios, then the group STATES, the
## transitions no scenario reached, the ANOMALIES, and a RESULT line; quits 1
## on any failure.

const MAIN_SCENE := preload("res://app/main.tscn")

const SETTLE_TICKS := 20 ## setup ticks after placing him, before the first input
## The slash clip (section 2.2, Revision 4): 17 ticks on screen, hitbox live
## on swing ticks 2-10, the Sprite back on tick 17.
const SWING_TICKS := 17
const LIVE_FIRST := 2
const LIVE_LAST := 10
const RIG_TOLERANCE := 0.01
const POSITION_TOLERANCE := 1e-5
## Section 7: the run's first cell shows for 8 ticks.
const RUN_FIRST_CELL_TICKS := 8

## Each clip of section 3's table: the pose it shows on its first tick.
const CLIP_POSE: Dictionary[StringName, StringName] = {
	&"idle": &"CHAR-IDLE",
	&"run": &"CHAR-RUN-A",
	&"rise": &"CHAR-RISE",
	&"fall": &"CHAR-FALL",
	&"sword_idle": &"CHAR-SWORD-IDLE",
	&"sword_run": &"CHAR-SWORD-RUN-A",
	&"sword_rise": &"CHAR-SWORD-RISE",
	&"sword_fall": &"CHAR-SWORD-FALL",
	&"slash": &"CHAR-SWORD-SLASH",
	&"hurt": &"CHAR-HURT",
	&"defeat": &"CHAR-DEFEAT",
	&"respawn": &"CHAR-RESPAWN",
	&"celebrate": &"CHAR-CELEBRATE",
}
const RUN_SECOND_CELL: Dictionary[StringName, StringName] = {
	&"run": &"CHAR-RUN-B",
	&"sword_run": &"CHAR-SWORD-RUN-B",
}

## Section 3's transition table, every row out of every state. States 6-9
## take the sword form's clip while he has the sword (section 3, "Forms"), so
## their rows are written out for both forms: a slash needs the sword, and a
## defeat cannot happen with it (a hit takes the sword, not a heart).
const TABLE: Array = [
	["idle", ["run", "rise", "hurt", "defeat", "celebrate"]],
	["run", ["idle", "rise", "fall", "hurt", "defeat", "celebrate"]],
	["rise", ["fall", "idle", "run", "hurt", "defeat", "respawn"]],
	["fall", ["idle", "run", "hurt", "defeat", "respawn"]],
	["sword_idle", ["sword_run", "sword_rise", "slash", "hurt", "celebrate"]],
	["sword_run", ["sword_idle", "sword_rise", "sword_fall", "slash", "hurt", "celebrate"]],
	["sword_rise", ["sword_fall", "sword_idle", "sword_run", "slash", "hurt", "respawn"]],
	["sword_fall", ["sword_idle", "sword_run", "slash", "hurt", "respawn"]],
	["slash", ["sword_idle", "sword_run", "sword_rise", "sword_fall", "hurt", "respawn", "celebrate"]],
	["hurt", ["idle", "run", "rise", "fall"]],
	["defeat", ["respawn"]],
	["respawn", ["idle"]],
	["celebrate", []],
]

## Transitions this test measured that section 3's table does not list. The
## check keeps what was measured; each is listed under ANOMALIES.
const MEASURED_OFF_TABLE: Dictionary[String, String] = {
	"run>sword_run": "walking into the pickup mid-run: section 3 lists no change of form; Revision 4 names the restart this causes",
}

const KEY_NAME: Dictionary[Key, String] = {KEY_D: "D", KEY_A: "A", KEY_SPACE: "Space", KEY_J: "J"}

var _tick := 0 ## the index the next physics tick will have
var _samples: Array[Dictionary] = []
var _sc := "" ## the scenario under way
var _t0: Dictionary[String, int] = {} ## each scenario's first input tick
var _pending_in := "" ## the key events the next tick will read
var _scenarios: Array[Dictionary] = []
var _keys_log: Dictionary[String, Array] = {}
var _waits_failed: Array[String] = []
var _failures := 0
var _checks := 0

var _main: Main
var _rudy: Rudy
var _player: AnimationPlayer
var _sprite: Sprite2D
var _rig: Node2D
var _lean: Node2D
var _grip: Node2D
var _arc: Sprite2D
var _box: CollisionShape2D


func _ready() -> void:
	_run.call_deferred()


func _physics_process(_delta: float) -> void:
	var t := _tick
	_tick += 1
	if _rudy == null or not is_instance_valid(_rudy):
		return
	var clip := StringName(_player.current_animation)
	_samples.append({
		"t": t,
		"sc": _sc,
		"mode": Rudy.Mode.keys()[_rudy.mode],
		"clip": clip,
		"pos": _player.current_animation_position if clip != &"" else -1.0,
		"pose": _rudy.pose,
		"spr": _sprite.visible,
		"rig": _rig.visible,
		"grip": _grip.rotation_degrees,
		"lean": _lean.rotation_degrees,
		"lean_x": _lean.position.x,
		"arc": _arc.modulate.a,
		"dis": _box.disabled,
		"vx": _rudy.velocity.x,
		"vy": _rudy.velocity.y,
		"floor": _rudy.is_on_floor(),
		"gear": _rudy.gear,
		"hearts": _rudy.hearts,
		"x": _rudy.global_position.x,
		"n_slash": Sfx.count(&"slash"),
		"in": _pending_in,
	})
	_pending_in = ""


# --- Driving ---

func _key(code: Key, pressed: bool) -> void:
	if not _t0.has(_sc):
		_t0[_sc] = _tick
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.pressed = pressed
	Input.parse_input_event(e)
	var label := KEY_NAME[code] + ("+" if pressed else "-")
	_pending_in += label
	_keys_log[_sc].append("%s@%d" % [label, _tick - _t0[_sc]])


func _down(code: Key) -> void:
	_key(code, true)


func _up(code: Key) -> void:
	_key(code, false)


## A key down now and up on the next tick; returns the tick the press is read.
func _tap(code: Key) -> int:
	var t := _tick
	_key(code, true)
	await _step(1)
	_key(code, false)
	return t


func _step(n: int) -> void:
	for i in n:
		await get_tree().process_frame


## Steps until events sent next are read on tick t.
func _until(t: int) -> void:
	while _tick < t:
		await get_tree().process_frame


func _last() -> Dictionary:
	return _samples[-1]


## Steps until cond(last sample) holds, at most max_ticks; a timeout is noted.
func _wait_for(label: String, max_ticks: int, cond: Callable) -> bool:
	for i in max_ticks:
		await get_tree().process_frame
		if cond.call(_last()):
			return true
	_waits_failed.append("%s: %s (not within %d ticks)" % [_sc, label, max_ticks])
	return false


## A fresh level in play; `spot` places him there in setup, else he stays at
## the level's StartPoint.
func _start(id: String, what: String, spot: Variant) -> void:
	_sc = id
	_keys_log[id] = []
	Main.title_shown = true
	_main = MAIN_SCENE.instantiate()
	add_child(_main)
	var rudy: Rudy = _main.get_node("Rudy")
	if spot != null:
		rudy.global_position = spot
	var where := "x %.0f on the walk line (y %.0f), %s, facing right, no sword, %d hearts" % [
		rudy.global_position.x, rudy.global_position.y,
		"placed in setup" if spot != null else "the level's StartPoint", rudy.hearts]
	_scenarios.append({"id": id, "what": what, "where": where})
	_player = rudy.get_node("Look/AnimationPlayer")
	_sprite = rudy.get_node("Look/Sprite")
	_rig = rudy.get_node("Look/SlashRig")
	_lean = rudy.get_node("Look/SlashRig/Lean")
	_grip = rudy.get_node("Look/SlashRig/Lean/Grip")
	_arc = rudy.get_node("Look/SlashRig/Lean/Arc")
	_box = rudy.get_node("SwordHitbox/Shape")
	_rudy = rudy
	await _step(SETTLE_TICKS)
	var s := _last()
	if not (s.floor and s.vx == 0.0 and s.mode == "PLAY"):
		_waits_failed.append("%s: settled in setup (floor %s, vx %.1f, mode %s)" % [id, s.floor, s.vx, s.mode])


func _end() -> void:
	_rudy = null
	_main.queue_free()
	_main = null
	await _step(2)


func _goblin(name: String) -> Goblin:
	return _main.get_node("Level1/Enemies/" + name)


# --- Scenarios ---

func _run() -> void:
	await _s1_plain_moves()
	await _s2_spikes_defeat()
	await _s3_pit_run()
	await _s4_pit_jump()
	await _s5_sword_moves()
	await _s6_hit_in_swing()
	await _s7_sword_ledge()
	await _s8_celebrate()
	_report()


## Plain form: run, stop, jump in place, turn and run, running jump, turn back.
func _s1_plain_moves() -> void:
	await _start("S1", "plain moves", Vector2(600, 840))
	_down(KEY_D)
	await _step(30)
	_up(KEY_D)
	await _step(25)
	await _tap(KEY_SPACE)
	await _wait_for("lands from the jump in place", 90, func(s): return s.floor)
	await _step(15)
	_down(KEY_A) # turns him on the ground; he runs left after the turn hold
	await _step(20)
	var jump := await _tap(KEY_SPACE)
	await _until(jump + 3)
	await _wait_for("lands from the running jump", 90, func(s): return s.floor)
	await _step(12)
	_down(KEY_D) # a turn on the ground while running
	_up(KEY_A)
	await _step(20)
	_up(KEY_D)
	await _step(20)
	jump = await _tap(KEY_SPACE) # a jump in place, then right after the top: lands running
	await _until(jump + 28)
	_down(KEY_D)
	await _wait_for("lands running", 90, func(s): return s.floor)
	await _step(10)
	jump = await _tap(KEY_SPACE) # a running jump, D let go after the top: lands standing
	await _until(jump + 26)
	_up(KEY_D)
	await _wait_for("lands standing", 90, func(s): return s.floor)
	await _step(20)
	await _end()


## Hearts lost to the spikes: a hit from the run, a hit in the air, then the
## defeat, and the respawn with the hearts full.
func _s2_spikes_defeat() -> void:
	await _start("S2", "spikes: hurt, hurt from the air, defeat, respawn", null)
	_down(KEY_D)
	await _wait_for("the spikes' first hit", 200, func(s): return s.mode == "HURT")
	_up(KEY_D)
	await _wait_for("the first hurt ends", 40, func(s): return s.mode == "PLAY")
	await _step(90) # invulnerability (1.2 s from the hit) is over
	var jump := await _tap(KEY_SPACE)
	await _until(jump + 23) # the top: he comes down on the spikes, moving sideways
	_down(KEY_D)
	await _wait_for("the spikes' hit from the air", 80, func(s): return s.mode == "HURT")
	_up(KEY_D)
	await _wait_for("the second hurt ends", 40, func(s): return s.mode == "PLAY")
	await _step(90)
	var toward := KEY_A if _last().x > 1065.0 else KEY_D # SpikesA is at x 1065
	_down(toward)
	await _wait_for("the defeat", 200, func(s): return s.mode == "DEFEATED")
	_up(toward)
	await _wait_for("the respawn", 200, func(s): return s.mode == "RESPAWNING")
	_down(KEY_D)
	await _wait_for("control back after the respawn", 80, func(s): return s.mode == "PLAY")
	await _step(15)
	_up(KEY_D)
	await _step(20)
	await _end()


## Runs off the ledge at x 4300 into the pit, falls out, respawns, runs.
func _s3_pit_run() -> void:
	await _start("S3", "run off the ledge into the pit, respawn", Vector2(4150, 840))
	_down(KEY_D)
	await _wait_for("falls out", 200, func(s): return s.mode == "FALLEN")
	await _wait_for("the respawn", 120, func(s): return s.mode == "RESPAWNING")
	await _wait_for("control back after the respawn", 80, func(s): return s.mode == "PLAY")
	await _step(15)
	_up(KEY_D)
	await _step(20)
	await _end()


## A jump from the ledge's lip that stops moving sideways before the top, so
## he drops into the pit in the rising pose.
func _s4_pit_jump() -> void:
	await _start("S4", "jump into the pit straight down, respawn", Vector2(4280, 840))
	_down(KEY_SPACE)
	_down(KEY_D)
	await _step(1)
	_up(KEY_SPACE)
	await _step(11)
	_up(KEY_D)
	await _wait_for("falls out", 200, func(s): return s.mode == "FALLEN")
	await _wait_for("the respawn", 120, func(s): return s.mode == "RESPAWNING")
	await _wait_for("control back after the respawn", 80, func(s): return s.mode == "PLAY")
	await _step(20)
	await _end()


## The sword form: pickup mid-run, a running jump with a slash in the air, a
## running slash, a slash standing, a jump in place, a jump during a slash,
## and a slash in the air from a jump in place. Kept between x 2400 and 3300,
## clear of goblin B's patrol (x 3000-3400) by its timing.
func _s5_sword_moves() -> void:
	await _start("S5", "sword moves", Vector2(2400, 840))
	_down(KEY_D)
	await _wait_for("walks into the pickup", 40, func(s): return s.gear == Rudy.Gear.SWORD)
	await _step(10)
	var jump := await _tap(KEY_SPACE)
	await _until(jump + 10)
	await _tap(KEY_J)
	await _wait_for("lands from the running jump", 90, func(s): return s.floor)
	await _step(10)
	_up(KEY_D)
	await _step(20)
	_down(KEY_A) # turn, then run left
	await _step(19)
	await _tap(KEY_J)
	await _step(25)
	_up(KEY_A)
	await _step(20)
	await _tap(KEY_J) # standing
	await _step(30)
	await _tap(KEY_SPACE) # jump in place
	await _wait_for("lands from the jump in place", 90, func(s): return s.floor)
	await _step(10)
	var swing := await _tap(KEY_J) # a jump on swing tick 5
	await _until(swing + 5)
	await _tap(KEY_SPACE)
	await _wait_for("lands from the jump in the swing", 90, func(s): return s.floor)
	await _step(15)
	jump = await _tap(KEY_SPACE) # a slash 25 ticks into a jump in place
	await _until(jump + 25)
	await _tap(KEY_J)
	await _step(30)
	await _wait_for("on the floor", 60, func(s): return s.floor)
	await _step(10)
	jump = await _tap(KEY_SPACE) # a jump in place, then left after the top: lands running
	await _until(jump + 28)
	_down(KEY_A)
	await _wait_for("lands running", 90, func(s): return s.floor)
	await _step(10)
	jump = await _tap(KEY_SPACE) # a running jump, A let go after the top: lands standing
	await _until(jump + 26)
	_up(KEY_A)
	await _wait_for("lands standing", 90, func(s): return s.floor)
	await _step(20)
	await _end()


## A goblin walks into his back during his swings: the hit ends the swing.
## He stops just short of goblin B's patrol (it never goes below x 3000),
## faces away from it, and swings back to back as it comes back.
func _s6_hit_in_swing() -> void:
	await _start("S6", "goblin B hits him from behind during a swing", Vector2(2400, 840))
	_down(KEY_D)
	await _wait_for("walks into the pickup", 40, func(s): return s.gear == Rudy.Gear.SWORD)
	await _wait_for("reaches x 2945", 80, func(s): return s.x >= 2945.0)
	_up(KEY_D)
	await _step(15)
	await _tap(KEY_A) # turns him away from the goblin without moving him
	await _step(10)
	var gob := _goblin("GoblinB")
	await _wait_for("goblin B comes back within 100 px", 700,
		func(s): return gob.facing < 0 and gob.global_position.x - s.x < 100.0)
	await _step(5) # so the hit, which comes when the goblin does, lands inside a swing
	for i in 12:
		if _last().mode == "HURT":
			break
		await _tap(KEY_J) # read on the previous swing's tick 18, the earliest
		for j in 17:
			if _last().mode == "HURT":
				break
			await _step(1)
	if _last().mode != "HURT":
		_waits_failed.append("S6: the goblin's hit (not within 12 swings)")
	await _wait_for("the hurt ends", 40, func(s): return s.mode == "PLAY")
	await _step(20)
	await _end()


## With the sword: a running jump over goblin B, on past the waystone, off
## the ledge at x 4300, a slash while falling into the pit, fall out, respawn
## at the waystone.
func _s7_sword_ledge() -> void:
	await _start("S7", "sword: jump goblin B, off the ledge, slash in the pit, respawn", Vector2(2400, 840))
	_down(KEY_D)
	await _wait_for("walks into the pickup", 40, func(s): return s.gear == Rudy.Gear.SWORD)
	var gob := _goblin("GoblinB")
	await _wait_for("goblin B 160 px ahead", 200, func(s): return gob.global_position.x - s.x < 160.0)
	await _tap(KEY_SPACE)
	await _wait_for("lands past goblin B", 90, func(s): return s.floor)
	await _wait_for("runs off the ledge", 200, func(s): return not s.floor)
	await _step(8)
	await _tap(KEY_J)
	await _wait_for("falls out", 60, func(s): return s.mode == "FALLEN")
	await _wait_for("the respawn", 120, func(s): return s.mode == "RESPAWNING")
	await _wait_for("control back after the respawn", 80, func(s): return s.mode == "PLAY")
	await _step(8)
	_up(KEY_D)
	await _step(25)
	await _end()


## Runs onto the teleport circle at x 7200.
func _s8_celebrate() -> void:
	await _start("S8", "run onto the teleport circle", Vector2(7000, 840))
	_down(KEY_D)
	await _wait_for("reaches the circle", 60, func(s): return s.mode == "CELEBRATING")
	_up(KEY_D)
	await _step(170) # Main's 2 s on the circle and the fade to the end card
	await _end()


# --- Analysis ---

func _st(s: Dictionary) -> int:
	return s.t - _t0.get(s.sc, s.t + 1)


func _at(s: Dictionary) -> String:
	return "%s t%d" % [s.sc, _st(s)]


func _check(what: String, ok: bool, detail: String = "") -> void:
	_checks += 1
	if not ok:
		_failures += 1
	print("%s  %s%s" % ["PASS" if ok else "FAIL", what, "" if detail.is_empty() else "  (%s)" % detail])


func _swing_tick(i: int, swings: Array[int]) -> int:
	for s in range(swings.size() - 1, -1, -1):
		if swings[s] <= i and _samples[i].sc == _samples[swings[s]].sc:
			return i - swings[s]
	return -1


## What made the change from p to c, and whether it is the table row's "when".
func _cause(p: Dictionary, c: Dictionary, swing_tick: int) -> Array:
	var from: String = p.clip
	var to: String = c.clip
	var lost: bool = c.hearts < p.hearts or (p.gear == Rudy.Gear.SWORD and c.gear == Rudy.Gear.NONE)
	match to:
		"hurt":
			return [lost and c.mode == "HURT", "a hit: hearts %d>%d, gear %d>%d" % [p.hearts, c.hearts, p.gear, c.gear]]
		"defeat":
			return [lost and c.hearts == 0 and c.mode == "DEFEATED", "a hit took his last heart: hearts %d>%d" % [p.hearts, c.hearts]]
		"respawn":
			return [c.mode == "RESPAWNING" and p.mode in ["FALLEN", "DEFEATED"], "Main respawned him from %s" % p.mode]
		"celebrate":
			return [c.mode == "CELEBRATING", "on the teleport circle"]
		"slash":
			return [c.n_slash == p.n_slash + 1 and c["in"].contains("J+"), "a slash press read, the swing begins"]
	match from:
		"slash":
			if c.mode == "FALLEN":
				return [to in ["sword_rise", "sword_fall"], "fell out of the level on swing tick %d" % swing_tick]
			return [swing_tick == SWING_TICKS and c.mode == "PLAY", "the swing ends on swing tick %d" % swing_tick]
		"hurt":
			return [p.mode == "HURT" and c.mode in ["PLAY", "FALLEN"], "hurt_time ends: mode %s>%s" % [p.mode, c.mode]]
		"respawn":
			return [p.mode == "RESPAWNING" and c.mode == "PLAY", "respawn_time ends"]
	if p.gear == Rudy.Gear.NONE and c.gear == Rudy.Gear.SWORD:
		return [true, "walked into the pickup"]
	var air_from := from.ends_with("rise") or from.ends_with("fall")
	if to.ends_with("rise"):
		if p.floor:
			return [c.vy == -1500.0 and c["in"].contains("Space+"), "a jump press read on the floor: vy %.0f" % c.vy]
		return [false, "rise entered in the air"]
	if to.ends_with("fall"):
		if air_from:
			return [p.vy < 0.0 and c.vy >= 0.0 and absf(c.vx) > 1.0, "at the top, moving sideways: vy %.1f>%.1f, vx %.1f" % [p.vy, c.vy, c.vx]]
		return [p.floor and not c.floor and absf(c.vx) > 1.0, "ran off a ledge: vx %.1f" % c.vx]
	if air_from:
		return [c.floor and not p.floor, "lands: vx %.1f" % c.vx]
	if to.ends_with("run"):
		return [c.floor and absf(c.vx) > 1.0, "a direction held: vx %.1f" % c.vx]
	if to.ends_with("idle"):
		var turned: bool = c.vx == 0.0 and absf(p.vx) > 200.0
		return [c.floor and absf(c.vx) <= 1.0, "%s: vx %.1f>%.1f" % ["turned on the ground" if turned else "slowed to a stop", p.vx, c.vx]]
	return [false, "no cause known"]


func _report() -> void:
	# The per-tick log.
	var last_sc := ""
	for s in _samples:
		if s.sc != last_sc:
			last_sc = s.sc
			for info in _scenarios:
				if info.id == s.sc:
					print("== SCENARIO %s, %s: starts at %s ==" % [info.id, info.what, info.where])
		print("tick %5d %s st %4d %-11s %-10s pos %.4f %-16s spr %d rig %d grip %7.2f lean %6.2f x %5.2f arc %.3f hb_dis %d v(%7.1f,%7.1f) floor %d gear %d hearts %d at %7.1f in %s" % [
			s.t, s.sc, _st(s), s.mode, s.clip, s.pos, s.pose, int(s.spr), int(s.rig), s.grip, s.lean,
			s.lean_x, s.arc, int(s.dis), s.vx, s.vy, int(s.floor), s.gear, s.hearts, s.x,
			s["in"] if s["in"] != "" else "-"])

	# Swings: the ticks a slash press started a swing (one slash sound each).
	var swings: Array[int] = []
	for i in range(1, _samples.size()):
		if _samples[i].sc == _samples[i - 1].sc and _samples[i].n_slash > _samples[i - 1].n_slash:
			swings.append(i)

	# Entries: every tick from a scenario's first input on whose clip differs
	# from the tick before, or on which a new swing starts.
	var entries: Array[Dictionary] = []
	for i in range(1, _samples.size()):
		var p := _samples[i - 1]
		var c := _samples[i]
		if c.sc != p.sc or _st(c) < 0:
			continue
		if c.clip != p.clip or i in swings:
			var cause := _cause(p, c, _swing_tick(i, swings))
			entries.append({"i": i, "from": String(p.clip), "to": String(c.clip), "ok": cause[0], "why": cause[1]})

	# The scenarios: keys and states.
	print("== SCENARIOS ==")
	for info in _scenarios:
		var states: PackedStringArray = []
		for e in entries:
			if _samples[e.i].sc == info.id:
				states.append("%s@%d" % [e.to, _st(_samples[e.i])])
		print("%s %s | starts at %s" % [info.id, info.what, info.where])
		print("%s keys: %s" % [info.id, " ".join(PackedStringArray(_keys_log[info.id]))])
		print("%s states: %s" % [info.id, " > ".join(states)])

	print("== STATES ==")
	_check("every scripted wait was met", _waits_failed.is_empty(), "; ".join(PackedStringArray(_waits_failed)))

	# 1. Each clip: entered, from 0, with its pose and the two visibilities.
	for clip: StringName in CLIP_POSE:
		var mine := entries.filter(func(e): return e.to == String(clip))
		var wrong: PackedStringArray = []
		for e in mine:
			var s := _samples[e.i]
			var rig_clip := clip == &"slash"
			if absf(s.pos) > POSITION_TOLERANCE or s.pose != CLIP_POSE[clip] or s.spr == rig_clip or s.rig != rig_clip:
				wrong.append("%s pos %.4f pose %s spr %d rig %d" % [_at(s), s.pos, s.pose, int(s.spr), int(s.rig)])
		var first := "never entered"
		if not mine.is_empty():
			var e: Dictionary = mine[0]
			first = "first on %s (tick %d) from %s: %s" % [_at(_samples[e.i]), _samples[e.i].t, e.from, e.why]
		_check("clip %s plays from 0 on the tick its state is entered, showing %s, Sprite %s, SlashRig %s" % [
			clip, CLIP_POSE[clip], "hidden" if clip == &"slash" else "shown", "shown" if clip == &"slash" else "hidden"],
			not mine.is_empty() and wrong.is_empty(),
			"%s; %d entries; wrong: [%s]" % [first, mine.size(), ", ".join(wrong)])

	# 2. The run's first cell shows for 8 ticks.
	for clip: StringName in RUN_SECOND_CELL:
		var stints: PackedStringArray = []
		var bad := false
		var n := 0
		for e in entries:
			if e.to != String(clip):
				continue
			n += 1
			var i: int = e.i
			var length := 0
			var first_cell := 0
			while i + length < _samples.size() and _samples[i + length].sc == _samples[i].sc and _samples[i + length].clip == clip:
				if first_cell == length and _samples[i + length].pose == CLIP_POSE[clip]:
					first_cell += 1
				length += 1
			var ok := first_cell == mini(RUN_FIRST_CELL_TICKS, length)
			if length > RUN_FIRST_CELL_TICKS:
				ok = ok and _samples[i + RUN_FIRST_CELL_TICKS].pose == RUN_SECOND_CELL[clip]
			bad = bad or not ok
			stints.append("%s: %d ticks, first cell %d%s" % [_at(_samples[i]), length, first_cell, "" if ok else " WRONG"])
		_check("%s shows %s for its first %d ticks, then %s" % [clip, CLIP_POSE[clip], RUN_FIRST_CELL_TICKS, RUN_SECOND_CELL[clip]],
			n > 0 and not bad, "; ".join(stints))

	# 3. Transitions, against section 3's table.
	var table: Dictionary[String, bool] = {}
	for row in TABLE:
		for to in row[1]:
			table["%s>%s" % [row[0], to]] = true
	var seen: Dictionary[String, Array] = {}
	for e in entries:
		var pair := "%s>%s" % [e.from, e.to]
		if not seen.has(pair):
			seen[pair] = []
		seen[pair].append(e)
	for pair in seen:
		var list: Array = seen[pair]
		var bad: PackedStringArray = []
		var at: PackedStringArray = []
		for e in list:
			at.append(_at(_samples[e.i]))
			if not e.ok:
				bad.append("%s: %s" % [_at(_samples[e.i]), e.why])
		var listed := table.has(pair)
		var where := "in the table" if listed else ("NOT in the table, measured: see ANOMALIES" if MEASURED_OFF_TABLE.has(pair) else "NOT in the table")
		_check("transition %s (%s): %s" % [pair.replace(">", " -> "), where, list[0].why],
			(listed or MEASURED_OFF_TABLE.has(pair)) and bad.is_empty(),
			"%d times, on %s%s" % [list.size(), ", ".join(at), "" if bad.is_empty() else "; wrong cause: " + "; ".join(bad)])

	# 4. Every swing, tick by tick.
	var slash_anim := _player_anim()
	var tracks := {
		"grip": slash_anim.find_track(^"SlashRig/Lean/Grip:rotation_degrees", Animation.TYPE_VALUE),
		"lean": slash_anim.find_track(^"SlashRig/Lean:rotation_degrees", Animation.TYPE_VALUE),
		"lean_x": slash_anim.find_track(^"SlashRig/Lean:position", Animation.TYPE_VALUE),
		"arc": slash_anim.find_track(^"SlashRig/Lean/Arc:modulate:a", Animation.TYPE_VALUE),
	}
	var live_in_swing: Dictionary[int, bool] = {}
	for start in swings:
		var s0 := _samples[start]
		var end := SWING_TICKS # the tick the swing leaves the slash clip
		for k in range(1, SWING_TICKS + 1):
			if start + k >= _samples.size() or _samples[start + k].sc != s0.sc or _samples[start + k].clip != &"slash":
				end = k
				break
		var max_pos := 0.0
		var max_rig := {"grip": 0.0, "lean": 0.0, "lean_x": 0.0, "arc": 0.0}
		var clip_wrong: PackedStringArray = []
		var vis_wrong: PackedStringArray = []
		var live: Array[int] = []
		for k in range(0, end + 1):
			if start + k >= _samples.size():
				break
			var s := _samples[start + k]
			if not s.dis:
				live.append(k)
				live_in_swing[start + k] = true
			if k == end:
				if not s.spr or s.rig:
					vis_wrong.append("k%d spr %d rig %d" % [k, int(s.spr), int(s.rig)])
				continue
			if s.clip != &"slash":
				clip_wrong.append("k%d %s" % [k, s.clip])
				continue
			max_pos = maxf(max_pos, absf(s.pos - k / 60.0))
			var time := k / 60.0
			var want := {
				"grip": slash_anim.value_track_interpolate(tracks.grip, time),
				"lean": slash_anim.value_track_interpolate(tracks.lean, time),
				"lean_x": (slash_anim.value_track_interpolate(tracks.lean_x, time) as Vector2).x,
				"arc": slash_anim.value_track_interpolate(tracks.arc, time),
			}
			for key in want:
				max_rig[key] = maxf(max_rig[key], absf(float(s[key]) - float(want[key])))
			if s.spr or not s.rig:
				vis_wrong.append("k%d spr %d rig %d" % [k, int(s.spr), int(s.rig)])
		var cut := "" if end == SWING_TICKS else ", cut on swing tick %d to %s" % [end, _samples[start + end].clip]
		var rig_ok := max_pos <= POSITION_TOLERANCE and clip_wrong.is_empty()
		for key in max_rig:
			rig_ok = rig_ok and max_rig[key] <= RIG_TOLERANCE
		_check("swing on %s (tick %d)%s: clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there" % [_at(s0), s0.t, cut],
			rig_ok and s0["in"].contains("J+"),
			"press read on swing tick 0: %s; ticks 0-%d; max error: position %.6f s, Grip %.4f, Lean %.4f, Lean x %.4f, Arc %.4f%s" % [
				s0["in"].contains("J+"), end - 1, max_pos, max_rig.grip, max_rig.lean, max_rig.lean_x, max_rig.arc,
				"" if clip_wrong.is_empty() else "; not slash: " + ", ".join(clip_wrong)])
		_check("swing on %s: SlashRig shows and the Sprite hides on ticks 0-%d, the Sprite shows again on tick %d" % [_at(s0), end - 1, end],
			vis_wrong.is_empty(), "wrong: [%s]" % ", ".join(vis_wrong))
		var want_live: Array[int] = []
		for k in range(LIVE_FIRST, mini(LIVE_LAST, end - 1) + 1):
			want_live.append(k)
		_check("swing on %s: hitbox live on swing ticks %d-%d only (before any cut), whatever follows" % [_at(s0), LIVE_FIRST, LIVE_LAST],
			live == want_live, "live on %s, then %s" % [str(live), _samples[mini(start + end, _samples.size() - 1)].clip])
	var stray: PackedStringArray = []
	for i in _samples.size():
		if not _samples[i].dis and not live_in_swing.has(i):
			stray.append(_at(_samples[i]))
	_check("the hitbox is never live outside a swing's ticks", stray.is_empty(), "%d swings; stray live ticks: [%s]" % [swings.size(), ", ".join(stray)])

	# Transitions no scenario reached.
	print("== NOT REACHED ==")
	var unreached := 0
	for row in TABLE:
		for to in row[1]:
			if not seen.has("%s>%s" % [row[0], to]):
				unreached += 1
				print("NOT REACHED  %s -> %s" % [row[0], to])
	print("%d of %d table transitions not reached" % [unreached, table.size()])

	print("== ANOMALIES ==")
	for pair in MEASURED_OFF_TABLE:
		if seen.has(pair):
			var at: PackedStringArray = []
			for e in seen[pair]:
				at.append("%s (tick %d)" % [_at(_samples[e.i]), _samples[e.i].t])
			print("ANOMALY  %s: %s; on %s" % [pair.replace(">", " -> "), MEASURED_OFF_TABLE[pair], ", ".join(at)])

	print("RESULT %s: %d checks, %d failed, %d ticks" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures, _samples.size()])
	get_tree().quit(1 if _failures > 0 else 0)


## The slash clip, read from the library of the last Rudy's player: the same
## resource every Rudy uses.
func _player_anim() -> Animation:
	var lib: AnimationLibrary = load("res://content/rudy/rudy_animations.tres")
	return lib.get_animation(&"slash")
