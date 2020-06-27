extends Spatial

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")

onready var target_position:Vector3 = translation

var is_local_player:bool = true
var player_name:String setget _set_player_name, _get_player_name

#
# Engine
#
func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta):
	var camera:Camera = get_viewport().get_camera()
	$Label.set_position(camera.unproject_position(translation))
	
func _physics_process(delta:float) -> void:
	if is_local_player:
		_handle_input()
	translation = translation.move_toward(target_position, delta)

#
# Private methods
#
func _handle_input() -> void:
	var moved:bool = false
	if Input.is_action_just_pressed("ui_left"):
		target_position.x -= 1
		moved = true
	elif Input.is_action_just_pressed("ui_right"):
		target_position.x += 1
		moved = true
	elif Input.is_action_just_pressed("ui_up"):
		target_position.z -= 1
		moved = true
	elif Input.is_action_just_pressed("ui_down"):
		target_position.z += 1
		moved = true
	if moved:
		_muplonen_network.send_player_move(target_position)

func _get_player_name() -> String:
	return $Label.text
	
func _set_player_name(value:String) -> void:
	$Label.text = value
