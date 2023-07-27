extends Node2D

@export var next_level: PackedScene

# Amount of time passed in milliseconds since the start of the level
var level_time_passed: float = 0.0
# Amount of time passed in milliseconds by the time the level starts
var level_time_at_start: float = 0.0

@onready var level_completed: ColorRect = $UserInterface/LevelCompleted
@onready var countdown_player: AnimationPlayer = $CountdownPlayer
@onready var level_timer_label: Label = %LevelTimerLabel
@onready var player = $Player
@onready var pause_menu = $UserInterface/PauseMenu
@onready var ui_sound_player = $UserInterfaceSoundPlayer
@onready var top_left_room_limit = $TopLeftRoomLimit
@onready var bottom_right_room_limit = $BottomRightRoomLimit


func _ready():
	Events.level_completed.connect(_show_level_completed)
	
	# Fade from black, pause the game and start the countdown
	get_tree().paused = true
	player.set_camera_limits(top_left_room_limit, bottom_right_room_limit)
	await LevelTransition.fade_from_black()
	countdown_player.play("countdown")
	
	# Wait for the countdown to finish before unpausing
	await countdown_player.animation_finished
	get_tree().paused = false
	
	level_time_at_start = Time.get_ticks_msec()


func _process(_delta):
	level_time_passed = Time.get_ticks_msec() - level_time_at_start
	level_timer_label.text = str(level_time_passed / 1000)


func go_to_next_level() -> void:
	if not next_level is PackedScene: # If no next level has been chosen
		return # Do not run the rest of this procedure
	# Otherwise
	# Wait for the level transition to finish before changing scene
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)


func _on_retry_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _show_level_completed() -> void:
	level_completed.show()
	level_completed.next_level_button.grab_focus()
	get_tree().paused = true


func _pause(to_pause: bool) -> void:
	if to_pause:
		pause_menu.resume_button.grab_focus.call_deferred()
	get_tree().paused = to_pause
	pause_menu.visible = to_pause
