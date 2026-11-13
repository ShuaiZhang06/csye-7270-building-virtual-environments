extends Node
## Rudy on a floor with the sword; one slash press sent three ways. Logs every
## physics tick: pose, the swing clock, whether the hitbox is live.
var rudy
var logger
func _key(pressed: bool) -> void:
	var e := InputEventKey.new(); e.physical_keycode = KEY_J; e.pressed = pressed
	Input.parse_input_event(e)
func _setup() -> void:
	var root := Node2D.new(); add_child(root)
	var floor := StaticBody2D.new(); var cs := CollisionShape2D.new(); var r := RectangleShape2D.new(); r.size = Vector2(20000, 100); cs.shape = r; cs.position = Vector2(0, 50); floor.add_child(cs); root.add_child(floor)
	rudy = (load("res://content/rudy/rudy.tscn") as PackedScene).instantiate(); rudy.position = Vector2(0, 0); root.add_child(rudy); rudy.equip_sword()
	logger = load("res://tests/probe/tick_logger.gd").new(); logger.rudy = rudy; logger.process_physics_priority = 100; root.add_child(logger)
func _ready() -> void:
	_run.call_deferred()
func _run() -> void:
	_setup()
	for i in 20: await get_tree().process_frame
	var mode: String = OS.get_environment("PROBE_MODE")
	print("MODE ", mode, " fixed_fps ", Engine.max_fps, " ticks/s ", Engine.physics_ticks_per_second)
	logger.lines.clear(); logger.t0 = -1
	if mode == "frame":
		_key(true)
		await get_tree().process_frame
		_key(false)
	elif mode == "physics":
		# shift the press by one physics tick: send it between the two ticks of a frame and flush
		await get_tree().process_frame
		await get_tree().physics_frame
		_key(true); Input.flush_buffered_events()
		await get_tree().process_frame
		_key(false)
	for i in 30: await get_tree().physics_frame
	for l in logger.lines: print(l)
	get_tree().quit(0)
