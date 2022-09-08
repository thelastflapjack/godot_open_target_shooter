extends PlayerState
# State controlling the player while running


############################
#      Public Methods      #
############################
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_aim") and _player.can_aim:
		emit_signal("change_state_request", "Aiming")
	elif event.is_action_pressed("player_run") or (not UserPreferences.toggle_sprint and event.is_action_released("player_run")):
		if _get_input_movement_direction_xz() == Vector3.ZERO:
			emit_signal("change_state_request", "Idle")
		else:
			emit_signal("change_state_request", "Walking")


func physics_update(delta: float) -> void:
	.physics_update(delta)
	
	var movement_direction_xz: Vector3 = _get_input_movement_direction_xz()
	_apply_xz_movement(delta, movement_direction_xz)
	if movement_direction_xz != Vector3.ZERO:
		_rotate_body(delta, movement_direction_xz)
	
	_player.velocity = _player.move_and_slide_with_snap(
			_player.velocity, _player.snap_vector,  Vector3.UP, true,
			4, deg2rad(_player.floor_max_angle_deg)
	)
	
	_player.aim_block_area.global_rotation.y = (
			PI + _player.camera_system.get_anchor_y_rotation().y
	)


func enter(_data: Dictionary={}) -> void:
	_animate()
	_player.weapons_anchor.rotation_degrees = Vector3(0, -180, 0)


############################
#      Private Methods     #
############################
func _animate() -> void:
	_player.lower_weapon()
	_animation_state_machine.travel("run")


func _update_state() -> void:
	var target_state_id: String = name
	if _get_input_movement_direction_xz() == Vector3.ZERO:
		target_state_id = "Idle"
	
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})
