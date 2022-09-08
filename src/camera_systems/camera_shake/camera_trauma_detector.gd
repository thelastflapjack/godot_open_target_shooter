class_name CameraTraumaDetector
extends Area
# Docstring


### Exported variables ###
export(NodePath) var _camera_node_path: NodePath


### Onready variables ###
onready var _camera: ShakeableClippedCamera = get_node(_camera_node_path)


############################
# Signal Connected Methods #
############################
func _on_area_entered(area: Area) -> void:
	assert(area is CameraTraumaCauser)
	var causer: CameraTraumaCauser = area
	if causer.is_active:
		_camera.add_trauma(causer.trauma)
	
	GenUtils.connect_signal_assert_ok(
		causer, "activated", self, 
		"_on_overlapping_causer_activated"
	)


func _on_area_exited(area: Area) -> void:
	assert(area is CameraTraumaCauser)
	var causer: CameraTraumaCauser = area
	causer.disconnect("activated", self, "_on_overlapping_causer_activated")


func _on_overlapping_causer_activated(causer: CameraTraumaCauser) -> void:
	_camera.add_trauma_causer(causer)

