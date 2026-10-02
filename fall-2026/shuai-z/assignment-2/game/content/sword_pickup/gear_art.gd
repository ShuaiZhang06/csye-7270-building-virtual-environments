class_name GearArt
## Code-drawn sword and shield until the art swap (PROP-SWORDSHIELD), shared by
## the pickup, the gear Rudy holds, and the gear that flies off him after a hit:
## a short, straight steel sword and a small round wooden shield with a plain
## iron rim and no emblem (CHARACTER-SHEET.md). Call these from a _draw().

const WOOD := Color("#8B5A2B")
const IRON := Color("#6E737A")
const STEEL := Color("#D3D7DE")
const GRIP := Color("#754634")
const LINE := Color("#290F0D")


static func shield(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	canvas.draw_circle(center, radius + 3.0, LINE)
	canvas.draw_circle(center, radius, IRON)
	canvas.draw_circle(center, radius - 4.0, WOOD)
	canvas.draw_circle(center, 3.5, IRON)


## A sword from the end of its grip to its tip.
static func sword(canvas: CanvasItem, grip: Vector2, tip: Vector2) -> void:
	var along := (tip - grip).normalized()
	var guard := grip + along * 9.0
	var across := along.orthogonal() * 8.0
	canvas.draw_line(grip, tip, LINE, 8.0)
	canvas.draw_line(guard, tip, STEEL, 4.0)
	canvas.draw_line(grip, guard, GRIP, 4.0)
	canvas.draw_line(guard - across, guard + across, LINE, 7.0)
	canvas.draw_line(guard - across, guard + across, GRIP, 3.5)


## The pickup's picture: the sword crossed over the shield.
static func crossed(canvas: CanvasItem, center: Vector2, radius: float) -> void:
	shield(canvas, center, radius)
	sword(canvas, center + Vector2(-radius, radius) * 1.05, center + Vector2(radius, -radius) * 1.3)
