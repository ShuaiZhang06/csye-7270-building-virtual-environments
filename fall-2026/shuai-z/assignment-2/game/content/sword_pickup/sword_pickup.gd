@tool
class_name SwordPickup
extends Area2D
## The sword-and-shield pickup (PROP-SWORDSHIELD). Rudy's first touch gives him
## the sword form, with one pickup sound. It then stops monitoring and hides; it
## is never freed, because after a death the level calls reset() and it is back
## where it was. Drawn by code until the art swap: the sword crossed over the
## shield with a faint warm glow, floating and bobbing a little. The origin is on
## the ground below it.

const GLOW := Color(1.0, 0.9, 0.6, 0.3)
const HEIGHT := 64.0 ## px from the ground to its centre
const BOB := 6.0 ## px up and down
const BOB_PERIOD := 1.6 ## s

var taken := false

var _clock := 0.0


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()


## Back where it was, for Rudy to take again.
func reset() -> void:
	taken = false
	visible = true
	set_deferred("monitoring", true)


func _on_body_entered(body: Node2D) -> void:
	if taken or not body is Rudy:
		return
	var rudy := body as Rudy
	if not rudy.can_be_touched() or rudy.gear != Rudy.Gear.NONE:
		return
	taken = true
	set_deferred("monitoring", false)
	visible = false
	rudy.equip_sword()
	Sfx.play(&"pickup")


func _draw() -> void:
	var center := Vector2(0, -HEIGHT + sin(_clock * TAU / BOB_PERIOD) * BOB)
	draw_circle(center, 34.0, GLOW)
	GearArt.crossed(self, center, 20.0)
