extends Node2D


func _on_back_button_pressed() -> void:
    EventBus.fire_start_menu_requested()
