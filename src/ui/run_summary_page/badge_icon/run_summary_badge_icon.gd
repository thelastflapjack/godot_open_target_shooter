class_name RunSummaryBadgeIcon
extends VBoxContainer


signal mouse_entered_badge_icon(badge)

var badge: Badge setget set_badge

onready var _badge_icon: TextureRect = $BadgeIcon
onready var _label_count: Label = $LabelCount


func set_badge(new_badge: Badge) -> void:
	badge = new_badge
	_badge_icon.texture = badge.icon


func set_count(count: int) -> void:
	_label_count.text = "x%d" % count


func _on_mouse_entered() -> void:
	emit_signal("mouse_entered_badge_icon", badge)
