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
var _ping_sent:bool = false

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
	if _time_since_last_msg > timeout * 0.5 && !_ping_sent && is_connected_to_server():
		_ping_sent = true
		send_ping_request()
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
	_ping_sent = false
	_read_buffer.data_array = _client.get_peer(1).get_packet()
	var message_id = _read_buffer.get_u16()
	if _message_registrations.has(message_id):
		var callback = _message_registrations[message_id]
		callback.call_func(_read_buffer)

#
# Public methods
#
func is_connected_to_server() -> bool:
	return _client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED

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

func send_character_list_request() -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(4)
	_client.get_peer(1).put_packet(_write_buffer.data_array)

func send_character_creation_request(charactername:String) -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(5)
	_write_buffer.put_string(charactername)
	_client.get_peer(1).put_packet(_write_buffer.data_array)

func send_character_selection_request(charactername:String) -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(6)
	_write_buffer.put_string(charactername)
	_client.get_peer(1).put_packet(_write_buffer.data_array)

func send_ping_request() -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(7)
	_client.get_peer(1).put_packet(_write_buffer.data_array)

func send_player_move(position:Vector3) -> void:
	_write_buffer.clear()
	_write_buffer.put_u16(8);
	_write_buffer.put_16(position.x)
	_write_buffer.put_16(position.y)
	_write_buffer.put_16(position.z)
	_client.get_peer(1).put_packet(_write_buffer.data_array)
