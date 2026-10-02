@tool
class_name GroundSegment
extends StaticBody2D
## A greybox block of ground. The node's position is its top-left corner; it
## draws itself and sizes its own collision box from `size`, in the editor too.
## A gap between two segments is a cliff.

const PATH := Color("#9C8463") ## planned Level 1 path colour
const GRASS := Color("#8FA85E") ## planned meadow colour
const LINE := Color("#290F0D")
const MARK_SPACING := 96.0 ## the ground marks show speed while the camera follows

@export var size := Vector2(1920, 240):
	set(value):
		size = value
		_fit_shape()
		queue_redraw()

var _shape: CollisionShape2D


func _ready() -> void:
	_shape = CollisionShape2D.new()
	add_child(_shape)
	_fit_shape()


func _fit_shape() -> void:
	if _shape == null:
		return
	var box := RectangleShape2D.new()
	box.size = size
	_shape.shape = box
	_shape.position = size / 2.0


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), PATH)
	draw_rect(Rect2(0, 0, size.x, 12), GRASS)
	var x := MARK_SPACING / 2.0
	while x < size.x:
		draw_line(Vector2(x, 26), Vector2(x - 10, 38), PATH.darkened(0.25), 3.0)
		x += MARK_SPACING
	draw_line(Vector2.ZERO, Vector2(size.x, 0), LINE, 3.0)
	draw_line(Vector2.ZERO, Vector2(0, size.y), LINE, 3.0)
	draw_line(Vector2(size.x, 0), size, LINE, 3.0)
