extends SceneTree
# Loads resources that cannot load and prints what Godot says about each.
func _init() -> void:
	print("CASE 1 missing file: ", load("res://tests/probe/does_not_exist.tres"))
	print("CASE 2 broken tres: ", load("res://tests/probe/broken.tres"))
	var ps = load("res://tests/probe/missing_texture.tscn")
	print("CASE 3 scene with missing texture: ", ps)
	if ps: print("CASE 3 instance: ", ps.instantiate())
	var ps2 = load("res://tests/probe/missing_subscene.tscn")
	print("CASE 4 scene with missing subscene: ", ps2)
	if ps2: print("CASE 4 instance: ", ps2.instantiate())
	print("CASE 5 preload-style typed load: ", ResourceLoader.load("res://tests/probe/nope.png", "Texture2D"))
	print("DONE")
	quit(0)
