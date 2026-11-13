extends Node
## The read-back test for Rudy's clips, steps 2a and 2b (CHANGE-BRIEF.md
## section 9 as Revision 3 stages it; section 10, row 9). Step 2b adds check 6,
## the Sprite on the sheet; check 4's limit from the Sprite's slicing; check
## 7's comparison with the names _pick_clip() returns; and the text check that
## rudy.gd and rudy_look.gd never write the Sprite's texture or frame. Run
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
	_expect_clean("2 key times and clip lengths match the brief to within 1 us",
		_check_times(player), "%d clips, %d keys" % [CLIPS.size(), _key_count(player)])
	_expect_clean("3 loop_mode is LOOP_LINEAR for run, sword_run and the one-key clips, LOOP_NONE for slash",
		_check_loops(player))
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
	_expect_clean("7 the library holds exactly section 3's 13 clips, counting the slash stand-in, and exactly the names _pick_clip() can return",
		_check_names(player, rudy_text), "%d clips; _pick_clip() returns %s" % [player.get_animation_list().size(),
			", ".join(_selector_names(rudy_text).names)])
	var write_problems := _scan_sprite_writes("rudy.gd", rudy_text)
	write_problems.append_array(_scan_sprite_writes("rudy_look.gd", look_text))
	_expect_clean("text: rudy.gd and rudy_look.gd assign neither the Sprite's texture nor its frame", write_problems)
	var scan_problems := _scan_text("rudy.tscn", FileAccess.get_file_as_string(SCENE_PATH))
	scan_problems.append_array(_scan_text("rudy_animations.tres", FileAccess.get_file_as_string(LIBRARY_PATH)))
	_expect_clean("10.9 no Godot 3 name in rudy.tscn or rudy_animations.tres (playback_speed; loop =, playing =, frames = at a line start)",
		scan_problems)
	_expect_clean("10.9 the scan does not flag the Godot 4 names hframes =, vframes =, loop_mode =, sprite_frames =, speed_scale =",
		_scan_text("sample", "hframes = 4\nvframes = 4\nloop_mode = 1\nsprite_frames = x\nspeed_scale = 1.0\n"))

	print("NEGATIVE")
	var clean := _copy_player()
	var clean_problems := track_problems(clean)
	for list in [_check_times(clean), _check_loops(clean), _check_frames(clean, limit), _check_sprite(clean),
			_check_names(clean, rudy_text), _scan_sprite_writes("rudy.gd", rudy_text), _scan_sprite_writes("rudy_look.gd", look_text)]:
		clean_problems.append_array(list)
	_expect_clean("control: an undamaged copy passes checks 1, 2, 3, 4, 6, 7 and the text check, so each failure below comes from its damage",
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
## (below `limit`), below the Sprite's hframes x vframes (step 2b), and the
## cell of the brief's table for that clip and key.
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
	for clip_name in have:
		if not CLIPS.has(StringName(clip_name)):
			problems.append("extra %s" % clip_name)
	var selector := _selector_names(rudy_text)
	problems.append_array(selector.problems)
	for clip_name: String in selector.names:
		if not (clip_name in have):
			problems.append("_pick_clip() returns %s, which has no clip" % clip_name)
	for clip_name in have:
		if not (String(clip_name) in selector.names):
			problems.append("%s is in the library but _pick_clip() never returns it" % clip_name)
	return problems


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
