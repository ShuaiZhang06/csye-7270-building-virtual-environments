extends SceneTree
## A host that calls play() from its own _physics_process, as rudy.gd would, with
## a child AnimationPlayer. Logs, after both, what the clip shows on each tick.
class Host extends Node2D:
	var tick := -1
	var plan: Dictionary = {}
	func _physics_process(_d: float) -> void:
		tick += 1
		if plan.has(tick):
			($AP as AnimationPlayer).play(plan[tick])
class TickLog extends Node:
	var host: Host
	var lines: PackedStringArray = []
	func _physics_process(_d: float) -> void:
		var ap: AnimationPlayer = host.get_node("AP")
		lines.append("tick %2d frame %d anim %-6s pos %.4f cell %d rot %7.2f" % [host.tick, Engine.get_process_frames(), ap.current_animation, ap.current_animation_position if ap.current_animation != "" else -1.0, (host.get_node("Sprite") as Sprite2D).frame, (host.get_node("Grip") as Node2D).rotation_degrees])
func _clip(update_mode: int) -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	var slash := Animation.new(); slash.length = 0.3; slash.loop_mode = Animation.LOOP_NONE
	var f := slash.add_track(Animation.TYPE_VALUE); slash.track_set_path(f, "Sprite:frame"); slash.value_track_set_update_mode(f, Animation.UPDATE_DISCRETE)
	slash.track_insert_key(f, 0.0, 10)
	var r := slash.add_track(Animation.TYPE_VALUE); slash.track_set_path(r, "Grip:rotation_degrees")
	for k in [[0.0, -70.0], [2.0/60, -60.0], [11.0/60, 55.0], [0.3, 10.0]]: slash.track_insert_key(r, k[0], k[1])
	lib.add_animation("slash", slash)
	var run := Animation.new(); run.length = 0.25; run.loop_mode = Animation.LOOP_LINEAR
	var g := run.add_track(Animation.TYPE_VALUE); run.track_set_path(g, "Sprite:frame"); run.value_track_set_update_mode(g, update_mode)
	run.track_insert_key(g, 0.0, 1); run.track_insert_key(g, 0.125, 2)
	lib.add_animation("run", run)
	var idle := Animation.new(); idle.length = 0.1
	var h := idle.add_track(Animation.TYPE_VALUE); idle.track_set_path(h, "Sprite:frame"); idle.value_track_set_update_mode(h, Animation.UPDATE_DISCRETE); idle.track_insert_key(h, 0.0, 0)
	lib.add_animation("idle", idle)
	return lib
func _init() -> void:
	_run.call_deferred()
func _run() -> void:
	var mode: String = OS.get_environment("PROBE_MODE")
	var host := Host.new()
	var sprite := Sprite2D.new(); sprite.name = "Sprite"; sprite.hframes = 4; sprite.vframes = 4
	sprite.texture = ImageTexture.create_from_image(Image.create(1640, 1544, false, Image.FORMAT_RGBA8)); host.add_child(sprite)
	var grip := Node2D.new(); grip.name = "Grip"; host.add_child(grip)
	var ap := AnimationPlayer.new(); ap.name = "AP"; host.add_child(ap)
	ap.add_animation_library("", _clip(Animation.UPDATE_CONTINUOUS if mode == "continuous" else Animation.UPDATE_DISCRETE))
	print("default callback_mode_process ", ap.callback_mode_process, " (0 physics, 1 idle, 2 manual); default callback_mode_method ", ap.callback_mode_method)
	if mode != "idle": ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	if mode in ["run", "continuous"]:
		host.plan = {2: "run"}
	else:
		# a slash on tick 2; play("slash") again mid-swing on tick 8; idle on 22, slash again on 23
		host.plan = {2: "slash", 8: "slash", 22: "idle", 23: "slash"}
	var logger := TickLog.new(); logger.host = host; logger.process_physics_priority = 100
	get_root().add_child(host); get_root().add_child(logger)
	for i in 36: await physics_frame
	print("MODE ", mode, " callback_mode_process ", ap.callback_mode_process)
	for l in logger.lines: print(l)
	quit(0)
