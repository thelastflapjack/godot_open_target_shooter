extends Node
# Main scene node, program starts here.
# Manages loading of and transition between major scenes.

### Exported variables ###
export(PackedScene) var _initial_scene: PackedScene

### Private variables ###
var _loader: ResourceInteractiveLoader
const _poll_time : float = 0.02

### Onready variables ###
onready var _anim_player: AnimationPlayer = get_node("AnimationPlayer")
onready var _fade_rect: ColorRect = get_node("CanvasLayer/ColorRect")
onready var _loader_poll_timer : Timer = get_node("LoaderPollTimer")


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	_loader_poll_timer.wait_time = _poll_time
	
	#make sure root is ready to take new child
	yield(get_tree().root,"ready")
	_set_current_scene(_initial_scene.instance())


############################
# Signal Connected Methods #
############################
func _on_change_scene_request(scene_res_path: String) -> void:
	call_deferred("_change_scene_background", scene_res_path)

func _on_animation_finished(anim_name: String) -> void:
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_loader_poll_timer_timeout() -> void:
	var err = _loader.poll()

	if err == ERR_FILE_EOF: # Finished loading.
		var resource = _loader.get_resource()
		_loader = null
		_set_current_scene(resource.instance())
	elif err == OK:
		#print(float(_loader.get_stage()) / float(_loader.get_stage_count()))
		# Would update a loading bar here
		_loader_poll_timer.start()
	else:
		assert(false,"ResourceInteractiveLoader Error: " + str(_loader.poll()))


############################
#      Private Methods     #
############################
func _fade(is_in : bool) -> void:
	#BUG: we can do _anim_player.play("fade",-1,1.0,!is_in),
	#     but apparently calling AnimationPlayer.play() with backward set to true doesn't play backward for some reason
	
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	if is_in:
		_anim_player.play("fade")
	else:
		_anim_player.play_backwards("fade")


func _set_current_scene(new_scene: Node) -> void:
	get_tree().get_root().add_child(new_scene)
	get_tree().current_scene = new_scene
	
	GenUtils.connect_signal_assert_ok(
			new_scene, "change_scene_request",
			self, "_on_change_scene_request"
	)
	get_tree().current_scene = new_scene
	if _anim_player.is_playing():
		yield(_anim_player, "animation_finished")
	_fade(false)


func _change_scene_background(new_scene_path: String) -> void:
	if new_scene_path == "":
		new_scene_path = _initial_scene.get_path()
	
	
	_loader = ResourceLoader.load_interactive(new_scene_path, "PackedScene")
	assert(_loader, "ResourceLoader is null. Attemped load target path: %s" % new_scene_path)
	
	_fade(true)
	yield(_anim_player, "animation_finished")
	
	var curr_scene := get_tree().current_scene
	if curr_scene:
		curr_scene.disconnect("change_scene_request", self, "_on_change_scene_request")
		curr_scene.queue_free()
		get_tree().current_scene = null
	
	_loader_poll_timer.start()
