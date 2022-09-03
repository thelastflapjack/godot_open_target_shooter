class_name MultiPageUIPage
extends Control
# Docstring


### Signals ###
# warning-ignore:unused_signal
signal change_page_request(page_name)
# warning-ignore:unused_signal
signal change_scene_request(target_scene_res_path)

### Exported variables ###
export(Vector2) var cords: Vector2
export(String) var _back_page_name: String

### Public variables ###
var active: bool = false

### Onready variables ###
onready var _audio_btn_pressed: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	cords = cords.snapped(Vector2(1,1))
