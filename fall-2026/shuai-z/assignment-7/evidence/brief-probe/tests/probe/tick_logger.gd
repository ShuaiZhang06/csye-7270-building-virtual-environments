extends Node
## Runs after Rudy each physics tick (higher process_physics_priority) and logs what he shows.
var rudy
var lines: PackedStringArray = []
var t0 := -1
func _physics_process(_d: float) -> void:
	var t := Engine.get_physics_frames()
	if t0 < 0: t0 = t
	var box: CollisionShape2D = rudy.get_node("SwordHitbox/Shape")
	lines.append("tick %d frame %d pose %s clock %.4f live %s just_pressed %s" % [t - t0, Engine.get_process_frames(), rudy.pose, rudy.get("_slash_clock"), not box.disabled, Input.is_action_just_pressed(&"slash")])
