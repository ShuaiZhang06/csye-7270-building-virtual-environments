I've written the step 4a changes and run every test. The rig is in the scene, hidden. `slash_rig` is in the library with a key at every phase boundary. The read-back passes 44 of 44. The pin's log differs only in its leak line, and every earlier test keeps its count. Nothing is committed, and I touched only the three files you allowed.

The main thing for you: with section 2.2's key values, the blade almost stops at 0° on ticks 5–7, then speeds up again (ANOMALY 1).

### `scripts/run-test.sh test_rudy_clips.tscn 60`, READBACK to RESULT

```
READBACK
PASS  1 every track resolves to a real node and property (track_problems)  (45 tracks)
PASS  1b every track path with a second subname resolves with get_indexed(), to the type it keys  (slash_rig track 5 SlashRig/Lean/Arc:modulate:a)
PASS  2 key times and clip lengths match the brief to within 1 us  (13 clips, 63 keys)
PASS  2 slash_rig: 6 tracks in order, key times = section 2.2's ticks / 60 to within 1 us, values, transitions, update modes, length 17/60 s  (length 0.283333 s, 6 tracks; Sprite:visible [update 1]: 0.000000 s (tick 0.00) = false @ 1.0; SlashRig:visible [update 1]: 0.000000 s (tick 0.00) = true @ 1.0; SlashRig/Lean/Grip:rotation_degrees [update 0]: 0.000000 s (tick 0.00) = -70.0 @ 2.0, 0.033333 s (tick 2.00) = -60.0 @ 2.0, 0.083333 s (tick 5.00) = 0.0 @ 2.0, 0.183333 s (tick 11.00) = 45.0 @ 0.5, 0.283333 s (tick 17.00) = 15.0 @ 1.0; SlashRig/Lean:rotation_degrees [update 0]: 0.000000 s (tick 0.00) = -2.0 @ 1.0, 0.033333 s (tick 2.00) = -2.0 @ 1.0, 0.083333 s (tick 5.00) = 3.0 @ 1.0, 0.183333 s (tick 11.00) = 3.0 @ 0.5, 0.283333 s (tick 17.00) = 0.0 @ 1.0; SlashRig/Lean:position [update 0]: 0.000000 s (tick 0.00) = (0.0, 0.0) @ 1.0, 0.033333 s (tick 2.00) = (0.0, 0.0) @ 1.0, 0.083333 s (tick 5.00) = (6.0, 0.0) @ 1.0, 0.183333 s (tick 11.00) = (6.0, 0.0) @ 0.5, 0.283333 s (tick 17.00) = (0.0, 0.0) @ 1.0; SlashRig/Lean/Arc:modulate:a [update 0]: 0.000000 s (tick 0.00) = 0.0 @ 1.0, 0.033333 s (tick 2.00) = 0.0 @ 1.0, 0.066667 s (tick 4.00) = 1.0 @ 1.0, 0.183333 s (tick 11.00) = 0.0 @ 1.0, 0.283333 s (tick 17.00) = 0.0 @ 1.0)
PASS  2 slash_rig: Grip by value_track_interpolate() on tick 3 in [-60, -40] deg and on tick 16 in [+15, +20] deg (section 7)  (Grip by tick 0:-70.00 1:-67.50 2:-60.00 3:-53.33 4:-33.33 5:0.00 6:1.25 7:5.00 8:11.25 9:20.00 10:31.25 11:45.00 12:35.83 13:28.33 14:22.50 15:18.33 16:15.83 17:15.00)
PASS  3 loop_mode is LOOP_LINEAR for run, sword_run and the one-key clips, LOOP_NONE for slash and slash_rig
PASS  4 every state clip has 3 tracks: Sprite:frame, Sprite:visible true and SlashRig:visible false at 0, all discrete
PASS  4 every frame track is discrete, every frame key is inside the sheet, below the Sprite's hframes x vframes, and on its cell  (sheet 1640x1544 px / cell 410x386 = 4x4 = 16 cells; Sprite 4 x 4 = 16 cells)
PASS  5 the player: callback_mode_process physics, autoplay empty, speed_scale 1.0, root_node .., the library as its default  (callback 0, autoplay "", speed_scale 1.0, root_node ..)
PASS  6 the Sprite: 4 x 4 on the 1640 x 1544 sheet with mipmaps, offset, scale, centring, material and filter as today, RudyLook's cell table in frames.json's order  (4 x 4, rudy_sheet.png 1640x1544, offset (-205.0, -370.0), scale (0.5, 0.5), centered false, 16 cells)
PASS  7 the library holds exactly section 3's 13 clips (counting the slash stand-in) plus slash_rig: the names _pick_clip() can return, plus slash_rig, which it never returns  (14 clips; _pick_clip() returns celebrate, respawn, defeat, hurt, slash, sword_fall, fall, sword_rise, rise, sword_run, run, sword_idle, idle)
PASS  8 the rig: Look/Sprite, SlashRig (hidden), AnimationPlayer; SlashRig/Lean at (0, 0) holds Grip (holding Blade), Body, Arc in that order; Grip at the grip point and Blade cancelling it  (Look ["Sprite", "SlashRig", "AnimationPlayer"]; SlashRig visible false; Lean ["Grip", "Body", "Arc"]; Grip at (27.12, -102.75); Blade at (-27.12, 102.75))
PASS  8 the rig parts: their PNGs at 410 x 386 with mipmaps, scale 0.5, not centred, offset (-205, -370), the outline on Blade and Body and none on Arc, every rig node on its parent's filter
PASS  text: rudy.gd and rudy_look.gd assign neither the Sprite's texture nor its frame
PASS  text: neither rudy.gd nor rudy_look.gd names slash_rig, so nothing plays it (Revision 4)
PASS  10.9 no Godot 3 name in rudy.tscn or rudy_animations.tres (playback_speed; loop =, playing =, frames = at a line start)
PASS  10.9 the scan does not flag the Godot 4 names hframes =, vframes =, loop_mode =, sprite_frames =, speed_scale =
NEGATIVE
PASS  control: an undamaged copy passes checks 1, 1b, 2, 3, 4, 6, 7, 8 and the text checks, so each failure below comes from its damage
PASS  1 idle's track to Sprite:frames, a missing property: must fail on "idle track 0"  (idle track 0: Sprite has no property frames)
PASS  2 run's second key at 8/60 s instead of 0.125 s: must fail on "run key 1"  (run key 1 at 0.133333 s, want 0.125000)
PASS  3 idle set to LOOP_NONE: must fail on "idle loop_mode"  (idle loop_mode 0, want 1)
PASS  4 sword_run's frame track on continuous updates: must fail on "sword_run track 0 update"  (sword_run track 0 update mode 0, want UPDATE_DISCRETE (1))
PASS  4 fall keyed to cell 16, outside the sheet: must fail on "fall key 0 cell 16 is outside"  (fall key 0 cell 16 is outside the sheet's 16 cells; fall key 0 cell 16 is outside the Sprite's 16 cells (hframes x vframes); fall key 0 cell 16, want 4)
PASS  4 rise keyed to cell 4 instead of 3: must fail on "rise key 0 cell 4, want 3"  (rise key 0 cell 4, want 3)
PASS  5 the player on the idle callback: must fail on "callback_mode_process"  (callback_mode_process 1, want physics (0))
PASS  7 hurt removed from the library: must fail on "missing hurt"  (missing hurt; _pick_clip() returns hurt, which has no clip)
PASS  4 the Sprite sliced 2 x 2, so cells 4 to 15 lie outside it: must fail on "outside the Sprite's 4 cells"  (celebrate key 0 cell 8 is outside the Sprite's 4 cells (hframes x vframes); respawn key 0 cell 7 is outside the Sprite's 4 cells (hframes x vframes); defeat key 0 cell 6 is outside the Sprite's 4 cells (hframes x vframes); hurt key 0 cell 5 is outside the Sprite's 4 cells (hframes x vframes); slash key 0 cell 10 is outside the Sprite's 4 cells (hframes x vframes); sword_rise key 0 cell 14 is outside the Sprite's 4 cells (hframes x vframes); fall key 0 cell 4 is outside the Sprite's 4 cells (hframes x vframes); sword_fall key 0 cell 15 is outside the Sprite's 4 cells (hframes x vframes); sword_run key 0 cell 12 is outside the Sprite's 4 cells (hframes x vframes); sword_run key 1 cell 13 is outside the Sprite's 4 cells (hframes x vframes); sword_idle key 0 cell 9 is outside the Sprite's 4 cells (hframes x vframes))
PASS  6 the Sprite sliced 16 x 1: must fail on "sliced 16 x 1"  (the Sprite sliced 16 x 1, want 4 x 4)
PASS  6 the Sprite's texture a whole PNG (CHAR-IDLE.png): must fail on "want the sheet"  (the Sprite's texture is res://content/rudy/frames/CHAR-IDLE.png at (410, 386), want the sheet res://content/rudy/sheet/rudy_sheet.png at (1640, 1544))
PASS  7 a clip the selector never returns (wave) added to the library: must fail on "wave is in the library but _pick_clip() never returns it"  (extra wave; wave is in the library but _pick_clip() never returns it)
PASS  text: rudy_look.gd's text with a line that sets the Sprite's texture: must fail on "rudy_look.gd: assigns the Sprite's texture"  (rudy_look.gd: assigns the Sprite's texture on line 77: _sprite.texture = FRAMES[&"CHAR-IDLE"])
PASS  10.9 the scene's text with speed_scale written as playback_speed: must fail on "playback_speed"  (rudy.tscn: playback_speed)
PASS  10.9 the library's text with loop_mode written as loop = true: must fail on "loop ="  (rudy_animations.tres: "loop =" at a line start; [the same, 12 times in all])
PASS  10.9 the scene's text with a line playing = true: must fail on "playing ="  (rudy.tscn: "playing =" at a line start)
PASS  10.9 the scene's text with a line frames = ...: must fail on "frames ="  (rudy.tscn: "frames =" at a line start)
PASS  1 slash_rig's Grip track on SlashRig/Grip, a path that drops Lean: must fail on "slash_rig track 2: no node at SlashRig/Grip"  (slash_rig track 2: no node at SlashRig/Grip:rotation_degrees)
PASS  1 (why 1b exists) track_problems() reads only the first subname, so it passes Arc keyed on modulate:alpha
PASS  1b slash_rig's Arc track keyed on modulate:alpha, which Color does not have: must fail on "slash_rig track 5: Arc does not resolve modulate:alpha"  (slash_rig track 5: Arc does not resolve modulate:alpha with get_indexed())
PASS  2 slash_rig's 5/60 s Grip key moved to 6/60 s: must fail on "slash_rig track 2 key 2 at"  (slash_rig track 2 key 2 at 0.100000 s (tick 6.00), want tick 5 = 0.083333 s)
PASS  3 slash_rig set to LOOP_LINEAR: must fail on "slash_rig loop_mode"  (slash_rig loop_mode 1, want LOOP_NONE (0))
PASS  4 hurt's SlashRig:visible key removed: must fail on "hurt SlashRig:visible has 0 keys"  (hurt SlashRig:visible has 0 keys, want one at 0.0 s of false)
PASS  8 Blade (with its Grip) moved after Body in the tree: must fail on "Blade draws after Body"  (Lean's children ["Body", "Grip", "Arc"], want ["Grip", "Body", "Arc"]; Blade draws after Body: Grip (holding Blade) is child 1 of Lean, Body child 0)
PASS  8 Grip moved 4 px off the grip point: must fail on "Grip at"  (Grip at (31.12, -102.75), rotation 0.0, scale (1.0, 1.0); want the grip point (27.12, -102.75), 0, 1; Blade at (-27.12, 102.75) does not cancel Grip at (31.12, -102.75))
PASS  text: rudy_look.gd's text with a line that plays slash_rig: must fail on "rudy_look.gd names slash_rig"  (rudy_look.gd names slash_rig)
RESULT PASS: 44 checks, 0 failed
```

The only shortening is in the `loop = true` line, where one message is repeated 12 times.

### `scripts/run-test.sh test_rudy_pin.tscn 60`

`RESULT FAIL: 19 checks, 3 failed, 953 ticks`, which is 16 of 19 as committed. The failures are T1, T2 and T6, with the same detail as step 2b. Exit 1, as expected.

```diff
@@ -977,7 +977,7 @@
 RESULT FAIL: 19 checks, 3 failed, 953 ticks
-WARNING: 18 ObjectDB instances were leaked at exit (run with `--verbose` for details).
+WARNING: 14 ObjectDB instances were leaked at exit (run with `--verbose` for details).
```

### `scripts/run-test.sh checks.tscn 60`

- **Last line before the leak warnings:** `all checks passed`.
- **Counts:** 141 PASS, 0 FAIL.
- **res:// paths:** `(96 paths; missing: )`, up from 93, as predicted; the three are the rig PNGs.
- **Other changes in its log:** the leak line (42 → 34), and the camera offset in the "he shows CHAR-HURT, and the camera shakes" line. That offset comes from an unseeded `randf_range` (`game/app/main.gd:97`). It changed in each of the last three commits, so it is noise.

### The other earlier tests, against section 5

| Test | Result | Section 5 |
|---|---|---|
| `invulnerable_tint_checks.tscn` at 30, 60, 144 | 15 PASS, 0 FAIL at each rate | 15 at each |
| `test_slash_sparks_config.gd` | 108 checks, `0 failure(s)` | 108 |
| `test_slash_sparks_state.tscn` | 14 PASS, 0 FAIL | 14 |
| `test_run_dust_config.gd` | 61 checks, `0 failure(s)` | 61 |
| `test_run_dust_state.tscn` | 14 PASS, 0 FAIL | 14 |

All six logs are byte-identical to the committed ones, leak lines included: none of them appears in `git status`. The config logs show 109 and 62 lines starting with PASS, because the final summary line also starts with PASS.

### git status

```
 M game/content/rudy/rudy.tscn
 M game/content/rudy/rudy_animations.tres
 M game/tests/test_rudy_clips.gd
 M logs/checks_60fps.log
 M logs/test_rudy_clips_60fps.log
 M logs/test_rudy_pin_60fps.log
?? sessions/prompt-7.txt
```

`rudy_animations.tres` has 389 insertions and 0 deletions, so no existing key changed. No other file appears. If Godot wrote to `game/.godot/` (its import cache), that would not show in `git status` because the folder is ignored, so I can't confirm it from git.

### git diff of `rudy.tscn`

```diff
@@ -5,6 +5,9 @@
 [ext_resource type="AnimationLibrary" path="res://content/rudy/rudy_animations.tres" id="5_anims"]
+[ext_resource type="Texture2D" path="res://content/rudy/rig/slash_blade.png" id="6_blade"]
+[ext_resource type="Texture2D" path="res://content/rudy/rig/slash_body.png" id="7_body"]
+[ext_resource type="Texture2D" path="res://content/rudy/rig/slash_arc.png" id="8_arc"]
@@ -34,6 +37,35 @@ offset = Vector2(-205, -370)
 hframes = 4
 vframes = 4
 
+[node name="SlashRig" type="Node2D" parent="Look"]
+visible = false
+
+[node name="Lean" type="Node2D" parent="Look/SlashRig"]
+
+[node name="Grip" type="Node2D" parent="Look/SlashRig/Lean"]
+position = Vector2(27.12, -102.75)
+
+[node name="Blade" type="Sprite2D" parent="Look/SlashRig/Lean/Grip"]
+material = ExtResource("4_outline")
+position = Vector2(-27.12, 102.75)
+scale = Vector2(0.5, 0.5)
+texture = ExtResource("6_blade")
+centered = false
+offset = Vector2(-205, -370)
+
+[node name="Body" type="Sprite2D" parent="Look/SlashRig/Lean"]
+material = ExtResource("4_outline")
+scale = Vector2(0.5, 0.5)
+texture = ExtResource("7_body")
+centered = false
+offset = Vector2(-205, -370)
+
+[node name="Arc" type="Sprite2D" parent="Look/SlashRig/Lean"]
+scale = Vector2(0.5, 0.5)
+texture = ExtResource("8_arc")
+centered = false
+offset = Vector2(-205, -370)
+
 [node name="AnimationPlayer" type="AnimationPlayer" parent="Look"]
```

### slash_rig's keys

`length` is 17/60 s (0.283333) and `loop_mode` is `LOOP_NONE` (0). A key's transition shapes the move from that key to the next one:
- **2.0** is ease-in, x²: it starts slow and speeds up.
- **0.5** is ease-out, 1−(1−x)²: it starts fast and settles.
- **1** is linear.

Track paths are relative to Look.

| Track | Time (s) | From tick | Value | Transition |
|---|---|---|---|---|
| `Sprite:visible` (discrete) | 0 | 0 | false | — |
| `SlashRig:visible` (discrete) | 0 | 0 | true | — |
| `SlashRig/Lean/Grip:rotation_degrees` | 0 | 0 | −70 | 2.0 (ease-in) |
| | 0.033333 | 2 | −60 | 2.0 (ease-in) |
| | 0.083333 | 5 | 0 | 2.0 (ease-in) |
| | 0.183333 | 11 | +45 | 0.5 (ease-out) |
| | 0.283333 | 17 | +15 | 1 (none follows) |
| `SlashRig/Lean:rotation_degrees` | 0 | 0 | −2 | 1 |
| | 0.033333 | 2 | −2 | 1 |
| | 0.083333 | 5 | +3 | 1 |
| | 0.183333 | 11 | +3 | 0.5 (ease-out) |
| | 0.283333 | 17 | 0 | 1 |
| `SlashRig/Lean:position` | 0 / 0.033333 / 0.083333 / 0.183333 / 0.283333 | 0 / 2 / 5 / 11 / 17 | (0,0) / (0,0) / (6,0) / (6,0) / (0,0) | 1 / 1 / 1 / 0.5 (ease-out) / 1 |
| `SlashRig/Lean/Arc:modulate:a` | 0 / 0.033333 / 0.066667 / 0.183333 / 0.283333 | 0 / 2 / **4** / 11 / 17 | 0 / 0 / 1 / 0 / 0 | all 1 (linear) |

Against section 7, by `value_track_interpolate()`: Grip is −53.33° on tick 3 (inside −60 to −40) and +15.83° on tick 16 (inside +15 to +20).

The other 13 clips, the stand-in `slash` included, each gained `Sprite:visible` true and `SlashRig:visible` false at 0, both discrete.

### ANOMALIES

1. **The swing can't accelerate through tick 5 with these key values.**
   - Section 2.2 calls the active phase "accelerating", but its keys move the blade 60° in ticks 2–5 and only 45° in ticks 5–11. That is 20°/tick on average, then 7.5°/tick.
   - With ease-in on 5→11, as the brief says (and as section 8 assumes when it puts horizontal at tick 9–10), Grip goes −33.3° → 0° → 1.25° → 5.0° on ticks 4–7. So the blade moves 33° in one tick, then nearly stops at the drawn angle.
   - At tick 11 the ease-out starts at its fastest, so the blade turns back from +45° at full speed.
   - The two predictions pass. This is measured, not yet seen. The likely fix is an earlier active key, a tuning change that needs a brief revision.
2. **The leak counts went down, not up:** the pin from 18 to 14, `checks` from 42 to 34. Only that line changed in the pin's log, as you asked. I don't know why the count fell.
3. **I changed what the read-back's check 4 expects.** In steps 2a/2b it required exactly one track per clip. It now finds the `Sprite:frame` track by path, and a new check requires the three tracks Revision 4 names. That is the read-back changing with its clip, which section 9 allows, but it is a change to a committed test's code. Every check from step 2a/2b still runs, and each of its NEGATIVE lines still fails for the reason it names.
4. **The chosen transitions are not in the brief yet.** The brief says each change to the key design gets a revision, so the values 2.0 / 0.5 / 1 need recording.

### What still needs a human

- **The slash strip and your eyes, once step 4b wires it.** None of this has been rendered:
  - the stall at ticks 5–7 and the fast turn back at tick 11 (anomaly 1);
  - the kink at the fist (Revision 4);
  - outline seams where the blade meets the hand (row 11);
  - a ghost band from the removed arc (row 12);
  - whether the arc's fade, 0 → 1 by tick 4 and out by tick 11, reads;
  - whether the 6 px Lean and +45° read as forward and down, facing either way.
- **Registration at rest.** No test draws the rig. It is placed from the cut script's numbers and checked as numbers only.
- **The game in play**, which should look exactly as it does now, since nothing plays `slash_rig`. The headless tests agree, but none of them renders.
- **The new read-back test code**, for your review, before you commit step 4a.

Nothing is committed.