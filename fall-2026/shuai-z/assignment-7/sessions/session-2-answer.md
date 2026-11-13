I added the pin test as two new files: `game/tests/test_rudy_pin.tscn` and `game/tests/test_rudy_pin.gd`. All three pin runs and the earlier checks passed, with exit code 0 each time. No other file in the repository changed except the wrapper's logs: `logs/checks_60fps.log` was overwritten and `logs/test_rudy_pin_60fps.log` is new. Godot didn't create a `.uid` file for the new script. Nothing is staged or committed. `sessions/prompt-2.txt` was already untracked before I started.

## What I built

**The scene** has a floor 20000 px wide with its top at y 0, the sword pickup at x −500, spikes at x 2500 and Rudy at the origin. There is no `Main`. The pickup and spikes come before Rudy in the tree, as in `main.tscn`.

**Two departures from section 5 of my answer:**
- **The recorder is the root node**, not a separate `Recorder` child. A separate node would need its own script, which would be a third file. The root has `process_physics_priority = 100`, so it still records after Rudy on every tick.
- **It calls `is_on_floor()`.** That is a method Rudy inherits from `CharacterBody2D`. It only reads state and changes nothing, and section 5 asks for it to be recorded. The test calls no other method on Rudy or `RudyLook`:
  - it reads `_slash_clock` directly instead of calling `is_slashing()`;
  - it checks I5 by reading the Sprite's texture against `RudyLook.FRAMES` instead of calling `frame()`.

**Input:** only `InputEventKey` events for D, A, Space and J, sent through `Input.parse_input_event`. The test steps one frame at a time with `await get_tree().process_frame`.
- The recorder also logs `Input.is_action_just_pressed` on every tick. That proves each scripted press was read on the tick the test meant.
- E1 needs presses on ticks 1, 2, 10, 11, 16, 17 and 18. A press read one tick after another one is sent as a J release followed by a J press in the same frame. The recorder confirmed all seven were read.

**Constants:** the measured numbers are in `T1`–`T9` constants, each with the comment "measured on baseline 2026-11-12". The output prints the per-tick trail first, then `== TIMING ==`, `== INVARIANT ==` and a `RESULT` line. The test calls `quit(1)` on any failure. A bounded wait that times out also counts as a failure.

**Measured values (TIMING):**

| | Value |
|---|---|
| T1 / T2 run cells, first 60 run ticks | `[7, 8, 7, 8, 7, 7, 8, 7, 1]`, starting on A (the final 1 is where the 60-tick window cuts off) |
| T3 slash pose / end of swing | ticks 0–16 / tick 17, then `CHAR-SWORD-IDLE` |
| T4 hitbox live | ticks 2–10 |
| T5 | a press on tick 17 is ignored; a press on tick 18 starts a new swing |
| T6 run after a slash | resumes: A for 5 ticks before the swing, A for 2 ticks after it |
| T7 stop | `CHAR-IDLE` 5 ticks after the tick the release is read |
| T8 turn on the ground | starts moving 7 ticks after the press |
| T9 HURT | 21 ticks |

## Run output

Each run prints about 950 trail lines, one per physics tick. Below, the trail is cut down to its header and the `marks` line; the full trail is in `logs/test_rudy_pin_60fps.log`. I diffed the full output of run 1 against runs 2 and 3. The only line that differs is the ObjectDB leak count: 14, 18 and 18.

**Pin, run 1** (exit 0)
```
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

== TRAIL (one line per physics tick, sampled after Rudy) ==
tick    0 PLAY    CHAR-IDLE          v(    0.0,    0.0) floor 1 clock -1.0000 live 0 facing  1 gear 0 x     0.0 jp -- snd 0
[… ticks 1–952 elided …]
marks { &"run_plain": 16, &"release_plain": 76, &"jump_plain": 92, &"slash_no_sword": 139, &"turn_left": 165, &"turn_right": 295, &"slash_single": 311, &"slash_repress": 347, "slash_jump_1": 398, "slash_jump_5": 451, "slash_jump_12": 508, &"run_sword": 572, &"run_slash_run": 648, &"run_slash": 668, &"run_slash_release": 728, &"spike_slash": 915, &"hit": 921 }
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
PASS  I5 every tick the Sprite shows FRAMES[pose] and Look.pose equals Rudy.pose  (0 of 953 ticks wrong)
PASS  I6 CHAR-SWORD-* poses only with the sword; plain idle, run, rise and fall only without it  (638 sword-pose ticks, 294 plain-pose ticks, wrong on [])
PASS  I7 jump read on swing tick 1: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I7 jump read on swing tick 5: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I7 jump read on swing tick 12: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I8 a slash press without the sword: no swing, no sound, hitbox never live  (press read: true, gear 0, swing: false, live: false, sounds 0)
RESULT PASS: 19 checks, 0 failed, 953 ticks
WARNING: 14 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
ERROR: 4 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:822)
```

**Pin, run 2** (exit 0): the same as run 1 except one line, `WARNING: 18 ObjectDB instances were leaked at exit (run with `--verbose` for details).` It ends `RESULT PASS: 19 checks, 0 failed, 953 ticks`.

**Pin, run 3** (exit 0): the same as run 2, including the 18-instance leak line. It ends `RESULT PASS: 19 checks, 0 failed, 953 ticks`.

**`scripts/run-test.sh checks.tscn 60`** (exit 0; 141 PASS lines, 0 FAIL, the same count as before)
```
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

PASS  main.tscn has its nodes
PASS  rudy.tscn has its nodes
[… 137 more PASS lines …]
PASS  the game opens with the debug line hidden
PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (90 paths; missing: )
all checks passed
WARNING: 39 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
ERROR: 8 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:822)
```
The full output is in `logs/checks_60fps.log`.

## ANOMALIES

These are kept as measured and not fixed.

1. **Today's run cells don't strictly alternate.** The cells measured `7, 8, 7, 8, 7, 7, 8, 7`: cells 5 and 6 are both 7 ticks. This is probably rounding in the run clock's `fmod`. The brief (section 2.1) says the new clip "alternates 8 and 7 ticks, much as today's clock does", which isn't quite true of today's clock. My answer only predicted that the first A lasts 7 ticks, and that held. Expect T1 and T2 to fail on the whole pattern at step 2b, not just on the first cell.
2. **The leak counts at exit vary between runs** (14, 18, 18) on identical tick trails. Every earlier test's log has the same kind of `ObjectDB … leaked` and `resources still in use` lines, and the wrapper doesn't fail on them. I'm reporting it only because the number isn't deterministic.

Everything else matched the code, the brief and my answer: the 17-tick swing, live ticks 2–10, the run resuming after a slash, and 21 HURT ticks. T7 (5 ticks) and T8 (7 ticks) also match: counting the press tick itself, they come to 0.1 s and 0.133 s, and `checks.gd` measured the same 0.133 s.

## What still needs a human

- **Read the trail once.** Check that the scenario ran the way you meant, using the `marks` line and the trail around each mark. The checks prove the presses were read on the intended ticks, but not that the scenario is the one you want pinned.
- **Play today's game as a baseline for feel.** This run draws nothing headless, so it can't show how today's run cadence, the instant cuts, or the run resuming after a slash look and feel. Play them now, before step 2b, so you have something to compare against when you judge the change and re-pin T1, T2 and T6.
- **States the pin leaves out:** the title, falling out, defeat, respawn and celebrate. As your review decided, only `checks.tscn` covers them. The pin also doesn't test ledges, running off an edge, or behaviour at 30 fps.

Nothing is committed.
