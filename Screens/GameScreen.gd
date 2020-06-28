extends Spatial

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")

#
# Engine
#
func _ready() -> void:
	_muplonen_network.connect("connection_closed", self, "_on_connection_closed")
	

#
# Public methods
#
func spawn_local_player(player_name:String) -> void:
	var local_player:PlayerCharacter = load("res://World/Entities/PlayerCharacter.tscn").instance()
	local_player.player_name = player_name
	local_player.is_local_player = true
	$Player.add_child(local_player)

#
# Callbacks
#
func _on_connection_closed() -> void:
	var login_screen = load("res://Screens/LoginScreen.tscn").instance()
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(login_screen)
	queue_free()
