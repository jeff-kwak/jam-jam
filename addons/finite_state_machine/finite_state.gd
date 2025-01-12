class_name FiniteState
extends Node


var _on_process: Array[Callable] = []
var _on_enter: Array[Callable] = []
var _on_exit: Array[Callable] = []
var _on_trigger = { }


var _fsm: FiniteStateMachine

var host: Node:
    get:
        return _fsm.host


func bind(fsm: FiniteStateMachine) -> void:
    _fsm = fsm


func enter() -> void:
    print("> %s::%s" % [host.name, self.name])
    for callback in _on_enter:
        callback.call()


func process(dt: float) -> void:
    for callback in _on_process:
        callback.call(dt)


func send(some_trigger: int) -> void:
    _fsm.send(some_trigger)


func exit() -> void:
    print("< %s::%s" % [host.name, self.name])
    for callback in _on_exit:
        callback.call()


func trigger(some_trigger: int) -> void:
    if _on_trigger.has(some_trigger):
        for callback in _on_trigger[some_trigger]:
            callback.call()


func add_on_enter(cb: Callable) -> void:
    _on_enter.append(cb)


func add_on_exit(cb: Callable) -> void:
    _on_exit.append(cb)


func add_on_process(cb: Callable) -> void:
    _on_process.append(cb)


func add_on_trigger(some_trigger: int, cb: Callable) -> void:
    if not _on_trigger.has(some_trigger):
        _on_trigger[some_trigger] = []

    _on_trigger[some_trigger].append(cb)
