extends CenterContainer


func _ready() -> void:
	get_tree().paused = false
	%StartButton.grab_focus.call_deferred()
	SoundManager.connect_ui_buttons.call_deferred($VBoxContainer)
	pass


func _on_start_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://level_1.tscn")
	LevelTransition.fade_from_black()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
