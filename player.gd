extends CharacterBody2D

@export var movement_data : PlayerMovementData

@onready var sprite = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

var double_jump : bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
		
	# Handle wall jumping
	if is_on_wall():
		var wall_normal = get_wall_normal()
		if (
				not is_on_floor()
				and ((Input.is_action_just_pressed("game_left") and wall_normal == Vector2.LEFT)
				or (Input.is_action_just_pressed("game_right") and wall_normal == Vector2.RIGHT))
		):
			velocity.x = wall_normal.x * movement_data.speed
			velocity.y = movement_data.jump_velocity

	# Handle normal jumping
	if is_on_floor(): double_jump = true
	if Input.is_action_just_pressed("game_jump"):
		if (is_on_floor() or coyote_jump_timer.time_left > 0.0):
			# If the player is on the floor or has just left the floor
			velocity.y = movement_data.jump_velocity
		elif double_jump: # If the player is mid-air and can double jump
			velocity.y = movement_data.jump_velocity
			double_jump = false

	# Get the input direction and handle the movement/deceleration
	var horizontal_direction = Input.get_axis("game_left", "game_right")
	if horizontal_direction: # If the player wants to move horizontally
		if is_on_floor(): # If the player wants to move horizontally while on the ground
			velocity.x = move_toward(velocity.x, horizontal_direction * movement_data.speed,
					movement_data.acceleration * delta)
		else: # If the player wants to move horizontally while mid-air
			velocity.x = move_toward(velocity.x, horizontal_direction * movement_data.speed,
					movement_data.air_acceleration * delta)
		sprite.flip_h = (horizontal_direction < 0)
		sprite.play("run")
	elif is_on_floor(): #Decelerate the player via friction if the player is on the floor
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		sprite.play("idle")
	else: # Decelerate the player via air resistance if the player is mid-air
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)
		sprite.play("jump")
	
	# Change the sprite animation to be jumping if in the air
	# This has to be after the movement code,
	# otherwise the "run" animation can ovveride the animation
	if not is_on_floor(): sprite.play("jump")
		
	# Move while accounting for Coyote Time
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ground = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ground: # Has the player just left the ground and now falling
		coyote_jump_timer.start()
