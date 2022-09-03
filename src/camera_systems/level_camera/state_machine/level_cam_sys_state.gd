class_name LevelCameraSystemState
extends State
# Docstring


### Exported variables ###
# Position relative to the target origin which the camera system will use as its origin
export(Vector3) var _anchor_offset: Vector3
# Position relative to anchor_offset where the camera will be..
export(Vector3) var _camera_offset: Vector3
export(Vector2) var _pitch_limits: Vector2
export(float, 0, 1) var _follow_smoothing: float


### Private variables ###
var _camera_sys: LevelCameraSystem


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	yield(owner, "ready")
	_camera_sys = owner

