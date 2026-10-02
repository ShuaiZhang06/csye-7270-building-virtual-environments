class_name Hearts
extends Control
## Code-drawn stand-in for UI-HEART until the art swap: one heart for each of
## Rudy's hearts, full or empty.

const FULL := Color("#C8504A")
const EMPTY := Color(0.16, 0.06, 0.05, 0.25)
const LINE := Color("#290F0D")
const SIZE := 22.0 ## px from the centre to the side of a heart
const SPACING := 60.0

var max_hearts := 3:
	set(value):
		max_hearts = value
		queue_redraw()
var shown := 3: ## how many are full
	set(value):
		shown = value
		queue_redraw()


func _draw() -> void:
	for i in max_hearts:
		_heart(Vector2(SIZE + 4.0 + i * SPACING, SIZE + 4.0), FULL if i < shown else EMPTY)


func _heart(center: Vector2, fill: Color) -> void:
	var points := PackedVector2Array()
	for k in 48:
		var t := TAU * k / 48.0
		var p := Vector2(16.0 * pow(sin(t), 3), -(13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)))
		points.append(center + p * (SIZE / 16.0))
	draw_colored_polygon(points, fill)
	points.append(points[0])
	draw_polyline(points, LINE, 3.0)
