extends MultiPageUIPage


func _ready() -> void:
	MusicManager.transition_to_track(
			MusicManager.Tracks.MAIN_MENU, 3
	)


func _on_btn_level_pressed() -> void:
	if active:
		emit_signal("change_page_request", "LevelSelect")
		_audio_btn_pressed.play()


func _on_btn_settings_pressed() -> void:
	if active:
		emit_signal("change_page_request", "SettingsPage")
		_audio_btn_pressed.play()


func _on_btn_controls_pressed() -> void:
	if active:
		emit_signal("change_page_request", "ControlsPage")
		_audio_btn_pressed.play()


func _on_btn_credits_pressed() -> void:
	if active:
		emit_signal("change_page_request", "CreditsPage")
		_audio_btn_pressed.play()


func _on_btn_exit_pressed() -> void:
	if active:
		_audio_btn_pressed.play()
		get_tree().quit()
