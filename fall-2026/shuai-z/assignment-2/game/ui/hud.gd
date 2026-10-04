class_name Hud
extends CanvasLayer
## The HUD: Rudy's hearts (UI-HEART), the debug line, the black fade, and the
## end card: "Level complete" over a high view of the road to the castle
## (ENV-ENDCARD, STORYBOARD.md panel 7), which fades in from the black. The
## debug line shows Rudy's pose ID, whether he is on the ground, his speed and
## position, the level's state, and how many times each sound ID has played. F1
## hides or shows it.

var _rudy: Rudy
var _status := ""

@onready var _hearts: Hearts = $Hearts
@onready var _debug: Label = $Debug
@onready var _fade: ColorRect = $Fade
@onready var _end_card: Control = $EndCard


func track(rudy: Rudy) -> void:
	_rudy = rudy
	_hearts.max_hearts = rudy.max_hearts
	set_hearts(rudy.hearts)
	rudy.hearts_changed.connect(set_hearts)


func set_hearts(hearts: int) -> void:
	_hearts.shown = hearts


func hearts_shown() -> int:
	return _hearts.shown


func set_status(text: String) -> void:
	_status = text


## Fades the screen to black (alpha 1) or back (alpha 0); await it.
func fade_to(alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", alpha, duration)
	await tween.finished


## Shows the end card, fading it in over `duration`.
func show_end_card(duration: float) -> void:
	_end_card.modulate.a = 0.0
	_end_card.visible = true
	create_tween().tween_property(_end_card, "modulate:a", 1.0, duration)


func is_showing_end_card() -> bool:
	return _end_card.visible


func _process(_delta: float) -> void:
	if _rudy == null or not _debug.visible:
		return
	_debug.text = "%s   %s   %s   speed %d, %d   x %d   level %s\nSfx: %s   (F1 hides this line)" % [
		_rudy.pose,
		"sword and shield" if _rudy.gear == Rudy.Gear.SWORD else "no gear",
		"on the ground" if _rudy.is_on_floor() else "in the air",
		roundi(_rudy.velocity.x), roundi(_rudy.velocity.y),
		roundi(_rudy.global_position.x),
		_status,
		Sfx.summary(),
	]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_debug"):
		_debug.visible = not _debug.visible
