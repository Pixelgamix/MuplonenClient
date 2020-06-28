extends Control

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")
onready var _charactername:LineEdit = $Panel/LineEditCharactername
onready var _status:Label = $Panel/LabelStatus
onready var _create_button:Button = $Panel/ButtonCreate

#
# Engine
#
func _ready() -> void:
	_muplonen_network.register_message_callback(5, funcref(self, "_on_character_created_received"))

func _exit_tree():
	_muplonen_network.unregister_message_callback(5)

#
# Signals
#
signal creation_aborted
signal character_created

#
# Callbacks
#
func _on_ButtonBack_pressed() -> void:
	emit_signal("creation_aborted")

func _on_ButtonCreate_pressed() -> void:
	_muplonen_network.send_character_creation_request(_charactername.text.strip_edges())

func _on_character_created_received(buffer: StreamPeerBuffer) -> void:
	var is_success = buffer.get_u8()
	if is_success == 0:
		var message = buffer.get_string()
		_status.add_color_override("font_color",Color.red)
		_status.text = message
	else:
		emit_signal("character_created")

func _on_LineEditCharactername_text_changed(new_text):
	_create_button.disabled = _charactername.text.strip_edges().length() < 3
