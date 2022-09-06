extends PlayerState
# State controlling the player while idle


############################
#      Public Methods      #
############################
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_aim") and _player.can_aim:
		emit_signal("change_state_request", "Aiming")
	elif event.is_action_pressed("player_run") && _get_input_movement_direction_xz() != Vector3.ZERO:
		emit_signal("change_state_request", "Running")


func physics_update(delta: float) -> void:
	.physics_update(delta)
	
	_apply_xz_movement(delta, Vector3.ZERO)
	
	_player.velocity = _player.move_and_slide_with_snap(
			_player.velocity, _player.snap_vector,  Vector3.UP, true,
			4, deg2rad(_player.floor_max_angle_deg)
	)
	
	_player.aim_block_area.global_rotation.y = (
			PI + _player.camera_system.get_anchor_y_rotation().y
	)


func enter(_data := {}) -> void:
	_animate()
	_player.weapons_anchor.rotation_degrees = Vector3(0, -180, 0)


############################
#      Private Methods     #
############################
func _animate() -> void:
	_player.lower_weapon()
	_animation_state_machine.travel("idle")


func _update_state() -> void:
	var target_state_id := name
	if _get_input_movement_direction_xz() != Vector3.ZERO:
		target_state_id = "Walking"
	
	if target_state_id != name:
		emit_signal("change_state_request", target_state_id, {})

