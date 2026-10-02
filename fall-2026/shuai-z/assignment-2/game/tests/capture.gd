extends Node
## Windowed capture for inspection: 1920×1080 screenshots into evidence/<step>/
## in the repository. It opens a window; run from the repository root:
##   Godot --path game --resolution 1920x1080 --always-on-top res://tests/capture.tscn -- 1a 1b
## Name the steps after "--"; without them it captures every step. Add
## --debug-collisions to draw the collision shapes; those files end in
## "-collisions". --always-on-top keeps macOS from slowing a hidden window.
## - 1a: Rudy's movement poses on flat ground (the spikes and goblins hidden).
## - 1b: the opening, the lit waystone, a fall into a cliff, the respawn, the
##   teleport circle and the end card (STORYBOARD.md panels 1, 5, 6 and 7).
## - 1c: a jump over the spikes, a stomp, a hit from a goblin with the hearts
##   and the flash, and the defeat (panels 2 and 4).

const MAIN := preload("res://app/main.tscn")
const SIZE := Vector2i(1920, 1080)

var _main: Main
var _rudy: Rudy
var _step := ""


func _ready() -> void:
	var steps := Array(OS.get_cmdline_user_args())
	if steps.is_empty():
		steps = ["1a", "1b", "1c"]
	for step: String in steps:
		_step = step
		DirAccess.make_dir_recursive_absolute(_out_dir())
		_main = MAIN.instantiate()
		add_child(_main)
		_rudy = _main.get_node("Rudy")
		await _frames(30)
		match step:
			"1a":
				await _capture_1a()
			"1b":
				await _capture_1b()
			"1c":
				await _capture_1c()
			_:
				push_error("no capture for step %s" % step)
		_main.queue_free()
		await _frames(2)
	get_tree().quit()


func _capture_1a() -> void:
	for path: String in ["Level1/Hazards", "Level1/Enemies"]:
		var threats: Node2D = _main.get_node(path)
		threats.process_mode = Node.PROCESS_MODE_DISABLED
		threats.visible = false
	await _shot("idle")
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-RUN-A")
	await _shot("run-a")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-RUN-B")
	await _shot("run-b")
	await _frames(40) # let the camera start following
	Input.action_press(&"jump")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-RISE")
	await _frames(10)
	await _shot("rise")
	Input.action_release(&"jump")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-FALL")
	await _frames(10)
	await _shot("fall")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-RUN-A")
	Input.action_release(&"move_right")
	Input.action_press(&"move_left")
	await _frames(30)
	await _shot("run-left")
	Input.action_release(&"move_left")
	await _frames(20)
	await _shot("idle-left")


func _capture_1b() -> void:
	var waystone: Waystone = _main.get_node("Level1/Waystone")
	var portal: Portal = _main.get_node("Level1/Portal")
	await _shot("opening") # panel 1, without the title
	# Run past the waystone and stop beside it.
	_rudy.global_position = Vector2(waystone.global_position.x - 500.0, 840.0)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.global_position.x > waystone.spawn_point.global_position.x - 30.0)
	Input.action_release(&"move_right")
	await _frames(60)
	await _shot("waystone-lit")
	# Walk into the first cliff (panel 5).
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.global_position.y > 950.0)
	Input.action_release(&"move_right")
	await _shot("cliff-fall")
	await _until(func() -> bool: return _rudy.mode == Rudy.Mode.RESPAWNING)
	await _frames(28) # the fade-in is over
	await _shot("respawn")
	await _until(func() -> bool: return _main.state == Main.State.PLAYING)
	# Onto the teleport circle (panel 6), then the end card.
	_rudy.global_position = Vector2(portal.global_position.x - 600.0, 840.0)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _main.state == Main.State.COMPLETE)
	Input.action_release(&"move_right")
	await _frames(100) # the light has risen and the camera has pulled back
	await _shot("teleport-circle")
	var hud: Hud = _main.get_node("Hud")
	await _until(func() -> bool: return hud.is_showing_end_card())
	await _frames(5)
	await _shot("end-card")


func _capture_1c() -> void:
	var spikes: Spikes = _main.get_node("Level1/Hazards/SpikesA")
	var goblin_a: Goblin = _main.get_node("Level1/Enemies/GoblinA")
	var goblin_b: Goblin = _main.get_node("Level1/Enemies/GoblinB")
	# Over the spikes, toward the first goblin (panel 2).
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.global_position.x >= spikes.global_position.x - 180.0)
	Input.action_press(&"jump")
	await _until(func() -> bool: return _rudy.global_position.x >= spikes.global_position.x)
	Input.action_release(&"jump")
	await _shot("over-the-spikes")
	# Keep running until he has landed past them: let go in the air and he drops onto them.
	await _until(func() -> bool:
		return _rudy.is_on_floor() and _rudy.global_position.x > spikes.global_position.x + 100.0)
	Input.action_release(&"move_right")
	# From here the goblins hold still, so each shot is set up exactly.
	for goblin: Goblin in [goblin_a, goblin_b]:
		goblin.speed = 0.0
	# Onto a goblin from above: the stomp.
	await _until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor())
	_rudy.global_position = Vector2(goblin_a.global_position.x, 840.0 - Goblin.HEIGHT - 120.0)
	_rudy.velocity = Vector2(0, 100)
	await _frames(1)
	await _until(func() -> bool: return goblin_a.dead)
	await _frames(4)
	await _shot("stomp")
	await _until(func() -> bool: return _rudy.is_on_floor())
	# Walking into a goblin, three times: a heart each, the knockback and the
	# flash (panel 4), then the defeat.
	for shot: String in ["hurt", "hurt-again", "defeat"]:
		await _until(func() -> bool:
			return _rudy.mode == Rudy.Mode.PLAY and _rudy.is_on_floor() and not _rudy.is_invulnerable())
		_rudy.global_position = Vector2(goblin_b.global_position.x - 120.0, 840.0)
		_rudy.velocity = Vector2.ZERO
		await _frames(2)
		var hearts := _rudy.hearts
		Input.action_press(&"move_right")
		await _until(func() -> bool: return _rudy.hearts < hearts)
		Input.action_release(&"move_right")
		await _frames(30 if shot == "defeat" else 4)
		await _shot(shot)


func _out_dir() -> String:
	return ProjectSettings.globalize_path("res://").path_join("../evidence/%s" % _step).simplify_path()


func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var rendered := image.get_size()
	if rendered != SIZE:
		image.resize(SIZE.x, SIZE.y, Image.INTERPOLATE_LANCZOS)
	var suffix := "-collisions" if get_tree().debug_collisions_hint else ""
	var path := _out_dir().path_join("%s-%s%s.png" % [_step, label, suffix])
	image.save_png(path)
	print("saved %s (rendered at %d x %d, pose %s)" % [path.get_file(), rendered.x, rendered.y, _rudy.pose])


func _until(condition: Callable) -> void:
	for i in 600:
		if condition.call():
			return
		await get_tree().physics_frame
	push_error("capture %s: a condition never came true" % _step)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
