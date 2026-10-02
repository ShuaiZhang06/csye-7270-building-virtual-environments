extends Node
## Windowed capture for inspection. Step 1a: runs Rudy through each movement
## pose and saves one 1920×1080 screenshot per pose to evidence/1a/ in the
## repository. It opens a window; run from the repository root:
##   Godot --path game --resolution 1920x1080 res://tests/capture.tscn
## Add --debug-collisions to draw the collision shapes; those files end in
## "-collisions".

const MAIN := preload("res://app/main.tscn")
const SIZE := Vector2i(1920, 1080)

var _out := ProjectSettings.globalize_path("res://").path_join("../evidence/1a").simplify_path()
var _rudy: Rudy


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(_out)
	var main := MAIN.instantiate()
	add_child(main)
	_rudy = main.get_node("Rudy")
	await _frames(30)
	await _shot("idle")
	Input.action_press(&"move_right")
	await _until_pose(&"CHAR-RUN-A")
	await _shot("run-a")
	await _until_pose(&"CHAR-RUN-B")
	await _shot("run-b")
	await _frames(40) # let the camera start following
	Input.action_press(&"jump")
	await _until_pose(&"CHAR-RISE")
	await _frames(10)
	await _shot("rise")
	Input.action_release(&"jump")
	await _until_pose(&"CHAR-FALL")
	await _frames(10)
	await _shot("fall")
	await _until_pose(&"CHAR-RUN-A")
	Input.action_release(&"move_right")
	Input.action_press(&"move_left")
	await _frames(20)
	await _shot("run-left")
	Input.action_release(&"move_left")
	await _frames(20)
	await _shot("idle-left")
	get_tree().quit()


func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var rendered := image.get_size()
	if rendered != SIZE:
		image.resize(SIZE.x, SIZE.y, Image.INTERPOLATE_LANCZOS)
	var suffix := "-collisions" if get_tree().debug_collisions_hint else ""
	var path := _out.path_join("1a-%s%s.png" % [label, suffix])
	image.save_png(path)
	print("saved %s (rendered at %d x %d, pose %s)" % [path.get_file(), rendered.x, rendered.y, _rudy.pose])


func _until_pose(id: StringName) -> void:
	for i in 300:
		if _rudy.pose == id:
			return
		await get_tree().physics_frame
	push_error("pose %s never showed" % id)


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
