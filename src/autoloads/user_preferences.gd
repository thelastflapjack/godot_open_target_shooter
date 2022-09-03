extends Node
# Autoloaded script to contain user preferences

var audio_vol_master: float = 0.5 setget set_audio_vol_master
var audio_vol_music: float = 0.5 setget set_audio_vol_music
var audio_vol_sfx: float = 0.5 setget set_audio_vol_sfx
var audio_vol_ui: float = 0.5 setget set_audio_vol_ui

var mouse_sensitivity: float = 0.5 setget set_mouse_sensitivity
var toggle_sprint: bool = true
var toggle_aim: bool = true

var borderless_window: bool = false setget set_borderless_window
var fullscreen_window: bool = true setget set_fullscreen_window
var vsync: bool = true setget set_vsync
var fxaa: bool = false setget set_fxaa
var msaa: int = Viewport.MSAA_4X setget set_msaa


func _ready() -> void:
	_load()


func set_audio_vol_master(val: float) -> void:
	audio_vol_master = clamp(val, 0, 1.0)
	if audio_vol_master == 0:
		AudioServer.set_bus_mute(0, true)
	else:
		AudioServer.set_bus_mute(0, false)
		AudioServer.set_bus_volume_db(0, _vol_linear_to_db(audio_vol_master))


func set_audio_vol_music(val: float) -> void:
	audio_vol_music = clamp(val, 0, 1.0)
	if audio_vol_music == 0:
		AudioServer.set_bus_mute(2, true)
	else:
		AudioServer.set_bus_mute(2, false)
		AudioServer.set_bus_volume_db(2, _vol_linear_to_db(audio_vol_music))


func set_audio_vol_sfx(val: float) -> void:
	audio_vol_sfx = clamp(val, 0, 1.0)
	if audio_vol_sfx == 0:
		AudioServer.set_bus_mute(1, true)
	else:
		AudioServer.set_bus_mute(1, false)
		AudioServer.set_bus_volume_db(1, _vol_linear_to_db(audio_vol_sfx))


func set_audio_vol_ui(val: float) -> void:
	audio_vol_ui = clamp(val, 0, 1.0)
	if audio_vol_ui == 0:
		AudioServer.set_bus_mute(3, true)
	else:
		AudioServer.set_bus_mute(3, false)
		AudioServer.set_bus_volume_db(3, _vol_linear_to_db(audio_vol_ui))


func set_mouse_sensitivity(val: float) -> void:
	mouse_sensitivity = clamp(val, 0.05, 1.0)


func set_borderless_window(val: bool) -> void:
	borderless_window = val
	OS.window_borderless = borderless_window


func set_fullscreen_window(val: bool) -> void:
	fullscreen_window = val
	OS.window_fullscreen = fullscreen_window


func set_vsync(val: bool) -> void:
	vsync = val
	OS.vsync_enabled = vsync


func set_fxaa(val: bool) -> void:
	fxaa = val
	get_viewport().fxaa = fxaa


func set_msaa(val: int) -> void:
	msaa = val
	get_viewport().msaa = msaa


func save() -> void:
	var file_checker: File = File.new()
	if not file_checker.file_exists("user://user_prefs.cfg"):
		# To create a new file
		# warning-ignore:return_value_discarded
		file_checker.open("user://user_prefs.cfg", File.WRITE)
	file_checker.close()
	
	var prefs_cfg: ConfigFile = ConfigFile.new()
	var err: int = prefs_cfg.load("user://user_prefs.cfg")
	if err == OK:
		prefs_cfg.set_value("user_prefs", "audio_vol_master", audio_vol_master)
		prefs_cfg.set_value("user_prefs", "audio_vol_music", audio_vol_music)
		prefs_cfg.set_value("user_prefs", "audio_vol_sfx", audio_vol_sfx)
		prefs_cfg.set_value("user_prefs", "audio_vol_ui", audio_vol_ui)
		
		prefs_cfg.set_value("user_prefs", "mouse_sensitivity", mouse_sensitivity)
		prefs_cfg.set_value("user_prefs", "toggle_sprint", toggle_sprint)
		prefs_cfg.set_value("user_prefs", "toggle_aim", toggle_aim)
		
		prefs_cfg.set_value("user_prefs", "borderless_window", borderless_window)
		prefs_cfg.set_value("user_prefs", "fullscreen_window", fullscreen_window)
		prefs_cfg.set_value("user_prefs", "vsync", vsync)
		prefs_cfg.set_value("user_prefs", "fxaa", fxaa)
		prefs_cfg.set_value("user_prefs", "msaa", msaa)
		
		err = prefs_cfg.save("user://user_prefs.cfg")


############################
#      Private Methods     #
############################
func _vol_db_to_linear(val: float) -> float:
	return db2linear(val - 6)


func _vol_linear_to_db(val: float) -> float:
	return linear2db(val) + 6


func _load() -> void:
	var prefs_cfg: ConfigFile = ConfigFile.new()
	var err: int = prefs_cfg.load("user://user_prefs.cfg")
	
	if err == OK:
		# Using set funcs for most so preferences are applied when this autoload
		# enters the sceen tree as the game program starts.
		set_audio_vol_master(prefs_cfg.get_value("user_prefs", "audio_vol_master"))
		set_audio_vol_music(prefs_cfg.get_value("user_prefs", "audio_vol_music"))
		set_audio_vol_sfx(prefs_cfg.get_value("user_prefs", "audio_vol_sfx"))
		set_audio_vol_ui(prefs_cfg.get_value("user_prefs", "audio_vol_ui"))
		
		set_mouse_sensitivity(prefs_cfg.get_value("user_prefs", "mouse_sensitivity"))
		toggle_sprint = prefs_cfg.get_value("user_prefs", "toggle_sprint")
		toggle_aim = prefs_cfg.get_value("user_prefs", "toggle_aim")
		
		set_borderless_window(prefs_cfg.get_value("user_prefs", "borderless_window"))
		set_fullscreen_window(prefs_cfg.get_value("user_prefs", "fullscreen_window"))
		set_vsync(prefs_cfg.get_value("user_prefs", "vsync"))
		set_fxaa(prefs_cfg.get_value("user_prefs", "fxaa"))
		set_msaa(prefs_cfg.get_value("user_prefs", "msaa"))

