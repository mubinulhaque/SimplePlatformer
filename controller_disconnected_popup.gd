extends ColorRect

signal controlled_reconnected

@onready var okay_button = $CenterContainer/VBoxContainer/OkayButton


func _ready():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _on_joy_connection_changed(_device_id: int, connected: bool):
	if connected:
		_hide_popup()


func _hide_popup():
	print("Controller reconnected!")
	controlled_reconnected.emit()
	hide()
