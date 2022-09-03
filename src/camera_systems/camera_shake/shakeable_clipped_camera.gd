class_name ShakeableClippedCamera
extends ClippedCamera
# Docstring


### Exported variables ###
export(OpenSimplexNoise) var _noise: OpenSimplexNoise
export(float) var _shake_speed: float = 7.5
export(Vector3) var _max_shake_rotation: Vector3 = Vector3(7, 7, 7)

### Private variables ###
var _active_trauma_causers: Array = []
var _trauma: float = 0.0

### Onready variables ###
onready var _initial_rotation_deg: Vector3 = rotation_degrees


############################
# Engine Callback Methods  #
############################
func _physics_process(_delta: float) -> void:
	_trauma = 0
	var i: int = 0
	while i < _active_trauma_causers.size():
		var causer: CameraTraumaCauser = _active_trauma_causers[i]
		if causer.trauma > 0:
			_trauma = clamp(_trauma + causer.trauma, 0.0, 1.0)
			i += 1
		else:
			_active_trauma_causers.remove(i)
	
	if _trauma > 0:
		var shake_intensity: float = pow(_trauma, 2)
		rotation_degrees.x = _initial_rotation_deg.x + (
				_max_shake_rotation.x * 
				_get_noise_val(1) * shake_intensity
		)
		rotation_degrees.y = _initial_rotation_deg.y + (
				_max_shake_rotation.y * 
				_get_noise_val(2) * shake_intensity
		)
		rotation_degrees.z = _initial_rotation_deg.z + (
				_max_shake_rotation.z * 
				_get_noise_val(3) * shake_intensity
		)


############################
#      Public Methods      #
############################
func add_trauma_causer(causer: CameraTraumaCauser) -> void:
	_active_trauma_causers.append(causer)


############################
#      Private Methods     #
############################
func _get_noise_val(rng_seed: int) -> float:
	_noise.seed = rng_seed
	return _noise.get_noise_1d(OS.get_ticks_msec() * 0.01 * _shake_speed)

