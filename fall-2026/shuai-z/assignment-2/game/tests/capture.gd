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
## - 1d: the sword-and-shield pickup, the sword form, a slash that cuts a
##   goblin, and the gear flying off after a hit (panels 3 and 4).
## - 2a: Rudy's generated frames with the outer outline: every pose he can take,
##   facing right and left, and the flash, each cropped around him at game
##   size (520 x 380 px); and two full screens, the opening and the slash.

const MAIN := preload("res://app/main.tscn")
const SIZE := Vector2i(1920, 1080)
const CROP := Vector2i(520, 380) ## around Rudy, his soles 300 px from the top

var _main: Main
var _rudy: Rudy
var _step := ""


func _ready() -> void:
	var steps := Array(OS.get_cmdline_user_args())
	if steps.is_empty():
		steps = ["1a", "1b", "1c", "1d", "2a"]
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
			"1d":
				await _capture_1d()
			"2a":
				await _capture_2a()
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


func _capture_1d() -> void:
	var pickup: SwordPickup = _main.get_node("Level1/SwordPickup")
	var spikes: Spikes = _main.get_node("Level1/Hazards/SpikesA")
	var goblin_b: Goblin = _main.get_node("Level1/Enemies/GoblinB")
	goblin_b.speed = 0.0 # it holds still for the slash
	# Running up to the pickup (panel 3, in play).
	_rudy.global_position = Vector2(pickup.global_position.x - 330.0, 840.0)
	await _frames(2)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.global_position.x >= pickup.global_position.x - 90.0)
	await _shot("pickup")
	await _until(func() -> bool: return _rudy.gear == Rudy.Gear.SWORD)
	Input.action_release(&"move_right")
	await _until(func() -> bool: return _rudy.is_on_floor() and _rudy.velocity.x == 0.0)
	await _frames(10)
	await _shot("sword-idle")
	# A cut that reaches a goblin.
	_rudy.global_position = Vector2(goblin_b.global_position.x - 70.0, 840.0)
	await _frames(4)
	Input.action_press(&"slash")
	await _until(func() -> bool: return goblin_b.dead)
	Input.action_release(&"slash")
	await _frames(2)
	await _shot("slash")
	await _until(func() -> bool: return not _rudy.is_slashing())
	# A hit takes the gear: it flies off (panel 4).
	_rudy.global_position = Vector2(spikes.global_position.x - 200.0, 840.0)
	await _frames(2)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.gear == Rudy.Gear.NONE)
	Input.action_release(&"move_right")
	await _frames(8)
	await _shot("gear-flies")


func _capture_2a() -> void:
	await _shot("opening")
	var hazards: Node2D = _main.get_node("Level1/Hazards")
	var enemies: Node2D = _main.get_node("Level1/Enemies")
	for threats: Node2D in [hazards, enemies]:
		threats.process_mode = Node.PROCESS_MODE_DISABLED
		threats.visible = false
	# The default form's movement, as in 1a.
	await _shot("idle", true)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-RUN-A")
	await _shot("run-a", true)
	await _until(func() -> bool: return _rudy.pose == &"CHAR-RUN-B")
	await _shot("run-b", true)
	Input.action_press(&"jump")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-RISE")
	await _frames(10)
	await _shot("rise", true)
	Input.action_release(&"jump")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-FALL")
	await _frames(8)
	await _shot("fall", true)
	await _until(func() -> bool: return _rudy.is_on_floor())
	Input.action_release(&"move_right")
	Input.action_press(&"move_left")
	await _frames(30)
	Input.action_release(&"move_left")
	await _frames(20)
	await _shot("idle-left", true)
	# The spikes: the hit, the flash, then the defeat and the respawn.
	hazards.process_mode = Node.PROCESS_MODE_INHERIT
	hazards.visible = true
	var spikes: Spikes = hazards.get_node("SpikesA")
	_rudy.global_position = Vector2(spikes.global_position.x - 220.0, 840.0)
	await _frames(2)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.mode == Rudy.Mode.HURT)
	Input.action_release(&"move_right")
	var look: Node2D = _rudy.get_node("Look")
	await _until(func() -> bool: return look.modulate.a == 1.0) # between flashes
	await _shot("hurt", true)
	await _until(func() -> bool: return _rudy.is_on_floor() and look.modulate.a < 1.0)
	await _shot("flash", true)
	await _until(func() -> bool: return _rudy.mode == Rudy.Mode.PLAY and not _rudy.is_invulnerable())
	_rudy.hearts = 1 # the next hit is the last heart
	_rudy.global_position = Vector2(spikes.global_position.x - 220.0, 840.0)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.mode == Rudy.Mode.DEFEATED)
	Input.action_release(&"move_right")
	await _frames(20)
	await _shot("defeat", true)
	await _until(func() -> bool: return _rudy.mode == Rudy.Mode.RESPAWNING)
	await _frames(28) # the fade-in is over
	await _shot("respawn", true)
	await _until(func() -> bool: return _main.state == Main.State.PLAYING)
	hazards.process_mode = Node.PROCESS_MODE_DISABLED
	hazards.visible = false
	# The sword form: the pickup, its movement, its idle and the slash.
	var pickup: SwordPickup = _main.get_node("Level1/SwordPickup")
	_rudy.global_position = Vector2(pickup.global_position.x - 300.0, 840.0)
	await _frames(2)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _rudy.gear == Rudy.Gear.SWORD)
	await _until(func() -> bool: return _rudy.pose == &"CHAR-SWORD-RUN-A")
	await _shot("sword-run-a", true)
	await _until(func() -> bool: return _rudy.pose == &"CHAR-SWORD-RUN-B")
	await _shot("sword-run-b", true)
	Input.action_press(&"jump")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-SWORD-RISE")
	await _frames(10)
	await _shot("sword-rise", true)
	Input.action_release(&"jump")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-SWORD-FALL")
	await _frames(8)
	await _shot("sword-fall", true)
	await _until(func() -> bool: return _rudy.is_on_floor())
	Input.action_release(&"move_right")
	await _frames(30)
	await _shot("sword-idle", true)
	Input.action_press(&"slash")
	await _until(func() -> bool: return _rudy.pose == &"CHAR-SWORD-SLASH")
	Input.action_release(&"slash")
	await _frames(6)
	await _shot("slash", true)
	await _shot("slash-full")
	# On the teleport circle.
	var portal: Portal = _main.get_node("Level1/Portal")
	_rudy.global_position = Vector2(portal.global_position.x - 400.0, 840.0)
	Input.action_press(&"move_right")
	await _until(func() -> bool: return _main.state == Main.State.COMPLETE)
	Input.action_release(&"move_right")
	await _frames(40)
	await _shot("celebrate", true)


func _out_dir() -> String:
	return ProjectSettings.globalize_path("res://").path_join("../evidence/%s" % _step).simplify_path()


## Saves the screen, or with `crop` only the CROP around Rudy.
func _shot(label: String, crop := false) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var rendered := image.get_size()
	if rendered != SIZE:
		image.resize(SIZE.x, SIZE.y, Image.INTERPOLATE_LANCZOS)
	if crop:
		var soles := Vector2i(_rudy.get_global_transform_with_canvas().origin.round())
		var corner := (soles - Vector2i(CROP.x / 2, 300)).clamp(Vector2i.ZERO, SIZE - CROP)
		image = image.get_region(Rect2i(corner, CROP))
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
