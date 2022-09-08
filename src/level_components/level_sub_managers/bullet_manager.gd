class_name BulletManager
extends Node
# Spawns bullets and keeps track of bullet related stats


### Signals ###
signal longshot_bullet()

### Private variables ###
var _longshot_distance: int = 30

### Public variables ###
var run_bullet_count: int
var run_acc: float
var run_longest_shot: float


############################
#      Public Methods      #
############################
func reset_run_stats() -> void:
	run_acc = 0
	run_bullet_count = 0
	run_longest_shot = 0


func spawn_bullet(weapon: Weapon, source: Node) -> void:
	var spawn_vector: Vector3 = weapon.bullet_spawn_point.global_transform.origin
	var bullet_direction: Vector3 = weapon.bullet_spawn_point.global_transform.basis.z
	
	var new_bullet: Bullet = weapon.bullet_packed_scene.instance()
	new_bullet.velocity = bullet_direction * weapon.bullet_speed
	new_bullet.damage = weapon.bullet_damage
	new_bullet.spawn_vector = spawn_vector
	new_bullet.max_range = weapon.max_range
	new_bullet.source = source
	
	add_child(new_bullet)
	
	GenUtils.connect_signal_assert_ok(new_bullet, "collided", self, "_on_bullet_collided")
	
	if (source is Player):
		run_bullet_count += 1


func update_run_accuracy(enemy_targets_down: int) -> void:
	run_acc = float(enemy_targets_down) / float(run_bullet_count)


############################
# Signal Connected Methods #
############################
func _on_bullet_collided(bullet: Bullet, collider: Spatial) -> void:
	if (bullet.source is Player) and (collider is Target):
		var target: Target = collider as Target
		if target.is_enemy and not target.is_hit:
			var bullet_distance: float = bullet.distance_vector.length()
			if bullet_distance > run_longest_shot:
				run_longest_shot = bullet_distance
			if bullet_distance >= _longshot_distance:
				emit_signal("longshot_bullet")
	
	if collider.is_in_group(Groups.HURTABLE):
		collider.hurt(bullet.damage)
	bullet.destroy()

