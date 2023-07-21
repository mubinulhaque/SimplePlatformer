extends Node2D

@export var next_level: PackedScene

# Amount of time passed in milliseconds since the start of the level
var level_time_passed: float = 0.0
# Amount of time passed in milliseconds by the time the level starts
var level_time_at_start: float = 0.0

@onready var level_completed: ColorRect = $CanvasLayer/LevelCompleted
@onready var countdown_player: AnimationPlayer = $CountdownPlayer
@onready var level_timer_label: Label = %LevelTimerLabel


func _ready():
	Events.level_completed.connect(_show_level_completed)
	
	# Fade from black, pause the game and start the countdown
	get_tree().paused = true
	await LevelTransition.fade_from_black()
	countdown_player.play("countdown")
	
	# Wait for the countdown to finish before unpausing
	await countdown_player.animation_finished
	get_tree().paused = false
	
	level_time_at_start = Time.get_ticks_msec()


func _process(_delta):
	level_time_passed = Time.get_ticks_msec() - level_time_at_start
	level_timer_label.text = str(level_time_passed / 1000)


func go_to_next_level():
	if not next_level is PackedScene: # If no next level has been chosen
		return # Do not run the rest of this procedure
	# Otherwise
	# Wait for the level transition to finish before changing scene
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)


func _show_level_completed():
	level_completed.show()
	level_completed.next_level_button.grab_focus()
	get_tree().paused = true


func _on_retry_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().reload_current_scene()
