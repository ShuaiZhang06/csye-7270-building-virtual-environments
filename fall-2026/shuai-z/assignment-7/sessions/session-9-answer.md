I wrote the state test (`game/tests/test_rudy_states.tscn` and `.gd`). It passes 81 of 81 checks, and two runs gave identical STATES and RESULT lines. No other file changed apart from the wrapper's logs. Godot did not write a `.uid` for the script: after five runs there is no `test_rudy_states.gd.uid`.

The test follows your rules:
- Each scenario starts a fresh real Main with the title skipped, as `_start_level()` does.
- Setup may only move Rudy to a spot and let him settle for 20 ticks.
- Input is `InputEventKey` events for D, A, Space and J through `Input.parse_input_event`.
- The test reads only properties, `is_on_floor()` and the AnimationPlayer's `current_animation` and `current_animation_position`.
- The recorder is the scene's root node with `process_physics_priority = 100`, so it samples after Rudy and his AnimationPlayer.

Each log line has the fields you listed. I added three things: the scenario and its tick ("st", where 0 is the tick the first input is read), Rudy's x position, and the keys read that tick.

## `scripts/run-test.sh test_rudy_states.tscn 60`, run 1

```
== STATES ==
PASS  every scripted wait was met
PASS  clip idle plays from 0 on the tick its state is entered, showing CHAR-IDLE, Sprite shown, SlashRig hidden  (first on S1 t35 (tick 55) from run: slowed to a stop: vx 93.3>0.0; 15 entries; wrong: [])
PASS  clip run plays from 0 on the tick its state is entered, showing CHAR-RUN-A, Sprite shown, SlashRig hidden  (first on S1 t0 (tick 20) from idle: a direction held: vx 93.3; 15 entries; wrong: [])
PASS  clip rise plays from 0 on the tick its state is entered, showing CHAR-RISE, Sprite shown, SlashRig hidden  (first on S1 t55 (tick 75) from idle: a jump press read on the floor: vy -1500; 6 entries; wrong: [])
PASS  clip fall plays from 0 on the tick its state is entered, showing CHAR-FALL, Sprite shown, SlashRig hidden  (first on S1 t155 (tick 175) from rise: at the top, moving sideways: vy -33.3>33.3, vx -560.0; 4 entries; wrong: [])
PASS  clip sword_idle plays from 0 on the tick its state is entered, showing CHAR-SWORD-IDLE, Sprite shown, SlashRig hidden  (first on S5 t76 (tick 1332) from sword_run: slowed to a stop: vx 93.3>0.0; 9 entries; wrong: [])
PASS  clip sword_run plays from 0 on the tick its state is entered, showing CHAR-SWORD-RUN-A, Sprite shown, SlashRig hidden  (first on S5 t8 (tick 1264) from run: walked into the pickup; 8 entries; wrong: [])
PASS  clip sword_rise plays from 0 on the tick its state is entered, showing CHAR-SWORD-RISE, Sprite shown, SlashRig hidden  (first on S5 t19 (tick 1275) from sword_run: a jump press read on the floor: vy -1500; 7 entries; wrong: [])
PASS  clip sword_fall plays from 0 on the tick its state is entered, showing CHAR-SWORD-FALL, Sprite shown, SlashRig hidden  (first on S5 t46 (tick 1302) from slash: the swing ends on swing tick 17; 5 entries; wrong: [])
PASS  clip slash plays from 0 on the tick its state is entered, showing CHAR-SWORD-SLASH, Sprite hidden, SlashRig shown  (first on S5 t29 (tick 1285) from sword_rise: a slash press read, the swing begins; 8 entries; wrong: [])
PASS  clip hurt plays from 0 on the tick its state is entered, showing CHAR-HURT, Sprite shown, SlashRig hidden  (first on S2 t80 (tick 462) from run: a hit: hearts 3>2, gear 0>0; 3 entries; wrong: [])
PASS  clip defeat plays from 0 on the tick its state is entered, showing CHAR-DEFEAT, Sprite shown, SlashRig hidden  (first on S2 t356 (tick 738) from run: a hit took his last heart: hearts 1>0; 1 entries; wrong: [])
PASS  clip respawn plays from 0 on the tick its state is entered, showing CHAR-RESPAWN, Sprite shown, SlashRig hidden  (first on S2 t424 (tick 806) from defeat: Main respawned him from DEFEATED; 4 entries; wrong: [])
PASS  clip celebrate plays from 0 on the tick its state is entered, showing CHAR-CELEBRATE, Sprite shown, SlashRig hidden  (first on S8 t15 (tick 2776) from run: on the teleport circle; 1 entries; wrong: [])
PASS  run shows CHAR-RUN-A for its first 8 ticks, then CHAR-RUN-B  (S1 t0: 35 ticks, first cell 8; S1 t119: 13 ticks, first cell 8; S1 t173: 13 ticks, first cell 8; S1 t193: 18 ticks, first cell 8; S1 t267: 11 ticks, first cell 8; S2 t0: 80 ticks, first cell 8; S2 t345: 11 ticks, first cell 8; S2 t466: 20 ticks, first cell 8; S3 t0: 19 ticks, first cell 8; S3 t121: 20 ticks, first cell 8; S5 t0: 8 ticks, first cell 8; S6 t0: 8 ticks, first cell 8; S7 t0: 8 ticks, first cell 8; S7 t308: 13 ticks, first cell 8; S8 t0: 15 ticks, first cell 8)
PASS  sword_run shows CHAR-SWORD-RUN-A for its first 8 ticks, then CHAR-SWORD-RUN-B  (S5 t8: 11 ticks, first cell 8; S5 t60: 16 ticks, first cell 8; S5 t98: 12 ticks, first cell 8; S5 t127: 14 ticks, first cell 8; S5 t409: 11 ticks, first cell 8; S6 t8: 58 ticks, first cell 8; S7 t8: 57 ticks, first cell 8; S7 t106: 100 ticks, first cell 8)
PASS  transition idle -> run (in the table): a direction held: vx 93.3  (13 times, on S1 t0, S1 t119, S1 t193, S2 t0, S2 t345, S2 t466, S3 t0, S3 t121, S5 t0, S6 t0, S7 t0, S7 t308, S8 t0)
PASS  transition run -> idle (in the table): slowed to a stop: vx 93.3>0.0  (6 times, on S1 t35, S1 t186, S1 t211, S2 t486, S3 t141, S7 t321)
PASS  transition idle -> rise (in the table): a jump press read on the floor: vy -1500  (4 times, on S1 t55, S1 t226, S2 t192, S4 t0)
PASS  transition rise -> idle (in the table): lands: vx 0.0  (1 times, on S1 t96)
PASS  transition run -> rise (in the table): a jump press read on the floor: vy -1500  (2 times, on S1 t132, S1 t278)
PASS  transition rise -> fall (in the table): at the top, moving sideways: vy -33.3>33.3, vx -560.0  (3 times, on S1 t155, S1 t301, S2 t215)
PASS  transition fall -> run (in the table): lands: vx -560.0  (1 times, on S1 t173)
PASS  transition rise -> run (in the table): lands: vx 560.0  (1 times, on S1 t267)
PASS  transition fall -> idle (in the table): lands: vx 0.0  (1 times, on S1 t319)
PASS  transition run -> hurt (in the table): a hit: hearts 3>2, gear 0>0  (1 times, on S2 t80)
PASS  transition hurt -> idle (in the table): hurt_time ends: mode HURT>PLAY  (3 times, on S2 t101, S2 t254, S6 t595)
PASS  transition fall -> hurt (in the table): a hit: hearts 2>1, gear 0>0  (1 times, on S2 t233)
PASS  transition run -> defeat (in the table): a hit took his last heart: hearts 1>0  (1 times, on S2 t356)
PASS  transition defeat -> respawn (in the table): Main respawned him from DEFEATED  (1 times, on S2 t424)
PASS  transition respawn -> idle (in the table): respawn_time ends  (4 times, on S2 t465, S3 t120, S4 t130, S7 t307)
PASS  transition run -> fall (in the table): ran off a ledge: vx 560.0  (1 times, on S3 t19)
PASS  transition fall -> respawn (in the table): Main respawned him from FALLEN  (1 times, on S3 t79)
PASS  transition rise -> respawn (in the table): Main respawned him from FALLEN  (1 times, on S4 t89)
PASS  transition run -> sword_run (NOT in the table, measured: see ANOMALIES): walked into the pickup  (3 times, on S5 t8, S6 t8, S7 t8)
PASS  transition sword_run -> sword_rise (in the table): a jump press read on the floor: vy -1500  (3 times, on S5 t19, S5 t420, S7 t65)
PASS  transition sword_rise -> slash (in the table): a slash press read, the swing begins  (2 times, on S5 t29, S5 t326)
PASS  transition slash -> sword_fall (in the table): the swing ends on swing tick 17  (2 times, on S5 t46, S7 t230)
PASS  transition sword_fall -> sword_run (in the table): lands: vx 560.0  (2 times, on S5 t60, S7 t106)
PASS  transition sword_run -> sword_idle (in the table): slowed to a stop: vx 93.3>0.0  (3 times, on S5 t76, S5 t141, S6 t66)
PASS  transition sword_idle -> sword_run (in the table): a direction held: vx -93.3  (1 times, on S5 t98)
PASS  transition sword_run -> slash (in the table): a slash press read, the swing begins  (1 times, on S5 t110)
PASS  transition slash -> sword_run (in the table): the swing ends on swing tick 17  (1 times, on S5 t127)
PASS  transition sword_idle -> slash (in the table): a slash press read, the swing begins  (4 times, on S5 t156, S5 t239, S6 t544, S6 t562)
PASS  transition slash -> sword_idle (in the table): the swing ends on swing tick 17  (3 times, on S5 t173, S5 t343, S6 t561)
PASS  transition sword_idle -> sword_rise (in the table): a jump press read on the floor: vy -1500  (3 times, on S5 t187, S5 t301, S5 t368)
PASS  transition sword_rise -> sword_idle (in the table): lands: vx 0.0  (2 times, on S5 t228, S5 t285)
PASS  transition slash -> sword_rise (in the table): the swing ends on swing tick 17  (1 times, on S5 t256)
PASS  transition sword_rise -> sword_run (in the table): lands: vx -560.0  (1 times, on S5 t409)
PASS  transition sword_rise -> sword_fall (in the table): at the top, moving sideways: vy -33.3>33.3, vx -560.0  (2 times, on S5 t443, S7 t88)
PASS  transition sword_fall -> sword_idle (in the table): lands: vx 0.0  (1 times, on S5 t461)
PASS  transition slash -> hurt (in the table): a hit: hearts 3>3, gear 1>0  (1 times, on S6 t574)
PASS  transition sword_run -> sword_fall (in the table): ran off a ledge: vx 560.0  (1 times, on S7 t206)
PASS  transition sword_fall -> slash (in the table): a slash press read, the swing begins  (1 times, on S7 t215)
PASS  transition sword_fall -> respawn (in the table): Main respawned him from FALLEN  (1 times, on S7 t266)
PASS  transition run -> celebrate (in the table): on the teleport circle  (1 times, on S8 t15)
PASS  swing on S5 t29 (tick 1285): clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-16; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S5 t29: SlashRig shows and the Sprite hides on ticks 0-16, the Sprite shows again on tick 17  (wrong: [])
PASS  swing on S5 t29: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then sword_fall)
PASS  swing on S5 t110 (tick 1366): clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-16; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S5 t110: SlashRig shows and the Sprite hides on ticks 0-16, the Sprite shows again on tick 17  (wrong: [])
PASS  swing on S5 t110: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then sword_run)
PASS  swing on S5 t156 (tick 1412): clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-16; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S5 t156: SlashRig shows and the Sprite hides on ticks 0-16, the Sprite shows again on tick 17  (wrong: [])
PASS  swing on S5 t156: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then sword_idle)
PASS  swing on S5 t239 (tick 1495): clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-16; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S5 t239: SlashRig shows and the Sprite hides on ticks 0-16, the Sprite shows again on tick 17  (wrong: [])
PASS  swing on S5 t239: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then sword_rise)
PASS  swing on S5 t326 (tick 1582): clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-16; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S5 t326: SlashRig shows and the Sprite hides on ticks 0-16, the Sprite shows again on tick 17  (wrong: [])
PASS  swing on S5 t326: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then sword_idle)
PASS  swing on S6 t544 (tick 2304): clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-16; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S6 t544: SlashRig shows and the Sprite hides on ticks 0-16, the Sprite shows again on tick 17  (wrong: [])
PASS  swing on S6 t544: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then sword_idle)
PASS  swing on S6 t562 (tick 2322), cut on swing tick 12 to hurt: clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-11; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S6 t562: SlashRig shows and the Sprite hides on ticks 0-11, the Sprite shows again on tick 12  (wrong: [])
PASS  swing on S6 t562: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then hurt)
PASS  swing on S7 t215 (tick 2613), cut on swing tick 15 to sword_fall: clip position = (ticks since the press)/60, Grip, Lean and Arc = the slash clip sampled there  (press read on swing tick 0: true; ticks 0-14; max error: position 0.000000 s, Grip 0.0000, Lean 0.0000, Lean x 0.0000, Arc 0.0000)
PASS  swing on S7 t215: SlashRig shows and the Sprite hides on ticks 0-14, the Sprite shows again on tick 15  (wrong: [])
PASS  swing on S7 t215: hitbox live on swing ticks 2-10 only (before any cut), whatever follows  (live on [2, 3, 4, 5, 6, 7, 8, 9, 10], then sword_fall)
PASS  the hitbox is never live outside a swing's ticks  (8 swings; stray live ticks: [])
RESULT PASS: 81 checks, 0 failed, 2932 ticks
```

One line needs a gloss: the `run -> idle` line shows the cause of its first case only. Its S1 t186 case is the turn on the ground, where vx drops from −560 to 0 at once.

## Run 2

I saved both runs' STATES and RESULT lines and compared them:

```
Files .../scratchpad/states_run1.txt and .../scratchpad/states_run2.txt are identical
RESULT PASS: 81 checks, 0 failed, 2932 ticks
```

The wrapper reported no error lines in either run.

## `scripts/run-test.sh test_rudy_pin.tscn 60`

```
FAIL  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T6 the run resumes after a slash  (restarts: CHAR-SWORD-RUN-A for 4 ticks before the swing, CHAR-SWORD-RUN-A for 8 ticks after it)
RESULT FAIL: 19 checks, 3 failed, 953 ticks
```

That is still 16 of 19, with only T1, T2 and T6 failing, as committed in step 2b. `logs/test_rudy_pin_60fps.log` is byte-identical to the committed one: git shows no change to it.

## `scripts/run-test.sh checks.tscn 60`

```
PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (97 paths; missing: )
all checks passed
```

The count is 97 as expected. The one new path is `res://tests/test_rudy_states.gd`, named by the new scene. The two paths the script names, `res://app/main.tscn` and `res://content/rudy/rudy_animations.tres`, were already counted.

## git status

```
On branch shuai-z/assignment-7
You are in a sparse checkout with 52% of tracked files present.
Changes not staged for commit:
	modified:   logs/checks_60fps.log
Untracked files:
	game/tests/test_rudy_states.gd
	game/tests/test_rudy_states.tscn
	logs/test_rudy_states_60fps.log
	sessions/prompt-9.txt
```

(The output above is translated; git printed it in Chinese.)

## Scenarios

Every scenario starts on a fresh level, on the walk line (y 840), facing right, without the sword and with 3 hearts. Keys are given as key+ (down) or key− (up) @ scenario tick, where t0 is the tick the first key is read.

| # | Starts at | Keys @ tick | States reached @ tick |
|---|---|---|---|
| S1 plain moves | x 600, placed in setup | D+@0 D−@30 Space+@55 −@56 A+@112 Space+@132 −@133 D+A−@186 D−@206 Space+@226 −@227 D+@254 Space+@278 −@279 D−@304 | run@0 › idle@35 › rise@55 › idle@96 › run@119 › rise@132 › fall@155 › run@173 › idle@186 (turn) › run@193 › idle@211 › rise@226 › run@267 › rise@278 › fall@301 › idle@319 |
| S2 spikes, defeat | x 300, the level's StartPoint (no placement) | D+@0 D−@81 Space+@192 −@193 D+@215 D−@234 A+@345 A−@357 D+@425 D−@481 | run@0 › hurt@80 › idle@101 › rise@192 › fall@215 › hurt@233 (fell onto the spikes) › idle@254 › run@345 › defeat@356 › respawn@424 › idle@465 › run@466 › idle@486 |
| S3 run into the pit | x 4150, placed | D+@0 D−@136 | run@0 › fall@19 › respawn@79 › idle@120 › run@121 › idle@141 |
| S4 jump into the pit | x 4280, placed | Space+D+@0 Space−@1 D−@12 | rise@0 › respawn@89 › idle@130 |
| S5 sword moves | x 2400, placed | D+@0 Space+@19 −@20 J+@29 −@30 D−@71 A+@91 J+@110 −@111 A−@136 J+@156 −@157 Space+@187 −@188 J+@239 −@240 Space+@244 −@245 Space+@301 −@302 J+@326 −@327 Space+@368 −@369 A+@396 Space+@420 −@421 A−@446 | run@0 › sword_run@8 (pickup) › sword_rise@19 › slash@29 › sword_fall@46 › sword_run@60 › sword_idle@76 › sword_run@98 › slash@110 › sword_run@127 › sword_idle@141 › slash@156 › sword_idle@173 › sword_rise@187 › sword_idle@228 › slash@239 › sword_rise@256 (jump on swing tick 5) › sword_idle@285 › sword_rise@301 › slash@326 › sword_idle@343 › sword_rise@368 › sword_run@409 › sword_rise@420 › sword_fall@443 › sword_idle@461 |
| S6 hit in a swing | x 2400, placed | D+@0 D−@61 A+@76 A−@77 J+@544 −@545 J+@562 −@563 | run@0 › sword_run@8 › sword_idle@66 › slash@544 › sword_idle@561 › slash@562 › hurt@574 (goblin B from behind, swing tick 12) › idle@595 |
| S7 sword into the pit | x 2400, placed | D+@0 Space+@65 −@66 J+@215 −@216 D−@316 | run@0 › sword_run@8 › sword_rise@65 (over goblin B) › sword_fall@88 › sword_run@106 › sword_fall@206 (off the ledge) › slash@215 › sword_fall@230 (fell out on swing tick 15) › respawn@266 (at the waystone) › idle@307 › run@308 › idle@321 |
| S8 celebrate | x 7000, placed | D+@0 D−@16 | run@0 › celebrate@15 |

Four presses were timed from read-only reads rather than fixed ticks:
- S2 t345: the direction of the last run (A, because he was right of the spikes at x 1065).
- S6 t76: the turn, sent once he had stopped after letting D go at x ≥ 2945.
- S6 t544: the first slash, 5 ticks after goblin B came back within 100 px.
- S7 t65: the jump, when goblin B was within 160 px ahead.

**Not reached: 18 of the table's 57 transitions.**
- **Cannot happen in this code:**
  - `slash -> respawn`: the fall-out ends the swing first, and he cannot be defeated with the sword.
  - `hurt -> run`: no direction is read on the tick hurt ends, and the knockback's vx has already decayed to 0.
- **Not seen on this level:**
  - `hurt -> rise` and `hurt -> fall`: he lands about 11 ticks into the 21-tick hurt.
  - `idle -> celebrate`: he has to move to get onto the circle.
- **Reachable but not scripted:**
  - `idle -> hurt`, `idle -> defeat`: my first draft hit both by accident, with goblin A walking into him.
  - `rise -> hurt`, `rise -> defeat`, `fall -> defeat`.
  - `sword_idle`, `sword_run`, `sword_rise` and `sword_fall` -> `hurt`.
  - `sword_idle`, `sword_run` and `slash` -> `celebrate`.
  - `sword_rise -> respawn`.

## ANOMALIES

**`run -> sword_run`: section 3's table has no change of form.** Walking into the pickup mid-run cuts to `sword_run`, which restarts from cell A on the tick he takes the sword. Revision 4 names this restart, but the table lists no such transition. The test keeps what was measured and marks this pair as off the table. It happened on S5 t8, S6 t8 and S7 t8:

```
tick  1263 S5 st    7 PLAY        run        pos 0.1167 CHAR-RUN-A       spr 1 rig 0 grip    0.00 lean   0.00 x  0.00 arc 1.000 hb_dis 1 v(  560.0,    0.0) floor 1 gear 0 hearts 3 at  2451.3 in -
tick  1264 S5 st    8 PLAY        sword_run  pos 0.0000 CHAR-SWORD-RUN-A spr 1 rig 0 grip    0.00 lean   0.00 x  0.00 arc 1.000 hb_dis 1 v(  560.0,    0.0) floor 1 gear 1 hearts 3 at  2460.7 in -
```

Everything else matched the brief, Revisions 3 and 4, and the plan:
- Every clip plays from 0 on its entry tick.
- Every run shows its first cell for 8 ticks.
- On every swing, the clip position is exactly k/60, and Grip, Lean and Arc match `value_track_interpolate()` with zero error.
- The rig shows on ticks 0–16 and the Sprite on tick 17. On a cut swing, the Sprite shows on the cut tick.
- The hitbox is live on ticks 2–10 only.

One observation that is not a disagreement: after a swing, the hidden rig keeps its tick-16 pose, because no other clip keys the rig's parts. For example, Grip stays at 15.83:

```
tick  1429 S5 st  173 PLAY        sword_idle pos 0.0000 CHAR-SWORD-IDLE  spr 1 rig 0 grip   15.83 lean   0.08 x  0.17 arc 0.000 hb_dis 1 ...
```

## What still needs a human to play
- **Whether each state reads on screen,** especially the cuts:
  - the pickup's restart to `SWORD-RUN-A`;
  - the run restarting after a slash, a hurt or a respawn;
  - the rig appearing and disappearing.
- **Whether you can tell his state with the sound muted.**
- **The art against Visible Collision Shapes** in every pose.
- **The 30 fps behaviour,** which this test does not cover. It is the edge test, step 5b.
- **The transitions listed as not reached,** if you want them seen.

Nothing is committed.