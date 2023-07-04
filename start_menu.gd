extends CenterContainer

func _on_start_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://level_one.tscn")
	LevelTransition.fade_from_black()


func _on_quit_button_pressed():
	get_tree().quit()

@onready var start_button = %StartButton

func _ready():
	start_button.grab_focus()
	pass
