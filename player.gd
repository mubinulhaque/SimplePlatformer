class_name Player
extends CharacterBody2D
## Class used for controlling the player
##
## The only things to be used here are unlock_double_jump() and 
## unlock_wall_jump(). Anything else might interfere with the player's movement.

# Pause the game
signal pause

## Controls how the player moves through its environment
@export var movement_data : PlayerMovementData

var alive: bool = true
## Whether the player has unlocked the double jump ability
var unlocked_double_jump: bool = false
## Whether the player has unlocked the wall jump ability
var unlocked_wall_jump: bool = false
## Whether the player has used their double jump ability yet.[br]
## Note: This will always be false if unlocked_double_jump is false.
var can_double_jump: bool = false
## Whether the player is currently wall-jumping.
## Used to stop the player from double-jumping and wall-jumping at the same time.
var wall_jumping: bool = false
## The gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
## The normal of the last wall that the player has collided with.
## Used to ensure the player can still wall jump for a small timeframe
## after the player has left the wall.
var last_wall_normal: Vector2 = Vector2.ZERO
var death_velocity: Vector2 = Vector2.UP

## The animated sprite used to represent the player
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
## The timer used to allow jumping for a small timeframe after the player
## has left the ground
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer
## The timer used to allow wall-jumping for a small timeframe after the player
## has left a wall
@onready var wall_jump_timer: Timer = $WallJumpTimer
## The position the player was at when they started the level.
## Used to reset the player's position if they die.
@onready var starting_position: Vector2 = global_position
@onready var collision_shape = $CollisionShape2D
@onready var camera = $Camera2D


func _physics_process(delta):
	# Handle the pause menu
	if Input.is_action_just_pressed("game_pause"):
		pause.emit()
	
	if alive:
		# Add the gravity
		if not is_on_floor():
			velocity.y += gravity * movement_data.gravity_scale * delta
			
		# Handle wall jumping
		if ((is_on_wall_only() or wall_jump_timer.time_left > 0.0)
				and Input.is_action_just_pressed("game_jump")
				and unlocked_wall_jump):
			# If the player is only colliding with a wall (and not the floor)
			# or has just left the wall and wants to jump
			var wall_normal: Vector2 = get_wall_normal()
			
			if wall_jump_timer.time_left > 0.0: # If the player has just left the wall
				# Get the old wall normal since get_wall_normal() only returns
				# a value if the player is colliding with a wall
				wall_normal = last_wall_normal
			
			velocity.x = wall_normal.x * movement_data.speed
			velocity.y = movement_data.jump_velocity
			sprite.flip_h = (velocity.x < 0)
			wall_jumping = true

		# Allow double jumping if the player is on the floor
		if is_on_floor() and unlocked_double_jump: 
			can_double_jump = true
		
		# Handle jumping 
		if Input.is_action_just_pressed("game_jump"):
			if is_on_floor() or coyote_jump_timer.time_left > 0.0:
				# If the player is on the floor or has just left the floor
				velocity.y = movement_data.jump_velocity
				coyote_jump_timer.stop()
				SoundManager.play_sound(SoundManager.JUMP_SOUND)
			elif can_double_jump and not wall_jumping:
				# If the player is mid-air and can double jump
				velocity.y = movement_data.jump_velocity
				can_double_jump = false

		# Get the input direction and handle the movement/deceleration
		var horizontal_direction = Input.get_axis("game_left", "game_right")
		if horizontal_direction: # If the player wants to move horizontally
			if is_on_floor():
				# If the player wants to move horizontally while on the ground
				velocity.x = move_toward(velocity.x, horizontal_direction
						* movement_data.speed, movement_data.acceleration * delta)
			else: # If the player wants to move horizontally while mid-air
				velocity.x = move_toward(velocity.x, horizontal_direction
						* movement_data.speed, movement_data.air_acceleration * delta)
			sprite.flip_h = (horizontal_direction < 0)
			sprite.play("run")
		elif is_on_floor():
			# Decelerate the player via friction if the player is on the floor
			velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
			sprite.play("idle")
		else:
			# Decelerate the player via air resistance if the player is mid-air
			velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)
		
		# Change the sprite animation to be jumping if in the air
		# This has to be after the movement code,
		# otherwise the "run" animation can override the animation
		if not is_on_floor():
			sprite.play("jump")
			
		# Check for the player colliding with the level
		var was_on_floor = is_on_floor()
		var was_on_wall = is_on_wall_only()
		
		# Update old wall normal
		if was_on_wall:
			last_wall_normal = get_wall_normal()
		
		move_and_slide()
		
		# Start the Coyote Timer
		var just_left_ground = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ground: # If the player just left the ground and now falling
			coyote_jump_timer.start()
		
		# Start the Wall Jump Timer
		var just_left_wall = was_on_wall and not is_on_wall_only()
		if just_left_wall:
			wall_jump_timer.start()
		
		# Set wall jumping to false so that players can wall jump again
		wall_jumping = false
	else:
		move_and_slide()
		velocity.x = move_toward(velocity.x, 0, gravity * delta)
		velocity.y = move_toward(velocity.y, 0, gravity * delta)
		
		if velocity == Vector2.ZERO:
			SoundManager.play_sound(SoundManager.DEATH_SOUND)
			global_position = starting_position
			sprite.play("idle")
			collision_shape.set_deferred("disabled", false)
			alive = true


func _on_hazard_detector_area_entered(_area):
	# When the player touches a hazard, play a death animation
	# and then reset their position
	if alive:
		velocity = -velocity.normalized() * 300
		sprite.play("death")
		collision_shape.set_deferred("disabled", true)
		SoundManager.play_sound(SoundManager.HURT_SOUND)
		alive = false


func set_camera_limits(top_left_position: Marker2D,
		bottom_right_position: Marker2D):
	camera.limit_left = top_left_position.position.x
	camera.limit_top = top_left_position.position.y
	camera.limit_right = bottom_right_position.position.x
	camera.limit_bottom = bottom_right_position.position.y
