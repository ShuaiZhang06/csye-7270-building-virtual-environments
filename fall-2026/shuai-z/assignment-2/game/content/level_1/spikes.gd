@tool
class_name Spikes
extends Area2D
## A row of spikes (ENV-SPIKES). Touching them costs Rudy a heart. They check
## every physics tick, so standing on them hurts again once his invulnerability
## ends. Drawn by code until the art swap: five iron spikes on a wooden base,
## 160 px wide. The origin is at the middle of the base, on the ground.

const IRON := Color("#9AA0A8")
const IRON_SHADE := Color("#7C828B")
const WOOD := Color("#7A5A3C")
const LINE := Color("#290F0D")
const WIDTH := 160.0
const SPIKE_HEIGHT := 40.0


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for body in get_overlapping_bodies():
		if body is Rudy:
			(body as Rudy).take_hit(global_position)


func _draw() -> void:
	var step := WIDTH / 5.0
	for i in 5:
		var left := -WIDTH / 2.0 + i * step
		var tip := Vector2(left + step / 2.0, -SPIKE_HEIGHT - 8.0)
		var spike := PackedVector2Array([Vector2(left + 2, -8), tip, Vector2(left + step - 2, -8)])
		draw_colored_polygon(spike, IRON)
		draw_colored_polygon(PackedVector2Array([tip, Vector2(left + step - 2, -8), Vector2(tip.x, -8)]), IRON_SHADE)
		spike.append(spike[0])
		draw_polyline(spike, LINE, 2.5)
	var base := Rect2(-WIDTH / 2.0 - 4.0, -10.0, WIDTH + 8.0, 10.0)
	draw_rect(base, WOOD)
	draw_rect(base, LINE, false, 2.5)
