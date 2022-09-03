class_name LevelButton
extends Button
# Extension of Button to allow passing of button reference when signaling
# that the button has been pressed or the mouse has entered its rect

signal level_button_pressed(button)
signal level_button_mouse_entered(button)


func _on_pressed() -> void:
	emit_signal("level_button_pressed", self)


func _on_mouse_entered():
	emit_signal("level_button_mouse_entered", self)
