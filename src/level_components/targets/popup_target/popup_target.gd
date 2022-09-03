tool
class_name PopupTarget
extends Spatial
# Docstring


### Signals ###
signal hit(target)

### Exported variables ###
export(float) var _move_distance: float = 0 setget _set_move_distance
export(float, 0.1, 5) var _move_speed: float = 1
export(float) var _end_wait: float = 1
export(bool) var is_enemy: bool = true setget _set_is_enemy

### Private variables ###
var _tween: SceneTreeTween
var _is_down: bool
var _enemy_mat: SpatialMaterial = preload("res://src/level_components/targets/popup_target/popup_target_enemy.material")
var _friendly_mat: SpatialMaterial = preload("res://src/level_components/targets/popup_target/popup_target_friendly.material")
var _audio_player_pop_down: AudioStreamPlayer3D

### Onready variables ###
onready var _anim_player: AnimationPlayer = $popup_target/AnimationPlayer
onready var _popup_target: Spatial = $popup_target 
onready var _target: Target = $popup_target/popup_target_rig/Skeleton/BoneAttachment/Target
onready var _path_line_tool: ImmediateGeometry = $ImmediateGeometry
onready var _move_target: MeshInstance = $MoveTarget
onready var _mesh_inst: MeshInstance = $popup_target/popup_target_rig/Skeleton/popup_target
onready var _audio_pop_down_enemy: AudioStreamPlayer3D = $popup_target/popup_target_rig/Skeleton/BoneAttachment/Target/AudioPopDownEnemy
onready var _audio_pop_down_friendly: AudioStreamPlayer3D = $popup_target/popup_target_rig/Skeleton/BoneAttachment/Target/AudioPopDownFriendly


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	if is_enemy:
		_mesh_inst.set_surface_material(0, _enemy_mat)
		_audio_player_pop_down = _audio_pop_down_enemy
	else:
		_mesh_inst.set_surface_material(0, _friendly_mat)
		_audio_player_pop_down = _audio_pop_down_friendly
	
	if not Engine.editor_hint:
		_target.is_enemy = is_enemy
		GenUtils.connect_signal_assert_ok(_target, "hit", self, "_on_target_hit")
		_move_target.queue_free()
		_path_line_tool.queue_free()
		if _move_distance != 0:
			_tween_popup_target_setup()
	else:
		_set_move_distance(_move_distance)
		_set_is_enemy(is_enemy)


############################
#      Public Methods      #
############################
func down() -> void:
	_anim_player.play("popdown")
	_is_down = true
	_target.inactive()
	if _tween:
		_tween.pause()


func popup() -> void:
	_anim_player.play("popup")
	_is_down = false
	_target.reset()
	if _tween:
		_tween.play()


############################
# Signal Connected Methods #
############################
func _on_target_hit() -> void:
	emit_signal("hit", self)
	_audio_player_pop_down.play()
	down()


############################
#      Private Methods     #
############################
func _set_move_distance(val: float) -> void:
	_move_distance = val
	if Engine.editor_hint:
		_path_line_tool = $ImmediateGeometry
		_move_target = $MoveTarget
		_move_target.transform.origin = Vector3(_move_distance, 0, 0)
		if _move_distance == 0:
			_move_target.set_visible(false)
			_path_line_tool.set_visible(false)
		else:
			_move_target.set_visible(true)
			_path_line_tool.set_visible(true)
			_path_line_tool.clear()
			_path_line_tool.begin(Mesh.PRIMITIVE_LINES)
			_path_line_tool.set_color(Color(1,0,1,1))
			_path_line_tool.add_vertex(Vector3.ZERO)
			_path_line_tool.add_vertex(Vector3(_move_distance, 0, 0))
			_path_line_tool.end()


func _set_is_enemy(val: bool) -> void:
	is_enemy = val
	if Engine.editor_hint:
		_mesh_inst = $popup_target/popup_target_rig/Skeleton/popup_target
		if is_enemy:
			_mesh_inst.set_surface_material(0, _enemy_mat)
		else:
			_mesh_inst.set_surface_material(0, _friendly_mat)


func _tween_popup_target_setup() -> void:
	var step_duration: float = abs(_move_distance) / _move_speed
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var tweener_step_1: PropertyTweener = _tween.tween_property(
			_popup_target, "translation", 
			Vector3(_move_distance, 0, 0), step_duration
	)
	tweener_step_1 = tweener_step_1.set_ease(Tween.EASE_OUT_IN)
	tweener_step_1 = tweener_step_1.set_trans(Tween.TRANS_LINEAR)
	tweener_step_1 = tweener_step_1.set_delay(_end_wait)
	
	var tweener_step_2: PropertyTweener = _tween.tween_property(
			_popup_target, "translation", 
			Vector3(0, 0, 0), step_duration
	)
	tweener_step_2 = tweener_step_2.set_ease(Tween.EASE_OUT_IN)
	tweener_step_2 = tweener_step_2.set_trans(Tween.TRANS_LINEAR)
	tweener_step_2 = tweener_step_2.set_delay(_end_wait)
	
	_tween = _tween.set_loops()


