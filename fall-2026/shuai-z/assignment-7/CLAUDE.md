# CLAUDE.md — Assignment 7 (walker-rudy, 2D)

Stable facts about this project. The change under way, its design and its rules are in `CHANGE-BRIEF.md`; where this file and the brief differ, the brief holds. Claude Code drafted this file on 2026-11-12 at my request; it is committed only after my review.

## The project

- This folder stands in for the game repository's root. The Godot project is `game/`, so the course's `godot/` paths become `game/`. Run every command from this folder.
- **Godot 4.7.2 stable** (`v4.7.2.stable.official.ed1daf0bf`, `logs/checks_60fps.log:1`). The project declares features `"4.7"` and the GL Compatibility renderer (`game/project.godot:16`).
- **60 physics ticks per second:** the project sets none, so the default holds.
- **Viewport** 1920 × 1080, `canvas_items` stretch, in a 1280 × 720 window (`game/project.godot:25-29`).
- Import before testing a fresh copy: `godot --headless --path game --import`.

## Tests: always through the wrapper

```bash
scripts/run-test.sh <test-file in game/tests/> <fps|realtime> [timeout-seconds]
```

- A `.tscn` test runs as the scene; a `.gd` test runs with `--script` and must `extends SceneTree`.
- A `--script` run cannot compile code that names an autoload such as `Sfx`, which `rudy.gd` does. Tests that load Rudy are scenes (`evidence/brief-probe/README.md`).
- The log is `logs/<test>_<fps>fps.log`. Exit 0 is not enough: the wrapper also fails on `SHADER ERROR`, `SCRIPT ERROR` and resource-load lines, because a scene with a missing texture loads and exits 0 (`evidence/load-error-probe/README.md`).
- Earlier tests and their counts, all 0 FAIL (`logs/`):
  - `checks.tscn`: 141 at 60;
  - `invulnerable_tint_checks.tscn`: 15 at 30, 60 and 144;
  - `test_slash_sparks_config.gd`: 108 checks;
  - `test_slash_sparks_state.tscn`: 14;
  - `test_run_dust_config.gd`: 61 checks;
  - `test_run_dust_state.tscn`: 14.
- New tests press keys with `Input.parse_input_event`, using the project's physical keys: D (move right), A (move left), Space (jump), J (slash). `checks.gd` uses `Input.action_press`; leave it as it is.
- Headless runs draw nothing. Frame strips need a Movie Maker run in a window.

## Godot 4 names (probed on 4.7.2: `evidence/brief-probe/README.md`)

- Write `loop_mode`, not `loop`. 4.7.2 happens to map `loop = true`, but Godot 4 code uses `loop_mode`.
- Write `speed_scale`, not `playback_speed`: `playback_speed` is dropped without a message.
- On `AnimatedSprite2D`, `sprite_frames` and `play()`, not `frames` and `playing = true`. `playing = true` does not play.
- `AnimationPlayer` and `AnimationTree` default to `callback_mode_process` idle (1); physics is 0 (Chapter 10; the probe confirmed it for `AnimationPlayer`).
- A track to a missing property prints nothing. If you are unsure a property exists in 4.7.2, check it (`ClassDB`, or load and read back) instead of guessing.

## Git

Git is read-only for the agent: `status`, `diff`, `log`, `show`. Do not commit, stage, stash, reset, switch branches or delete files with git; commits are mine.
