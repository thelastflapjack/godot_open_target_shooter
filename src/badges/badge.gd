class_name Badge
extends Resource
# Docstring

export(String) var title: String
export(String, MULTILINE) var description: String
export(float, 0.0, 10.0, 0.1) var time_value: float
export(Texture) var icon: Texture setget ,get_icon
export(bool) var is_end_of_run_badge: bool = false


var _placeholder_icon: Texture = preload("res://raw_assets/images_icons/badges/placeholder.png")


func get_icon() -> Texture:
	if icon:
		return icon
	return _placeholder_icon


func _to_string() -> String:
	return (
			"%s (-%3.1fs): %s" % [title, time_value, description]
	)
