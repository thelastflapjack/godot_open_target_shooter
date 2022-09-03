class_name CameraTraumaCauser
extends Area
# Defines an area for a CameraTraumaDetector to detect and react to.


signal activated(causer)


export(float, 0.01, 1.0, 0.01) var _trauma_max: float = 0.5
export(float, 0.01, 1.0, 0.01) var _trauma_jump: float = 0.5
export(float, 0.01, 1.0, 0.01) var _trauma_reduction_rate: float = 0.5


var trauma: float = 0.0
var is_active: bool = false


func _process(delta: float) -> void:
	if trauma > 0:
		trauma = max(trauma - (delta * _trauma_reduction_rate), 0.0)
		if trauma == 0:
			is_active = false


func new_trauma() -> void:
	if trauma == 0:
		emit_signal("activated", self)
		is_active = true
	trauma = min(trauma + _trauma_jump, _trauma_max)
