extends Node

signal level_completed # Has the level been completed?

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
	# Set the background colour to black
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# Set the default audio buses
	SoundManager.set_default_ui_sound_bus("UI")
	SoundManager.set_default_sound_bus("Ingame")


## Input methods
func is_input_action_just_pressed(action: StringName) -> bool:
	return window_focused and Input.is_action_just_pressed(action)


func is_input_action_pressed(action: StringName) -> bool:
	return window_focused and Input.is_action_pressed(action)


func is_input_event_action_pressed(event: InputEvent, action: StringName) -> bool:
	return window_focused and event.is_action_pressed(action)


func get_input_axis(axisX: StringName, axisY: StringName) -> float:
	# Godot currently has a bug that does not allow axis mappings and button
	# mappings on the same input action. This function checks the button
	# mappings first. If these return zero, it checks the axis mappings.
	if window_focused:
		var buttonAxis: float = Input.get_axis(axisX, axisY)
		if buttonAxis != 0:
			return buttonAxis
		else:
			return Input.get_axis(axisX + "_joystick", axisY + "_joystick")
	else:
		return 0
