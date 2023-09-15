extends ColorRect

signal resume
signal retry

@onready var resume_button = %ResumeButton


func _ready() -> void:
	SoundManager.connect_ui_buttons($CenterContainer/VBoxContainer)


func _on_resume_button_pressed() -> void:
	resume.emit()


func _on_retry_button_pressed() -> void:
	retry.emit()


func _on_main_menu_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	LevelTransition.fade_from_black()
