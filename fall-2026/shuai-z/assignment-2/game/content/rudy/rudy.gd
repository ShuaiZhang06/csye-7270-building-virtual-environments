class_name Rudy
extends CharacterBody2D
## Rudy's controller. It moves him and picks the pose that shows his state,
## named by the pose's asset ID in CHARACTER-SHEET.md, so the art swap only has
## to map each ID to a frame. The origin is at his soles.
##
## On the ground, pressing the other direction turns him in place at once, with
## no slide; he moves that way only if the key is still held after
## turn_hold_time, so a tap turns him without moving him or the camera.
##
## The level takes control away when he falls out of the level, while he gets
## back up after a respawn, and while he celebrates on the teleport circle.
##
## The feel numbers are tuned by playtesting.

signal respawned ## he has got back up after a respawn, and control returns

enum Mode {
	PLAY, ## under the player's control
	FALLEN, ## fell below a cliff; no control
	RESPAWNING, ## getting back up at a checkpoint (CHAR-RESPAWN); no control
	CELEBRATING, ## on the teleport circle (CHAR-CELEBRATE); no control
}

@export_group("Feel")
@export var run_speed := 560.0 ## px/s
@export var run_accel := 5600.0 ## px/s²: full speed, or a stop, in 0.1 s
@export var turn_hold_time := 0.12 ## s the key is held after a turn on the ground before he moves
@export var gravity := 4000.0 ## px/s² on the way up
@export var fall_gravity := 6400.0 ## px/s² on the way down, so the fall is quicker than the rise
@export var jump_velocity := 1300.0 ## px/s; at 60 physics ticks/s the apex is 222 px, the rise takes 0.33 s and the fall 0.27 s
@export var run_frame_time := 0.125 ## seconds per run frame (RUN-A, then RUN-B)
@export var respawn_time := 0.7 ## s in CHAR-RESPAWN before control returns

var facing := 1 ## 1 faces right, -1 faces left
var pose: StringName = &"CHAR-IDLE"
var mode := Mode.PLAY

var _run_clock := 0.0
var _turn_time_left := 0.0
var _respawn_time_left := 0.0

@onready var _look: RudyPlaceholder = $Look


## He fell below a cliff: he keeps falling, out of the player's control.
func fall_out() -> void:
	mode = Mode.FALLEN


## Puts him back on his feet at a checkpoint, facing right, getting back up.
func respawn_at(spot: Vector2) -> void:
	global_position = spot
	velocity = Vector2.ZERO
	facing = 1
	_turn_time_left = 0.0
	mode = Mode.RESPAWNING
	_respawn_time_left = respawn_time


func celebrate() -> void:
	mode = Mode.CELEBRATING


func _physics_process(delta: float) -> void:
	var in_control := mode == Mode.PLAY
	var dir := _input_direction() if in_control else 0
	if dir != 0 and dir != facing:
		facing = dir
		if is_on_floor():
			velocity.x = 0.0
			_turn_time_left = turn_hold_time
	if dir == 0 or not is_on_floor():
		_turn_time_left = 0.0
	_turn_time_left = maxf(_turn_time_left - delta, 0.0)
	var target_speed := 0.0 if _turn_time_left > 0.0 else dir * run_speed
	velocity.x = move_toward(velocity.x, target_speed, run_accel * delta)

	if not is_on_floor():
		velocity.y += (fall_gravity if velocity.y >= 0.0 else gravity) * delta
	elif in_control and Input.is_action_just_pressed(&"jump"):
		# A fresh press with ground underfoot: holding the key cannot jump again.
		velocity.y = -jump_velocity
		Sfx.play(&"jump")
	move_and_slide()

	if mode == Mode.RESPAWNING:
		_respawn_time_left -= delta
		if _respawn_time_left <= 0.0:
			mode = Mode.PLAY
			respawned.emit()

	_look.scale.x = facing
	pose = _pick_pose(delta)
	_look.show_pose(pose)


func _input_direction() -> int:
	var axis := Input.get_axis(&"move_left", &"move_right")
	if axis > 0.0:
		return 1
	if axis < 0.0:
		return -1
	return 0


func _pick_pose(delta: float) -> StringName:
	if mode == Mode.CELEBRATING:
		return &"CHAR-CELEBRATE"
	if mode == Mode.RESPAWNING:
		return &"CHAR-RESPAWN"
	if not is_on_floor():
		_run_clock = 0.0
		return &"CHAR-RISE" if velocity.y < 0.0 else &"CHAR-FALL"
	if absf(velocity.x) > 1.0:
		_run_clock += delta
		var second_frame := fmod(_run_clock, run_frame_time * 2.0) >= run_frame_time
		return &"CHAR-RUN-B" if second_frame else &"CHAR-RUN-A"
	_run_clock = 0.0
	return &"CHAR-IDLE"
