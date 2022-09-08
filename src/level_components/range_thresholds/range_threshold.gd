extends Spatial
# Docstring

signal player_passed_through()

var _is_player_in_entry_area: bool
var _is_player_passing_through: bool

onready var _barrier: StaticBody = $Barrier


func _on_entry_detection_area_body_entered(body: PhysicsBody) -> void:
	assert(body is Player)
	_barrier.add_collision_exception_with(body)
	_is_player_in_entry_area = true


func _on_entry_detection_area_body_exited(body: PhysicsBody) -> void:
	assert(body is Player)
	_barrier.remove_collision_exception_with(body)
	_is_player_in_entry_area = false
	if _is_player_passing_through:
		_is_player_passing_through = false
		emit_signal("player_passed_through")


func _on_passed_through_detection_area_body_exited(body: PhysicsBody) -> void:
	assert(body is Player)
	_is_player_passing_through = true


func _on_passed_through_detection_area_body_entered(body: PhysicsBody) -> void:
	assert(body is Player)
	_is_player_passing_through = _is_player_in_entry_area
