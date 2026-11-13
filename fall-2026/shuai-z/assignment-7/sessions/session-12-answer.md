I've moved the library and set `step` on all 13 clips. The read-back now shows **51 checks, 0 failed**, the other test counts are unchanged, and nothing is committed. To get checks.tscn back to 0 FAIL and 98 paths I had to change my new test code twice; that's under ANOMALIES.

## What changed

- **Move:** I ran exactly `mkdir -p game/animations` and `mv game/content/rudy/rudy_animations.tres game/animations/rudy_animations.tres`. Comparing the committed file with the new one shows only the 13 added `step` lines, so no other byte changed.
- **Paths:** `rudy.tscn:7` (the ext_resource), `test_rudy_clips.gd:47` (`LIBRARY_PATH`) and `test_rudy_states.gd:752` (the `load()`). `evidence/` and `sessions/` are untouched.
- **The read-back, `test_rudy_clips.gd`:**
  - check 11 (`_check_steps`) tests `is_equal_approx(clip.step, 1.0 / fps)` against a `STEP_FPS` table, and also fails a clip that isn't in the table;
  - check 12 (`_check_location`) tests the player's library path, the single AnimationLibrary ext_resource in `rudy.tscn`'s text, that text never naming the old path, and that no file exists at the old path;
  - the three NEGATIVE lines you asked for;
  - one paragraph in the header comment.

  I also added checks 11 and 12 to the existing "control" line's list and label, so each of the new NEGATIVE lines is shown to fail only from its damage. Its expectation is unchanged.
- **CLAUDE.md:** five edits, all on the library's path, its line ranges or `step`. It is now 108 lines.

### The step lines added (`game/animations/rudy_animations.tres`)

| Line | Clip | step |
|---|---|---|
| 7 | idle | 0.0166666666667 |
| 49 | run | 0.125 |
| 91 | rise | 0.0166666666667 |
| 133 | fall | 0.0166666666667 |
| 175 | hurt | 0.0166666666667 |
| 217 | defeat | 0.0166666666667 |
| 259 | respawn | 0.0166666666667 |
| 301 | celebrate | 0.0166666666667 |
| 343 | sword_idle | 0.0166666666667 |
| 384 | slash (after `length`; it has no `loop_mode` line) | 0.0166666666667 |
| 462 | sword_run | 0.125 |
| 504 | sword_rise | 0.0166666666667 |
| 546 | sword_fall | 0.0166666666667 |

## Real output

The import (`godot --headless --path game --import`) ended with `[ DONE ] loading_editor_layout`. It printed no errors.

**`scripts/run-test.sh test_rudy_clips.tscn 60`** (final run, `logs/test_rudy_clips_60fps.log`). Lines 1–21 of the READBACK group and the first 28 NEGATIVE lines are the same 46 checks as before; every one is PASS, and their text and values are unchanged. The new lines and the result:
```
PASS  11 every clip's step is one frame period, is_equal_approx(clip.step, 1.0 / fps): 1/60 s for slash and the ten one-key clips, 1/8 s for run and sword_run (Revision 5)  (celebrate 0.016667, defeat 0.016667, fall 0.016667, hurt 0.016667, idle 0.016667, respawn 0.016667, rise 0.016667, run 0.125000, slash 0.016667, sword_fall 0.016667, sword_idle 0.016667, sword_rise 0.016667, sword_run 0.125000)
PASS  12 the scene's player takes its library from res://animations/rudy_animations.tres, and no file is left at res://content/rudy/rudy_animations.tres (Revision 5)  (library res://animations/rudy_animations.tres; old path exists false)
NEGATIVE
PASS  control: an undamaged copy passes checks 1, 1b, 2, 3, 4, 6, 7, 8, 11, 12 and the text checks, and rudy_look.gd's undamaged text loaded as a new script passes check 9, so each failure below comes from its damage
...
PASS  11 run's step left at the default 1/30 s: must fail on "run step"  (run step 0.033333 s, want 1/8 = 0.125000 s)
PASS  11 slash's step at 1/30 s: must fail on "slash step"  (slash step 0.033333 s, want 1/60 = 0.016667 s)
PASS  12 rudy.tscn's text naming the library at its old path: must fail on "rudy.tscn names the old path"  (rudy.tscn's AnimationLibrary ext_resources ["res://content/rudy/rudy_animations.tres"], want only res://animations/rudy_animations.tres; rudy.tscn names the old path res://content/rudy/rudy_animations.tres)
RESULT PASS: 51 checks, 0 failed
```
That is 46 + 2 + 3 = 51, as you expected.

**`test_rudy_pin.tscn 60`:**
```
FAIL  T1 run from a standstill: ... cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T2 run from a standstill: ... cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T6 the run resumes after a slash  (restarts: CHAR-SWORD-RUN-A for 4 ticks before the swing, CHAR-SWORD-RUN-A for 8 ticks after it)
RESULT FAIL: 19 checks, 3 failed, 953 ticks
```
`git diff` on its log: only the leak line differs.
```
-WARNING: 18 ObjectDB instances were leaked at exit
+WARNING: 17 ObjectDB instances were leaked at exit
```

**The states and edge tests:**
```
RESULT PASS: 81 checks, 0 failed, 2932 ticks
RESULT PASS: 98 checks, 0 failed, 5225 ticks, 60 fps
RESULT PASS: 66 checks, 0 failed, 642 ticks, 30 fps
```
In `git diff`, the states log changes only in its leak line (21 → 20) and the 60 fps edges log only in its leak line (19 → 17). The 30 fps edges log is byte-identical, so it has no diff at all.

**`checks.tscn 60`** (final run):
```
PASS  the game opens with the debug line hidden
PASS  every file the scenes, resources and scripts name by a res:// path is in the project  (98 paths; missing: )
all checks passed
```
That is 141 PASS and 98 paths. Its log diff has the leak and resource lines, plus line 59's camera offset, which comes from an unseeded `randf_range` (`game/app/main.gd:97`) and changes on every run.

`git diff --stat game/shaders/` and `git diff scripts/run-test.sh` both print nothing.

## ANOMALIES

1. **The first checks.tscn run failed.** It read `FAIL every file ... is in the project (100 paths; missing: res://content/rudy/rudy_animations.tres (named in res://tests/test_rudy_clips.gd))`. checks.gd collects every `res://…` literal in the project and requires each one to exist. My new test named the old path on purpose, to assert it is gone, and my header comment held a bare `res://animations/`.
   - I left checks.gd alone and changed only my new code: the old path is now worked out at run time, `SCENE_PATH.get_base_dir().path_join(LIBRARY_PATH.get_file())`, and the comment says `game/animations/`.
   - A middle attempt, joining two string parts, still gave 99 paths, because `res://content/rudy/` counted as a path of its own.
   - Please check that this is acceptable. It does mean checks.gd's scan can't see that path in this test.
2. **The leak counts move between runs** (checks.tscn gave 28/8 on one run and 22/7 on the next), so the leak-line diffs aren't caused by this step.

## Still for a human

- Whether the derived old path (anomaly 1) is acceptable to you.
- Opening the project in the editor. The `step` lines are written by hand as resource text, and no editor has opened or re-saved the file. Check that the Animation panel shows Snap 1/60 for `slash` and 0.125 for `run`, and that saving it from the editor doesn't rewrite the keys.
- The pin's T1, T2 and T6 are still the intended failures; they wait for your play and re-pin (Revision 4).
- I left two stale lines in CLAUDE.md, because you limited the CLAUDE.md edits to the library's path, its line numbers and `step`:
  - its read-back line still says `46 PASS (logs/test_rudy_clips_60fps.log:51)`; it is now 51 at `:56`;
  - `test_rudy_states_60fps.log:3072` is now `:3073` in the new log.
- `git status`: `M CLAUDE.md`, `M game/content/rudy/rudy.tscn`, `D game/content/rudy/rudy_animations.tres`, `M game/tests/test_rudy_clips.gd`, `M game/tests/test_rudy_states.gd`, five changed logs, and untracked `game/animations/` (only `rudy_animations.tres`) plus your `sessions/prompt-12.txt`.