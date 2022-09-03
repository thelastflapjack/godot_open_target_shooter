class_name Bullet
extends KinematicBody


### Signals ###
signal collided(bullet)

### Public variables ###
var velocity: Vector3
var damage: int
var spawn_vector: Vector3
var max_range: int
var source: Node
var distance_vector: Vector3


### Private variables ###
var _collider: Spatial

### Onready variables ###
onready var _max_range_squared: int = pow(max_range, 2)
onready var _mesh_inst: MeshInstance = $MeshInstance
onready var _collision_shape: CollisionShape = $CollisionShape
onready var _particles: Particles = $Particles

onready var _audio_impact_wood: AudioStreamPlayer3D = $AudioPlayerImpactWood
onready var _audio_impact_metal: AudioStreamPlayer3D = $AudioPlayerImpactMetal
onready var _audio_impact_concrete: AudioStreamPlayer3D = $AudioPlayerImpactConcrete


func _ready() -> void:
	global_transform.origin = spawn_vector


func _physics_process(delta: float) -> void:
	var move_vector: Vector3 = velocity * delta
	distance_vector += move_vector
	var collision: KinematicCollision = move_and_collide(move_vector)
	if collision:
		_collider = collision.collider
		emit_signal("collided", self, _collider)
	else:
		if (distance_vector + move_vector).length_squared() > _max_range_squared:
			queue_free()


func destroy() -> void:
	set_physics_process(false)
	_mesh_inst.visible = false
	_collision_shape.disabled = true
	
	if _collider:
		if _collider.is_in_group("IMPACT_SOUND_WOOD"):
			_audio_impact_wood.play()
		elif _collider.is_in_group("IMPACT_SOUND_METAL"):
			_audio_impact_metal.play()
		elif _collider.is_in_group("IMPACT_SOUND_CONCRETE"):
			_audio_impact_concrete.play()
	
	_particles.emitting = true
	# Sould be long enough for audio to finish
	yield(get_tree().create_timer(_particles.lifetime, false), "timeout")
	queue_free()
