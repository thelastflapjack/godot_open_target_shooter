class_name LevelCameraSystem
extends Spatial
# Main script controlling the level camera system


### Onready variables ###
onready var anchor_y: Spatial = $AnchorY
onready var _anchor_x: Spatial = $AnchorY/AnchorX
onready var camera: ShakeableClippedCamera = $AnchorY/AnchorX/ShakeableClippedCamera
onready var cam_raycast: RayCast = $AnchorY/AnchorX/ShakeableClippedCamera/RayCast
onready var _state_machine: StateMachine = $StateMachine


### Public variables ###
var anchor_y_rotation_target: Vector3


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	if not Engine.editor_hint:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		anchor_y_rotation_target = anchor_y.rotation


func _unhandled_input(event: InputEvent) -> void:
	_state_machine.handle_input(event)


func _physics_process(delta: float) -> void:
	if not Engine.editor_hint:
		_state_machine.physics_update(delta)


############################
#      Public Methods      #
############################
func get_forward_vector() -> Vector3:
	return anchor_y.global_transform.basis.z


func get_camera_global_transform() -> Transform:
	return camera.global_transform


func get_anchor_y_rotation() -> Vector3:
	return anchor_y.rotation


func raycast_collision_point() -> Vector3:
	if cam_raycast.is_colliding():
		return cam_raycast.get_collision_point()
	return cam_raycast.to_global(cam_raycast.get_cast_to())


func update_camera_local_transform(anchor_offset: Vector3, camera_offset: Vector3) -> void:
	var tween: SceneTreeTween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween = tween.set_ease(Tween.EASE_IN)
	tween = tween.set_trans(Tween.TRANS_LINEAR)
	tween = tween.set_parallel(true)
	var duration: float = 0.15
	
	var _anchor_y_pos_tweener: PropertyTweener = tween.tween_property(
			anchor_y, "translation", 
			Vector3(0, anchor_offset.y, 0), duration
	)
	var _anchor_x_pos_tweener: PropertyTweener = tween.tween_property(
			_anchor_x, "translation", 
			Vector3(anchor_offset.x, 0, 0), duration
	)
	var _camera_pos_tweener: PropertyTweener = tween.tween_property(
			camera, "translation", 
			camera_offset, duration
	)
	var _cam_raycast_pos_tweener: PropertyTweener = tween.tween_property(
			cam_raycast, "translation", 
			Vector3(0, 0, -camera_offset.z), duration
	)
	tween.play()

