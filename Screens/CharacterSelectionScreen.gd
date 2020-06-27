extends Node

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")
onready var _selection_dialog = $CenterContainer/CharacterSelectionDialog

#
# Engine
#
func _ready() -> void:
	_muplonen_network.connect("connection_closed", self, "_on_connection_closed")
	_selection_dialog.connect("character_creation", self, "_on_character_creation")
	_selection_dialog.connect("character_selected", self, "_on_character_selected")

func _exit_tree() -> void:
	_muplonen_network.disconnect("connection_closed", self, "_on_connection_closed")
	_selection_dialog.disconnect("character_creation", self, "_on_character_creation")
	_selection_dialog.disconnect("character_selected", self, "_on_character_selected")

#
# Callbacks
#	
func _on_connection_closed() -> void:
	var login_screen = load("res://Screens/LoginScreen.tscn").instance()
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(login_screen)
	queue_free()

func _on_character_selected(charactername:String) -> void:
	var game_ui = load("res://Screens/GameScreen.tscn").instance()
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(game_ui)
	queue_free()

func _on_character_creation() -> void:
	var creation_scene = load("res://Screens/CharacterCreationScreen.tscn").instance()
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(creation_scene)
	queue_free()
