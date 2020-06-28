extends Control

#
# Private members
#
onready var _result_label:Label = $Panel/LabelResult
onready var _login_button:Button = $Panel/ButtonLogin
onready var _register_button:Button = $Panel/ButtonRegister
onready var _login_lineedit:LineEdit = $Panel/LineEditUsername
onready var _password_lineedit:LineEdit = $Panel/LineEditPassword
onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")
var _function_to_execute_after_connect: String = ""

#
# Signals
#
signal logged_in

#
# Engine
#
func _ready() -> void:
	_muplonen_network.register_message_callback(1, funcref(self, "_registration_reply_received"))
	_muplonen_network.register_message_callback(2, funcref(self, "_login_reply_received"))
	
func _exit_tree() -> void:
	_muplonen_network.unregister_message_callback(1)
	_muplonen_network.unregister_message_callback(2)

func _process(delta: float) -> void:
	if _muplonen_network.is_connected_to_server() && _function_to_execute_after_connect != "":
		call(_function_to_execute_after_connect)
		_function_to_execute_after_connect = ""

#
# Callbacks
#
func _registration_reply_received(buffer: StreamPeerBuffer) -> void:
	var success = buffer.get_u8()
	if success == 0:
		_result_label.add_color_override("font_color",Color.red)
	else:
		_result_label.add_color_override("font_color",Color.green)
	var text = buffer.get_string()
	_result_label.text = text
	
func _login_reply_received(buffer: StreamPeerBuffer) -> void:
	var success = buffer.get_u8()
	var text = buffer.get_string()
	if success == 0:
		_result_label.add_color_override("font_color",Color.red)
		_result_label.text = text
	else:
		_result_label.add_color_override("font_color",Color.green)
		_result_label.text = "Login successfull!"
		emit_signal("logged_in")

func _on_ButtonLogin_pressed() -> void:
	_muplonen_network.connect_to_server()
	_function_to_execute_after_connect = "do_login"

func _on_LineEditPassword_text_entered(new_text):
	_muplonen_network.connect_to_server()
	_function_to_execute_after_connect = "do_login"

func _on_ButtonRegister_pressed() -> void:
	_muplonen_network.connect_to_server()
	_function_to_execute_after_connect = "do_register"

func _on_LineEditUsername_text_changed(new_text:String) -> void:
	_login_button.disabled = new_text.strip_edges().length() < 3 || _password_lineedit.text.length() < 3
	_register_button.disabled = new_text.strip_edges().length() < 3 || _password_lineedit.text.length() < 3
	
func _on_LineEditPassword_text_changed(new_text:String) -> void:
	_login_button.disabled = new_text.strip_edges().length() < 3 || _password_lineedit.text.length() < 3
	_register_button.disabled = new_text.strip_edges().length() < 3 || _password_lineedit.text.length() < 3

#
# Private methods
#
func do_login() -> void:
	_muplonen_network.send_account_login_message(_login_lineedit.text.strip_edges(),_password_lineedit.text)

func do_register() -> void:
	_muplonen_network.send_account_registration_message(_login_lineedit.text.strip_edges(),_password_lineedit.text)
