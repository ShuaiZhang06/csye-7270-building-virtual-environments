# CHANGE-BRIEF — Assignment 7: a sprite run cycle and a cutout-rig sword slash for Rudy

**Revision 1 — 2026-11-12, committed before the first prompt.** Later changes are added as dated revisions at the end; this revision stays as it is.

**How this brief was made:** Claude Code (Claude Opus 5.5) drafted all of it from the assignment, Chapters 10 and 11, this folder's files and the probes in `evidence/brief-probe/`. That includes the design, the tables, the rules, the predictions and the key values.

**The assignment text.** Canvas shows Assignment 7 only as a revision note on an existing assignment. The note keeps several parts "as written" (the pin-first discipline, the state machine, the edges and re-pins) without including them. On 2026-11-12 I decided that the text it revises is the course repository's animation assignment, `assignments/08-animation-and-state.md` on `main`; I think the Canvas page was posted without that body by mistake. An earlier draft of the same note, `assignments/course-briefs/07-doing-animation.md` in the course's `walker-claude` repository (commit `48c6177ed`), bears this out: it opens by saying the first review measured the assignment "against wiring animation to player actions", the subject of that file. So this brief works to that file as changed by the note, and where the two differ, the note holds. Each requirement below comes from one of those two texts or from the chapters they assign (Chapters 10 and 11); anything else is marked as a choice of this brief.

The choices are mine: on 2026-11-12 I chose
- the run cycle as the looping sprite clip;
- the sword slash as the committing action, on a cutout rig;
- Rudy's own Assignment 2 frames as the sprite source, rather than a found sheet or the course sprite set (whose path the assignment text leaves as a placeholder);
- to keep the slash's gameplay timing as it is.

I reviewed the brief before committing it. The key values are a first design; the tuning loop exists to change them, with a revision here each time.

`CLAUDE.md` is still empty. Every prompt the assignment supplies begins "Read CLAUDE.md first", so it is written before the first prompt, and it imports this file (`@CHANGE-BRIEF.md`), which makes this brief the contract the agent works to.

This folder holds one Godot project, `game/`, copied from tag `a6`. The course's commands say `godot/`; here they say `game/`. New game files go in `game/content/rudy/` (the sheet, the rig parts, the animation library) and `game/tests/`. Design-time scripts go in `tools/` in this folder, outside the game. Frame strips go in `captures/<clip>/r<N>/`.

## 0. The four ideas this change rests on

1. **An animation is tracks of keys.** Every clip here is a list of tracks, each a node path and a property with keyed values. A wrong path or a wrong number still loads, so a test reads the clip back.
2. **One authority.** `rudy.gd` alone decides Rudy's state, as it does now. One `AnimationPlayer` alone writes what he looks like. No code sets his sprite's texture or frame, and nothing plays a clip on its own.
3. **Two clocks.** Gameplay runs on physics ticks; an `AnimationPlayer` runs on rendered frames unless it is told otherwise. Here it is told: both run on the physics tick, and the brief records where they could still part.
4. **Feel designed in frames.** The slash is designed as startup, active and recovery ticks, taken from the gameplay timing the game already has. The run is designed as a two-cell cycle with a stated seam. The keys come from those tables, and play decides whether the tables are right.

## 1. The state

- **Engine and renderer.** Godot 4.7.2 (`logs/checks_60fps.log:1`), GL Compatibility (`game/project.godot:16`, `:95-96`). The viewport is 1920 × 1080 with `canvas_items` stretch, in a 1280 × 720 window (`game/project.godot:25-29`).
- **Physics ticks per second: 60.** `game/project.godot` sets none, so the default holds (`evidence/brief-probe/logs/slash_ticks_60fps_frame.log:3`).
- **No animation nodes yet.** No scene or script in `game/` names `AnimationPlayer`, `AnimationTree`, `AnimatedSprite2D`, `Skeleton2D` or `Bone2D` (checked with grep on 2026-11-12).
- **Where Rudy's state lives.** In `game/content/rudy/rudy.gd`, as physics plus a mode:
  - `mode` (`rudy.gd:40-48`): `WAITING`, `PLAY`, `HURT`, `DEFEATED`, `FALLEN`, `RESPAWNING`, `CELEBRATING`;
  - `gear` (none or sword), `is_on_floor()`, `velocity`, and the swing clock `_slash_clock` (`rudy.gd:92`, `:116-117`).

  Every physics tick, `_physics_process` (`rudy.gd:198-234`) moves him, runs `_swing()` and then `_pick_pose()` (`rudy.gd:285-311`). That is a priority list, like `visual_animation()` in walker-jumpman-clawd (Chapter 11), and it returns a pose's asset ID. `_look.show_pose(pose)` (`rudy.gd:234`) then sets the Sprite's texture to that pose's PNG (`game/content/rudy/rudy_look.gd:39-46`). There are no transitions and no cross-fades: every change is a cut on the tick its condition changes.
- **The run today.** `_run_clock` (`rudy.gd:84`) counts up while he runs on the floor. With `run_frame_time` 0.125 s (`rudy.gd:61`) he shows `RUN-A`, then `RUN-B`, and so on (`rudy.gd:306-309`). The clock is reset in the air and when he stands (`rudy.gd:299`, `:310`). It is neither reset nor advanced during a swing (`rudy.gd:295-296`), so a run resumes its phase after a slash.
- **The slash today, measured** (`evidence/brief-probe/logs/slash_ticks_60fps_frame.log:4-21`). Tick 0 is the tick the press is read:

  | Ticks | Pose | Hitbox | Why |
  |---|---|---|---|
  | 0–1 | `CHAR-SWORD-SLASH` | dead | the clock is below `slash_live_from` 0.03 s when `_swing()` reads it (`rudy.gd:67`, `:241`) |
  | 2–10 | `CHAR-SWORD-SLASH` | **live**, 9 ticks (0.15 s) | 2/60 s to 10/60 s lie within 0.03–0.18 s (`rudy.gd:67-68`) |
  | 11–16 | `CHAR-SWORD-SLASH` | dead | past `slash_live_to` |
  | 17 | `CHAR-SWORD-IDLE` | dead | the clock reaches `slash_time` 0.3 s on this tick's increment, and the swing ends on the same tick (`rudy.gd:248-251`) |

  So the swing is on screen for **17 ticks (0.283 s), not 18.** A press is ignored while a swing is under way (`rudy.gd:223`), including on tick 17, because the press is read before `_swing()` ends the swing. The earliest next swing is read on tick 18.
- **What cancels a swing.** A hit (`rudy.gd:143`), a fall out of the level (`rudy.gd:168`), a respawn (`rudy.gd:182`) and the teleport circle (`rudy.gd:195`). Jumping and moving do not. Turning does not either: `facing` changes mid-swing (`rudy.gd:204-208`), so the hitbox and the look flip with him (`rudy.gd:231`, `:240`).
- **Rudy's frames** (`game/content/rudy/frames/frames.json`):
  - 16 PNGs, each on a 410 × 386 canvas, with the body origin (his soles, on the torso line) at texture pixel (205, 370);
  - stored at density 2: 2 texture px per game px. The Sprite draws them at scale 0.5, `centered` off, offset (−205, −370) (`game/content/rudy/rudy.tscn:27-32`);
  - with the 4 px outline material (`game/systems/art/outline.gdshader`, width 8 texture px) and linear mipmap filtering.

  Every frame keeps at least 16 texture px of transparent margin on each side (`evidence/brief-probe/logs/frame_margins.log:17`), so neither the outline nor a mipmap reaches a neighbouring cell when they share a sheet.
- **What the existing tests read of his look** (`game/tests/checks.gd`):
  - `Rudy.pose` as an asset ID in many checks, including the run's `RUN-A`/`RUN-B` trail (`checks.gd:172-173`), the air poses (`:197-198`, `:301`, `:310`) and the slash (`:727-733`);
  - `RudyLook.FRAMES` and `RudyLook.frame()`, compared on every tick (`checks.gd:129-131`);
  - the frames manifest, the Sprite's offset, scale and centring, and its filter and outline (`checks.gd:848-878`);
  - that every pose but the block showed its own frame (`checks.gd:879-886`).

  These existing checks are tied to today's texture swap. They are earlier tests, so they keep passing unchanged (section 5).
- **How the existing tests press keys.** `checks.gd` uses `Input.action_press` (`checks.gd:167` and on). New tests use `Input.parse_input_event` with the project's physical keys: D (move right), A (move left), Space (jump), J (slash) (`game/project.godot:33-68`). `action_press` never reaches `_input` or `_unhandled_input`; `parse_input_event` goes the way a real key does. A probe press of J through `parse_input_event` was read as `slash` on the next physics tick (`evidence/brief-probe/logs/slash_ticks_60fps_frame.log:4`).

## 2. The animation set

The assignment's minimum is two clips, one sprite and one rig. One must loop and one must be a committing action, and at least one is driven by the player's state machine. Here both are Rudy's, and both are driven by his state machine.

| Clip | Role | Route | Source | Driven by |
|---|---|---|---|---|
| `run`, `sword_run` | **The looping sprite clip** | `Sprite2D` with an `AnimationPlayer` frame track | Rudy's run frames, packed into a sheet | `rudy.gd`'s state |
| `slash` | **The committing action, on a rig** | Cutout rig keyed as resource text | Parts cut from `CHAR-SWORD-SLASH.png` | `rudy.gd`'s state |

The state machine needs more states than these two clips (section 3). Each other state gets a **one-key clip** on the same `AnimationPlayer`, keying the Sprite's frame to that pose's cell. Those are not part of the two-clip set: they replace today's texture swap, so that one player draws everything.

All clips live in one `AnimationLibrary`, `game/content/rudy/rudy_animations.tres`, written as resource text so that every key is readable in a diff. The `AnimationPlayer` is a child of `Rudy/Look`, with `root_node` left at `..` (its parent, `Look`; `evidence/brief-probe/logs/godot3_names_resource.log:5`). Its settings:
- `callback_mode_process` physics (section 4);
- `autoplay` empty;
- `speed_scale` 1.0.

### 2.1 Clip 1 — the run cycle (sprite, loops)

**Route:** `Sprite2D` with an `AnimationPlayer` frame track. The sheet is sliced with `hframes` and `vframes`, and the clip keys `frame`.

**Source and terms.** Rudy's frames were generated in Assignment 2 with the Gemini app's image generation, under Google's Terms of Service and Generative AI Additional Terms (`../assignment-2/SOURCES.md:33`), and follow Assignment 2's rules for generated art.
- The accepted originals are `../assignment-2/generated/accepted/CHAR-*.jpg`.
- `../assignment-2/design/tools/matte_sprites.py` made the game frames in `game/content/rudy/frames/` from them.

They have been in this repository, which is public, since Assignment 2 (the `shuai-z/assignment-2` branch), and they appear in the films of Assignments 2, 5 and 6. The editable sources are those originals and the frames themselves. Both are committed and stay unedited. No found sheet and no third-party licence is involved. SOURCES.md records this again for Assignment 7.

**The sheet** is `game/content/rudy/sheet/rudy_sheet.png`, made by `tools/pack_rudy_sheet.py` from the 16 game frames, with no scaling and no edits:
- **cell** 410 × 386 px, no padding;
- **grid** 4 columns × 4 rows (`hframes` 4, `vframes` 4), 1640 × 1544 px;
- **frame order** row by row, in `frames.json` order:

| Cell | Pose | Cell | Pose | Cell | Pose | Cell | Pose |
|---|---|---|---|---|---|---|---|
| 0 | `CHAR-IDLE` | 4 | `CHAR-FALL` | 8 | `CHAR-CELEBRATE` | 12 | `CHAR-SWORD-RUN-A` |
| 1 | `CHAR-RUN-A` | 5 | `CHAR-HURT` | 9 | `CHAR-SWORD-IDLE` | 13 | `CHAR-SWORD-RUN-B` |
| 2 | `CHAR-RUN-B` | 6 | `CHAR-DEFEAT` | 10 | `CHAR-SWORD-SLASH` | 14 | `CHAR-SWORD-RISE` |
| 3 | `CHAR-RISE` | 7 | `CHAR-RESPAWN` | 11 | `CHAR-SWORD-BLOCK` | 15 | `CHAR-SWORD-FALL` |

- **The last cell is 15.** A frame key of 16 or more points outside the sheet.
- **The packing script asserts** that each cell equals its source PNG pixel for pixel, and prints the sheet's SHA-256.
- **The sheet imports with mipmaps** (`mipmaps/generate=true`), like the frames (`game/content/rudy/frames/CHAR-IDLE.png.import`).
- **The Sprite keeps** its offset (−205, −370), its scale 0.5, `centered` off, the outline material and the filter it inherits from `Look`. With `hframes` and `vframes` set, each cell is drawn where its frame was drawn.

**Registration.** Every frame puts the body origin at texture pixel (205, 370) (`frames.json`), so the body origin sits at the same place in every cell. The check is the frame strip: his soles stay on the walk line in every cell, and the run's two cells do not jump against each other.

**The cycle:**

| | `run` | `sword_run` |
|---|---|---|
| Cells | 1 (`RUN-A`) at 0.0 s, 2 (`RUN-B`) at 0.125 s | 12 (`SWORD-RUN-A`) at 0.0 s, 13 (`SWORD-RUN-B`) at 0.125 s |
| Cell rate | 8 cells/s: 0.125 s per cell, today's `run_frame_time` (`rudy.gd:61`) | the same |
| `length` | 0.25 s | 0.25 s |
| Update mode | `UPDATE_DISCRETE` | `UPDATE_DISCRETE` |
| `loop_mode` | `LOOP_LINEAR` | `LOOP_LINEAR` |

- **The seam rule for a frame track.** There is no duplicate across the wrap: the last key is B and the first is A. The gap from the last key to `length` (0.25 − 0.125) equals the key interval (0.125).
- **Ticks per cell.** At 60 ticks/s a cell lasts 7.5 ticks, so cells alternate 8 and 7 ticks (`evidence/brief-probe/logs/anim_run_discrete_60fps.log:8-31`), much as today's clock does.
- **Restart.** The run plays from `RUN-A` whenever he enters it from any other state. Today's run restarts from A after standing and after the air, but resumes its phase after a slash (section 1). The new clip restarts from A after a slash too. **That is the one intended change to the run's timing.** The pin records today's resume, and the re-pin records the restart, after I have played it.
- **One source for the timing.** `run_frame_time` and `_run_clock` leave `rudy.gd`; the clip's keys become the only source of the run's timing. No existing test reads either of them.

### 2.2 Clip 2 — the slash (cutout rig, commits)

**Route:** cutout rig keyed as resource text. The agent writes the keys directly in `rudy_animations.tres`.

**Rig source.** `tools/cut_slash_rig.py` cuts parts from `game/content/rudy/frames/CHAR-SWORD-SLASH.png`, whose provenance is that of section 2.1. The parts go in `game/content/rudy/rig/`, each on the same 410 × 386 canvas with the same origin, so that at rest they register exactly on the original frame:
- `slash_body.png`: the frame without the blade and without the translucent arc. Where the arc crosses the robe and the shield, the script repairs the pixels from the surrounding robe and shield.
- `slash_blade.png`: the blade and crossguard, from the fist outwards.
- `slash_arc.png`: the translucent arc alone.

The script measures and prints the grip point (the centre of the fist around the hilt, near texture pixel (258, 165)). It checks that the three parts, composited at rest, equal the original frame except inside the repaired band, and it prints the size of that band. The parts are a derivative of my own generated art. The original frame stays as it is, and the script and the parts are committed as the rig's editable source.

**Rig nodes**, all under `Rudy/Look`, so they flip with `facing` and flash with the invulnerability fade as the Sprite does:

```text
Look
├── Sprite            Sprite2D, the sheet; hidden during the slash
├── SlashRig          Node2D, visible only during the slash
│   └── Lean          Node2D, pivot at his soles (0, 0); keyed position and rotation_degrees
│       ├── Grip      Node2D, pivot at the grip point; keyed rotation_degrees
│       │   └── Blade Sprite2D, slash_blade.png, drawn BEHIND Body
│       ├── Body      Sprite2D, slash_body.png
│       └── Arc       Sprite2D, slash_arc.png; keyed modulate:a; no outline material
└── AnimationPlayer
```

- **Draw order.** Blade comes before Body in the tree, so the fist covers the hilt and the blade's outline does not cross his hand.
- **Materials.** Body and Blade use the outline material; Arc does not, as the faint trail has none today (`outline.gdshader:8-9`).
- **Sprite settings.** Every part keeps the Sprite's offset and scale, so its canvas origin sits on Rudy's origin. Blade is offset from the Grip pivot so that, at Grip 0°, it sits where it was drawn.

**The phase table.** Frames are physics ticks at 60 per second, and tick 0 is the press tick. This is today's gameplay timing (section 1), which this change keeps. The clip's frame rate is 60, so a key's time is its tick divided by 60. The clip starts on tick 0, because the player is always playing a state clip when the slash starts (section 4).

| Phase | Ticks | Clip time | Hitbox (gameplay, unchanged) | What the rig does |
|---|---|---|---|---|
| **Startup** | 0–1 | 0 – 2/60 s | dead | The blade is raised back over his shoulder (Grip −70° → −60°) and his weight sits back (Lean −2°). Two ticks: at 30 fps one rendered frame, so the wind-up reads as one held pose |
| **Active** | 2–10 | 2/60 – 11/60 s | **live** | The blade sweeps forward and down, accelerating: Grip −60° → 0° (the drawn angle) at tick 5 → +45° at tick 11. He leans into it (Lean +3°, x +6 px by tick 5). The arc appears at tick 2 (α 0 → 1 by tick 4) and fades by tick 11 |
| **Recovery** | 11–16 | 11/60 – 17/60 s | dead | The blade settles back: Grip +45° → +15°, decelerating. Lean returns to 0°, x 0 |
| **End** | 17 | 17/60 s | the swing ends (`rudy.gd:250-251`) | The clip's `length` is 17/60 s (0.2833 s). The state leaves `slash` on this tick, a cut to the sword form's idle, run or air pose |

**Keys at every phase boundary.** Key times are 0, 2/60, 5/60, 11/60 and 17/60 s, on these tracks:

| Track | 0 | 2/60 | 5/60 | 11/60 | 17/60 | Transitions |
|---|---|---|---|---|---|---|
| `Look/Sprite:visible` (discrete) | false | | | | | |
| `Look/SlashRig:visible` (discrete) | true | | | | | |
| `Look/SlashRig/Lean/Grip:rotation_degrees` | −70 | −60 | 0 | 45 | 15 | ease-in (accelerating) into the active keys; ease-out (settling) from 11/60 |
| `Look/SlashRig/Lean:rotation_degrees` | −2 | −2 | 3 | 3 | 0 | ease-out from 11/60 |
| `Look/SlashRig/Lean:position` | (0, 0) | (0, 0) | (6, 0) | (6, 0) | (0, 0) | ease-out from 11/60 |
| `Look/SlashRig/Lean/Arc:modulate:a` | 0 | 0 | 1 (at 4/60) | 0 | 0 | linear |

- **Visibility.** Every other state clip keys `Sprite:visible` true and `SlashRig:visible` false at time 0, so leaving the slash on any tick shows the Sprite again.
- **Loop and positive angles.** `loop_mode` is `LOOP_NONE`. Positive angles turn clockwise on screen (y points down), so +45° points the blade forward and down.
- **The agent's key table.** The agent lists every key time beside the tick it comes from.

**Interrupts by phase.** These are unchanged gameplay rules, and the clip follows them:

| Event | Startup | Active | Recovery |
|---|---|---|---|
| Slash pressed again | ignored: no new swing, the clip is not restarted | ignored | ignored, including on tick 17 |
| Jump pressed on the floor | he jumps; the swing plays on in the air | the same | the same |
| Move or turn | he moves or turns; the rig flips with `Look` on the tick he turns | the same | the same |
| A hit (with the sword, it always knocks the sword away) | the swing ends on that tick: hurt clip, Sprite shown, rig hidden, hitbox dead | the same | the same |
| Fall out, respawn, teleport circle | the swing ends on that tick | the same | the same |
| Pause | the clip freezes with the tree; it goes on from the same point on resume | the same | the same |

## 3. The state machine

**Wiring: the existing priority list stays the single authority.** `rudy.gd` keeps choosing his state every physics tick with today's priorities, but the choice is now a clip name, not an asset ID. `RudyLook` plays that clip when it differs from the one playing. I chose this over an `AnimationTree`:
- **One authority.** The selector already is it. A tree with its own transitions would be a second machine that could disagree with it (Chapter 11).
- **No sampling gap.** The selector runs on every physics tick, so the gap Chapter 11 found between physics ticks and tree updates cannot open.
- **Nothing to blend.** There is nothing to cross-fade between whole frames.

Its weakness is the one Chapter 11 names for walker-jumpman-clawd: every change is a cut.

**The restart rule.** `play()` with the name already playing does not restart it (`evidence/brief-probe/logs/anim_clock_physics_60fps.log:13-14`). A new swing always follows at least one tick of another state (section 1), but `RudyLook` still starts every new swing with `play("slash")` and `seek(0.0, true)`, so the rule never rests on that gap.

**What keeps its meaning,** so that the existing checks pass unchanged:
- `Rudy.pose` is the asset ID of the pose on screen, read after the tick's animation update: the cell's pose while the Sprite shows, and `CHAR-SWORD-SLASH` while the rig shows.
- `RudyLook.FRAMES` maps every asset ID to its original PNG.
- `RudyLook.frame()` returns the original PNG of the pose on screen. During the slash that is `CHAR-SWORD-SLASH.png`, the frame the rig is cut from.

**The states.** Higher in the table wins, as in `_pick_pose()` today:

| # | State (clip) | Shows | Entered when | Loops | Cross-fade |
|---|---|---|---|---|---|
| 1 | `celebrate` | cell 8 | `mode` is `CELEBRATING`: on the teleport circle (`rudy.gd:193-195`) | one key, `LOOP_LINEAR` | none, a cut |
| 2 | `respawn` | cell 7 | `mode` is `RESPAWNING`, for `respawn_time` 0.7 s (`rudy.gd:177-190`) | one key, linear | cut |
| 3 | `defeat` | cell 6 | `mode` is `DEFEATED`: a hit took his last heart (`rudy.gd:147`) | one key, linear | cut |
| 4 | `hurt` | cell 5 | `mode` is `HURT`, for `hurt_time` 0.35 s (`rudy.gd:151`) | one key, linear | cut |
| 5 | `slash` | the rig | `is_slashing()`: a fresh slash press with the sword, and no swing under way (`rudy.gd:223-226`) | `LOOP_NONE` | cut |
| 6 | `rise` / `sword_rise` | cell 3 / 14 | off the floor, and not in the falling pose's case below | one key, linear | cut |
| 7 | `fall` / `sword_fall` | cell 4 / 15 | off the floor, falling (`velocity.y` ≥ 0), and moving sideways when the fall began (`rudy.gd:298-304`) | one key, linear | cut |
| 8 | `run` / `sword_run` | cells 1–2 / 12–13 | on the floor, `absf(velocity.x)` > 1 (`rudy.gd:306-309`) | `LOOP_LINEAR` | cut |
| 9 | `idle` / `sword_idle` | cell 0 / 9 | otherwise, including `WAITING` on the title | one key, linear | cut |

- **Air poses.** `FALLEN` (below a cliff) shows the air states by rule 6 or 7.
- **Forms.** States 6 to 9 use the sword form's clip while `gear` is the sword.
- **Single-key clips loop.** They loop so that the player never stops: a `play()` on a stopped player shows its first key one tick late (`evidence/brief-probe/logs/anim_clock_physics_60fps.log:7-8`, against `:26-28`).
- **Cuts everywhere.** Whole frames cannot cross-fade, and the rig appears and disappears on a tick, so every transition is a cut on the tick its condition changes, as today.

**Every transition out of every state**, written before reading the agent's list:

| From | To | When |
|---|---|---|
| `idle` | `run` | a direction is held: at once if he faces it, after `turn_hold_time` 0.12 s if it turns him (`rudy.gd:204-215`) |
| | `rise` | a fresh jump press on the floor (`rudy.gd:219-222`) |
| | `slash` | a fresh slash press with the sword |
| | `hurt` / `defeat` | a hit; `defeat` if it took his last heart (only without the sword) |
| | `celebrate` | he reaches the teleport circle |
| `run` | `idle` | no direction held and he has slowed to `absf(velocity.x)` ≤ 1 (0.1 s from full speed, `rudy.gd:56`), or he turns on the ground (`velocity.x` is set to 0 at once, `rudy.gd:206-207`) |
| | `rise` | a fresh jump press |
| | `fall` | he runs off a ledge: falling, and moving sideways |
| | `slash`, `hurt`, `defeat`, `celebrate` | as from `idle` |
| `rise` | `fall` | at the top, if he was moving sideways when the fall began |
| | `idle` / `run` | he lands |
| | `slash`, `hurt`, `defeat` | as from `idle` |
| | `respawn` | after a fall out of the level, when `Main` respawns him (`game/app/main.gd:128`) |
| `fall` | `idle` / `run` | he lands |
| | `slash`, `hurt`, `defeat`, `respawn` | as from `rise` |
| `slash` | `sword_idle` / `sword_run` / `sword_rise` / `sword_fall` | the swing ends on tick 17, to whichever his physics says |
| | `hurt` | a hit, in any phase (`rudy.gd:143`). Never `defeat`: with the sword, a hit takes the sword, not a heart |
| | `sword_rise` / `sword_fall` | a fall out of the level (`rudy.gd:166-168`): the swing ends, and he keeps the sword until the respawn takes it (`rudy.gd:181`) |
| | `respawn`, `celebrate` | as for any state (`rudy.gd:182`, `:195`) |
| `hurt` | `idle` / `run` / `rise` / `fall` | `hurt_time` ends (`rudy.gd:263-268`); `defeat` cannot follow, since he is invulnerable for 1.2 s |
| | `rise` / `fall` | he falls out of the level during the knockback |
| `defeat` | `respawn` | `Main` starts the level over (`main.gd:128`) |
| `respawn` | `idle` (then `run` if a direction is held) | `respawn_time` ends (`rudy.gd:270-273`) |
| `celebrate` | none | the end card follows; Enter reloads the scene |

**The committing action.** Once a slash starts, it plays to tick 17 unless one of the events in section 2.2's interrupt table ends it: a hit, a fall out, a respawn or the circle. No input cancels it.

## 4. Two clocks

- **Gameplay** runs in `rudy.gd`'s `_physics_process`, 60 ticks/s, and the hitbox stays there: `_swing()` reads `_slash_clock` (`rudy.gd:239-251`). **No animation key decides a gameplay fact.** The clip only draws; the hitbox, the slash sound (`rudy.gd:226`) and Effect A's sparks (which watch `SwordHitbox/Shape.disabled`, `game/effects/effects_driver.gd`) stay as they are.
- **The `AnimationPlayer`'s `callback_mode_process` is physics (0), set in the scene,** not the default idle (1) (`evidence/brief-probe/logs/anim_clock_physics_60fps.log:3`). In physics mode the clip time is (ticks since `play()`)/60 at 60 fps and at 30 fps alike (`anim_clock_physics_30fps.log:9-13`). In idle mode at 30 fps it advanced once per rendered frame, in uneven steps (0, 0.0292, 0.0592 s; `anim_clock_idle_30fps.log:7-13`): a second clock that would let the rig's active keys drift off the live ticks.
- **Order within a tick.** The player is a child of `Look`, which is a child of `Rudy`, and in the probe a child's physics processing ran after its host's `_physics_process` on the same tick. So a `play()` from `rudy.gd` on tick 0 shows the clip's first key on tick 0, provided the player was already playing (`anim_clock_physics_60fps.log:27-28`).
- **Method callbacks** stay deferred (the default, 0). No clip has a method track, so nothing depends on when a method key runs.
- **No `AnimatedSprite2D`** is used, so no second sprite clock exists.
- **The rendered frame.** Tests run at `--fixed-fps 60`: one tick per frame. Movie Maker captures run at 30 fps: two ticks per frame, and each PNG shows the state after the frame's second tick.

## 5. Boundaries

- **Unchanged, as the assignment requires** ("What must not change"):
  - movement tuning (`rudy.gd:54-63` except `run_frame_time`);
  - collision shapes (`Body` and `SwordHitbox`, `rudy.tscn`);
  - input actions (`game/project.godot`'s input map);
  - the Assignment 2 audio and its calls;
  - the particle effects (`game/effects/*`, `main.tscn`'s effects nodes), which the course text calls "your Assignment 7 effects" in its older numbering;
  - earlier tests (below).
- **Also unchanged, by this brief's choice:**
  - every gameplay timing (`slash_time` 0.3 s and the live window 0.03–0.18 s, `hurt_time`, invulnerability, respawn), and when a swing ends or is cancelled. That is my decision of 2026-11-12 to keep the slash's timing; the assignment allows timing changes if they are pinned, played and re-pinned;
  - the goblins, the level, `Main`, the HUD and `game/systems/*` (the outline material is reused, not changed), because the change is Rudy's animation only;
  - the rest of `game/project.godot`.
- **Earlier tests pass unchanged, with the same counts:**
  - `checks.tscn`: 141 at 60;
  - `invulnerable_tint_checks.tscn`: 15 at 30, 60 and 144;
  - `test_slash_sparks_config.gd`: 108 checks;
  - `test_slash_sparks_state.tscn`: 14;
  - `test_run_dust_config.gd`: 61 checks;
  - `test_run_dust_state.tscn`: 14 (`logs/`).

  New tests go beside them. A FAIL in an earlier test is classified, never edited away.
- **What may change:**
  - `rudy.tscn`: `Look` gains the `AnimationPlayer` and `SlashRig`; the Sprite's texture becomes the sheet, with `hframes` 4 and `vframes` 4 and the same offset, scale, centring, material and filter.
  - `rudy_look.gd`: it plays clips instead of setting textures, keeping `FRAMES`, `frame()` and the pose on screen.
  - `rudy.gd`: the selector returns a clip name; `run_frame_time` and `_run_clock` go; `pose` reads the pose on screen.
  - New files: the sheet, the rig parts, `rudy_animations.tres`, `tools/*.py`, and the tests.
- **One authority, in rules:**
  - The `AnimationPlayer` is the only writer of `Look/Sprite:frame`, `Look/Sprite:visible`, `Look/SlashRig:visible` and the rig parts' keyed properties.
  - No code sets the Sprite's `texture` or `frame`; the texture is the sheet, in the scene.
  - `rudy.gd` is the only caller of the clip changes, through `RudyLook`.
  - `autoplay` is empty.

## 6. Edges

| # | Edge | Intended behaviour | Tested at |
|---|---|---|---|
| E1 | **Slash requested during a slash**, at every phase boundary: presses read on ticks 1, 2, 10, 11, 16 and 17 | Ignored. No new swing, no second slash sound, the clip position keeps counting, and the hitbox is live on ticks 2–10 only. A press read on tick 18 starts a new swing from clip time 0: the blade travels again (Grip −70° → +45°, at least 100°), and the hitbox is live on its ticks 2–10 | 60 fps; and 30 fps at both tick offsets |
| E2 | **Jump during a slash** (an action during another action), pressed on ticks 1, 5 and 12 of a swing on the floor | He jumps on that tick, and the slash plays to its end in the air with its hitbox ticks unchanged. Landing during the swing does not cut it. After tick 17 he shows `sword_rise` or `sword_fall`. **My decision:** the swing does not hang the jump, unlike Chapter 10's finite-state-machine demo | 60; 30 at both offsets |
| E3 | **Hit during a slash**, a goblin's touch in startup, active and recovery | On the hit's tick: the swing ends, he shows `hurt`, the rig is hidden and the Sprite shown, the hitbox is dead, and no further sparks start | 60 |
| E4 | **Run, slash, run**, holding right throughout | The slash shows at once over the run. After tick 17, `sword_run` restarts at `SWORD-RUN-A` (the intended change; the pin records today's resume) | 60 |
| E5 | **Turn during the active phase** | On the turn's tick, the rig flips with `Look`, and the hitbox moves to his other side (`rudy.gd:240`). Neither the clip nor the hitbox window restarts | 60 |
| E6 | **Pause during the active phase** (Esc) | The clip position and the swing clock both freeze, and on resume both go on from the same tick | 60 |
| E7 | **Same action while it plays, on the run**: a direction tap during the run | The run is not restarted while it stays `run` | 60 |

- **The second tick offset at 30 fps.** A press sent at a rendered frame is read on the first of its two ticks. To read it on the second, the test awaits one `process_frame`, then one `physics_frame`, then sends the event with `Input.parse_input_event` and calls `Input.flush_buffered_events()` (`evidence/brief-probe/logs/slash_ticks_30fps_physics.log:6-9`, against `slash_ticks_30fps_frame.log:4-7`).
- **The mutation check** for each fixed edge runs the strengthened test on the pre-fix commit in a `git worktree`, outside this folder, and must fail there.

## 7. Timing predictions

| Quantity | Prediction |
|---|---|
| Physics ticks per second | 60 (default; `slash_ticks_60fps_frame.log:3`) |
| Test frame rate | `--fixed-fps 60` for pins, read-backs and state tests: 1 tick per frame. `--fixed-fps 30` for the edge reruns: 2 ticks per frame |
| Capture frame rate | Movie Maker at 30 fps: 2 ticks per PNG |
| The slash's active key (Grip −60°, at 2/60 s) | **observed on tick 2 after the press**, the same tick the hitbox goes live: frame 2 at 60 fps. At 30 fps, with the press on a frame's first tick, the frame of the press shows tick 1 (still wind-up), and the next shows tick 3 (active, Grip between −60° and −40°, by the ease-in). With the press on the second tick, the frame of the press shows tick 0 (wind-up), and the next shows tick 2 (the first active key) |
| The slash's last frame on screen | tick 16 (clip time 16/60 s, Grip between +15° and +20°, by the ease-out). Tick 17 shows the sword form's next pose |
| The run's first `RUN-B` | 8 ticks after the run starts: the key at 0.125 s is reached at 8/60 s. Cells then last 7 and 8 ticks in turn (`anim_run_discrete_60fps.log`). Today's code shows 7 ticks of `RUN-A` first, because its clock advances before it is read; the pin measures it |
| The swing's total | 17 ticks (0.283 s) on screen, as today; the clip's `length` matches it |

## 8. The motion reference

**What the assignment asks.** The course text asks for "a motion reference for at least one action: its source, frame rate, and the frame counts you measured", and for the counts to be compared with key times in play. The revision note puts measuring the reference first in the clip workflow and judges each clip's frame strip "against the motion reference". Neither says where the reference comes from. The instructor's own example for this assignment (`walker-claude`, `assignments/07-animation/CHANGE-BRIEF.md`) adds that students "supply their own measured reference" and that no motion reference is fabricated.

**The reference.** On 2026-11-12 I chose openly licensed footage over filming myself. Claude found three videos on Wikimedia Commons, downloaded them at my word, and counted their frames. The sources, licences, checksums, method and every frame number are in `evidence/motion-reference/README.md`. The counts are Claude's reading of the frames, and I checked them against the contact sheets on 2026-11-12.

| Reference | Source and licence | Frame rate |
|---|---|---|
| The swing | "IMG 8252" Hand-and-a-half sword (Bastard sword) exercises, by Kuroczynski, CC BY-SA 4.0 | 29.97 fps |
| The run | S1 and S3 Videos of Arellano, McDermott, Kram and Grabowski (2015), PLOS ONE, DOI 10.1371/journal.pone.0115637, CC BY 4.0: one runner from the side, at 3.0 and 9.0 m/s | 29.97 fps |

- **What was measured:**
  - the swing: frames of wind-up (from the blade leaving its guard to the moment it moves forward fast), of the fast strike, and of the follow-through until the blade settles;
  - the run: frames per step, from one foot's contact to the other's.
- **Predictions, written before the measurement:**
  - **The wind-up:** about 6–10 frames at 30 fps (0.2–0.33 s), far longer than the game's 2 ticks (0.033 s). The startup stays at 2 ticks by my decision (responsiveness, and no gameplay change); the reference informs the shape inside the phases, not their length.
  - **The strike:** 2–4 frames at 30 fps (0.07–0.13 s), close to the game's 9-tick active window (0.15 s).
  - **The follow-through:** 4–8 frames (0.13–0.27 s), against the game's 6 ticks (0.1 s).
  - **The run:** a jog at about 9–10 frames per step at 30 fps (0.3 s); Rudy's cells change every 0.125 s, so his cadence is about 2.4 × a jog and above a sprinter's 0.2–0.22 s per step. That is a cartoon cadence; whether it reads is my judgment in play.
- **Measured** (`evidence/motion-reference/README.md`):

  | | Reference | At 30 fps | The game, in this brief | Against the prediction |
  |---|---|---|---|---|
  | Wind-up | 0.500 s in all (frames 315–330): backswing 0.300 s, held cocked 0.100 s, turn forward 0.067 s | 15 frames | startup 2 ticks, 0.033 s | longer than predicted (6–10 frames). The backswing alone, 9 frames, is within it |
  | Strike | 0.200 s (frames 330–336); vertical to horizontal in the first 4 frames | 6 frames | active 9 ticks, 0.150 s | longer than predicted (2–4 frames) |
  | Follow-through | 0.133 s (frames 336–340) | 4 frames | recovery 6 ticks, 0.100 s | at the low end of the prediction (4–8 frames) |
  | Step at 3.0 m/s | 0.367 s, 2.72 steps/s | 11 frames | one run cell, 0.125 s | slower than the predicted jog (9–10 frames) |
  | Step at 9.0 m/s | 0.246 s, 4.1 steps/s | about 7.4 frames | one run cell, 0.125 s | slower than the predicted sprint (0.20–0.22 s) |

  The reference's swing is a two-handed cut with a hand-and-a-half sword, not a one-handed swing like Rudy's. The runs are on a treadmill. Their cadences match real runners at those speeds, so the videos play in real time.
- **What the numbers say about the keys,** for the strips and for play, not yet a change:
  - **Wind-up.** The game's 2-tick startup is 1/15 of the reference's wind-up, by my decision, so it can show only the reference's held, cocked pose. The rig holds the blade back over his shoulder from tick 0, rather than moving it back during the startup.
  - **Strike.** The game's active window is 3/4 of the reference's strike, which is close. The reference reaches horizontal two-thirds of the way through, which is tick 8 of the game's ticks 2–11. The drawn blade points about 30° above horizontal, so horizontal is Grip about +30°. With this brief's keys (0° at tick 5, +45° at tick 11, easing in), Grip passes it only around tick 9–10. If the slash strip reads late, the first tuning candidate is an earlier key in the active phase.
  - **Follow-through.** The game's 0.100 s recovery against the reference's 0.133 s: close.
  - **Run.** One run cell is a step, so Rudy steps every 0.125 s, half the time of the sprinter at 9.0 m/s and a third of the runner at 3.0 m/s. He reads as a fast scurry. Whether that suits a cartoon boy at 560 px/s is my judgment in play; a slower cell rate would be a TIMING change, pinned, played and re-pinned.

## 9. Tests and checks

**The pin, first.** `game/tests/test_rudy_pin.tscn` (scene, because `rudy.gd` names the `Sfx` autoload) pins today's behaviour before any animation change.
- **Input:** only `Input.parse_input_event` key events. It never calls Rudy's or `RudyLook`'s methods and never writes his state, velocity or position.
- **Stepping:** one physics tick at a time at `--fixed-fps 60`, through the wrapper.
- **Per-tick log:** tick, `mode`, `pose`, `velocity`, `is_on_floor()`, `_slash_clock`, the hitbox's `disabled`, and `facing`.
- **TIMING** (numbers I may change on purpose):
  - the ticks of `RUN-A` and `RUN-B` in a run;
  - the first `RUN-B` tick;
  - the slash pose's ticks (0–16), the live ticks (2–10) and the end tick (17);
  - the run's phase after a slash (resumes today).
- **INVARIANT** (facts that must survive):
  - the hitbox is live only while the slash pose shows, on exactly 9 ticks per swing;
  - no swing starts during a swing;
  - one slash sound per swing;
  - a hit ends a swing on its tick;
  - every pose shows its own frame (`RudyLook.frame()` against `FRAMES`);
  - the sword form's poses show only with the sword;
  - E2's jump keeps the swing.

**The read-back test**, `game/tests/test_rudy_clips.tscn`, one structure test for every clip. Against the `AnimationPlayer` in `rudy.tscn`:
1. `track_problems()`, the assignment's function, returns nothing: every track resolves to a real node and property (`evidence/brief-probe/logs/godot3_names_resource.log:6-7` shows it catching both kinds).
2. Key times equal this brief's ticks/60 (the slash) or the cycle spec (the run), to within 1 µs. Clip `length`s are as stated.
3. `loop_mode` is `LOOP_LINEAR` for `run`, `sword_run` and the one-key clips, and `LOOP_NONE` for `slash`.
4. Every frame track uses `UPDATE_DISCRETE`. Every frame key is below `hframes * vframes` (16) and equals the cell of section 2.1 for its clip.
5. The player's `callback_mode_process` is physics, its `autoplay` is empty, and its `speed_scale` is 1.0.
6. The Sprite: `hframes` 4, `vframes` 4, its texture is the 1640 × 1544 sheet, the sheet's `.import` has mipmaps, and offset, scale, centring, material and filter are as today.
7. **The structure check:** every clip name the selector can return has a clip, and every clip in the library is one it can return.

The clip and its read-back expectations change together in tuning: the read-back pins the clip's structure, not the game's behaviour. Behaviour pins change only in their own re-pin step, after play.

**The state test**, `game/tests/test_rudy_states.tscn`. Every state is entered from its real action under scripted input, at 60 fps, with a per-tick log. On every slash tick, the clip position equals (ticks since the press)/60, and Grip's rotation matches the key table.

**The edge test**, `game/tests/test_rudy_edges.tscn`: E1–E7 (section 6), at 60, and E1 and E2 at 30 at both offsets.

**Commands, always through the wrapper:**

```bash
scripts/run-test.sh test_rudy_pin.tscn 60
scripts/run-test.sh test_rudy_clips.tscn 60
scripts/run-test.sh test_rudy_states.tscn 60
scripts/run-test.sh test_rudy_edges.tscn 60
scripts/run-test.sh test_rudy_edges.tscn 30
scripts/run-test.sh checks.tscn 60
```

**Frame strips and watching.**
- **Capture.** The revision note asks for the pin test or a replay to be run "with a renderer, Movie Maker and --debug-collisions, so frame N lines up with log line N". So strips come from a Movie Maker run in a window (it needs a renderer) at 30 fps with `--debug-collisions`. It replays the pin test's scripted input, and its per-frame log numbers frame N as the PNG is numbered.
- **What each strip holds.** For the slash, every frame from the press through tick 17. For the run, two full cycles.
- **What decides.** Claude's reading of the frames is a claim. My verdict at normal speed and at `--time-scale 0.25`, with Visible Collision Shapes on, decides.

## 10. Predicted failures and how each is caught

| # | Failure | What it would look like | Caught by |
|---|---|---|---|
| 1 | **A frame track left on continuous** | No error. `RUN-B` shows 4 ticks early and `RUN-A` comes back 4 ticks early (`evidence/brief-probe/logs/anim_run_continuous_60fps.log:11-20`). With non-neighbouring cells it would sweep through the cells between | Read-back check 4 |
| 2 | **The sheet sliced wrong** (`hframes`/`vframes` swapped, 16 × 1, or cells in another order) | The wrong cells, or parts of two, with no error | Read-back checks 4 and 6; the packing script's pixel check; the strip |
| 3 | **A track path to a missing node or property** (`SlashRig/Grip` without `Lean`, or `Sprite:frame_coords` for `frame`) | A missing node prints one warning, which the wrapper fails on. A missing property prints **nothing** (`evidence/load-error-probe/`); the rig simply does not move | Read-back check 1 |
| 4 | **The slash not restarted** (`play("slash")` while it plays) | The second swing of a fast pair shows a frozen blade at its last angle (Chapter 10's counter that reached 2 while the blade sat still) | E1's tick-18 check: the blade travels at least 100° |
| 5 | **The player left on the idle callback** | Headless at 60 fps: the clip trails by a tick. At 30 fps or in a window: the rig's phases drift off the hitbox ticks, unevenly (`anim_clock_idle_30fps.log:7-13`) | Read-back check 5; the state test's clip position on every slash tick |
| 6 | **A one-key state clip left `LOOP_NONE`** | It ends, the player stops, and the next state's first key shows a tick late (`anim_clock_physics_60fps.log:7-8`) | Read-back check 3; the pin's per-tick trail |
| 7 | **Two authorities**: the old `show_pose()` still sets the texture beside the `AnimationPlayer` | A flicker between a whole PNG and a sheet cell; the Sprite's texture not the sheet after a run | Read-back check 6 after the state test's run; `checks.gd`'s frame checks |
| 8 | **The look contract broken**: `pose`, `FRAMES` or `frame()` changed meaning | `checks.gd` fails at its frame checks (`checks.gd:129-131`, `:848-886`), or its pose trails (`:172-173`, `:197-198`) | `checks.tscn` after every step; the FAIL classified |
| 9 | **Godot 3 names.** `playback_speed` for `speed_scale`. (`loop = true` for `loop_mode` is **not** a failure in 4.7.2: it is mapped to `LOOP_LINEAR`, `godot3_names_resource.log:3`. It is listed so the course's warning is not taken at face value.) | `playback_speed` is dropped without a message: the clip plays at speed 1 (`godot3_names_resource.log:4`) | Read-back check 5 (`speed_scale` 1.0); a text scan in the read-back for `playback_speed`, `loop =`, `playing =` and `frames =` in `rudy.tscn` and `rudy_animations.tres` |
| 10 | **The sheet imported without mipmaps** | The hair and outline shimmer at half scale while he runs | Read-back check 6 reads the `.import`; the strip |
| 11 | **An outline at the rig's seam** | A dark line across his fist where the blade meets the hand | The blade drawn behind the body (section 2.2); the slash strip; my eyes |
| 12 | **The arc's removal leaves a ghost band** on the robe | A pale streak across the lower robe in every slash frame | The cutting script's printed band; strip frames at ticks 1 and 12; my eyes. If it shows, the band is repaired again or the arc is kept baked into the body, and a revision here says which |
| 13 | **Rig parts out of register at rest** | At Grip 0°, Lean 0, the composite differs from `CHAR-SWORD-SLASH` outside the band: a jump between the run and the slash | The cutting script's composite check |
| 14 | **The run's restart changes a pin.** That is asked-for (E4) | The pin's "run resumes after a slash" TIMING line fails | Classified as asked-for. Re-pinned only after I have played it |

## 11. The evidence split

| Rule | Checked by | How |
|---|---|---|
| Every clip's tracks, keys, loop and update modes; the player's settings; the sheet's slicing | headless: read-back test | `test_rudy_clips.tscn`, section 9 |
| Every state entered from its real action; the clip follows the swing tick by tick | headless: state test | `test_rudy_states.tscn`, scripted key events |
| E1–E7 | headless: edge test | `test_rudy_edges.tscn` at 60, and 30 at both offsets; mutation checks in a worktree |
| Today's behaviour, before the change | headless: pin | `test_rudy_pin.tscn`, committed before any animation change |
| The earlier game | headless: earlier tests | the six earlier tests at their counts (section 5) |
| How the run and the slash read: timing, weight, the wind-up, the seam, registration | strip, then eyes | Claude reads the strips against sections 2 and 8, and that reading is a claim. My verdict in the running game at 1280 × 720, at normal speed and `--time-scale 0.25`, decides |
| Art against the collision shapes in every pose | eyes | Debug > Visible Collision Shapes in play; `--debug-collisions` in the strips |
| The state changes as I act | eyes | the Scene dock's Remote tab on the `AnimationPlayer` while I play |
| Which state he is in, with sound muted | eyes | I play muted and say whether I can tell |

## 12. How the agent sessions run

The rules below are the ones the assignment states; the source of each is in brackets.

- **One step per prompt.** One bounded step per prompt and one commit per verified step [course text, "Pin first, then change"]. Each prompt runs as its own Claude Code session with stream-JSON output, as in Chapter 10's command.
- **Git is read-only for the agent** (status, diff, log, show) [revision note, "Keep read-only git"].
- **The result event.** A session counts only if its stream-JSON ends with a `result` event whose subtype is `success` [revision note, "the result-event check"]. A session that ends any other way, at a usage limit or a turn limit, is **interrupted**.
- **Resuming** [revision note, "Add a rule for resuming interrupted sessions"]. An interrupted session's uncommitted work is not built on. I inspect its diff and rerun its checks through the wrapper. Then either I commit it as its own verified step, or I discard it with `git restore` and `git clean` limited to the files it touched. Only then does a new session start, with a prompt that says what the old one left.
- **Mutation checks** run in a `git worktree` of the pre-fix commit [revision note, "use git worktree for the mutation check"].
- **Committing.** Commits are mine, in the order worked: baseline, pin, each change, each fix, each re-pin [course text, "Commit in the order you worked"].

## 13. Out of scope

- No `AnimationTree`, no `AnimatedSprite2D`, no method or audio tracks: the slash sound stays in code.
- No gameplay change, including the slash's 2-tick startup.
- The goblins keep their code-picked frames (`goblin.gd:112-118`). `CHAR-SWORD-BLOCK` stays unused, as today (`checks.gd:879-882`).
- No new image is generated. The rig's parts are cut from an existing frame.

## Revisions
