tool
extends EditorPlugin

func _enter_tree() -> void:
	print("Cocobase-Plugin is enabled.");


func _exit_tree() -> void:
	print("Cocobase-Plugin is disabled.");
