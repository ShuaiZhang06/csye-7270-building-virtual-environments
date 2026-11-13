I've wired the slash rig into Rudy. Every run you asked for passed, apart from the three pin lines you expected to fail (T1, T2, T6). I changed only the three files you allowed, and nothing is committed.

One thing differs from what you predicted: both pin runs left `logs/test_rudy_pin_60fps.log` exactly the same as the committed copy, leak line included (ANOMALY 1).

### What changed

- **`rudy_animations.tres`:** the stand-in `slash` (one key on cell 10) is gone. The rig clip is renamed to `slash`: its sub-resource id is now `Animation_slash`, its `resource_name` is `slash`, and its `_data` entry is `&"slash"`. No key, length or loop mode changed, and no other clip changed. Check 2 reads the same 6 tracks, keys and transitions as in step 4a. The library now has 13 clips.
- **`rudy_look.gd`:** `pose` returns `CHAR-SWORD-SLASH` while `SlashRig.visible` is true. Otherwise it returns `CELLS[Sprite.frame]`, as before. `frame()` is still `FRAMES[pose]`, so it returns `CHAR-SWORD-SLASH.png` while the rig shows. The script only reads the two visibilities and never writes them.
  - The getter now finds both nodes with `get_node_or_null()`, and I removed the `@onready var _sprite`. An `@onready` var stays null on a copy that isn't in the tree, so check 9 couldn't have read it.
- **`test_rudy_clips.gd`:**
  - **slash_rig renamed:** `RIG_CLIP` is now `&"slash"`. Check 2's two `slash_rig` lines, check 3 and the four step-4a NEGATIVE lines (on checks 1, 1b, 2 and 3) now read `slash`, with the same expectations and the reason strings renamed.
  - **Stand-in removed:** its entry (cell 10) is out of `CLIPS`. So check 4's three-track rule, check 4's frame-cell check and check 2's one-track timing now cover the 12 state clips other than `slash`.
  - **Check 7:** an exact match again. The library holds the 12 clips plus `slash` and nothing else, and exactly the names `_pick_clip()` returns. The step-4a exemption for `slash_rig` is gone.
  - **The `slash_rig` text check:** kept, and it now also scans `rudy_animations.tres`, so no clip or sub-resource may be called `slash_rig`. Its NEGATIVE line is kept.
  - **New check 9, the pose rule:** it runs on a fresh copy of `rudy.tscn` that is never added to the tree and has no current animation. The Sprite is on cell 9 in both cases, so a pose read from the cell alone would say `CHAR-SWORD-IDLE` while the rig shows. To read `Rudy.pose` on that copy, the test sets the copy's `_look` by hand.
  - **Its NEGATIVE line uses text, as you asked:** I took `rudy_look.gd`'s text, removed the SlashRig branch from the getter, and loaded it as a new `GDScript` on a copy's Look. I had to drop the `class_name` line, because a second script can't take the name `RudyLook`. The control line now also loads the undamaged text the same way and shows it passes check 9.

### `scripts/run-test.sh test_rudy_clips.tscn 60`

```
READBACK
PASS  1 every track resolves to a real node and property (track_problems)  (42 tracks)
PASS  1b every track path with a second subname resolves with get_indexed(), to the type it keys  (slash track 5 SlashRig/Lean/Arc:modulate:a)
PASS  2 key times and clip lengths match the brief to within 1 us  (12 state clips besides slash, 60 keys in all 13 clips)
PASS  2 slash (the rig clip): 6 tracks in order, key times = section 2.2's ticks / 60 to within 1 us, values, transitions, update modes, length 17/60 s  (length 0.283333 s, 6 tracks; Sprite:visible [update 1]: 0.000000 s (tick 0.00) = false @ 1.0; SlashRig:visible [update 1]: 0.000000 s (tick 0.00) = true @ 1.0; SlashRig/Lean/Grip:rotation_degrees [update 0]: 0.000000 s (tick 0.00) = -70.0 @ 2.0, 0.033333 s (tick 2.00) = -60.0 @ 2.0, 0.083333 s (tick 5.00) = 0.0 @ 2.0, 0.183333 s (tick 11.00) = 45.0 @ 0.5, 0.283333 s (tick 17.00) = 15.0 @ 1.0; SlashRig/Lean:rotation_degrees [update 0]: 0.000000 s (tick 0.00) = -2.0 @ 1.0, 0.033333 s (tick 2.00) = -2.0 @ 1.0, 0.083333 s (tick 5.00) = 3.0 @ 1.0, 0.183333 s (tick 11.00) = 3.0 @ 0.5, 0.283333 s (tick 17.00) = 0.0 @ 1.0; SlashRig/Lean:position [update 0]: 0.000000 s (tick 0.00) = (0.0, 0.0) @ 1.0, 0.033333 s (tick 2.00) = (0.0, 0.0) @ 1.0, 0.083333 s (tick 5.00) = (6.0, 0.0) @ 1.0, 0.183333 s (tick 11.00) = (6.0, 0.0) @ 0.5, 0.283333 s (tick 17.00) = (0.0, 0.0) @ 1.0; SlashRig/Lean/Arc:modulate:a [update 0]: 0.000000 s (tick 0.00) = 0.0 @ 1.0, 0.033333 s (tick 2.00) = 0.0 @ 1.0, 0.066667 s (tick 4.00) = 1.0 @ 1.0, 0.183333 s (tick 11.00) = 0.0 @ 1.0, 0.283333 s (tick 17.00) = 0.0 @ 1.0)
PASS  2 slash (the rig clip): Grip by value_track_interpolate() on tick 3 in [-60, -40] deg and on tick 16 in [+15, +20] deg (section 7)  (Grip by tick 0:-70.00 1:-67.50 2:-60.00 3:-53.33 4:-33.33 5:0.00 6:1.25 7:5.00 8:11.25 9:20.00 10:31.25 11:45.00 12:35.83 13:28.33 14:22.50 15:18.33 16:15.83 17:15.00)
PASS  3 loop_mode is LOOP_LINEAR for run, sword_run and the one-key clips, LOOP_NONE for slash
PASS  4 every state clip except slash has 3 tracks: Sprite:frame, Sprite:visible true and SlashRig:visible false at 0, all discrete
PASS  4 every frame track is discrete, every frame key is inside the sheet, below the Sprite's hframes x vframes, and on its cell  (sheet 1640x1544 px / cell 410x386 = 4x4 = 16 cells; Sprite 4 x 4 = 16 cells)
PASS  5 the player: callback_mode_process physics, autoplay empty, speed_scale 1.0, root_node .., the library as its default  (callback 0, autoplay "", speed_scale 1.0, root_node ..)
PASS  6 the Sprite: 4 x 4 on the 1640 x 1544 sheet with mipmaps, offset, scale, centring, material and filter as today, RudyLook's cell table in frames.json's order  (4 x 4, rudy_sheet.png 1640x1544, offset (-205.0, -370.0), scale (0.5, 0.5), centered false, 16 cells)
PASS  7 the library holds exactly section 3's 13 clips (slash the rig clip), and exactly the names _pick_clip() can return  (13 clips; _pick_clip() returns celebrate, respawn, defeat, hurt, slash, sword_fall, fall, sword_rise, rise, sword_run, run, sword_idle, idle)
PASS  8 the rig: Look/Sprite, SlashRig (hidden), AnimationPlayer; SlashRig/Lean at (0, 0) holds Grip (holding Blade), Body, Arc in that order; Grip at the grip point and Blade cancelling it  (Look ["Sprite", "SlashRig", "AnimationPlayer"]; SlashRig visible false; Lean ["Grip", "Body", "Arc"]; Grip at (27.12, -102.75); Blade at (-27.12, 102.75))
PASS  8 the rig parts: their PNGs at 410 x 386 with mipmaps, scale 0.5, not centred, offset (-205, -370), the outline on Blade and Body and none on Arc, every rig node on its parent's filter
PASS  text: rudy.gd and rudy_look.gd assign neither the Sprite's texture nor its frame
PASS  9 the pose rule (section 3), on a copy not in the tree, no clip played: SlashRig shown, Sprite hidden on cell 9 -> pose CHAR-SWORD-SLASH and frame() its PNG; SlashRig hidden, Sprite shown on cell 9 -> CHAR-SWORD-IDLE; RudyLook.pose and Rudy.pose  (SlashRig shown, Sprite hidden on cell 9: pose CHAR-SWORD-SLASH, frame() CHAR-SWORD-SLASH.png, Rudy.pose CHAR-SWORD-SLASH; SlashRig hidden, Sprite shown on cell 9: pose CHAR-SWORD-IDLE, frame() CHAR-SWORD-IDLE.png, Rudy.pose CHAR-SWORD-IDLE)
PASS  text: neither rudy.gd, rudy_look.gd nor rudy_animations.tres names slash_rig, step 4a's name for the rig clip (Revision 4)
PASS  10.9 no Godot 3 name in rudy.tscn or rudy_animations.tres (playback_speed; loop =, playing =, frames = at a line start)
PASS  10.9 the scan does not flag the Godot 4 names hframes =, vframes =, loop_mode =, sprite_frames =, speed_scale =
NEGATIVE
PASS  control: an undamaged copy passes checks 1, 1b, 2, 3, 4, 6, 7, 8 and the text checks, and rudy_look.gd's undamaged text loaded as a new script passes check 9, so each failure below comes from its damage
PASS  1 idle's track to Sprite:frames, a missing property: must fail on "idle track 0"  (idle track 0: Sprite has no property frames)
PASS  2 run's second key at 8/60 s instead of 0.125 s: must fail on "run key 1"  (run key 1 at 0.133333 s, want 0.125000)
PASS  3 idle set to LOOP_NONE: must fail on "idle loop_mode"  (idle loop_mode 0, want 1)
PASS  4 sword_run's frame track on continuous updates: must fail on "sword_run track 0 update"  (sword_run track 0 update mode 0, want UPDATE_DISCRETE (1))
PASS  4 fall keyed to cell 16, outside the sheet: must fail on "fall key 0 cell 16 is outside"  (fall key 0 cell 16 is outside the sheet's 16 cells; fall key 0 cell 16 is outside the Sprite's 16 cells (hframes x vframes); fall key 0 cell 16, want 4)
PASS  4 rise keyed to cell 4 instead of 3: must fail on "rise key 0 cell 4, want 3"  (rise key 0 cell 4, want 3)
PASS  5 the player on the idle callback: must fail on "callback_mode_process"  (callback_mode_process 1, want physics (0))
PASS  7 hurt removed from the library: must fail on "missing hurt"  (missing hurt; _pick_clip() returns hurt, which has no clip)
PASS  4 the Sprite sliced 2 x 2, so cells 4 to 15 lie outside it: must fail on "outside the Sprite's 4 cells"  (celebrate key 0 cell 8 is outside the Sprite's 4 cells (hframes x vframes); respawn key 0 cell 7 is outside the Sprite's 4 cells (hframes x vframes); defeat key 0 cell 6 is outside the Sprite's 4 cells (hframes x vframes); hurt key 0 cell 5 is outside the Sprite's 4 cells (hframes x vframes); sword_rise key 0 cell 14 is outside the Sprite's 4 cells (hframes x vframes); fall key 0 cell 4 is outside the Sprite's 4 cells (hframes x vframes); sword_fall key 0 cell 15 is outside the Sprite's 4 cells (hframes x vframes); sword_run key 0 cell 12 is outside the Sprite's 4 cells (hframes x vframes); sword_run key 1 cell 13 is outside the Sprite's 4 cells (hframes x vframes); sword_idle key 0 cell 9 is outside the Sprite's 4 cells (hframes x vframes))
PASS  6 the Sprite sliced 16 x 1: must fail on "sliced 16 x 1"  (the Sprite sliced 16 x 1, want 4 x 4)
PASS  6 the Sprite's texture a whole PNG (CHAR-IDLE.png): must fail on "want the sheet"  (the Sprite's texture is res://content/rudy/frames/CHAR-IDLE.png at (410, 386), want the sheet res://content/rudy/sheet/rudy_sheet.png at (1640, 1544))
PASS  7 a clip the selector never returns (wave) added to the library: must fail on "wave is in the library but _pick_clip() never returns it"  (extra wave; wave is in the library but _pick_clip() never returns it)
PASS  text: rudy_look.gd's text with a line that sets the Sprite's texture: must fail on "rudy_look.gd: assigns the Sprite's texture"  (rudy_look.gd: assigns the Sprite's texture on line 91: _sprite.texture = FRAMES[&"CHAR-IDLE"])
PASS  10.9 the scene's text with speed_scale written as playback_speed: must fail on "playback_speed"  (rudy.tscn: playback_speed)
PASS  10.9 the library's text with loop_mode written as loop = true: must fail on "loop ="  (rudy_animations.tres: "loop =" at a line start; [the same, 12 times in all])
PASS  10.9 the scene's text with a line playing = true: must fail on "playing ="  (rudy.tscn: "playing =" at a line start)
PASS  10.9 the scene's text with a line frames = ...: must fail on "frames ="  (rudy.tscn: "frames =" at a line start)
PASS  1 slash's Grip track on SlashRig/Grip, a path that drops Lean: must fail on "slash track 2: no node at SlashRig/Grip"  (slash track 2: no node at SlashRig/Grip:rotation_degrees)
PASS  1 (why 1b exists) track_problems() reads only the first subname, so it passes Arc keyed on modulate:alpha
PASS  1b slash's Arc track keyed on modulate:alpha, which Color does not have: must fail on "slash track 5: Arc does not resolve modulate:alpha"  (slash track 5: Arc does not resolve modulate:alpha with get_indexed())
PASS  2 slash's 5/60 s Grip key moved to 6/60 s: must fail on "slash track 2 key 2 at"  (slash track 2 key 2 at 0.100000 s (tick 6.00), want tick 5 = 0.083333 s)
PASS  3 slash set to LOOP_LINEAR: must fail on "slash loop_mode"  (slash loop_mode 1, want LOOP_NONE (0))
PASS  4 hurt's SlashRig:visible key removed: must fail on "hurt SlashRig:visible has 0 keys"  (hurt SlashRig:visible has 0 keys, want one at 0.0 s of false)
PASS  8 Blade (with its Grip) moved after Body in the tree: must fail on "Blade draws after Body"  (Lean's children ["Body", "Grip", "Arc"], want ["Grip", "Body", "Arc"]; Blade draws after Body: Grip (holding Blade) is child 1 of Lean, Body child 0)
PASS  8 Grip moved 4 px off the grip point: must fail on "Grip at"  (Grip at (31.12, -102.75), rotation 0.0, scale (1.0, 1.0); want the grip point (27.12, -102.75), 0, 1; Blade at (-27.12, 102.75) does not cancel Grip at (31.12, -102.75))
PASS  text: rudy_look.gd's text with a line that plays slash_rig: must fail on "rudy_look.gd names slash_rig"  (rudy_look.gd names slash_rig)
PASS  9 rudy_look.gd's text with its pose ignoring SlashRig (the SlashRig branch removed): must fail on "SlashRig shown, Sprite hidden on cell 9: pose CHAR-SWORD-IDLE, want CHAR-SWORD-SLASH"  (SlashRig shown, Sprite hidden on cell 9: pose CHAR-SWORD-IDLE, want CHAR-SWORD-SLASH; SlashRig shown, Sprite hidden on cell 9: frame() CHAR-SWORD-IDLE.png, want CHAR-SWORD-SLASH.png)
RESULT PASS: 46 checks, 0 failed
```

The only shortening is the `loop = true` line, which repeats one message 12 times. The run printed nothing else, and the wrapper flagged nothing.

### `scripts/run-test.sh test_rudy_pin.tscn 60`, twice

Both runs printed the same lines:

```
== TIMING ==
FAIL  T1 run from a standstill: moves on the press tick, CHAR-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
FAIL  T2 run from a standstill: moves on the press tick, CHAR-SWORD-RUN-A first, cells [7, 8, 7, 8, 7, 7, 8, 7, 1]  (moves on press tick: true, first CHAR-SWORD-RUN-A, cells [8, 8, 7, 8, 7, 8, 7, 7])
PASS  T3 slash pose on ticks 0-16, swing ends on tick 17 with CHAR-SWORD-IDLE  (slash pose 17 ticks, ends on tick 17, then CHAR-SWORD-IDLE)
PASS  T4 hitbox live on ticks 2-10  (live on ticks 2-10 (9 ticks))
PASS  T5 a press read on swing tick 17 is ignored; one on tick 18 starts a swing  (presses read: true, tick 17 starts a swing: false, tick 18 starts a swing: true)
FAIL  T6 the run resumes after a slash  (restarts: CHAR-SWORD-RUN-A for 4 ticks before the swing, CHAR-SWORD-RUN-A for 8 ticks after it)
PASS  T7 CHAR-IDLE 5 ticks after the release is read  (5 ticks)
PASS  T8 a turn faces left on its tick and moves 7 ticks later  (faces left at once: true, moves after 7 ticks)
PASS  T9 HURT lasts 21 ticks  (21 ticks)
== INVARIANT ==
PASS  I1 the hitbox is live only in CHAR-SWORD-SLASH; every full swing has one dead-to-live edge and 9 live ticks  (8 swings, live ticks [9, 9, 9, 9, 9, 9, 9, 4]; live outside the pose on []; [])
PASS  I2 no swing starts during a swing (presses read on swing ticks [1, 2, 10, 11, 16, 17, 18])  (presses read on [1, 2, 10, 11, 16, 17, 18]; swings begun mid-swing at []; swings begun on ticks 1-17 of the repress swing: [])
PASS  I3 one slash sound per swing, on the swing's first tick  (8 sounds on ticks [311, 347, 365, 398, 451, 508, 668, 915]; 8 swings from ticks [311, 347, 365, 398, 451, 508, 668, 915])
PASS  I4 on a hit's tick during a swing: CHAR-HURT, swing over, hitbox dead, sword gone  (hit on swing tick 6; previous tick swinging: true; then pose CHAR-HURT, clock -1.0000, live false, gear 0)
PASS  I5 every tick RudyLook.frame() equals RudyLook.FRAMES[Rudy.pose]  (0 of 953 ticks wrong)
PASS  I6 CHAR-SWORD-* poses only with the sword; plain idle, run, rise and fall only without it  (638 sword-pose ticks, 294 plain-pose ticks, wrong on [])
PASS  I7 jump read on swing tick 1: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I7 jump read on swing tick 5: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I7 jump read on swing tick 12: takes off on that tick, the swing keeps the floor swing's pose and live ticks, then a sword air pose  (takeoff: true, swing 17 ticks, pose 17 ticks, live 2-10 (9 ticks), then CHAR-SWORD-RISE)
PASS  I8 a slash press without the sword: no swing, no sound, hitbox never live  (press read: true, gear 0, swing: false, live: false, sounds 0)
RESULT FAIL: 19 checks, 3 failed, 953 ticks
```

That is 16 of 19, with only T1, T2 and T6 failing, as in step 2b. Every INVARIANT line passes.

`git diff logs/test_rudy_pin_60fps.log` is **empty after each run**. The log is byte-identical to the committed one, including `WARNING: 18 ObjectDB instances were leaked`.

### `scripts/run-test.sh checks.tscn 60`

- **Last line:** `all checks passed`.
- **Counts:** 141 PASS, 0 FAIL.
- **res:// paths:** `(96 paths; missing: )`, unchanged.
- **Its log diff:** two lines changed, both noise:
  - the camera offset, `(2.145133, 0.599853)` → `(5.303154, 3.369257)`, from the unseeded `randf_range` at `main.gd:97`;
  - the leak line, 29 → 38.

### The other earlier tests, against section 5

| Test | Result | Section 5 |
|---|---|---|
| `invulnerable_tint_checks.tscn` at 30, 60, 144 | 15 PASS at each rate, 0 FAIL | 15 at each |
| `test_slash_sparks_config.gd` | 108 checks, `0 failure(s)` | 108 |
| `test_slash_sparks_state.tscn` | 14 PASS, 0 FAIL | 14 |
| `test_run_dust_config.gd` | 61 checks, `0 failure(s)` | 61 |
| `test_run_dust_state.tscn` | 14 PASS, 0 FAIL | 14 |

Across `logs/`, the only FAIL lines are the pin's three. The two config logs have 109 and 62 lines starting with PASS, because each one's summary line also starts with PASS. None of these six logs changed, so none appears in `git status`.

### git status

```
modified:   game/content/rudy/rudy_animations.tres
modified:   game/content/rudy/rudy_look.gd
modified:   game/tests/test_rudy_clips.gd
modified:   logs/checks_60fps.log
modified:   logs/test_rudy_clips_60fps.log
untracked:  sessions/prompt-8.txt
```

Git also reports a sparse checkout ("52% of tracked files"). Godot wrote no other tracked or untracked file. Anything it wrote to `game/.godot/` wouldn't show, because that folder is ignored.

### git diff of `rudy_animations.tres`

Git lines up the change oddly. It keeps the stand-in's three header lines (`id="Animation_slash"`, `resource_name = "slash"`, `length`) and deletes the stand-in's tracks together with the rig clip's header. The result is the rig clip, unchanged, under id `Animation_slash`.

```diff
@@ -375,46 +375,6 @@ length = 0.283333333333
 tracks/0/type = "value"
 tracks/0/imported = false
 tracks/0/enabled = true
-tracks/0/path = NodePath("Sprite:frame")
-tracks/0/interp = 1
-tracks/0/loop_wrap = true
-tracks/0/keys = {
-"times": PackedFloat32Array(0),
-"transitions": PackedFloat32Array(1),
-"update": 1,
-"values": [10]
-}
-tracks/1/type = "value"
-tracks/1/imported = false
-tracks/1/enabled = true
-tracks/1/path = NodePath("Sprite:visible")
-tracks/1/interp = 1
-tracks/1/loop_wrap = true
-tracks/1/keys = {
-"times": PackedFloat32Array(0),
-"transitions": PackedFloat32Array(1),
-"update": 1,
-"values": [true]
-}
-tracks/2/type = "value"
-tracks/2/imported = false
-tracks/2/enabled = true
-tracks/2/path = NodePath("SlashRig:visible")
-tracks/2/interp = 1
-tracks/2/loop_wrap = true
-tracks/2/keys = {
-"times": PackedFloat32Array(0),
-"transitions": PackedFloat32Array(1),
-"update": 1,
-"values": [false]
-}
-
-[sub_resource type="Animation" id="Animation_slash_rig"]
-resource_name = "slash_rig"
-length = 0.283333333333
-tracks/0/type = "value"
-tracks/0/imported = false
-tracks/0/enabled = true
 tracks/0/path = NodePath("Sprite:visible")
 tracks/0/interp = 1
 tracks/0/loop_wrap = true
@@ -619,7 +579,6 @@ _data = {
 &"rise": SubResource("Animation_rise"),
 &"run": SubResource("Animation_run"),
 &"slash": SubResource("Animation_slash"),
-&"slash_rig": SubResource("Animation_slash_rig"),
 &"sword_fall": SubResource("Animation_sword_fall"),
```

### git diff of `rudy_look.gd`

```diff
@@ -16,7 +16,11 @@ extends Node2D
 ## cells, in frames.json's order: CELLS). Its AnimationPlayer is the only
 ## writer of the Sprite's frame: this script plays the clip the controller
 ## picks and never sets the Sprite's texture or frame (CHANGE-BRIEF.md
-## section 5). The pose on screen is read back from the cell the Sprite shows.
+## section 5). The pose on screen is read back from what is drawn: while the
+## slash's cutout rig (SlashRig) shows, it is CHAR-SWORD-SLASH, the frame the
+## rig is cut from; otherwise it is the pose of the cell the Sprite shows. The
+## player is also the only writer of SlashRig's and the Sprite's visibility:
+## this script only reads them (section 3).
@@ -46,12 +50,21 @@ const CELLS: Array[StringName] = [
-## The asset ID of the pose on screen: the pose of the cell the Sprite shows.
+## The pose the slash rig draws: the frame its parts are cut from (section 2.2).
+const RIG_POSE := &"CHAR-SWORD-SLASH"
+
+## The asset ID of the pose on screen: RIG_POSE while SlashRig shows, else the
+## pose of the cell the Sprite shows. It reads the nodes, not the clip asked
+## for, and finds them by path, so it also reads true on a copy of Rudy that
+## is not in the tree.
 var pose: StringName:
 	get:
-		return CELLS[_sprite.frame] if _sprite else CELLS[0]
+		var rig := get_node_or_null(^"SlashRig") as CanvasItem
+		if rig != null and rig.visible:
+			return RIG_POSE
+		var sprite := get_node_or_null(^"Sprite") as Sprite2D
+		return CELLS[sprite.frame] if sprite else CELLS[0]
 
-@onready var _sprite: Sprite2D = $Sprite
 @onready var _player: AnimationPlayer = $AnimationPlayer
@@ -70,6 +83,7 @@ func play_clip(clip: StringName, restart := false) -> void:
-## The frame on screen now: the original PNG of the pose the Sprite shows.
+## The frame on screen now: the original PNG of the pose on screen. While the
+## rig shows, that is CHAR-SWORD-SLASH.png, the frame the rig is cut from.
```

### ANOMALIES

1. **The pin's log didn't change at all.** You expected it to differ only in its leak count. Both runs left it byte-identical to the committed log, leak line (18) included. The two values differ in how they were found, not what they show, so I see no problem.
2. **Check 9 sets Rudy's `_look` by hand on its copy.** `Rudy.pose` reads `_look`, an `@onready` var that stays null outside the tree, and `rudy.gd` was not to change. So the test sets `_look` on its copy before reading `Rudy.pose`. Adding the copy to the tree instead would have run `_ready()`, which plays `idle`. The NEGATIVE copy checks `RudyLook.pose` and `frame()` only, because its Look has a script that isn't `RudyLook` and so can't go into `_look`'s typed slot.
3. **One case check 9 doesn't cover:** `SlashRig` and the Sprite both visible. The getter would report `CHAR-SWORD-SLASH`. That can't happen today, since every clip keys both visibilities at 0.
4. **What section 5 forbids is checked only for the Sprite's texture and frame.** "No script writes `visible`" is not scanned for. I didn't add that check because it isn't in Revision 4's stages for this step.

### What still needs a human to play

This step is the first time the rig appears on screen, and no test has drawn it. Headless runs draw nothing, so everything below needs a Movie Maker strip or your eyes, at normal speed and at `--time-scale 0.25`:
- **Registration:** whether the rig sits exactly where the Sprite's frame does, with no jump at the cut from idle or run into the slash, or back out on tick 17.
- **Step 4a's motion anomaly:** the blade nearly stops at 0° on ticks 5–7, then turns back fast at tick 11.
- **The art:** the kink at the fist, an outline seam where blade meets hand, any ghost band from the removed arc, and whether the arc's fade reads.
- **Facing:** whether the 6 px lean and the +45° finish read as forward and down, facing either way. The rig flips with `Look` on a turn mid-swing.
- **The invulnerability flash:** whether the rig fades with it after a hit during a swing.
- **Visible Collision Shapes on:** whether the hitbox's live ticks (2–10) line up with the blade's sweep.
- **The run restarts:** T1, T2 and T6, and Revision 4's other run restarts, still to be played before step 6's re-pin.