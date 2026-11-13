extends SceneTree
# Claude's probe of session 5's anomaly A1: the order of play() and seek(0, true)
# when a new swing starts on a player already playing another clip.
func _initialize() -> void:
	_go()
func _variant(label: String, how: Callable) -> void:
	var look := Node2D.new(); root.add_child(look)
	var s := Sprite2D.new(); s.name = "Sprite"; s.texture = load("res://content/rudy/sheet/rudy_sheet.png"); s.hframes = 4; s.vframes = 4; look.add_child(s)
	var ap := AnimationPlayer.new(); look.add_child(ap)
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	ap.add_animation_library("", load("res://content/rudy/rudy_animations.tres"))
	ap.play("sword_idle")
	for i in 3:
		await process_frame
	how.call(ap)  # tick 0 of the swing: called between frames, as rudy.gd does in its own physics step
	var cells := []
	var stop := -1
	for t in 19:
		await process_frame
		cells.append(s.frame)
		if stop < 0 and not ap.is_playing():
			stop = t
	var slash_ticks := cells.count(10)
	print("%-28s slash cell on %d ticks; player stopped on tick %d; ticks 15-18: %s" % [label, slash_ticks, stop, cells.slice(15, 19)])
	look.queue_free()
	await process_frame
func _go() -> void:
	await _variant("play then seek (first try)", func(ap): ap.play("slash"); ap.seek(0.0, true))
	await _variant("seek then play (the fix)", func(ap): ap.seek(0.0, true); ap.play("slash"))
	await _variant("play only", func(ap): ap.play("slash"))
	quit()
