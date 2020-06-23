extends Node

onready var _user_interface = $UserInterface
onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")

var _login_dialog_template = preload("res://UI/Dialogs/LoginDialog.tscn")
var _login_dialog:LoginDialog

var _game_ui_template = preload("res://UI/GameUi.tscn")
var _game_ui

#
# Engine
#
func _ready():
	_muplonen_network.connect("connection_closed", self, "_on_connection_closed")
	_show_login_dialog()

#
# Private methods
#
func _show_login_dialog() -> void:
	_login_dialog = _login_dialog_template.instance()
	_login_dialog.connect("logged_in", self, "_on_logged_in")
	_user_interface.add_child(_login_dialog)
	
func _close_login_dialog() -> void:
	_login_dialog.disconnect("logged_in", self, "_on_logged_in")
	_user_interface.remove_child(_login_dialog)
	_login_dialog.queue_free()
	
func _go_to_login_screen() -> void:
	_user_interface.remove_child(_game_ui)
	_game_ui.queue_free()
	_show_login_dialog()

#
# Callbacks
#
func _on_logged_in() -> void:
	_close_login_dialog()
	_game_ui = _game_ui_template.instance()
	_user_interface.add_child(_game_ui)

func _on_connection_closed() -> void:
	_go_to_login_screen()
