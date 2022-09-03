extends Spatial
# Docstring

export(OpenSimplexNoise) var _noise: OpenSimplexNoise

var _camera_max_rotation: Vector3 = Vector3(10,10,2)
var _camera_shake_speed: float = 1.5

onready var _camera: Camera = $Camera
onready var _camera_rotation_initial_deg: Vector3 = _camera.rotation_degrees


func _physics_process(_delta: float) -> void:
	_camera.rotation_degrees.x = (
				_camera_rotation_initial_deg.x + 
				(_camera_max_rotation.x * _get_noise_val(1))
	)
	_camera.rotation_degrees.y = (
				_camera_rotation_initial_deg.y + 
				(_camera_max_rotation.y * _get_noise_val(2))
	)
	_camera.rotation_degrees.z = (
				_camera_rotation_initial_deg.z + 
				(_camera_max_rotation.z * _get_noise_val(3))
	)


func _get_noise_val(rng_seed: int) -> float:
	_noise.seed = rng_seed
	return _noise.get_noise_1d(OS.get_ticks_msec() * 0.001 *_camera_shake_speed)
