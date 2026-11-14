extends Node
## The pin: Rudy's behaviour today, before any animation change
## (CHANGE-BRIEF.md section 9; sessions/session-1-answer.md section 5, as
## corrected in sessions/plan-1-review.md). Run from the assignment folder:
##   scripts/run-test.sh test_rudy_pin.tscn 60
##
## The scene is the test's own: a floor, the sword pickup at x -500, a row of
## spikes at x 2500 and Rudy at the origin, with no Main (so no title, camera,
## music, falling out, defeat, respawn or celebrate; checks.tscn covers those).
##
## Rules this test keeps:
## - Rudy is driven only by InputEventKey events for the project's physical
##   keys D, A, Space and J, sent with Input.parse_input_event. It never calls
##   Rudy's or RudyLook's methods to drive him and never writes his velocity,
##   position or state. It reads his properties, and calls two read-only
##   queries that change nothing: is_on_floor(), which section 5 asks to
##   record, and RudyLook.frame(), for I5.
## - It steps one rendered frame at a time with process_frame. Under
##   --fixed-fps 60 at 60 physics ticks per second, one frame is one tick, and
##   an event sent after an await is read on the next tick.
## - This node is the recorder. Its process_physics_priority is 100 (set in
##   the scene), so its _physics_process runs after Rudy's on every tick and
##   sample N is the state Rudy left at the end of tick N.
##
## Tick numbers inside a swing count from the tick its press is read (tick 0).
## TIMING lines pin numbers that may change on purpose (the brief's re-pin
## step); INVARIANT lines pin facts that must survive any change. Every
## number in the TIMING constants below was measured on this baseline.
## Prints a per-tick trail, then the two groups, then a RESULT line; quits 1
## on any failure.
##
## 2026-11-13, after the change (CHANGE-BRIEF.md Revision 5, "The pin's state
## order"): INVARIANT I9 added, the order of states over the whole scripted
## run. Nothing else in this file changed.

# --- TIMING: measured on baseline 2026-11-12 ---
## T1: cell lengths in ticks over the first 60 ticks of a run from a
## standstill, without the sword; the first cell is RUN-A. The last entry is
## the cell the 60-tick window cuts off. Measured on baseline 2026-11-12.
const RUN_CELLS_PLAIN: Array[int] = [7, 8, 7, 8, 7, 7, 8, 7, 1]
## T2: the same with the sword (SWORD-RUN-A first). Measured on baseline 2026-11-12.
const RUN_CELLS_SWORD: Array[int] = [7, 8, 7, 8, 7, 7, 8, 7, 1]
## T3: ticks the slash pose shows (ticks 0 to this minus 1), and the tick the
## swing ends and the sword form's next pose shows. Measured on baseline 2026-11-12.
const SLASH_POSE_TICKS := 17
const SLASH_END_TICK := 17
## T4: the first and last tick on which the hitbox is live. Measured on baseline 2026-11-12.
const LIVE_FIRST_TICK := 2
const LIVE_LAST_TICK := 10
## T5: a press read on this tick is still ignored; one on the next starts a
## swing. Measured on baseline 2026-11-12.
const LAST_IGNORED_PRESS_TICK := 17
## T6: what the run does after a slash: "resumes" (its cell clock was frozen
## during the swing) or "restarts" (from the first cell). Measured on baseline 2026-11-12.
const RUN_AFTER_SLASH := "resumes"
## T7: ticks from the tick a release of D is read to the first CHAR-IDLE tick,
## from full speed. Measured on baseline 2026-11-12.
const STOP_TICKS := 5
## T8: ticks from the tick a turning press is read on the ground to the first
## run tick. Measured on baseline 2026-11-12.
const TURN_HOLD_TICKS := 7
## T9: ticks in HURT mode after a hit. Measured on baseline 2026-11-12.
const HURT_TICKS := 21

## Swing ticks on which E1's presses are read (brief section 6).
const REPRESS_TICKS: Array[int] = [1, 2, 10, 11, 16, 17, 18]
## Swing ticks on which E2's jumps are read.
const JUMP_TICKS: Array[int] = [1, 5, 12]
## Run ticks before the slash in run, slash, run.
const RUN_BEFORE_SLASH := 20
## x at which the J press is sent on the way to the spikes, so the hit lands
## inside the swing: the spikes' box starts at 2460 and his capsule is 20 wide
## either side, at 560 px/s (9.33 px per tick).
const SPIKE_SLASH_X := 2390.0

const PLAIN_POSES: Array[StringName] = [&"CHAR-IDLE", &"CHAR-RUN-A", &"CHAR-RUN-B", &"CHAR-RISE", &"CHAR-FALL"]

## I9: a tick's state is its pose (Rudy.pose), mapped by this table. Any
## other pose fails I9. Added after the change (Revision 5).
const POSE_STATES := {
	&"CHAR-IDLE": "idle",
	&"CHAR-RUN-A": "run",
	&"CHAR-RUN-B": "run",
	&"CHAR-RISE": "rise",
	&"CHAR-FALL": "fall",
	&"CHAR-HURT": "hurt",
	&"CHAR-SWORD-IDLE": "sword_idle",
	&"CHAR-SWORD-RUN-A": "sword_run",
	&"CHAR-SWORD-RUN-B": "sword_run",
	&"CHAR-SWORD-RISE": "sword_rise",
	&"CHAR-SWORD-FALL": "sword_fall",
	&"CHAR-SWORD-SLASH": "slash",
}
## I9: the states of the whole scripted run, consecutive ticks of one state
## collapsed into one entry. Written out from the trail lines of the baseline
## log committed with this pin (git show 3908ae80:./logs/test_rudy_pin_60fps.log),
## mapped by POSE_STATES. The line was added after the change (Revision 5);
## the comment after each entry is the baseline tick on which that state begins.
const STATE_ORDER: Array[String] = [
	"idle",        # 0
	"run",         # 16
	"idle",        # 81
	"rise",        # 92
	"idle",        # 133
	"run",         # 172
	"sword_run",   # 283
	"sword_idle",  # 289
	"slash",       # 311
	"sword_idle",  # 328
	"slash",       # 347
	"sword_idle",  # 364
	"slash",       # 365
	"sword_idle",  # 382
	"slash",       # 398
	"sword_rise",  # 415
	"sword_idle",  # 440
	"slash",       # 451
	"sword_rise",  # 468
	"sword_idle",  # 497
	"slash",       # 508
	"sword_rise",  # 525
	"sword_idle",  # 561
	"sword_run",   # 572
	"sword_idle",  # 637
	"sword_run",   # 648
	"slash",       # 668
	"sword_run",   # 685
	"sword_idle",  # 733
	"sword_run",   # 744
	"slash",       # 915
	"hurt",        # 921
	"idle",        # 942
]

var _samples: Array[Dictionary] = []
var _mark: Dictionary = {} ## named ticks the script records as it goes
var _waits_failed: Array[String] = []
var _timing: Array[String] = []
var _invariant: Array[String] = []
var _failures := 0

@onready var _rudy: Rudy = $World/Rudy
@onready var _look: RudyLook = $World/Rudy/Look
@onready var _box: CollisionShape2D = $World/Rudy/SwordHitbox/Shape


func _ready() -> void:
	_run.call_deferred()


func _physics_process(_delta: float) -> void:
	var pose: StringName = _rudy.pose
	_samples.append({
		"t": _samples.size(),
		"mode": Rudy.Mode.keys()[_rudy.mode],
		"pose": pose,
		"vx": _rudy.velocity.x,
		"vy": _rudy.velocity.y,
		"floor": _rudy.is_on_floor(),
		"clock": _rudy._slash_clock,
		"live": not _box.disabled,
		"facing": _rudy.facing,
		"gear": _rudy.gear,
		"x": _rudy.global_position.x,
		"frame_ok": RudyLook.FRAMES.has(pose) and _look.frame() == RudyLook.FRAMES[pose],
		"jp_slash": Input.is_action_just_pressed(&"slash"),
		"jp_jump": Input.is_action_just_pressed(&"jump"),
		"n_slash": Sfx.count(&"slash"),
	})


# --- Driving ---

func _key(code: Key, pressed: bool) -> void:
	var e := InputEventKey.new()
	e.physical_keycode = code
	e.pressed = pressed
	Input.parse_input_event(e)


## The tick on which an event sent now is read.
func _now() -> int:
	return _samples.size()


func _last() -> Dictionary:
	return _samples[-1]


func _frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


## Steps until events sent next are read on tick t.
func _until(t: int) -> void:
	while _samples.size() < t:
		await get_tree().process_frame


## A key down now and up on the next tick; returns the tick the press is read.
func _tap(code: Key) -> int:
	var t := _now()
	_key(code, true)
	await _frames(1)
	_key(code, false)
	return t


## Steps until cond(last sample) holds, at most max_ticks; a timeout is noted.
func _wait_for(label: String, max_ticks: int, cond: Callable) -> bool:
	for i in max_ticks:
		await _frames(1)
		if cond.call(_last()):
			return true
	_waits_failed.append("%s (gave up after %d ticks, at tick %d)" % [label, max_ticks, _now() - 1])
	return false


func _standing(s: Dictionary) -> bool:
	return s.floor and absf(s.vx) <= 1.0 and s.clock < 0.0 and s.mode == "PLAY"


# --- The script ---

func _run() -> void:
	# 1. Settle on the floor.
	await _frames(10)
	await _wait_for("settle", 30, _standing)
	await _frames(5)

	# 2. Run right without the sword for 60 ticks, release, stop.
	_mark.run_plain = _now()
	_key(KEY_D, true)
	await _until(_mark.run_plain + 60)
	_mark.release_plain = _now()
	_key(KEY_D, false)
	await _wait_for("stop after the plain run", 60, func(s): return s.pose == &"CHAR-IDLE")
	await _frames(10)

	# 3. Jump in place, land; then J without the sword (I8).
	_mark.jump_plain = await _tap(KEY_SPACE)
	await _frames(5)
	await _wait_for("land after the plain jump", 120, _standing)
	await _frames(5)
	_mark.slash_no_sword = await _tap(KEY_J)
	await _frames(25)

	# 4. Hold A (a turn on the ground) until he has the sword; stop; turn right.
	_mark.turn_left = _now()
	_key(KEY_A, true)
	await _wait_for("reach the sword", 400, func(s): return s.gear == Rudy.Gear.SWORD)
	_key(KEY_A, false)
	await _wait_for("stop after the pickup", 60, _standing)
	await _frames(5)
	_mark.turn_right = await _tap(KEY_D)
	await _frames(15)

	# 5a. A single slash.
	_mark.slash_single = await _tap(KEY_J)
	await _frames(35)
	# 5b. A slash with presses read on swing ticks 1, 2, 10, 11, 16, 17 and 18.
	var s := _now()
	_mark.slash_repress = s
	_key(KEY_J, true)
	for k in REPRESS_TICKS:
		await _until(s + k)
		_key(KEY_J, false)
		_key(KEY_J, true)
	await _frames(1)
	_key(KEY_J, false)
	await _wait_for("the swing after the presses ends", 60, func(x): return x.clock < 0.0)
	await _frames(15)

	# 6. Jumps read on swing ticks 1, 5 and 12, each in its own swing.
	for k in JUMP_TICKS:
		s = _now()
		_mark["slash_jump_%d" % k] = s
		_key(KEY_J, true)
		await _until(s + 1)
		_key(KEY_J, false)
		await _until(s + k)
		_key(KEY_SPACE, true)
		await _frames(1)
		_key(KEY_SPACE, false)
		await _wait_for("land after the jump on swing tick %d" % k, 150, _standing)
		await _frames(10)

	# 7a. Run right with the sword for 60 ticks, release, stop.
	_mark.run_sword = _now()
	_key(KEY_D, true)
	await _until(_mark.run_sword + 60)
	_key(KEY_D, false)
	await _wait_for("stop after the sword run", 60, _standing)
	await _frames(10)
	# 7b. Run, slash, run, holding D throughout.
	_mark.run_slash_run = _now()
	_key(KEY_D, true)
	await _until(_mark.run_slash_run + RUN_BEFORE_SLASH)
	_mark.run_slash = await _tap(KEY_J)
	await _until(_mark.run_slash + 60)
	_mark.run_slash_release = _now()
	_key(KEY_D, false)
	await _wait_for("stop after run, slash, run", 60, _standing)
	await _frames(10)

	# 8. Hold D into the spikes, J pressed on the way; wait out HURT.
	_key(KEY_D, true)
	await _wait_for("reach x %.0f" % SPIKE_SLASH_X, 600, func(x): return x.x >= SPIKE_SLASH_X)
	_mark.spike_slash = await _tap(KEY_J)
	await _wait_for("the spikes' hit", 60, func(x): return x.mode == "HURT")
	_mark.hit = _now() - 1
	_key(KEY_D, false)
	await _wait_for("HURT ends", 120, func(x): return x.mode != "HURT")
	await _frames(10)

	_print_trail()
	_check_all()
	get_tree().quit(1 if _failures > 0 else 0)


# --- Reading the samples ---

func _print_trail() -> void:
	print("== TRAIL (one line per physics tick, sampled after Rudy) ==")
	for s in _samples:
		print("tick %4d %-7s %-18s v(%7.1f,%7.1f) floor %d clock %7.4f live %d facing %2d gear %d x %7.1f jp %s%s snd %d%s" % [
			s.t, s.mode, s.pose, s.vx, s.vy, int(s.floor), s.clock, int(s.live), s.facing, s.gear, s.x,
			"J" if s.jp_slash else "-", "S" if s.jp_jump else "-", s.n_slash,
			"" if s.frame_ok else "  FRAME-MISMATCH"])
	print("marks ", _mark)


## Every swing: start (its tick 0), end (the first tick not swinging, or -1),
## whether it began while another swing was under way, its live ticks and
## its dead-to-live edges, both relative to start, and the mode it ended in.
func _swings() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var cur: Dictionary = {}
	for i in _samples.size():
		var c: float = _samples[i].clock
		var prev: float = _samples[i - 1].clock if i > 0 else -1.0
		if c >= 0.0 and (prev < 0.0 or c < prev):
			if not cur.is_empty():
				cur.end = i
				out.append(cur)
			cur = {"start": i, "end": -1, "restart": prev >= 0.0}
		elif c < 0.0 and not cur.is_empty():
			cur.end = i
			out.append(cur)
			cur = {}
	if not cur.is_empty():
		out.append(cur)
	for w in out:
		var stop: int = w.end if w.end >= 0 else _samples.size()
		var live: Array[int] = []
		var edges := 0
		for i in range(w.start, stop):
			if _samples[i].live:
				live.append(i - w.start)
				if i == 0 or not _samples[i - 1].live:
					edges += 1
		w.live = live
		w.edges = edges
		w.end_mode = _samples[w.end].mode if w.end >= 0 else ""
		w.pose_ticks = 0
		for i in range(w.start, stop):
			if _samples[i].pose == &"CHAR-SWORD-SLASH":
				w.pose_ticks += 1
	return out


func _swing_at(swings: Array[Dictionary], start: int) -> Dictionary:
	for w in swings:
		if w.start == start:
			return w
	return {}


## Lengths of the runs of equal poses over ticks [from, from + n), and the
## first pose.
func _cells(from: int, n: int) -> Dictionary:
	var lens: Array[int] = []
	var first: StringName = _samples[from].pose
	var cur: StringName = &""
	for i in range(from, from + n):
		var p: StringName = _samples[i].pose
		if p == cur:
			lens[-1] += 1
		else:
			lens.append(1)
			cur = p
	return {"first": first, "lens": lens}


func _first_tick(from: int, cond: Callable) -> int:
	for i in range(from, _samples.size()):
		if cond.call(_samples[i]):
			return i
	return -1


func _range_text(a: Array[int]) -> String:
	if a.is_empty():
		return "none"
	return "%d-%d (%d ticks)" % [a[0], a[-1], a.size()] if a == _span(a[0], a[-1]) else str(a)


func _span(a: int, b: int) -> Array[int]:
	var out: Array[int] = []
	for i in range(a, b + 1):
		out.append(i)
	return out


func _check(group: Array[String], id: String, ok: bool, what: String, measured: String) -> void:
	if not ok:
		_failures += 1
	group.append("%s  %s %s  (%s)" % ["PASS" if ok else "FAIL", id, what, measured])


# --- The checks ---

func _check_all() -> void:
	var swings := _swings()
	var single := _swing_at(swings, _mark.get("slash_single", -1))

	# T1, T2: the run's cells.
	for spec in [["T1", "run_plain", &"CHAR-RUN-A", RUN_CELLS_PLAIN], ["T2", "run_sword", &"CHAR-SWORD-RUN-A", RUN_CELLS_SWORD]]:
		var p: int = _mark.get(spec[1], -1)
		if p < 0 or p + 60 > _samples.size():
			_check(_timing, spec[0], false, "run cells", "the run was not reached")
			continue
		var c := _cells(p, 60)
		var starts: bool = absf(_samples[p].vx) > 1.0 and (p == 0 or absf(_samples[p - 1].vx) <= 1.0)
		_check(_timing, spec[0], starts and c.first == spec[2] and c.lens == spec[3],
			"run from a standstill: moves on the press tick, %s first, cells %s" % [spec[2], spec[3]],
			"moves on press tick: %s, first %s, cells %s" % [starts, c.first, c.lens])

	# T3, T4: the single slash.
	if single.is_empty():
		_check(_timing, "T3", false, "slash pose and end", "no swing on the press tick")
		_check(_timing, "T4", false, "live ticks", "no swing on the press tick")
	else:
		var length: int = single.end - single.start if single.end >= 0 else -1
		var next_pose: StringName = _samples[single.end].pose if single.end >= 0 else &""
		_check(_timing, "T3", single.pose_ticks == SLASH_POSE_TICKS and length == SLASH_END_TICK and next_pose == &"CHAR-SWORD-IDLE",
			"slash pose on ticks 0-%d, swing ends on tick %d with CHAR-SWORD-IDLE" % [SLASH_POSE_TICKS - 1, SLASH_END_TICK],
			"slash pose %d ticks, ends on tick %d, then %s" % [single.pose_ticks, length, next_pose])
		_check(_timing, "T4", single.live == _span(LIVE_FIRST_TICK, LIVE_LAST_TICK),
			"hitbox live on ticks %d-%d" % [LIVE_FIRST_TICK, LIVE_LAST_TICK],
			"live on ticks %s" % _range_text(single.live))

	# T5: the press on tick 17 ignored, the one on 18 starts a swing.
	var r: int = _mark.get("slash_repress", -1)
	if r < 0 or r + 20 > _samples.size():
		_check(_timing, "T5", false, "presses at the swing's end", "not reached")
	else:
		var a := r + LAST_IGNORED_PRESS_TICK
		var read_both: bool = _samples[a].jp_slash and _samples[a + 1].jp_slash
		var ignored := _swing_at(swings, a).is_empty()
		var started := not _swing_at(swings, a + 1).is_empty()
		_check(_timing, "T5", read_both and ignored and started,
			"a press read on swing tick %d is ignored; one on tick %d starts a swing" % [LAST_IGNORED_PRESS_TICK, LAST_IGNORED_PRESS_TICK + 1],
			"presses read: %s, tick %d starts a swing: %s, tick %d starts a swing: %s" % [read_both, LAST_IGNORED_PRESS_TICK, not ignored, LAST_IGNORED_PRESS_TICK + 1, started])

	# T6: the run's phase after a slash.
	var rs: int = _mark.get("run_slash", -1)
	var rr: int = _mark.get("run_slash_run", -1)
	var rw := _swing_at(swings, rs)
	var rsw: int = _mark.get("run_sword", -1)
	if rw.is_empty() or rw.end < 0 or rsw < 0:
		_check(_timing, "T6", false, "run phase after a slash", "no swing in the run")
	else:
		var after_n: int = 20
		var before: Array[StringName] = []
		for i in range(rr, rs):
			before.append(_samples[i].pose)
		var after: Array[StringName] = []
		for i in range(rw.end, rw.end + after_n):
			after.append(_samples[i].pose)
		# The uninterrupted sword run (7a) is the reference pattern.
		var resume: Array[StringName] = []
		var restart: Array[StringName] = []
		for i in after_n:
			resume.append(_samples[rsw + before.size() + i].pose)
			restart.append(_samples[rsw + i].pose)
		var measured := "resumes" if after == resume else ("restarts" if after == restart else "neither")
		var before_cell := 0
		for i in range(rs - 1, rr - 1, -1):
			if _samples[i].pose != _samples[rs - 1].pose:
				break
			before_cell += 1
		var after_cell := 0
		for i in range(rw.end, _samples.size()):
			if _samples[i].pose != _samples[rw.end].pose:
				break
			after_cell += 1
		_check(_timing, "T6", measured == RUN_AFTER_SLASH,
			"the run %s after a slash" % RUN_AFTER_SLASH,
			"%s: %s for %d ticks before the swing, %s for %d ticks after it" % [measured, _samples[rs - 1].pose, before_cell, _samples[rw.end].pose, after_cell])

	# T7: stop.
	var rel: int = _mark.get("release_plain", -1)
	var idle := _first_tick(rel, func(x): return x.pose == &"CHAR-IDLE") if rel >= 0 else -1
	_check(_timing, "T7", idle >= 0 and idle - rel == STOP_TICKS,
		"CHAR-IDLE %d ticks after the release is read" % STOP_TICKS,
		"%d ticks" % (idle - rel))

	# T8: the turn on the ground.
	var tl: int = _mark.get("turn_left", -1)
	var moved := _first_tick(tl, func(x): return absf(x.vx) > 1.0) if tl >= 0 else -1
	var turned_at_once: bool = tl >= 0 and _samples[tl].facing == -1 and _samples[tl].pose == &"CHAR-IDLE"
	_check(_timing, "T8", turned_at_once and moved >= 0 and moved - tl == TURN_HOLD_TICKS,
		"a turn faces left on its tick and moves %d ticks later" % TURN_HOLD_TICKS,
		"faces left at once: %s, moves after %d ticks" % [turned_at_once, moved - tl])

	# T9: HURT.
	var h: int = _mark.get("hit", -1)
	var hurt := 0
	if h >= 0:
		for i in range(h, _samples.size()):
			if _samples[i].mode != "HURT":
				break
			hurt += 1
	_check(_timing, "T9", hurt == HURT_TICKS, "HURT lasts %d ticks" % HURT_TICKS, "%d ticks" % hurt)

	# I1: live only in the slash pose; one edge and the reference's live count per full swing.
	var live_wrong: Array[int] = []
	for x in _samples:
		if x.live and x.pose != &"CHAR-SWORD-SLASH":
			live_wrong.append(x.t)
	var ref_live: int = single.live.size() if not single.is_empty() else -1
	var swing_wrong: Array[String] = []
	var counts: Array[int] = []
	for w in swings:
		counts.append(w.live.size())
		var cut: bool = w.end_mode == "HURT"
		if w.edges > 1 or (not cut and (w.edges != 1 or w.live.size() != 9)) or (cut and w.live.size() > 9):
			swing_wrong.append("swing at %d: %d edges, %d live" % [w.start, w.edges, w.live.size()])
	_check(_invariant, "I1", live_wrong.is_empty() and swing_wrong.is_empty() and ref_live == 9,
		"the hitbox is live only in CHAR-SWORD-SLASH; every full swing has one dead-to-live edge and 9 live ticks",
		"%d swings, live ticks %s; live outside the pose on %s; %s" % [swings.size(), counts, live_wrong, swing_wrong])

	# I2: no swing starts during a swing.
	var restarts: Array[int] = []
	for w in swings:
		if w.restart:
			restarts.append(w.start)
	var presses_read: Array[int] = []
	var new_in_window: Array[int] = []
	if r >= 0:
		for k in REPRESS_TICKS:
			if r + k < _samples.size() and _samples[r + k].jp_slash:
				presses_read.append(k)
		for w in swings:
			if w.start > r and w.start < r + 18:
				new_in_window.append(w.start - r)
	var all_read: bool = presses_read == REPRESS_TICKS
	_check(_invariant, "I2", restarts.is_empty() and new_in_window.is_empty() and all_read,
		"no swing starts during a swing (presses read on swing ticks %s)" % [REPRESS_TICKS],
		"presses read on %s; swings begun mid-swing at %s; swings begun on ticks 1-17 of the repress swing: %s" % [presses_read, restarts, new_in_window])

	# I3: one slash sound per swing, on its first tick.
	var sound_ticks: Array[int] = []
	var start_ticks: Array[int] = []
	for i in range(1, _samples.size()):
		var d: int = _samples[i].n_slash - _samples[i - 1].n_slash
		for j in d:
			sound_ticks.append(i)
	for w in swings:
		start_ticks.append(w.start)
	_check(_invariant, "I3", sound_ticks == start_ticks and not start_ticks.is_empty(),
		"one slash sound per swing, on the swing's first tick",
		"%d sounds on ticks %s; %d swings from ticks %s" % [sound_ticks.size(), sound_ticks, start_ticks.size(), start_ticks])

	# I4: a hit ends a swing on its tick.
	if h < 1:
		_check(_invariant, "I4", false, "a hit ends a swing on its tick", "no hit")
	else:
		var x := _samples[h]
		var prev := _samples[h - 1]
		var hw := _swing_at(swings, _mark.get("spike_slash", -1))
		var ok: bool = prev.clock >= 0.0 and x.pose == &"CHAR-HURT" and x.clock < 0.0 and not x.live and x.gear == Rudy.Gear.NONE and not hw.is_empty() and hw.end == h
		_check(_invariant, "I4", ok,
			"on a hit's tick during a swing: CHAR-HURT, swing over, hitbox dead, sword gone",
			"hit on swing tick %d; previous tick swinging: %s; then pose %s, clock %.4f, live %s, gear %d" % [h - _mark.get("spike_slash", h), prev.clock >= 0.0, x.pose, x.clock, x.live, x.gear])

	# I5: every pose shows its own frame (the look contract, brief section 3).
	var mismatch: Array[int] = []
	for x in _samples:
		if not x.frame_ok:
			mismatch.append(x.t)
	_check(_invariant, "I5", mismatch.is_empty(),
		"every tick RudyLook.frame() equals RudyLook.FRAMES[Rudy.pose]",
		"%d of %d ticks wrong%s" % [mismatch.size(), _samples.size(), "" if mismatch.is_empty() else ", first %d" % mismatch[0]])

	# I6: forms follow the gear.
	var form_wrong: Array[int] = []
	var seen_sword := 0
	var seen_plain := 0
	for x in _samples:
		var sword_pose: bool = String(x.pose).begins_with("CHAR-SWORD-")
		if sword_pose:
			seen_sword += 1
		if PLAIN_POSES.has(x.pose):
			seen_plain += 1
		if (sword_pose and x.gear != Rudy.Gear.SWORD) or (PLAIN_POSES.has(x.pose) and x.gear != Rudy.Gear.NONE):
			form_wrong.append(x.t)
	_check(_invariant, "I6", form_wrong.is_empty() and seen_sword > 0 and seen_plain > 0,
		"CHAR-SWORD-* poses only with the sword; plain idle, run, rise and fall only without it",
		"%d sword-pose ticks, %d plain-pose ticks, wrong on %s" % [seen_sword, seen_plain, form_wrong])

	# I7: a jump during a swing keeps the swing.
	for k in JUMP_TICKS:
		var js: int = _mark.get("slash_jump_%d" % k, -1)
		var jw := _swing_at(swings, js)
		if jw.is_empty() or jw.end < 0 or single.is_empty():
			_check(_invariant, "I7", false, "jump on swing tick %d keeps the swing" % k, "no swing")
			continue
		var t := js + k
		var takeoff: bool = _samples[t].jp_jump and _samples[t].vy < 0.0 and not _samples[t].floor and _samples[t - 1].floor
		var same: bool = jw.end - jw.start == single.end - single.start and jw.pose_ticks == single.pose_ticks and jw.live == single.live
		var after: StringName = _samples[jw.end].pose
		var air_after: bool = after == &"CHAR-SWORD-RISE" or after == &"CHAR-SWORD-FALL"
		_check(_invariant, "I7", takeoff and same and air_after,
			"jump read on swing tick %d: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose" % k,
			"takeoff: %s, swing %d ticks, pose %d ticks, live %s, then %s" % [takeoff, jw.end - jw.start, jw.pose_ticks, _range_text(jw.live), after])

	# I8: J without the sword.
	var q: int = _mark.get("slash_no_sword", -1)
	if q < 0:
		_check(_invariant, "I8", false, "slash without the sword", "not reached")
	else:
		var swung := false
		var live := false
		for i in range(q, mini(q + 20, _samples.size())):
			swung = swung or _samples[i].clock >= 0.0
			live = live or _samples[i].live
		var sounds: int = _samples[q + 19].n_slash - _samples[q - 1].n_slash
		_check(_invariant, "I8", _samples[q].jp_slash and _samples[q].gear == Rudy.Gear.NONE and not swung and not live and sounds == 0,
			"a slash press without the sword: no swing, no sound, hitbox never live",
			"press read: %s, gear %d, swing: %s, live: %s, sounds %d" % [_samples[q].jp_slash, _samples[q].gear, swung, live, sounds])

	# I9: the order of states over the whole scripted run (Revision 5).
	var order: Array[String] = []
	var order_ticks: Array[int] = []
	var unknown: Array[String] = []
	for x in _samples:
		var st: String = POSE_STATES.get(x.pose, "?%s" % x.pose)
		if not POSE_STATES.has(x.pose) and unknown.size() < 5:
			unknown.append("%s on tick %d" % [x.pose, x.t])
		if order.is_empty() or order[-1] != st:
			order.append(st)
			order_ticks.append(x.t)
	var order_text := "%d states, the same as the baseline's" % order.size()
	if order != STATE_ORDER:
		var n := mini(order.size(), STATE_ORDER.size())
		var part := n
		for i in n:
			if order[i] != STATE_ORDER[i]:
				part = i
				break
		var lo := maxi(part - 3, 0)
		var at_tick: String = str(order_ticks[part]) if part < order_ticks.size() else "none"
		order_text = "%d states against the baseline's %d; they part at index %d (measured state begins on tick %s): measured %s, baseline %s" % [
			order.size(), STATE_ORDER.size(), part, at_tick,
			order.slice(lo, part + 4), STATE_ORDER.slice(lo, part + 4)]
	if not unknown.is_empty():
		order_text += "; poses outside the table: %s" % [unknown]
	_check(_invariant, "I9", order == STATE_ORDER and unknown.is_empty(),
		"the states of the scripted run, consecutive ticks collapsed, are the %d of the baseline log, in order" % STATE_ORDER.size(),
		order_text)

	print("== TIMING ==")
	for line in _timing:
		print(line)
	print("== INVARIANT ==")
	for line in _invariant:
		print(line)
	for w in _waits_failed:
		_failures += 1
		print("FAIL  WAIT %s" % w)
	print("RESULT %s: %d checks, %d failed, %d ticks" % ["PASS" if _failures == 0 else "FAIL", _timing.size() + _invariant.size(), _failures, _samples.size()])
