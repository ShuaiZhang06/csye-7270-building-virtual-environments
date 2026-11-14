I added I9 and it passes. Both pin runs gave **20 checks, 3 failed**: only T1, T2 and T6, as you expected. Nothing is committed.

## The change

- **`game/tests/test_rudy_pin.gd`**:
  - **Header:** one new paragraph saying I9 was added on 2026-11-13, after the change (Revision 5, "The pin's state order"), and that nothing else in the file changed.
  - **`POSE_STATES`:** your fixed table of 12 poses. A pose not in the table gets the state `?<pose>`, which can never match, and I9 fails and names the first five ticks where that happened.
  - **`STATE_ORDER`:** the 33 states. Its comment says they come from `git show 3908ae80:./logs/test_rudy_pin_60fps.log`, mapped by the table, and that the line was added after the change.
  - **The I9 check:** it reads `Rudy.pose` from the samples the test already takes (`_samples[i].pose`) and joins consecutive ticks of the same state into one entry. On a mismatch it prints the first index where the two sequences part, the tick on which the measured state there begins, and the states from three before that index to three after, from both sequences.
  - Every other check, constant and expected value is unchanged.
- **`CLAUDE.md`**: only the pin's command line changed, to `# pin: 20 checks, T1, T2, T6 FAIL as asked (logs/test_rudy_pin_60fps.log:959-980)`.

## Pin, run 1 (exit 1)
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
PASS  I9 the states of the scripted run, consecutive ticks collapsed, are the 33 of the baseline log, in order  (33 states, the same as the baseline's)
RESULT FAIL: 20 checks, 3 failed, 953 ticks
WARNING: 15 ObjectDB instances were leaked at exit
```

## Pin, run 2
Every TIMING and INVARIANT line is identical to run 1; only the leak count differs:
```
PASS  I9 the states of the scripted run, consecutive ticks collapsed, are the 33 of the baseline log, in order  (33 states, the same as the baseline's)
RESULT FAIL: 20 checks, 3 failed, 953 ticks
WARNING: 14 ObjectDB instances were leaked at exit (run with `--verbose` for details).
```

`git diff -U0 logs/test_rudy_pin_60fps.log` shows only the three lines you expected:
```
-RESULT FAIL: 19 checks, 3 failed, 953 ticks
-WARNING: 16 ObjectDB instances were leaked at exit (run with `--verbose` for details).
+PASS  I9 the states of the scripted run, consecutive ticks collapsed, are the 33 of the baseline log, in order  (33 states, the same as the baseline's)
+RESULT FAIL: 20 checks, 3 failed, 953 ticks
+WARNING: 14 ObjectDB instances were leaked at exit (run with `--verbose` for details).
```

## checks.tscn 60
```
PASS  the game opens with the debug line hidden
PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (98 paths; missing: )
all checks passed
WARNING: 34 ObjectDB instances were leaked at exit (run with `--verbose` for details).
```
That is 141 PASS, 0 FAIL, and the res:// path count is still 98. Its log differs from the committed one in one line, the camera-shake offset: `(1.939641, 1.497191)` became `(-1.812971, 5.494018)`. That check passed both times.

## git status
```
 M CLAUDE.md
 M game/tests/test_rudy_pin.gd
 M logs/checks_60fps.log
 M logs/test_rudy_pin_60fps.log
?? sessions/prompt-15.txt
```

## The constant beside the baseline's start ticks (from 3908ae80's trail)

| # | State | Tick | # | State | Tick | # | State | Tick |
|---|---|---|---|---|---|---|---|---|
| 0 | idle | 0 | 11 | sword_idle | 364 | 22 | sword_idle | 561 |
| 1 | run | 16 | 12 | slash | 365 | 23 | sword_run | 572 |
| 2 | idle | 81 | 13 | sword_idle | 382 | 24 | sword_idle | 637 |
| 3 | rise | 92 | 14 | slash | 398 | 25 | sword_run | 648 |
| 4 | idle | 133 | 15 | sword_rise | 415 | 26 | slash | 668 |
| 5 | run | 172 | 16 | sword_idle | 440 | 27 | sword_run | 685 |
| 6 | sword_run | 283 | 17 | slash | 451 | 28 | sword_idle | 733 |
| 7 | sword_idle | 289 | 18 | sword_rise | 468 | 29 | sword_run | 744 |
| 8 | slash | 311 | 19 | sword_idle | 497 | 30 | slash | 915 |
| 9 | sword_idle | 328 | 20 | slash | 508 | 31 | hurt | 921 |
| 10 | slash | 347 | 21 | sword_rise | 525 | 32 | idle | 942 |

Three things to know about the sequence:
- **No `fall` state.** The scripted run never shows `fall` or `sword_fall`, because each jump goes straight up and lands from the rising pose. So I9 pins the order, not that every state is reached.
- **The one-tick `sword_idle` at 364** is the gap between the swing at 347 and the swing re-pressed on tick 18 (365).
- **Why I9 can still pass on 3908ae80.** On the current code the runs restart their cells, but all of a run's ticks collapse to one `run` or `sword_run` entry, so the cell timing can't change the sequence.

I didn't run anything on 3908ae80, as you asked. I wrote the table by hand from the baseline trail: the permission mode refused my awk and Python one-liners, so I read the trail's pose column with Grep and listed each change.