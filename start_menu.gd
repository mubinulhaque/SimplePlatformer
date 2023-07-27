extends CenterContainer


func _ready():
	%StartButton.grab_focus()
	pass


func _on_start_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://level_1.tscn")
	LevelTransition.fade_from_black()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
