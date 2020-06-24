extends Node

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")
onready var _creation_dialog = $CenterContainer/CharacterCreationDialog

#
# Engine
#
func _ready() -> void:
	_muplonen_network.connect("connection_closed", self, "_on_connection_closed")
	_creation_dialog.connect("character_created", self, "_on_character_created")
	_creation_dialog.connect("creation_aborted", self, "_on_creation_aborted")

func _exit_tree() -> void:
	_muplonen_network.disconnect("connection_closed", self, "_on_connection_closed")

#
# Callbacks
#	
func _on_connection_closed() -> void:
	var login_screen = load("res://Screens/LoginScreen.tscn").instance()
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(login_screen)
	queue_free()

func _on_character_created() -> void:
	_go_to_character_selection()
	
func _on_creation_aborted() -> void:
	_go_to_character_selection()
	
#
# Private methods
#
func _go_to_character_selection() -> void:
	var selection_screen = load("res://Screens/CharacterSelectionScreen.tscn").instance()
	var parent = get_parent()
	parent.remove_child(self);
	parent.add_child(selection_screen)
	queue_free()
