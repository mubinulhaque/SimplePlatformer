extends Node

signal level_completed # Has the level been completed?
signal heart_collected # Has a heart been collected?

var window_focused: bool = true # Is the window currently focused?
var check_for_window_focus: bool = true # Should we check for window focus?


# Check if the window is currently focused
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			window_focused = true
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			# First, check if we want to know whether the window is focused
			# If so, set it to false when this notification appears
			# Otherwise, set it to true
			window_focused = not check_for_window_focus


func _ready() -> void:
	ControllerIcons.input_type_changed.connect(_on_input_type_changed)
	
	# Set the background colour to black
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# Set the default audio buses
	SoundManager.set_default_ui_sound_bus("UI")
	SoundManager.set_default_sound_bus("Ingame")


func _on_input_type_changed(new_input_type: ControllerIcons.InputType) -> void:
	match new_input_type:
		ControllerIcons.InputType.CONTROLLER:
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
			Input.warp_mouse(Vector2.ZERO)
		ControllerIcons.InputType.KEYBOARD_MOUSE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.warp_mouse(Vector2(640, 360))


## Input methods
func create_new_input_event(input_action: StringName):
	var new_input_event = InputEventAction.new()
	new_input_event.action = input_action
	new_input_event.pressed = true
	Input.parse_input_event(new_input_event)
	await get_tree().create_timer(0.1).timeout
	new_input_event.pressed = false
	Input.parse_input_event(new_input_event)


func is_input_action_just_pressed(action: StringName) -> bool:
	return window_focused and Input.is_action_just_pressed(action)


func is_input_action_pressed(action: StringName) -> bool:
	return window_focused and Input.is_action_pressed(action)


func is_input_event_action_pressed(event: InputEvent, action: StringName) -> bool:
	return window_focused and event.is_action_pressed(action)


func get_input_axis(axis_negative: StringName, axis_positive: StringName) -> float:
	if window_focused:
		return Input.get_axis(axis_negative, axis_positive)
	else:
		return 0
