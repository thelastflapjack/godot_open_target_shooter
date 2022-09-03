extends MultiPageUIPage
# Docstring

signal resume_requested()
signal quit_requested()


func _unhandled_input(event: InputEvent) -> void:
	if active:
		if event.is_action_pressed("ui_cancel"):
			emit_signal("resume_requested")


func _on_btn_resume_pressed() -> void:
	if active:
		emit_signal("resume_requested")
		_audio_btn_pressed.play()


func _on_btn_settings_pressed() -> void:
	if active:
		emit_signal("change_page_request", "SettingsPage")
		_audio_btn_pressed.play()


func _on_btn_controls_pressed() -> void:
	if active:
		emit_signal("change_page_request", "ControlsPage")
		_audio_btn_pressed.play()


func _on_btn_quit_pressed() -> void:
	if active:
		emit_signal("quit_requested")
		_audio_btn_pressed.play()

