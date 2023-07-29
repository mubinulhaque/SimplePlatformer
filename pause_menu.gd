extends ColorRect

signal resume
signal retry

@onready var resume_button = %ResumeButton


func _ready() -> void:
	SoundManager.connect_ui_buttons($CenterContainer/VBoxContainer)


func _input(event) -> void:
	# Defocus all buttons when a mouse button is clicked
	# By focusing on a non focusable Control node
	if event is InputEventMouseButton:
		$ControllerTextureRect.grab_focus()


func _on_resume_button_pressed() -> void:
	resume.emit()


func _on_retry_button_pressed() -> void:
	retry.emit()


func _on_main_menu_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	LevelTransition.fade_from_black()
