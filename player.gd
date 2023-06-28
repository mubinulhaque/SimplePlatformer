extends CharacterBody2D

const SPEED = 100.0
const ACCELERATION = 600.0
const FRICTION = 1000.0
const JUMP_VELOCITY = -300.0

@onready var sprite = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if (is_on_floor() or coyote_jump_timer.time_left > 0.0) and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		sprite.flip_h = (direction < 0)
		sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		sprite.play("idle")
	
	#Change the sprite animation to be jumping if in the air
	#This has to be after the movement code, otherwise the "run" animation can ovveride the animation
	if not is_on_floor():
		sprite.play("jump")
		
	#Moving while accounting for Coyote Time
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ground = was_on_floor and not is_on_floor() and velocity.y >= 0 #Has the player just left the ground and now falling
	if just_left_ground:
		coyote_jump_timer.start()
