class_name StartMenu
extends Node2D


func _on_play_button_pressed() -> void:
    EventBus.fire_next_level_requested()


func _on_credits_button_pressed() -> void:
    EventBus.fire_credit_menu_requested()
