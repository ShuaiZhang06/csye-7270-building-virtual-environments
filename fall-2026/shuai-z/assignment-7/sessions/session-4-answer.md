I've built step 2a and every test passes: the new read-back passes 21 checks, the pin passes 19, and all the earlier tests keep their section 5 counts. Nothing is committed. Two things differ from your predictions, under ANOMALIES: the res:// path count is 93, not 92, and one detail value in `checks.tscn` changed.

## What was written

- **`game/content/rudy/rudy_animations.tres`** (new): one AnimationLibrary with 13 clips. Each has one value track, `Sprite:frame`, with `"update": 1` (discrete) and `interp = 1`. The clips are 1.0 s and loop (`loop_mode = 1`), except `run` and `sword_run` (0.25 s) and `slash` (17/60 s, no `loop_mode` line, so `LOOP_NONE`).
- **`game/content/rudy/rudy.tscn`**: one new resource line for the library and one new `AnimationPlayer` under `Look`. Nothing else changed; the Sprite still uses `CHAR-IDLE.png` with no `hframes` or `vframes` lines, so both stay at 1.
- **`game/tests/test_rudy_clips.tscn` and `.gd`** (new): the scene loads `rudy.tscn` but never adds it to the tree, and never calls `play()`, `seek()` or `advance()`. `track_problems()` is copied unchanged from `probe_g3_names.gd` lines 2–28. Each damaged copy is a fresh instance with a new library of duplicated clips; the callback copy keeps the loaded library, because that damage is to the player node only.

The test does a few things you didn't list, which is why it has 21 checks:
- A control line: an undamaged copy passes checks 1–4 and 7, so each NEGATIVE failure comes from its damage.
- Four NEGATIVE lines for the text scan (`playback_speed`, `loop =`, `playing =`, `frames =`), so that check can be seen to fail too.
- A READBACK line showing the scan does not flag `hframes =`, `vframes =`, `loop_mode =`, `sprite_frames =` or `speed_scale =`.
- Check 4 also asserts one value track per clip on `Sprite:frame` (Revision 3), with whole-number keys. Check 5 also asserts `root_node` `..`, that the player's parent is `Look`, and that the default library is `rudy_animations.tres`.
- Each NEGATIVE line passes only if the failure message names the damaged clip or field.

## Every clip

Cells are from section 2.1's table and section 3's state table; poses are those cells' frames.

| Clip | Length | Loop | Key time | Cell | Pose in that cell |
|---|---|---|---|---|---|
| `idle` | 1.0 s | LINEAR | 0.0 | 0 | `CHAR-IDLE` |
| `run` | 0.25 s | LINEAR | 0.0 | 1 | `CHAR-RUN-A` |
| | | | 0.125 | 2 | `CHAR-RUN-B` |
| `rise` | 1.0 s | LINEAR | 0.0 | 3 | `CHAR-RISE` |
| `fall` | 1.0 s | LINEAR | 0.0 | 4 | `CHAR-FALL` |
| `hurt` | 1.0 s | LINEAR | 0.0 | 5 | `CHAR-HURT` |
| `defeat` | 1.0 s | LINEAR | 0.0 | 6 | `CHAR-DEFEAT` |
| `respawn` | 1.0 s | LINEAR | 0.0 | 7 | `CHAR-RESPAWN` |
| `celebrate` | 1.0 s | LINEAR | 0.0 | 8 | `CHAR-CELEBRATE` |
| `sword_idle` | 1.0 s | LINEAR | 0.0 | 9 | `CHAR-SWORD-IDLE` |
| `slash` (stand-in) | 17/60 s (0.283333) | NONE | 0.0 (tick 0) | 10 | `CHAR-SWORD-SLASH` |
| `sword_run` | 0.25 s | LINEAR | 0.0 | 12 | `CHAR-SWORD-RUN-A` |
| | | | 0.125 | 13 | `CHAR-SWORD-RUN-B` |
| `sword_rise` | 1.0 s | LINEAR | 0.0 | 14 | `CHAR-SWORD-RISE` |
| `sword_fall` | 1.0 s | LINEAR | 0.0 | 15 | `CHAR-SWORD-FALL` |

No clip uses cell 11 (`CHAR-SWORD-BLOCK`); it stays unused (section 13).

## Real output

**`scripts/run-test.sh test_rudy_clips.tscn 60`** (final run):
```
READBACK
PASS  1 every track resolves to a real node and property (track_problems)  (13 tracks)
PASS  2 key times and clip lengths match the brief to within 1 us  (13 clips, 15 keys)
PASS  3 loop_mode is LOOP_LINEAR for run, sword_run and the one-key clips, LOOP_NONE for slash
PASS  4 every frame track is discrete, every frame key is inside the sheet and on its cell  (sheet 1640x1544 px / cell 410x386 = 4x4 = 16 cells)
PASS  5 the player: callback_mode_process physics, autoplay empty, speed_scale 1.0, root_node .., the library as its default  (callback 0, autoplay "", speed_scale 1.0, root_node ..)
PASS  7 the library holds exactly section 3's 13 clips, counting the slash stand-in  (13 clips)
PASS  10.9 no Godot 3 name in rudy.tscn or rudy_animations.tres (playback_speed; loop =, playing =, frames = at a line start)
PASS  10.9 the scan does not flag the Godot 4 names hframes =, vframes =, loop_mode =, sprite_frames =, speed_scale =
NEGATIVE
PASS  control: an undamaged copy passes checks 1, 2, 3, 4 and 7, so each failure below comes from its damage
PASS  1 idle's track to Sprite:frames, a missing property: must fail on "idle track 0"  (idle track 0: Sprite has no property frames)
PASS  2 run's second key at 8/60 s instead of 0.125 s: must fail on "run key 1"  (run key 1 at 0.133333 s, want 0.125000)
PASS  3 idle set to LOOP_NONE: must fail on "idle loop_mode"  (idle loop_mode 0, want 1)
PASS  4 sword_run's frame track on continuous updates: must fail on "sword_run track 0 update"  (sword_run track 0 update mode 0, want UPDATE_DISCRETE (1))
PASS  4 fall keyed to cell 16, outside the sheet: must fail on "fall key 0 cell 16 is outside"  (fall key 0 cell 16 is outside the sheet's 16 cells; fall key 0 cell 16, want 4)
PASS  4 rise keyed to cell 4 instead of 3: must fail on "rise key 0 cell 4, want 3"  (rise key 0 cell 4, want 3)
PASS  5 the player on the idle callback: must fail on "callback_mode_process"  (callback_mode_process 1, want physics (0))
PASS  7 hurt removed from the library: must fail on "missing hurt"  (missing hurt)
PASS  10.9 the scene's text with speed_scale written as playback_speed: must fail on "playback_speed"  (rudy.tscn: playback_speed)
PASS  10.9 the library's text with loop_mode written as loop = true: must fail on "loop ="  (rudy_animations.tres: "loop =" at a line start; … the same, 12 times in all, once per looping clip)
PASS  10.9 the scene's text with a line playing = true: must fail on "playing ="  (rudy.tscn: "playing =" at a line start)
PASS  10.9 the scene's text with a line frames = ...: must fail on "frames ="  (rudy.tscn: "frames =" at a line start)
RESULT PASS: 21 checks, 0 failed
```
In the `loop =` line I shortened the 12 identical messages, which the log has in full. The first run's callback line also failed on the library path, because that copy had a new in-memory library; I changed that case to keep the loaded library and reran, and the output above is the rerun.

**`scripts/run-test.sh test_rudy_pin.tscn 60`**: `RESULT PASS: 19 checks, 0 failed, 953 ticks`. `git diff logs/test_rudy_pin_60fps.log` shows only the leak count:
```
-WARNING: 18 ObjectDB instances were leaked at exit (run with `--verbose` for details).
+WARNING: 17 ObjectDB instances were leaked at exit (run with `--verbose` for details).
```

**`scripts/run-test.sh checks.tscn 60`**: the last line is `all checks passed`, with 141 PASS lines and no FAIL. The path line reads `(93 paths; missing: )`, up from 90.

**Earlier tests against section 5**: all count as expected, with no FAIL in any log. Their logs are byte-identical to the committed ones (`git diff --stat logs/` lists only `checks` and `test_rudy_pin`).

| Test | Section 5 | Measured |
|---|---|---|
| `invulnerable_tint_checks.tscn` at 30, 60, 144 | 15 each | 15, 15, 15 (`all checks passed`) |
| `test_slash_sparks_config.gd` | 108 checks | 108, plus the summary line `PASS  test_slash_sparks_config: 0 failure(s)` |
| `test_slash_sparks_state.tscn` | 14 | 14 |
| `test_run_dust_config.gd` | 61 checks | 61, plus the summary line `PASS  test_run_dust_config: 0 failure(s)` |
| `test_run_dust_state.tscn` | 14 | 14 |

I didn't capture the wrapper's exit status separately: commands with `;` or `&&` were refused, and most runs went through `| tail`. No run printed the wrapper's `run-test.sh: FAILED on an error line` message.

## ANOMALIES

1. **The res:// path count is 93, not 92.** The three new paths:
   - `res://content/rudy/rudy_animations.tres`, named in `rudy.tscn`;
   - `res://tests/test_rudy_clips.gd`, named in `test_rudy_clips.tscn`;
   - `res://content/rudy/sheet/rudy_sheet.png`, named in `test_rudy_clips.gd`. The test loads the sheet to get check 4's limit from its size, as Revision 3 asks. No file named this path before; the `.import` file names it, but `checks.gd` doesn't scan `.import` files.
2. **One detail value in `checks.tscn` changed.** In the line `he shows CHAR-HURT, and the camera shakes`, the camera offset went from `(0.056848, -6.790619)` to `(4.082537, -4.644651)`. The check passes. My guess is that the shake is random, but I haven't checked that in the code.

## Other files

- Godot wrote no `.uid` file: `git status` shows none, including for `test_rudy_clips.gd`. I didn't inspect the ignored `game/.godot/` cache.
- The only other changes are the wrapper's logs: `checks_60fps.log` and `test_rudy_pin_60fps.log` modified, `test_rudy_clips_60fps.log` new.

**git status:**
```
修改：     game/content/rudy/rudy.tscn
修改：     logs/checks_60fps.log
修改：     logs/test_rudy_pin_60fps.log
未跟踪的文件:
	game/content/rudy/rudy_animations.tres
	game/tests/test_rudy_clips.gd
	game/tests/test_rudy_clips.tscn
	logs/test_rudy_clips_60fps.log
	sessions/prompt-4.txt   (already there before this step)
```

**git diff game/content/rudy/rudy.tscn:**
```diff
 [ext_resource type="Material" path="res://systems/art/outline.tres" id="4_outline"]
+[ext_resource type="AnimationLibrary" path="res://content/rudy/rudy_animations.tres" id="5_anims"]
@@
 offset = Vector2(-205, -370)
 
+[node name="AnimationPlayer" type="AnimationPlayer" parent="Look"]
+root_node = NodePath("..")
+libraries = {
+&"": ExtResource("5_anims")
+}
+autoplay = ""
+speed_scale = 1.0
+callback_mode_process = 0
+
 [node name="SwordHitbox" type="Area2D" parent="."]
```

## What still needs a human

- **The scene's default values.** `root_node`, `autoplay` and `speed_scale` are written out even though they equal Godot's defaults, so the diff shows section 2's settings. Opening and saving `rudy.tscn` in the editor will probably remove those three lines; check 5 reads the values, so it passes either way. Decide whether to keep them.
- **What check 1 can't see yet.** It passes because `Sprite2D` has a `frame` property. With `hframes` and `vframes` at 1, frame 1 and above don't exist on the Sprite yet. Nothing shows that until step 2b puts the sheet on the Sprite (checks 4 and 6 then).
- **The `slash` length.** It is written as `0.283333333333`, which is within 1 µs of 17/60 and passes check 2. Step 4a replaces this clip's tracks.
- **The two anomalies.** Whether 93 paths is acceptable, and whether the camera shake really is random.
- **Nothing to watch yet.** Nothing is wired and the Sprite still shows whole PNGs, so the game looks the same. The first strip and your play verdict come after step 2b.
- **The commit.** Review the diff; the commit is yours. I haven't committed anything.