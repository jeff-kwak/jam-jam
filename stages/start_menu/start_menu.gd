class_name StartMenu
extends Node2D


func _on_play_button_pressed() -> void:
    print("start_menu: play pressed")
    EventBus.fire_start_gameplay_requested()


func _on_credits_button_pressed() -> void:
    print("start_menu: credits pressed")
    EventBus.fire_credit_menu_requested()
