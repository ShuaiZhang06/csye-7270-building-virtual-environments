extends SceneTree
const T := preload("res://tests/probe/nope.png")
func _init() -> void:
	print("PRELOAD ", T)
	quit(0)
