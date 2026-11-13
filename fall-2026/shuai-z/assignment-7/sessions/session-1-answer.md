I've read everything and changed nothing. One limit first: this session can't run shell commands (Bash was denied), so I ran no Godot command. Every measured value below comes from logs already committed in `evidence/` and `logs/`. Where I've only worked a number out from the code, I say so.

## 1. Where Rudy's gameplay state lives

**There are no animation nodes in the game.** A search of `game/` for `AnimationPlayer`, `AnimationTree`, `AnimatedSprite2D`, `Skeleton2D`, `Bone2D` and `AnimationLibrary` finds nothing. The only `AnimationPlayer`s in the folder are the probe fixtures in `evidence/brief-probe/tests/probe/g3/`, which aren't part of the game. So no animation key decides anything today.

**All of it is in `game/content/rudy/rudy.gd`.** Rudy's state is the script's own variables plus the body's physics:

| State | Where |
|---|---|
| `mode`: WAITING, PLAY, HURT, DEFEATED, FALLEN, RESPAWNING, CELEBRATING | enum `rudy.gd:40-48`, variable `:80` |
| `gear`, `hearts`, `facing`, `pose` | `:78-82` |
| Timers: `_run_clock`, `_turn_time_left`, `_respawn_time_left`, `_hurt_time_left`, `_invulnerable_left`, `_slash_clock` (below 0 means not swinging) | `:84-92` |
| Air-pose memory: `_was_falling`, `_falls_sideways`, `_bounce_pending` | `:89-91` |
| `velocity`, `is_on_floor()` (from CharacterBody2D) | written `:199-227` |

What he looks like is a copy of that state:
- `RudyLook.pose` and `_sprite.texture` are set by `show_pose()` (`rudy_look.gd:34`, `:39-46`).
- `Look.scale.x` follows `facing` and `Look.modulate.a` does the invulnerability flash (`rudy.gd:231-232`).

**Other scripts write his state too, through his methods:**
- `main.gd:82` sets WAITING and `:109` sets PLAY.
- `main.gd:120` calls `fall_out()`, `:128` calls `respawn_at()` and `:188` calls `celebrate()`.
- `goblin.gd:107` calls `bounce()`, and `goblin.gd:109` and `spikes.gd:18` call `take_hit()`.
- `sword_pickup.gd:49` calls `equip_sword()`.

**One thing to know:** `_pick_pose()` changes state as well as reading it. It sets `_run_clock`, `_was_falling` and `_falls_sideways` (`:299-310`).

## 2. What decides each state and transition

The order within one tick is in `_physics_process` (`rudy.gd:198-234`): input and facing, horizontal speed, gravity or jump, slash start, `move_and_slide`, `_swing`, the countdowns, then `_pick_pose` and `show_pose`.

**Mode transitions:**

| Transition | Decided at |
|---|---|
| WAITING → PLAY | `main.gd:106-109` (Enter on the title) |
| PLAY/HURT → HURT, or → DEFEATED at 0 hearts without the sword | `rudy.gd:129-153`; also cancels the swing (`:143`) |
| HURT → PLAY | `rudy.gd:265-268`, after `hurt_time` 0.35 s |
| PLAY → FALLEN | `main.gd:89-90` → `rudy.gd:167`; cancels the swing (`:168`) |
| FALLEN/DEFEATED → RESPAWNING | `main.gd:128` → `rudy.gd:177-190`; cancels the swing (`:182`), takes the sword (`:181`) |
| RESPAWNING → PLAY | `rudy.gd:269-273`, after `respawn_time` 0.7 s |
| PLAY → CELEBRATING | `main.gd:188` → `rudy.gd:193-195`; cancels the swing |

**Pose choice** is a priority list in `_pick_pose` (`rudy.gd:285-311`); the first match wins:
1. CELEBRATE, RESPAWN, DEFEAT or HURT, by `mode` (`:286-294`).
2. `CHAR-SWORD-SLASH` while `is_slashing()` (`:295-296`).
3. In the air (`:298-304`): FALL only if he's falling and was moving sideways (`|vx| > 1`) when the fall began; otherwise RISE. FALLEN mode lands here too.
4. RUN-A/RUN-B on the floor while `|vx| > 1`, using `fmod(_run_clock, 0.25) >= 0.125` (`:306-309`).
5. IDLE otherwise (`:310-311`). WAITING lands here.

States 3–5 use the `CHAR-SWORD-` frames while `gear == SWORD` (`:297`).

**The inputs behind those choices:**

| Action | Decided at |
|---|---|
| Jump | `rudy.gd:219-222`: a fresh press, on the floor, in PLAY |
| Slash start | `:223-226`: in PLAY, with the sword, not already swinging, a fresh press. It works in the air too |
| Slash end | `:248-251`: when `_slash_clock >= slash_time` |
| Hitbox live | `:241-242`: `0.03 <= clock <= 0.18`, read before the tick adds `delta` |
| Turn on the ground | `:204-208`: `vx` is zeroed and he waits `turn_hold_time` 0.12 s before moving |
| Run ↔ idle | `:212-215`: `move_toward` at 5600 px/s², about 93.3 px/s per tick |

**Hit order:** in `main.tscn`, `Level1` (the goblins and spikes) comes before `Rudy` (`:15`, `:21`). So a hit lands before his own tick runs, and that tick already shows `CHAR-HURT`.

## 3. Physics ticks per second: 60

`game/project.godot` doesn't set `physics/common/physics_ticks_per_second`, so the default of 60 holds. The committed probe printed `ticks/s 60` (`evidence/brief-probe/logs/slash_ticks_60fps_frame.log:3`). No script changes it: every use of `Engine.physics_ticks_per_second` in `game/` only reads it.

## 4. ANOMALIES (measured, kept, not fixed)

- **A1: the swing is 17 ticks, not 18.** `slash_time` 0.3 s reads as 18 ticks at 60/s. The probe shows the slash pose on ticks 0–16 and `CHAR-SWORD-IDLE` on tick 17 (`slash_ticks_60fps_frame.log:4-21`). The clock already moves forward on the tick of the press (`rudy.gd:225` and then `:249`), so after tick 17 it reaches 18/60.
- **A2: the existing swing-length check is loose.** `checks.gd:732` accepts `(swing_ticks + 2)/60` within ±2/60 s of 0.3 s, so it can't tell a 17-tick swing from an 18- or 19-tick one. That's the only reason it doesn't contradict A1. I'm noting it, not changing it.

The run cycle hasn't been measured yet. From the code I expect `RUN-A` to last 7 ticks first, because the clock moves forward before it's read (`:307-308`). After that, the cell lengths depend on how `fmod` rounds at multiples of 0.125 s. The pin will measure them. If they don't match the code, the measured values go in the test and on this list.

## 5. Proposal (1): the pin test, `game/tests/test_rudy_pin.tscn` + `test_rudy_pin.gd`

**The scene, laid out in the `.tscn` so the script never writes a position.** Hazards and the pickup come before Rudy, as in `main.tscn`:
```
PinTest (Node, test_rudy_pin.gd)
└── World (Node2D)
    ├── Floor     StaticBody2D, layer 1, 20000 × 100 rectangle, top at y 0
    ├── Pickup    sword_pickup.tscn at (-500, 0)    (mask 2, sword_pickup.tscn:11)
    ├── Spikes    spikes.tscn at (2500, 0)
    ├── Rudy      rudy.tscn at (0, 0)    (mode defaults to PLAY, rudy.gd:80)
    └── Recorder  Node, process_physics_priority 100, so it runs after Rudy each tick
```
There's no `Main`, so no title, camera or music.

**Driving it:**
- Input is only `InputEventKey` with `physical_keycode` D, A, Space or J, sent through `Input.parse_input_event`.
- The script steps with `await get_tree().process_frame`, one frame per step at `--fixed-fps 60`, so one tick per step. An event sent right after the await is read on the next tick, which the test calls tick 0 (`slash_ticks_60fps_frame.log:4`).
- A tap is a key-down and then a key-up on the next frame.
- It never calls Rudy's or `RudyLook`'s methods, never writes velocity, position or game state, and never resets `Sfx`: it reads `Sfx.count(&"slash")` as before-and-after differences.

**Per-tick log line** from the Recorder: tick, `mode`, `pose`, `velocity`, `is_on_floor()`, `_slash_clock`, `SwordHitbox/Shape.disabled`, `facing`, `gear`. Every check is computed from these samples.

**The script:**
1. Wait 10 frames to settle.
2. Run right without the sword for 60 ticks, release, stop.
3. Jump in place.
4. Hold A until `gear == SWORD`, then turn right.
5. Single slash, then presses on swing ticks 1, 2, 10, 11, 16, 17 and 18.
6. Jumps pressed on swing ticks 1, 5 and 12.
7. Run, slash, run while holding D.
8. Hold D into the spikes, with J pressed on the way, then wait out HURT.

Bounded waits use conditions read from the samples. A wait that times out is a FAIL.

**Output:** results are collected and printed in two blocks, `== TIMING ==` and `== INVARIANT ==`, as `PASS/FAIL  T<n>/I<n> <what>  (<measured>)`, then a summary line. It exits 1 on any FAIL.

**TIMING** (numbers you may change on purpose):

| # | Line |
|---|---|
| T1 | Run without the sword, from a standstill: first run tick = the press tick; the measured A/B cell lengths over 60 run ticks (predicted: A 7 ticks first) |
| T2 | The same with the sword (`CHAR-SWORD-RUN-A/B`) |
| T3 | Slash pose on swing ticks 0–16, 17 ticks; first `CHAR-SWORD-IDLE` on tick 17 |
| T4 | Hitbox live on swing ticks 2–10 |
| T5 | A press read on tick 17 is ignored; one read on tick 18 starts a new swing |
| T6 | Run phase after a slash: the run cell and how long it has left after tick 17 match where `_run_clock` stood before the swing (it resumes today) |
| T7 | Run → idle after releasing D: number of ticks until `CHAR-IDLE` |
| T8 | Turn on the ground: number of idle ticks before the run starts |
| T9 | HURT lasts N ticks (0.35 s is about 21) |

**INVARIANT** (facts that must survive any change):

| # | Line |
|---|---|
| I1 | Every tick the hitbox is live, the pose is `CHAR-SWORD-SLASH`; each swing has exactly one dead→live edge and 9 live ticks |
| I2 | No swing starts during a swing: `_slash_clock` never returns to 0 mid-swing for presses on ticks 1–17 |
| I3 | One `slash` sound per swing |
| I4 | On the first HURT tick: pose `CHAR-HURT`, not slashing, hitbox disabled, gear NONE |
| I5 | Every tick, `RudyLook.frame()` equals `FRAMES[pose]` |
| I6 | `CHAR-SWORD-*` poses appear only with the sword, and the plain-form idle/run/rise/fall poses never with it |
| I7 | A jump during a swing (ticks 1, 5, 12): takeoff on that tick, slash pose to tick 16, live ticks 2–10 unchanged, then `CHAR-SWORD-RISE` or `-FALL` |
| I8 | Slash without the sword: no swing, no sound, hitbox never live |

Run it with `scripts/run-test.sh test_rudy_pin.tscn 60`.

## 6. Proposal (2): the smallest plan

**The animation set.** All clips live in one library, `game/content/rudy/rudy_animations.tres`:
- `run` and `sword_run`: looping sprite frame tracks, two discrete keys at 0 and 0.125 s, `length` 0.25.
- `slash`: a cutout rig, `LOOP_NONE`, `length` 17/60 s.
- One-key looping clips for the other states: `idle`, `sword_idle`, `rise`, `sword_rise`, `fall`, `sword_fall`, `hurt`, `defeat`, `respawn`, `celebrate`.

**The state machine.** The priority list in `_pick_pose` stays the only authority, but returns a clip name. `RudyLook` plays that clip when it changes, and calls `seek(0, true)` for each new slash. There's no `AnimationTree`. The player runs on the physics callback with `autoplay` empty.

**Steps, one per prompt, each committed by you:**

| Step | What | Checks |
|---|---|---|
| 0 | The pin above. No game change | pin plus the six earlier tests |
| 1 | `tools/pack_rudy_sheet.py` and the 4 × 4 sheet. No game change | the script's pixel check; earlier tests |
| 2 | `AnimationPlayer`, the library of sprite clips, the Sprite on the sheet; `rudy.gd` returns clip names; `_run_clock` and `run_frame_time` go. The slash is still one key on cell 10 | `test_rudy_clips.tscn` (read-back); pin; earlier tests. Expected FAIL: T6 only (the run now restarts after a slash) |
| 3 | `tools/cut_slash_rig.py` and the three rig parts. No game change | the script's composite and band check |
| 4 | `SlashRig` nodes and the keyed `slash` clip | read-back; pin (I1–I8 must pass); earlier tests |
| 5 | `test_rudy_states.tscn` and `test_rudy_edges.tscn` (E1–E7, at 60 and 30) | the new tests |
| 6 | Re-pin T6, after you've played it | pin |

**What only you can judge:** nothing for step 0. From step 2 on, with the strips at normal speed and at `--time-scale 0.25`:
- whether the run reads, its cadence, and whether he stays on the ground line;
- the slash's wind-up, sweep and ghost band;
- the art against Visible Collision Shapes;
- whether you can tell his state with the sound muted.

Tell me which step to start; I'd begin with step 0. When the session can run commands, I'll run the checks through the wrapper and paste the real output.
