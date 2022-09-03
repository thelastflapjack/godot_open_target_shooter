class_name LevelUI
extends CanvasLayer
# Docstring

var _par_time: float

onready var _label_time: Label = $Content/RunStats/GridContainer/Control/TimeLabel
onready var _label_enemy_hits: Label = $Content/RunStats/GridContainer/EnemyLabel
onready var _label_friendly_hits: Label = $Content/RunStats/GridContainer/FriendlyLabel

onready var _label_time_best: Label = $Content/LevelStats/GridContainer/TimeBestLabel
onready var _label_time_par: Label = $Content/LevelStats/GridContainer/TimeParLabel

onready var _panel_last_badge: Panel = $Content/LastBadge
onready var _tex_rect_last_badge_icon: TextureRect = $Content/LastBadge/HBoxContainer/LastBadgeIcon
onready var _label_last_badge_title: Label = $Content/LastBadge/HBoxContainer/LastBadgeTitle
onready var _last_badge_particles: Particles2D = $Content/LastBadge/Particles2D
onready var _last_badge_anim_player: AnimationPlayer = $Content/LastBadge/AnimationPlayer
onready var _last_badge_audio_stream: AudioStreamPlayer = $Content/LastBadge/AudioStreamPlayer



############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_panel_last_badge.visible = false


############################
#      Public Methods      #
############################
func set_label_time(time_seconds: float) -> void:
	_label_time.set_text("%6.1f" % stepify(time_seconds, 0.1))


func set_label_enemy_hits(targets_hit: int, targets_total: int) -> void:
	_label_enemy_hits.set_text("%02d/%02d" % [targets_hit, targets_total])


func set_label_friendly_hits(targets_hit: int) -> void:
	_label_friendly_hits.set_text("%02d" % targets_hit)


func set_label_time_best(time_seconds: float) -> void:
	_label_time_best.set_text("%6.2f" % stepify(time_seconds, 0.01))
	
	var color_target: Color = Color("4bff50")
	if _par_time < time_seconds:
		color_target = Color("ff4b4b")
		
	_label_time_best.modulate = color_target


func set_label_time_par(time_seconds: float) -> void:
	_label_time_par.set_text("%6.2f" % stepify(time_seconds, 0.01))
	_par_time = time_seconds


############################
# Signal Connected Methods #
############################
func _on_badge_earned(badge: Badge) -> void:
	if not badge.is_end_of_run_badge:
		_tex_rect_last_badge_icon.texture = badge.icon
		_label_last_badge_title.text = badge.title
		_last_badge_anim_player.play("RESET")
		_last_badge_particles.restart()
		_last_badge_anim_player.play("fade_last_badge")
		_last_badge_audio_stream.play()
