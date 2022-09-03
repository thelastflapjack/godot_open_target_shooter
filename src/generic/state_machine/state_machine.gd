class_name StateMachine
extends Node
# Generic state machine.


### Signals ###
signal transitioned_to(state)

### Private variables ###
var _initial_state: State
var _current_state: State setget ,get_current_state
var _states: Dictionary


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
#	# Wait till owner is ready. Is This needed?
	yield(owner, "ready")
	_find_states()
	_initial_state = get_child(0)
	_enter_initial_state()


############################
#      Public Methods      #
############################
# Corresponds to _unhandled_input() callback
func handle_input(event: InputEvent) -> void:
	_current_state.handle_input(event)


# Corresponds to the _process() callback
func update(delta: float) -> void:
	_current_state.update(delta)


# Corresponds to the _physics_process() callback
func physics_update(delta: float) -> void:
	_current_state.physics_update(delta)


func get_current_state() -> State:
	return _current_state


func transition_to(target_state_id: String, data: Dictionary = {}) -> void:
	assert(_states.has(target_state_id))
	_current_state.disconnect("change_state_request", self, "_on_change_state_request")
	_current_state.exit()
	
	_current_state = _states[target_state_id]
	_current_state.enter(data)
	GenUtils.connect_signal_assert_ok(
			_current_state, "change_state_request",
			self, "_on_change_state_request"
	)
	emit_signal("transitioned_to", _current_state)


func return_to_initial_state() -> void:
	transition_to(_initial_state.name)


############################
# Signal Connected Methods #
############################
func _on_change_state_request(state_id: String, data := {}) -> void:
	transition_to(state_id, data)


############################
#      Private Methods     #
############################
func _find_states() -> void:
	for child in get_children():
		if child is State:
			_states[child.name] = child


func _enter_initial_state() -> void:
	_current_state = _initial_state
	GenUtils.connect_signal_assert_ok(
			_current_state, "change_state_request",
			self, "_on_change_state_request"
	)
	_current_state.enter()
