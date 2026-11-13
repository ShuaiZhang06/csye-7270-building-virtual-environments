extends SceneTree
func _init() -> void:
	var a := Animation.new()
	a.set("loop", true)
	print("set('loop', true) in code -> loop_mode ", a.loop_mode)
	var b := Animation.new()
	print("'loop' in Animation: ", "loop" in b, " ; get('loop'): ", b.get("loop"))
	var ap := AnimationPlayer.new()
	ap.set("playback_speed", 2.0)
	print("set('playback_speed', 2.0) -> speed_scale ", ap.speed_scale)
	var s := AnimatedSprite2D.new()
	s.set("frames", SpriteFrames.new()); s.set("playing", true)
	print("AnimatedSprite2D set('frames') -> sprite_frames ", s.sprite_frames, " ; set('playing', true) -> is_playing ", s.is_playing())
	quit(0)
