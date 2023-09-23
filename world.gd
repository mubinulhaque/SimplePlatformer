extends Node2D

@export var next_level: PackedScene

var current_room_size: Vector2 = Vector2.ZERO
var current_room_centre: Vector2 = Vector2.ZERO
# Amount of time passed in milliseconds since the start of the level
var level_time_passed: float = 0.0
# Amount of time passed in milliseconds by the time the level starts
var level_time_at_start: float = 0.0
var starting_number_of_hearts : int = 0

@onready var level_completed: ColorRect = $UserInterface/LevelCompleted
@onready var countdown_player: AnimationPlayer = $CountdownPlayer
@onready var level_timer_label: Label = %LevelTimerLabel
@onready var player = $Player
@onready var pause_menu = $UserInterface/PauseMenu
@onready var controller_disconnected_popup = $UserInterface/ControllerDisconnectedPopup
@onready var camera = $Camera2D
@onready var heart_counter = $UserInterface/LevelTimer/HeartCounter/HeartCounterLabel


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	Events.heart_collected.connect(_on_heart_collected)
	Events.level_completed.connect(_show_level_completed)
	
	# Count the number of hearts
	var hearts = get_tree().get_nodes_in_group("hearts")
	starting_number_of_hearts = hearts.size()
	heart_counter.text = str(hearts.size()) + "/" + str(hearts.size())
	
	# Fade from black, pause the game and start the countdown
	get_tree().paused = true
	await LevelTransition.fade_from_black()
	countdown_player.play("countdown")
	
	# Wait for the countdown to finish before unpausing
	await countdown_player.animation_finished
	get_tree().paused = false
	
	level_time_at_start = Time.get_ticks_msec()


func _physics_process(_delta):
	# Handle camera movement
	# The minimum space between the camera's x position and the room's length
	var x_margin: float = (current_room_size.x - get_viewport_rect().size.x) / 2
	# The minimum space between the camera's y position and the room's height
	var y_margin: float = (current_room_size.y - get_viewport_rect().size.y) / 2
	
	var new_camera_position : Vector2 = Vector2.ZERO
	
	# If the width of the current room is smaller than the viewport's width
	if x_margin <= 0:
		new_camera_position.x = current_room_centre.x
	# If the width of the current room is not smaller than the viewport's width
	else:
		# Bind the camera to the player while also respecting the margin
		new_camera_position.x = clamp(player.position.x, 
				current_room_centre.x - x_margin, 
				current_room_centre.x + x_margin)
	
	# If the height of the current room is smaller than the viewport's height
	if y_margin <= 0:
		new_camera_position.y = current_room_centre.y
	# If the height of the current room is not smaller than the viewport's height
	else:
		# Bind the camera to the player while also respecting the margin
		new_camera_position.y = clamp(player.position.y,
				current_room_centre.y - y_margin,
				current_room_centre.y + y_margin)
	
	camera.position = lerp(camera.position, new_camera_position, 0.1)


func _process(_delta) -> void:
	# Calculate the time it takes for the player to finish the level
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


func _pause() -> void:
	get_tree().paused = true
	pause_menu.visible = true
	pause_menu.pause_time_at_start = Time.get_ticks_msec()
	pause_menu.resume_button.grab_focus.call_deferred()


func _resume(time_offset: float) -> void:
	get_tree().paused = false
	pause_menu.visible = false
	level_time_at_start += time_offset


func _on_joy_connection_changed(_device_id: int, connected: bool):
	if not connected:
		controller_disconnected_popup.show()
		controller_disconnected_popup.okay_button.grab_focus.call_deferred()
		get_tree().paused = true


func _on_controller_reconnected() -> void:
	get_tree().paused = false


func _on_new_room_entered(room_size: Vector2, room_centre: Vector2) -> void:
	current_room_size = room_size
	current_room_centre = room_centre


func _on_heart_collected() -> void:
	var hearts = get_tree().get_nodes_in_group("hearts")
	heart_counter.text = str(hearts.size() - 1) + "/" + str(starting_number_of_hearts)
