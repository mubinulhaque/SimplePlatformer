extends ColorRect

signal retry()
signal next_level()

@onready var next_level_button: Button = %NextLevelButton


func _ready() -> void:
	SoundManager.connect_ui_buttons($CenterContainer/VBoxContainer)


func _on_retry_button_pressed() -> void:
	retry.emit()


func _on_next_level_button_pressed() -> void:
	next_level.emit()
