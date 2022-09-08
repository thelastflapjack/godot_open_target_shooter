extends LevelCameraSystemState
# State of LevelCameraSystem which makes the camera system follow the player


### Onready variables ###
onready var _player: Player = get_owner().get_node("../Player") # Bad, but works. Consider alternative.


############################
#      Public Methods      #
############################

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_handle_input_mouse_motion(event)


func physics_update(_delta: float) -> void:
	_camera_sys.anchor_y.rotation = lerp(
			_camera_sys.anchor_y.rotation, _camera_sys.anchor_y_rotation_target,
			0.95
	)
	_follow_follow_target()


func enter(_data: Dictionary={}) -> void:
	_camera_sys.update_camera_local_transform(
			_anchor_offset, _camera_offset
	)
	_camera_sys.cam_raycast.enabled = true
	_camera_sys.camera.add_exception(_player)
	
	GenUtils.connect_signal_assert_ok(_player, "aiming_started", self, "_on_player_aiming_started")


func exit() -> void:
	_camera_sys.camera.clear_exceptions()
	_player.disconnect("aiming_started", self, "_on_player_aiming_started")


############################
# Signal Connected Methods #
############################
func _on_player_aiming_started() -> void:
	emit_signal("change_state_request", "FollowPlayerAiming")


############################
#      Private Methods     #
############################
func _follow_follow_target() -> void:
	_camera_sys.global_translation = lerp(
			_camera_sys.global_translation,
			_player.global_translation, 
			_follow_smoothing
	)


func _handle_input_mouse_motion(event: InputEventMouseMotion) -> void:
	var last_mouse_motion := event.relative * 0.004 * UserPreferences.mouse_sensitivity
	_camera_sys.anchor_y_rotation_target.y -= last_mouse_motion.x
	
	_camera_sys.anchor_y_rotation_target.x -= last_mouse_motion.y
	_camera_sys.anchor_y_rotation_target.x = clamp(
			_camera_sys.anchor_y_rotation_target.x, _pitch_limits.x, _pitch_limits.y
	)
