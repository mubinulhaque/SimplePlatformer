class_name Ability
extends Area2D
## Class used to define unlockable abilities that the player can get
## 
## If extended, the only method to be overriden should be _gain_ability().
## Anything else can interfere with collision checking.


func _ready():
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: PhysicsBody2D):
	if body is Player:
		_gain_ability(body)
		queue_free()


## Defines what happens when a player collides with the ability.
func _gain_ability(player: Player) -> void:
	print("Ability has been gained!")
