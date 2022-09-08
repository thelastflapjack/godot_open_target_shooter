class_name PlayerHUD
extends Control
# Docstring


onready var _weapon_ammo_label: Label = $WeaponInfo/VBoxContainer/LabelAmmo
onready var _weapon_tex_rect: TextureRect = $WeaponInfo/VBoxContainer/WeaponIcon
onready var _label_reload: Label = $ReloadLabel
onready var _animation_player: AnimationPlayer = $AnimationPlayer


func update_weapon_ammo(remaining: int) -> void:
	_weapon_ammo_label.text = "%02d / INF" % remaining
	if remaining <= 0:
		_label_reload.visible = true
		_animation_player.play("reload_warning")
	else:
		_label_reload.visible = false
		_animation_player.stop(true)


func update_weapon_icon(icon: Texture) -> void:
	_weapon_tex_rect.texture = icon

