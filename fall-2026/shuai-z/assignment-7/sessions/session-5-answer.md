I've wired step 2b, and the pin fails on exactly T1, T2 and T6, as you predicted. Every other TIMING and INVARIANT line passes, and so do all the earlier tests at their section 5 counts. My first version broke the slash's last tick; I fixed that in `rudy_look.gd` (ANOMALIES, A1). Nothing is committed.

## What changed

- **`rudy.tscn`**: the Sprite's texture is now the sheet, with `hframes = 4` and `vframes = 4`. Its offset, scale, centring, material and filter are unchanged. The `CHAR-IDLE.png` resource is gone, since nothing in the scene used it any more.
- **`rudy_look.gd`**:
  - `show_pose()` is replaced by `play_clip(clip, restart)`. It plays only when the clip differs from the one playing; a new swing always restarts.
  - New `CELLS` table, in frames.json's order.
  - `pose` and `frame()` are now worked out from `_sprite.frame` through `CELLS`, so they report what the Sprite shows, never the requested clip name.
  - `FRAMES` is kept.
- **`rudy.gd`**:
  - `_pick_pose()` becomes `_pick_clip()`, same priorities, returning only StringName literals.
  - `run_frame_time` and `_run_clock` are gone.
  - `_ready` starts the player on `idle`.
  - A `new_swing` flag on the press tick passes `restart`.
  - `pose` is now a getter that reads `_look.pose`.
- **`test_rudy_clips.gd`**: the stages Revision 3 starts in this step, each with a NEGATIVE line. Beyond what you listed, I made three small changes:
  - **An extra NEGATIVE for check 4 (Sprite sliced 2 × 2).** None of your four damages can make check 4's new clause fail: a 16 × 1 slice still has 16 cells. Without it, that clause would have no negative.
  - **A wider control line**, now covering checks 4, 6, 7 and the text check.
  - **The header comment** now says which step added what.

## `test_rudy_clips.tscn 60`, READBACK to RESULT
```
READBACK
PASS  1 every track resolves to a real node and property (track_problems)  (13 tracks)
PASS  2 key times and clip lengths match the brief to within 1 us  (13 clips, 15 keys)
PASS  3 loop_mode is LOOP_LINEAR for run, sword_run and the one-key clips, LOOP_NONE for slash
PASS  4 every frame track is discrete, every frame key is inside the sheet, below the Sprite's hframes x vframes, and on its cell  (sheet 1640x1544 px / cell 410x386 = 4x4 = 16 cells; Sprite 4 x 4 = 16 cells)
PASS  5 the player: callback_mode_process physics, autoplay empty, speed_scale 1.0, root_node .., the library as its default  (callback 0, autoplay "", speed_scale 1.0, root_node ..)
PASS  6 the Sprite: 4 x 4 on the 1640 x 1544 sheet with mipmaps, offset, scale, centring, material and filter as today, RudyLook's cell table in frames.json's order  (4 x 4, rudy_sheet.png 1640x1544, offset (-205.0, -370.0), scale (0.5, 0.5), centered false, 16 cells)
PASS  7 the library holds exactly section 3's 13 clips, counting the slash stand-in, and exactly the names _pick_clip() can return  (13 clips; _pick_clip() returns celebrate, respawn, defeat, hurt, slash, sword_fall, fall, sword_rise, rise, sword_run, run, sword_idle, idle)
PASS  text: rudy.gd and rudy_look.gd assign neither the Sprite's texture nor its frame
PASS  10.9 no Godot 3 name in rudy.tscn or rudy_animations.tres (playback_speed; loop =, playing =, frames = at a line start)
PASS  10.9 the scan does not flag the Godot 4 names hframes =, vframes =, loop_mode =, sprite_frames =, speed_scale =
NEGATIVE
PASS  control: an undamaged copy passes checks 1, 2, 3, 4, 6, 7 and the text check, so each failure below comes from its damage
PASS  1 idle's track to Sprite:frames, a missing property: must fail on "idle track 0"  (idle track 0: Sprite has no property frames)
PASS  2 run's second key at 8/60 s instead of 0.125 s: must fail on "run key 1"  (run key 1 at 0.133333 s, want 0.125000)
PASS  3 idle set to LOOP_NONE: must fail on "idle loop_mode"  (idle loop_mode 0, want 1)
PASS  4 sword_run's frame track on continuous updates: must fail on "sword_run track 0 update"  (sword_run track 0 update mode 0, want UPDATE_DISCRETE (1))
PASS  4 fall keyed to cell 16, outside the sheet: must fail on "fall key 0 cell 16 is outside"  (fall key 0 cell 16 is outside the sheet's 16 cells; fall key 0 cell 16 is outside the Sprite's 16 cells (hframes x vframes); fall key 0 cell 16, want 4)
PASS  4 rise keyed to cell 4 instead of 3: must fail on "rise key 0 cell 4, want 3"  (rise key 0 cell 4, want 3)
PASS  5 the player on the idle callback: must fail on "callback_mode_process"  (callback_mode_process 1, want physics (0))
PASS  7 hurt removed from the library: must fail on "missing hurt"  (missing hurt; _pick_clip() returns hurt, which has no clip)
PASS  4 the Sprite sliced 2 x 2, so cells 4 to 15 lie outside it: must fail on "outside the Sprite's 4 cells"  (celebrate key 0 cell 8 is outside the Sprite's 4 cells (hframes x vframes); respawn key 0 cell 7 is outside the Sprite's 4 cells (hframes x vframes); defeat key 0 cell 6 is outside the Sprite's 4 cells (hframes x vframes); hurt key 0 cell 5 is outside the Sprite's 4 cells (hframes x vframes); slash key 0 cell 10 is outside the Sprite's 4 cells (hframes x vframes); sword_rise key 0 cell 14 is outside the Sprite's 4 cells (hframes x vframes); fall key 0 cell 4 is outside the Sprite's 4 cells (hframes x vframes); sword_fall key 0 cell 15 is outside the Sprite's 4 cells (hframes x vframes); sword_run key 0 cell 12 is outside the Sprite's 4 cells (hframes x vframes); sword_run key 1 cell 13 is outside the Sprite's 4 cells (hframes x vframes); sword_idle key 0 cell 9 is outside the Sprite's 4 cells (hframes x vframes))
PASS  6 the Sprite sliced 16 x 1: must fail on "sliced 16 x 1"  (the Sprite sliced 16 x 1, want 4 x 4)
PASS  6 the Sprite's texture a whole PNG (CHAR-IDLE.png): must fail on "want the sheet"  (the Sprite's texture is res://content/rudy/frames/CHAR-IDLE.png at (410, 386), want the sheet res://content/rudy/sheet/rudy_sheet.png at (1640, 1544))
PASS  7 a clip the selector never returns (wave) added to the library: must fail on "wave is in the library but _pick_clip() never returns it"  (extra wave; wave is in the library but _pick_clip() never returns it)
PASS  text: rudy_look.gd's text with a line that sets the Sprite's texture: must fail on "rudy_look.gd: assigns the Sprite's texture"  (rudy_look.gd: assigns the Sprite's texture on line 77: _sprite.texture = FRAMES[&"CHAR-IDLE"])
PASS  10.9 the scene's text with speed_scale written as playback_speed: must fail on "playback_speed"  (rudy.tscn: playback_speed)
PASS  10.9 the library's text with loop_mode written as loop = true: must fail on "loop ="  (rudy_animations.tres: "loop =" at a line start; [the same text 11 more times, one per clip])
PASS  10.9 the scene's text with a line playing = true: must fail on "playing ="  (rudy.tscn: "playing =" at a line start)
PASS  10.9 the scene's text with a line frames = ...: must fail on "frames ="  (rudy.tscn: "frames =" at a line start)
RESULT PASS: 28 checks, 0 failed
```

## `test_rudy_pin.tscn 60`, three runs after the fix
All three runs printed the same lines:
```
== TIMING ==
FAIL  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
PASS  T3 slash pose on ticks 0-16, swing ends on tick 17 with CHAR-SWORD-IDLE  (slash pose 17 ticks, ends on tick 17, then CHAR-SWORD-IDLE)
PASS  T4 hitbox live on ticks 2-10  (live on ticks 2-10 (9 ticks))
PASS  T5 a press read on swing tick 17 is ignored; one on tick 18 starts a swing  (presses read: true, tick 17 starts a swing: false, tick 18 starts a swing: true)
FAIL  T6 the run resumes after a slash  (restarts: CHAR-SWORD-RUN-A for 4 ticks before the swing, CHAR-SWORD-RUN-A for 8 ticks after it)
PASS  T7 CHAR-IDLE 5 ticks after the release is read  (5 ticks)
PASS  T8 a turn faces left on its tick and moves 7 ticks later  (faces left at once: true, moves after 7 ticks)
PASS  T9 HURT lasts 21 ticks  (21 ticks)
== INVARIANT ==
PASS  I1 the hitbox is live only in CHAR-SWORD-SLASH; every full swing has one dead-to-live edge and 9 live ticks  (8 swings, live ticks [9, 9, 9, 9, 9, 9, 9, 4]; live outside the pose on []; [])
PASS  I2 no swing starts during a swing (presses read on swing ticks [1, 2, 10, 11, 16, 17, 18])  (presses read on [1, 2, 10, 11, 16, 17, 18]; swings begun mid-swing at []; swings begun on ticks 1-17 of the repress swing: [])
PASS  I3 one slash sound per swing, on the swing's first tick  (8 sounds on ticks [311, 347, 365, 398, 451, 508, 668, 915]; 8 swings from ticks [311, 347, 365, 398, 451, 508, 668, 915])
PASS  I4 on a hit's tick during a swing: CHAR-HURT, swing over, hitbox dead, sword gone  (hit on swing tick 6; previous tick swinging: true; then pose CHAR-HURT, clock -1.0000, live false, gear 0)
PASS  I5 every tick RudyLook.frame() equals RudyLook.FRAMES[Rudy.pose]  (0 of 953 ticks wrong)
PASS  I6 CHAR-SWORD-* poses only with the sword; plain idle, run, rise and fall only without it  (638 sword-pose ticks, 294 plain-pose ticks, wrong on [])
PASS  I7 jump read on swing tick 1: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I7 jump read on swing tick 5: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I7 jump read on swing tick 12: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I8 a slash press without the sword: no swing, no sound, hitbox never live  (press read: true, gear 0, swing: false, live: false, sounds 0)
RESULT FAIL: 19 checks, 3 failed, 953 ticks
```

**The three FAILs:**

| Line | Measured | Predicted? |
|---|---|---|
| T1 | first `RUN-A` lasts 8 ticks; cells `[8, 8, 7, 8, 7, 8, 7, 7]` | Yes. The first cell is 8 (section 7) and every later cell is 7 or 8. They don't strictly alternate, though: two 8s open and two 7s close, where section 7 says "7 and 8 ticks in turn". |
| T2 | the same, `[8, 8, 7, 8, 7, 8, 7, 7]` | Yes, as T1. |
| T6 | "restarts": `SWORD-RUN-A` for 4 ticks before the swing, `SWORD-RUN-A` for 8 ticks after it | Yes, the run restarts from its first cell (section 2.1, E4). |

## `checks.tscn 60`
- Last line: `all checks passed`
- 141 PASS, 0 FAIL
- `PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (93 paths; missing: )`, so the count stays 93.

## The other earlier tests (section 5)

| Test | Result | Section 5 |
|---|---|---|
| `invulnerable_tint_checks.tscn` at 30 / 60 / 144 | 15 PASS each, `all checks passed` | 15 |
| `test_slash_sparks_config.gd` | 108 checks, `0 failure(s)` | 108 |
| `test_slash_sparks_state.tscn` | 14 PASS, `all checks passed` | 14 |
| `test_run_dust_config.gd` | 61 checks, `0 failure(s)` | 61 |
| `test_run_dust_state.tscn` | 14 PASS, `all checks passed` | 14 |

## ANOMALIES

**A1. My first wiring failed T3 and all three I7 lines; fixed.**
- **Log lines from that run:**
  - `FAIL  T3 … (slash pose 17 ticks, ends on tick 17, then CHAR-SWORD-SLASH)`
  - `FAIL  I7 jump read on swing tick 1 … then CHAR-SWORD-SLASH`, and the same on ticks 5 and 12
  - T6 also read `neither: … CHAR-SWORD-SLASH for 1 ticks after it`
- **What happened:** the trail showed the slash cell on swing tick 17 (log tick 328), one tick too long.
- **The cause was my order of calls:** `play()` and then `seek(0.0, true)`.
  - `play()` sets a "just started" flag, so the player's next update adds no time.
  - `seek(…, true)` runs an update at once and uses that flag up. The player's own update on the same tick then adds 1/60 s.
  - So the 17/60 s clip ended on tick 16 and the player stopped. On tick 17 the `play()` landed on a stopped player and showed a tick late (section 3).
- **Fix:** `rudy_look.gd` now calls `seek(0.0, true)` first and `play()` after. Every new swing still gets both calls, and T3 and I7 pass.
- **This explanation is inferred, not probed.** It comes from the trail plus how I remember Godot's AnimationPlayer working. I wrote a probe in the scratchpad, but running Godot outside the wrapper was denied.
- **A side effect:** that seek briefly applies the outgoing clip's first key, which the slash then overwrites in the same tick's update. No test reads between the two writes.
- **Not yet tested:** a restart while `slash` is itself playing. That needs E1's tick-18 check in step 5.

**A2. Other places where the run now restarts instead of resuming its phase.** These are confirmed from the old code, and no code was added to keep the old phase:
- **HURT: confirmed.** The old `_pick_pose()` returned at `Mode.HURT` before the air branch reset `_run_clock`, so the clock carried through the knockback, airborne or not. If D was held when HURT ended, the run picked up its old phase; now it restarts at `RUN-A`. No test sees it: the pin's step 8 waits out HURT, but T9 only counts HURT ticks.
- **DEFEATED, then RESPAWNING: confirmed.** Both modes returned early and `respawn_at()` never reset the clock. So a run after the respawn used to continue the phase from before the defeat; now it restarts. Only `checks.tscn` gets there, and its respawn check (`checks.gd:371`) asserts `CHAR-RESPAWN` then `CHAR-IDLE`, not the run phase. Not seen.
- **Picking up the sword mid-run: confirmed.** Only the form prefix changed and the clock went on, so `RUN-B` became `SWORD-RUN-B` mid-cell. Now `run` changes to `sword_run`, which starts at `SWORD-RUN-A`. The pin's step 4 runs into the pickup but checks no phase there, and T2 starts from a standstill. Not seen.
- **FALLEN: not a change.** FALLEN went through the air branch, which reset the clock, so the old code restarted too.
- **CELEBRATING: no visible case.** Nothing leaves celebrate in play: Enter reloads the scene with a new Rudy.

**A3. Exit-leak lines.** The pin and checks logs end with ObjectDB leak and "resources still in use" lines. Both were already in the committed baseline logs; only the leak counts moved (pin 16 → 18, checks 42 → 31). The wrapper doesn't fail on these lines, and I didn't look into the counts.

## git status
```
 M game/content/rudy/rudy.gd
 M game/content/rudy/rudy.tscn
 M game/content/rudy/rudy_look.gd
 M game/tests/test_rudy_clips.gd
 M logs/checks_60fps.log
 M logs/test_rudy_clips_60fps.log
 M logs/test_rudy_pin_60fps.log
?? sessions/prompt-5.txt
```
Godot wrote no file git can see beyond these logs. The other six logs were rewritten but show no change.

## git diff: rudy.tscn, rudy_look.gd, rudy.gd
```diff
--- a/game/content/rudy/rudy.gd
+++ b/game/content/rudy/rudy.gd
@@ -1,8 +1,9 @@
-## Rudy's controller. It moves him and picks the pose that shows his state,
-## named by the pose's asset ID in CHARACTER-SHEET.md; his Look shows that ID's
-## generated frame. The origin is at his soles.
+## Rudy's controller. It moves him and picks the clip that shows his state
+## (_pick_clip); his Look plays that clip on its AnimationPlayer, which draws
+## the pose's frame from the sheet. `pose` is the asset ID in
+## CHARACTER-SHEET.md of the pose on screen. The origin is at his soles.
@@ -58,7 +59,6 @@
-@export var run_frame_time := 0.125 ## seconds per run frame (RUN-A, then RUN-B)
@@ -76,12 +76,14 @@
-var pose: StringName = &"CHAR-IDLE"
+## The asset ID of the pose on screen, read from the cell his Look's Sprite shows.
+var pose: StringName:
+	get:
+		return _look.pose if _look else &"CHAR-IDLE"
 ...
-var _run_clock := 0.0
@@ -102,6 +104,9 @@ func _ready() -> void:
 	_slash_query.collide_with_bodies = false
+	# The player is never stopped when a state starts: it plays idle (cell 0,
+	# the Sprite's frame before the first tick) from the start.
+	_look.play_clip(&"idle")
@@ -220,9 +225,11 @@ func _physics_process(delta: float) -> void:
+	var new_swing := false
 	if in_control and gear == Gear.SWORD and not is_slashing() and Input.is_action_just_pressed(&"slash"):
 		# A fresh press, and not while a swing is under way: one sound per swing.
 		_slash_clock = 0.0
+		new_swing = true
 		Sfx.play(&"slash")
@@ -230,8 +237,8 @@
-	pose = _pick_pose(delta)
-	_look.show_pose(pose)
+	# Every new swing starts the slash clip over from its first key.
+	_look.play_clip(_pick_clip(), new_swing)
@@ -282,30 +289,32 @@
-func _pick_pose(delta: float) -> StringName:
+## The clip for his state, by today's priorities (CHANGE-BRIEF.md section 3):
+## higher in the list wins. Every name it returns is a StringName literal, so
+## the read-back test can read them all from this file's text. The run's
+## timing lives in the run clips' keys.
+func _pick_clip() -> StringName:
 	match mode:
 		Mode.CELEBRATING:
-			return &"CHAR-CELEBRATE"
+			return &"celebrate"
 		Mode.RESPAWNING:
-			return &"CHAR-RESPAWN"
+			return &"respawn"
 		Mode.DEFEATED:
-			return &"CHAR-DEFEAT"
+			return &"defeat"
 		Mode.HURT:
-			return &"CHAR-HURT"
+			return &"hurt"
 	if is_slashing():
-		return &"CHAR-SWORD-SLASH"
-	var form := "CHAR-SWORD-" if gear == Gear.SWORD else "CHAR-"
+		return &"slash"
+	var sword := gear == Gear.SWORD
 	if not is_on_floor():
-		_run_clock = 0.0
 		var falling := velocity.y >= 0.0
 		if falling and not _was_falling:
 			_falls_sideways = absf(velocity.x) > 1.0
 		_was_falling = falling
-		return StringName(form + ("FALL" if falling and _falls_sideways else "RISE"))
+		if falling and _falls_sideways:
+			return &"sword_fall" if sword else &"fall"
+		return &"sword_rise" if sword else &"rise"
 	_was_falling = false
 	if absf(velocity.x) > 1.0:
-		_run_clock += delta
-		var second_frame := fmod(_run_clock, run_frame_time * 2.0) >= run_frame_time
-		return StringName(form + ("RUN-B" if second_frame else "RUN-A"))
-	_run_clock = 0.0
-	return StringName(form + "IDLE")
+		return &"sword_run" if sword else &"run"
+	return &"sword_idle" if sword else &"idle"

--- a/game/content/rudy/rudy.tscn
+++ b/game/content/rudy/rudy.tscn
-[ext_resource type="Texture2D" path="res://content/rudy/frames/CHAR-IDLE.png" id="3_idle"]
+[ext_resource type="Texture2D" path="res://content/rudy/sheet/rudy_sheet.png" id="3_sheet"]
@@ -28,9 +28,11 @@
 [node name="Sprite" type="Sprite2D" parent="Look"]
 material = ExtResource("4_outline")
 scale = Vector2(0.5, 0.5)
-texture = ExtResource("3_idle")
+texture = ExtResource("3_sheet")
 centered = false
 offset = Vector2(-205, -370)
+hframes = 4
+vframes = 4

--- a/game/content/rudy/rudy_look.gd
+++ b/game/content/rudy/rudy_look.gd
@@ -11,6 +11,12 @@
+##
+## The Sprite draws the 16 frames from one sheet, sheet/rudy_sheet.png (4 x 4
+## cells, in frames.json's order: CELLS). Its AnimationPlayer is the only
+## writer of the Sprite's frame: this script plays the clip the controller
+## picks and never sets the Sprite's texture or frame (CHANGE-BRIEF.md
+## section 5). The pose on screen is read back from the cell the Sprite shows.
@@ -31,21 +37,39 @@
-var pose: StringName = &"CHAR-IDLE"
+## The sheet's cells, row by row: cell N shows the frame of CELLS[N]. This is
+## frames.json's order (CHANGE-BRIEF.md section 2.1).
+const CELLS: Array[StringName] = [
+	&"CHAR-IDLE", &"CHAR-RUN-A", &"CHAR-RUN-B", &"CHAR-RISE",
+	&"CHAR-FALL", &"CHAR-HURT", &"CHAR-DEFEAT", &"CHAR-RESPAWN",
+	&"CHAR-CELEBRATE", &"CHAR-SWORD-IDLE", &"CHAR-SWORD-SLASH", &"CHAR-SWORD-BLOCK",
+	&"CHAR-SWORD-RUN-A", &"CHAR-SWORD-RUN-B", &"CHAR-SWORD-RISE", &"CHAR-SWORD-FALL",
+]
+
+## The asset ID of the pose on screen: the pose of the cell the Sprite shows.
+var pose: StringName:
+	get:
+		return CELLS[_sprite.frame] if _sprite else CELLS[0]
 
 @onready var _sprite: Sprite2D = $Sprite
+@onready var _player: AnimationPlayer = $AnimationPlayer
 
-func show_pose(id: StringName) -> void:
-	if id == pose:
-		return
-	if not FRAMES.has(id):
-		push_error("Rudy has no frame for the pose %s" % id)
+## Plays `clip` if it is not the clip playing. `restart` starts it over from
+## its first key even if it is playing: every new swing does (section 3).
+## The seek comes before play(): play() marks the clip as just started, so
+## the player's update later this tick adds no time and shows the first key
+## on this tick. A seek(0.0, true) after play() would run that update at once,
+## using the mark up, and the tick's own update would then add a tick: the
+## slash would end, and the player stop, a tick early.
+func play_clip(clip: StringName, restart := false) -> void:
+	if not restart and StringName(_player.current_animation) == clip:
 		return
-	pose = id
-	_sprite.texture = FRAMES[id]
+	if restart:
+		_player.seek(0.0, true)
+	_player.play(clip)
 
-## The frame on screen now.
+## The frame on screen now: the original PNG of the pose the Sprite shows.
 func frame() -> Texture2D:
-	return _sprite.texture
+	return FRAMES[pose]
```

## What still needs a human to play
Headless runs draw nothing, so all of this needs a window:
- **The sheet on screen.** Check every pose for registration: his soles stay on the walk line and the two run cells don't jump against each other. Check that the outline is whole, and that at half scale with mipmaps no edge of a neighbouring cell bleeds in.
- **The run.** The first cell now holds 8 ticks. The run restarts after a slash, after a hurt, after a respawn, and when he picks up the sword mid-run (A2). Whether each of those reads well is your call before T1, T2 and T6 are re-pinned.
- **No flicker on any state change,** including the swing start, where the outgoing clip is seeked for one update (A1).
- **The Remote tab** on `Look/AnimationPlayer`, to watch the clip follow his state.
- **The slash** is still the one-cell stand-in until steps 3 and 4, so there's nothing to judge in its motion yet.