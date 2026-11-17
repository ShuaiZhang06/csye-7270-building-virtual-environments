I couldn't finish this step. I wrote and imported the four files, but none of them has run. After the import, the permission mode refused every Godot run I tried, including the wrapper. So there are no headless logs and no rerun diff, and I can't paste output or say whether any frame matches the brief. I did not try other ways around the refusal.

**What did run**
- `godot --headless --path game --import` finished (`[ DONE ] loading_editor_layout`). It wrote `game/previews/slash_preview.gd.uid` and `run_preview.gd.uid`.
- `git status --short`:
  ```
  ?? game/previews/run_preview.gd
  ?? game/previews/run_preview.gd.uid
  ?? game/previews/run_preview.tscn
  ?? game/previews/slash_preview.gd
  ?? game/previews/slash_preview.gd.uid
  ?? game/previews/slash_preview.tscn
  ?? sessions/prompt-17.txt
  ```
  No other file changed, including `game/shaders/` and the wrapper. Nothing is committed.

**What was refused**
- `godot --headless --path game --fixed-fps 30 --quit-after 90 res://previews/slash_preview.tscn 2>&1 | tee logs/slash_preview_headless.log`, with and without extra commands around it.
- `scripts/run-test.sh checks.tscn 60`.

To finish, allow these commands, or run them yourself:
```bash
godot --headless --path game --fixed-fps 30 --quit-after 90 res://previews/slash_preview.tscn 2>&1 | tee logs/slash_preview_headless.log
godot --headless --path game --fixed-fps 30 --quit-after 90 res://previews/slash_preview.tscn -- second-tick 2>&1 | tee logs/slash_preview_headless_second_tick.log
godot --headless --path game --fixed-fps 30 --quit-after 90 res://previews/run_preview.tscn 2>&1 | tee logs/run_preview_headless.log
godot --headless --path game --fixed-fps 30 --quit-after 90 res://previews/run_preview.tscn -- sword 2>&1 | tee logs/run_preview_headless_sword.log
godot --headless --path game --fixed-fps 30 --quit-after 90 res://previews/slash_preview.tscn 2>&1 | tee logs/slash_preview_headless_rerun.log
diff logs/slash_preview_headless.log logs/slash_preview_headless_rerun.log
scripts/run-test.sh checks.tscn 60
```
If you allow them, I'll run them, paste each header and the frames to read, check each against the brief, and check the output against the wrapper's error patterns.

**The `res://` path count will probably be 102, not 100.** `checks.gd`'s `_res_paths_named_in` counts every `res://` string in `.gd` and `.tscn` files, comments included. Today's count is 98 (`logs/checks_60fps.log:143`). Four paths are new:
- the two scripts, named in the new `.tscn` files;
- the two scenes, named in the run and capture commands in each script's header comment.

All four exist, so the check should still pass. It just won't read 100. I kept the text's command with its `res://` path in the headers. If you want 100, those comment lines would have to drop the `res://` prefix.

**What the scripts do**
- **Input.** Rudy is the real `rudy.tscn` at (2500, 840). He gets only `parse_input_event` key events; the scripts only read his state.
- **When the keys are read.**
  - In `slash_preview`, J is read on tick 60 and every 120 ticks after.
  - With `-- second-tick`, it waits one `physics_frame` past the frame boundary, then sends J and calls `Input.flush_buffered_events()`, as `test_rudy_edges.gd` does. J should then be read on tick 61.
  - In `run_preview`, D is read on tick 60 and released on tick 84. With no argument, the SwordPickup is disabled and hidden in `_ready`. With `-- sword` it is left alone.
- **Swing tick.** The log doesn't assume the planned tick. It records the tick on which `is_slashing()` first comes back true, and counts the swing from there.
- **Log.** Each rendered frame prints one `frame N` line with fixed decimals, and the corner label shows the frame number. The camera is updated with `force_update_scroll()` before the screen origin is read, so the origin isn't a frame behind.
- **The second offset's table is derived, not the brief's.** It is computed from the slash track's keys and easing, and it says so in its header:

  | Frame | Swing tick | Grip | Lean | Lean x | Arc α | Hitbox |
  |---|---|---|---|---|---|---|
  | F−1 = 29 | before the press | sword-idle Sprite | | | | |
  | F = 30 | 0 | −70 | −2 | 0 | 0 | dead |
  | F+1 = 31 | 2 | −60 | −2 | 0 | 0 | live |
  | F+2 = 32 | 4 | −33.33 | +1.33 | 4 | 1 | live |
  | F+5 = 35 | 10 | +31.25 | +3 | 6 | 0.14 | live |
  | F+6 = 36 | 12 | +35.83 | +2.08 | 4.17 | 0 | dead |
  | F+8 = 38 | 16 | +15.83 | +0.08 | 0.17 | 0 | dead |
  | F+9 = 39 | 18 | sword-idle Sprite | | | | |

  Revision 5's own values for ticks 1, 3, 5 and 7 (−67.5, −53.3, 0, +5) agree with the same keys.
- **Run frames to read.** The header lists frames 30–41 and derives the expected cells: frames 30–33 A, 34–36 B, 37–40 A, 41 B.

**Not yet checked, because nothing ran**
- That frame 0 holds ticks 0–1.
- That the slot-b press really lands on tick 61.
- That the disabled pickup stays untaken in the no-argument run.
- That the screen origin holds at one point.

The logs above would show each of these.
