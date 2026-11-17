# TEST-REPORT — Assignment 7: Rudy's run cycle and sword slash

The text's "Use It": "Open the project in the Godot editor and run it. Record actual results in TEST-REPORT.md, with the source revision, Godot version and renderer."

**Who wrote what.** Claude Code (Claude Opus 5.5) ran the headless tests and drafted this report from their logs. The human checks are mine. Each one is recorded only after I have done it, in my own words, with Claude's translation beside them, marked as a translation. A row that says "not done yet" has not been done.

## The run

- **Source revision:** `09ce1cb7`. Claude ran every test below at this revision on 2026-11-16, through `scripts/run-test.sh`, in its stated mode.
  - Every count equals the one in the committed log.
  - The logs differed from the committed ones only in Godot's leak lines and in the random camera-shake offset, so they were not committed again.
  - No log contains `SHADER ERROR`, `SCRIPT ERROR` or `Failed loading resource`.
- **Godot:** 4.7.2.stable.official.ed1daf0bf (`logs/checks_60fps.log:1`).
- **Renderer:** GL Compatibility (`game/project.godot:16`, `:95-96`). In a window: OpenGL API 4.1 Metal, Apple M3 (`logs/slash_preview_r0.log:2`).
- **OS:** macOS 15.1 (24B83).
- **The editor run.** The text: "Open the project in the Godot editor and run it." **Done, by me**, on 2026-11-16. My words: "跑过了，没问题". Claude's translation: "I ran it; no problem."

## Baseline

Every earlier test, before the change and after it, in its pinned mode:

| Test | Mode | Before (`db2f8989`) | After (`09ce1cb7`) |
|---|---|---|---|
| `checks.tscn` | 60 | 141 PASS | 141 PASS (`logs/checks_60fps.log:3-144`) |
| `invulnerable_tint_checks.tscn` | 30, 60, 144 | 15 PASS each | 15 PASS each |
| `test_slash_sparks_config.gd` | 60 | 108 checks, then a summary PASS | the same |
| `test_slash_sparks_state.tscn` | 60 | 14 PASS | 14 PASS |
| `test_run_dust_config.gd` | 60 | 61 checks, then a summary PASS | the same |
| `test_run_dust_config.gd` | realtime | 61 checks, then a summary PASS (first logged in `799fc127`) | the same |
| `test_run_dust_state.tscn` | 60 | 14 PASS | 14 PASS |

**Nothing changed in an earlier test.** `checks.tscn`'s scan of `res://` paths now counts 102 paths, where the baseline counted 89, and none is missing. The new paths are the files this change added.

## Pins

`game/tests/test_rudy_pin.tscn` at 60. It drives Rudy through one scripted run with `Input.parse_input_event` only.

| Stage | Commit | Result |
|---|---|---|
| Before the change | `3908ae80` | 19 PASS: T1–T9 (timing) and I1–I8 (invariants) |
| After the change, before the re-pin | `400abd36` to `6eab8f49` | T1, T2 and T6 fail; the rest pass |
| I9 added after the change: the order of the 33 states of the scripted run, from `3908ae80`'s log | `3b0dea9e` | passes at the head and, in a worktree, on `3908ae80` (`logs/pin_I9_on_3908ae80.txt`) |
| Re-pinned, its own commit with the reason | `e45658e6` | **20 PASS** (`logs/test_rudy_pin_60fps.log:959-980`) |

**What changed, and why the brief predicted it:**
- **T1 and T2, the run's cells from a standstill:** `[7, 8, 7, 8, 7, 7, 8, 7, 1]` → `[8, 8, 7, 8, 7, 8, 7, 7]`. The clip's first cell lasts 8 ticks, where the old clock showed 7 (`CHANGE-BRIEF.md` section 7, "The run's first RUN-B").
- **T6, the run after a slash:** "resumes" → "restarts" (section 2.1, "Restart"; section 6, E4; section 10, row 14).
- **The rest of the trail.** Claude compared all 953 ticks of the trail at `3908ae80` with the trail now. Every field matches but the pose, and the pose differs only between a run's two cells:
  - one-tick shifts at the cell edges;
  - the sword pickup mid-run, ticks 284–288, where the sword run now starts at SWORD-RUN-A (Revision 4);
  - after the slash, ticks 687–732 (T6).
- **No pin changed for a reason the brief did not predict.** One sentence of section 7 was loose about the order of the cells. Revision 6 corrects it.
- **I played the run before the re-pin.** On 2026-11-16 I said of it: "我看过了 没问题". Claude's translation: "I have looked at it; no problem."

## Read-back

`game/tests/test_rudy_clips.tscn` at 60: **51 PASS** (`logs/test_rudy_clips_60fps.log:56`). One test reads back both clips: `run` and `sword_run`, the sprite clips, and `slash`, the rig clip. It reads every other clip in the library too. It runs against the `AnimationPlayer` in `rudy.tscn`. The assertions, by name (`logs/test_rudy_clips_60fps.log:4-23`):

| Assertion | Check | What it asserts |
|---|---|---|
| **Track** | 1, 1b | `track_problems()` finds nothing wrong: every track resolves to a real node and property. A second subname (`modulate:a`) also resolves with `get_indexed()` |
| **Key time** | 2 | Key times and clip lengths match the brief to within 1 µs. The slash's six tracks: its keys, values and transitions. Grip by `value_track_interpolate()` on ticks 3 and 16 |
| **Step** | 11 | `is_equal_approx(clip.step, 1.0 / fps)`: 1/60 s for the slash and the one-key clips, 1/8 s for the runs |
| **Loop mode** | 3 | `LOOP_LINEAR` for `run`, `sword_run` and the one-key clips; `LOOP_NONE` for `slash` |
| **Update mode** | 4 | Every frame track is discrete |
| **Frame range** | 4 | Every frame key is below the Sprite's `hframes × vframes` (16), and is its clip's cell |
| Also | 5–10.9, 12 | The player's settings; the Sprite on the sheet; the library against the selector (the structure check, below); the rig's nodes and parts; the pose rule; no Godot 3 names; the library's location |

**Thirty NEGATIVE lines** (`:24-55`) damage in-memory copies, one assertion at a time, and each must fail on its own message. A control line shows that the undamaged copy passes.

## Mutations

The text's four mutations (`6eab8f49`; `evidence/mutations/`). Each ran in a fresh `git worktree` at `f1680bfb`, beside the repository, which was then thrown away.

| Run | The change | Read-back | Caught by |
|---|---|---|---|
| C0 | none, a control | exit 0, 51 PASS | — |
| M1 | slash track 2's subname `rotation_degrees` → `rotation_degree` | **exit 1**, 6 fail | check 1, `track_problems()` (`logs/mutation_M1.txt:14`) |
| M2 | run's `loop_mode` → `LOOP_NONE` | **exit 1**, 2 fail | check 3 (`logs/mutation_M2.txt:14`) |
| M3 | run's first frame key → 16, `hframes × vframes` | **exit 1**, 2 fail | check 4 (`logs/mutation_M3.txt:14`) |
| M4 | `game/.godot` deleted, then `--import` | exit 0, 51 PASS | nothing, as predicted |

**Why M4 does not fail.** The rig is keyed as resource text, not imported, so no clip, key or loop mode lives in the import cache. Only textures are imported, and checks 6 and 8 read their import settings after the fresh import.

## Fresh cache

This is M4. The read-back, run after deleting `game/.godot` and reimporting, gave 51 PASS (`logs/mutation_M4.txt:8`). The rig is not imported, so no importer setting holds a loop mode. `slash`'s `LOOP_NONE` is in `game/animations/rudy_animations.tres`, and check 3 read it after the reimport.

## State machine

- **The structure test:** read-back check 7 (`logs/test_rudy_clips_60fps.log:14`). The library holds exactly section 3's 13 clips, and exactly the names `_pick_clip()` can return. It is checked against the resource.
- **The state test:** `game/tests/test_rudy_states.tscn` at 60, **99 PASS** (`logs/test_rudy_states_60fps.log:7125`). It runs the real `Main`, with real input through `Input.parse_input_event`, in 20 scenarios.
  - Every clip plays from 0 on the tick its state is entered, showing its own pose (`:7019-7031`).
  - The run's first cell lasts 8 ticks in every run and sword run (`:7032-7033`).
  - **54 of the table's 58 transitions** are reached. The other 4 are listed with their reasons (`:7116`; `CHANGE-BRIEF.md`, Revision 6).

## Edges

`game/tests/test_rudy_edges.tscn`: **108 PASS at 60** (`logs/test_rudy_edges_60fps.log:6679`), and **66 PASS at 30**, at both tick offsets (`logs/test_rudy_edges_30fps.log:734`).
- **The phase boundaries** are tick 2 (startup to active), 11 (active to recovery) and 17 (the end).
- **Inputs before, on and after each boundary:**
  - E1, a re-press of J, on ticks 1, 2, 3; 10, 11, 12; 16, 17, 18. It is ignored on ticks 1–17, and tick 18 starts a new swing from clip time 0.
  - E3, a hit, on ticks 1, 2, 3; 10, 11, 12; 16. It ends the swing on its tick in every phase. Tick 17 has no swing left to end.
- **An interrupt in each phase:** a hit in startup, active and recovery (E3). Also:
  - a jump on ticks 1, 5 and 12 (E2);
  - a turn in the active phase (E5);
  - a pause in the active phase (E6);
  - run, slash, run (E4).
- **A limit of the method.**
  - At 30 fps, a re-press read on swing tick 1 in a frame's second tick cannot follow a swing whose own J was read in the frame's first tick: the two merge into one press, which starts the swing (swing M, measured).
  - So swing tick 1 is tested in the first slot instead, in a swing whose own J is read in the second (`sessions/session-10-answer.md:131`, `:160`, `:205`).

## Frame strips (fixture)

These are fixture captures of `game/previews/`, not of the running game. Claude Code ran them, at my request, not as the text has it. `TUNING.md` records each.

| Strip | Commit | Folders |
|---|---|---|
| r0, the keys as first committed | `c70c8367` | `captures/slash/r0/`, `captures/slash/r0-second-tick/`, `captures/run/r0/`, `captures/run/r0-sword/` |
| r1, Grip eases out from 5/60, kept | `66103310` | `captures/slash/r1/`, `captures/slash/r1-second-tick/` |

## The cycle seam (HUMAN CHECK)

The text: "The looping clip played through at least five wraps at normal speed: no stutter, no duplicated frame, no jump."

**Done, by me.** 2026-11-16, my words, for the four human checks together:

> 我亲手做过了。循环接缝没问题。实际玩也没问题。对位正常，背景正常。

Claude's translation: "I did them myself. The cycle seam: no problem. Actual play: no problem too. Registration is normal, the background is normal."

My words for this check: "循环接缝没问题" ("the cycle seam: no problem"). They do not say how many wraps I watched, or which form I watched: the plain run, the sword run, or both.

## The action in play (HUMAN CHECK)

The text: "The committing action triggered by normal play many times, including an interrupt in each phase; the startup, active and recovery phases read as distinct."

**Done, by me** (my words are under "The cycle seam" above). My words for this check: "实际玩也没问题" ("actual play: no problem too"). They do not say which interrupts I tried in which phase. Earlier, on the preview, I had said that the three phases are distinct (`TUNING.md`, r0).

## Registration (HUMAN CHECK)

The text: "The frame strip of the cycle: the character does not drift within its cells." The strips are `captures/run/r0/` and `captures/run/r0-sword/`, frames 30–41.

**Done, by me** (my words are under "The cycle seam" above). My words for this check: "对位正常" ("registration is normal").

The headless log shows his origin at screen (960, 840) and his soles at y 840 on every frame (`logs/run_preview_r0.log`). That is the log, not a look at the cells.

## Against the background (HUMAN CHECK)

The text: "Both clips over the darkest and lightest stretch of real level art they can appear on."

**Done, by me** (my words are under "The cycle seam" above). My words for this check: "背景正常" ("the background is normal"). They do not name the stretches I looked at.

## Two clocks

Both clips advance on the physics tick, and so does the gameplay they are read against. Measured:
- **The clip.** The `AnimationPlayer`'s `callback_mode_process` is 0, physics (`game/content/rudy/rudy.tscn:76`; read-back check 5).
- **Gameplay.** `_swing()` runs in `rudy.gd`'s `_physics_process`. It reads `_slash_clock`, decides the hitbox from it, then advances it (`game/content/rudy/rudy.gd:246-258`).
- **At 60 fps.** On every swing tick of the state test, the clip's position equals (ticks since the press)/60 (`logs/test_rudy_states_60fps.log:7088` and on). The hitbox is live on swing ticks 2–10 exactly, the ticks of the clip's active keys.
- **At 30 fps, at both offsets.** The same holds (`logs/test_rudy_edges_30fps.log:665` and on). That log samples the swing clock after it has advanced, so it reads (tick + 1)/60 there.
- **The largest disagreement is 0 s.** The clip shows tick N, and the hitbox is decided on tick N.
- **Left on the idle callback,** the clip would have trailed by a tick at 60, 16.7 ms, and by up to a rendered frame at 30, 33.3 ms (`evidence/brief-probe/logs/anim_clock_idle_30fps.log:7-13`).

## Claude against you

- **r0, the catch.**
  - My first verdict: "剑扫过去没有卡一下". Claude's translation: "the sword does not catch as it sweeps across".
  - Claude's reading of frames 32 and 33: a near-stop. The blade turns 53° and then 5°.
  - We disagreed. Claude's reading drove round r1, and I approved the change it proposed.
- **r1, the settle.** Claude read frames 34–35 as a settle, not a new catch. I kept the change after playing at `--time-scale 0.25`, and said nothing either way about a settle or a catch.

The readings are in `sessions/session-18-answer.md` and `sessions/session-18c-answer.md`. My verdicts are in `TUNING.md`.

## What no headless run shows

A passing headless suite shows four things:
- the clips are structured as the brief says;
- every track resolves;
- the state machine plays them on the right states;
- the hitbox and the clip agree tick by tick.

It does not show whether the motion reads, whether the cycle wraps without a visible seam, or whether the action feels committed. Those are the human checks above. Claude's readings of the strips are claims.

## Still open

- **The observation-driven revision the text asks for.** Round r1 was driven by Claude's reading, not by something I saw (`TUNING.md`).
