extends SceneTree
## Checks, on this machine, the four "Headless facts" lines the assignment's
## Step 1 asks CLAUDE.md to carry. Run from assignment-7/:
##   godot --headless --fixed-fps 60 --path game --script "$PWD/evidence/headless-facts-probe/probe_headless_facts.gd" <scratch dir>
## The script lives outside game/, so the game gains no file. It reads
## res://content/rudy/rudy_animations.tres and writes one .tres to the scratch
## directory given after the script. Each FACT line names the fact it bears on.

var _scratch := ""


func _init() -> void:
	for arg in OS.get_cmdline_user_args() + OS.get_cmdline_args():
		if arg.begins_with("/") and DirAccess.dir_exists_absolute(arg) and not arg.ends_with(".gd"):
			_scratch = arg
	_run.call_deferred()


func _run() -> void:
	print("ENV display %s, rendering method %s, video adapter '%s'" % [
		DisplayServer.get_name(), RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_name()])
	await _fact_1_headless_clips()
	_fact_2_key_times()
	_fact_3_update_mode()
	print("DONE")
	quit(0)


## Fact 1: a headless run advances clips and reads their structure, and draws
## nothing.
func _fact_1_headless_clips() -> void:
	var host := Node2D.new()
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.hframes = 4
	sprite.vframes = 4
	host.add_child(sprite)
	# The rig's node names, as in rudy.tscn, so every track of the library
	# resolves; only the Sprite is checked.
	var rig := Node2D.new()
	rig.name = "SlashRig"
	var lean := Node2D.new()
	lean.name = "Lean"
	var grip := Node2D.new()
	grip.name = "Grip"
	var arc := Sprite2D.new()
	arc.name = "Arc"
	host.add_child(rig)
	rig.add_child(lean)
	lean.add_child(grip)
	lean.add_child(arc)
	var player := AnimationPlayer.new()
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	host.add_child(player)
	var lib: AnimationLibrary = load("res://content/rudy/rudy_animations.tres")
	player.add_animation_library(&"", lib)
	root.add_child(host)
	var run := lib.get_animation(&"run")
	print("FACT1 structure: run has %d tracks, track 0 %s, %d keys, update mode %d, loop_mode %d, length %s" % [
		run.get_track_count(), run.track_get_path(0), run.track_get_key_count(0),
		run.value_track_get_update_mode(0), run.loop_mode, run.length])
	player.play(&"run")
	var cells: Array[int] = []
	var positions: Array[String] = []
	for i in 12:
		await physics_frame
		cells.append(sprite.frame)
		positions.append("%.4f" % player.current_animation_position)
	print("FACT1 advances: 12 physics ticks of run, Sprite.frame %s" % [cells])
	print("FACT1 advances: clip position %s" % [", ".join(positions)])
	await process_frame
	var image := root.get_texture().get_image()
	if image == null:
		print("FACT1 draws: root viewport get_image() returned null")
	else:
		print("FACT1 draws: root viewport get_image() %s, is_empty %s" % [image.get_size(), image.is_empty()])
	host.queue_free()


## Fact 2: key times are 32-bit floats; compare them with a tolerance.
func _fact_2_key_times() -> void:
	var fresh := Animation.new()
	print("FACT2 Animation.new(): step %.17f, length %.17f; 1.0/30.0 is %.17f; step == 1.0/30.0 %s, is_equal_approx %s" % [
		fresh.step, fresh.length, 1.0 / 30.0, fresh.step == 1.0 / 30.0, is_equal_approx(fresh.step, 1.0 / 30.0)])
	var t := fresh.add_track(Animation.TYPE_VALUE)
	fresh.track_set_path(t, NodePath("Sprite:frame"))
	for tick in [2, 5, 11, 17]:
		fresh.track_insert_key(t, tick / 60.0, tick)
	_report_times("in memory, keys inserted at tick/60", fresh, t)
	if _scratch != "":
		var path := _scratch.path_join("probe_saved_anim.tres")
		var err := ResourceSaver.save(fresh, path)
		var text := FileAccess.get_file_as_string(path)
		for line in text.split("\n"):
			if line.begins_with("\"times\""):
				print("FACT2 saved as resource text (error %d): %s" % [err, line])
		var reloaded: Animation = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		_report_times("saved and loaded back", reloaded, 0)
	var lib: AnimationLibrary = load("res://content/rudy/rudy_animations.tres")
	var slash := lib.get_animation(&"slash")
	var grip := slash.find_track(NodePath("SlashRig/Lean/Grip:rotation_degrees"), Animation.TYPE_VALUE)
	_report_times("rudy_animations.tres slash Grip", slash, grip)
	print("FACT2 rudy_animations.tres slash length %.17f; 17/60 is %.17f; == %s" % [
		slash.length, 17.0 / 60.0, slash.length == 17.0 / 60.0])


func _report_times(label: String, anim: Animation, track: int) -> void:
	var parts: Array[String] = []
	var exact := 0
	for i in anim.track_get_key_count(track):
		var got := anim.track_get_key_time(track, i)
		var tick := roundi(got * 60.0)
		var want := tick / 60.0
		if got == want:
			exact += 1
		parts.append("tick %d: %.17f (%+.3f ns)" % [tick, got, (got - want) * 1e9])
	print("FACT2 %s: %d of %d keys == tick/60; %s" % [label, exact, parts.size(), "; ".join(parts)])


## Fact 3: value_track_get_update_mode applies only to value tracks.
func _fact_3_update_mode() -> void:
	var anim := Animation.new()
	var value := anim.add_track(Animation.TYPE_VALUE)
	anim.value_track_set_update_mode(value, Animation.UPDATE_DISCRETE)
	var bezier := anim.add_track(Animation.TYPE_BEZIER)
	var method := anim.add_track(Animation.TYPE_METHOD)
	print("FACT3 UPDATE_CONTINUOUS %d, UPDATE_DISCRETE %d, UPDATE_CAPTURE %d" % [
		Animation.UPDATE_CONTINUOUS, Animation.UPDATE_DISCRETE, Animation.UPDATE_CAPTURE])
	print("FACT3 value track set to discrete: %d" % anim.value_track_get_update_mode(value))
	print("FACT3 next, a bezier track; an error line here comes from Godot")
	print("FACT3 bezier track: %d" % anim.value_track_get_update_mode(bezier))
	print("FACT3 next, a method track; an error line here comes from Godot")
	print("FACT3 method track: %d" % anim.value_track_get_update_mode(method))
	var lib: AnimationLibrary = load("res://content/rudy/rudy_animations.tres")
	var kinds := {}
	for clip_name in lib.get_animation_list():
		var clip := lib.get_animation(clip_name)
		for i in clip.get_track_count():
			kinds[clip.track_get_type(i)] = kinds.get(clip.track_get_type(i), 0) + 1
	print("FACT3 rudy_animations.tres track types (TYPE_VALUE is %d): %s" % [Animation.TYPE_VALUE, kinds])
