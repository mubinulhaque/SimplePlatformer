extends Node2D

func _show_level_completed():
	level_completed.show()
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout # Wait for 1 second
	if not next_level is PackedScene: # If no next level has been chosen
		return # Do not run the rest of this procedure
	# Otherwise
	# Wait for the level transition to finish before changing scene
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()

@export var next_level: PackedScene

@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	Events.level_completed.connect(_show_level_completed)
