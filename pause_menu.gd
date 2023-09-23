extends ColorRect

signal resume(time_offset: float)
signal retry

@onready var resume_button = %ResumeButton
# Amount of time passed in milliseconds when the pause menu becomes visible
var pause_time_at_start: float = 0.0
# Amount of time passed in milliseconds while paused
var pause_time_passed: float = 0.0


func _ready() -> void:
	SoundManager.connect_ui_buttons($CenterContainer/VBoxContainer)

func _process(_delta):
	pause_time_passed = Time.get_ticks_msec() - pause_time_at_start


func _on_resume_button_pressed() -> void:
	resume.emit(pause_time_passed)


func _on_retry_button_pressed() -> void:
	retry.emit()


func _on_main_menu_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://start_menu.tscn")
	LevelTransition.fade_from_black()
