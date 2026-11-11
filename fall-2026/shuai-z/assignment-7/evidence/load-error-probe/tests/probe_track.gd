extends SceneTree
# An AnimationPlayer whose tracks name a node and a property that do not exist.
var frames := 0
func _init() -> void:
	var root := Node2D.new()
	var sprite := Sprite2D.new(); sprite.name = "Sprite"; root.add_child(sprite)
	var player := AnimationPlayer.new(); root.add_child(player)
	var clip := Animation.new(); clip.length = 0.5
	var t0 := clip.add_track(Animation.TYPE_VALUE); clip.track_set_path(t0, "Nobody:frame"); clip.track_insert_key(t0, 0.0, 0)
	var t1 := clip.add_track(Animation.TYPE_VALUE); clip.track_set_path(t1, "Sprite:no_such_prop"); clip.track_insert_key(t1, 0.0, 0)
	var lib := AnimationLibrary.new(); lib.add_animation("bad", clip); player.add_animation_library("", lib)
	get_root().add_child.call_deferred(root)
	player.play.call_deferred("bad")
func _process(_d: float) -> bool:
	frames += 1
	if frames == 5:
		print("TRACK PROBE DONE")
		quit(0)
	return false
