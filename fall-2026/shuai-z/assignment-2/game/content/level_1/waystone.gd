@tool
class_name Waystone
extends Area2D
## The checkpoint (ENV-WAYSTONE). The first time Rudy touches it, it lights,
## once, and the level brings him back to its spawn point after a death.
## Drawn by code until the art swap: a weathered standing stone with a carved
## rune that is dark, then lit. The origin is at the foot of the stone.

signal activated(waystone: Waystone)

const STONE := Color("#8E949B") ## weathered fieldstone
const RUNE_DARK := Color("#5F646B")
const RUNE_LIT := Color("#EAF6FF")
const GLOW := Color(0.82, 0.92, 1.0, 0.35)
const LINE := Color("#290F0D")

var lit := false

@onready var spawn_point: Marker2D = $SpawnPoint


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if lit or not body is Rudy:
		return
	lit = true
	queue_redraw()
	Sfx.play(&"checkpoint")
	activated.emit(self)


func _draw() -> void:
	if lit:
		draw_circle(Vector2(0, -60), 78.0, GLOW)
	var stone := PackedVector2Array([
		Vector2(-32, 0), Vector2(-35, -70), Vector2(-24, -104), Vector2(0, -112),
		Vector2(24, -104), Vector2(35, -70), Vector2(32, 0),
	])
	draw_colored_polygon(stone, STONE)
	var outline := stone.duplicate()
	outline.append(stone[0])
	draw_polyline(outline, LINE, 3.0)
	var rune := RUNE_LIT if lit else RUNE_DARK
	draw_line(Vector2(0, -90), Vector2(0, -24), rune, 5.0)
	draw_line(Vector2(0, -62), Vector2(-17, -82), rune, 5.0)
	draw_line(Vector2(0, -62), Vector2(17, -82), rune, 5.0)
