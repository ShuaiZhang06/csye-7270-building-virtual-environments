@tool
class_name Goblin
extends Area2D
## A patrolling goblin (ENEMY-GOBLIN). It walks back and forth between where it
## starts and `patrol_distance` px to its right. Landing on it from above
## defeats it, with one stomp sound, and bounces Rudy up; touching it any other
## way costs him a heart. After Rudy dies the level calls reset(), and the
## goblin is back where it started, even if it was defeated.
## It asks the physics space each tick whether its box touches Rudy, instead of
## reading the area's overlap list, which reports a contact two ticks late: by
## then a fast fall has sunk his soles too deep to tell a stomp from a side hit.
## Drawn by code until the art swap, facing right: grey-green skin, long
## pointed ears, a big nose, a ragged brown tunic and bare feet; two walk frames
## and a squashed frame. The origin is at its feet.

const SKIN := Color("#8FA07A")
const SKIN_SHADE := Color("#76875F")
const TUNIC := Color("#7A5A3C")
const LINE := Color("#290F0D")
const HEIGHT := 104.0 ## the collision box's height
const STOMP_MARGIN := 14.0 ## px: Rudy's soles must have been at most this far below its top before his last move
const WALK_FRAME_TIME := 0.18
const SQUASH_TIME := 0.4 ## s the squashed frame shows before it disappears
const OUTLINE := 3.0

@export var patrol_distance := 400.0 ## px to the right of where it starts
@export var speed := 100.0 ## px/s

var dead := false
var facing := 1

var _start_x := 0.0
var _walk_clock := 0.0
var _squash_left := 0.0
var _query := PhysicsShapeQueryParameters2D.new()

@onready var _box: CollisionShape2D = $Shape


func _ready() -> void:
	_start_x = position.x
	_query.shape = _box.shape
	_query.collision_mask = 2 # the Player layer
	_query.collide_with_areas = false


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if dead:
		if _squash_left > 0.0:
			_squash_left -= delta
			if _squash_left <= 0.0:
				visible = false
		return
	_patrol(delta)
	_query.transform = _box.global_transform
	for contact in get_world_2d().direct_space_state.intersect_shape(_query, 4):
		if contact.collider is Rudy:
			_touch(contact.collider as Rudy, delta)


## Defeats it once. It stops touching anything before the sound plays, so a
## defeated goblin ignores every later hit.
func defeat(cause: StringName) -> void:
	if dead:
		return
	dead = true
	set_deferred("monitorable", false)
	_squash_left = SQUASH_TIME
	queue_redraw()
	if cause == &"stomp":
		Sfx.play(&"stomp")


## Back where it started, alive, walking right.
func reset() -> void:
	dead = false
	position.x = _start_x
	facing = 1
	_walk_clock = 0.0
	_squash_left = 0.0
	visible = true
	set_deferred("monitorable", true)
	queue_redraw()


func _patrol(delta: float) -> void:
	position.x += facing * speed * delta
	# Turn at each end. It only turns, so a goblin placed outside its patrol
	# walks back into it instead of jumping there.
	if position.x >= _start_x + patrol_distance:
		facing = -1
	elif position.x <= _start_x:
		facing = 1
	var frame_before := _walk_frame()
	_walk_clock += delta
	if _walk_frame() != frame_before:
		queue_redraw()


func _touch(rudy: Rudy, delta: float) -> void:
	if not rudy.can_be_touched():
		return
	var top := global_position.y - HEIGHT
	var soles_before := rudy.global_position.y - rudy.velocity.y * delta
	if rudy.velocity.y > 0.0 and soles_before <= top + STOMP_MARGIN:
		defeat(&"stomp")
		rudy.bounce()
	else:
		rudy.take_hit(global_position)


func _walk_frame() -> int:
	return int(_walk_clock / WALK_FRAME_TIME) % 2


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	if dead:
		_draw_squashed()
	else:
		_draw_walking(_walk_frame())
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_walking(frame: int) -> void:
	var near_foot := Vector2(12, 0) if frame == 0 else Vector2(-6, 0)
	var far_foot := Vector2(-10, -4) if frame == 0 else Vector2(10, -4)
	_limb(Vector2(-6, -24), far_foot, 8.0, SKIN_SHADE)
	_limb(Vector2(6, -24), near_foot, 8.0, SKIN)
	_shape(PackedVector2Array([
		Vector2(-20, -64), Vector2(20, -64), Vector2(24, -26), Vector2(16, -20), Vector2(8, -26),
		Vector2(0, -19), Vector2(-8, -26), Vector2(-16, -20), Vector2(-24, -26),
	]), TUNIC)
	_limb(Vector2(14, -58), Vector2(20, -36), 7.0, SKIN)
	# A long pointed ear behind the head, the head, then the big nose.
	_shape(PackedVector2Array([Vector2(-12, -98), Vector2(-48, -116), Vector2(-18, -82)]), SKIN)
	_disc(Vector2(4, -88), 26.0, SKIN)
	_disc(Vector2(29, -86), 8.0, SKIN_SHADE)
	draw_circle(Vector2(16, -97), 3.5, LINE)
	draw_line(Vector2(8, -75), Vector2(24, -77), LINE, 2.5)


func _draw_squashed() -> void:
	_shape(PackedVector2Array([Vector2(-14, -18), Vector2(-50, -28), Vector2(-22, -8)]), SKIN)
	_ellipse(Vector2(0, -12), Vector2(42, 12), SKIN)
	draw_rect(Rect2(-30, -10, 60, 8), TUNIC)
	for x: float in [8.0, 20.0]:
		draw_line(Vector2(x - 4, -20), Vector2(x + 4, -12), LINE, 2.5)
		draw_line(Vector2(x - 4, -12), Vector2(x + 4, -20), LINE, 2.5)


func _disc(center: Vector2, radius: float, fill: Color) -> void:
	draw_circle(center, radius + OUTLINE, LINE)
	draw_circle(center, radius, fill)


func _limb(from: Vector2, to: Vector2, width: float, fill: Color) -> void:
	draw_line(from, to, LINE, width + OUTLINE * 2.0)
	draw_circle(to, width / 2.0 + OUTLINE, LINE)
	draw_line(from, to, fill, width)
	draw_circle(to, width / 2.0, fill)


func _shape(points: PackedVector2Array, fill: Color) -> void:
	draw_colored_polygon(points, fill)
	var ring := points.duplicate()
	ring.append(points[0])
	draw_polyline(ring, LINE, OUTLINE)


func _ellipse(center: Vector2, radii: Vector2, fill: Color) -> void:
	var points := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	_shape(points, fill)
