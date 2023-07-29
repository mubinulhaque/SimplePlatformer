extends ColorRect

signal retry()
signal next_level()

@onready var next_level_button: Button = %NextLevelButton


func _ready() -> void:
	SoundManager.connect_ui_buttons($CenterContainer/VBoxContainer)


func _input(event) -> void:
	# Defocus all buttons when a mouse button is clicked
	# By focusing on a non focusable Control node
	if event is InputEventMouseButton:
		$ControllerTextureRect.grab_focus()


func _on_retry_button_pressed() -> void:
	retry.emit()


func _on_next_level_button_pressed() -> void:
	next_level.emit()
