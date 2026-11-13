extends Node
# Claude's probe after step 4b: one slash on the real Rudy, logged every tick
# after Rudy (process_physics_priority 100): what is drawn, and the rig's keys.
@onready var rudy: Rudy = $World/Rudy
var tick := -1
var press_tick := 12
func _ready() -> void:
	rudy.gear = Rudy.Gear.SWORD
func _physics_process(_d: float) -> void:
	tick += 1
	var look := rudy.get_node("Look")
	var rig: Node2D = look.get_node("SlashRig")
	var grip: Node2D = rig.get_node("Lean/Grip")
	var lean: Node2D = rig.get_node("Lean")
	var arc: Sprite2D = rig.get_node("Lean/Arc")
	var ap: AnimationPlayer = look.get_node("AnimationPlayer")
	var s := tick - press_tick
	if s >= -2 and s <= 19:
		print("swing tick %3d  clip %-10s pos %.4f  sprite %-5s rig %-5s  grip %7.2f  lean %5.2f x %4.1f  arc %.2f  pose %s  live %s" % [s,
			ap.current_animation, ap.current_animation_position if ap.is_playing() else -1.0,
			look.get_node("Sprite").visible, rig.visible, grip.rotation_degrees, lean.rotation_degrees, lean.position.x,
			arc.modulate.a, rudy.pose, not rudy.get_node("SwordHitbox/Shape").disabled])
	if tick == press_tick - 1:
		var e := InputEventKey.new(); e.physical_keycode = KEY_J; e.pressed = true
		Input.parse_input_event(e)
	if tick == press_tick + 3:
		var e := InputEventKey.new(); e.physical_keycode = KEY_J; e.pressed = false
		Input.parse_input_event(e)
	if tick == press_tick + 22:
		get_tree().quit()
