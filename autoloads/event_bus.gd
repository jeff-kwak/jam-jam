extends Node

## Game management signals
signal start_menu_requested
signal credit_menu_requested
signal start_gameplay_requested


func fire_start_menu_requested() -> void:
    start_menu_requested.emit()


func fire_credit_menu_requested() -> void:
    credit_menu_requested.emit()


func fire_start_gameplay_requested() -> void:
    start_gameplay_requested.emit()
