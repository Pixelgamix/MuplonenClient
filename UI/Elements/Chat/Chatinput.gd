extends HBoxContainer
class_name Chatinput

onready var _line_edit: LineEdit = $LineEdit

signal chat_send

func _emit_chat_signal(message: String) -> void:
	emit_signal("chat_send", message)

func _on_ButtonSend_pressed() -> void:
	_emit_chat_signal(_line_edit.text)

func _on_LineEdit_text_entered(new_text):
	_emit_chat_signal(_line_edit.text)
	_line_edit.text = ""
