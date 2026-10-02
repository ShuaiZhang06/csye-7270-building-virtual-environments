@tool
extends Node2D
## Code-drawn stand-in for Level 1's parallax layers until the art swap.
## "far" stands in for ENV-SKY-CASTLE: hazy hills and a small castle on the
## horizon. "mid" stands in for ENV-FIELDS: a green meadow meeting golden wheat.
## The sky is the clear colour. The colours are the planned Level 1 palette in
## CHARACTER-SHEET.md, so Rudy's readability can be judged early.

const HILL_FAR := Color("#BFD2C4")
const HILL_NEAR := Color("#B2C7A9")
const CASTLE := Color("#A3ABB5")
const CASTLE_SHADE := Color("#8E96A1")
const MEADOW := Color("#8FA85E")
const WHEAT := Color("#D8B858")
const WHEAT_STALK := Color("#BE9E43")
const CASTLE_X := 1400.0 ## on the far layer, it shows right of centre at the start and left of centre at the end
const STEP := 16.0
const BASE_Y := 880.0 ## below the ground line, hidden by the ground

@export_enum("far", "mid") var layer: String = "far":
	set(value):
		layer = value
		queue_redraw()


func _draw() -> void:
	if layer == "far":
		_band(-1500.0, 3500.0, _far_hill_top, HILL_FAR)
		_castle(Vector2(CASTLE_X, _far_hill_top(CASTLE_X) + 6.0))
		_band(-1500.0, 3500.0, _near_hill_top, HILL_NEAR)
	else:
		_band(-1500.0, 5500.0, _meadow_top, MEADOW)
		_band(-1500.0, 5500.0, _wheat_top, WHEAT)
		_wheat_stalks(-1500.0, 5500.0)


func _far_hill_top(x: float) -> float:
	return 470.0 + 18.0 * sin(x / 260.0) + 10.0 * sin(x / 97.0 + 1.3)


func _near_hill_top(x: float) -> float:
	return 520.0 + 22.0 * sin(x / 330.0 + 0.7) + 9.0 * sin(x / 123.0)


func _meadow_top(x: float) -> float:
	return 565.0 + 16.0 * sin(x / 210.0 + 0.4) + 8.0 * sin(x / 77.0)


func _wheat_top(x: float) -> float:
	return 645.0 + 20.0 * sin(x / 180.0) + 10.0 * sin(x / 61.0 + 2.0)


func _band(x0: float, x1: float, top: Callable, fill: Color) -> void:
	var points := PackedVector2Array()
	var x := x0
	while x <= x1:
		points.append(Vector2(x, top.call(x)))
		x += STEP
	points.append(Vector2(x1, BASE_Y))
	points.append(Vector2(x0, BASE_Y))
	draw_colored_polygon(points, fill)


func _wheat_stalks(x0: float, x1: float) -> void:
	var x := x0
	var row := 0
	while x <= x1:
		var top := _wheat_top(x)
		for depth: float in [8.0, 52.0, 104.0]:
			var sway := 3.0 if (row + int(depth)) % 2 == 0 else -3.0
			draw_line(Vector2(x, top + depth), Vector2(x + sway, top + depth + 16.0), WHEAT_STALK, 2.0)
		x += 22.0
		row += 1


## A small grey castle far away: a keep between two round towers with pointed
## roofs. `base` is the middle of its foot.
func _castle(base: Vector2) -> void:
	draw_rect(Rect2(base.x - 34, base.y - 58, 68, 58), CASTLE)
	for i in 5:
		draw_rect(Rect2(base.x - 34 + i * 15, base.y - 66, 8, 8), CASTLE)
	for side: float in [-1.0, 1.0]:
		var cx := base.x + side * 44.0
		draw_rect(Rect2(cx - 11, base.y - 84, 22, 84), CASTLE)
		draw_colored_polygon(PackedVector2Array([
			Vector2(cx - 14, base.y - 84), Vector2(cx, base.y - 112), Vector2(cx + 14, base.y - 84),
		]), CASTLE_SHADE)
	draw_rect(Rect2(base.x - 8, base.y - 22, 16, 22), CASTLE_SHADE)
