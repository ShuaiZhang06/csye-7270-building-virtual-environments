class_name FlyingGear
extends Node2D
## The sword and shield flying off Rudy when a hit takes them (STORYBOARD.md
## panel 4): thrown up and away from the hit, spinning, fading out. It is only
## a picture and touches nothing.

const LIFETIME := 0.6 ## s until it has faded out
const GRAVITY := 1800.0 ## px/s²

var velocity := Vector2.ZERO

var _age := 0.0


func _process(delta: float) -> void:
	_age += delta
	velocity.y += GRAVITY * delta
	position += velocity * delta
	rotation += 9.0 * delta * signf(velocity.x)
	modulate.a = clampf(1.0 - _age / LIFETIME, 0.0, 1.0)
	if _age >= LIFETIME:
		queue_free()


func _draw() -> void:
	GearArt.crossed(self, Vector2.ZERO, 16.0)
