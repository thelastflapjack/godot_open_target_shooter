#class_name
extends MultiPageUIMagager
# Docstring


signal quit_level()

onready var _anim_player: AnimationPlayer = $AnimationPlayer


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	var home_page: MultiPageUIPage = _pages["Home"]
	GenUtils.connect_signal_assert_ok(
			home_page, "resume_requested",
			self, "_on_resume_requested"
	)
	GenUtils.connect_signal_assert_ok(
			home_page, "quit_requested",
			self, "_on_quit_requested"
	)


############################
#      Public Methods      #
############################
func popup() -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_anim_player.play("popup")
	get_tree().set_pause(true)


############################
# Signal Connected Methods #
############################
func _on_resume_requested() -> void:
	if visible:
		_close()


func _on_quit_requested() -> void:
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	emit_signal("quit_level")


############################
#      Private Methods     #
############################
func _close() -> void:
	_anim_player.play_backwards("popup")
	yield(_anim_player, "animation_finished")
	get_tree().set_pause(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_visible(false)
