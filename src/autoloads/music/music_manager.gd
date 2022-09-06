extends Node
# Docstring


### Signals ###

### Enums ###
enum Tracks {
	None,
	MAIN_MENU,
	ON_RANGE,
	OFF_RANGE,
}


### Private variables ###
var _current_track_id: int = Tracks.None


### Onready variables ###
onready var _track_stream_players: Dictionary = {
	Tracks.MAIN_MENU: $TrackMainMenu,
	Tracks.ON_RANGE: $TrackOnRange,
	Tracks.OFF_RANGE: $TrackOffRange,
}


############################
#      Public Methods      #
############################

func transition_to_track(new_track_id: int, fade_time: float=1.5, transition_delay: float=0.0) -> void:
	assert(
			_track_stream_players.keys().has(new_track_id), 
			"MusicManager Error: Tried to transition to non-existent track."
	)
	
	if _current_track_id != Tracks.None:
		_track_fade(_current_track_id, false, fade_time)
		if transition_delay > 0.0:
			yield(get_tree().create_timer(transition_delay), "timeout")
	_track_fade(new_track_id, true, fade_time)
	_current_track_id = new_track_id


############################
#      Private Methods     #
############################

func _track_fade(track_id: int, fade_in: bool, fade_time: float) -> void:
	var track_stream_player: AudioStreamPlayer = _track_stream_players[track_id]
	var tween: SceneTreeTween = create_tween().set_trans(Tween.TRANS_SINE)
	
	if fade_in:
		tween.tween_callback(track_stream_player, "play")
		tween.tween_property(
				track_stream_player, "volume_db", 0.0, fade_time
		).from(-20.0).set_ease(Tween.EASE_IN)
	
	else:
		tween.tween_property(
				track_stream_player, "volume_db", -20.0, fade_time
		).from(0.0).set_ease(Tween.EASE_OUT)
		tween.tween_callback(track_stream_player, "stop")
		
	tween.play()

