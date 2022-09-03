extends Control
# Docstring

### Public variables ###
var is_new_best: bool = false


### Private variables ###
var _badge_icon_res: PackedScene = preload("res://src/ui/run_summary_page/badge_icon/run_summary_badge_icon.tscn")
var _par_time: float

### Onready variables ###
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _audio_btn_pressed: AudioStreamPlayer = $AudioStreamPlayer

onready var _header_final_time: Label = $HeaderFinalTime
onready var _label_base_time: Label = find_node("LabelBaseTime")
onready var _label_badge_time: Label = find_node("LabelBadgeTime")
onready var _label_penalty_time_missed_enemy: Label = find_node("LabelPenaltyTimeEnemy")
onready var _label_penalty_time_hit_friendly: Label = find_node("LabelPenaltyTimeFriendly")
onready var _label_final_time: Label = find_node("LabelFinalTime")
onready var _label_par_time: Label = find_node("LabelParTime")
onready var _label_shots_fired: Label = find_node("LabelShotsFired")
onready var _label_longest_shot: Label = find_node("LabelLongestShot")
onready var _label_targets_hit_value: Label = find_node("ValueTargetsHit")
onready var _label_all_targets_hit_value: Label = find_node("ValueAllTargetsHit")
onready var _label_friendlies_hit_value: Label = find_node("ValueFriendliesHit")
onready var _label_accuracy_value: Label = find_node("ValueAccuracy")

onready var _badge_icons_container: HBoxContainer = find_node("BadgeIcons")
onready var _badge_hover_info: VBoxContainer = $VBoxContainer/BadgeInfoHover
onready var _hover_badge_title_label: Label = $VBoxContainer/BadgeInfoHover/BadgeTitle
onready var _hover_badge_description_label: Label = $VBoxContainer/BadgeInfoHover/BadgeDescription
onready var _hover_badge_time_val_label: Label = $VBoxContainer/BadgeInfoHover/BadgeTimeValue

onready var _new_best_effect: Control = $NewBestEffect


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	$VBoxContainer/ScrollContainer/BadgeIcons/BadgePlaceholder.queue_free()


############################
#      Public Methods      #
############################
func update_time_stats(time_final: float, time_raw: float, badge_time: float, missed_enemy_penalty_time: float, hit_friendly_penalty_time: float) -> void:
	_header_final_time.text = "%6.2f s" % time_final
	_label_final_time.text = "%6.2f s" % time_final
	_label_base_time.text = "%6.2f s" % time_raw
	_label_badge_time.text = "%+6.2f s" % badge_time
	_label_penalty_time_missed_enemy.text = "%+6.2f s" % missed_enemy_penalty_time
	_label_penalty_time_hit_friendly.text = "%+6.2f s" % hit_friendly_penalty_time
	
	var color_target: Color = Color("4bff50")
	if _par_time < time_final:
		color_target = Color("ff4b4b")
	_header_final_time.modulate = color_target
	_label_final_time.modulate = color_target
	
	if badge_time < 0:
		_label_badge_time.modulate = Color("4bff50")
	
	if missed_enemy_penalty_time > 0:
		_label_penalty_time_missed_enemy.modulate = Color("ff4b4b")
	
	if hit_friendly_penalty_time > 0:
		_label_penalty_time_hit_friendly.modulate = Color("ff4b4b")


func update_misc_stats(targets_hit: int, targets_total: int, friendlies_hit: int, accuracy: float, bullet_count: int, longest_shot: float) -> void:
	_label_shots_fired.text = String(bullet_count)
	_label_longest_shot.text = "%6.1f m" % longest_shot
	_label_targets_hit_value.text = "%02d/%02d" % [targets_hit, targets_total]
	_label_friendlies_hit_value.text = String(friendlies_hit)
	_label_accuracy_value.text = "%6.2f %%" % (accuracy * 100)


func update_run_badges(run_badges: Dictionary) -> void:
	for badge in run_badges.keys():
		var new_badge_icon: RunSummaryBadgeIcon = _badge_icon_res.instance()
		_badge_icons_container.add_child(new_badge_icon)
		new_badge_icon.badge = badge
		new_badge_icon.set_count(run_badges[badge])
		GenUtils.connect_signal_assert_ok(
				new_badge_icon, "mouse_entered_badge_icon",
				self, "_on_mouse_entered_badge_icon"
		)


func set_level_par_time(time: float) -> void:
	_label_par_time.text = "%6.2f s" % time
	_par_time = time


func popup() -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var tween: SceneTreeTween = create_tween()
	var fade_tweener: PropertyTweener = tween.tween_property(
			self, "modulate", Color(1,1,1,1), 0.3
	)
	fade_tweener = fade_tweener.from(Color(1,1,1,0))
	tween.play()
	
	_new_best_effect.visible = is_new_best
	if is_new_best:
		_anim_player.play("new_best")
	
	get_tree().set_pause(true)
	


############################
# Signal Connected Methods #
############################
func _on_btn_continue_pressed():
	_audio_btn_pressed.play()
	_close()


func _on_mouse_entered_badge_icon(badge: Badge) -> void:
	_hover_badge_title_label.text = badge.title
	_hover_badge_description_label.text = badge.description
	_hover_badge_time_val_label.text = "-%3.1f Seconds" % badge.time_value
	_badge_hover_info.visible = true


############################
#      Private Methods     #
############################

func _close() -> void:
	var tween: SceneTreeTween = create_tween()
	var fade_tweener: PropertyTweener = tween.tween_property(
			self, "modulate", Color(1,1,1,0), 0.3
	)
	fade_tweener = fade_tweener.from(Color(1,1,1,1))
	tween.play()
	yield(tween, "finished")
	
	_anim_player.stop()
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_badge_hover_info.visible = false
	visible = false
	for badge_icon in _badge_icons_container.get_children():
		badge_icon.queue_free()

