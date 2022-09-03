class_name BadgeTracker
extends Node
# Docstring


### Signals ###
signal badge_earned(badge)

### Enums ###

### Constants ###

### Exported variables ###

### Public variables ###

### Private variables ###
var _multikill_window: int = 2
var _multikill_timer: Timer
var _multi_kill_count: int = 0

var _badges: Dictionary = {
		"double_kill": preload("res://src/badges/multi_kill/double.tres"),
		"triple_kill": preload("res://src/badges/multi_kill/triple.tres"),
		"quad_kill": preload("res://src/badges/multi_kill/quad.tres"),
		"over_kill": preload("res://src/badges/multi_kill/over.tres"),
		"longshot": preload("res://src/badges/longshot.tres"),
		"sharp_shooter": preload("res://src/badges/sharp_shooter.tres"),
		"clean_sweep": preload("res://src/badges/clean_sweep.tres"),
}

var _run_badges: Dictionary


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_setup_multikill_timer()


############################
#      Public Methods      #
############################
func reset_badges() -> void:
	_run_badges = {}


func get_run_badges() -> Dictionary:
	return _run_badges.duplicate()


func evaluate_end_of_run_stats(all_enemies_hit: bool, no_frendlies_hit, accuracy: float) -> void:
	if all_enemies_hit and no_frendlies_hit:
		_badge_earned(_badges["clean_sweep"])
	if accuracy == 1:
		_badge_earned(_badges["sharp_shooter"])


func get_run_badge_time() -> float:
	var run_badge_time: float = 0
	for badge in _run_badges:
		run_badge_time -= badge.time_value * _run_badges[badge]
	
	return run_badge_time


############################
# Signal Connected Methods #
############################
func _on_enemy_target_hit() -> void:
	if _multikill_timer.is_stopped():
		_start_new_multikill_window()
	_multi_kill_count += 1


func _on_friendly_target_hit() -> void:
	_multikill_timer.stop()


func _on_multikill_timer_timeout() -> void:
	if _multi_kill_count > 1:
		var multi_kill_badge: Badge
		match _multi_kill_count:
			2:
				multi_kill_badge = _badges["double_kill"]
			3:
				multi_kill_badge = _badges["triple_kill"]
			4:
				multi_kill_badge = _badges["quad_kill"]
			_:
				multi_kill_badge = _badges["over_kill"]
		
		_badge_earned(multi_kill_badge)


func _on_longshot_bullet() -> void:
	_badge_earned(_badges["longshot"])


############################
#      Private Methods     #
############################
func _badge_earned(badge: Badge) -> void:
	if _run_badges.has(badge):
		_run_badges[badge] += 1
	else:
		_run_badges[badge] = 1
	emit_signal("badge_earned", badge)


func _setup_multikill_timer() -> void:
	_multikill_timer = Timer.new()
	add_child(_multikill_timer)
	_multikill_timer.wait_time = _multikill_window
	_multikill_timer.one_shot = true
	
	GenUtils.connect_signal_assert_ok(
			_multikill_timer, "timeout",
			self, "_on_multikill_timer_timeout"
	)


func _start_new_multikill_window() -> void:
	_multi_kill_count = 0
	_multikill_timer.start()
