extends Node2D

@export var next_level: PackedScene

@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var countdown_player = $CountdownPlayer


func _ready():
	Events.level_completed.connect(_show_level_completed)
	
	# Fade from black, pause the game and start the countdown
	get_tree().paused = true
	await LevelTransition.fade_from_black()
	countdown_player.play("countdown")
	
	# Wait for the countdown to finish before unpausing
	await countdown_player.animation_finished
	get_tree().paused = false


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
