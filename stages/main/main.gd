extends Node2D


enum State {
    START_MENU,
    GAME_PLAY,
    CREDITS
}


enum Trigger {
    START_MENU_REQUESTED,
    CREDIT_MENU_REQUESTED,
    START_GAMEPLAY_REQUESTED,
}


@export var _start_menu: PackedScene
@export var _credits_menu: PackedScene
@export var _game_play: PackedScene


@onready var _stages: Node2D = $Stages


var _fsm: FiniteStateMachine = FiniteStateMachine.new(self)
var _overlay: Node2D = null


func _init() -> void:
    EventBus.start_menu_requested.connect(func(): _fsm.send(Trigger.START_MENU_REQUESTED))
    EventBus.start_gameplay_requested.connect(func(): _fsm.send(Trigger.START_GAMEPLAY_REQUESTED))
    EventBus.credit_menu_requested.connect(func(): _fsm.send(Trigger.CREDIT_MENU_REQUESTED))


func _ready() -> void:
    _fsm.setup(State.START_MENU).bind($States/MainMenu) \
        .on_enter(func(): _transition_to_stage(_start_menu)) \
        .permit(Trigger.START_GAMEPLAY_REQUESTED, State.GAME_PLAY) \
        .permit(Trigger.CREDIT_MENU_REQUESTED, State.CREDITS)

    _fsm.setup(State.CREDITS).bind($States/Credits) \
        .permit(Trigger.START_MENU_REQUESTED, State.START_MENU) \
        .on_enter(func(): _transition_to_stage(_credits_menu))

    _fsm.setup(State.GAME_PLAY).bind($States/GamePlay) \
        .on_enter(func(): _transition_to_stage(_game_play)) \
        .permit(Trigger.START_MENU_REQUESTED, State.START_MENU)

    _fsm.start(State.START_MENU)


func _process(delta: float) -> void:
    _fsm.process(delta)


# TODO: Do some fancy transition effects if you want
func _transition_to_stage(stage: PackedScene) -> void:
    _clear_stage()
    _stages.add_child(stage.instantiate())


func _clear_stage() -> void:
    for child in _stages.get_children():
        _stages.remove_child(child)


func _load_overlay(overlay: PackedScene) -> void:
    _overlay = overlay.instantiate()
    add_child(_overlay) # has to be last so it's on top of everything else


func _remove_overlay(overlay: Node2D) -> void:
    remove_child(overlay)
    if overlay == _overlay:
        _overlay.queue_free()
        _overlay = null
