extends ScrollContainer
class_name Chatviewer

const max_entries = 5

var _current_entry_count = 0

onready var _chat_entries: VBoxContainer = $Chatentries

func add_entry(username:String, message:String) -> void:
	_current_entry_count += 1
	if _current_entry_count > max_entries:
		_current_entry_count -= 1
		_chat_entries.remove_child(_chat_entries.get_child(0))
	
	var label: Label = Label.new()
	label.text = username + " said: " + message
	_chat_entries.add_child(label)
