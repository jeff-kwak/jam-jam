class_name FiniteStateMachine
extends Node

var _permitted = {

}


var _state_references = {

}


var _current_state: int = -1
var _change_queue: Array[FiniteState] = []


var host: Node


func _init(h: Node) -> void:
    host = h


### Binds a state enumeration to the class that will provide enter and exit
func setup(state_value: int) -> ConfigState:
    return ConfigState.new(self, state_value)


### Called to potentially transition to a new state
### The type of some_trigger is left as an integer to allow the child class
### to define the states and permitted trigers in that class
func send(some_trigger: int) -> void:
    if(not _permitted.has(_current_state)):
        push_warning("The current state has no permitted transitions, state: %s (trigger: %s)" % [_current_state, some_trigger])
        return

    if(not _state_references.has(_current_state)):
        push_error("Current state %s has no reference" % _current_state)
        return

    _state_references[_current_state].trigger(some_trigger)

    var transitions = _permitted[_current_state]
    if(transitions.has(some_trigger)):
        _change_state(transitions[some_trigger])
        return


func process(dt: float) -> void:
    if(not _state_references.has(_current_state)):
        push_error("Current state %s has no reference" % _current_state)
        return

    _state_references[_current_state].process(dt)


func start(initial_state: int) -> void:
    if(not _state_references.has(initial_state)):
        push_error("Asked to start in state %s, but no state reference found" % initial_state)
        return

    print("FSM: initial state set to %s" % initial_state)

    _state_references[initial_state].enter()
    _current_state = initial_state


func _change_state(next_state_value: int) -> void:
    if(not _state_references.has(next_state_value)):
        push_error("Asked to change to state %s from %s, but no state reference found" % [next_state_value, _current_state])
        return

    _change_queue.append(_state_references[next_state_value])

    var next_state = _change_queue.pop_front()
    while next_state != null:
        _state_references[_current_state].exit()
        _current_state = next_state_value
        _state_references[_current_state].enter()
        next_state = _change_queue.pop_front()


## Provides a little fluent DSL to configure the state machine

class ConfigState:
    var _fsm: FiniteStateMachine
    var _for_this_state: int

    func _init(fsm: FiniteStateMachine, state_value: int) -> void:
        _fsm = fsm
        _for_this_state = state_value

    func bind(state_reference: FiniteState) -> ConfigPermit:
        state_reference.bind(_fsm)
        _fsm._state_references[_for_this_state] = state_reference
        return ConfigPermit.new(_fsm, _for_this_state)


class ConfigPermit:
    var _fsm: FiniteStateMachine
    var _for_this_state: int


    func _init(fsm: FiniteStateMachine, for_this_state: int) -> void:
        self._fsm = fsm
        self._for_this_state = for_this_state


    func permit(some_trigger: int, some_state: int) -> ConfigPermit:
        if not _fsm._permitted.has(_for_this_state):
            _fsm._permitted[_for_this_state] = {}

        _fsm._permitted[_for_this_state][some_trigger] = some_state
        return self


    func on_trigger(some_trigger: int, callback: Callable) -> ConfigPermit:
        _fsm._state_references[_for_this_state].add_on_trigger(some_trigger, callback)
        return self


    func on_process(callback: Callable) -> ConfigPermit:
        _fsm._state_references[_for_this_state].add_on_process(callback)
        return self


    func on_enter(callback: Callable) -> ConfigPermit:
        _fsm._state_references[_for_this_state].add_on_enter(callback)
        return self


    func on_exit(callback: Callable) -> ConfigPermit:
        _fsm._state_references[_for_this_state].add_on_exit(callback)
        return self


    func on_input(callback: Callable) -> ConfigPermit:
        _fsm._state_references[_for_this_state].add_on_input(callback)
        return self
