class_name State
extends Node
# Virtual base class for all states.

### Signals ###
# warning-ignore:unused_signal
signal change_state_request(state_id, data)


############################
#      Public Methods      #
############################
# Virtual function. Corresponds to _unhandled_input() callback
# warning-ignore:unused_argument
func handle_input(event: InputEvent) -> void:
	pass


# Virtual function. Corresponds to the _process() callback
# warning-ignore:unused_argument
func update(delta: float) -> void:
	pass


# Virtual function. Corresponds to the _physics_process() callback
# warning-ignore:unused_argument
func physics_update(delta: float) -> void:
	pass


# Virtual function. Called by the state machine upon changing the active state.
# _data is a dictionary with arbitrary data the state can use to initialize.
func enter(_data := {}) -> void:
	pass


# Virtual function. Called by the state machine before changing the active state. Use this function
# to clean up the state.
func exit() -> void:
	pass


############################
#      Private Methods     #
############################
