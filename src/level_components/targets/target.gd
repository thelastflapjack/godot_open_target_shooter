class_name Target
extends StaticBody
# Docstring


### Signals ###
signal hit()


### Public variables ###
var is_enemy: bool
var is_hit: bool = false

### Private variables ###
var _health: int = 1


############################
# Engine Callback Methods  #
############################


############################
#      Public Methods      #
############################
func inactive() -> void:
	_health = 0
	is_hit = true
	

func reset() -> void:
	_health = 1
	is_hit = false


func hurt(value: int) -> void:
	_health = int(max(_health - value, 0))
	if (_health == 0) && (not is_hit):
		is_hit = true
		emit_signal("hit")

