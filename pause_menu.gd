extends ColorRect

signal resume
signal retry

@onready var resume_button = %ResumeButton

func _ready():
	SoundManager.connect_ui_buttons($CenterContainer/VBoxContainer)


func _on_resume_button_pressed() -> void:
	resume.emit()


func _on_retry_button_pressed() -> void:
	retry.emit()


func _on_main_menu_button_pressed() -> void:
	pass # Replace with function body.
