tool
class_name LevelCamSysStatePosiionData
extends Resource
# Docstring

signal transform_value_changed()

# Position relative to the target origin which the camera system will use as its origin
export(Vector3) var anchor_offset: Vector3 setget set_anchor_offset
export(Vector3) var anchor_rotation: Vector3 setget set_anchor_rotation
# Position relative to anchor_offset where the camera will be..
export(Vector3) var camera_offset: Vector3 setget set_camera_offset
export(Vector2) var pitch_limits: Vector2
# Relative to target + anchor_offset
export(Vector3) var look_target_initial: Vector3 setget set_look_target_initial
export(float, 0, 1) var follow_smoothing: float


func set_anchor_offset(val: Vector3) -> void:
	anchor_offset = val
	emit_signal("transform_value_changed")


func set_anchor_rotation(val: Vector3) -> void:
	anchor_rotation = val
	emit_signal("transform_value_changed")


func set_camera_offset(val: Vector3) -> void:
	camera_offset = val
	emit_signal("transform_value_changed")


func set_look_target_initial(val: Vector3) -> void:
	look_target_initial = val
	emit_signal("transform_value_changed")
