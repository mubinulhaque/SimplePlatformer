extends CharacterBody2D

# If the player has collided with a hazard
func _on_hazard_detector_area_entered(area):
	print("Collided with hazard!")
	global_position = starting_position

@export var movement_data : PlayerMovementData

var can_double_jump : bool = false
var wall_jumping : bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

@onready var sprite = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
		
	# Handle wall jumping
	if is_on_wall_only() and Input.is_action_just_pressed("game_jump"):
		# If the player is only colliding with a wall (and not the floor)
		# and wants to jump
		var wall_normal = get_wall_normal()
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		sprite.flip_h = (velocity.x < 0)
		wall_jumping = true

	# Handle normal jumping
	if is_on_floor(): 
		can_double_jump = true
	
	# Handle double jumping 
	if Input.is_action_just_pressed("game_jump"):
		if (is_on_floor() or coyote_jump_timer.time_left > 0.0):
			# If the player is on the floor or has just left the floor
			velocity.y = movement_data.jump_velocity
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
		sprite.play("jump")
	
	# Change the sprite animation to be jumping if in the air
	# This has to be after the movement code,
	# otherwise the "run" animation can ovveride the animation
	if not is_on_floor():
		sprite.play("jump")
		
	# Move while accounting for Coyote Time
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ground = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ground: # If the player just left the ground and now falling
		coyote_jump_timer.start()
		
	wall_jumping = false
