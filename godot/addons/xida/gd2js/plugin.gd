@tool
extends EditorPlugin

const GD2JS_AUTOLOAD_NAME = "GD2JS"

func _enter_tree():
	add_autoload_singleton(GD2JS_AUTOLOAD_NAME, GD2JS_AUTOLOAD_NAME.to_lower() + ".gd")

func _exit_tree():
	remove_autoload_singleton(GD2JS_AUTOLOAD_NAME)
