extends Node

onready var _login_dialog = $CenterContainer/LoginDialog

func _ready() -> void:
	_login_dialog.connect("logged_in", self, "_on_logged_in")
	
func _exit_tree() -> void:
	_login_dialog.disconnect("logged_in", self, "_on_logged_in")
	
func _on_logged_in() -> void:
	var character_selection_screen = load("res://Screens/CharacterSelectionScreen.tscn").instance()
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(character_selection_screen)
	queue_free()
