@tool
extends EditorPlugin


func _enter_tree() -> void:
    add_custom_type("FiniteState", "FiniteState", preload("finite_state.gd"), preload("Play.svg"))


func _exit_tree() -> void:
    remove_custom_type("FiniteState")
