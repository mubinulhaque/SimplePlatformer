extends ColorRect

signal resume
signal retry

@onready var resume_button = %ResumeButton


func _on_resume_button_pressed():
	resume.emit()


func _on_retry_button_pressed():
	retry.emit()


func _on_main_menu_button_pressed():
	pass # Replace with function body.
