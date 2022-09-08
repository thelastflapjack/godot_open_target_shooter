extends PlayerState
# State controlling the player while aiming

var _strafe_dir_target: Vector2
var _strafe_dir: Vector2
var _strafe_dir_accel: float = 3.0
var _neck_bone_number: int = 7
var _neck_bone_neutral_pose: Transform

############################
#      Public Methods      #
############################
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_shoot"):
		_player.fire_weapon()
	elif event.is_action_pressed("player_aim") or (not UserPreferences.toggle_aim and event.is_action_released("player_aim")):
		emit_signal("change_state_request", "Idle")
	elif event.is_action_pressed("player_run"):
		emit_signal("change_state_request", "Running")


func physics_update(delta: float) -> void:
	.physics_update(delta)
	
	var movement_direction_xz: Vector3 = _get_input_movement_direction_xz()
	_strafe_dir = _strafe_dir.move_toward(_strafe_dir_target, _strafe_dir_accel * delta)
	_player._anim_tree.set("parameters/aim/BlendSpace2D/blend_position", _strafe_dir)
	_apply_xz_movement(delta, movement_direction_xz)
	_rotate_body(delta, -_player.camera_system.get_forward_vector())
	
	_player.velocity = _player.move_and_slide_with_snap(
			_player.velocity, _player.snap_vector,  Vector3.UP, true,
			4, deg2rad(_player.floor_max_angle_deg)
	)
	
	var look_target: Vector3 = _player.camera_system.raycast_collision_point()
	_player.weapons_anchor.look_at(look_target, Vector3.UP)
	
	# Rotate neck bone to move with camera
	var neck_bone_custom_pose: Transform = _neck_bone_neutral_pose.rotated(
		Vector3(1,0,0), -_player.camera_system.get_anchor_y_rotation().x
	)
	_player.skeleton.set_bone_custom_pose(_neck_bone_number, neck_bone_custom_pose)
	
	_player.aim_block_area.global_rotation.y = (
			PI + _player.camera_system.get_anchor_y_rotation().y
	)


func enter(_data: Dictionary={}) -> void:
	_animate()
	_neck_bone_neutral_pose = _player.skeleton.get_bone_pose(_neck_bone_number)


func exit() -> void:
	_player.skeleton.set_bone_custom_pose(_neck_bone_number, _neck_bone_neutral_pose)


############################
#      Private Methods     #
############################

func _get_input_movement_direction_xz() -> Vector3:
	var input_vector: Vector3 = Vector3.ZERO
	input_vector.z = Input.get_action_strength("player_backward") - Input.get_action_strength("player_forward")
	input_vector.x = Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var input_vectorm_norm: Vector3 = input_vector.normalized()
	_strafe_dir_target = Vector2(
		-round(input_vectorm_norm.x),
		-round(input_vectorm_norm.z)
	)
	
	var direction: Vector3 = input_vector.normalized().rotated(
			Vector3.UP, 
			_player.camera_system.get_camera_global_transform().basis.get_euler().y
	)
	return direction


func _animate() -> void:
	_animation_state_machine.travel("aim")
	_player.raise_weapon()


func _update_state() -> void:
	var target_state_id: String = name
	if not _player.can_aim:
		if _get_input_movement_direction_xz() == Vector3.ZERO:
			target_state_id = "Idle"
		else:
			target_state_id = "Walking"

	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
