extends Spatial

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")

var characters:Dictionary = {}

#
# Engine
#
func _ready() -> void:
	_muplonen_network.register_message_callback(8, funcref(self, "_self_enter_room_received"))
	_muplonen_network.register_message_callback(9, funcref(self, "_other_player_enter_room_received"))
	_muplonen_network.register_message_callback(10, funcref(self, "_other_player_left_room_received"))
	_muplonen_network.register_message_callback(11, funcref(self, "_other_player_moved_received"))
	
func _exit_tree() -> void:
	_muplonen_network.unregister_message_callback(8)
	_muplonen_network.unregister_message_callback(9)
	_muplonen_network.unregister_message_callback(10)
	_muplonen_network.unregister_message_callback(11)

#
# Callbacks
#
func _self_enter_room_received(buffer: StreamPeerBuffer) -> void:
	var num_others_in_room = buffer.get_u16()
	for index in range(num_others_in_room):
		var other_name = buffer.get_string()
		var other_x = buffer.get_16()
		var other_y = buffer.get_16()
		var other_z = buffer.get_16()
		var other_player = load("res://World/Entities/PlayerCharacter.tscn").instance()
		other_player.is_local_player = false
		other_player.player_name = other_name
		other_player.translation = Vector3(other_x, other_y, other_z)
		other_player.target_position = other_player.translation
		characters[other_name] = other_player
		add_child(other_player)
	
func _other_player_enter_room_received(buffer: StreamPeerBuffer) -> void:
	var other_name = buffer.get_string()
	var other_x = buffer.get_16()
	var other_y = buffer.get_16()
	var other_z = buffer.get_16()
	var other_player = load("res://World/Entities/PlayerCharacter.tscn").instance()
	other_player.is_local_player = false
	other_player.player_name = other_name
	other_player.translation = Vector3(other_x, other_y, other_z)
	other_player.target_position = other_player.translation
	characters[other_name] = other_player
	add_child(other_player)
	
func _other_player_left_room_received(buffer: StreamPeerBuffer) -> void:
	var other_name = buffer.get_string()
	if characters.has(other_name):
		var other_player = characters[other_name]
		characters.erase(other_name)
		remove_child(other_player)
		other_player.queue_free()
	
func _other_player_moved_received(buffer: StreamPeerBuffer) -> void:
	var other_name = buffer.get_string()
	var other_x = buffer.get_16()
	var other_y = buffer.get_16()
	var other_z = buffer.get_16()
	if characters.has(other_name):
		var other_player = characters[other_name]
		other_player.target_position = Vector3(other_x, other_y, other_z)
