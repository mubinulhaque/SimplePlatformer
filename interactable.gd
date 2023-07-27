class_name Interactable
extends Area2D
## Class used to define interactable objects that the player can touch
## 
## If extended, the only method to be overriden should be _interact().
## Anything else can interfere with collision checking.

var interacted_sound = SoundManager.POWERUP_SOUND

func _ready():
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: PhysicsBody2D):
	if body is Player:
		SoundManager.play_sound(interacted_sound)
		_interact(body)
		queue_free()


## Defines what happens when a player collides with the interactable.
func _interact(player: Player) -> void:
	print("Ability has been gained!")
