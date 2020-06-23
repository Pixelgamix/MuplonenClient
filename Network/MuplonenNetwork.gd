extends Node

#
# Handles network interaction with the Muplonen Server
#

const websocket_url:String = "ws://localhost:5000/ws"
const timeout:float = 30.0;

var _client:WebSocketClient = WebSocketClient.new()
var _read_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
var _write_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
var _message_registrations = {}
var _time_since_last_msg = 0

#
# Signals
#
signal connection_closed

#
# Engine
#
func _ready() -> void:
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

func _exit_tree() -> void:
	_client.disconnect_from_host()
	
func _process(delta: float) -> void:
	_client.poll()
	_time_since_last_msg += delta
	if _time_since_last_msg > timeout:
		_time_since_last_msg = 0
		disconnect_from_server()

#
# Callbacks
#
func _closed(was_clean:bool = false) -> void:
	_time_since_last_msg = 0
	_client.disconnect_from_host()
	set_process(false)
	emit_signal("connection_closed")

func _connected(proto:String = "") -> void:
	_time_since_last_msg = 0
	
func _on_data() -> void:
	_time_since_last_msg = 0
	_read_buffer.data_array = _client.get_peer(1).get_packet()
	var message_id = _read_buffer.get_u16()
	var callback = _message_registrations[message_id]
	callback.call_func(_read_buffer)

#
# Public methods
#
func is_connected_to_server() -> bool:
	return _client.get_connection_status() == 2

func connect_to_server() -> void:
	_client.disconnect_from_host()
	_client.connect_to_url(websocket_url)
	set_process(true)
	
func disconnect_from_server() -> void:
		_client.disconnect_from_host()
	
func register_message_callback(message_id:int, var callback) -> void:
	_message_registrations[message_id] = callback
	
func unregister_message_callback(message_id:int) -> void:
	_message_registrations.erase(message_id)

func send_account_registration_message(username:String, password:String) -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(1)
	_write_buffer.put_string(username)
	_write_buffer.put_string(password)
	_client.get_peer(1).put_packet(_write_buffer.data_array)
	
func send_account_login_message(username:String, password:String) -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(2)
	_write_buffer.put_string(username)
	_write_buffer.put_string(password)
	_client.get_peer(1).put_packet(_write_buffer.data_array)

func send_chat_message(message:String) -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(3)
	_write_buffer.put_string(message)
	_client.get_peer(1).put_packet(_write_buffer.data_array)
