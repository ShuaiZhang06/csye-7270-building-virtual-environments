extends Node
## The read-back test for Rudy's clips, steps 2a, 2b and 4a (CHANGE-BRIEF.md
## section 9 as Revisions 3 and 4 stage it; section 10, row 9). Step 2b adds
## check 6, the Sprite on the sheet; check 4's limit from the Sprite's slicing;
## check 7's comparison with the names _pick_clip() returns; and the text check
## that rudy.gd and rudy_look.gd never write the Sprite's texture or frame.
## Step 4a (Revision 4) adds the keyed rig clip slash_rig, not wired: checks 2
## and 3 for its keys, length and loop mode, and a sample of Grip at ticks 3
## and 16 against section 7; check 1b, every track path with a second subname
## resolved with get_indexed(); check 4's two visibility keys on every state
## clip; check 7's library as the selector's names plus slash_rig; check 8, the
## SlashRig nodes; and a text check that no script names slash_rig. Run
## from the assignment folder:
##   scripts/run-test.sh test_rudy_clips.tscn 60
##
## It loads rudy.tscn and reads the AnimationPlayer under Look. It is a scene
## test because rudy.gd names the Sfx autoload (CLAUDE.md). The instance is
## never added to the tree, and the test never calls play(), seek() or
## advance(), so no clip runs and nothing in Rudy moves.
##
## READBACK only reads: the scene's player, its library, its Sprite, the
## sheet's size and .import, frames.json, and the text of rudy.tscn,
## rudy_animations.tres, rudy.gd and rudy_look.gd.
## NEGATIVE runs the same checks on damaged copies made in memory: each copy
## is a fresh instance of rudy.tscn whose player gets a new library of
## duplicated clips, so the library READBACK read is never touched and no file
## is written. Every NEGATIVE line passes only if its check fails, and fails
## for the reason damaged (the problem text names the damaged clip or field).
## Prints PASS/FAIL lines in the two groups, then a RESULT line; quits 1 on
## any failure.

const RUDY := preload("res://content/rudy/rudy.tscn")
const LIBRARY_PATH := "res://content/rudy/rudy_animations.tres"
const SCENE_PATH := "res://content/rudy/rudy.tscn"
const SHEET_PATH := "res://content/rudy/sheet/rudy_sheet.png"
const RUDY_SCRIPT_PATH := "res://content/rudy/rudy.gd"
const LOOK_SCRIPT_PATH := "res://content/rudy/rudy_look.gd"
const MANIFEST_PATH := "res://content/rudy/frames/frames.json"
const OUTLINE_PATH := "res://systems/art/outline.tres"
## Section 2.1: the sheet's size in px.
const SHEET_SIZE := Vector2i(1640, 1544)

## Section 2.1: the sheet's cell, with no padding.
const CELL := Vector2i(410, 386)

## Every clip the library must hold, with its length, loop mode and keys as
## [time in seconds, cell]. Sources: section 2.1's cycle table (run,
## sword_run), section 3's state table (the cells of the one-key clips),
## Revision 3 (one-key clips 1.0 s, LOOP_LINEAR; slash a one-key stand-in on
## cell 10 with section 2.2's length 17/60 s and LOOP_NONE).
const CLIPS := {
	&"celebrate": [1.0, Animation.LOOP_LINEAR, [[0.0, 8]]],
	&"respawn": [1.0, Animation.LOOP_LINEAR, [[0.0, 7]]],
	&"defeat": [1.0, Animation.LOOP_LINEAR, [[0.0, 6]]],
	&"hurt": [1.0, Animation.LOOP_LINEAR, [[0.0, 5]]],
	&"slash": [17.0 / 60.0, Animation.LOOP_NONE, [[0.0, 10]]],
	&"rise": [1.0, Animation.LOOP_LINEAR, [[0.0, 3]]],
	&"sword_rise": [1.0, Animation.LOOP_LINEAR, [[0.0, 14]]],
	&"fall": [1.0, Animation.LOOP_LINEAR, [[0.0, 4]]],
	&"sword_fall": [1.0, Animation.LOOP_LINEAR, [[0.0, 15]]],
	&"run": [0.25, Animation.LOOP_LINEAR, [[0.0, 1], [0.125, 2]]],
	&"sword_run": [0.25, Animation.LOOP_LINEAR, [[0.0, 12], [0.125, 13]]],
	&"idle": [1.0, Animation.LOOP_LINEAR, [[0.0, 0]]],
	&"sword_idle": [1.0, Animation.LOOP_LINEAR, [[0.0, 9]]],
}

## Key times and lengths must match to within 1 microsecond (section 9, check 2).
const TIME_TOLERANCE := 0.000001

## The two visibility keys every state clip carries from step 4a (section 2.2;
## Revision 4): [path, the value keyed at 0.0 s], both discrete.
const STATE_VISIBILITY := [
	[^"Sprite:visible", true],
	[^"SlashRig:visible", false],
]

## Step 4a's keyed rig clip (Revision 4: named slash_rig while the stand-in
## slash stays). Section 2.2's key table, in ticks at 60 (a key's time is its
## tick / 60), 17/60 s long, LOOP_NONE. Each track: [path, update mode,
## [[tick, value, transition], ...]], in the library's track order. The
## transitions are this step's choice for the table's words: 2.0 is Godot's
## ease-in (accelerating), 0.5 its ease-out (settling), 1.0 linear; a key's
## transition shapes the move from it to the next key.
const RIG_CLIP := &"slash_rig"
const RIG_LENGTH := 17.0 / 60.0
const RIG_TRACKS := [
	[^"Sprite:visible", Animation.UPDATE_DISCRETE, [[0, false, 1.0]]],
	[^"SlashRig:visible", Animation.UPDATE_DISCRETE, [[0, true, 1.0]]],
	[^"SlashRig/Lean/Grip:rotation_degrees", Animation.UPDATE_CONTINUOUS,
		[[0, -70.0, 2.0], [2, -60.0, 2.0], [5, 0.0, 2.0], [11, 45.0, 0.5], [17, 15.0, 1.0]]],
	[^"SlashRig/Lean:rotation_degrees", Animation.UPDATE_CONTINUOUS,
		[[0, -2.0, 1.0], [2, -2.0, 1.0], [5, 3.0, 1.0], [11, 3.0, 0.5], [17, 0.0, 1.0]]],
	[^"SlashRig/Lean:position", Animation.UPDATE_CONTINUOUS,
		[[0, Vector2(0, 0), 1.0], [2, Vector2(0, 0), 1.0], [5, Vector2(6, 0), 1.0], [11, Vector2(6, 0), 0.5],
			[17, Vector2(0, 0), 1.0]]],
	[^"SlashRig/Lean/Arc:modulate:a", Animation.UPDATE_CONTINUOUS,
		[[0, 0.0, 1.0], [2, 0.0, 1.0], [4, 1.0, 1.0], [11, 0.0, 1.0], [17, 0.0, 1.0]]],
]
## Section 7: Grip on tick 3 between -60 and -40 deg (the ease-in), and on
## tick 16, the slash's last tick on screen, between +15 and +20 deg (the
## ease-out). [tick, low, high].
const GRIP_SAMPLES := [[3, -60.0, -40.0], [16, 15.0, 20.0]]
const GRIP_TRACK := ^"SlashRig/Lean/Grip:rotation_degrees"

## Section 2.2's rig nodes and Revision 4's grip point, in game px from his
## origin. Each part: [node path under Look, texture, material (or "")].
const GRIP_POINT := Vector2(27.12, -102.75)
const GRIP_TOLERANCE := 0.005
const RIG_PARTS := [
	[^"SlashRig/Lean/Grip/Blade", "res://content/rudy/rig/slash_blade.png", OUTLINE_PATH],
	[^"SlashRig/Lean/Body", "res://content/rudy/rig/slash_body.png", OUTLINE_PATH],
	[^"SlashRig/Lean/Arc", "res://content/rudy/rig/slash_arc.png", ""],
]

var _checks := 0
var _failures := 0
var _copies: Array[Node] = []


func _ready() -> void:
	var rudy: Node = RUDY.instantiate()
	var player: AnimationPlayer = rudy.get_node("Look/AnimationPlayer")
	var sheet: Texture2D = load(SHEET_PATH)
	var limit := _sheet_cells(sheet)
	var sprite := _sprite_of(player)
	var rudy_text := FileAccess.get_file_as_string(RUDY_SCRIPT_PATH)
	var look_text := FileAccess.get_file_as_string(LOOK_SCRIPT_PATH)

	print("READBACK")
	_expect_clean("1 every track resolves to a real node and property (track_problems)",
		track_problems(player), "%d tracks" % _track_count(player))
	_expect_clean("1b every track path with a second subname resolves with get_indexed(), to the type it keys",
		_check_indexed(player), ", ".join(_indexed_paths(player)))
	_expect_clean("2 key times and clip lengths match the brief to within 1 us",
		_check_times(player), "%d clips, %d keys" % [CLIPS.size(), _key_count(player)])
	_expect_clean("2 slash_rig: 6 tracks in order, key times = section 2.2's ticks / 60 to within 1 us, values, transitions, update modes, length 17/60 s",
		_check_rig_clip(player), _rig_key_summary(player))
	_expect_clean("2 slash_rig: Grip by value_track_interpolate() on tick 3 in [-60, -40] deg and on tick 16 in [+15, +20] deg (section 7)",
		_check_rig_samples(player), _grip_trail(player))
	_expect_clean("3 loop_mode is LOOP_LINEAR for run, sword_run and the one-key clips, LOOP_NONE for slash and slash_rig",
		_check_loops(player))
	_expect_clean("4 every state clip has 3 tracks: Sprite:frame, Sprite:visible true and SlashRig:visible false at 0, all discrete",
		_check_state_tracks(player))
	_expect_clean("4 every frame track is discrete, every frame key is inside the sheet, below the Sprite's hframes x vframes, and on its cell",
		_check_frames(player, limit),
		"sheet %dx%d px / cell %dx%d = %dx%d = %d cells; Sprite %d x %d = %d cells" % [sheet.get_width(), sheet.get_height(),
			CELL.x, CELL.y, sheet.get_width() / CELL.x, sheet.get_height() / CELL.y, limit,
			sprite.hframes, sprite.vframes, sprite.hframes * sprite.vframes])
	_expect_clean("5 the player: callback_mode_process physics, autoplay empty, speed_scale 1.0, root_node .., the library as its default",
		_check_player(player),
		"callback %d, autoplay \"%s\", speed_scale %s, root_node %s" % [player.callback_mode_process,
			player.autoplay, player.speed_scale, player.root_node])
	_expect_clean("6 the Sprite: 4 x 4 on the 1640 x 1544 sheet with mipmaps, offset, scale, centring, material and filter as today, RudyLook's cell table in frames.json's order",
		_check_sprite(player),
		"%d x %d, %s %dx%d, offset %s, scale %s, centered %s, %d cells" % [sprite.hframes, sprite.vframes,
			sprite.texture.resource_path.get_file() if sprite.texture else "no texture",
			sprite.texture.get_width() if sprite.texture else 0, sprite.texture.get_height() if sprite.texture else 0,
			sprite.offset, sprite.scale, sprite.centered, RudyLook.CELLS.size()])
	_expect_clean("7 the library holds exactly section 3's 13 clips (counting the slash stand-in) plus slash_rig: the names _pick_clip() can return, plus slash_rig, which it never returns",
		_check_names(player, rudy_text), "%d clips; _pick_clip() returns %s" % [player.get_animation_list().size(),
			", ".join(_selector_names(rudy_text).names)])
	_expect_clean("8 the rig: Look/Sprite, SlashRig (hidden), AnimationPlayer; SlashRig/Lean at (0, 0) holds Grip (holding Blade), Body, Arc in that order; Grip at the grip point and Blade cancelling it",
		_check_rig(player), _rig_summary(player))
	_expect_clean("8 the rig parts: their PNGs at 410 x 386 with mipmaps, scale 0.5, not centred, offset (-205, -370), the outline on Blade and Body and none on Arc, every rig node on its parent's filter",
		_check_rig_parts(player))
	var write_problems := _scan_sprite_writes("rudy.gd", rudy_text)
	write_problems.append_array(_scan_sprite_writes("rudy_look.gd", look_text))
	_expect_clean("text: rudy.gd and rudy_look.gd assign neither the Sprite's texture nor its frame", write_problems)
	_expect_clean("text: neither rudy.gd nor rudy_look.gd names slash_rig, so nothing plays it (Revision 4)",
		_scan_rig_name(rudy_text, look_text))
	var scan_problems := _scan_text("rudy.tscn", FileAccess.get_file_as_string(SCENE_PATH))
	scan_problems.append_array(_scan_text("rudy_animations.tres", FileAccess.get_file_as_string(LIBRARY_PATH)))
	_expect_clean("10.9 no Godot 3 name in rudy.tscn or rudy_animations.tres (playback_speed; loop =, playing =, frames = at a line start)",
		scan_problems)
	_expect_clean("10.9 the scan does not flag the Godot 4 names hframes =, vframes =, loop_mode =, sprite_frames =, speed_scale =",
		_scan_text("sample", "hframes = 4\nvframes = 4\nloop_mode = 1\nsprite_frames = x\nspeed_scale = 1.0\n"))

	print("NEGATIVE")
	var clean := _copy_player()
	var clean_problems := track_problems(clean)
	for list in [_check_indexed(clean), _check_times(clean), _check_rig_clip(clean), _check_rig_samples(clean),
			_check_loops(clean), _check_state_tracks(clean), _check_frames(clean, limit), _check_sprite(clean),
			_check_names(clean, rudy_text), _check_rig(clean), _check_rig_parts(clean),
			_scan_sprite_writes("rudy.gd", rudy_text), _scan_sprite_writes("rudy_look.gd", look_text),
			_scan_rig_name(rudy_text, look_text)]:
		clean_problems.append_array(list)
	_expect_clean("control: an undamaged copy passes checks 1, 1b, 2, 3, 4, 6, 7, 8 and the text checks, so each failure below comes from its damage",
		clean_problems)

	var p := _copy_player()
	p.get_animation(&"idle").track_set_path(0, NodePath("Sprite:frames"))
	_expect_failure("1 idle's track to Sprite:frames, a missing property", track_problems(p), "idle track 0")

	p = _copy_player()
	p.get_animation(&"run").track_set_key_time(0, 1, 8.0 / 60.0)
	_expect_failure("2 run's second key at 8/60 s instead of 0.125 s", _check_times(p), "run key 1")

	p = _copy_player()
	p.get_animation(&"idle").loop_mode = Animation.LOOP_NONE
	_expect_failure("3 idle set to LOOP_NONE", _check_loops(p), "idle loop_mode")

	p = _copy_player()
	p.get_animation(&"sword_run").value_track_set_update_mode(0, Animation.UPDATE_CONTINUOUS)
	_expect_failure("4 sword_run's frame track on continuous updates", _check_frames(p, limit), "sword_run track 0 update")

	p = _copy_player()
	p.get_animation(&"fall").track_set_key_value(0, 0, 16)
	_expect_failure("4 fall keyed to cell 16, outside the sheet", _check_frames(p, limit), "fall key 0 cell 16 is outside")

	p = _copy_player()
	p.get_animation(&"rise").track_set_key_value(0, 0, 4)
	_expect_failure("4 rise keyed to cell 4 instead of 3", _check_frames(p, limit), "rise key 0 cell 4, want 3")

	# A node property, not the library's: a fresh instance keeps the loaded
	# library, so check 5's library line still passes and only the callback fails.
	p = _copy_player(false)
	p.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
	_expect_failure("5 the player on the idle callback", _check_player(p), "callback_mode_process")

	p = _copy_player()
	p.get_animation_library(&"").remove_animation(&"hurt")
	_expect_failure("7 hurt removed from the library", _check_names(p, rudy_text), "missing hurt")

	# Step 2b's checks. Damage to the Sprite is to a fresh instance's node, so
	# the loaded library is kept.
	p = _copy_player(false)
	_sprite_of(p).hframes = 2
	_sprite_of(p).vframes = 2
	_expect_failure("4 the Sprite sliced 2 x 2, so cells 4 to 15 lie outside it", _check_frames(p, limit),
		"outside the Sprite's 4 cells")

	p = _copy_player(false)
	_sprite_of(p).hframes = 16
	_sprite_of(p).vframes = 1
	_expect_failure("6 the Sprite sliced 16 x 1", _check_sprite(p), "sliced 16 x 1")

	p = _copy_player(false)
	_sprite_of(p).texture = RudyLook.FRAMES[&"CHAR-IDLE"]
	_expect_failure("6 the Sprite's texture a whole PNG (CHAR-IDLE.png)", _check_sprite(p), "want the sheet")

	p = _copy_player()
	p.get_animation_library(&"").add_animation(&"wave", p.get_animation(&"idle").duplicate(true))
	_expect_failure("7 a clip the selector never returns (wave) added to the library", _check_names(p, rudy_text),
		"wave is in the library but _pick_clip() never returns it")

	_expect_failure("text: rudy_look.gd's text with a line that sets the Sprite's texture",
		_scan_sprite_writes("rudy_look.gd", look_text + "\n\t_sprite.texture = FRAMES[&\"CHAR-IDLE\"]\n"),
		"rudy_look.gd: assigns the Sprite's texture")

	var scene_text := FileAccess.get_file_as_string(SCENE_PATH)
	var library_text := FileAccess.get_file_as_string(LIBRARY_PATH)
	_expect_failure("10.9 the scene's text with speed_scale written as playback_speed",
		_scan_text("rudy.tscn", scene_text.replace("speed_scale = 1.0", "playback_speed = 1.0")), "playback_speed")
	_expect_failure("10.9 the library's text with loop_mode written as loop = true",
		_scan_text("rudy_animations.tres", library_text.replace("loop_mode = 1", "loop = true")), "loop =")
	_expect_failure("10.9 the scene's text with a line playing = true",
		_scan_text("rudy.tscn", scene_text + "playing = true\n"), "playing =")
	_expect_failure("10.9 the scene's text with a line frames = ...",
		_scan_text("rudy.tscn", scene_text + "frames = SubResource(\"x\")\n"), "frames =")

	# Step 4a's checks (Revision 4).
	p = _copy_player()
	p.get_animation(RIG_CLIP).track_set_path(2, ^"SlashRig/Grip:rotation_degrees")
	_expect_failure("1 slash_rig's Grip track on SlashRig/Grip, a path that drops Lean", track_problems(p),
		"slash_rig track 2: no node at SlashRig/Grip")

	p = _copy_player()
	p.get_animation(RIG_CLIP).track_set_path(5, ^"SlashRig/Lean/Arc:modulate:alpha")
	_expect_clean("1 (why 1b exists) track_problems() reads only the first subname, so it passes Arc keyed on modulate:alpha",
		track_problems(p))
	_expect_failure("1b slash_rig's Arc track keyed on modulate:alpha, which Color does not have", _check_indexed(p),
		"slash_rig track 5: Arc does not resolve modulate:alpha")

	p = _copy_player()
	p.get_animation(RIG_CLIP).track_set_key_time(2, 2, 6.0 / 60.0)
	_expect_failure("2 slash_rig's 5/60 s Grip key moved to 6/60 s", _check_rig_clip(p), "slash_rig track 2 key 2 at")

	p = _copy_player()
	p.get_animation(RIG_CLIP).loop_mode = Animation.LOOP_LINEAR
	_expect_failure("3 slash_rig set to LOOP_LINEAR", _check_loops(p), "slash_rig loop_mode")

	p = _copy_player()
	var hurt := p.get_animation(&"hurt")
	hurt.track_remove_key(hurt.find_track(^"SlashRig:visible", Animation.TYPE_VALUE), 0)
	_expect_failure("4 hurt's SlashRig:visible key removed", _check_state_tracks(p), "hurt SlashRig:visible has 0 keys")

	p = _copy_player(false)
	var lean := p.get_node(^"../SlashRig/Lean")
	lean.move_child(lean.get_node(^"Grip"), lean.get_node(^"Body").get_index())
	_expect_failure("8 Blade (with its Grip) moved after Body in the tree", _check_rig(p), "Blade draws after Body")

	p = _copy_player(false)
	(p.get_node(^"../SlashRig/Lean/Grip") as Node2D).position = GRIP_POINT + Vector2(4, 0)
	_expect_failure("8 Grip moved 4 px off the grip point", _check_rig(p), "Grip at")

	_expect_failure("text: rudy_look.gd's text with a line that plays slash_rig",
		_scan_rig_name(rudy_text, look_text + "\n\t_player.play(&\"slash_rig\")\n"), "rudy_look.gd names slash_rig")

	print("RESULT %s: %d checks, %d failed" % ["PASS" if _failures == 0 else "FAIL", _checks, _failures])
	rudy.free()
	for copy in _copies:
		copy.free()
	get_tree().quit(1 if _failures > 0 else 0)


# Copied unchanged from evidence/brief-probe/tests/probe_g3_names.gd, lines 2-28.
static func track_problems(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var root := player.get_node(player.root_node)
	for clip_name in player.get_animation_list():
		var clip := player.get_animation(clip_name)
		for t in clip.get_track_count():
			var path := clip.track_get_path(t)
			var node := root.get_node_or_null(NodePath(path.get_concatenated_names()))
			if node == null:
				problems.append("%s track %d: no node at %s" % [clip_name, t, path])
				continue
			if path.get_subname_count() == 0:
				continue
			var sub := path.get_subname(0)
			match clip.track_get_type(t):
				Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D, Animation.TYPE_SCALE_3D:
					var skeleton := node as Skeleton3D
					if skeleton == null or skeleton.find_bone(sub) == -1:
						problems.append("%s track %d: no bone %s on %s" % [clip_name, t, sub, node.name])
				Animation.TYPE_BLEND_SHAPE:
					var mesh := node as MeshInstance3D
					if mesh == null or mesh.find_blend_shape_by_name(sub) == -1:
						problems.append("%s track %d: no blend shape %s on %s" % [clip_name, t, sub, node.name])
				_:
					if not (sub in node):
						problems.append("%s track %d: %s has no property %s" % [clip_name, t, node.name, sub])
	return problems


## Check 2: each clip's length, and each key's time on its one track.
func _check_times(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	for clip_name: StringName in CLIPS:
		if not player.has_animation(clip_name):
			problems.append("%s missing" % clip_name)
			continue
		var clip := player.get_animation(clip_name)
		var want_length: float = CLIPS[clip_name][0]
		if absf(clip.length - want_length) > TIME_TOLERANCE:
			problems.append("%s length %.6f s, want %.6f" % [clip_name, clip.length, want_length])
		if clip.get_track_count() < 1:
			problems.append("%s has no track" % clip_name)
			continue
		var keys: Array = CLIPS[clip_name][2]
		if clip.track_get_key_count(0) != keys.size():
			problems.append("%s track 0 has %d keys, want %d" % [clip_name, clip.track_get_key_count(0), keys.size()])
			continue
		for k in keys.size():
			var time := clip.track_get_key_time(0, k)
			if absf(time - float(keys[k][0])) > TIME_TOLERANCE:
				problems.append("%s key %d at %.6f s, want %.6f" % [clip_name, k, time, keys[k][0]])
	return problems


## Check 3: loop modes.
func _check_loops(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	for clip_name: StringName in CLIPS:
		if not player.has_animation(clip_name):
			problems.append("%s missing" % clip_name)
			continue
		var mode := player.get_animation(clip_name).loop_mode
		if mode != CLIPS[clip_name][1]:
			problems.append("%s loop_mode %d, want %d" % [clip_name, mode, CLIPS[clip_name][1]])
	if not player.has_animation(RIG_CLIP):
		problems.append("%s missing" % RIG_CLIP)
	elif player.get_animation(RIG_CLIP).loop_mode != Animation.LOOP_NONE:
		problems.append("%s loop_mode %d, want LOOP_NONE (%d)"
			% [RIG_CLIP, player.get_animation(RIG_CLIP).loop_mode, Animation.LOOP_NONE])
	return problems


## Check 4, step 4a's part (Revision 4): every state clip has exactly three
## tracks, a value track on Sprite:frame and the two visibility tracks of
## STATE_VISIBILITY, all UPDATE_DISCRETE, each visibility track one key at 0.0
## s of its value. _check_frames reads the frame track's keys.
func _check_state_tracks(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	for clip_name: StringName in CLIPS:
		if not player.has_animation(clip_name):
			problems.append("%s missing" % clip_name)
			continue
		var clip := player.get_animation(clip_name)
		if clip.get_track_count() != 3:
			problems.append("%s has %d tracks, want 3 (Sprite:frame, Sprite:visible, SlashRig:visible)"
				% [clip_name, clip.get_track_count()])
		var frame_track := clip.find_track(^"Sprite:frame", Animation.TYPE_VALUE)
		if frame_track < 0:
			problems.append("%s has no value track on Sprite:frame" % clip_name)
		elif clip.value_track_get_update_mode(frame_track) != Animation.UPDATE_DISCRETE:
			problems.append("%s Sprite:frame update mode %d, want UPDATE_DISCRETE"
				% [clip_name, clip.value_track_get_update_mode(frame_track)])
		for entry: Array in STATE_VISIBILITY:
			var path: NodePath = entry[0]
			var t := clip.find_track(path, Animation.TYPE_VALUE)
			if t < 0:
				problems.append("%s has no value track on %s" % [clip_name, path])
				continue
			if clip.value_track_get_update_mode(t) != Animation.UPDATE_DISCRETE:
				problems.append("%s %s update mode %d, want UPDATE_DISCRETE"
					% [clip_name, path, clip.value_track_get_update_mode(t)])
			if clip.track_get_key_count(t) != 1:
				problems.append("%s %s has %d keys, want one at 0.0 s of %s"
					% [clip_name, path, clip.track_get_key_count(t), entry[1]])
				continue
			var value: Variant = clip.track_get_key_value(t, 0)
			if absf(clip.track_get_key_time(t, 0)) > TIME_TOLERANCE or typeof(value) != TYPE_BOOL or value != entry[1]:
				problems.append("%s %s key at %.6f s of %s, want 0.0 s of %s"
					% [clip_name, path, clip.track_get_key_time(t, 0), value, entry[1]])
	return problems


## Check 4: on every state clip, the value track on Sprite:frame is
## UPDATE_DISCRETE, and every key is a cell inside the sheet (below `limit`),
## below the Sprite's hframes x vframes (step 2b), and the cell of the brief's
## table for that clip and key. (Steps 2a and 2b required one track per clip;
## step 4a's track count is in _check_state_tracks.)
func _check_frames(player: AnimationPlayer, limit: int) -> Array[String]:
	var problems: Array[String] = []
	if limit != 16:
		problems.append("the sheet holds %d cells, want 16" % limit)
	var sprite := _sprite_of(player)
	var sprite_cells := sprite.hframes * sprite.vframes if sprite else 0
	if sprite == null:
		problems.append("no Sprite beside the player")
	for clip_name: StringName in CLIPS:
		if not player.has_animation(clip_name):
			problems.append("%s missing" % clip_name)
			continue
		var clip := player.get_animation(clip_name)
		var t := clip.find_track(^"Sprite:frame", Animation.TYPE_VALUE)
		if t < 0:
			problems.append("%s has no value track on Sprite:frame" % clip_name)
			continue
		if clip.value_track_get_update_mode(t) != Animation.UPDATE_DISCRETE:
			problems.append("%s track %d update mode %d, want UPDATE_DISCRETE (%d)"
				% [clip_name, t, clip.value_track_get_update_mode(t), Animation.UPDATE_DISCRETE])
		var keys: Array = CLIPS[clip_name][2]
		for k in clip.track_get_key_count(t):
			var value: Variant = clip.track_get_key_value(t, k)
			if typeof(value) != TYPE_INT:
				problems.append("%s key %d value %s is not an int" % [clip_name, k, value])
				continue
			if value < 0 or value >= limit:
				problems.append("%s key %d cell %d is outside the sheet's %d cells" % [clip_name, k, value, limit])
			if value < 0 or value >= sprite_cells:
				problems.append("%s key %d cell %d is outside the Sprite's %d cells (hframes x vframes)"
					% [clip_name, k, value, sprite_cells])
			if k < keys.size() and value != keys[k][1]:
				problems.append("%s key %d cell %d, want %d" % [clip_name, k, value, keys[k][1]])
	return problems


## Check 5: the player's settings (section 2).
func _check_player(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	if player.callback_mode_process != AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS:
		problems.append("callback_mode_process %d, want physics (%d)"
			% [player.callback_mode_process, AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS])
	if player.autoplay != "":
		problems.append("autoplay \"%s\", want empty" % player.autoplay)
	if player.speed_scale != 1.0:
		problems.append("speed_scale %s, want 1.0" % player.speed_scale)
	if player.root_node != NodePath(".."):
		problems.append("root_node %s, want .." % player.root_node)
	if player.get_parent() == null or player.get_parent().name != &"Look":
		problems.append("the player is not a child of Look")
	if player.get_animation_library_list() != [&""]:
		problems.append("libraries %s, want only the default library" % [player.get_animation_library_list()])
	elif player.get_animation_library(&"").resource_path != LIBRARY_PATH:
		problems.append("the default library is %s, want %s"
			% [player.get_animation_library(&"").resource_path, LIBRARY_PATH])
	return problems


## Check 6 (section 9; Revision 3 starts it in step 2b): the Sprite on the
## sheet, drawn as today, and RudyLook's cell table in frames.json's order.
func _check_sprite(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var sprite := _sprite_of(player)
	if sprite == null:
		problems.append("no Sprite beside the player")
		return problems
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	var origin := Vector2(manifest.origin[0], manifest.origin[1])
	var density: float = manifest.density
	if sprite.hframes != 4 or sprite.vframes != 4:
		problems.append("the Sprite sliced %d x %d, want 4 x 4" % [sprite.hframes, sprite.vframes])
	var texture := sprite.texture
	if texture == null or texture.resource_path != SHEET_PATH or Vector2i(texture.get_size()) != SHEET_SIZE:
		problems.append("the Sprite's texture is %s at %s, want the sheet %s at %s" % [
			texture.resource_path if texture else "none", Vector2i(texture.get_size()) if texture else Vector2i.ZERO,
			SHEET_PATH, SHEET_SIZE])
	if not FileAccess.get_file_as_string(SHEET_PATH + ".import").contains("mipmaps/generate=true"):
		problems.append("the sheet's .import does not generate mipmaps")
	if sprite.centered or sprite.position != Vector2.ZERO or sprite.offset != -origin or sprite.scale != Vector2.ONE / density:
		problems.append("centered %s, position %s, offset %s, scale %s; want not centered, (0, 0), %s, %s"
			% [sprite.centered, sprite.position, sprite.offset, sprite.scale, -origin, Vector2.ONE / density])
	if sprite.material == null or sprite.material.resource_path != OUTLINE_PATH:
		problems.append("material %s, want %s" % [sprite.material.resource_path if sprite.material else "none", OUTLINE_PATH])
	var look := sprite.get_parent() as CanvasItem
	if sprite.texture_filter != CanvasItem.TEXTURE_FILTER_PARENT_NODE or look == null \
			or look.texture_filter != CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS:
		problems.append("filter: Sprite %d, Look %s; want the parent's (%d) under linear with mipmaps (%d)"
			% [sprite.texture_filter, look.texture_filter if look else "none",
				CanvasItem.TEXTURE_FILTER_PARENT_NODE, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS])
	var order: Array[String] = []
	for id in manifest.frames:
		order.append(String(id))
	var cells: Array[String] = []
	for id in RudyLook.CELLS:
		cells.append(String(id))
	if cells != order:
		problems.append("RudyLook.CELLS %s, want frames.json's order %s" % [cells, order])
	return problems


## Check 7: the library against section 3's states (Revision 3) and, from
## step 2b, against the names _pick_clip() can return, read from rudy.gd's text.
func _check_names(player: AnimationPlayer, rudy_text: String) -> Array[String]:
	var problems: Array[String] = []
	var have := player.get_animation_list()
	for clip_name: StringName in CLIPS:
		if not (String(clip_name) in have):
			problems.append("missing %s" % clip_name)
	if not (String(RIG_CLIP) in have):
		problems.append("missing %s" % RIG_CLIP)
	for clip_name in have:
		if not CLIPS.has(StringName(clip_name)) and StringName(clip_name) != RIG_CLIP:
			problems.append("extra %s" % clip_name)
	var selector := _selector_names(rudy_text)
	problems.append_array(selector.problems)
	for clip_name: String in selector.names:
		if not (clip_name in have):
			problems.append("_pick_clip() returns %s, which has no clip" % clip_name)
	if String(RIG_CLIP) in selector.names:
		problems.append("_pick_clip() returns %s, which step 4a leaves unwired" % RIG_CLIP)
	for clip_name in have:
		if StringName(clip_name) != RIG_CLIP and not (String(clip_name) in selector.names):
			problems.append("%s is in the library but _pick_clip() never returns it" % clip_name)
	return problems


## Check 1b: track_problems() reads only a path's first subname, so it passes
## a track keyed on modulate:alpha. Every track path with a second subname is
## resolved here in full with get_indexed(), and must give a value of the type
## the track keys.
func _check_indexed(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var root := player.get_node(player.root_node)
	for clip_name in player.get_animation_list():
		var clip := player.get_animation(clip_name)
		for t in clip.get_track_count():
			var path := clip.track_get_path(t)
			if path.get_subname_count() < 2:
				continue
			var node := root.get_node_or_null(NodePath(path.get_concatenated_names()))
			if node == null:
				problems.append("%s track %d: no node at %s" % [clip_name, t, path])
				continue
			var property := path.get_concatenated_subnames()
			var value: Variant = node.get_indexed(NodePath(property))
			if value == null:
				problems.append("%s track %d: %s does not resolve %s with get_indexed()" % [clip_name, t, node.name, property])
				continue
			if clip.track_get_key_count(t) > 0 and typeof(clip.track_get_key_value(t, 0)) != typeof(value):
				problems.append("%s track %d: %s:%s is type %d, the keys type %d"
					% [clip_name, t, node.name, property, typeof(value), typeof(clip.track_get_key_value(t, 0))])
	return problems


## The paths check 1b resolved, for its PASS line.
func _indexed_paths(player: AnimationPlayer) -> Array[String]:
	var paths: Array[String] = []
	for clip_name in player.get_animation_list():
		var clip := player.get_animation(clip_name)
		for t in clip.get_track_count():
			if clip.track_get_path(t).get_subname_count() >= 2:
				paths.append("%s track %d %s" % [clip_name, t, clip.track_get_path(t)])
	if paths.is_empty():
		paths.append("no track has a second subname")
	return paths


## Checks 2 for slash_rig: its length, and every track against RIG_TRACKS in
## order: path, value type, update mode, linear interpolation for the
## continuous tracks, key count, and each key's time (tick / 60, within 1 us),
## value and transition.
func _check_rig_clip(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	if not player.has_animation(RIG_CLIP):
		problems.append("%s missing" % RIG_CLIP)
		return problems
	var clip := player.get_animation(RIG_CLIP)
	if absf(clip.length - RIG_LENGTH) > TIME_TOLERANCE:
		problems.append("%s length %.6f s, want 17/60 = %.6f" % [RIG_CLIP, clip.length, RIG_LENGTH])
	if clip.get_track_count() != RIG_TRACKS.size():
		problems.append("%s has %d tracks, want %d" % [RIG_CLIP, clip.get_track_count(), RIG_TRACKS.size()])
	for t in mini(clip.get_track_count(), RIG_TRACKS.size()):
		var want: Array = RIG_TRACKS[t]
		if clip.track_get_type(t) != Animation.TYPE_VALUE or clip.track_get_path(t) != want[0]:
			problems.append("%s track %d is type %d on %s, want a value track on %s"
				% [RIG_CLIP, t, clip.track_get_type(t), clip.track_get_path(t), want[0]])
			continue
		if clip.value_track_get_update_mode(t) != want[1]:
			problems.append("%s track %d update mode %d, want %d"
				% [RIG_CLIP, t, clip.value_track_get_update_mode(t), want[1]])
		if want[1] == Animation.UPDATE_CONTINUOUS and clip.track_get_interpolation_type(t) != Animation.INTERPOLATION_LINEAR:
			problems.append("%s track %d interpolation %d, want linear"
				% [RIG_CLIP, t, clip.track_get_interpolation_type(t)])
		var keys: Array = want[2]
		if clip.track_get_key_count(t) != keys.size():
			problems.append("%s track %d has %d keys, want %d" % [RIG_CLIP, t, clip.track_get_key_count(t), keys.size()])
			continue
		for k in keys.size():
			var tick: int = keys[k][0]
			var time := clip.track_get_key_time(t, k)
			if absf(time - tick / 60.0) > TIME_TOLERANCE:
				problems.append("%s track %d key %d at %.6f s (tick %.2f), want tick %d = %.6f s"
					% [RIG_CLIP, t, k, time, time * 60.0, tick, tick / 60.0])
			var value: Variant = clip.track_get_key_value(t, k)
			if not _same(value, keys[k][1]):
				problems.append("%s track %d key %d value %s, want %s" % [RIG_CLIP, t, k, value, keys[k][1]])
			var transition := clip.track_get_key_transition(t, k)
			if absf(transition - float(keys[k][2])) > 0.000001:
				problems.append("%s track %d key %d transition %s, want %s" % [RIG_CLIP, t, k, transition, keys[k][2]])
	return problems


## Check 2's sample of slash_rig: Grip's value on the ticks of section 7,
## by value_track_interpolate() at tick / 60.
func _check_rig_samples(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	if not player.has_animation(RIG_CLIP):
		problems.append("%s missing" % RIG_CLIP)
		return problems
	var clip := player.get_animation(RIG_CLIP)
	var t := clip.find_track(GRIP_TRACK, Animation.TYPE_VALUE)
	if t < 0:
		problems.append("%s has no value track on %s" % [RIG_CLIP, GRIP_TRACK])
		return problems
	for sample: Array in GRIP_SAMPLES:
		var value: float = clip.value_track_interpolate(t, sample[0] / 60.0)
		if value < sample[1] or value > sample[2]:
			problems.append("Grip on tick %d is %.2f deg, want %s to %s" % [sample[0], value, sample[1], sample[2]])
	return problems


## Grip on every tick 0-17, for the sample's PASS line and the key table.
func _grip_trail(player: AnimationPlayer) -> String:
	if not player.has_animation(RIG_CLIP):
		return "no slash_rig"
	var clip := player.get_animation(RIG_CLIP)
	var t := clip.find_track(GRIP_TRACK, Animation.TYPE_VALUE)
	if t < 0:
		return "no Grip track"
	var parts: Array[String] = []
	for tick in 18:
		parts.append("%d:%.2f" % [tick, clip.value_track_interpolate(t, tick / 60.0)])
	return "Grip by tick " + " ".join(parts)


## slash_rig's tracks and key times, for check 2's PASS line.
func _rig_key_summary(player: AnimationPlayer) -> String:
	if not player.has_animation(RIG_CLIP):
		return "no slash_rig"
	var clip := player.get_animation(RIG_CLIP)
	var parts: Array[String] = ["length %.6f s, %d tracks" % [clip.length, clip.get_track_count()]]
	for t in clip.get_track_count():
		var keys: Array[String] = []
		for k in clip.track_get_key_count(t):
			keys.append("%.6f s (tick %.2f) = %s @ %s" % [clip.track_get_key_time(t, k), clip.track_get_key_time(t, k) * 60.0,
				clip.track_get_key_value(t, k), clip.track_get_key_transition(t, k)])
		parts.append("%s [update %d]: %s" % [clip.track_get_path(t), clip.value_track_get_update_mode(t), ", ".join(keys)])
	return "; ".join(parts)


## Check 8: the rig's tree, its draw order, SlashRig hidden, Lean at his
## soles, Grip at the grip point, and Blade's position cancelling Grip's so
## that at Grip 0 it sits where it was drawn (section 2.2; Revision 4).
func _check_rig(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var look := player.get_parent()
	if look == null:
		problems.append("the player has no parent")
		return problems
	var want_children: Array[String] = ["Sprite", "SlashRig", "AnimationPlayer"]
	if _child_names(look) != want_children:
		problems.append("Look's children %s, want %s" % [_child_names(look), want_children])
	var rig := look.get_node_or_null(^"SlashRig")
	if rig == null or rig.get_class() != "Node2D":
		problems.append("Look/SlashRig is %s, want a Node2D" % (rig.get_class() if rig else "missing"))
		return problems
	if (rig as Node2D).visible:
		problems.append("SlashRig is visible, want hidden until the slash")
	if (rig as Node2D).transform != Transform2D.IDENTITY:
		problems.append("SlashRig's transform %s, want identity" % (rig as Node2D).transform)
	var want_rig: Array[String] = ["Lean"]
	if _child_names(rig) != want_rig:
		problems.append("SlashRig's children %s, want %s" % [_child_names(rig), want_rig])
	var lean := rig.get_node_or_null(^"Lean")
	if lean == null or lean.get_class() != "Node2D":
		problems.append("SlashRig/Lean is %s, want a Node2D" % (lean.get_class() if lean else "missing"))
		return problems
	if (lean as Node2D).position != Vector2.ZERO or (lean as Node2D).rotation != 0.0 or (lean as Node2D).scale != Vector2.ONE:
		problems.append("Lean at %s, rotation %s, scale %s; want his soles (0, 0), 0, 1"
			% [(lean as Node2D).position, (lean as Node2D).rotation, (lean as Node2D).scale])
	var want_lean: Array[String] = ["Grip", "Body", "Arc"]
	if _child_names(lean) != want_lean:
		problems.append("Lean's children %s, want %s" % [_child_names(lean), want_lean])
	var grip := lean.get_node_or_null(^"Grip")
	var body := lean.get_node_or_null(^"Body")
	if grip == null or grip.get_class() != "Node2D":
		problems.append("Lean/Grip is %s, want a Node2D" % (grip.get_class() if grip else "missing"))
		return problems
	if body != null and grip.get_index() > body.get_index():
		problems.append("Blade draws after Body: Grip (holding Blade) is child %d of Lean, Body child %d"
			% [grip.get_index(), body.get_index()])
	var want_grip: Array[String] = ["Blade"]
	if _child_names(grip) != want_grip:
		problems.append("Grip's children %s, want %s" % [_child_names(grip), want_grip])
	var grip_2d := grip as Node2D
	var off := (grip_2d.position - GRIP_POINT).abs()
	if off.x > GRIP_TOLERANCE or off.y > GRIP_TOLERANCE or grip_2d.rotation != 0.0 or grip_2d.scale != Vector2.ONE:
		problems.append("Grip at %s, rotation %s, scale %s; want the grip point %s, 0, 1"
			% [grip_2d.position, grip_2d.rotation, grip_2d.scale, GRIP_POINT])
	var blade := grip.get_node_or_null(^"Blade") as Node2D
	if blade == null:
		problems.append("no Grip/Blade")
	else:
		var sum := (blade.position + grip_2d.position).abs()
		if sum.x > 0.000001 or sum.y > 0.000001:
			problems.append("Blade at %s does not cancel Grip at %s" % [blade.position, grip_2d.position])
	return problems


## Check 8's parts: each a Sprite2D drawn as the Sprite is (section 2.1's
## offset, scale and centring), on its rig PNG, which imports with mipmaps,
## with the outline on Blade and Body and no material on Arc; Body and Arc at
## Lean's origin; and every rig node on its parent's filter, so all inherit
## Look's linear-with-mipmaps.
func _check_rig_parts(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var look := player.get_parent()
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	var origin := Vector2(manifest.origin[0], manifest.origin[1])
	var density: float = manifest.density
	for path: NodePath in [^"SlashRig", ^"SlashRig/Lean", ^"SlashRig/Lean/Grip"]:
		var node := look.get_node_or_null(path) as CanvasItem
		if node == null:
			problems.append("no %s" % path)
		elif node.texture_filter != CanvasItem.TEXTURE_FILTER_PARENT_NODE:
			problems.append("%s filter %d, want the parent's (%d)" % [path, node.texture_filter, CanvasItem.TEXTURE_FILTER_PARENT_NODE])
	for part: Array in RIG_PARTS:
		var path: NodePath = part[0]
		var node := look.get_node_or_null(path)
		if node == null or node.get_class() != "Sprite2D":
			problems.append("%s is %s, want a Sprite2D" % [path, node.get_class() if node else "missing"])
			continue
		var sprite := node as Sprite2D
		var texture := sprite.texture
		if texture == null or texture.resource_path != part[1] or Vector2i(texture.get_size()) != CELL:
			problems.append("%s texture %s at %s, want %s at %s" % [path, texture.resource_path if texture else "none",
				Vector2i(texture.get_size()) if texture else Vector2i.ZERO, part[1], CELL])
		if not FileAccess.get_file_as_string(part[1] + ".import").contains("mipmaps/generate=true"):
			problems.append("%s.import does not generate mipmaps" % part[1])
		if sprite.centered or sprite.offset != -origin or sprite.scale != Vector2.ONE / density or sprite.rotation != 0.0 \
				or sprite.hframes != 1 or sprite.vframes != 1:
			problems.append("%s centered %s, offset %s, scale %s, rotation %s, %d x %d; want not centred, %s, %s, 0, 1 x 1"
				% [path, sprite.centered, sprite.offset, sprite.scale, sprite.rotation, sprite.hframes, sprite.vframes,
					-origin, Vector2.ONE / density])
		if path != ^"SlashRig/Lean/Grip/Blade" and sprite.position != Vector2.ZERO:
			problems.append("%s at %s, want (0, 0)" % [path, sprite.position])
		var material_path := sprite.material.resource_path if sprite.material else ""
		if material_path != part[2]:
			problems.append("%s material %s, want %s" % [path, material_path if material_path else "none",
				part[2] if part[2] else "none"])
		if sprite.texture_filter != CanvasItem.TEXTURE_FILTER_PARENT_NODE:
			problems.append("%s filter %d, want the parent's (%d)" % [path, sprite.texture_filter, CanvasItem.TEXTURE_FILTER_PARENT_NODE])
		if sprite.modulate != Color.WHITE or sprite.self_modulate != Color.WHITE:
			problems.append("%s modulate %s, self_modulate %s, want white" % [path, sprite.modulate, sprite.self_modulate])
	return problems


## The rig's tree as read, for check 8's PASS line.
func _rig_summary(player: AnimationPlayer) -> String:
	var look := player.get_parent()
	var rig := look.get_node_or_null(^"SlashRig") as Node2D
	var grip := look.get_node_or_null(^"SlashRig/Lean/Grip") as Node2D
	var blade := look.get_node_or_null(^"SlashRig/Lean/Grip/Blade") as Node2D
	if rig == null or grip == null or blade == null:
		return "rig incomplete"
	return "Look %s; SlashRig visible %s; Lean %s; Grip at %s; Blade at %s" % [_child_names(look), rig.visible,
		_child_names(rig.get_node(^"Lean")), grip.position, blade.position]


## Revision 4: nothing plays slash_rig in step 4a, so neither script names it.
func _scan_rig_name(rudy_text: String, look_text: String) -> Array[String]:
	var problems: Array[String] = []
	if rudy_text.is_empty() or look_text.is_empty():
		problems.append("no text to scan")
	if rudy_text.contains(String(RIG_CLIP)):
		problems.append("rudy.gd names %s" % RIG_CLIP)
	if look_text.contains(String(RIG_CLIP)):
		problems.append("rudy_look.gd names %s" % RIG_CLIP)
	return problems


func _child_names(node: Node) -> Array[String]:
	var names: Array[String] = []
	for child in node.get_children():
		names.append(String(child.name))
	return names


## Equal values: floats within 1e-4, vectors approximately, others exactly,
## and always of the same type.
func _same(a: Variant, b: Variant) -> bool:
	if typeof(a) != typeof(b):
		return false
	if typeof(a) == TYPE_FLOAT:
		return absf(a - b) < 0.0001
	if typeof(a) == TYPE_VECTOR2:
		return (a as Vector2).is_equal_approx(b)
	return a == b


## The clip names _pick_clip() can return, read from the text of rudy.gd:
## every return in its body must be a StringName literal, or two joined by
## `if ... else`. Returns {names, problems}.
func _selector_names(text: String) -> Dictionary:
	var names: Array[String] = []
	var problems: Array[String] = []
	var start := text.find("func _pick_clip(")
	if start < 0:
		problems.append("rudy.gd has no func _pick_clip(")
		return {"names": names, "problems": problems}
	var end := text.find("\nfunc ", start + 1)
	var body := text.substr(start, (end if end >= 0 else text.length()) - start)
	var literal_return := RegEx.create_from_string(r'^&"\w+"(\s+if\s+.+\s+else\s+&"\w+")?$')
	var literal := RegEx.create_from_string(r'&"(\w+)"')
	var returns := RegEx.create_from_string(r"(?m)^\s*return\b(.*)$")
	for found in returns.search_all(body):
		var expression := found.get_string(1).strip_edges()
		if literal_return.search(expression) == null:
			problems.append("_pick_clip() returns \"%s\", not a StringName literal" % expression)
			continue
		for m in literal.search_all(expression):
			if not (m.get_string(1) in names):
				names.append(m.get_string(1))
	if names.is_empty():
		problems.append("_pick_clip() returns no name")
	return {"names": names, "problems": problems}


## The one-authority rule in text (section 5): no assignment to a texture or
## frame (or frame_coords), and no set() or setter call for one, in code
## outside comments.
func _scan_sprite_writes(label: String, text: String) -> Array[String]:
	var problems: Array[String] = []
	if text.is_empty():
		problems.append("%s: no text to scan" % label)
	var assignment := RegEx.create_from_string(r"(^|[^\w])(texture|frame|frame_coords)\s*=(?!=)")
	var setter := RegEx.create_from_string(r"\b(set|set_deferred)\(\s*[&^]?\"(texture|frame|frame_coords)\"|\bset_(texture|frame|frame_coords)\(")
	var lines := text.split("\n")
	for i in lines.size():
		var code := lines[i]
		var comment_at := code.find("#")
		if comment_at >= 0:
			code = code.substr(0, comment_at)
		var found := assignment.search(code)
		if found == null:
			found = setter.search(code)
		if found != null:
			var property := found.get_string(2) if found.get_string(2) != "" else found.get_string(3)
			problems.append("%s: assigns the Sprite's %s on line %d: %s" % [label, property, i + 1, lines[i].strip_edges()])
	return problems


## The Sprite the player draws on: Look/Sprite, beside it.
func _sprite_of(player: AnimationPlayer) -> Sprite2D:
	return player.get_node_or_null(^"../Sprite") as Sprite2D


## Section 10, row 9: Godot 3 names in resource text.
func _scan_text(label: String, text: String) -> Array[String]:
	var problems: Array[String] = []
	if text.is_empty():
		problems.append("%s: no text to scan" % label)
	if text.contains("playback_speed"):
		problems.append("%s: playback_speed" % label)
	var line_start := RegEx.create_from_string(r"(?m)^(loop|playing|frames) =")
	for found in line_start.search_all(text):
		problems.append("%s: \"%s\" at a line start" % [label, found.get_string()])
	return problems


## The sheet's cells, from its size and section 2.1's cell (Revision 3).
func _sheet_cells(sheet: Texture2D) -> int:
	if sheet == null:
		return 0
	if sheet.get_width() % CELL.x != 0 or sheet.get_height() % CELL.y != 0:
		return 0
	return (sheet.get_width() / CELL.x) * (sheet.get_height() / CELL.y)


## A fresh instance of rudy.tscn whose player holds a new library of
## duplicated clips, so damaging it touches neither the loaded library nor
## any file. With `new_library` false it keeps the loaded library, for damage
## to the player node alone.
func _copy_player(new_library := true) -> AnimationPlayer:
	var rudy: Node = RUDY.instantiate()
	_copies.append(rudy)
	var player: AnimationPlayer = rudy.get_node("Look/AnimationPlayer")
	if not new_library:
		return player
	var source := player.get_animation_library(&"")
	var library := AnimationLibrary.new()
	for clip_name in source.get_animation_list():
		library.add_animation(clip_name, source.get_animation(clip_name).duplicate(true))
	player.remove_animation_library(&"")
	player.add_animation_library(&"", library)
	return player


func _track_count(player: AnimationPlayer) -> int:
	var n := 0
	for clip_name in player.get_animation_list():
		n += player.get_animation(clip_name).get_track_count()
	return n


func _key_count(player: AnimationPlayer) -> int:
	var n := 0
	for clip_name in player.get_animation_list():
		var clip := player.get_animation(clip_name)
		for t in clip.get_track_count():
			n += clip.track_get_key_count(t)
	return n


func _expect_clean(what: String, problems: Array[String], detail: String = "") -> void:
	_checks += 1
	var ok := problems.is_empty()
	if not ok:
		_failures += 1
		detail = "; ".join(problems)
	print("%s  %s%s" % ["PASS" if ok else "FAIL", what, "" if detail.is_empty() else "  (%s)" % detail])


## Passes only if the check reported a problem whose text contains `reason`.
func _expect_failure(what: String, problems: Array[String], reason: String) -> void:
	_checks += 1
	var ok := false
	for problem in problems:
		if problem.contains(reason):
			ok = true
	if not ok:
		_failures += 1
	var seen := "; ".join(problems) if not problems.is_empty() else "the check passed"
	print("%s  %s: must fail on \"%s\"  (%s)" % ["PASS" if ok else "FAIL", what, reason, seen])
