extends MultiPageUIPage
# Script controlling the level select menu screen


### Exported variables ###
export(String) var _level_directory_path: String

### Private variables ###
var _selected_level_button: LevelButton

### Onready variables ###
onready var _level_button_res := preload("res://src/ui/main_menu/level_select/level_button/level_button.tscn")

onready var _level_button_grid: GridContainer = $VBoxContainer/LevelButtons
onready var _label_level_name: Label = $VBoxContainer/PanelContainer/VBoxContainer/LabelLevel
onready var _label_level_time_par: Label = $VBoxContainer/PanelContainer/VBoxContainer/LevelStats/LabelParTime
onready var _label_level_time_best: Label = $VBoxContainer/PanelContainer/VBoxContainer/LevelStats/LabelBestTime
onready var _btn_start_level: Button = $VBoxContainer/TitleLabel/BtnStartLevel

############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_btn_start_level.disabled = true
	_add_level_buttons(_find_level_file_names())


############################
# Signal Connected Methods #
############################
func _on_btn_back_pressed() -> void:
	if active:
		emit_signal("change_page_request", _back_page_name)
		_audio_btn_pressed.play()
		_btn_start_level.disabled = true


func _on_level_button_pressed(button: LevelButton) -> void:
	if active:
		_selected_level_button = button
		_audio_btn_pressed.play()
		_btn_start_level.disabled = false
		_update_selected_level_stats(button)


func _on_start_level_button_pressed() -> void:
	if active and _selected_level_button:
		var level_res_path := (
				"res://src/levels/%s.tscn" % 
				_selected_level_button.text.replace(" ", "_").to_lower()
		)
		emit_signal("change_scene_request", level_res_path)
		_audio_btn_pressed.play()


func _update_selected_level_stats(button: LevelButton) -> void:
	var level_name: String = button.get_text().to_lower().replace(" ", "_")
	var level_time_par: float = SaveLoad.load_level_par_time(level_name)
	var level_time_best: float = SaveLoad.load_level_best_time(level_name)
	
	_label_level_name.set_text(button.get_text())
	_label_level_time_par.set_text("%5.2f" % level_time_par)
	if level_time_best != -1.0:
		_label_level_time_best.set_text("%5.2f" % level_time_best)
		var color_target: Color = Color("4bff50")
		if level_time_best > level_time_par:
			color_target = Color("ff4b4b")
		_label_level_time_best.modulate = color_target
	else:
		_label_level_time_best.set_text("--.--")
		_label_level_time_best.modulate = Color.white


############################
#      Private Methods     #
############################
func _find_level_file_names() -> PoolStringArray:
	var result: PoolStringArray = []
	var dir: Directory = Directory.new()
	var err: int = dir.open(_level_directory_path)
	if err == OK:
		var regex: RegEx = RegEx.new()
		var match_string: String = "level_\\d+.tscn"
		err = regex.compile(match_string)
		if err == OK:
			# warning-ignore:return_value_discarded
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					if regex.search(file_name):
						result.append(file_name)
				file_name = dir.get_next()
		else:
			print("Error %d : Failed compile RegEx %s" % [err, match_string])
	else:
		print("Error %d : Failed to open directory %s" % [err, _level_directory_path])
	return result


func _add_level_buttons(level_file_names: PoolStringArray) -> void:
	for i in range(level_file_names.size()):
		var file_name: String = level_file_names[i]
		var new_button: LevelButton = _level_button_res.instance()
		_level_button_grid.add_child(new_button)
		new_button.set_v_size_flags(SIZE_EXPAND_FILL)
		new_button.set_custom_minimum_size(Vector2(200, 0))
		var text: String = file_name.get_basename().capitalize()
		new_button.set_text(text)
		new_button.set_name("Button%s" % text.replace(" ", ""))
		
		GenUtils.connect_signal_assert_ok(
				new_button, "level_button_pressed",
				self, "_on_level_button_pressed"
		)
