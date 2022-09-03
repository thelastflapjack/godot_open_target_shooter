class_name TargetManager
extends Node
# Docstring


### Signals ###
signal enemy_target_hit()
signal friendly_target_hit()


### Private variables ###
var _all_targets_enemy: Array
var _down_targets_enemy: Array
var _all_targets_friendly: Array
var _down_targets_friendly: Array


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	var i := 0
	var target: PopupTarget
	while i < get_child_count():
		target = get_child(i)
		if target.is_enemy:
			_all_targets_enemy.append(target)
		else:
			_all_targets_friendly.append(target)
		target.down()
		GenUtils.connect_signal_assert_ok(target, "hit", self, "_on_target_hit")
		i += 1
	
	_down_targets_enemy = _all_targets_enemy.duplicate()
	_down_targets_friendly = _all_targets_friendly.duplicate()


############################
#      Public Methods      #
############################
func reset_targets() -> void:
	for target in _down_targets_enemy:
		(target as PopupTarget).popup()
	_down_targets_enemy.clear()
	
	for target in _down_targets_friendly:
		(target as PopupTarget).popup()
	_down_targets_friendly.clear()


func target_count_enemy() -> int:
	return _all_targets_enemy.size()


func target_count_enemy_down() -> int:
	return _down_targets_enemy.size()


func target_count_enemy_up() -> int:
	return _all_targets_enemy.size() - _down_targets_enemy.size()


func target_count_friendly() -> int:
	return _all_targets_friendly.size()


func target_count_friendly_down() -> int:
	return _down_targets_friendly.size()


func are_all_enemy_targets_down() -> bool:
	return _all_targets_enemy.size() == _down_targets_enemy.size()


func are_all_friendly_targets_up() -> bool:
	return _down_targets_friendly.size() == 0


############################
# Signal Connected Methods #
############################
func _on_target_hit(target: PopupTarget) -> void:
	if target.is_enemy:
		_down_targets_enemy.append(target)
		emit_signal("enemy_target_hit")
	else:
		_down_targets_friendly.append(target)
		emit_signal("friendly_target_hit")


############################
#      Private Methods     #
############################
