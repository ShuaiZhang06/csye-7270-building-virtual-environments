extends Node2D
## Runs Level 1: puts Rudy at the start and keeps the camera on him. The camera
## follows him sideways only, so the ground stays at the same height on screen
## and a fall drops him out of the frame (STORYBOARD.md, panels 2 and 5).

@onready var _level: Node2D = $Level1
@onready var _rudy: Rudy = $Rudy
@onready var _camera: Camera2D = $Camera
@onready var _hud: Hud = $Hud


func _ready() -> void:
	var start: Marker2D = _level.get_node("StartPoint")
	_rudy.global_position = start.global_position
	# The right-hand bound marks the end of the level.
	var right_bound: Node2D = _level.get_node("Bounds/Right")
	_camera.limit_right = roundi(right_bound.global_position.x)
	_camera.position.x = _rudy.global_position.x
	_camera.reset_smoothing()
	_hud.track(_rudy)


func _physics_process(_delta: float) -> void:
	_camera.position.x = _rudy.global_position.x
