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

## Step 3 — Effect A's state test

`game/tests/test_slash_sparks_state.tscn` (with `test_slash_sparks_state.gd`) runs the real `Main` at 60 fps through the wrapper, not in realtime, because it does not wait on audio. Every cut comes from the real `slash` action, the sword from walking into the pickup with `move_right`, and the pause from the real `pause` action; the test never calls the driver. The only game state it writes is Rudy's position, and once his velocity for the stomp, the same setup `checks.gd` uses. The driver, `game/effects/effects_driver.gd`, sits after `Rudy` in `game/app/main.tscn`, so it sees the hitbox go live on the tick `_swing()` makes it.

| Check | Rule | Result at 60 fps (`logs/test_slash_sparks_state_60fps.log`) |
|---|---|---|
| S1 no burst on load and on the title, with slash pressed there | A1 | PASS: 0 bursts, state TITLE |
| S2 no burst on load with the title skipped | A1 | PASS: 0 bursts |
| S3 slash without the sword: no burst, no live edge | A1 | PASS |
| S4 one cut: exactly one burst, born on the tick the hitbox went live | A1 | PASS: born on tick 214, edge on tick 214 |
| S5 facing right: on the hitbox within 1 px, not mirrored | A2 | PASS: burst and hitbox both at (2518.0, 764.0), x axis +1 |
| S6 facing left: on the hitbox within 1 px, mirrored | A2 | PASS: both at (2418.0, 764.0), x axis −1 |
| S7 two cuts 19 ticks apart: two bursts alive at the second; the first the same node, not moved, still emitting | A3 | PASS |
| S8 the first burst leaves the tree 25–30 ticks after its birth | A3 | PASS: 27 ticks |
| S9 mashing slash: one burst per live edge per swing, never more than 2 alive | A1, A3 | PASS: 7 swings, 7 edges, 7 bursts, at most 2 alive |
| S10 every burst under `Effects/SlashBursts`, never under Rudy or a goblin | A4 | PASS: 11 bursts, 0 outside |
| S11 a cut defeats a goblin: the goblin hides while the burst is still visible, every tick of its life | A4 | PASS: visible 27 ticks, hidden 0 |
| S12 a stomp with the sword: no burst, no live edge | A1 | PASS |
| S13 slash while paused: no burst then, none in the 10 ticks after resuming | A1 | PASS |
| S14 a burst alive at a pause stays in the tree, visible and emitting, and stops processing until resumed | A5 (headless part) | PASS |

After the effect was wired in, Claude reran the other tests through the wrapper: `checks.tscn` 141 of 141 at 60 fps (it now finds 85 `res://` paths, all present); `invulnerable_tint_checks.tscn` 15 of 15 at 30, 60 and 144; `test_slash_sparks_config.gd` 108 of 108 at 60.

### Mutations of the driver

The approved plan's step 4. The implementation session made each change, ran the state test at 60 fps and restored the file; the two runs' output is in its transcript and was copied out by Claude into the logs below. After the restores, `effects_driver.gd` and `main.tscn` were the same blobs as after step 1 (`0f8c60e6`, `b6ab510bd`), and the test passed 14 of 14 again.

| Mutation | Expected | Result | Log |
|---|---|---|---|
| **a. One reused burst:** the driver keeps one `SlashSparks` and sets `emitting = true` on it again for every cut (predicted failure 4) | S7 and S8 fail | **Exit 1, 6 failures:** S6, S7, S8, S9, S11, S14. No new burst enters the tree after the first, so every check that looks for a new burst fails. S8 fails because no second burst was recorded (`-1 ticks`), not because it measured a restarted life | `logs/mutation_driver_reuse_60fps.log` |
| **b. The driver one tick late:** `Effects` moved before `Rudy` in `main.tscn` | S4 fails | **Exit 1, 2 failures:** S4 (born on tick 215, edge on 214) and S7, which also checks the second burst's birth tick | `logs/mutation_driver_order_60fps.log` |

**What the state test establishes:** each live cut makes exactly one burst on that tick, at the hitbox, mirrored with Rudy's facing; nothing else makes one; two quick cuts overlap without the first being restarted, moved or cut short, with at most two alive; no burst belongs to Rudy or a goblin; and a paused burst stops processing.

**What it cannot establish:** that anything is drawn, since the dummy renderer draws nothing and the 27-tick life is the node's own clock; that the sparks fly the way Rudy faces, since only the node is mirrored (failure 8); that paused sparks really hold still; and real key presses, since the input goes through `Input.action_press`.

**My check in the running game** (2026-11-04, after the effect was wired in): I played the game and found no problem [我已经进到游戏里看过了，没问题]. I did not record which of the eye checks I made one by one: a cut facing left, a cut on a goblin, Esc right after a swing (A5), a cut at the top of a jump and over the pit, both screen edges, and the first frames after loading. Those are still to be recorded item by item.
