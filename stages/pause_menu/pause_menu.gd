extends Node2D



func _on_resume_button_pressed() -> void:
    EventBus.fire_unpause_game_requested()


func _on_restart_button_pressed() -> void:
    EventBus.fire_restart_level_requested()


func _on_quit_button_pressed() -> void:
    EventBus.fire_start_menu_requested()
