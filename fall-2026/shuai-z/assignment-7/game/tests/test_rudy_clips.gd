extends Node
## The read-back test for Rudy's clips, step 2a (CHANGE-BRIEF.md section 9 as
## Revision 3 stages it; section 10, row 9). Run from the assignment folder:
##   scripts/run-test.sh test_rudy_clips.tscn 60
##
## It loads rudy.tscn and reads the AnimationPlayer under Look. It is a scene
## test because rudy.gd names the Sfx autoload (CLAUDE.md). The instance is
## never added to the tree, and the test never calls play(), seek() or
## advance(), so no clip runs and nothing in Rudy moves.
##
## READBACK only reads: the scene's player, its library, the sheet's size and
## the text of rudy.tscn and rudy_animations.tres.
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

var _checks := 0
var _failures := 0
var _copies: Array[Node] = []


func _ready() -> void:
	var rudy: Node = RUDY.instantiate()
	var player: AnimationPlayer = rudy.get_node("Look/AnimationPlayer")
	var sheet: Texture2D = load(SHEET_PATH)
	var limit := _sheet_cells(sheet)

	print("READBACK")
	_expect_clean("1 every track resolves to a real node and property (track_problems)",
		track_problems(player), "%d tracks" % _track_count(player))
	_expect_clean("2 key times and clip lengths match the brief to within 1 us",
		_check_times(player), "%d clips, %d keys" % [CLIPS.size(), _key_count(player)])
	_expect_clean("3 loop_mode is LOOP_LINEAR for run, sword_run and the one-key clips, LOOP_NONE for slash",
		_check_loops(player))
	_expect_clean("4 every frame track is discrete, every frame key is inside the sheet and on its cell",
		_check_frames(player, limit),
		"sheet %dx%d px / cell %dx%d = %dx%d = %d cells" % [sheet.get_width(), sheet.get_height(),
			CELL.x, CELL.y, sheet.get_width() / CELL.x, sheet.get_height() / CELL.y, limit])
	_expect_clean("5 the player: callback_mode_process physics, autoplay empty, speed_scale 1.0, root_node .., the library as its default",
		_check_player(player),
		"callback %d, autoplay \"%s\", speed_scale %s, root_node %s" % [player.callback_mode_process,
			player.autoplay, player.speed_scale, player.root_node])
	_expect_clean("7 the library holds exactly section 3's 13 clips, counting the slash stand-in",
		_check_names(player), "%d clips" % player.get_animation_list().size())
	var scan_problems := _scan_text("rudy.tscn", FileAccess.get_file_as_string(SCENE_PATH))
	scan_problems.append_array(_scan_text("rudy_animations.tres", FileAccess.get_file_as_string(LIBRARY_PATH)))
	_expect_clean("10.9 no Godot 3 name in rudy.tscn or rudy_animations.tres (playback_speed; loop =, playing =, frames = at a line start)",
		scan_problems)
	_expect_clean("10.9 the scan does not flag the Godot 4 names hframes =, vframes =, loop_mode =, sprite_frames =, speed_scale =",
		_scan_text("sample", "hframes = 4\nvframes = 4\nloop_mode = 1\nsprite_frames = x\nspeed_scale = 1.0\n"))

	print("NEGATIVE")
	var clean := _copy_player()
	var clean_problems := track_problems(clean)
	for list in [_check_times(clean), _check_loops(clean), _check_frames(clean, limit), _check_names(clean)]:
		clean_problems.append_array(list)
	_expect_clean("control: an undamaged copy passes checks 1, 2, 3, 4 and 7, so each failure below comes from its damage",
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
	_expect_failure("7 hurt removed from the library", _check_names(p), "missing hurt")

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
	return problems


## Check 4: every clip has one track, a value track on Sprite:frame
## (Revision 3), on UPDATE_DISCRETE, and every key is a cell inside the sheet
## (below `limit`) and the cell of the brief's table for that clip and key.
func _check_frames(player: AnimationPlayer, limit: int) -> Array[String]:
	var problems: Array[String] = []
	if limit != 16:
		problems.append("the sheet holds %d cells, want 16" % limit)
	for clip_name: StringName in CLIPS:
		if not player.has_animation(clip_name):
			problems.append("%s missing" % clip_name)
			continue
		var clip := player.get_animation(clip_name)
		if clip.get_track_count() != 1:
			problems.append("%s has %d tracks, want 1" % [clip_name, clip.get_track_count()])
		for t in clip.get_track_count():
			if clip.track_get_type(t) != Animation.TYPE_VALUE or clip.track_get_path(t) != NodePath("Sprite:frame"):
				problems.append("%s track %d is type %d on %s, want a value track on Sprite:frame"
					% [clip_name, t, clip.track_get_type(t), clip.track_get_path(t)])
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


## Check 7, as Revision 3 stages it: the library against section 3's states.
func _check_names(player: AnimationPlayer) -> Array[String]:
	var problems: Array[String] = []
	var have := player.get_animation_list()
	for clip_name: StringName in CLIPS:
		if not (String(clip_name) in have):
			problems.append("missing %s" % clip_name)
	for clip_name in have:
		if not CLIPS.has(StringName(clip_name)):
			problems.append("extra %s" % clip_name)
	return problems


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
