class_name Hud
extends CanvasLayer
## The HUD. For now it holds only the debug line: Rudy's pose ID, whether he is
## on the ground, his speed and position, and how many times each sound ID has
## played. F1 hides or shows it.

var _rudy: Rudy

@onready var _debug: Label = $Debug


func track(rudy: Rudy) -> void:
	_rudy = rudy


func _process(_delta: float) -> void:
	if _rudy == null or not _debug.visible:
		return
	_debug.text = "%s   %s   speed %d, %d   x %d\nSfx: %s   (F1 hides this line)" % [
		_rudy.pose,
		"on the ground" if _rudy.is_on_floor() else "in the air",
		roundi(_rudy.velocity.x), roundi(_rudy.velocity.y),
		roundi(_rudy.global_position.x),
		Sfx.summary(),
	]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_debug"):
		_debug.visible = not _debug.visible
