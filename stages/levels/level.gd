extends Node2D


@onready var _level_name_label: Label = %LevelNameLabel
@onready var _timer_display: Label = %TimerDisplay


var _count: int = 0


func _ready() -> void:
    _level_name_label.text = name
    _count = 0


func _process(_delta: float) -> void:
    _timer_display.text = str(_count).lpad(2, "0")


func _on_restart_button_pressed() -> void:
    EventBus.fire_restart_level_requested()


func _on_next_level_button_pressed() -> void:
    EventBus.fire_next_level_requested()


func _on_timer_timeout() -> void:
    _count += 1
