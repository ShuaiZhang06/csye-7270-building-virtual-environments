@tool
class_name Portal
extends Area2D
## The teleport circle (ENV-PORTAL) at the end of the level. Rudy stepping onto
## it ends the level; the level guards against a second time. Drawn by code
## until the art swap: a flat circle of pale gold light on the ground, seen
## from a low side angle, and a column of light that rises once. The origin is
## at the centre of the circle, on the ground.

signal reached

const RING := Color("#E9D49A")
const CORE := Color("#FFF4D6")
const LIGHT := Color(1.0, 0.96, 0.82)
const LINE := Color("#290F0D")
const LIGHT_HEIGHT := 640.0

var _light := 0.0 ## 0 before Rudy arrives; rises to 1


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func light_up(duration: float) -> void:
	create_tween().tween_method(_set_light, 0.0, 1.0, duration)


func _on_body_entered(body: Node2D) -> void:
	if body is Rudy:
		reached.emit()


func _set_light(amount: float) -> void:
	_light = amount
	queue_redraw()


func _draw() -> void:
	_ellipse(Vector2(0, -6), Vector2(150, 28), RING, true)
	_ellipse(Vector2(0, -6), Vector2(100, 18), CORE, false)
	if _light > 0.0:
		var height := LIGHT_HEIGHT * _light
		draw_rect(Rect2(-130, -6 - height, 260, height), Color(LIGHT, 0.3 * _light))
		draw_rect(Rect2(-70, -6 - height, 140, height), Color(LIGHT, 0.35 * _light))


func _ellipse(center: Vector2, radii: Vector2, fill: Color, outlined: bool) -> void:
	var points := PackedVector2Array()
	for i in 32:
		var a := TAU * i / 32.0
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, fill)
	if outlined:
		points.append(points[0])
		draw_polyline(points, LINE, 3.0)
