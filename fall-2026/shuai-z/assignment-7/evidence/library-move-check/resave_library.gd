extends SceneTree
# Saves the loaded clip library the way the editor would, to a scratch file.
func _init() -> void:
	var out := OS.get_cmdline_user_args()[0]
	var lib: AnimationLibrary = load("res://animations/rudy_animations.tres")
	print("save error %d" % ResourceSaver.save(lib, out))
	for n in lib.get_animation_list():
		print("%s step %.17f" % [n, lib.get_animation(n).step])
	quit(0)
