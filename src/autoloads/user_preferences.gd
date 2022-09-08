extends Node
# Autoloaded script to contain user preferences


### Enums ###
enum AudioBuses {
	MASTER = 0,
	SFX = 1,
	MUSIC = 2,
	UI = 3,
}


### Public variables ###
var audio_vol: Dictionary = {
	AudioBuses.MASTER: 0.5,
	AudioBuses.SFX: 0.5,
	AudioBuses.MUSIC: 0.5,
	AudioBuses.UI: 0.5,
}

var mouse_sensitivity: float = 0.5 setget set_mouse_sensitivity
var toggle_sprint: bool = true
var toggle_aim: bool = true

var borderless_window: bool = false setget set_borderless_window
var fullscreen_window: bool = true setget set_fullscreen_window
var vsync: bool = true setget set_vsync
var fxaa: bool = false setget set_fxaa
var msaa: int = Viewport.MSAA_4X setget set_msaa


############################
# Engine Callback Methods  #
############################

func _ready() -> void:
	_load()


############################
#      Public Methods      #
############################

func set_audio_vol(bus: int, val: float) -> void:
	audio_vol[bus] = clamp(val, 0, 1.0)
	AudioServer.set_bus_volume_db(bus, _vol_linear_to_db(val))
	AudioServer.set_bus_mute(bus, val == 0) #mute if val is 0, unmute otherwise


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
		prefs_cfg.set_value("user_prefs", "audio_vol_master", audio_vol[AudioBuses.MASTER])
		prefs_cfg.set_value("user_prefs", "audio_vol_music", audio_vol[AudioBuses.MUSIC])
		prefs_cfg.set_value("user_prefs", "audio_vol_sfx", audio_vol[AudioBuses.SFX])
		prefs_cfg.set_value("user_prefs", "audio_vol_ui", audio_vol[AudioBuses.UI])
		
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
		set_audio_vol(AudioBuses.MASTER, prefs_cfg.get_value("user_prefs", "audio_vol_master"))
		set_audio_vol(AudioBuses.MUSIC, prefs_cfg.get_value("user_prefs", "audio_vol_music"))
		set_audio_vol(AudioBuses.SFX, prefs_cfg.get_value("user_prefs", "audio_vol_sfx"))
		set_audio_vol(AudioBuses.UI, prefs_cfg.get_value("user_prefs", "audio_vol_ui"))
		
		set_mouse_sensitivity(prefs_cfg.get_value("user_prefs", "mouse_sensitivity"))
		toggle_sprint = prefs_cfg.get_value("user_prefs", "toggle_sprint")
		toggle_aim = prefs_cfg.get_value("user_prefs", "toggle_aim")
		
		set_borderless_window(prefs_cfg.get_value("user_prefs", "borderless_window"))
		set_fullscreen_window(prefs_cfg.get_value("user_prefs", "fullscreen_window"))
		set_vsync(prefs_cfg.get_value("user_prefs", "vsync"))
		set_fxaa(prefs_cfg.get_value("user_prefs", "fxaa"))
		set_msaa(prefs_cfg.get_value("user_prefs", "msaa"))

