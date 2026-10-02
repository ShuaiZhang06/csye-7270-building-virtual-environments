class_name RudyPlaceholder
extends Node2D
## Code-drawn stand-in for Rudy's sprites until the art swap (step 2).
## It draws him at game size, 160 px from the soles (y = 0) to the cowlick tip,
## with the chin at 107 px and the top of the head at 151 px, in the palette
## sampled from CHAR-REF-07 (CHARACTER-SHEET.md, revision 2). The pose's asset ID
## is written above his head, so each state can be checked before the art exists.

const HAIR := Color("#C9905A")
const EYE := Color("#475827")
const ROBE := Color("#6F717D")
const SKIN := Color("#FCC5A6")
const LEATHER := Color("#754634")
const TRIM := Color("#D4BEA6")
const LINE := Color("#290F0D")
const SHADE := Color("#55575F") ## the hood, the legs and the far arm
const OUTLINE := 3.0
const HIP := Vector2(0, -30)
const SHOULDER := Vector2(2, -97)

## Per pose: the near and far sole (x, y), the near and far arm angle in degrees
## (0 hangs straight down, 90 points forward, 180 points up), the forward lean,
## and how far the body drops toward the ground (kneeling).
const POSES := {
	&"CHAR-IDLE": [Vector2(6, 0), Vector2(-6, 0), 10.0, -10.0, 0.0, 0.0],
	&"CHAR-RUN-A": [Vector2(20, 0), Vector2(-22, -8), -45.0, 50.0, 10.0, 0.0],
	&"CHAR-RUN-B": [Vector2(12, -16), Vector2(0, 0), 15.0, -15.0, 6.0, 0.0],
	&"CHAR-RISE": [Vector2(8, -20), Vector2(-6, -16), 120.0, -150.0, 0.0, 0.0],
	&"CHAR-FALL": [Vector2(10, 0), Vector2(-10, -4), 100.0, -70.0, -4.0, 0.0],
	&"CHAR-RESPAWN": [Vector2(18, 0), Vector2(-26, -2), 70.0, -10.0, 14.0, 24.0],
	&"CHAR-CELEBRATE": [Vector2(10, 0), Vector2(-10, 0), 125.0, -120.0, -6.0, 0.0],
	&"CHAR-HURT": [Vector2(14, -6), Vector2(-4, -14), 100.0, 140.0, -20.0, 0.0],
	&"CHAR-DEFEAT": [Vector2(34, 0), Vector2(28, -2), -30.0, -40.0, -8.0, 30.0],
}

var _pose: StringName = &"CHAR-IDLE"


func show_pose(id: StringName) -> void:
	if id != _pose:
		_pose = id
		queue_redraw()


func _draw() -> void:
	var p: Array = POSES.get(_pose, POSES[&"CHAR-IDLE"])
	var near_sole: Vector2 = p[0]
	var far_sole: Vector2 = p[1]
	var lean := deg_to_rad(float(p[4]))
	var drop := Vector2(0, float(p[5]))
	var upper := Transform2D(0.0, drop) * Transform2D(lean, HIP) * Transform2D(0.0, -HIP)

	# The far side first, so the body covers it.
	_leg(Vector2(-4, HIP.y) + drop, far_sole, SHADE.darkened(0.2), LEATHER.darkened(0.2))
	draw_set_transform_matrix(upper)
	_arm(float(p[3]), SHADE)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	_leg(Vector2(4, HIP.y) + drop, near_sole, SHADE, LEATHER)
	draw_set_transform_matrix(upper)
	_robe()
	_head()
	_arm(float(p[2]), ROBE)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	_label()


func _leg(hip: Vector2, sole: Vector2, fill: Color, boot_fill: Color) -> void:
	_limb(hip, sole + Vector2(0, -9), 9.0, fill)
	var boot := Rect2(sole.x - 7.0, sole.y - 11.0, 16.0, 11.0)
	draw_rect(boot.grow(OUTLINE), LINE)
	draw_rect(boot, boot_fill)


func _arm(angle_deg: float, fill: Color) -> void:
	var a := deg_to_rad(angle_deg)
	var dir := Vector2(sin(a), cos(a))
	var hand := SHOULDER + dir * 30.0
	_limb(SHOULDER, hand, 10.0, fill)
	_disc(hand + dir * 3.0, 5.0, SKIN)


func _robe() -> void:
	# Knee-length and flaring a little at the hem; the hood lies on his back.
	_shape(PackedVector2Array([
		Vector2(-15, -104), Vector2(15, -104), Vector2(18, -62),
		Vector2(24, -26), Vector2(-24, -26), Vector2(-18, -62),
	]), ROBE)
	draw_line(Vector2(13, -101), Vector2(20, -29), TRIM, 2.5) # the front opening's trim
	draw_line(Vector2(-23, -28), Vector2(23, -28), TRIM, 2.0) # the hem's trim
	draw_line(Vector2(-18, -62), Vector2(18, -62), LEATHER, 5.0) # the belt
	_ellipse(Vector2(-12, -101), Vector2(15, 11), SHADE)


func _head() -> void:
	_disc(Vector2(0, -129), 22.0, HAIR)
	_disc(Vector2(6, -123), 15.0, SKIN)
	draw_circle(Vector2(13, -126), 3.5, EYE)
	# One cowlick at the crown; its tip is the top of the 160 px.
	var curl := PackedVector2Array([Vector2(-3, -149), Vector2(-5, -155), Vector2(-1, -160), Vector2(4, -157)])
	draw_polyline(curl, LINE, 4.0 + OUTLINE * 2.0)
	draw_polyline(curl, HAIR, 4.0)


func _label() -> void:
	# Undo the facing flip, so the text always reads left to right.
	var font := ThemeDB.fallback_font
	var text := String(_pose)
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_set_transform(Vector2(0, -174), 0.0, Vector2(signf(scale.x), 1.0))
	draw_rect(Rect2(-width / 2.0 - 6.0, -20.0, width + 12.0, 26.0), Color(1, 1, 1, 0.75))
	draw_string(font, Vector2(-width / 2.0, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, LINE)
	draw_set_transform_matrix(Transform2D.IDENTITY)


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
	for i in 20:
		var a := TAU * i / 20.0
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	_shape(points, fill)
