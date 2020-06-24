extends VBoxContainer

onready var _muplonen_network:MuplonenNetwork = get_node("/root/MuplonenNetwork")
onready var _label_character_name:Label = $LabelCharacterName
onready var _selection_button:Button = $ButtonSelect

var _characters:Array = Array()
var _current_index = 0

#
# Signals
#
signal character_selected
signal character_creation

#
# Engine
#
func _ready() -> void:
	_muplonen_network.register_message_callback(4, funcref(self, "_character_list_reply_received"))
	_muplonen_network.register_message_callback(6, funcref(self, "_character_selection_reply_received"))
	_muplonen_network.send_character_list_request()
	
func _exit_tree() -> void:
	_muplonen_network.unregister_message_callback(4)
	_muplonen_network.unregister_message_callback(6)

#
# Callbacks
#
func _character_list_reply_received(buffer: StreamPeerBuffer) -> void:
	var character_count = buffer.get_u8()
	for x in range(character_count):
		var character_name = buffer.get_string()
		var character_created_at = buffer.get_string()
		_characters.append(character_name)
	if character_count > 0:
		_selection_button.disabled = false
		_show_current_index_character()
		
func _character_selection_reply_received(buffer: StreamPeerBuffer) -> void:
	emit_signal("character_selected", _characters[_current_index])

func _show_current_index_character() -> void:
	if _current_index < _characters.size():
		_label_character_name.text = _characters[_current_index]

func _on_ButtonPrevious_pressed():
	if _current_index > 0:
		_current_index -= 1
	_show_current_index_character()

func _on_ButtonNext_pressed():
	if _current_index < _characters.size() - 1:
		_current_index += 1
	_show_current_index_character()
	
func _on_ButtonCreate_pressed():
	emit_signal("character_creation")

func _on_ButtonSelect_pressed():
	_muplonen_network.send_character_selection_request(_characters[_current_index])
