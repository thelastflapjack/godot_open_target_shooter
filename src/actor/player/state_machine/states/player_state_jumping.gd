#class_name PlayerStateJumping
extends PlayerState
# Docstring


### Exported variables ###
export(Animation) var _jump_animation: Animation

### Private variables ###
var _apply_jump_velocity := false
#var _can_double_jump := false


### Onready variables ###
onready var _audio_jump: AudioStreamPlayer = get_node("AudioStreamJump")

############################
#      Public Methods      #
############################
# Corresponds to the _physics_process() callback
func physics_update(delta: float) -> void:
	if _player.is_on_floor():
		_update_state()
	_update_snap_vector()
	
	var movement_direction_xz := _get_input_movement_direction_xz()
	_apply_xz_movement(delta, movement_direction_xz)

	if movement_direction_xz != Vector3.ZERO:
		_rotate_body(delta, movement_direction_xz)

	_apply_pushed_impulse_velocity()
	_apply_gravity(delta)
	
	if (not _apply_jump_velocity) && _player.can_double_jump && Input.is_action_just_pressed("player_jump"):
		_apply_jump_velocity = true
		_player.can_double_jump = false
	
	if _apply_jump_velocity:
		_player.snap_vector = Vector3.ZERO
		_player.velocity.y = _player.jump_impulse_speed
		_apply_jump_velocity = false

	_player.velocity = _player.move_and_slide_with_snap(
			_player.velocity, _player.snap_vector,  Vector3.UP, true,
			4, deg2rad(_player.floor_max_angle_deg)
	)


func enter(_data := {}) -> void:
	_player.set_collision_shape(_player.COLLISION_SHAPES.STANDING)
	_animate()
	_apply_jump_velocity = true
	_player.snap_vector = Vector3.ZERO
	_player.can_double_jump = true
	yield(get_tree().create_timer(_jump_animation.get_length(), false), "timeout")
	_update_state()


func exit() -> void:
	pass


############################
#      Private Methods     #
############################
func _animate() -> void:
	_animation_state_machine.travel("jump")
	_audio_jump.play()


func _update_state() -> void:
	var target_state_id := "InAir"
	if _player.is_on_floor():
		if _get_input_movement_direction_xz() != Vector3.ZERO:
			target_state_id = "Running"
		else:
			target_state_id = "Idle"
	
	emit_signal("change_state_request", target_state_id, {})


func _apply_gravity(delta: float) -> void:
	_player.velocity.y = max(
			_player.velocity.y + (_player.gravity_acceleration_jump * delta),
			_player.max_speed_fall
	)
