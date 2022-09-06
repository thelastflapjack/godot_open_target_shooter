class_name Player
extends KinematicBody
# Controller for the player


### Signals ###
signal aiming_started()
signal aiming_stopped()
signal shooting(spawn_point, bullet_speed, bullet_scene, bullet_damage)


### Public variables ###
var velocity := Vector3.ZERO
var snap_vector := Vector3.ZERO
var camera_system: LevelCameraSystem
var input_movement_direction_xz := Vector3.ZERO
var floor_max_angle_deg := 45.0

var current_weapon: Weapon
var can_aim: bool = true


### Private variables ###
var _animation_state_machine: AnimationNodeStateMachinePlayback setget ,get_animation_state_machine
var _is_weapon_lowered: bool = false
var _aim_blocking_bodies: Array


### Onready variables ###
onready var _hud: PlayerHUD = $HUD
onready var skeleton: Skeleton = $Body/dummy_rig/Skeleton
onready var _anim_tree: AnimationTree = get_node("AnimationTree")
onready var _state_machine: StateMachine = get_node("StateMachine")

onready var weapons_anchor: Position3D = $Body/dummy_rig/Skeleton/BoneAttachmentChest/WeaponsAnchor
onready var _weapon_slot_primary: Spatial = weapons_anchor.get_node("WeaponSlotPrimary")
onready var _weapon_slot_secondary: Spatial = weapons_anchor.get_node("WeaponSlotSecondary")
onready var _weapon_slots_anim_player: AnimationPlayer = weapons_anchor.get_node("AnimPlayerWeaponSlots")

onready var _ik_arm_left: SkeletonIK = $Body/dummy_rig/Skeleton/IKArmLeft
onready var _ik_arm_right: SkeletonIK = $Body/dummy_rig/Skeleton/IKArmRight

onready var aim_block_area: Area = $AimBlockArea


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_animation_state_machine = _anim_tree["parameters/playback"]
	
	current_weapon = _weapon_slot_primary.get_child(0)
	_ik_arm_left.set_target_node(current_weapon.grip_left_hand.get_path())
	_ik_arm_left.start()
	_ik_arm_right.set_target_node(current_weapon.grip_right_hand.get_path())
	_ik_arm_right.start()
	
	_weapon_slot_secondary.get_child(0).ammo_loaded = _weapon_slot_secondary.get_child(0).magazine_size
	
	_hud.update_weapon_ammo(current_weapon.ammo_loaded)
	_hud.update_weapon_icon(current_weapon.icon)
	_reload_current_weapon()


func _physics_process(delta: float) -> void:
	_state_machine.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_reload"):
		_reload_current_weapon()
	elif event.is_action_pressed("player_next_weapon") && not current_weapon.is_reloading:
		_switch_weapon()
	else:
		_state_machine.handle_input(event)


############################
#      Public Methods      #
############################
func lower_weapon() -> void:
	if not _is_weapon_lowered:
		_weapon_slots_anim_player.play("lower_weapons")
		emit_signal("aiming_stopped")
		_is_weapon_lowered = true


func raise_weapon() -> void:
	if _is_weapon_lowered:
		_weapon_slots_anim_player.play_backwards("lower_weapons")
		emit_signal("aiming_started")
		_is_weapon_lowered = false


func _switch_weapon() -> void:
	if current_weapon.slot_type == Weapon.SLOT_TYPE.PRIMARY:
		_weapon_slot_primary.visible = false
		_weapon_slot_secondary.visible = true
		current_weapon = _weapon_slot_secondary.get_child(0)
	else:
		_weapon_slot_secondary.visible = false
		_weapon_slot_primary.visible = true
		current_weapon = _weapon_slot_primary.get_child(0)
	
	_ik_arm_left.set_target_node(current_weapon.grip_left_hand.get_path())
	_ik_arm_right.set_target_node(current_weapon.grip_right_hand.get_path())
	_hud.update_weapon_ammo(current_weapon.ammo_loaded)
	_hud.update_weapon_icon(current_weapon.icon)


func fire_weapon() -> void:
	if current_weapon.fire():
		_hud.update_weapon_ammo(current_weapon.ammo_loaded)
		emit_signal("shooting", current_weapon)


func get_animation_state_machine() -> AnimationNodeStateMachinePlayback:
	return _animation_state_machine



############################
# Signal Connected Methods #
############################
func _on_aim_block_area_body_entered(body: Spatial) -> void:
	_aim_blocking_bodies.append(body)
	can_aim = false


func _on_aim_block_area_body_exited(body: Spatial) -> void:
	_aim_blocking_bodies.erase(body)
	can_aim = (_aim_blocking_bodies.size() == 0)


############################
#      Private Methods     #
############################

func _reload_current_weapon() -> void:
	if not current_weapon.is_reloading:
		# Unload mag
		current_weapon.is_reloading = true
		current_weapon.reload_unload()
		_hud.update_weapon_ammo(current_weapon.ammo_loaded)
		yield(current_weapon, "reload_unload_anim_done")
		
		# Get new magazine
		var time_hand_to_ammo_bag: float = 0.25
		var time_hand_in_ammo_bag: float = 0.5
		var get_mag_tween: SceneTreeTween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		# Reach for new mag
		var tweener_reach: PropertyTweener = get_mag_tween.tween_property(
				_ik_arm_left, "interpolation", 0.0, time_hand_to_ammo_bag
		)
		tweener_reach = tweener_reach.from(1.0)
		
		# Pause with hand in ammo bag
		# warning-ignore:return_value_discarded
		get_mag_tween.tween_interval(time_hand_in_ammo_bag)
		
		# Bring new mag under gun
		var tweener_return: PropertyTweener = get_mag_tween.tween_property(
				_ik_arm_left, "interpolation", 1.0, time_hand_to_ammo_bag
		)
		tweener_return = tweener_return.from(0.0)
		get_mag_tween.play()
		yield(get_mag_tween, "finished")
		
		# Load new mag
		current_weapon.reload_load()
		yield(current_weapon, "reload_load_anim_done")
		current_weapon.is_reloading = false
		_hud.update_weapon_ammo(current_weapon.ammo_loaded)
