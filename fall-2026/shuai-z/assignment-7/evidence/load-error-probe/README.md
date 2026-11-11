# What Godot 4.7.2 prints when a resource fails to load

Claude Code ran this probe on 2026-11-11, at my request to set up the Assignment 7 folder, to find the lines `scripts/run-test.sh` should fail on. Assignment 7 asks for the wrapper's error patterns to cover resource-load failures.

**How it was run.** The files in `tests/` were copied into `game/tests/` of a scratch copy of this folder's `game/`, imported once (`godot --headless --path game --import`), and run through the wrapper at `--fixed-fps 60` with a 60 s timeout. They are not in `game/`, so they are not part of the game. Godot 4.7.2 (`v4.7.2.stable.official.ed1daf0bf`), macOS.

| Probe | What it does | What Godot printed | Exit, A6 wrapper | Exit, A7 wrapper |
|---|---|---|---|---|
| `probe_load.gd` | `load()` of a missing `.tres`; a `.tres` with a syntax error; a scene whose texture is missing; a scene whose sub-scene is missing; `ResourceLoader.load()` of a missing texture | `Cannot open file`, `Failed loading resource`, `Parse Error`, `Resource file not found`, `Error loading resource`. **Both scenes loaded and instanced**: the one with the missing texture gave a `Sprite2D` with no texture | 0 | 1 |
| `probe_scene_missing.tscn` | The scene with the missing texture, run as the test scene; its script prints `SCENE RAN` and quits | `Resource file not found`, `Parse Error: [ext_resource] referenced non-existent resource`. The scene still ran (`SCENE RAN`) | 0 | 1 |
| `probe_preload.gd` | `preload()` of a missing texture | `SCRIPT ERROR: Parse Error`, `Failed to load script` | 1 | 1 |
| `probe_track.gd` | An `AnimationPlayer` clip with a track to a missing node (`Nobody:frame`) and one to a missing property (`Sprite:no_such_prop`), played for 5 frames | `WARNING: ... couldn't resolve track: 'Nobody:frame'`. **Nothing at all for the missing property** | 0 | 1 |
| `probe_clean.gd` | Prints `PASS clean` and quits | nothing unusual | 0 | 0 |

`logs/` holds the A7 wrapper's log for each probe. The A6 wrapper's exit codes were read from a second run of the same probes.

**What this means for Assignment 7.**

- An exit code of 0, and even a scene that runs, do not mean every resource loaded. A sprite sheet or a sub-scene with a wrong path loads as nothing, and only the log says so. The A6 wrapper caught one of the four broken probes, the `preload()`, because Godot calls it a `SCRIPT ERROR`.
- A track to a missing node gives only a warning, and a track to a missing property prints nothing. The wrapper fails on the warning; only the clip read-back test (`track_problems()` in the assignment) can catch the missing property.
- None of the patterns appears in any log in `../../../assignment-6/logs/`, so the new check does not fail a run that passed in Assignment 6.
