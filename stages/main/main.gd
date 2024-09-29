extends Node2D


enum State {
    START_MENU,
    GAME_PLAY,
    PAUSED,
    CREDITS
}


enum Trigger {
    START_MENU_REQUESTED,
    CREDIT_MENU_REQUESTED,
    NEXT_LEVEL_REQUESTED,
    RESTART_LEVEL_REQUESTED,
    PAUSE_GAMEPLAY_REQUESTED,
    UNPAUSE_GAMEPLAY_REQUESTED
}


@export var _start_menu: PackedScene
@export var _credits_menu: PackedScene
@export var _pause_menu: PackedScene
@export var _levels: Array[PackedScene]


@onready var _stages: Node2D = $Stages


var _fsm: FiniteStateMachine = FiniteStateMachine.new(self)
var _current_level: Node2D = null
var _overlay: Node2D = null
var _level_idx: int = -1


func _init() -> void:
    EventBus.start_menu_requested.connect(func(): _fsm.send(Trigger.START_MENU_REQUESTED))
    EventBus.credit_menu_requested.connect(func(): _fsm.send(Trigger.CREDIT_MENU_REQUESTED))
    EventBus.next_level_requested.connect(func(): _fsm.send(Trigger.NEXT_LEVEL_REQUESTED))
    EventBus.restart_level_requested.connect(func(): _fsm.send(Trigger.RESTART_LEVEL_REQUESTED))
    EventBus.pause_game_requested.connect(func(): _fsm.send(Trigger.PAUSE_GAMEPLAY_REQUESTED))
    EventBus.unpause_game_requested.connect(func(): _fsm.send(Trigger.UNPAUSE_GAMEPLAY_REQUESTED))


func _ready() -> void:
    _fsm.setup(State.START_MENU).bind($States/MainMenu) \
        .permit(Trigger.CREDIT_MENU_REQUESTED, State.CREDITS) \
        .permit(Trigger.NEXT_LEVEL_REQUESTED, State.GAME_PLAY) \
        .on_enter(func(): _transition_to_stage(_start_menu)) \
        .on_enter(func(): _level_idx = -1)

    _fsm.setup(State.CREDITS).bind($States/Credits) \
        .permit(Trigger.START_MENU_REQUESTED, State.START_MENU) \
        .on_enter(func(): _transition_to_stage(_credits_menu))

    _fsm.setup(State.GAME_PLAY).bind($States/GamePlay) \
        .permit(Trigger.PAUSE_GAMEPLAY_REQUESTED, State.PAUSED) \
        .on_enter(_load_when_first) \
        .on_process(_listen_for_pause) \
        .on_trigger(Trigger.NEXT_LEVEL_REQUESTED, _load_next_level) \
        .on_trigger(Trigger.RESTART_LEVEL_REQUESTED, _reload_current_level)

    _fsm.setup(State.PAUSED).bind($States/Paused) \
        .permit(Trigger.UNPAUSE_GAMEPLAY_REQUESTED, State.GAME_PLAY) \
        .permit(Trigger.RESTART_LEVEL_REQUESTED, State.GAME_PLAY) \
        .permit(Trigger.START_MENU_REQUESTED, State.START_MENU) \
        .on_enter(func(): _load_overlay(_pause_menu)) \
        .on_enter(_pause_game) \
        .on_exit(_unpause_game) \
        .on_exit(func(): _remove_overlay(_overlay)) \
        .on_trigger(Trigger.RESTART_LEVEL_REQUESTED, _reload_current_level) \
        .on_trigger(Trigger.START_MENU_REQUESTED, _reset_game)

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


func _load_when_first() -> void:
    if _level_idx < 0:
        print("main: loading first level")
        _clear_stage()
        _level_idx = 0
        _load_level(_level_idx)


func _reload_current_level() -> void:
    print("main: reload current level %s" % _level_idx)
    _load_level(_level_idx)


func _load_next_level() -> void:
    _level_idx += 1
    _load_level(_level_idx)


func _load_level(idx: int) -> void:
    if idx < 0 or idx >= len(_levels):
        push_error("Tried to load a level that doesn't exist: %s" % idx)
        return

    if _current_level != null:
        _stages.remove_child(_current_level)
    _current_level = _levels[idx].instantiate()
    _stages.add_child(_current_level)


func _pause_game() -> void:
    _stages.process_mode = Node.PROCESS_MODE_DISABLED


func _unpause_game() -> void:
    _stages.process_mode = Node.PROCESS_MODE_INHERIT


func _load_overlay(overlay: PackedScene) -> void:
    _overlay = overlay.instantiate()
    add_child(_overlay) # has to be last so it's on top of everything else


func _remove_overlay(overlay: Node2D) -> void:
    remove_child(overlay)
    if overlay == _overlay:
        _overlay.queue_free()
        _overlay = null


func _listen_for_pause(_dt: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        _fsm.send(Trigger.PAUSE_GAMEPLAY_REQUESTED)


func _listen_for_unpause(_dt: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        _fsm.send(Trigger.UNPAUSE_GAMEPLAY_REQUESTED)


func _reset_game() -> void:
    _current_level.queue_free()
    _current_level = null
    _level_idx = -1
    _clear_stage()
