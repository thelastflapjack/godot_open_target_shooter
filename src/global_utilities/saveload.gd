class_name SaveLoad
extends Reference


static func load_level_par_time(level_name: String) -> float:
	var par_time: float = -1.0
	var cfg_file: ConfigFile = ConfigFile.new()
	var err: int = cfg_file.load("res://read_only_data/level_par_times.cfg")
	
	if err == OK:
		par_time =  cfg_file.get_value("par_times", level_name)
	return par_time


static func save_level_best_time(level_name: String, time: float) -> void:
	var file_checker: File = File.new()
	if not file_checker.file_exists("user://level_best_times.cfg"):
		# To create a new save file
		# warning-ignore:return_value_discarded
		file_checker.open("user://level_best_times.cfg", File.WRITE)
	file_checker.close()
		
	var save_file: ConfigFile = ConfigFile.new()
	var err: int = save_file.load("user://level_best_times.cfg")
	if err == OK:
		save_file.set_value("level_best_times", level_name, time)
		err = save_file.save("user://level_best_times.cfg")


static func load_level_best_time(level_name: String) -> float:
	var file_checker: File = File.new()
	if file_checker.file_exists("user://level_best_times.cfg"):
		var save_file: ConfigFile = ConfigFile.new()
		var err: int = save_file.load("user://level_best_times.cfg")
		if err == OK:
			return save_file.get_value("level_best_times", level_name, -1.0)
		else:
			return -1.0
	else:
		# To create a new save file
		var err: int = file_checker.open("user://level_best_times.cfg", File.WRITE)
		if err == OK:
			file_checker.close()
	return -1.0
