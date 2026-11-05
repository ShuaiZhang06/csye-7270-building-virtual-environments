# TEST-REPORT — Assignment 6, walker-rudy

What each test establishes, what it cannot establish, and the mutations that show it can fail. Sections are added as the steps are done.

**How this file is written.** Claude Code ran the tests and mutations below at my request and drafted this report from their logs; I decided each step. Every run used Godot 4.7.2 headless through `scripts/run-test.sh`, unless the row says otherwise.

---

## Step 2 — Effect A's configuration test

`game/tests/test_slash_sparks_config.gd` (`extends SceneTree`) loads `game/effects/slash_sparks.tscn` and checks 108 things against the brief's values: the root and its two emitters, every emission, process, draw and culling setting in the brief's table for `Flash` and `Sparks` (as revised: 28 sparks), the textures, the curves and the colour ramps. It reads the Godot 4 `_min`/`_max` values from the loaded resources, never whether a name exists. Because Godot 4.7.2 maps some Godot 3 names silently (`CLAUDE.md`, "Godot 4 names"), it also scans the scene's text for Godot 3 class names and property lines.

| Run | Result | Log |
|---|---|---|
| The effect as committed (`fed848b8`), 60 fps | 108 of 108, exit 0 | `logs/test_slash_sparks_config_60fps.log` |
| The same at 30 and 144 fps, after the agent's build (`ea4419ae`, 14 sparks) | 108 of 108 each, exit 0; those two logs were not kept | — |
| The existing tests, after the effect was added | `checks.tscn` 141 of 141 at 60 fps (it now finds 83 `res://` paths, all present); `invulnerable_tint_checks.tscn` 15 of 15 at 30, 60 and 144 | `logs/checks_60fps.log`, `logs/invulnerable_tint_checks_*fps.log` |

**What a pass establishes:** the effect scene is configured as the brief says, with Godot 4 names, and the brief and the scene have not drifted apart.

**What it cannot establish:** that the effect fires on the right event, at the right place, or the right number of times (Step 3's state test); and anything about the look. Headless, nothing is drawn (`CLAUDE.md`, "Headless facts"). The look comes from the frame strips and my verdict (`TUNING.md`).

### Mutations

Each mutation changed one line of `game/effects/slash_sparks.tscn` and left everything else, including the brief and the test, alone. After each one Claude restored the file with `git checkout`; its SHA-1 was `2ebf93f7d46d84267398cdfed28e668c5cafe8ae` before and after both mutations. The test then passed 108 of 108 again, and its log was identical to the committed one.

| Mutation | The line changed | Expected | Result | Log |
|---|---|---|---|---|
| **1. A Godot 3 name.** One property the brief names, renamed to its Godot 3 name | Line 77, in `Sparks`' material: `initial_velocity_min = 260.0` → `initial_velocity = 260.0` | Exit 1: the scene loads without a message, with velocity 0 to 420, not 260 to 420 (CHANGE-BRIEF.md, Revision 2) | **Exit 1, 2 failures:** the text scan found `initial_velocity = 260.0`, and `Sparks initial_velocity_min` read 0.0 instead of 260.0. `initial_velocity_max` still read 420.0. | `logs/mutation_godot3_name_60fps.log` |
| **2. A value changed, the brief not.** | Line 76, in `Sparks`' material: `spread = 30.0` → `spread = 45.0` | Exit 1, on the spread check | **Exit 1, 1 failure:** `Sparks spread is 30.0`, read 45.0 | `logs/mutation_value_drift_60fps.log` |

**Mutation 1 in a window.** The assignment asks to run the game with the mutation and note that the effect still fires. The effect is not wired into the game until Step 3, so Claude ran the preview instead: a 30 fps Movie Maker run of `game/previews/slash_sparks_preview.tscn` with the mutated scene (`logs/capture_mutation_godot3_name.log`; frames 12 and 15 kept in `captures/slash_sparks/mutation_godot3_name/`, fixture captures). The burst fired on frame 10, as before. Beside r1's frames 12 and 15 it still reads as a spray; the only visible difference is a knot of slow sparks left near the hitbox on frame 15. That is the silent failure the test exists for: nothing in the log or the picture announces it.

**Did the version translate the old name?** Not this one. Godot 4.7.2 keeps `initial_velocity` only as an editor range that is never saved, so the number on that line sets both ends of the range to 0, and the `initial_velocity_max` line after it sets the top end back to 420 (`logs/probe_mutation.log:4`). It does translate `Particles2D`, `ParticlesMaterial` and `flag_disable_z` (`logs/probe_mutation.log:7-10`). No loaded value can show those three, so only the text scan would catch them; that is why mutation 1 failed two checks rather than one.
