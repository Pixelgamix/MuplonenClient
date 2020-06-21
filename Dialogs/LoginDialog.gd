extends Control


export var websocket_url:String = "ws://localhost:5000/ws"

var _client:WebSocketClient = WebSocketClient.new()
var _read_buffer:StreamPeerBuffer = StreamPeerBuffer.new()
var _write_buffer:StreamPeerBuffer = StreamPeerBuffer.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)

func _closed(was_clean:bool = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto:String = ""):
	print("Connected with protocol: ", proto)
	
func _on_data():
	_read_buffer.data_array = _client.get_peer(1).get_packet()
	print("Got data from server: ", _read_buffer.get_string())

func _process(delta):
	_client.poll()

func _on_ButtonLogin_pressed():
	_write_buffer.clear()
	_write_buffer.put_u16(1)
	_write_buffer.put_string($Panel/LineEditUsername.text)
	_write_buffer.put_string($Panel/LineEditPassword.text)
	_client.get_peer(1).put_packet( _write_buffer.data_array )
