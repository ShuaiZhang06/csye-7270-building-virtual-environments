T1, T2 and T6 are re-pinned and the pin now passes all 20 checks, on both runs. I committed nothing.

Before editing, I ran the pin once to read the current values. They are the ones you expected: `[8, 8, 7, 8, 7, 8, 7, 7]` for both cell lists, and `"restarts"`.

## The changes

**`game/tests/test_rudy_pin.gd`**
- The three constants now hold those values.
- Each comment keeps "Measured on baseline 2026-11-12" with the old value, and adds a "Re-pinned 2026-11-16" line with the brief references and the fact that you looked at the run in the game.
- T1's sentence about the cell cut off by the 60-tick window is kept.
- The header (lines 27-29) and the TIMING heading (line 43) now say that T1, T2 and T6 were re-pinned. A dated entry for this step follows the I9 one (lines 36-41).
- No check's code, other constant or driving changed.

**`CLAUDE.md`, two lines**
- Line 38, the pin's command: `# pin: 20 PASS, T1, T2, T6 re-pinned (logs/test_rudy_pin_60fps.log:959-980)`. The log line range is unchanged.
- Line 50 now says the three were re-pinned on 2026-11-16, after you looked at the run, and why, citing brief section 7, section 2.1 "Restart" and Revision 4. It points to the constants at `game/tests/test_rudy_pin.gd:43-72`.

## `scripts/run-test.sh test_rudy_pin.tscn 60`, run 1

```
== TIMING ==
PASS  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [8, 8, 7, 8, 7, 8, 7, 7]  (moves on press tick: true, first CHAR-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
PASS  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [8, 8, 7, 8, 7, 8, 7, 7]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
PASS  T3 slash pose on ticks 0-16, swing ends on tick 17 with CHAR-SWORD-IDLE  (slash pose 17 ticks, ends on tick 17, then CHAR-SWORD-IDLE)
PASS  T4 hitbox live on ticks 2-10  (live on ticks 2-10 (9 ticks))
PASS  T5 a press read on swing tick 17 is ignored; one on tick 18 starts a swing  (presses read: true, tick 17 starts a swing: false, tick 18 starts a swing: true)
PASS  T6 the run restarts after a slash  (restarts: CHAR-SWORD-RUN-A for 4 ticks before the swing, CHAR-SWORD-RUN-A for 8 ticks after it)
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
RESULT PASS: 20 checks, 0 failed, 953 ticks
```

## Run 2

Run 2 printed the same lines, ending `RESULT PASS: 20 checks, 0 failed, 953 ticks`.

## `git diff logs/test_rudy_pin_60fps.log`

Only the T1, T2, T6 and RESULT lines changed, plus the leak count, as expected:

```
-FAIL  T1 ... cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (... cells [8, 8, 7, 8, 7, 8, 7, 7])
+PASS  T1 ... cells [8, 8, 7, 8, 7, 8, 7, 7]  (... cells [8, 8, 7, 8, 7, 8, 7, 7])
-FAIL  T2 ... (same pattern)
+PASS  T2 ...
-FAIL  T6 the run resumes after a slash  (restarts: ...)
+PASS  T6 the run restarts after a slash  (restarts: ...)
-RESULT FAIL: 20 checks, 3 failed, 953 ticks
-WARNING: 14 ObjectDB instances were leaked at exit ...
+RESULT PASS: 20 checks, 0 failed, 953 ticks
+WARNING: 18 ObjectDB instances were leaked at exit ...
```

## `scripts/run-test.sh checks.tscn 60`

```
PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (98 paths; missing: )
all checks passed
WARNING: 34 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
ERROR: 8 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:822)
```

- The `res://` path count is still 98.
- There are 141 PASS lines and 0 FAIL in `logs/checks_60fps.log`.
- One line of that log changed: line 59, the camera-shake offset in the hurt check, `(1.939641, 1.497191)` → `(-2.926532, 1.451911)`. It still passes; my guess is that the shake is random, but I haven't checked that.

## `git status`

```
modified:   CLAUDE.md
modified:   game/tests/test_rudy_pin.gd
modified:   logs/checks_60fps.log
modified:   logs/test_rudy_pin_60fps.log
untracked:  sessions/prompt-16.txt
```

The full `git diff game/tests/test_rudy_pin.gd` is in the tool output above. It contains only the comment lines and the three constants described under "The changes".

## Against the brief's predictions

- **T1 and T2: predicted.** `CHANGE-BRIEF.md:321`, section 7: "8 ticks after the run starts: the key at 0.125 s is reached at 8/60 s." The first cell now lasts 8 ticks, where the baseline showed 7. That line also says "Today's code shows 7 ticks of `RUN-A` first", which the baseline value confirms.
  - **A wording mismatch, not a behaviour finding.** The same line goes on to say "Cells then last 7 and 8 ticks in turn". Read literally, that means 8, 7, 8, 7. The measured cells are 8, **8**, 7, 8, 7, 8, 7, 7: every RUN-B cell lasts 8 ticks and every RUN-A after the first lasts 7.
  - The brief's own cited probe, `evidence/brief-probe/logs/anim_run_discrete_60fps.log:8-31`, shows the same 8, 8, 7, 8. RUN-B keeps the tick on which the clip reaches 0.25 s, before it wraps to RUN-A (`:23`, then `:24`).
  - `CHANGE-BRIEF.md:121` ("cells alternate 8 and 7 ticks") fits the measurement. So the behaviour matches the probe the brief cites; only the order in that sentence on line 321 is loose. I changed neither the brief nor the expected value.
  - The window cut moved: the baseline ended with a cut-off cell of 1 tick, and now the last entry is the 7-tick RUN-B. That cell goes on to tick 76 in the trail (`logs/test_rudy_pin_60fps.log:80`), so T1's comment about the cut-off cell still holds.
- **T6: predicted.** `CHANGE-BRIEF.md:122`, section 2.1 "Restart": "The new clip restarts from A after a slash too … the re-pin records the restart." Also `:304` (E4: "`sword_run` restarts at `SWORD-RUN-A`") and `:428` (section 10, row 14). The measured value is "restarts", with SWORD-RUN-A shown for 8 ticks after the swing.
