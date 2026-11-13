I've changed I5 as you asked, and all three runs pass: 19 checks, 0 failed, exit 0 each time.

I5 now checks, on every tick, that `RudyLook.frame()` equals `RudyLook.FRAMES[Rudy.pose]`. It no longer reads the Sprite's texture or `RudyLook.pose`.

The whole output of run 3 is the same as run 3 before the change except for two lines: I5's label, and the exit leak count (14, now 16). The leak count varies from run to run anyway. The trail is identical, and the `== TIMING ==`, `== INVARIANT ==` and `RESULT` lines are identical in all three runs.

## Two edits beyond the I5 check

Both exist only because of the I5 change, but I'm naming them because you said to change nothing else:
1. **The header comment.** It said the test calls only `is_on_floor()`. It now also names `RudyLook.frame()` as a read-only query, so the comment doesn't contradict the code.
2. **The trail's mismatch marker.** It read the two fields I removed, so it now reads the new `frame_ok` field and prints `FRAME-MISMATCH` instead of `LOOK-MISMATCH`. It never printed on this baseline.

I also removed the `_sprite` variable, which only the texture comparison used.

## Diff of `game/tests/test_rudy_pin.gd`

The file is untracked, so `git diff` shows nothing. This is the diff of my edits against the version from the last turn; I wrote the hunk headers myself, without line numbers.

```diff
--- a/game/tests/test_rudy_pin.gd   (previous turn)
+++ b/game/tests/test_rudy_pin.gd   (now)
@@ header comment @@
 ## - Rudy is driven only by InputEventKey events for the project's physical
 ##   keys D, A, Space and J, sent with Input.parse_input_event. It never calls
 ##   Rudy's or RudyLook's methods to drive him and never writes his velocity,
-##   position or state. It reads his properties, and is_on_floor(), a query
-##   with no side effects that section 5 asks to record.
+##   position or state. It reads his properties, and calls two read-only
+##   queries that change nothing: is_on_floor(), which section 5 asks to
+##   record, and RudyLook.frame(), for I5.
@@ node references @@
 @onready var _rudy: Rudy = $World/Rudy
 @onready var _look: RudyLook = $World/Rudy/Look
-@onready var _sprite: Sprite2D = $World/Rudy/Look/Sprite
 @onready var _box: CollisionShape2D = $World/Rudy/SwordHitbox/Shape
@@ func _physics_process (the recorder) @@
 		"x": _rudy.global_position.x,
-		"look_pose": _look.pose,
-		"tex_ok": RudyLook.FRAMES.has(pose) and _sprite.texture == RudyLook.FRAMES[pose],
+		"frame_ok": RudyLook.FRAMES.has(pose) and _look.frame() == RudyLook.FRAMES[pose],
 		"jp_slash": Input.is_action_just_pressed(&"slash"),
@@ func _print_trail @@
 			"J" if s.jp_slash else "-", "S" if s.jp_jump else "-", s.n_slash,
-			"" if s.tex_ok and s.look_pose == s.pose else "  LOOK-MISMATCH"])
+			"" if s.frame_ok else "  FRAME-MISMATCH"])
@@ func _check_all, I5 @@
-	# I5: every pose shows its own frame.
+	# I5: every pose shows its own frame (the look contract, brief section 3).
 	var mismatch: Array[int] = []
 	for x in _samples:
-		if not x.tex_ok or x.look_pose != x.pose:
+		if not x.frame_ok:
 			mismatch.append(x.t)
 	_check(_invariant, "I5", mismatch.is_empty(),
-		"every tick the Sprite shows FRAMES[pose] and Look.pose equals Rudy.pose",
+		"every tick RudyLook.frame() equals RudyLook.FRAMES[Rudy.pose]",
 		"%d of %d ticks wrong%s" % [mismatch.size(), _samples.size(), "" if mismatch.is_empty() else ", first %d" % mismatch[0]])
```

## Run 1 (exit 0)
```
== TIMING ==
PASS  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-RUN-A, cells [7, 8, 7, 8, 7, 7, 8, 7, 1])
PASS  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [7, 8, 7, 8, 7, 7, 8, 7, 1])
PASS  T3 slash pose on ticks 0-16, swing ends on tick 17 with CHAR-SWORD-IDLE  (slash pose 17 ticks, ends on tick 17, then CHAR-SWORD-IDLE)
PASS  T4 hitbox live on ticks 2-10  (live on ticks 2-10 (9 ticks))
PASS  T5 a press read on swing tick 17 is ignored; one on tick 18 starts a swing  (presses read: true, tick 17 starts a swing: false, tick 18 starts a swing: true)
PASS  T6 the run resumes after a slash  (resumes: CHAR-SWORD-RUN-A for 5 ticks before the swing, CHAR-SWORD-RUN-A for 2 ticks after it)
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
RESULT PASS: 19 checks, 0 failed, 953 ticks
```

## Run 2 (exit 0)
```
== TIMING ==
PASS  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-RUN-A, cells [7, 8, 7, 8, 7, 7, 8, 7, 1])
PASS  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [7, 8, 7, 8, 7, 7, 8, 7, 1])
PASS  T3 slash pose on ticks 0-16, swing ends on tick 17 with CHAR-SWORD-IDLE  (slash pose 17 ticks, ends on tick 17, then CHAR-SWORD-IDLE)
PASS  T4 hitbox live on ticks 2-10  (live on ticks 2-10 (9 ticks))
PASS  T5 a press read on swing tick 17 is ignored; one on tick 18 starts a swing  (presses read: true, tick 17 starts a swing: false, tick 18 starts a swing: true)
PASS  T6 the run resumes after a slash  (resumes: CHAR-SWORD-RUN-A for 5 ticks before the swing, CHAR-SWORD-RUN-A for 2 ticks after it)
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
RESULT PASS: 19 checks, 0 failed, 953 ticks
```

## Run 3 (exit 0)
```
== TIMING ==
PASS  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-RUN-A, cells [7, 8, 7, 8, 7, 7, 8, 7, 1])
PASS  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [7, 8, 7, 8, 7, 7, 8, 7, 1])
PASS  T3 slash pose on ticks 0-16, swing ends on tick 17 with CHAR-SWORD-IDLE  (slash pose 17 ticks, ends on tick 17, then CHAR-SWORD-IDLE)
PASS  T4 hitbox live on ticks 2-10  (live on ticks 2-10 (9 ticks))
PASS  T5 a press read on swing tick 17 is ignored; one on tick 18 starts a swing  (presses read: true, tick 17 starts a swing: false, tick 18 starts a swing: true)
PASS  T6 the run resumes after a slash  (resumes: CHAR-SWORD-RUN-A for 5 ticks before the swing, CHAR-SWORD-RUN-A for 2 ticks after it)
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
RESULT PASS: 19 checks, 0 failed, 953 ticks
```

Each run also ended with the usual exit lines, which the wrapper doesn't fail on. The ObjectDB leak counts were 17, 18 and 16, followed by `ERROR: 4 resources still in use at exit`.

No other file changed apart from the wrapper's log `logs/test_rudy_pin_60fps.log`. Nothing is committed.
