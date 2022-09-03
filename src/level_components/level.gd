class_name LevelManager
extends Spatial
# Script to keep track of and manage level properties


### Signals ###
signal change_scene_request(target_scene_res_path)


### Private variables ###
var _par_time: float
var _best_time: float = -1.0

var _is_player_on_range: bool = false
var _run_time_raw: float setget _set_run_time_raw
var _run_time: float
var _bonus_value: int = 1000

var _missed_enemy_penalty: float = 1.2
var _hit_friendly_penalty: float = 0.6


### Onready variables ###
onready var _primary_light: DirectionalLight = $WorldEnvironment/DirectionalLight
onready var _player: Player = $Player
onready var _camera_system: LevelCameraSystem = $LevelCameraSystem
onready var _level_name := filename.get_file().get_basename()
onready var _level_ui: LevelUI = get_node("LevelUI")
onready var _pause_menu: MultiPageUIMagager = $PauseMenu/PauseMenu
onready var _run_summary_page: Control = $RunSummaryPage/RunSummaryPage

onready var _target_manager: TargetManager = $TargetManager
onready var _bullet_manager: BulletManager = $BulletManager
onready var _badge_tracker: BadgeTracker = $BadgeTracker

onready var _audio_player_run_start: AudioStreamPlayer = $AudioStreamRunStart
onready var _audio_player_run_end: AudioStreamPlayer = $AudioStreamRunEnd


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_player.camera_system = _camera_system
	
	_par_time = SaveLoad.load_level_par_time(_level_name)
	_level_ui.set_label_time_par(_par_time)
	_best_time = SaveLoad.load_level_best_time(_level_name)
	if _best_time != -1.0:
		_level_ui.set_label_time_best(_best_time)
	_run_summary_page.set_level_par_time(_par_time)
	
	_connect_signals()
	_init_level_ui()


func _process(delta: float) -> void:
	if _is_player_on_range:
		_set_run_time_raw(_run_time_raw + delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_pause_menu.popup()


############################
# Signal Connected Methods #
############################
func _on_player_passed_through_range_entrance() -> void:
	_start_run()


func _on_player_passed_through_range_exit() -> void:
	_finish_run()


func _on_player_shooting(player_weapon: Weapon) -> void:
	_bullet_manager.spawn_bullet(player_weapon, _player)
	if _is_player_on_range:
		_bullet_manager.update_run_accuracy(_target_manager.target_count_enemy_down())


func _on_enemy_target_hit() -> void:
	if _is_player_on_range:
		_level_ui.set_label_enemy_hits(
				_target_manager.target_count_enemy_down(), _target_manager.target_count_enemy()
		)
		_bullet_manager.update_run_accuracy(_target_manager.target_count_enemy_down())


func _on_friendly_target_hit() -> void:
	if _is_player_on_range:
		_level_ui.set_label_friendly_hits(
				_target_manager.target_count_friendly_down()
		)


func _on_quit_level() -> void:
	emit_signal("change_scene_request", "res://src/ui/main_menu/main_menu.tscn")


############################
#      Private Methods     #
############################
func _set_run_time_raw(seconds: float) -> void:
	_run_time_raw = seconds
	_level_ui.set_label_time(_run_time_raw)


func _init_level_ui() -> void:
	_level_ui.set_label_enemy_hits(
			0, _target_manager.target_count_enemy()
	)
	_level_ui.set_label_friendly_hits(0)


func _connect_signals() -> void:
	# Player
	GenUtils.connect_signal_assert_ok(
			_player, "shooting", 
			self, "_on_player_shooting"
	)
	
	# Target Manager
	GenUtils.connect_signal_assert_ok(
			_target_manager, "enemy_target_hit",
			self, "_on_enemy_target_hit"
	)
	GenUtils.connect_signal_assert_ok(
			_target_manager, "friendly_target_hit",
			self, "_on_friendly_target_hit"
	)
	GenUtils.connect_signal_assert_ok(
			_target_manager, "enemy_target_hit",
			_badge_tracker, "_on_enemy_target_hit"
	)
	GenUtils.connect_signal_assert_ok(
			_target_manager, "friendly_target_hit",
			_badge_tracker, "_on_friendly_target_hit"
	)
	
	# Pause menu
	GenUtils.connect_signal_assert_ok(
			_pause_menu, "quit_level", 
			self, "_on_quit_level"
	)
	
	# Bullet Manager
	GenUtils.connect_signal_assert_ok(
			_bullet_manager, "longshot_bullet",
			_badge_tracker, "_on_longshot_bullet"
	)
	
	# Badge Tracker
	GenUtils.connect_signal_assert_ok(
			_badge_tracker, "badge_earned",
			_level_ui, "_on_badge_earned"
	)


func _start_run() -> void:
	_audio_player_run_start.play()
	_is_player_on_range = true
	_run_time_raw = 0
	_run_time = 0
	
	_target_manager.reset_targets()
	_bullet_manager.reset_run_stats()
	_badge_tracker.reset_badges()
	
	_level_ui.set_label_enemy_hits(0, _target_manager.target_count_enemy())
	_level_ui.set_label_friendly_hits(0)


func _update_and_show_run_summary(missed_enemy_penalty_time_total: float, hit_friendly_penalty_time_total: float) -> void:
	_run_summary_page.update_time_stats(
			_run_time, _run_time_raw, _badge_tracker.get_run_badge_time(),
			missed_enemy_penalty_time_total, hit_friendly_penalty_time_total
	)
	_run_summary_page.update_misc_stats(
			_target_manager.target_count_enemy_down(), _target_manager.target_count_enemy(), 
			_target_manager.target_count_friendly_down(), _bullet_manager.run_acc, 
			_bullet_manager.run_bullet_count, _bullet_manager.run_longest_shot
	)
	_run_summary_page.update_run_badges(_badge_tracker.get_run_badges())
	_run_summary_page.popup()


func _finish_run() -> void:
	_audio_player_run_end.play()
	_is_player_on_range = false
	
	_badge_tracker.evaluate_end_of_run_stats(
			_target_manager.are_all_enemy_targets_down(),
			_target_manager.are_all_friendly_targets_up(),
			_bullet_manager.run_acc
	)
	
	var missed_enemy_penalty_time_total: float = (
		_missed_enemy_penalty * _target_manager.target_count_enemy_up()
	)
	var hit_friendly_penalty_time_total: float = (
		_hit_friendly_penalty * _target_manager.target_count_friendly_down()
	)
	
	_run_time = (
			_run_time_raw + _badge_tracker.get_run_badge_time() +
			missed_enemy_penalty_time_total + hit_friendly_penalty_time_total
	)
	 
	_update_level_best()
	
	yield(get_tree().create_timer(0.5), "timeout")
	_update_and_show_run_summary(
			missed_enemy_penalty_time_total, hit_friendly_penalty_time_total
	)


func _update_level_best() -> void:
	if _best_time == -1.0:
		_best_time = _run_time
		_level_ui.set_label_time_best(_best_time)
		SaveLoad.save_level_best_time(_level_name, _run_time)
		_run_summary_page.is_new_best = true
	elif _run_time < _best_time:
		_run_summary_page.is_new_best = true
		_best_time = _run_time
		_level_ui.set_label_time_best(_best_time)
		SaveLoad.save_level_best_time(_level_name, _run_time)
	else:
		_run_summary_page.is_new_best = false
