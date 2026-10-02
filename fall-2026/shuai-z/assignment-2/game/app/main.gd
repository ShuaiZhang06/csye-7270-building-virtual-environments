class_name Main
extends Node2D
## Runs Level 1. It places Rudy, keeps the camera on him, and runs the level's
## states (CHANGE-BRIEF.md, STORYBOARD.md panels 5–7):
## - PLAYING;
## - DYING: a fall below a cliff is instant death; after a fade Rudy gets back
##   up at the last checkpoint, the lit waystone or else the start;
## - COMPLETE: entered once, on the teleport circle. Input stops, Rudy
##   celebrates, the light rises, the camera pulls back, and the screen fades to
##   the end card, where Enter plays the level again from the opening.
## The camera follows Rudy sideways only, so the ground stays at the same height
## on screen and a fall drops him out of the frame.

signal restart_requested ## only when Main is not the current scene, as in the checks

enum State { PLAYING, DYING, COMPLETE }

const KILL_Y := 1300.0 ## below this line he has fallen out of the level
const FALL_HOLD := 0.25 ## s after he crosses the kill line, before the fade
const FADE_TIME := 0.35 ## s each way
const CELEBRATE_TIME := 2.0 ## s on the circle before the fade to the end card
const END_ZOOM := Vector2(0.8, 0.8)
const ZOOM_TIME := 1.5

var state := State.PLAYING
var checkpoint_name := "start"

var _checkpoint: Vector2
var _end_card_shown := false

@onready var _level: Node2D = $Level1
@onready var _rudy: Rudy = $Rudy
@onready var _camera: Camera2D = $Camera
@onready var _hud: Hud = $Hud
@onready var _waystone: Waystone = $Level1/Waystone
@onready var _portal: Portal = $Level1/Portal


func _ready() -> void:
	_checkpoint = (_level.get_node("StartPoint") as Marker2D).global_position
	_rudy.global_position = _checkpoint
	# The right-hand bound marks the end of the level.
	var right_bound: Node2D = _level.get_node("Bounds/Right")
	_camera.limit_right = roundi(right_bound.global_position.x)
	_snap_camera()
	_waystone.activated.connect(_on_waystone_activated)
	_portal.reached.connect(_on_portal_reached)
	_hud.track(_rudy)
	_show_status()


func _physics_process(_delta: float) -> void:
	_camera.position.x = _rudy.global_position.x
	if state == State.PLAYING and _rudy.global_position.y > KILL_Y:
		_die_by_fall()


func _process(_delta: float) -> void:
	if _end_card_shown and Input.is_action_just_pressed(&"restart"):
		_end_card_shown = false
		_restart()


func _die_by_fall() -> void:
	state = State.DYING # set first, so the kill line ignores him from now on
	_rudy.fall_out()
	Sfx.play(&"fall")
	_show_status()
	await get_tree().create_timer(FALL_HOLD).timeout
	await _hud.fade_to(1.0, FADE_TIME)
	_rudy.respawn_at(_checkpoint)
	_snap_camera()
	await _hud.fade_to(0.0, FADE_TIME)
	if _rudy.mode == Rudy.Mode.RESPAWNING:
		await _rudy.respawned
	state = State.PLAYING
	_show_status()


func _on_waystone_activated(waystone: Waystone) -> void:
	_checkpoint = waystone.spawn_point.global_position
	checkpoint_name = "waystone"
	_show_status()


func _on_portal_reached() -> void:
	if state != State.PLAYING:
		return
	state = State.COMPLETE # entered once; input stops
	_rudy.celebrate()
	Sfx.play(&"portal")
	_show_status()
	_portal.light_up(CELEBRATE_TIME)
	create_tween().tween_property(_camera, "zoom", END_ZOOM, ZOOM_TIME).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(CELEBRATE_TIME).timeout
	await _hud.fade_to(1.0, FADE_TIME)
	_hud.show_end_card()
	_end_card_shown = true


func _restart() -> void:
	if get_tree().current_scene == self:
		get_tree().reload_current_scene()
	else:
		restart_requested.emit()


func _snap_camera() -> void:
	_camera.position.x = _rudy.global_position.x
	_camera.reset_smoothing()


func _show_status() -> void:
	_hud.set_status("%s, checkpoint: %s" % [State.keys()[state], checkpoint_name])
