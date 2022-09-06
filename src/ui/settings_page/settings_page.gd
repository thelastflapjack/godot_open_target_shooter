extends MultiPageUIPage
# Script controlling the settings page


### Onready variables ###
onready var _label_fps: Label = $FPSLabel

onready var _slider_audio_master: HSlider = find_node("SliderAudioMaster")
onready var _slider_audio_sfx: HSlider = find_node("SliderAudioSFX")
onready var _slider_audio_music: HSlider = find_node("SliderAudioMusic")
onready var _slider_audio_ui: HSlider = find_node("SliderAudioUI")

onready var _slider_mouse_sensitivity: HSlider = find_node("SliderMouseSense")
onready var _check_btn_toggle_sprint: CheckButton = find_node("ToggleSprintCheckButton")
onready var _check_btn_toggle_aim: CheckButton = find_node("ToggleAimCheckButton")

onready var _check_btn_borderless: CheckButton = find_node("BorderlessCheckButton")
onready var _check_btn_fullscreen: CheckButton = find_node("FullScreenCheckButton")
onready var _check_btn_vsync: CheckButton = find_node("VSyncCheckButton")
onready var _check_btn_fxaa: CheckButton = find_node("FXAACheckButton")
onready var _option_btn_msaa: OptionButton = find_node("MSAAOptionButton")


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_slider_audio_master.value = UserPreferences.audio_vol[UserPreferences.AudioBuses.Master]
	_slider_audio_sfx.value = UserPreferences.audio_vol[UserPreferences.AudioBuses.Sfx]
	_slider_audio_music.value = UserPreferences.audio_vol[UserPreferences.AudioBuses.Music]
	_slider_audio_ui.value = UserPreferences.audio_vol[UserPreferences.AudioBuses.Ui]
	
	_slider_mouse_sensitivity.value = UserPreferences.mouse_sensitivity
	_check_btn_toggle_sprint.pressed = UserPreferences.toggle_sprint
	_check_btn_toggle_aim.pressed = UserPreferences.toggle_aim
	
	_check_btn_borderless.pressed = UserPreferences.borderless_window
	_check_btn_fullscreen.pressed  = UserPreferences.fullscreen_window
	_check_btn_vsync.pressed  = UserPreferences.vsync
	_check_btn_fxaa.pressed = UserPreferences.fxaa
	_option_btn_msaa.selected = UserPreferences.msaa


func _physics_process(_delta: float) -> void:
	_label_fps.text = String(Performance.get_monitor(Performance.TIME_FPS))


############################
# Signal Connected Methods #
############################
func _on_btn_back_pressed() -> void:
	if active:
		UserPreferences.save()
		emit_signal("change_page_request", _back_page_name)
		_audio_btn_pressed.play()


func _on_audio_slider_value_changed(value: float, bus: int) -> void:
	if active:
		UserPreferences.set_audio_vol(bus, value)


func _on_slider_mouse_sense_value_changed(value: float) -> void:
	if active:
		UserPreferences.set_mouse_sensitivity(value)


func _on_check_btn_toggle_sprint_pressed() -> void:
	if active:
		UserPreferences.toggle_sprint = _check_btn_toggle_sprint.pressed


func _on_check_btn_toggle_aim_pressed() -> void:
	if active:
		UserPreferences.toggle_aim = _check_btn_toggle_aim.pressed


func _on_check_btn_borderless_pressed() -> void:
	if active:
		UserPreferences.borderless_window = _check_btn_borderless.pressed


func _on_check_btn_fullscreen_pressed() -> void:
	if active:
		UserPreferences.fullscreen_window = _check_btn_fullscreen.pressed


func _on_check_btn_vsync_pressed() -> void:
	if active:
		UserPreferences.vsync = _check_btn_vsync.pressed


func _on_check_btn_fxaa_pressed() -> void:
	if active:
		UserPreferences.fxaa = _check_btn_fxaa.pressed


func _on_option_btn_msaa_item_selected(index: int) -> void:
	if active:
		UserPreferences.msaa = index
