extends Node

signal level_completed # Has the level been completed?


func _ready():
	# Set the default audio buses
	SoundManager.set_default_ui_sound_bus("UI")
	SoundManager.set_default_sound_bus("Ingame")
