extends Control

onready var _result_label:Label = $Panel/LabelResult
onready var _muplonen_network = get_node("/root/MuplonenNetwork")

var _function_to_execute_after_connect: String = ""

func _ready() -> void:
	_muplonen_network.register_message_callback(1, funcref(self, "_registration_reply_received"))
	_muplonen_network.register_message_callback(2, funcref(self, "_login_reply_received"))

func _process(delta: float) -> void:
	if _muplonen_network.is_connected_to_server() && _function_to_execute_after_connect != "":
		call(_function_to_execute_after_connect)
		_function_to_execute_after_connect = ""

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
		_muplonen_network.disconnect_from_server()

func _on_ButtonLogin_pressed() -> void:
	_muplonen_network.connect_to_server()
	_function_to_execute_after_connect = "do_login"

func _on_ButtonRegister_pressed() -> void:
	_muplonen_network.connect_to_server()
	_function_to_execute_after_connect = "do_register"

func do_login() -> void:
	_muplonen_network.send_account_login_message($Panel/LineEditUsername.text,$Panel/LineEditPassword.text)

func do_register() -> void:
	_muplonen_network.send_account_registration_message($Panel/LineEditUsername.text,$Panel/LineEditPassword.text)
