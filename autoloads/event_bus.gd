extends Node

## Game management signals
signal start_menu_requested
signal credit_menu_requested
signal start_gameplay_requested
signal pause_game_requested
signal unpause_game_requested


func fire_start_menu_requested() -> void:
    start_menu_requested.emit()


func fire_credit_menu_requested() -> void:
    credit_menu_requested.emit()


func fire_pause_game_requested() -> void:
    pause_game_requested.emit()


func fire_unpause_game_requested() -> void:
    unpause_game_requested.emit()


func fire_start_gameplay_requested() -> void:
    start_gameplay_requested.emit()
