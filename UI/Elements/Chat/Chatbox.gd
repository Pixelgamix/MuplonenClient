extends VBoxContainer
class_name Chatbox

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")
onready var _chat_viewer:Chatviewer = $Chatviewer
onready var _chat_input:Chatinput = $Chatinput

func _ready() -> void:
	_muplonen_network.register_message_callback(3, funcref(self, "_on_chat_message_received"))
	_chat_input.connect("chat_send", self, "_on_chat_send")

func _exit_tree() -> void:
	_muplonen_network.unregister_message_callback(3)

func _on_chat_send(message: String) -> void:
	_muplonen_network.send_chat_message(message)

func _on_chat_message_received(buffer: StreamPeerBuffer) -> void:
	var playername = buffer.get_string()
	var message = buffer.get_string()
	_chat_viewer.add_entry(playername, message)
