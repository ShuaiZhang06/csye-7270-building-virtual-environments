# CLAUDE.md — Assignment 7 (walker-rudy, 2D)

A scoped Claude Code session drafted this file from `sessions/prompt-11.txt` on 2026-11-13. I review it; the draft is committed unedited and my review apart from it (`CHANGE-BRIEF.md`, Revision 5).

## Project context

- **Root.** This folder stands in for the game repository's root; the Godot project is `game/`, so the course's `godot/` paths become `game/` (`CHANGE-BRIEF.md`, Revision 5). Run every command from this folder (`scripts/run-test.sh:34`).
- **Godot 4.7.2 stable**, `v4.7.2.stable.official.ed1daf0bf` (`logs/checks_60fps.log:1`). Features `"4.7"`, `"GL Compatibility"` (`game/project.godot:16`).
- **Renderer:** GL Compatibility, `gl_compatibility` on desktop and mobile (`game/project.godot:95-96`).
- **Physics:** 60 ticks/s, the default; `game/project.godot` sets none (`evidence/brief-probe/logs/slash_ticks_60fps_frame.log:3`).
- **Viewport** 1920 × 1080, `canvas_items` stretch, 1280 × 720 window (`game/project.godot:25-29`).
- **State machine:** `game/content/rudy/rudy.gd` owns it. `mode` (`rudy.gd:41-49`, `:83`), `gear`, `_slash_clock` and physics feed `_pick_clip()` (`rudy.gd:296-320`), which returns a clip name every physics tick. `_physics_process` passes it to `RudyLook.play_clip()` (`rudy.gd:241`; `game/content/rudy/rudy_look.gd:78-83`), with a restart on every new swing. The hitbox stays in code: `_swing()` (`rudy.gd:246-258`).
- **The clips** (one `AnimationPlayer`, `Look/AnimationPlayer`, `rudy.tscn:69-76`; `root_node` `..`, so track paths start at `Look`; `callback_mode_process = 0`, physics):
  - `run`, `sword_run`, the looping sprite clips. Route: `Sprite2D` with an `AnimationPlayer` frame track. Node: `Look/Sprite`, texture `sheet/rudy_sheet.png`, `hframes` 4, `vframes` 4 (`rudy.tscn:31-38`). Tracks `Sprite:frame`, `Sprite:visible`, `SlashRig:visible`; `length` 0.25, `loop_mode = 1` (`rudy_animations.tres:45-51`, `:449-455`).
  - `slash`, the committing action. Route: cutout rig keyed as resource text. Node: `Look/SlashRig` with `Lean`, `Lean/Grip/Blade`, `Lean/Body`, `Lean/Arc` (`rudy.tscn:40-67`). Tracks `Sprite:visible`, `SlashRig:visible`, `SlashRig/Lean/Grip:rotation_degrees`, `SlashRig/Lean:rotation_degrees`, `SlashRig/Lean:position`, `SlashRig/Lean/Arc:modulate:a`; `length` 0.283333 (17/60), no `loop_mode` line, so the default `LOOP_NONE` (`rudy_animations.tres:373-438`).
  - Ten one-key state clips on `Sprite:frame` (`idle`, `rise`, `fall`, `hurt`, `defeat`, `respawn`, `celebrate`, `sword_idle`, `sword_rise`, `sword_fall`), each 1.0 s, `loop_mode = 1` (`rudy_animations.tres`).
- **The clip library is today** `game/content/rudy/rudy_animations.tres` (`rudy.tscn:7`, `:70-73`). Revision 5 of the brief moves it to `game/animations/rudy_animations.tres` after this step, with no key changed. `game/animations/` does not exist yet. The move must also update `test_rudy_clips.gd:43` and `test_rudy_states.gd:752`, which load it by path.
- **Scenes the clips appear in:**
  - `game/content/rudy/rudy.tscn`, which owns the player, the Sprite and the rig;
  - `game/app/main.tscn:21`, which instances Rudy in the game;
  - `game/tests/test_rudy_pin.tscn:29`, which instances Rudy on its own floor;
  - `test_rudy_states.tscn` and `test_rudy_edges.tscn` instance `main.tscn` at run time (`test_rudy_states.gd:37`, `test_rudy_edges.gd:58`); `test_rudy_clips.tscn` preloads `rudy.tscn` (`test_rudy_clips.gd:42`).
  - `game/previews/slash_sparks_preview.tscn:14` and `run_dust_preview.tscn:19` hold a plain `Node2D` named Rudy, a frozen sprite, not the clips. The previews Revision 5 names (`game/previews/slash_preview.tscn`, `run_preview.tscn`) do not exist yet.
- **Import a fresh copy first:** `godot --headless --path game --import` (`README.md:26`).

### Tests: always through the wrapper

`scripts/run-test.sh <test-file in game/tests/> <fps|realtime> [timeout-seconds]` (`scripts/run-test.sh:2`, `:35-37`).
- A number runs `--fixed-fps <n>` and logs to `logs/<test>_<n>fps.log`; `realtime` runs without `--fixed-fps`, for tests that wait on audio, and logs to `logs/<test>_realtime.log` (`run-test.sh:29-31`, `:40-44`, `:51`). The timeout is 120 s by default; status 124 means a hang (`:30`, `:52`).
- A `.tscn` runs as the scene; a `.gd` runs with `--script` and must `extends SceneTree` (`:45-49`). A `--script` run cannot compile code naming the `Sfx` autoload, which `rudy.gd:145` does, so tests that load Rudy are scenes (`evidence/brief-probe/README.md`).
- Exit 0 is not enough: the wrapper fails on `SHADER ERROR`, `SCRIPT ERROR`, resource-load lines and `couldn't resolve track` (`run-test.sh:54-59`). A track to a missing *property* prints nothing (`:25-27`).

```bash
scripts/run-test.sh test_rudy_clips.tscn 60       # read-back: 46 PASS (logs/test_rudy_clips_60fps.log:51)
scripts/run-test.sh test_rudy_states.tscn 60      # states: 81 PASS (logs/test_rudy_states_60fps.log:3072)
scripts/run-test.sh test_rudy_edges.tscn 60       # edges E1-E7: 98 PASS (logs/test_rudy_edges_60fps.log:5371)
scripts/run-test.sh test_rudy_edges.tscn 30       # E1, E2 at both offsets: 66 PASS (logs/test_rudy_edges_30fps.log:734)
scripts/run-test.sh test_rudy_pin.tscn 60         # pin: 19 checks, T1, T2, T6 FAIL as asked (logs/test_rudy_pin_60fps.log:959-979)
scripts/run-test.sh checks.tscn 60                # 141 PASS (logs/checks_60fps.log:141-144)
scripts/run-test.sh invulnerable_tint_checks.tscn 30   # also 60 and 144: 15 PASS each
scripts/run-test.sh test_slash_sparks_config.gd 60     # 108 checks
scripts/run-test.sh test_slash_sparks_state.tscn 60    # 14 PASS
scripts/run-test.sh test_run_dust_config.gd 60         # 61 checks
scripts/run-test.sh test_run_dust_state.tscn 60        # 14 PASS
scripts/run-test.sh <test> realtime                    # no current test uses it
```

- The pin's three FAILs are the run's intended restart; they are re-pinned after I play it (`CHANGE-BRIEF.md`, Revision 4). Earlier tests must keep their counts with 0 FAIL (`CHANGE-BRIEF.md` section 5).
- New tests press keys with `Input.parse_input_event`, physical keys D, A, Space, J (Esc to pause) (`game/project.godot:33-72`). `checks.gd` uses `Input.action_press`; leave it.
- Headless runs draw nothing; frame strips need a Movie Maker run in a window (`CHANGE-BRIEF.md` section 9).

## Current change

@CHANGE-BRIEF.md

## Ownership

- Every file in `game/shaders/` (`invulnerable_tint.gdshader`, `particles_generated.gdshader` and their `.uid` files) is written by hand by me and is never edited by an agent.
- Clips live as resources in `game/animations/` or in the scene that owns them, and are never built in code at runtime. Until the brief's move, the library stays at `game/content/rudy/rudy_animations.tres`.
- `scripts/run-test.sh` stays as committed (`db2f8989`; `CHANGE-BRIEF.md`, Revision 5).

## One authority

Exactly one node writes to each animated node. Never add a second writer to a node that already has one.

| Node and property | Its one writer |
|---|---|
| `Look/Sprite`: `frame`, `visible` | `Look/AnimationPlayer`. Its `texture` is the sheet, set only in `rudy.tscn:34` |
| `Look/SlashRig`: `visible` | `Look/AnimationPlayer` |
| `SlashRig/Lean`: `position`, `rotation_degrees`; `Lean/Grip`: `rotation_degrees`; `Lean/Arc`: `modulate:a` | `Look/AnimationPlayer` |
| `Lean/Grip/Blade`, `Lean/Body` | nothing keys them; they move with their parents |
| `Look`: `scale.x` (facing), `modulate.a` (flash) | `Rudy` (`rudy.gd:238-239`); no clip keys `Look` |
| `Look/AnimationPlayer`: which clip plays | `Rudy`, only through `RudyLook.play_clip()` (`rudy.gd:109`, `:241`); `autoplay` is empty (`rudy.tscn:74`) |
| `SwordHitbox/Shape`: `disabled`, `position` | `Rudy`'s `_swing()` (`rudy.gd:247-249`); gameplay, never keyed |

No `AnimationTree`, second `AnimationPlayer`, `AnimatedSprite2D` or RESET clip exists, and none is added.

## Godot 4 names

- Use Godot 4 class and property names for 4.7.2, never Godot 3 names: `loop_mode` (`Animation.LOOP_NONE`, `LOOP_LINEAR`, `LOOP_PINGPONG`), not a boolean `loop`; `speed_scale`, not `playback_speed`, which 4.7.2 drops without a message; `AnimatedSprite2D` with `sprite_frames` and `play()`, not `AnimatedSprite`, `frames` or `playing = true` (`evidence/brief-probe/README.md`).
- `callback_mode_process`: physics is 0, idle is 1 and the default (`evidence/brief-probe/logs/anim_clock_physics_60fps.log:3`).
- `Animation.step` is set per clip by the brief; no clip sets it yet (`rudy_animations.tres` has no `step` line).
- If you are unsure a class, property or constant exists in 4.7.2, say so, then check it (`ClassDB`, or load and read back) instead of guessing.

## Out of scope

- Gameplay: movement numbers, the swing's timing and live window, hurt, invulnerability and respawn timing, and what cancels a swing.
- Collision shapes, the input map and the rest of `game/project.godot`.
- Audio and its calls; the slash sound stays in code, with no audio or method tracks.
- The particle effects (`game/effects/`, `main.tscn`'s effects nodes), the goblins, the level, `Main`, the HUD and `game/systems/` (the outline material is reused, not changed).
- `game/shaders/` and `scripts/run-test.sh`.
- Earlier tests: never edited to pass. A FAIL is classified, not edited away.
- No `AnimationTree`, no `AnimatedSprite2D`, no new generated image, no use of `CHAR-SWORD-BLOCK`.

## Git

Read-only for the agent: `status`, `diff`, `log`, `show`. No commit, stage, stash, reset, restore, clean, branch switch or file deletion through git; commits are mine.

## Unconfirmed

- That `game/shaders/` is byte-identical to Assignment 6's (Revision 5 says so). This session could not run `git diff`.
- `Animation.step`'s default of 1/30 s in 4.7.2: Revision 5 states it; no probe in `evidence/` records it.
- The realtime mode: no `logs/*_realtime.log` exists, so it is unrun in this folder.
- Whether the read-back's NEGATIVE copies, made in memory by duplicating existing clips (`test_rudy_clips.gd:34-38`), count as "built in code at runtime". I read the rule as covering game code; you decide.
- The `invulnerable_tint`, sparks and dust counts come from `logs/` PASS lines, not from runs in this session.
