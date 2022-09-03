class_name Weapon
extends Spatial
# Docstring


#######################
# When you need to change the transforms of GripLeftHand or GripRightHand in
# the editor, you must update the RESET animation in the AnimationPlayer too!
######################


### Signals ###
signal need_to_reload()
signal reload_unload_anim_done()
signal reload_load_anim_done()

### Enums ###
enum SLOT_TYPE{PRIMARY, SECONDARY}

### Exported variables ###
export(SLOT_TYPE) var slot_type: int

export(Texture) var icon: Texture
export(PackedScene) var bullet_packed_scene: PackedScene
export(float) var bullet_speed: float = 50
export(int) var bullet_damage: int = 10
export(int) var max_range: int = 60

export(int) var magazine_size: int = 15


### Public variables ###
var ammo_loaded: int = 0 setget set_ammo_loaded
var is_reloading: bool = false


### Onready variables ###
onready var grip_left_hand: Position3D = $Weapon/GripLeftHand
onready var grip_right_hand: Position3D = $Weapon/GripRightHand

onready var bullet_spawn_point: Spatial = $Weapon/BulletSpawn
onready var _audio_player_fire: AudioStreamPlayer3D = $Weapon/BulletSpawn/AudioStreamPlayer3D
onready var _particles: Particles = $Weapon/BulletSpawn/Particles
onready var _cam_trauma_causer: CameraTraumaCauser = $Weapon/BulletSpawn/CameraTraumaCauser
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _audio_player_empty_click: AudioStreamPlayer3D = $AudioStreamEmptyClick


func set_ammo_loaded(value: int) -> void:
	ammo_loaded = int(clamp(value, 0, magazine_size))
	if ammo_loaded == 0:
		emit_signal("need_to_reload")


func fire() -> bool:
	if ammo_loaded == 0:
		_audio_player_empty_click.play()
	elif not is_reloading:
		set_ammo_loaded(ammo_loaded - 1)
		_anim_player.stop()
		_anim_player.play("fire")
		_audio_player_fire.play()
		_cam_trauma_causer.new_trauma()
		_particles.restart()
		return true
	return false


func reload_unload() -> void:
	set_ammo_loaded(0)
	# TODO: Animate the magnet of the arm IK nodes
	_anim_player.play("reload_unload")
	yield(_anim_player, "animation_finished")
	emit_signal("reload_unload_anim_done")


func reload_load() -> void:
	_anim_player.play("reload_load")
	yield(_anim_player, "animation_finished")
	set_ammo_loaded(magazine_size)
	emit_signal("reload_load_anim_done")
