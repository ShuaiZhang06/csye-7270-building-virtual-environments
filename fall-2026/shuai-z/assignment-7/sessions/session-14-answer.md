I corrected the state test's TABLE to Revision 5 and added scenarios S9–S20. The test now reaches **54 of the 58 transitions**, and the other 4 are listed with their reasons. Both runs gave **RESULT PASS: 99 checks, 0 failed, 6933 ticks**. Nothing is committed.

Two things you should know first:
- **`sword_idle -> celebrate` cannot happen, although session 9 judged it reachable.** It fails for the same reason as `idle -> celebrate`, so it stays in NOT REACHED (details in ANOMALIES).
- **Run 2 was compared by eye, not with a diff tool.** Copying run 1's log to the scratchpad was refused, so I compared the lines I searched for in both runs. They are identical, at the same line numbers, with the same tick count.

## `scripts/run-test.sh test_rudy_states.tscn 60`, run 1

This is an excerpt. The full STATES section, 99 PASS lines, is at `logs/test_rudy_states_60fps.log:7017-7125`.

```
PASS  every scripted wait was met
PASS  transition run -> sword_run (in the table): walked into the pickup  (10 times, on S5 t8, S6 t8, S7 t8, S12 t8, S13 t8, S14 t8, S15 t8, S16 t8, S17 t8, S18 t8)
PASS  transition rise -> hurt (in the table): a hit: hearts 3>2, gear 0>0  (1 times, on S9 t41)
PASS  transition idle -> hurt (in the table): a hit: hearts 2>1, gear 0>0  (3 times, on S9 t113, S10 t87, S11 t87)
PASS  transition idle -> defeat (in the table): a hit took his last heart: hearts 1>0  (1 times, on S9 t185)
PASS  transition rise -> defeat (in the table): a hit took his last heart: hearts 1>0  (1 times, on S10 t210)
PASS  transition fall -> defeat (in the table): a hit took his last heart: hearts 1>0  (1 times, on S11 t210)
PASS  transition sword_run -> hurt (in the table): a hit: hearts 3>3, gear 1>0  (1 times, on S12 t81)
PASS  transition sword_idle -> hurt (in the table): a hit: hearts 3>3, gear 1>0  (1 times, on S13 t213)
PASS  transition sword_rise -> hurt (in the table): a hit: hearts 3>3, gear 1>0  (1 times, on S14 t213)
PASS  transition sword_fall -> hurt (in the table): a hit: hearts 3>3, gear 1>0  (1 times, on S15 t212)
PASS  transition sword_rise -> respawn (in the table): Main respawned him from FALLEN  (1 times, on S16 t296)
PASS  transition sword_run -> celebrate (in the table): on the teleport circle  (1 times, on S17 t508)
PASS  transition slash -> celebrate (in the table): on the teleport circle  (1 times, on S18 t508)
PASS  transition rise -> sword_rise (in the table): jumped into the pickup  (1 times, on S19 t29)
PASS  transition fall -> sword_fall (in the table): jumped into the pickup  (1 times, on S20 t52)
PASS  every transition in the table (58) is reached, or listed as not reachable with its reason  (54 reached, 4 listed; unreached without a reason: []; listed but reached: []; listed but not in the table: [])
== NOT REACHED ==
NOT REACHED  idle -> celebrate: cannot happen in this code on this level. The circle (Portal: a 160 x 60 px box standing on the ground, portal.tscn:7, :24; main.gd:184-188) is entered only by moving into it, and the clip of the tick he enters it is the one that leaves. On the floor he moves only with |velocity.x| > 1, which picks run (rudy.gd:318-319): velocity.x changes in steps of run_accel/60 = 93.3 px/s from 0, 560 or the 350 px/s knockback (rudy.gd:57, :158, :220), so it is never between 0 and 1. Dropping in from above, he crosses the box's top 60 px above the ground while still in the air, since the fastest fall on this level (from the 294 px apex, rudy.gd:60-61) covers about 32 px a tick, which picks rise or fall (rudy.gd:309-316)
NOT REACHED  sword_idle -> celebrate: cannot happen in this code on this level, for idle -> celebrate's reason: entering the circle moving on the floor picks sword_run, or slash during a swing (rudy.gd:306-307, :318-319); dropping into its 60 px box from above, he is still in the air, which picks sword_rise or sword_fall (rudy.gd:309-316)
NOT REACHED  hurt -> rise: this level cannot produce it. hurt lasts 21 ticks (hurt_time 0.35 s, rudy.gd:74, :272-275), and on flat ground a hit leaves him in the air for at most about 18 (a goblin's box reaches his soles only below 118 px, goblin.gd:19, and the knockback adds 17 px up, rudy.gd:73; spikes reach 52 px, spikes.tscn:7). So hurt ends in the air, or he falls out during it, only if the knockback carries him over a ledge, and every hazard on Level1 is at least 378 px from one (goblin C's patrol ends at x 6020, the cliff at x 6400), while a knockback travels at most about 113 px. The longest time in the air after a hit is measured below
NOT REACHED  hurt -> fall: this level cannot produce it, for hurt -> rise's reason: no hazard on Level1 stands within a knockback's reach of a ledge, and on flat ground he lands before hurt_time ends
4 of 58 table transitions not reached
measured for hurt -> rise and hurt -> fall: ticks in HURT per hit [21]; ticks in the air from each hit, longest 14: S2 t80 from run: 12; S2 t233 from fall: 11; S6 t574 from slash: 12; S9 t41 from rise: 11; S9 t113 from idle: 12; S10 t15 from run: 12; S10 t87 from idle: 12; S11 t15 from run: 12; S11 t87 from idle: 12; S12 t81 from sword_run: 12; S13 t213 from sword_idle: 12; S14 t213 from sword_rise: 14; S15 t212 from sword_fall: 14
== ANOMALIES ==
RESULT PASS: 99 checks, 0 failed, 6933 ticks
```

## Run 2

Every line above came back identical: the same text at the same log line numbers (STATES at 7017, NOT REACHED at 7117–7123, RESULT at 7125), and the same tick count.
```
RESULT PASS: 99 checks, 0 failed, 6933 ticks
```
The wrapper flagged no error line in either run.

There is one difference between runs, outside these lines. The exit-time "ObjectDB instances leaked" count changed: 24 in run 1, 22 in run 2, and 25 in the committed log. It was already there before this step, and the wrapper does not fail on it.

## `scripts/run-test.sh test_rudy_pin.tscn 60`
```
FAIL  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T6 the run resumes after a slash  (restarts: CHAR-SWORD-RUN-A for 4 ticks before the swing, CHAR-SWORD-RUN-A for 8 ticks after it)
RESULT FAIL: 19 checks, 3 failed, 953 ticks
```
That is still 16 of 19, with only T1, T2 and T6 failing. In the pin's log, only the leak count changed (16 → 18).

## `scripts/run-test.sh checks.tscn 60`
```
PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (98 paths; missing: )
all checks passed
```
The res:// path count stays at 98. In its log, only the leak count and one random camera-shake offset changed.

## What changed
- **TABLE**, corrected to Revision 5:
  - removed `slash -> respawn` and `hurt -> run`;
  - added `run -> sword_run`, `rise -> sword_rise` and `fall -> sword_fall`;
  - it now has 58 transitions, and `MEASURED_OFF_TABLE` is empty.
- **`NOT_REACHABLE`**: a list of the four pairs, each with its reason, which the log prints.
- **One new check:** every table transition is reached, or listed with a reason. It also fails if a listed pair is ever reached.
- **The measured line:** the log now prints how long each hit kept him in the air (the `measured` line above).
- **S9–S20**, run after the existing scenarios. They follow the test's rules: setup only places him, and input is only `parse_input_event`.
- **A different cause label.** A pickup taken in the air is labelled "jumped into the pickup". The existing on-the-ground case keeps "walked into the pickup".
- **Header:** a line for this step.
- **No existing scenario, check or expected value changed.**
- **CLAUDE.md:** only the state test's line, now 99 PASS at `:7125`.

How the new scenarios work:

| # | What it does |
|---|---|
| S9–S11 | Spikes A. A hit leaves him invulnerable, so he walks onto the spikes and stands there until they hit him: `idle -> hurt` and `idle -> defeat`. A jump in place, steered onto them after the top, gives the rise and fall hits. S9 starts with that jump; S10 and S11 start by running into the spikes. |
| S12 | With the sword, runs on into goblin B. |
| S13–S15 | Takes the sword, goes back to goblin A's turning point and waits. S14 jumps when goblin A is 44 px away. S15 jumps at 109 px and taps A on the tick the fall begins, so goblin A reaches him low in the fall rather than under a stomp. |
| S16 | S7's opening, then S4's straight-down jump into the pit, with the sword. |
| S17, S18 | checks.gd's route, with its jump leads, sent as key events. S18 swings at x 7000. |
| S19, S20 | Running jumps into the pickup, timed against its 45 px circle 76 px up. |

## The 58 transitions

Ticks are scenario ticks, counted from the scenario's first input, at the first time each transition happened.

| From | To | Reached |
|---|---|---|
| idle | run / rise / hurt / defeat | S1 t0 / S1 t55 / **S9 t113** / **S9 t185** |
| idle | celebrate | **not reached:** cannot happen (rudy.gd:318-319, :220; 60 px box at portal.tscn:7, :24; fall speed from rudy.gd:60-61) |
| run | idle / rise / fall / hurt / defeat / celebrate / sword_run | S1 t35 / S1 t132 / S3 t19 / S2 t80 / S2 t356 / S8 t15 / S5 t8 |
| rise | fall / idle / run / hurt / defeat / respawn / sword_rise | S1 t155 / S1 t96 / S1 t267 / **S9 t41** / **S10 t210** / S4 t89 / **S19 t29** |
| fall | idle / run / hurt / defeat / respawn / sword_fall | S1 t319 / S1 t173 / S2 t233 / **S11 t210** / S3 t79 / **S20 t52** |
| sword_idle | sword_run / sword_rise / slash / hurt | S5 t98 / S5 t187 / S5 t156 / **S13 t213** |
| sword_idle | celebrate | **not reached:** cannot happen, the same reason as idle (rudy.gd:306-307, :309-320) |
| sword_run | sword_idle / sword_rise / sword_fall / slash / hurt / celebrate | S5 t76 / S5 t19 / S7 t206 / S5 t110 / **S12 t81** / **S17 t508** |
| sword_rise | sword_fall / sword_idle / sword_run / slash / hurt / respawn | S5 t443 / S5 t228 / S5 t409 / S5 t29 / **S14 t213** / **S16 t296** |
| sword_fall | sword_idle / sword_run / slash / hurt / respawn | S5 t461 / S5 t60 / S7 t215 / **S15 t212** / S7 t266 |
| slash | sword_idle / sword_run / sword_rise / sword_fall / hurt / celebrate | S5 t173 / S5 t127 / S5 t256 / S5 t46 / S6 t574 / **S18 t508** |
| hurt | idle | S2 t101 |
| hurt | rise / fall | **not reached:** this level has no hazard within a knockback's reach (about 113 px) of a ledge. The nearest is 378 px away. On flat ground he lands at most 14 ticks after a hit (measured), and hurt lasts 21. |
| defeat | respawn | S2 t424 |
| respawn | idle | S2 t465 |

Bold marks the transitions this step reached.

I checked session 9's three unreachable pairs again before keeping them:
- **`hurt -> rise` and `hurt -> fall`:** the measurement bears them out. The longest time in the air after a hit was 14 ticks (the hits from `sword_rise` and `sword_fall`), and hurt always lasted 21.
- **`idle -> celebrate`:** follows from rudy.gd's velocity steps and the circle's 60 px box.

## ANOMALIES
- **`idle -> celebrate` and `sword_idle -> celebrate` are in the brief's table (section 3), but this code on this level cannot produce them.** Revision 5 did not remove them.
  - **Why idle cannot happen:** he can only enter the circle by moving into it. On the ground, moving always picks the run clip, or slash during a swing. Dropping in from above, he crosses the box's top while still in the air.
  - **Session 9:** it put `sword_idle -> celebrate` among the reachable ones, and that was wrong.
  - **What I did:** kept them in the table as the brief has them and listed both in NOT REACHED. I did not change the game or the brief. Whether a revision removes them is your decision.
- **Everything measured matched the brief.** That includes every new swing (S18's, cut by the circle on swing tick 12): clip position k/60 with zero error, and the hitbox live only on ticks 2–10.

## git status
```
 M CLAUDE.md
 M game/tests/test_rudy_states.gd
 M logs/checks_60fps.log
 M logs/test_rudy_pin_60fps.log
 M logs/test_rudy_states_60fps.log
?? sessions/prompt-14.txt
```
`git diff --stat game/shaders/` and `git diff scripts/run-test.sh` both print nothing. The `.tscn` did not need to change.

## What still needs a human to play
- **Whether the new cuts read on screen:**
  - a hurt from the rise and from the fall pose;
  - the sword knocked away mid-fall (S15);
  - the form changing in mid-air at the pickup (`rise -> sword_rise`, `fall -> sword_fall`);
  - a swing cut short by the circle (S18).
- **Standing on the spikes until they hit:** it is real gameplay, but it is a strange way to play. Check that the hurt pose reads there.
- **The art against Visible Collision Shapes** in these poses, especially the goblin's touch in the rise and fall poses.
- **Whether you can tell his state with the sound muted.**
- **Whether the brief should drop `idle -> celebrate` and `sword_idle -> celebrate`.**