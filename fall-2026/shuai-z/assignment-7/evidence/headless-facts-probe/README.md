# headless-facts-probe — the CLAUDE.md review's checks

The assignment's Step 1 says to add four lines to `CLAUDE.md`'s "Headless facts" block once they are confirmed on this machine. This folder holds the probe that confirmed them, and the other checks the review of the agent's draft (`5b6d8ca6`) needed.

**How it was made:** Claude Code (Claude Opus 5.5) wrote the probe and ran every command below on 2026-11-13, in our conversation, during the review I asked for. Godot 4.7.2 (`v4.7.2.stable.official.ed1daf0bf`), macOS, Apple M3.

## Commands, from `assignment-7/`

```bash
godot --headless --fixed-fps 60 --path game --script "$PWD/evidence/headless-facts-probe/probe_headless_facts.gd" -- <scratch> > logs/probe_headless_facts_60fps.log 2>&1
godot --headless --path game --write-movie <scratch>/frame.png --fixed-fps 30 --quit-after 10 res://previews/run_dust_preview.tscn > logs/probe_movie_headless.log 2>&1
godot --path game --write-movie <scratch>/frame.png --fixed-fps 30 --quit-after 10 res://previews/run_dust_preview.tscn > logs/probe_movie_window.log 2>&1
scripts/run-test.sh test_run_dust_config.gd realtime
```

- The probe script sits outside `game/`, so the game gains no file. It reads `res://content/rudy/rudy_animations.tres` and saves one `.tres` to the scratch directory.
- Two log lines held local paths: the probe's backtraces now read `assignment-7/…`, and the windowed run's output path reads `<scratch>/`. Nothing else in the logs was changed.

## The four lines

| The line | What the probe saw | Log |
|---|---|---|
| A headless run advances clips and reads their structure. It draws nothing, so whether the motion reads is not observable here. | The display server is `headless`, with no video adapter. The `run` clip read back its three tracks, two keys, discrete update mode, `loop_mode` 1 and length 0.25. Played on a physics-callback `AnimationPlayer`, its position grew by 1/60 per tick, and the Sprite's frame went from cell 1 to cell 2 once it passed 0.125 s. The root viewport's `get_image()` returned null, after the dummy renderer's null-texture error. | `probe_headless_facts_60fps.log:3-11` |
| Key times are 32-bit floats; compare them with a tolerance. | **Keys loaded from resource text:** resource text stores times as `PackedFloat32Array`, and a saved clip loaded back had no key equal to tick/60, off by up to 4 ns. Every key of `rudy_animations.tres` loads that way, so the slash's Grip keys equal tick/60 only at 0. **The slash's `length`** is written with 12 digits, so it is not `== 17.0 / 60.0` either. **Keys inserted from code** kept their 64-bit times until saved. **`Animation.step`** defaults to 0.03333333507180214, the 32-bit float nearest 1/30: `==` to `1.0 / 30.0` is false, and `is_equal_approx` is true. | `probe_headless_facts_60fps.log:12-17` |
| `value_track_get_update_mode` applies only to value tracks. | On a value track set to discrete it returned 1. On a bezier track and a method track, it printed `Condition "t->type != TYPE_VALUE" is true` and returned 0, `UPDATE_CONTINUOUS`. That is a wrong answer, not a failed run: the wrapper's error patterns do not include that line. All 42 tracks in `rudy_animations.tres` are value tracks. | `probe_headless_facts_60fps.log:18-36` |
| Frame strips come from a windowed Movie Maker run, which I start. | **Under `--headless`**, Movie Maker started recording, hit the dummy renderer's null texture and crashed with signal 11. It wrote only `frame.wav` and no PNG. **In a window**, it wrote 10 PNGs of 1280 × 720, each with 103,428 distinct colours. That I start the captures is the assignment's rule ("you run every capture"), not something a probe shows. | `probe_movie_headless.log:3-8`; `probe_movie_window.log:2-8` |

## The draft's "Unconfirmed" list

- **`game/shaders/` against Assignment 6's:** `diff -rq game/shaders ../assignment-6/game/shaders` printed nothing. The session could have run `git diff` (it was allowed); its one denied command was a compound command starting with `cd`.
- **`Animation.step`'s default:** 1/30 s, as a 32-bit float (above).
- **The realtime mode:** `test_run_dust_config.gd` passed in it, and its log equals the 60 fps log after the version line (`logs/test_run_dust_config_realtime.log`).
- **The NEGATIVE copies in `test_rudy_clips.gd`:** a question of what the rule means, not a fact; my answer is in `CLAUDE.md`'s "Ownership".
- **The earlier tests' counts:** each matches its log. The two config tests print one summary PASS line after their checks, so their logs hold 109 and 62 PASS lines for 108 and 61 checks (`logs/test_slash_sparks_config_60fps.log:111`, `logs/test_run_dust_config_60fps.log:64`).
